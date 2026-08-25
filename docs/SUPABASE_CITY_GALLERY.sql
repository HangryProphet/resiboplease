-- Resibo, Please — Public City Gallery V1 (SUPERSEDED)
-- Do not run this after V2. New setups and migrations must use
-- SUPABASE_CITY_GALLERY_V2.sql, which adds authenticated ownership and privacy.
-- Run this in the Supabase SQL editor for the project used by the app.

create extension if not exists pgcrypto;

create table if not exists public.city_snapshots (
  id uuid primary key default gen_random_uuid(),
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
    and not jsonb_path_exists(
      major_issues,
      '$[*] ? (@.type() != "string")'
    )
  ),
  major_events jsonb not null default '[]'::jsonb check (
    jsonb_typeof(major_events) = 'array'
    and jsonb_array_length(major_events) <= 8
    and pg_column_size(major_events) <= 2048
    and not jsonb_path_exists(
      major_events,
      '$[*] ? (@.type() != "string")'
    )
  ),
  created_at timestamptz not null default now()
);

create index if not exists city_snapshots_created_at_idx
  on public.city_snapshots (created_at desc);

alter table public.city_snapshots enable row level security;

drop policy if exists "Public city snapshots are readable" on public.city_snapshots;
create policy "Public city snapshots are readable"
  on public.city_snapshots
  for select
  to anon, authenticated
  using (true);

drop policy if exists "Sanitized city snapshots are publishable" on public.city_snapshots;
create policy "Sanitized city snapshots are publishable"
  on public.city_snapshots
  for insert
  to anon, authenticated
  with check (
    char_length(city_name) between 1 and 60
    and term_number between 1 and 100
    and jsonb_array_length(major_issues) <= 8
    and jsonb_array_length(major_events) <= 8
    and pg_column_size(major_issues) <= 2048
    and pg_column_size(major_events) <= 2048
  );

grant select, insert on table public.city_snapshots to anon, authenticated;

-- No UPDATE or DELETE policy is granted to public clients. This table contains
-- public fictional summaries only; private save data must never be added here.
