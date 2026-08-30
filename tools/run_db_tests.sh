#!/usr/bin/env bash
# Stawia czystą bazę testową, ładuje migracje i uruchamia testy pgTAP przez pg_prove.
# Wymaga: Postgres 16 z PostGIS i pgTAP oraz pg_prove. Nie dotyka bazy produkcyjnej.
set -euo pipefail

DB="${TEST_DB:-mapa_test}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PSQL=(psql -v ON_ERROR_STOP=1 -q -d "$DB")

dropdb --if-exists "$DB"
createdb "$DB"

# Supabase dostarcza schemat auth i rolę authenticated w środowisku docelowym;
# lokalnie stawiamy minimalny odpowiednik, żeby te same migracje przeszły bez zmian.
"${PSQL[@]}" <<'SQL'
create extension if not exists pgtap;
create schema if not exists auth;
create table auth.users (id uuid primary key);

-- auth.uid() czyta aktora ustawionego przez set_actor() — testowy odpowiednik sesji.
create or replace function auth.uid() returns uuid
language sql stable as $$
  select nullif(current_setting('test.actor', true), '')::uuid;
$$;

create or replace function set_actor(actor uuid) returns void
language sql as $$ select set_config('test.actor', coalesce(actor::text, ''), true); $$;

do $$ begin
  create role authenticated;
exception when duplicate_object then null;
end $$;
SQL

for migration in "$ROOT"/supabase/migrations/*.sql; do
  "${PSQL[@]}" -f "$migration"
done

# Rola authenticated musi móc czytać tabele — dostęp zawęża dopiero RLS.
"${PSQL[@]}" -c "grant usage on schema public, auth to authenticated;
                 grant select, insert, update, delete on all tables in schema public to authenticated;
                 grant execute on all functions in schema public to authenticated;"

pg_prove --ext .sql -d "$DB" "$ROOT"/supabase/tests/*.sql
