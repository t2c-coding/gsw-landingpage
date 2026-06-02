-- Run in Supabase SQL Editor (Dashboard → SQL)

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  name text not null,
  company text not null,
  role text,
  message text,
  campaign text not null default 'geoscience',
  utm_source text,
  utm_medium text,
  utm_campaign text,
  ip_hash text,
  created_at timestamptz not null default now()
);

create index if not exists leads_created_at_idx on public.leads (created_at desc);

alter table public.leads enable row level security;

-- No public policies: inserts only via service_role from API
