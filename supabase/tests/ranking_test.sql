-- Test mechaniki rankingu i personalizacji.
-- Uruchomienie: tools/run_db_tests.sh (stawia czystą bazę, ładuje migracje, wykonuje ten plik).
--
-- Konwencja: każdy przypadek kończy się `assert_equal`, które przerywa przebieg
-- z nazwaną przyczyną. Brak wyjątku = zielono.

\set ON_ERROR_STOP on

create or replace function assert_equal(got anyelement, want anyelement, label text)
returns void language plpgsql as $$
begin
  if got is distinct from want then
    raise exception '% — oczekiwano %, jest %', label, want, got;
  end if;
  raise notice 'ok: %', label;
end;
$$;

-- Tożsamości testowe. auth.uid() czyta GUC ustawiany przez set_actor().
insert into auth.users (id) values
  ('11111111-1111-1111-1111-111111111111'),
  ('22222222-2222-2222-2222-222222222222'),
  ('33333333-3333-3333-3333-333333333333');

insert into app_users (id, handle, display_name) values
  ('11111111-1111-1111-1111-111111111111', 'wnuk',   'Wnuk'),
  ('22222222-2222-2222-2222-222222222222', 'babcia', 'Babcia'),
  ('33333333-3333-3333-3333-333333333333', 'ziomek', 'Ziomek');

insert into friendships (user_a, user_b, requested_by) values
  ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222',
   '11111111-1111-1111-1111-111111111111'),
  ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333',
   '11111111-1111-1111-1111-111111111111');

-- Pięć lokali na Starówce (współrzędne poglądowe, w bboxie Głównego Miasta).
insert into places (id, name, category, geom, source, source_ref) values
  ('aaaaaaaa-0000-0000-0000-000000000001', 'Lokal A', 'food',
   st_point(18.6530, 54.3490)::geography, 'osm', 'test:1'),
  ('aaaaaaaa-0000-0000-0000-000000000002', 'Lokal B', 'food',
   st_point(18.6540, 54.3495)::geography, 'osm', 'test:2'),
  ('aaaaaaaa-0000-0000-0000-000000000003', 'Lokal C', 'food',
   st_point(18.6550, 54.3500)::geography, 'osm', 'test:3'),
  ('aaaaaaaa-0000-0000-0000-000000000004', 'Lokal D', 'food',
   st_point(18.6560, 54.3505)::geography, 'osm', 'test:4'),
  ('aaaaaaaa-0000-0000-0000-000000000005', 'Lokal E', 'food',
   st_point(18.6570, 54.3510)::geography, 'osm', 'test:5'),
  ('aaaaaaaa-0000-0000-0000-000000000006', 'Lokal F', 'food',
   st_point(18.6580, 54.3515)::geography, 'osm', 'test:6');

-- ---------------------------------------------------------------- score z pozycji

select set_actor('11111111-1111-1111-1111-111111111111');

select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000001', 'liked', 1);
select assert_equal(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  10.0::numeric, 'jedyne miejsce w kubelku liked dostaje gorna granice');

-- Wstawienie na pozycję 1 spycha poprzednie miejsce na 2.
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000002', 'liked', 1);
select assert_equal(
  (select position from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  2, 'wstawienie na czolo przesuwa poprzedniego lidera');
select assert_equal(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000002'),
  10.0::numeric, 'nowy lider ma 10.0');
select assert_equal(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  6.7::numeric, 'ostatni w kubelku liked ma dolna granice kubelka');

-- Kubełek decyduje o przedziale niezależnie od liczby miejsc w innych kubełkach.
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000003', 'disliked', 1);
select assert_equal(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000003'),
  3.3::numeric, 'jedyne miejsce w kubelku disliked dostaje gorna granice kubelka');

-- Przeniesienie między kubełkami domyka lukę po starej pozycji.
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000002', 'fine', 1);
select assert_equal(
  (select count(*)::int from rankings where user_id = auth.uid() and bucket = 'liked'),
  1, 'po przeniesieniu w kubelku liked zostaje jedno miejsce');
select assert_equal(
  (select position from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  1, 'numeracja kubelka zrodlowego pozostaje ciagla');
select assert_equal(
  (select score from rankings where user_id = auth.uid()
     and place_id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  10.0::numeric, 'jedyny pozostaly w kubelku wraca na gorna granice');

-- Ranking nie może zgubić ani zdublować miejsca.
select assert_equal(
  (select count(*)::int from rankings where user_id = auth.uid()),
  3, 'liczba zrankowanych miejsc zgadza sie po przenosinach');

-- --------------------------------------------------- zasada babci: gust dzieli

-- Wnuk i Ziomek mają zgodny gust (A > B > C > D > E), Babcia dokładnie odwrotny.
-- Pięć wspólnych miejsc to próg, powyżej którego wolno cokolwiek twierdzić o guście.
select set_actor('11111111-1111-1111-1111-111111111111');
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000001', 'liked', 1);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000002', 'liked', 2);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000003', 'liked', 3);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000004', 'liked', 4);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000005', 'liked', 5);

select set_actor('33333333-3333-3333-3333-333333333333');
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000001', 'liked', 1);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000002', 'liked', 2);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000003', 'liked', 3);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000004', 'liked', 4);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000005', 'liked', 5);

select set_actor('22222222-2222-2222-2222-222222222222');
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000005', 'liked', 1);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000004', 'liked', 2);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000003', 'liked', 3);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000002', 'liked', 4);
select rank_place('food', 'aaaaaaaa-0000-0000-0000-000000000001', 'liked', 5);

select refresh_taste_similarity();

select assert_equal(
  (select tau from taste_similarity
    where user_a = '11111111-1111-1111-1111-111111111111'
      and user_b = '33333333-3333-3333-3333-333333333333'),
  1.000::numeric, 'zgodny gust daje tau = 1');
select assert_equal(
  (select tau from taste_similarity
    where user_a = '11111111-1111-1111-1111-111111111111'
      and user_b = '22222222-2222-2222-2222-222222222222'),
  -1.000::numeric, 'przeciwny gust daje tau = -1');

-- Waga głosu: zgodny gust waży 1.0, przeciwny 0.5 — nigdy zero.
select assert_equal(
  taste_weight('11111111-1111-1111-1111-111111111111',
               '33333333-3333-3333-3333-333333333333'),
  1.000::numeric, 'znajomy o zgodnym guscie wazy 1.0');
select assert_equal(
  taste_weight('11111111-1111-1111-1111-111111111111',
               '22222222-2222-2222-2222-222222222222'),
  0.500::numeric, 'znajomy o przeciwnym guscie wazy 0.5, nie zero');
select assert_equal(
  taste_weight('11111111-1111-1111-1111-111111111111',
               '99999999-9999-9999-9999-999999999999'),
  0.750::numeric, 'bez danych waga jest neutralna');

-- Sedno produktu: ten sam lokal, inny wynik — bo liczy się gust patrzącego.
-- Wnuk widzi lokal A jako średnią ważoną: Ziomek 10.0 (waga 1.0) i Babcia 6.7
-- (waga 0.5) → (10.0 + 3.35) / 1.5 = 8.9. Głos zgodnego gustu przeważa.
select set_actor('11111111-1111-1111-1111-111111111111');
select assert_equal(
  (select round(friend_score, 1) from map_places(18.64, 54.34, 18.67, 54.36, 'food')
    where id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  8.9::numeric, 'lokal A u wnuka: glos zgodnego ziomka przewaza glos babci');

-- Babcia patrzy na ten sam lokal przez swój graf (jej jedyny znajomy to wnuk).
select set_actor('22222222-2222-2222-2222-222222222222');
select assert_equal(
  (select round(friend_score, 1) from map_places(18.64, 54.34, 18.67, 54.36, 'food')
    where id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  10.0::numeric, 'ten sam lokal u babci ma inny wynik — bo liczy sie jej graf');

-- Miejsce bez sygnału nie dostaje wyniku zastępczego (żadnej średniej globalnej).
select set_actor('11111111-1111-1111-1111-111111111111');
select assert_equal(
  (select friend_score from map_places(18.64, 54.34, 18.67, 54.36, 'food')
    where id = 'aaaaaaaa-0000-0000-0000-000000000006'),
  null::numeric, 'miejsce bez ocen znajomych nie ma wyniku — brak sygnalu to brak liczby');

-- ------------------------------------------------------------ pojedynki

select set_actor('11111111-1111-1111-1111-111111111111');
select assert_equal(
  (select place_id from rank_pivot('food', 'liked', 1, 1)),
  'aaaaaaaa-0000-0000-0000-000000000001'::uuid,
  'pojedynczy przedzial zwraca jedynego kandydata');

select 'WSZYSTKIE TESTY PRZESZLY' as wynik;
