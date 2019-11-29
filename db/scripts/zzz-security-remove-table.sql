

DO
$body$
  DECLARE 
    _pol pg_policies;
    _drop_sql text;
  BEGIN

    for _pol in
      select 
        *
      from pg_policies
    loop
      _drop_sql := 'drop policy if exists ' || _pol.policyname || ' on ' || _pol.schemaname || '.' || _pol.tablename || ';';
      -- raise notice 'pol: %', _pol.policyname;
      -- raise notice '_drop_sql: %', _drop_sql;
      execute _drop_sql;
    end loop
    ;
  END
$body$;
