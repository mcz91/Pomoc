-- Mechanika rankingu i personalizacji. Framework: pgTAP.
-- Uruchomienie: tools/run_db_tests.sh (pg_prove na czystej bazie z migracjami).

begin;
select plan(20);

-- Trzy osoby o rozbieżnym guście — wnuk, babcia i ziomek wnuka.
insert into auth.users (id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222'),
  ('33333333-3333-3333-3333-333333333333');

insert into app_users (id, handle, display_name) values
  ('11111111-1111-1111-1111-111111111111', 'wnuk',   'Wnuk'),
  ('22222222-2222-2222-2222-222222222222', 'babcia', 'Babcia'),
  ('33333333-3333-3333-3333-333333333333', 'ziomek', 'Ziomek');

-- Babcia i ziomek nie znają się nawzajem — każde ma własny graf.
insert into friendships (user_a, user_b, requested_by) values
  ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222',
   '11111111-1111-1111-1111-111111111111'),
  ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333',
   '11111111-1111-1111-1111-111111111111');

insert into places (id, name, category, geom, source, source_ref)
select ('aaaaaaaa-0000-0000-0000-00000000000' || n)::uuid,
       'Lokal ' || chr(64 + n), 'food',
       st_point(18.6530 + n * 0.001, 54.3490 + n * 0.0005)::geography,
       'osm', 'test:' || n
  from generate_series(1, 6) as n;

-- ---------------------------------------------------------- score z pozycji

select set_actor('11111111-1111-1111-1111-111111111111');

select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000001', 'liked', 1);
select is(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  10.0::numeric, 'jedyne miejsce w kubelku liked dostaje gorna granice');

select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000002', 'liked', 1);
select is(
  (select position from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  2, 'wstawienie na czolo przesuwa poprzedniego lidera');
select is(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000002'),
  10.0::numeric, 'nowy lider ma 10.0');
select is(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  6.7::numeric, 'ostatni w kubelku liked ma dolna granice kubelka');

select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000003', 'disliked', 1);
select is(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000003'),
  3.3::numeric, 'kubelek disliked ma wlasny zakres, niezalezny od reszty');

-- Przeniesienie między kubełkami domyka lukę po starej pozycji.
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000002', 'fine', 1);
select is(
  (select count(*)::int from rankings where user_id = auth.uid() and bucket = 'liked'),
  1, 'po przeniesieniu w kubelku liked zostaje jedno miejsce');
select is(
  (select position from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  1, 'numeracja kubelka zrodlowego pozostaje ciagla');
select is(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  10.0::numeric, 'jedyny pozostaly w kubelku wraca na gorna granice');
select is(
  (select count(*)::int from rankings where user_id = auth.uid()),
  3, 'ranking nie gubi ani nie dubluje miejsca przy przenosinach');

-- ----------------------------------------------- zasada babci: gust dzieli

-- Wnuk i ziomek: A > B > C > D > E. Babcia dokładnie odwrotnie.
-- Pięć wspólnych miejsc to próg, powyżej którego wolno cokolwiek twierdzić o guście.
-- Pętla, nie select po generate_series: rank_place zmienia stan, na którym
-- opiera się następne wywołanie, a kolejność obliczania wyrażeń w liście
-- selecta nie jest gwarantowana.
do $seed$
declare
  prefix text := 'aaaaaaaa-0000-0000-0000-00000000000';
  n int;
begin
  perform set_actor('11111111-1111-1111-1111-111111111111');
  for n in 1..5 loop
    perform rank_place('food', (prefix || n)::uuid, 'liked', n);
  end loop;

  perform set_actor('33333333-3333-3333-3333-333333333333');
  for n in 1..5 loop
    perform rank_place('food', (prefix || n)::uuid, 'liked', n);
  end loop;

  -- Babcia: dokładnie odwrotna kolejność. Wstawiamy od jej ulubionego (E) w dół.
  perform set_actor('22222222-2222-2222-2222-222222222222');
  for n in 1..5 loop
    perform rank_place('food', (prefix || (6 - n))::uuid, 'liked', n);
  end loop;
end
$seed$;

select refresh_taste_similarity();

select is(
  (select tau from taste_similarity
    where user_a = '11111111-1111-1111-1111-111111111111'
      and user_b = '33333333-3333-3333-3333-333333333333'),
  1.000::numeric, 'zgodny gust daje tau = 1');
select is(
  (select tau from taste_similarity
    where user_a = '11111111-1111-1111-1111-111111111111'
      and user_b = '22222222-2222-2222-2222-222222222222'),
  -1.000::numeric, 'przeciwny gust daje tau = -1');

select is(taste_weight('11111111-1111-1111-1111-111111111111',
                       '33333333-3333-3333-3333-333333333333'),
          1.000::numeric, 'znajomy o zgodnym guscie wazy 1.0');
select is(taste_weight('11111111-1111-1111-1111-111111111111',
                       '22222222-2222-2222-2222-222222222222'),
          0.500::numeric, 'znajomy o przeciwnym guscie wazy 0.5, nie zero');
select is(taste_weight('11111111-1111-1111-1111-111111111111',
                       '99999999-9999-9999-9999-999999999999'),
          0.750::numeric, 'bez danych waga jest neutralna');

-- Sedno produktu. Wnuk widzi lokal A jako srednia wazona: ziomek 10.0 (waga 1.0)
-- i babcia 6.7 (waga 0.5) => (10.0 + 3.35) / 1.5 = 8.9.
select set_actor('11111111-1111-1111-1111-111111111111');
select is(
  (select round(friend_score, 1) from map_places(18.64, 54.34, 18.67, 54.36, 'food')
    where id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  8.9::numeric, 'lokal A u wnuka: glos zgodnego ziomka przewaza glos babci');

select set_actor('22222222-2222-2222-2222-222222222222');
select is(
  (select round(friend_score, 1) from map_places(18.64, 54.34, 18.67, 54.36, 'food')
    where id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  10.0::numeric, 'ten sam lokal u babci ma inny wynik — bo liczy sie jej graf');

-- Brak sygnalu to brak liczby. Zadnej sredniej globalnej w zastepstwie.
select set_actor('11111111-1111-1111-1111-111111111111');
select is(
  (select friend_score from map_places(18.64, 54.34, 18.67, 54.36, 'food')
    where id = 'aaaaaaaa-0000-0000-0000-000000000006'),
  null::numeric, 'miejsce bez ocen znajomych nie ma wyniku');

-- ------------------------------------------------------------- pojedynki

select is(
  (select place_id from rank_pivot('food', 'liked', 1, 1)),
  'aaaaaaaa-0000-0000-0000-000000000001'::uuid,
  'pojedynczy przedzial zwraca jedynego kandydata');
select is(
  (select pos from rank_pivot('food', 'liked', 1, 5)),
  3, 'rywalem jest srodek przedzialu');

-- Bez sesji nie ma zapisu — funkcje rankingu nie maja trybu anonimowego.
select set_actor(null);
select throws_ok(
  $$select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000001', 'liked', 1)$$,
  'brak sesji', 'ranking bez sesji jest odmawiany');

select * from finish();
rollback;
