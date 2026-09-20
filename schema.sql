-- Git-thrift — run once in Supabase: SQL Editor → New query → paste → Run.
-- Single-family app: anyone whose confirmed email is in `members` shares one inventory.

create table if not exists public.members (
  email    text primary key,
  added_at timestamptz not null default now()
);

create table if not exists public.items (
  id         text primary key,
  data       jsonb not null,
  status     text not null default 'draft',
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.settings (
  key   text primary key,          -- 'rules', 'anthropic_key'
  value jsonb not null
);

-- True when the signed-in user's email is on the family list.
create or replace function public.is_member()
returns boolean
language sql stable security definer
set search_path = public
as $$
  select exists (
    select 1 from public.members
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

alter table public.members  enable row level security;
alter table public.items    enable row level security;
alter table public.settings enable row level security;

-- Members can see the list; only you (SQL editor / dashboard) can change it.
drop policy if exists members_read on public.members;
create policy members_read on public.members
  for select to authenticated using (public.is_member());

drop policy if exists items_all on public.items;
create policy items_all on public.items
  for all to authenticated using (public.is_member()) with check (public.is_member());

drop policy if exists settings_all on public.settings;
create policy settings_all on public.settings
  for all to authenticated using (public.is_member()) with check (public.is_member());

-- Live sync between phones.
do $$ begin
  alter publication supabase_realtime add table public.items;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.settings;
exception when duplicate_object then null; end $$;

-- Add the family. Use the exact emails they'll sign up with.
-- insert into public.members (email) values
--   ('you@example.com'), ('wife@example.com'), ('daughter@example.com');
