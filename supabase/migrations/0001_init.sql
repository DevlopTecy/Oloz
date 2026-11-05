-- ==============================================================================
-- Oloz Calm Digital Wellbeing — Initial Supabase Sync Schema
-- Version: 0001_init.sql
-- ==============================================================================

-- 1. Devices registered for each user
create table public.devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users on delete cascade,
  device_key text not null,            -- the local device_id ('phone', 'pc', or uuid)
  label text not null,                 -- 'This phone', 'Windows PC'
  platform text not null check (platform in ('android', 'windows')),
  last_seen timestamptz not null default now(),
  unique (user_id, device_key)
);

-- 2. Daily rollups per app and device
-- Privacy constraint: Only daily totals (foreground ms, opens, reels) are synced.
-- Raw session timestamps, window titles, URLs, and personal content are NEVER synced.
create table public.daily_totals (
  user_id uuid not null references auth.users on delete cascade,
  device_key text not null,
  day date not null,
  package text not null,
  label text not null,
  category text not null,
  foreground_ms bigint not null default 0,
  opens int not null default 0,
  reels int not null default 0,
  updated_at timestamptz not null default now(),
  primary key (user_id, device_key, day, package)
);

-- 3. Cross-device synced user settings & limits
create table public.user_settings (
  user_id uuid primary key references auth.users on delete cascade,
  daily_limit_ms bigint,
  reels_goal int,
  per_app_limits jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Enable Row Level Security (RLS) on all tables
alter table public.devices enable row level security;
alter table public.daily_totals enable row level security;
alter table public.user_settings enable row level security;

-- Strict RLS Policies: users can only read, insert, update, or delete their own data
create policy "own rows" on public.devices
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own rows" on public.daily_totals
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "own rows" on public.user_settings
  for all using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Performance indices for range queries and rollups
create index idx_daily_totals_user_day on public.daily_totals(user_id, day);
create index idx_devices_user on public.devices(user_id);
