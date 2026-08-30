-- 0002_rls — polityki dostępu. Domyślnie: widzi właściciel i zaakceptowani znajomi.

alter table app_users       enable row level security;
alter table invites         enable row level security;
alter table friendships     enable row level security;
alter table places          enable row level security;
alter table logs            enable row level security;
alter table rankings        enable row level security;
alter table comparisons     enable row level security;
alter table lists           enable row level security;
alter table list_items      enable row level security;
alter table taste_similarity enable row level security;
alter table activity        enable row level security;
alter table reports         enable row level security;

-- Jedno miejsce, w którym mieszka definicja "znajomego". Stabilne dla polityk.
create or replace function is_friend(other uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from friendships f
    where f.status = 'accepted'
      and ((f.user_a = auth.uid() and f.user_b = other)
        or (f.user_b = auth.uid() and f.user_a = other))
  );
$$;

create or replace function visible_to_me(owner uuid)
returns boolean
language sql stable
as $$ select owner = auth.uid() or is_friend(owner); $$;

-- Profile: każdy zalogowany widzi podstawowe dane (potrzebne przy zaproszeniach).
create policy users_read   on app_users for select to authenticated using (true);
create policy users_update on app_users for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());
create policy users_insert on app_users for insert to authenticated
  with check (id = auth.uid());

-- Zaproszenia widzi wyłącznie ich autor; realizacja kodu idzie przez funkcję
-- security definer (redeem_invite), nie przez bezpośredni UPDATE klienta.
create policy invites_own on invites for select to authenticated
  using (inviter_id = auth.uid());
create policy invites_create on invites for insert to authenticated
  with check (inviter_id = auth.uid());

create policy friendships_read on friendships for select to authenticated
  using (user_a = auth.uid() or user_b = auth.uid());
create policy friendships_delete on friendships for delete to authenticated
  using (user_a = auth.uid() or user_b = auth.uid());

-- Miejsca są wspólnym dobrem grupy: czyta każdy zalogowany, dodaje każdy.
create policy places_read on places for select to authenticated using (true);
create policy places_insert on places for insert to authenticated
  with check (created_by = auth.uid() and source = 'user');
create policy places_update_own on places for update to authenticated
  using (created_by = auth.uid()) with check (created_by = auth.uid());

create policy logs_read on logs for select to authenticated
  using (visible_to_me(user_id));
create policy logs_write on logs for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy rankings_read on rankings for select to authenticated
  using (visible_to_me(user_id));
create policy rankings_write on rankings for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Pojedynki to prywatny materiał kalibracyjny — nie pokazujemy ich znajomym.
create policy comparisons_own on comparisons for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- "Chcę spróbować" jest prywatna, dopóki właściciel jej nie udostępni.
create policy lists_read on lists for select to authenticated
  using (owner_id = auth.uid() or (is_shared and is_friend(owner_id)));
create policy lists_write on lists for all to authenticated
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy list_items_read on list_items for select to authenticated
  using (exists (
    select 1 from lists l where l.id = list_id
      and (l.owner_id = auth.uid() or (l.is_shared and is_friend(l.owner_id)))));
create policy list_items_write on list_items for all to authenticated
  using (exists (select 1 from lists l where l.id = list_id and l.owner_id = auth.uid()))
  with check (exists (select 1 from lists l where l.id = list_id and l.owner_id = auth.uid()));

create policy similarity_read on taste_similarity for select to authenticated
  using (user_a = auth.uid() or user_b = auth.uid());

create policy activity_read on activity for select to authenticated
  using (visible_to_me(user_id));
create policy activity_insert on activity for insert to authenticated
  with check (user_id = auth.uid());

create policy reports_own on reports for select to authenticated
  using (reporter_id = auth.uid());
create policy reports_create on reports for insert to authenticated
  with check (reporter_id = auth.uid());

-- Realizacja zaproszenia: tworzy krawędź grafu i zamyka kod w jednej transakcji.
create or replace function redeem_invite(invite_code text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  inviter uuid;
  me uuid := auth.uid();
begin
  if me is null then
    raise exception 'brak sesji';
  end if;

  select inviter_id into inviter from invites
   where code = upper(invite_code) and used_by is null
   for update;

  if inviter is null then
    raise exception 'kod nieznany albo już użyty';
  end if;
  if inviter = me then
    raise exception 'nie można użyć własnego kodu';
  end if;

  update invites set used_by = me, used_at = now() where code = upper(invite_code);

  insert into friendships (user_a, user_b, status, requested_by)
  values (least(inviter, me), greatest(inviter, me), 'accepted', inviter)
  on conflict do nothing;

  return inviter;
end;
$$;
