-- Server-authoritative actions for Untitled World.
-- Applied to project ifhvwqmwrgjxpcuqpaed. Existing character rows are preserved.
create table if not exists public.player_world_trees (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  x numeric not null check (x between 0 and 720),
  y numeric not null check (y between 0 and 480),
  alive boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.player_world_trees enable row level security;
drop policy if exists "Players can view their own world trees" on public.player_world_trees;
create policy "Players can view their own world trees"
on public.player_world_trees for select to authenticated
using ((select auth.uid()) = user_id);
revoke all on public.player_world_trees from anon, authenticated;
grant select on public.player_world_trees to authenticated;

-- Inventory and game-state writes must go through the validated functions below.
revoke insert, update on table public.player_characters from authenticated;
grant select on table public.player_characters to authenticated;

create or replace function public.start_new_life(p_background text)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_uid uuid := auth.uid(); v_coins integer; v_character public.player_characters%rowtype;
begin
  if v_uid is null then raise exception 'Sign in required'; end if;
  if p_background not in ('working','merchant','noble') then raise exception 'Invalid background'; end if;
  v_coins := case p_background when 'working' then 12 when 'merchant' then 85 else 240 end;
  insert into public.player_characters(user_id,character_name,background,coins,logs,planks,buildings,position_x,position_y,world_day,world_time,game_state)
  values(v_uid,'Wanderer',p_background,v_coins,0,0,0,350,250,1,8,'{}'::jsonb)
  on conflict(user_id) do update set character_name=excluded.character_name,background=excluded.background,
    coins=excluded.coins,logs=0,planks=0,buildings=0,position_x=350,position_y=250,
    world_day=1,world_time=8,game_state='{}'::jsonb,updated_at=now()
  returning * into v_character;
  delete from public.player_world_trees where user_id=v_uid;
  insert into public.player_world_trees(user_id,x,y)
  select v_uid,30+random()*660,25+random()*420 from generate_series(1,23);
  return jsonb_build_object('coins',v_character.coins,'logs',v_character.logs,'planks',v_character.planks,'buildings',v_character.buildings,'x',v_character.position_x,'y',v_character.position_y,'day',v_character.world_day,'background',v_character.background);
end; $$;

create or replace function public.move_player(p_dx integer,p_dy integer)
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_uid uuid:=auth.uid(); v_row public.player_characters%rowtype;
begin
  if v_uid is null then raise exception 'Sign in required'; end if;
  if abs(p_dx)>20 or abs(p_dy)>20 or (p_dx<>0 and p_dy<>0) or (p_dx=0 and p_dy=0) then raise exception 'Invalid movement'; end if;
  update public.player_characters set position_x=greatest(12,least(708,position_x+p_dx)),
    position_y=greatest(12,least(468,position_y+p_dy)),world_time=(world_time+1)%24,
    world_day=world_day+case when world_time=23 then 1 else 0 end,updated_at=now()
  where user_id=v_uid returning * into v_row;
  if not found then raise exception 'Start a character first'; end if;
  return jsonb_build_object('x',v_row.position_x,'y',v_row.position_y,'day',v_row.world_day,'world_time',v_row.world_time);
end; $$;

create or replace function public.chop_tree()
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_uid uuid:=auth.uid(); v_x numeric; v_y numeric; v_tree uuid; v_row public.player_characters%rowtype;
begin
  if v_uid is null then raise exception 'Sign in required'; end if;
  select position_x,position_y into v_x,v_y from public.player_characters where user_id=v_uid;
  if not found then raise exception 'Start a character first'; end if;
  select id into v_tree from public.player_world_trees
  where user_id=v_uid and alive and power(x-v_x,2)+power(y-v_y,2)<3844
  order by power(x-v_x,2)+power(y-v_y,2) limit 1 for update;
  if v_tree is null then raise exception 'No living tree is within reach'; end if;
  update public.player_world_trees set alive=false where id=v_tree;
  update public.player_characters set logs=logs+3,updated_at=now() where user_id=v_uid returning * into v_row;
  return jsonb_build_object('logs',v_row.logs,'tree_id',v_tree);
end; $$;

create or replace function public.craft_plank()
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_uid uuid:=auth.uid(); v_row public.player_characters%rowtype;
begin
  if v_uid is null then raise exception 'Sign in required'; end if;
  update public.player_characters set logs=logs-2,planks=planks+1,updated_at=now()
  where user_id=v_uid and logs>=2 returning * into v_row;
  if not found then raise exception 'You need at least 2 logs'; end if;
  return jsonb_build_object('logs',v_row.logs,'planks',v_row.planks);
end; $$;

create or replace function public.build_cabin()
returns jsonb language plpgsql security definer set search_path = ''
as $$
declare v_uid uuid:=auth.uid(); v_row public.player_characters%rowtype;
begin
  if v_uid is null then raise exception 'Sign in required'; end if;
  update public.player_characters set planks=planks-8,buildings=buildings+1,updated_at=now()
  where user_id=v_uid and planks>=8 returning * into v_row;
  if not found then raise exception 'A cabin requires 8 planks'; end if;
  return jsonb_build_object('planks',v_row.planks,'buildings',v_row.buildings);
end; $$;

create or replace function public.save_world_clock(p_day integer,p_world_time integer)
returns void language plpgsql security definer set search_path = ''
as $$
begin
  if auth.uid() is null then raise exception 'Sign in required'; end if;
  if p_day<1 or p_world_time<0 or p_world_time>23 then raise exception 'Invalid world time'; end if;
  update public.player_characters set world_day=p_day,world_time=p_world_time,updated_at=now() where user_id=auth.uid();
  if not found then raise exception 'Start a character first'; end if;
end; $$;

revoke all on function public.start_new_life(text) from public,anon;
revoke all on function public.move_player(integer,integer) from public,anon;
revoke all on function public.chop_tree() from public,anon;
revoke all on function public.craft_plank() from public,anon;
revoke all on function public.build_cabin() from public,anon;
revoke all on function public.save_world_clock(integer,integer) from public,anon;
grant execute on function public.start_new_life(text) to authenticated;
grant execute on function public.move_player(integer,integer) to authenticated;
grant execute on function public.chop_tree() to authenticated;
grant execute on function public.craft_plank() to authenticated;
grant execute on function public.build_cabin() to authenticated;
grant execute on function public.save_world_clock(integer,integer) to authenticated;

-- Give existing characters a forest without changing their inventory or location.
insert into public.player_world_trees(user_id,x,y)
select pc.user_id,30+random()*660,25+random()*420
from public.player_characters pc
where not exists(select 1 from public.player_world_trees t where t.user_id=pc.user_id);
