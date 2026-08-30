-- 0001_init — schemat bazowy Mapy Znajomych.
-- Zakres MVP: Gdańsk Starówka, kategoria gastro, dostęp na zaproszenia.

create extension if not exists postgis;
create extension if not exists pg_trgm;
create extension if not exists unaccent;
create extension if not exists citext;

-- ---------------------------------------------------------------- tożsamość

create table app_users (
  id           uuid primary key references auth.users on delete cascade,
  handle       citext not null unique check (handle ~ '^[a-z0-9_]{3,20}$'),
  display_name text   not null check (length(display_name) between 1 and 40),
  avatar_path  text,
  home_city    text   not null default 'gdansk',
  created_at   timestamptz not null default now()
);

-- Kody zaproszeń są jedyną drogą do konta i jedynym źródłem krawędzi grafu.
create table invites (
  code       text primary key check (code ~ '^[A-Z0-9]{6}$'),
  inviter_id uuid not null references app_users on delete cascade,
  used_by    uuid references app_users on delete set null,
  created_at timestamptz not null default now(),
  used_at    timestamptz,
  constraint invite_used_consistently check ((used_by is null) = (used_at is null))
);
create index invites_inviter_idx on invites (inviter_id);

-- Znajomość jest symetryczna: trzymamy jeden wiersz z user_a < user_b.
create table friendships (
  user_a       uuid not null references app_users on delete cascade,
  user_b       uuid not null references app_users on delete cascade,
  status       text not null default 'accepted' check (status in ('pending', 'accepted')),
  requested_by uuid not null references app_users on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (user_a, user_b),
  constraint friendship_canonical_order check (user_a < user_b)
);
create index friendships_b_idx on friendships (user_b);

-- ------------------------------------------------------------------ miejsca

create type place_category as enum ('food', 'cafe', 'drinks', 'culture', 'chill', 'other');
create type place_source   as enum ('osm', 'fsq', 'overture', 'user');
create type place_status    as enum ('active', 'closed', 'pending', 'duplicate');

-- Klucz porównawczy dedupu: bez znaków diakrytycznych, bez interpunkcji.
-- Dwuargumentowy unaccent ze wskazanym słownikiem jest immutable, jednoargumentowy
-- nie jest — kolumna generowana wymaga tego pierwszego.
create or replace function normalize_name(raw text)
returns text
language sql immutable parallel safe as $$
  select trim(regexp_replace(
    lower(unaccent('unaccent'::regdictionary, raw)), '[^a-z0-9]+', ' ', 'g'));
$$;

create table places (
  id              uuid primary key default gen_random_uuid(),
  city            text not null default 'gdansk',
  name            text not null check (length(name) between 1 and 120),
  normalized_name text generated always as (normalize_name(name)) stored,
  category        place_category not null,
  geom            geography(point, 4326) not null,
  address         text,
  source          place_source not null,
  source_ref      text,
  status          place_status not null default 'active',
  duplicate_of    uuid references places on delete set null,
  created_by      uuid references app_users on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  constraint duplicate_needs_target check ((status = 'duplicate') = (duplicate_of is not null))
);
create index places_geom_idx  on places using gist (geom);
create index places_name_idx  on places using gin (normalized_name gin_trgm_ops);
create index places_scope_idx on places (city, category, status);
create unique index places_source_ref_idx on places (source, source_ref)
  where source_ref is not null;

-- ---------------------------------------------------------------- aktywność

create table logs (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references app_users on delete cascade,
  place_id   uuid not null references places   on delete cascade,
  visited_on date not null default current_date,
  note       text check (length(note) <= 500),
  created_at timestamptz not null default now()
);
create index logs_user_idx  on logs (user_id, created_at desc);
create index logs_place_idx on logs (place_id);

create type ranking_bucket as enum ('disliked', 'fine', 'liked');

-- Pozycja jest źródłem prawdy; score jest jej pochodną (patrz 0003_ranking).
create table rankings (
  user_id    uuid not null references app_users on delete cascade,
  category   place_category not null,
  place_id   uuid not null references places on delete cascade,
  bucket     ranking_bucket not null,
  position   int  not null check (position >= 1),
  score      numeric(3,1) not null check (score between 0 and 10),
  updated_at timestamptz not null default now(),
  primary key (user_id, category, place_id)
);
-- Deferrable: przesuwanie pozycji w jednej transakcji chwilowo je duplikuje.
alter table rankings add constraint rankings_position_unique
  unique (user_id, category, bucket, position) deferrable initially deferred;
create index rankings_place_idx on rankings (place_id, category);

-- Ślad audytowy pojedynków. Nie jest stanem — stan trzyma tabela rankings.
create table comparisons (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references app_users on delete cascade,
  category   place_category not null,
  subject_id uuid not null references places on delete cascade,
  rival_id   uuid not null references places on delete cascade,
  winner_id  uuid references places on delete cascade,
  skipped    boolean not null default false,
  created_at timestamptz not null default now(),
  constraint comparison_outcome check (skipped = (winner_id is null))
);
create index comparisons_user_idx on comparisons (user_id, created_at desc);

-- ------------------------------------------------------------------- listy

create type list_kind as enum ('custom', 'want_to_try');

create table lists (
  id       uuid primary key default gen_random_uuid(),
  owner_id uuid not null references app_users on delete cascade,
  name     text not null check (length(name) between 1 and 40),
  emoji    text,
  kind     list_kind not null default 'custom',
  -- Lista "chcę spróbować" jest prywatna z definicji; dzielenie się nią to gest.
  is_shared boolean not null default false,
  created_at timestamptz not null default now()
);
create unique index lists_one_want_to_try_idx on lists (owner_id)
  where kind = 'want_to_try';

create table list_items (
  list_id  uuid not null references lists  on delete cascade,
  place_id uuid not null references places on delete cascade,
  note     text check (length(note) <= 300),
  added_at timestamptz not null default now(),
  primary key (list_id, place_id)
);

-- ------------------------------------------- personalizacja i feed (pochodne)

-- Podobieństwo gustu: tau Kendalla na wspólnie zrankowanych miejscach.
-- Materializowane nocnym jobem, nigdy w ścieżce zapytania.
create table taste_similarity (
  user_a       uuid not null references app_users on delete cascade,
  user_b       uuid not null references app_users on delete cascade,
  tau          numeric(4,3) not null check (tau between -1 and 1),
  common_count int not null check (common_count >= 0),
  computed_at  timestamptz not null default now(),
  primary key (user_a, user_b),
  constraint similarity_canonical_order check (user_a < user_b)
);

create type activity_kind as enum ('logged', 'ranked', 'added_place', 'listed');

create table activity (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references app_users on delete cascade,
  kind       activity_kind not null,
  place_id   uuid references places on delete cascade,
  payload    jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index activity_feed_idx on activity (user_id, id desc);

create table reports (
  id          uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references app_users on delete cascade,
  target_kind text not null check (target_kind in ('place', 'log', 'user')),
  target_id   uuid not null,
  reason      text not null check (length(reason) between 1 and 500),
  status      text not null default 'open' check (status in ('open', 'resolved', 'rejected')),
  created_at  timestamptz not null default now()
);
