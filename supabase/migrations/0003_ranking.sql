-- 0003_ranking — mechanika rankingu parowego i personalizacji.
--
-- ZASADA BABCI: nigdzie w tym pliku nie powstaje "średnia ocena miejsca".
-- Każda liczba, którą widzi użytkownik, jest liczona DLA NIEGO — z jego własnego
-- rankingu i z rankingów jego znajomych ważonych zbieżnością gustu. Miejsce
-- świetne dla jednej osoby ma prawo mieć niski wynik u drugiej i to jest cecha,
-- nie błąd.

-- Zakresy score dla kubełków. Kubełek decyduje o przedziale, pozycja o miejscu w nim.
create or replace function bucket_bounds(b ranking_bucket)
returns table (lo numeric, hi numeric)
language sql immutable as $$
  select case b when 'liked' then 6.7 when 'fine' then 3.4 else 0.0 end,
         case b when 'liked' then 10.0 when 'fine' then 6.6 else 3.3 end;
$$;

-- Przelicza score całej kategorii użytkownika z pozycji. Pozycja jest prawdą,
-- score wyłącznie jej czytelną projekcją.
create or replace function rank_recompute(target_user uuid, cat place_category)
returns void
language sql security definer set search_path = public as $$
  with sized as (
    select r.place_id, r.bucket, r.position,
           count(*) over (partition by r.bucket) as n
      from rankings r
     where r.user_id = target_user and r.category = cat
  )
  update rankings t
     set score = round(b.hi - (b.hi - b.lo) * (s.position - 1) / greatest(1, s.n - 1), 1),
         updated_at = now()
    from sized s, lateral bucket_bounds(s.bucket) b
   where t.user_id = target_user and t.category = cat and t.place_id = s.place_id;
$$;

-- Zwraca miejsce do pojedynku: środek przedziału [lo_pos, hi_pos] w kubełku.
-- Stan wyszukiwania binarnego trzyma wywołujący; baza podaje wyłącznie rywala.
create or replace function rank_pivot(cat place_category, b ranking_bucket,
                                      lo_pos int, hi_pos int)
returns table (place_id uuid, name text, pos int)
language sql stable as $$
  select r.place_id, p.name, r.position
    from rankings r join places p on p.id = r.place_id
   where r.user_id = auth.uid() and r.category = cat and r.bucket = b
     and r.position between lo_pos and hi_pos
   order by r.position
  offset greatest(0, (hi_pos - lo_pos) / 2) limit 1;
$$;

-- Wstawia albo przenosi miejsce na wskazaną pozycję w kubełku i przelicza score.
-- Wywoływana raz, na końcu serii pojedynków.
create or replace function rank_place(cat place_category, target_place uuid,
                                      b ranking_bucket, pos int)
returns numeric
language plpgsql security definer set search_path = public as $$
declare
  me uuid := auth.uid();
  old_bucket ranking_bucket;
  old_position int;
  bucket_size int;
  final_pos int;
  result numeric;
begin
  if me is null then
    raise exception 'brak sesji';
  end if;

  select r.bucket, r.position into old_bucket, old_position
    from rankings r
   where r.user_id = me and r.category = cat and r.place_id = target_place;

  -- Przeniesienie: najpierw domykamy lukę po starej pozycji, żeby numeracja
  -- kubełka źródłowego pozostała ciągła.
  if old_bucket is not null then
    delete from rankings
     where user_id = me and category = cat and place_id = target_place;
    update rankings set position = position - 1
     where user_id = me and category = cat and bucket = old_bucket
       and position > old_position;
  end if;

  select count(*) into bucket_size
    from rankings where user_id = me and category = cat and bucket = b;
  final_pos := least(greatest(pos, 1), bucket_size + 1);

  update rankings set position = position + 1
   where user_id = me and category = cat and bucket = b and position >= final_pos;

  insert into rankings (user_id, category, place_id, bucket, position, score)
  values (me, cat, target_place, b, final_pos, 0);

  perform rank_recompute(me, cat);

  select score into result
    from rankings
   where user_id = me and category = cat and place_id = target_place;

  insert into activity (user_id, kind, place_id, payload)
  values (me, 'ranked', target_place,
          jsonb_build_object('bucket', b, 'score', result));

  return result;
end;
$$;

-- ------------------------------------------------------- podobieństwo gustu

-- Tau Kendalla (wariant tau-a) na wspólnie zrankowanych miejscach. Remisy liczą
-- się jako zero, więc dwie osoby zgodne co do kolejności mają tau bliskie 1
-- niezależnie od tego, jak hojnie każda z nich rozdaje score.
create or replace function taste_tau(a uuid, b uuid)
returns table (tau numeric, common_count int)
language sql stable security definer set search_path = public as $$
  with common as (
    select ra.place_id, ra.score as sa, rb.score as sb
      from rankings ra
      join rankings rb on rb.place_id = ra.place_id and rb.category = ra.category
     where ra.user_id = a and rb.user_id = b
  ),
  pairs as (
    select sign((c1.sa - c2.sa) * (c1.sb - c2.sb)) as agreement
      from common c1 join common c2 on c1.place_id < c2.place_id
  )
  select coalesce(round(avg(agreement), 3), 0)::numeric,
         (select count(*) from common)::int
    from pairs;
$$;

-- Nocny job (pg_cron). Liczy wyłącznie dla par znajomych — reszta grafu nie ma
-- dziś odbiorcy, a przy zaproszeniowym gronie to i tak cała potrzebna macierz.
create or replace function refresh_taste_similarity()
returns int
language plpgsql security definer set search_path = public as $$
declare touched int;
begin
  insert into taste_similarity (user_a, user_b, tau, common_count, computed_at)
  select f.user_a, f.user_b, t.tau, t.common_count, now()
    from friendships f, lateral taste_tau(f.user_a, f.user_b) t
   where f.status = 'accepted'
  on conflict (user_a, user_b) do update
     set tau = excluded.tau,
         common_count = excluded.common_count,
         computed_at = now();
  get diagnostics touched = row_count;
  return touched;
end;
$$;

-- Waga głosu znajomego: 0.5 (przeciwny gust) … 1.0 (identyczny gust).
-- Nikt nie waży zera — sama znajomość jest sygnałem. Poniżej pięciu wspólnych
-- miejsc nie mamy o kim czego twierdzić, więc waga jest neutralna.
create or replace function taste_weight(viewer uuid, other uuid)
returns numeric
language sql stable security definer set search_path = public as $$
  select case
           when s.common_count is null or s.common_count < 5 then 0.75
           else round(0.5 + 0.5 * ((s.tau + 1) / 2), 3)
         end
    from (select 1) as _
    left join taste_similarity s
      on s.user_a = least(viewer, other) and s.user_b = greatest(viewer, other);
$$;

-- ------------------------------------------------------ zapytanie mapy

-- Zwraca miejsca w viewporcie z liczbami policzonymi dla wołającego.
-- Świadomie NIE zwraca żadnej średniej globalnej (zasada babci).
create or replace function map_places(
  west double precision, south double precision,
  east double precision, north double precision,
  cat place_category default 'food',
  max_rows int default 300
)
returns table (
  id uuid,
  name text,
  category place_category,
  lon double precision,
  lat double precision,
  my_score numeric,
  friend_score numeric,
  friend_count int,
  want_to_try boolean
)
language sql stable as $$
  with me as (select auth.uid() as uid),
  visible as (
    select p.*
      from places p
     where p.status = 'active'
       and p.category = cat
       and p.geom && st_makeenvelope(west, south, east, north, 4326)::geography
     limit max_rows
  )
  select v.id, v.name, v.category,
         st_x(v.geom::geometry), st_y(v.geom::geometry),
         mine.score,
         friends.weighted_score,
         coalesce(friends.n, 0)::int,
         wtt.place_id is not null
    from visible v
    cross join me
    left join rankings mine
      on mine.place_id = v.id and mine.user_id = me.uid and mine.category = cat
    left join lateral (
      -- RLS na rankings już ogranicza widok do mnie i znajomych; wykluczamy siebie.
      select round(sum(r.score * taste_weight(me.uid, r.user_id))
                   / nullif(sum(taste_weight(me.uid, r.user_id)), 0), 1) as weighted_score,
             count(*) as n
        from rankings r
       where r.place_id = v.id and r.category = cat and r.user_id <> me.uid
    ) friends on true
    left join lateral (
      select li.place_id
        from list_items li join lists l on l.id = li.list_id
       where li.place_id = v.id and l.owner_id = me.uid and l.kind = 'want_to_try'
       limit 1
    ) wtt on true;
$$;
