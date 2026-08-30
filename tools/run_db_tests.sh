#!/usr/bin/env bash
# Stawia czystą bazę testową, ładuje migracje i uruchamia testy SQL.
# Wymaga lokalnego Postgresa z PostGIS. Nie dotyka bazy produkcyjnej.
set -euo pipefail

DB="${TEST_DB:-mapa_test}"
PSQL=(psql -v ON_ERROR_STOP=1 -q)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

dropdb --if-exists "$DB"
createdb "$DB"

# Supabase dostarcza schemat auth w środowisku docelowym; lokalnie stawiamy
# minimalny odpowiednik, żeby te same migracje przeszły bez modyfikacji.
"${PSQL[@]}" -d "$DB" <<'SQL'
create schema if not exists auth;
create table auth.users (id uuid primary key);

-- auth.uid() czyta aktora ustawionego przez set_actor() — testowy odpowiednik sesji.
create or replace function auth.uid() returns uuid
language sql stable as $$
  select nullif(current_setting('test.actor', true), '')::uuid;
$$;

create or replace function set_actor(actor uuid) returns void
language sql as $$ select set_config('test.actor', actor::text, false); $$;

do $$ begin
  create role authenticated;
exception when duplicate_object then null;
end $$;
SQL

for migration in "$ROOT"/supabase/migrations/*.sql; do
  echo "== $(basename "$migration")"
  "${PSQL[@]}" -d "$DB" -f "$migration"
done

echo "== testy"
"${PSQL[@]}" -d "$DB" -f "$ROOT/supabase/tests/ranking_test.sql"
