-- 学习时间兑换应用 - Supabase 表结构与 RLS
-- 在 Supabase Dashboard -> SQL Editor 中执行此脚本

-- 1. profiles：用户扩展信息（比例、昵称）
create table if not exists public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  study_to_entertainment_ratio numeric not null default 0.5,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- 2. study_sessions：学习会话
create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  started_at timestamptz not null,
  ended_at timestamptz not null,
  duration_minutes numeric not null,
  created_at timestamptz default now()
);

-- 3. entertainment_usage：娱乐时间使用记录
create table if not exists public.entertainment_usage (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  minutes numeric not null,
  created_at timestamptz default now()
);

-- 4. rewards：用户自定义礼物
create table if not exists public.rewards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  cost_study_minutes numeric not null,
  created_at timestamptz default now()
);

-- 5. reward_redemptions：礼物兑换记录
create table if not exists public.reward_redemptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  reward_id uuid not null references public.rewards (id) on delete restrict,
  cost_minutes numeric not null,
  created_at timestamptz default now()
);

-- 索引
create index if not exists idx_study_sessions_user_id on public.study_sessions (user_id);
create index if not exists idx_entertainment_usage_user_id on public.entertainment_usage (user_id);
create index if not exists idx_rewards_user_id on public.rewards (user_id);
create index if not exists idx_reward_redemptions_user_id on public.reward_redemptions (user_id);

-- 启用 RLS
alter table public.profiles enable row level security;
alter table public.study_sessions enable row level security;
alter table public.entertainment_usage enable row level security;
alter table public.rewards enable row level security;
alter table public.reward_redemptions enable row level security;

-- RLS 策略：仅允许操作自己的数据
create policy "profiles_select_own" on public.profiles for select using (auth.uid() = user_id);
create policy "profiles_insert_own" on public.profiles for insert with check (auth.uid() = user_id);
create policy "profiles_update_own" on public.profiles for update using (auth.uid() = user_id);

create policy "study_sessions_all_own" on public.study_sessions for all using (auth.uid() = user_id);

create policy "entertainment_usage_all_own" on public.entertainment_usage for all using (auth.uid() = user_id);

create policy "rewards_all_own" on public.rewards for all using (auth.uid() = user_id);

create policy "reward_redemptions_all_own" on public.reward_redemptions for all using (auth.uid() = user_id);

-- 新用户注册时自动创建 profile
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (user_id, study_to_entertainment_ratio)
  values (new.id, 0.5);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 更新 profiles 时自动刷新 updated_at
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;
drop trigger if exists profiles_updated_at on public.profiles;
create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();
