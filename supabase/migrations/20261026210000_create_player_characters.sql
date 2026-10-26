-- Untitled World: persistent player character records.
-- Apply to the separate Untitled World Supabase project only.
create table public.player_characters (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  character_name text not null default 'Wanderer'
    check (char_length(character_name) between 1 and 32),
  background text not null
    check (background in ('working', 'merchant', 'noble')),
  coins integer not null default 0 check (coins >= 0),
  logs integer not null default 0 check (logs >= 0),
  planks integer not null default 0 check (planks >= 0),
  buildings integer not null default 0 check (buildings >= 0),
  position_x numeric not null default 0,
  position_y numeric not null default 0,
  world_day integer not null default 1 check (world_day >= 1),
  world_time integer not null default 8 check (world_time between 0 and 23),
  game_state jsonb not null default '{}'::jsonb
    check (jsonb_typeof(game_state) = 'object'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.player_characters enable row level security;

create policy "Players can view their own character"
on public.player_characters for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Players can create their own character"
on public.player_characters for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Players can update their own character"
on public.player_characters for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create index player_characters_user_id_idx
on public.player_characters(user_id);

-- Restrict table privileges in addition to row-level security.
revoke all on table public.player_characters from anon;
revoke all on table public.player_characters from authenticated;
grant select, insert, update on table public.player_characters to authenticated;
