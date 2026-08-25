-- Resibo, Please — Public City Gallery V2
-- Lightweight anonymous-auth identity, ownership, privacy, and secure writes.
--
-- IMPORTANT MIGRATION NOTE:
-- Existing V1 snapshots have no trustworthy owner. This script deletes only
-- city_snapshots rows whose owner_id is NULL before making ownership required.
-- Back up those development rows first if you need them; otherwise republish
-- completed cities after running this migration.

begin;

create extension if not exists pgcrypto;

create table if not exists public.player_profiles (
  user_id uuid primary key default auth.uid()
    references auth.users (id) on delete cascade,
  display_name text not null,
  display_name_normalized text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint player_profiles_display_name_length check (
    char_length(display_name) between 3 and 24
  ),
  constraint player_profiles_display_name_characters check (
    display_name ~ '^[[:alnum:]_ ]+$'
  ),
  constraint player_profiles_display_name_trimmed check (
    display_name = btrim(display_name)
    and display_name !~ '[[:space:]]{2,}'
  ),
  constraint player_profiles_normalized_matches check (
    display_name_normalized = lower(display_name)
  )
);

create unique index if not exists player_profiles_display_name_normalized_uidx
  on public.player_profiles (display_name_normalized);

create or replace function public.resibo_set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke all on function public.resibo_set_updated_at() from public, anon, authenticated;

drop trigger if exists player_profiles_set_updated_at
  on public.player_profiles;
create trigger player_profiles_set_updated_at
before update on public.player_profiles
for each row execute function public.resibo_set_updated_at();

create table if not exists public.city_snapshots (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid()
    references public.player_profiles (user_id) on delete cascade,
  is_public boolean not null default true,
  city_name text not null check (char_length(city_name) between 1 and 60),
  term_number integer not null check (term_number between 1 and 100),
  starting_pressure text not null check (
    starting_pressure in ('stable', 'strained', 'crisis')
  ),
  top_issue text not null check (char_length(top_issue) between 1 and 100),
  selected_candidate_name text not null check (
    char_length(selected_candidate_name) between 1 and 100
  ),
  candidate_party text not null check (
    char_length(candidate_party) between 1 and 120
  ),
  final_city_condition text not null check (
    final_city_condition in ('strong', 'functional', 'mixed', 'strained', 'critical')
  ),
  outcome_summary text not null check (
    char_length(outcome_summary) between 1 and 600
  ),
  major_issues jsonb not null default '[]'::jsonb check (
    jsonb_typeof(major_issues) = 'array'
    and jsonb_array_length(major_issues) <= 8
    and pg_column_size(major_issues) <= 2048
    and not jsonb_path_exists(major_issues, '$[*] ? (@.type() != "string")')
  ),
  major_events jsonb not null default '[]'::jsonb check (
    jsonb_typeof(major_events) = 'array'
    and jsonb_array_length(major_events) <= 8
    and pg_column_size(major_events) <= 2048
    and not jsonb_path_exists(major_events, '$[*] ? (@.type() != "string")')
  ),
  created_at timestamptz not null default now()
);

-- V1-to-V2 migration. New installations already have these columns.
alter table public.city_snapshots
  add column if not exists owner_id uuid,
  add column if not exists is_public boolean not null default true;

-- V1 rows cannot be assigned securely because no authenticated owner was saved.
delete from public.city_snapshots where owner_id is null;

alter table public.city_snapshots
  alter column owner_id set default auth.uid(),
  alter column owner_id set not null,
  alter column is_public set default true,
  alter column is_public set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'city_snapshots_owner_profile_fkey'
      and conrelid = 'public.city_snapshots'::regclass
  ) then
    alter table public.city_snapshots
      add constraint city_snapshots_owner_profile_fkey
      foreign key (owner_id)
      references public.player_profiles (user_id)
      on delete cascade;
  end if;
end;
$$;

create index if not exists city_snapshots_created_at_idx
  on public.city_snapshots (created_at desc);
create index if not exists city_snapshots_public_created_at_idx
  on public.city_snapshots (is_public, created_at desc);
create index if not exists city_snapshots_owner_created_at_idx
  on public.city_snapshots (owner_id, created_at desc);

alter table public.player_profiles enable row level security;
alter table public.city_snapshots enable row level security;
alter table public.player_profiles force row level security;
alter table public.city_snapshots force row level security;

-- Remove every prior policy so a broad V1 policy cannot remain active.
do $$
declare policy_row record;
begin
  for policy_row in
    select policyname, tablename
    from pg_policies
    where schemaname = 'public'
      and tablename in ('player_profiles', 'city_snapshots')
  loop
    execute format(
      'drop policy if exists %I on public.%I',
      policy_row.policyname,
      policy_row.tablename
    );
  end loop;
end;
$$;

create policy "Authenticated users can search player names"
  on public.player_profiles
  for select
  to authenticated
  using (true);

create policy "Users can create only their own player profile"
  on public.player_profiles
  for insert
  to authenticated
  with check ((select auth.uid()) is not null
    and user_id = (select auth.uid()));

create policy "Users can update only their own player profile"
  on public.player_profiles
  for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

create policy "Public cities and owned cities are readable"
  on public.city_snapshots
  for select
  to authenticated
  using (is_public or owner_id = (select auth.uid()));

create policy "Users can publish only owned city snapshots"
  on public.city_snapshots
  for insert
  to authenticated
  with check ((select auth.uid()) is not null
    and owner_id = (select auth.uid()));

create policy "Users can update only owned city snapshots"
  on public.city_snapshots
  for update
  to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "Users can delete only owned city snapshots"
  on public.city_snapshots
  for delete
  to authenticated
  using (owner_id = (select auth.uid()));

revoke all on table public.player_profiles from anon, authenticated;
revoke all on table public.city_snapshots from anon, authenticated;

grant select on table public.player_profiles to authenticated;
grant insert (display_name, display_name_normalized)
  on table public.player_profiles to authenticated;
grant update (display_name, display_name_normalized)
  on table public.player_profiles to authenticated;

grant select on table public.city_snapshots to authenticated;
grant insert (
  is_public,
  city_name,
  term_number,
  starting_pressure,
  top_issue,
  selected_candidate_name,
  candidate_party,
  final_city_condition,
  outcome_summary,
  major_issues,
  major_events,
  created_at
) on table public.city_snapshots to authenticated;
grant update (is_public) on table public.city_snapshots to authenticated;
grant delete on table public.city_snapshots to authenticated;

commit;

-- Dashboard step required before the app can create a hidden anonymous session:
-- Authentication -> Providers -> Anonymous Sign-Ins -> Enable.
-- Anonymous Auth users use the authenticated Postgres role; they are not the
-- unauthenticated `anon` database role. Keep CAPTCHA/rate limits in mind before
-- exposing this demo publicly.
