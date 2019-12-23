  DO
  $body$
    DECLARE 
    BEGIN
      raise notice 'jessica or molly?';

      if (select 1) is null then
        raise notice 'jessica';
      else
        raise notice 'molly';
      end if;

      raise notice 'why not both?';
    END
  $body$;
