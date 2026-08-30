# Mapa Znajomych

Mapa miejsc oceniana rankingiem parowym, z wynikami liczonymi osobno dla każdego
użytkownika — z jego własnych ocen i z ocen jego znajomych ważonych zbieżnością gustu.

**Zasada babci:** nigdzie nie pokazujemy średniej globalnej miejsca. Chcesz iść gdzie indziej
niż twoja babcia, więc liczba na pinezce jest zawsze czyjaś, nie wszystkich. Miejsce bez
sygnału zostaje bez liczby.

Poligon MVP: **Gdańsk, Starówka**, kategoria gastro, dostęp na zaproszenia.
Faza: walidacja (kill-test 12 tygodni), rozwój poza reżimem Foundry.

- Projekt techniczny: [`PROJEKT_TECHNICZNY.md`](PROJEKT_TECHNICZNY.md)

## Struktura

```
app/                 aplikacja Expo (React Native + MapLibre)
  lib/               logika: pojedynki rankingu, prezentacja wyników, klient Supabase
  screens/           mapa i przepływ oceniania
supabase/migrations/ schemat, RLS, mechanika rankingu i personalizacji
supabase/tests/      testy mechaniki na prawdziwym Postgresie
tools/               seed POI ze Starówki, uruchamianie testów bazy
```

## Uruchomienie

**Baza (testy lokalne).** Wymaga Postgresa 16 z PostGIS:

```bash
tools/run_db_tests.sh          # czysta baza + migracje + testy mechaniki
```

**Seed miejsc ze Starówki** (dane z OpenStreetMap, licencja ODbL):

```bash
python3 tools/seed_starowka.py > supabase/seed/gdansk_starowka.sql
psql "$DATABASE_URL" -f supabase/seed/gdansk_starowka.sql
```

Skrypt jest idempotentny: ponowny przebieg odświeża nazwy i adresy z OSM, a miejsc dodanych
przez użytkowników nie dotyka.

**Aplikacja.** MapLibre wymaga buildu developerskiego — Expo Go nie wystarczy:

```bash
cd app
cp .env.example .env.local     # uzupełnij URL i klucz anon projektu Supabase
npm install
npm test                       # testy pętli pojedynków
npm run typecheck
npm run ios                    # albo: npm run android
```

## Atrybucja danych

Miejsca pochodzą z OpenStreetMap (© współtwórcy OSM, ODbL), kafle z OpenFreeMap.
Atrybucja musi być widoczna w aplikacji — komponent mapy renderuje ją domyślnie.
