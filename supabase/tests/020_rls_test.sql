-- Model prywatności. RLS jest tu jedyną granicą dostępu, więc jest testowany
-- jak kod: co widzi znajomy, czego nie widzi obcy, czego nie widzi nikt.

begin;
select plan(15);

-- Każda tabela z danymi użytkownika musi mieć włączone RLS. Test wyłapuje
-- tabelę dodaną w przyszłej migracji, o której ktoś zapomniał.
select is(
  (select count(*)::int
     from pg_class c
     join pg_namespace ns on ns.oid = c.relnamespace
    where ns.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity
      -- Tabele wniesione przez rozszerzenia (np. spatial_ref_sys z PostGIS)
      -- nie są nasze i nie niosą danych użytkownika.
      and not exists (select 1 from pg_depend d
                       where d.objid = c.oid and d.deptype = 'e')),
  0, 'kazda nasza tabela w public ma wlaczone RLS');

insert into auth.users (id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222'),
  ('44444444-4444-4444-4444-444444444444');

insert into app_users (id, handle, display_name) values
  ('11111111-1111-1111-1111-111111111111', 'wnuk',   'Wnuk'),
  ('22222222-2222-2222-2222-222222222222', 'babcia', 'Babcia'),
  ('44444444-4444-4444-4444-444444444444', 'obcy',   'Obcy');

insert into friendships (user_a, user_b, requested_by) values
  ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222',
   '11111111-1111-1111-1111-111111111111');

insert into places (id, name, category, geom, source, source_ref) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'Lokal A', 'food',
   st_point(18.6530, 54.3490)::geography, 'osm', 'rls:1');

-- Dane wnuka: ocena, prywatna lista i ślad pojedynku.
select set_actor('11111111-1111-1111-1111-111111111111');
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000001', 'liked', 1);
insert into logs (user_id, place_id) values (auth.uid(), 'aaaaaaaa-0000-0000-0000-000000000001');
insert into comparisons (user_id, category, subject_id, rival_id, winner_id)
values (auth.uid(), 'food', 'aaaaaaaa-0000-0000-0000-000000000001',
        'aaaaaaaa-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001');
insert into lists (id, owner_id, name, kind)
values ('cccccccc-0000-0000-0000-000000000001', auth.uid(), 'Chcę spróbować', 'want_to_try');
insert into list_items (list_id, place_id)
values ('cccccccc-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001');

-- Od tego miejsca czytamy jako rola authenticated, czyli z egzekwowanym RLS.
set local role authenticated;

select is((select count(*)::int from rankings), 1, 'wlasciciel widzi swoja ocene');
select is((select count(*)::int from logs), 1, 'wlasciciel widzi swoj log');
select is((select count(*)::int from lists), 1, 'wlasciciel widzi swoja liste');

-- Znajomy widzi oceny i logi, ale nie prywatną listę ani nie ślady pojedynków.
select set_actor('22222222-2222-2222-2222-222222222222');
select is((select count(*)::int from rankings), 1, 'znajomy widzi oceny znajomego');
select is((select count(*)::int from logs), 1, 'znajomy widzi logi znajomego');
select is((select count(*)::int from lists), 0,
          'lista "chce sprobowac" jest prywatna nawet dla znajomego');
select is((select count(*)::int from list_items), 0,
          'pozycje prywatnej listy tez sa niewidoczne');
select is((select count(*)::int from comparisons), 0,
          'slady pojedynkow sa prywatnym materialem kalibracyjnym');

-- Obcy nie widzi niczego poza wspólnymi miejscami.
select set_actor('44444444-4444-4444-4444-444444444444');
select is((select count(*)::int from rankings), 0, 'obcy nie widzi ocen');
select is((select count(*)::int from logs), 0, 'obcy nie widzi logow');
select is((select count(*)::int from places), 1, 'miejsca sa wspolnym dobrem grupy');

-- Wynik znajomych obcego nie istnieje — nie dziedziczy cudzego grafu.
select is(
  (select friend_score from map_places(18.64, 54.34, 18.67, 54.36, 'food')
    where id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  null::numeric, 'obcy nie widzi wyniku policzonego z cudzego grafu');

-- Udostępnienie listy jest świadomym gestem i dopiero ono otwiera widok.
reset role;
update lists set is_shared = true where id = 'cccccccc-0000-0000-0000-000000000001';
set local role authenticated;

select set_actor('22222222-2222-2222-2222-222222222222');
select is((select count(*)::int from lists), 1, 'udostepniona lista jest widoczna dla znajomego');
select set_actor('44444444-4444-4444-4444-444444444444');
select is((select count(*)::int from lists), 0, 'udostepnienie nie siega poza graf znajomych');

select * from finish();
rollback;
