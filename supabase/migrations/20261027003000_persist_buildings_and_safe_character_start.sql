-- Persist player buildings and make starting a life non-destructive.
create table if not exists public.player_world_buildings (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 building_type text not null default 'cabin' check (building_type in ('cabin')),
 x numeric not null check (x between 0 and 720),
 y numeric not null check (y between 0 and 480),
 created_at timestamptz not null default now()
);
alter table public.player_world_buildings enable row level security;
drop policy if exists "Players can view their own world buildings" on public.player_world_buildings;
create policy "Players can view their own world buildings" on public.player_world_buildings
for select to authenticated using ((select auth.uid())=user_id);
revoke all on public.player_world_buildings from anon,authenticated;
grant select on public.player_world_buildings to authenticated;

create or replace function public.start_new_life(p_background text)
returns jsonb language plpgsql security definer set search_path=''
as $$
declare v_uid uuid:=auth.uid(); v_character public.player_characters%rowtype;
begin
 if v_uid is null then raise exception 'Sign in required'; end if;
 if p_background not in ('working','merchant','noble') then raise exception 'Invalid background'; end if;
 select * into v_character from public.player_characters where user_id=v_uid;
 if found then return jsonb_build_object('existing',true,'coins',v_character.coins,'logs',v_character.logs,'planks',v_character.planks,'buildings',v_character.buildings,'x',v_character.position_x,'y',v_character.position_y,'day',v_character.world_day,'background',v_character.background); end if;
 insert into public.player_characters(user_id,character_name,background,coins,logs,planks,buildings,position_x,position_y,world_day,world_time,game_state)
 values(v_uid,'Wanderer',p_background,case p_background when 'working' then 12 when 'merchant' then 85 else 240 end,0,0,0,350,250,1,8,'{}'::jsonb)
 returning * into v_character;
 insert into public.player_world_trees(user_id,x,y) select v_uid,30+random()*660,25+random()*420 from generate_series(1,23);
 return jsonb_build_object('existing',false,'coins',v_character.coins,'logs',v_character.logs,'planks',v_character.planks,'buildings',v_character.buildings,'x',v_character.position_x,'y',v_character.position_y,'day',v_character.world_day,'background',v_character.background);
end; $$;

create or replace function public.build_cabin(p_x numeric,p_y numeric)
returns jsonb language plpgsql security definer set search_path=''
as $$
declare v_uid uuid:=auth.uid(); v_row public.player_characters%rowtype; v_building uuid;
begin
 if v_uid is null then raise exception 'Sign in required'; end if;
 if p_x<0 or p_x>720 or p_y<0 or p_y>480 then raise exception 'Invalid building location'; end if;
 if not exists(select 1 from public.player_characters where user_id=v_uid) then raise exception 'Start a character first'; end if;
 if not exists(select 1 from public.player_characters where user_id=v_uid and planks>=8) then raise exception 'A cabin requires 8 planks'; end if;
 if exists(select 1 from public.player_characters where user_id=v_uid and power(position_x-p_x,2)+power(position_y-p_y,2)>2500) then raise exception 'Build closer to your character'; end if;
 update public.player_characters set planks=planks-8,buildings=buildings+1,updated_at=now() where user_id=v_uid and planks>=8 returning * into v_row;
 if not found then raise exception 'A cabin requires 8 planks'; end if;
 insert into public.player_world_buildings(user_id,building_type,x,y) values(v_uid,'cabin',p_x,p_y) returning id into v_building;
 return jsonb_build_object('planks',v_row.planks,'buildings',v_row.buildings,'id',v_building,'x',p_x,'y',p_y,'building_type','cabin');
end; $$;
revoke all on function public.start_new_life(text) from public,anon;
revoke all on function public.build_cabin(numeric,numeric) from public,anon;
grant execute on function public.start_new_life(text) to authenticated;
grant execute on function public.build_cabin(numeric,numeric) to authenticated;
