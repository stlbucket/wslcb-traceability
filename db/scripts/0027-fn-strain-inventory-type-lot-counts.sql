CREATE TYPE lcb_fn.strain_inventory_type_lot_count AS (
  strain_id text,
  strain_name text,
  inventory_type text,
  inventory_type_name text,
  count bigint
);

CREATE OR REPLACE FUNCTION lcb_fn.strain_inventory_type_lot_counts() 
RETURNS setof lcb_fn.strain_inventory_type_lot_count
    LANGUAGE plpgsql STRICT STABLE
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _retval jsonb;
  BEGIN
    _current_app_user := auth_fn.current_app_user();
    
    return query select distinct
      st.id strain_id
      ,st.name strain_name
      ,it.id inventory_type
      ,it.name inventory_type_name
      ,count(*)
    from lcb.strain st
    join lcb.inventory_lot il on il.strain_id = st.id
    join lcb_ref.inventory_type it on il.inventory_type = it.id
    group by
      st.id
      ,st.name
      ,it.id
      ,it.name
  ;
  end;
  $$;

grant execute on function lcb_fn.strain_inventory_type_lot_counts to app_user;
-- select coalesce((array_to_json(array_agg(row_to_json(s))))::jsonb, '[]'::jsonb)
-- FROM (
--   select distinct
--     st.id strain_id
--     ,st.name strain_name
--     ,it.id inventory_type
--     ,it.name inventory_type_name
--     ,count(*)
--   from lcb.strain st
--   join lcb.inventory_lot il on il.strain_id = st.id
--   join lcb_ref.inventory_type it on il.inventory_type = it.id
--   group by
--     st.id
--     ,st.name
--     ,it.id
--     ,it.name
-- ) s
-- ;