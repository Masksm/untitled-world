-- Record the frontier market action in the versioned schema history.
create or replace function public.sell_resource(p_resource text,p_quantity integer)
returns jsonb language plpgsql security definer set search_path=''
as $$
declare v_uid uuid:=auth.uid(); v_row public.player_characters%rowtype; v_price integer; v_total integer;
begin
 if v_uid is null then raise exception 'Sign in required'; end if;
 if p_resource not in ('logs','planks') then raise exception 'Unsupported market good'; end if;
 if p_quantity is null or p_quantity<1 or p_quantity>500 then raise exception 'Invalid quantity'; end if;
 select * into v_row from public.player_characters where user_id=v_uid for update;
 if not found then raise exception 'Start a character first'; end if;
 if power(v_row.position_x-610,2)+power(v_row.position_y-250,2)>4225 then raise exception 'Visit the market stall to trade'; end if;
 if p_resource='logs' then
  if v_row.logs<p_quantity then raise exception 'You do not have that many logs'; end if;
  v_price:=2; v_total:=p_quantity*v_price;
  update public.player_characters set logs=logs-p_quantity,coins=coins+v_total,updated_at=now() where user_id=v_uid returning * into v_row;
 else
  if v_row.planks<p_quantity then raise exception 'You do not have that many planks'; end if;
  v_price:=7; v_total:=p_quantity*v_price;
  update public.player_characters set planks=planks-p_quantity,coins=coins+v_total,updated_at=now() where user_id=v_uid returning * into v_row;
 end if;
 return jsonb_build_object('coins',v_row.coins,'logs',v_row.logs,'planks',v_row.planks,'sold',p_quantity,'resource',p_resource,'earned',v_total);
end; $$;
revoke all on function public.sell_resource(text,integer) from public,anon;
grant execute on function public.sell_resource(text,integer) to authenticated;
