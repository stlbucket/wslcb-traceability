-- Deploy app-roles:0010-roles to pg

BEGIN;

    DO $$
    BEGIN
        PERFORM true FROM pg_roles WHERE rolname = 'app_user';
        IF NOT FOUND THEN
          CREATE ROLE app_user;
        END IF;
    END;
    $$;

COMMIT;
