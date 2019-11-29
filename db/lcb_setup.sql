--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 11.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: app; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA app;


ALTER SCHEMA app OWNER TO postgres;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- Name: auth_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth_fn;


ALTER SCHEMA auth_fn OWNER TO postgres;

--
-- Name: lcb; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA lcb;


ALTER SCHEMA lcb OWNER TO postgres;

--
-- Name: lcb_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA lcb_fn;


ALTER SCHEMA lcb_fn OWNER TO postgres;

--
-- Name: lcb_hist; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA lcb_hist;


ALTER SCHEMA lcb_hist OWNER TO postgres;

--
-- Name: org; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA org;


ALTER SCHEMA org OWNER TO postgres;

--
-- Name: org_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA org_fn;


ALTER SCHEMA org_fn OWNER TO postgres;

--
-- Name: shard_1; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA shard_1;


ALTER SCHEMA shard_1 OWNER TO postgres;

--
-- Name: util_fn; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA util_fn;


ALTER SCHEMA util_fn OWNER TO postgres;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: jwt_token; Type: TYPE; Schema: auth; Owner: postgres
--

CREATE TYPE auth.jwt_token AS (
	role text,
	app_user_id text,
	app_tenant_id text,
	token text
);


ALTER TYPE auth.jwt_token OWNER TO postgres;

--
-- Name: permission_key; Type: TYPE; Schema: auth; Owner: postgres
--

CREATE TYPE auth.permission_key AS ENUM (
    'Admin',
    'SuperAdmin',
    'Demon',
    'User'
);


ALTER TYPE auth.permission_key OWNER TO postgres;

--
-- Name: fn_timestamp_update_application(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_timestamp_update_application() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_timestamp_update_application() OWNER TO postgres;

--
-- Name: fn_timestamp_update_license(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_timestamp_update_license() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    if NEW.app_tenant_id is null then 
      -- only users with 'SuperAdmin' permission_key will be able to arbitrarily set this value
      -- rls policy (below) will prevent users from specifying an alternate app_tenant_id
      NEW.app_tenant_id := auth_fn.current_app_tenant_id();
    end if;
    -- NEW.organization_id = (select id from org.organization where actual_app_tenant_id = NEW.app_tenant_id);
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_timestamp_update_license() OWNER TO postgres;

--
-- Name: fn_timestamp_update_license_permission(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_timestamp_update_license_permission() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    if NEW.app_tenant_id is null then 
      -- only users with 'SuperAdmin' permission_key will be able to arbitrarily set this value
      -- rls policy (below) will prevent users from specifying an alternate app_tenant_id
      NEW.app_tenant_id := auth_fn.current_app_tenant_id();
    end if;
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_timestamp_update_license_permission() OWNER TO postgres;

--
-- Name: fn_timestamp_update_license_type(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_timestamp_update_license_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_timestamp_update_license_type() OWNER TO postgres;

--
-- Name: fn_timestamp_update_license_type_permission(); Type: FUNCTION; Schema: app; Owner: postgres
--

CREATE FUNCTION app.fn_timestamp_update_license_type_permission() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_timestamp_update_license_type_permission() OWNER TO postgres;

--
-- Name: fn_timestamp_update_app_tenant(); Type: FUNCTION; Schema: auth; Owner: postgres
--

CREATE FUNCTION auth.fn_timestamp_update_app_tenant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION auth.fn_timestamp_update_app_tenant() OWNER TO postgres;

--
-- Name: fn_timestamp_update_app_user(); Type: FUNCTION; Schema: auth; Owner: postgres
--

CREATE FUNCTION auth.fn_timestamp_update_app_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION auth.fn_timestamp_update_app_user() OWNER TO postgres;

--
-- Name: fn_timestamp_update_permission(); Type: FUNCTION; Schema: auth; Owner: postgres
--

CREATE FUNCTION auth.fn_timestamp_update_permission() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION auth.fn_timestamp_update_permission() OWNER TO postgres;

--
-- Name: app_user_has_access(text, text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text DEFAULT ''::text) RETURNS boolean
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _app_user auth.app_user;
    _retval boolean;
  BEGIN
    _app_user := (SELECT auth_fn.current_app_user());

    _retval := (_app_user.permission_key IN ('SuperAdmin')) OR (_app_user.app_tenant_id = _app_tenant_id);

    IF _permission_key = 'fail' THEN
      _retval := false;
    END IF;

    RETURN _retval;
  end;
  $$;


ALTER FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text) OWNER TO postgres;

--
-- Name: FUNCTION app_user_has_access(_app_tenant_id text, _permission_key text); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text) IS 'Verify if a user has access to an entity via the app_tenant_id';


--
-- Name: authenticate(text, text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.authenticate(_username text, _password text) RETURNS auth.jwt_token
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _app_user auth.app_user;
  BEGIN
    SELECT *
    INTO _app_user
    FROM auth.app_user
    WHERE username = _username;
  -- RAISE EXCEPTION 'WTF: %', _app_user;

    IF _app_user.password_hash = crypt(_password, _app_user.password_hash) THEN
      IF _app_user.permission_key = 'SuperAdmin' THEN
        RETURN ('app_super_admin', _app_user.id, _app_user.app_tenant_id, null)::auth.jwt_token;
      ELSEIF _app_user.permission_key = 'Admin' THEN
        RETURN ('app_admin', _app_user.id, _app_user.app_tenant_id, null)::auth.jwt_token;
      ELSEIF _app_user.permission_key = 'User' THEN
        RETURN ('app_user', _app_user.id, _app_user.app_tenant_id, null)::auth.jwt_token;
      ELSEIF _app_user.permission_key = 'Demon' THEN
        RETURN ('app_sync', _app_user.id, _app_user.app_tenant_id, null)::auth.jwt_token;
      END IF;
  
      RAISE EXCEPTION 'Invalid permission key: %', _app_user.permission_key;
    ELSE
      RAISE EXCEPTION 'Invalid username or password';
    END IF;
  end;
  $$;


ALTER FUNCTION auth_fn.authenticate(_username text, _password text) OWNER TO postgres;

--
-- Name: FUNCTION authenticate(_username text, _password text); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.authenticate(_username text, _password text) IS 'Creates a JWT token that will securely identify a contact and give them certain permissions.';


--
-- Name: generate_ulid(); Type: FUNCTION; Schema: util_fn; Owner: postgres
--

CREATE FUNCTION util_fn.generate_ulid() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  -- Crockford's Base32
  encoding   BYTEA = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  timestamp  BYTEA = E'\\000\\000\\000\\000\\000\\000';
  output     TEXT = '';

  unix_time  BIGINT;
  ulid       BYTEA;
BEGIN
  -- 6 timestamp bytes
  unix_time = (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT;
  timestamp = SET_BYTE(timestamp, 0, (unix_time >> 40)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 1, (unix_time >> 32)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 2, (unix_time >> 24)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 3, (unix_time >> 16)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 4, (unix_time >> 8)::BIT(8)::INTEGER);
  timestamp = SET_BYTE(timestamp, 5, unix_time::BIT(8)::INTEGER);

  -- 10 entropy bytes
  ulid = timestamp || gen_random_bytes(10);

  -- Encode the timestamp
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 0) & 224) >> 5));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 0) & 31)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 1) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 1) & 7) << 2) | ((GET_BYTE(ulid, 2) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 2) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 2) & 1) << 4) | ((GET_BYTE(ulid, 3) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 3) & 15) << 1) | ((GET_BYTE(ulid, 4) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 4) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 4) & 3) << 3) | ((GET_BYTE(ulid, 5) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 5) & 31)));

  -- Encode the entropy
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 6) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 6) & 7) << 2) | ((GET_BYTE(ulid, 7) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 7) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 7) & 1) << 4) | ((GET_BYTE(ulid, 8) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 8) & 15) << 1) | ((GET_BYTE(ulid, 9) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 9) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 9) & 3) << 3) | ((GET_BYTE(ulid, 10) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 10) & 31)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 11) & 248) >> 3));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 11) & 7) << 2) | ((GET_BYTE(ulid, 12) & 192) >> 6)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 12) & 62) >> 1));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 12) & 1) << 4) | ((GET_BYTE(ulid, 13) & 240) >> 4)));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 13) & 15) << 1) | ((GET_BYTE(ulid, 14) & 128) >> 7)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 14) & 124) >> 2));
  output = output || CHR(GET_BYTE(encoding, ((GET_BYTE(ulid, 14) & 3) << 3) | ((GET_BYTE(ulid, 15) & 224) >> 5)));
  output = output || CHR(GET_BYTE(encoding, (GET_BYTE(ulid, 15) & 31)));

  RETURN output;
END
$$;


ALTER FUNCTION util_fn.generate_ulid() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: app_tenant; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.app_tenant (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    identifier text NOT NULL,
    CONSTRAINT app_tenant_identifier_check CHECK ((identifier <> ''::text))
);


ALTER TABLE auth.app_tenant OWNER TO postgres;

--
-- Name: TABLE app_tenant; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.app_tenant IS '@omit create,update,delete';


--
-- Name: COLUMN app_tenant.id; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.app_tenant.id IS '@omit create';


--
-- Name: COLUMN app_tenant.created_at; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.app_tenant.created_at IS '@omit create,update';


--
-- Name: COLUMN app_tenant.updated_at; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.app_tenant.updated_at IS '@omit create,update';


--
-- Name: build_app_tenant(text, text); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) RETURNS auth.app_tenant
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _matcher text;
    _app_tenant auth.app_tenant;
  BEGIN
    if _name is null or _name = '' then
      raise exception 'Must specify name to create app tenant';
    end if;

    if _identifier is null or _identifier = '' then
      raise exception 'Must specify identifier to create app tenant';
    end if;

    SELECT *
    INTO _app_tenant
    FROM auth.app_tenant
    WHERE identifier = _identifier;

    IF _app_tenant.id IS NULL THEN
      INSERT INTO auth.app_tenant(
        name
        ,identifier
      )
      SELECT
        _name
        ,_identifier
      RETURNING *
      INTO _app_tenant
      ;
    END IF;

--    RAISE EXCEPTION '
--    _name: %
--    _app_tenant: %
--    '
--    ,_name
--    ,_app_tenant
--    ;

    RETURN _app_tenant;
  end;
  $$;


ALTER FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) OWNER TO postgres;

--
-- Name: FUNCTION build_app_tenant(_name text, _identifier text); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) IS 'Creates a new app user';


--
-- Name: app_user; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.app_user (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    username text NOT NULL,
    recovery_email text NOT NULL,
    password_hash text NOT NULL,
    inactive boolean DEFAULT false NOT NULL,
    password_reset_required boolean DEFAULT false NOT NULL,
    permission_key auth.permission_key NOT NULL
);


ALTER TABLE auth.app_user OWNER TO postgres;

--
-- Name: TABLE app_user; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.app_user IS '@omit create,update,delete';


--
-- Name: COLUMN app_user.id; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.app_user.id IS '@omit create';


--
-- Name: COLUMN app_user.created_at; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.app_user.created_at IS '@omit create,update';


--
-- Name: COLUMN app_user.updated_at; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.app_user.updated_at IS '@omit create,update';


--
-- Name: COLUMN app_user.password_hash; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.app_user.password_hash IS '@omit';


--
-- Name: build_app_user(text, text, text, text, auth.permission_key); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) RETURNS auth.app_user
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _app_user auth.app_user;
  BEGIN

    SELECT *
    INTO _app_user
    FROM auth.app_user
    WHERE username = _username;

    IF _app_user.id IS NOT NULL THEN
      RAISE EXCEPTION 'username already taken: %', _username;
    ELSE
      INSERT INTO auth.app_user(
        app_tenant_id
        ,username
        ,password_hash
        ,password_reset_required
        ,recovery_email
        ,permission_key
      )
      SELECT
        _app_tenant_id
        ,_username
        ,public.crypt(_password, public.gen_salt('bf'))
        ,true
        ,_recovery_email
        ,_permission_key
      RETURNING *
      INTO _app_user
      ;
    END IF;

    RETURN _app_user;
  end;
  $$;


ALTER FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) OWNER TO postgres;

--
-- Name: FUNCTION build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) IS 'Creates a new app user';


--
-- Name: current_app_tenant_id(); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.current_app_tenant_id() RETURNS text
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
  BEGIN
    return current_setting('jwt.claims.app_tenant_id')::text;
  end;
  $$;


ALTER FUNCTION auth_fn.current_app_tenant_id() OWNER TO postgres;

--
-- Name: FUNCTION current_app_tenant_id(); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.current_app_tenant_id() IS '@omit';


--
-- Name: current_app_user(); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.current_app_user() RETURNS auth.app_user
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT *
  FROM auth.app_user
  WHERE id = current_setting('jwt.claims.app_user_id')::text;
$$;


ALTER FUNCTION auth_fn.current_app_user() OWNER TO postgres;

--
-- Name: FUNCTION current_app_user(); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.current_app_user() IS '@ omit';


--
-- Name: current_app_user_id(); Type: FUNCTION; Schema: auth_fn; Owner: postgres
--

CREATE FUNCTION auth_fn.current_app_user_id() RETURNS text
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
  BEGIN
    return current_setting('jwt.claims.app_user_id')::text;
  end;
  $$;


ALTER FUNCTION auth_fn.current_app_user_id() OWNER TO postgres;

--
-- Name: FUNCTION current_app_user_id(); Type: COMMENT; Schema: auth_fn; Owner: postgres
--

COMMENT ON FUNCTION auth_fn.current_app_user_id() IS '@omit';


--
-- Name: fn_timestamp_update_inventory_lot(); Type: FUNCTION; Schema: lcb; Owner: postgres
--

CREATE FUNCTION lcb.fn_timestamp_update_inventory_lot() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION lcb.fn_timestamp_update_inventory_lot() OWNER TO postgres;

--
-- Name: fn_timestamp_update_lcb_license(); Type: FUNCTION; Schema: lcb; Owner: postgres
--

CREATE FUNCTION lcb.fn_timestamp_update_lcb_license() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION lcb.fn_timestamp_update_lcb_license() OWNER TO postgres;

--
-- Name: fn_timestamp_update_lcb_license_holder(); Type: FUNCTION; Schema: lcb; Owner: postgres
--

CREATE FUNCTION lcb.fn_timestamp_update_lcb_license_holder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION lcb.fn_timestamp_update_lcb_license_holder() OWNER TO postgres;

--
-- Name: fn_timestamp_update_contact(); Type: FUNCTION; Schema: org; Owner: postgres
--

CREATE FUNCTION org.fn_timestamp_update_contact() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    if NEW.app_tenant_id is null then 
      -- only users with 'SuperAdmin' permission_key will be able to arbitrarily set this value
      -- rls policy (below) will prevent users from specifying an alternate app_tenant_id
      NEW.app_tenant_id := auth_fn.current_app_tenant_id();
    end if;
    RETURN NEW;
  END; $$;


ALTER FUNCTION org.fn_timestamp_update_contact() OWNER TO postgres;

--
-- Name: fn_timestamp_update_contact_app_user(); Type: FUNCTION; Schema: org; Owner: postgres
--

CREATE FUNCTION org.fn_timestamp_update_contact_app_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    if NEW.app_tenant_id is null then 
      -- only users with 'SuperAdmin' permission_key will be able to arbitrarily set this value
      -- rls policy (below) will prevent users from specifying an alternate app_tenant_id
      NEW.app_tenant_id := auth_fn.current_app_tenant_id();
    end if;
    RETURN NEW;
  END; $$;


ALTER FUNCTION org.fn_timestamp_update_contact_app_user() OWNER TO postgres;

--
-- Name: fn_timestamp_update_facility(); Type: FUNCTION; Schema: org; Owner: postgres
--

CREATE FUNCTION org.fn_timestamp_update_facility() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    if NEW.app_tenant_id is null then 
      -- only users with 'SuperAdmin' permission_key will be able to arbitrarily set this value
      -- rls policy (below) will prevent users from specifying an alternate app_tenant_id
      NEW.app_tenant_id := auth_fn.current_app_tenant_id();
    end if;
    RETURN NEW;
  END; $$;


ALTER FUNCTION org.fn_timestamp_update_facility() OWNER TO postgres;

--
-- Name: fn_timestamp_update_location(); Type: FUNCTION; Schema: org; Owner: postgres
--

CREATE FUNCTION org.fn_timestamp_update_location() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    if NEW.app_tenant_id is null then 
      -- only users with 'SuperAdmin' permission_key will be able to arbitrarily set this value
      -- rls policy (below) will prevent users from specifying an alternate app_tenant_id
      NEW.app_tenant_id := auth_fn.current_app_tenant_id();
    end if;
    RETURN NEW;
  END; $$;


ALTER FUNCTION org.fn_timestamp_update_location() OWNER TO postgres;

--
-- Name: fn_timestamp_update_organization(); Type: FUNCTION; Schema: org; Owner: postgres
--

CREATE FUNCTION org.fn_timestamp_update_organization() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  begin
    if NEW.app_tenant_id is null then 
      -- only users with 'SuperAdmin' permission_key will be able to arbitrarily set this value
      -- rls policy (below) will prevent users from specifying an alternate app_tenant_id
      NEW.app_tenant_id := auth_fn.current_app_tenant_id();
    end if;

    NEW.updated_at = current_timestamp;

    return NEW;
  end; $$;


ALTER FUNCTION org.fn_timestamp_update_organization() OWNER TO postgres;

--
-- Name: contact; Type: TABLE; Schema: org; Owner: postgres
--

CREATE TABLE org.contact (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    organization_id text,
    location_id text,
    external_id text,
    first_name text,
    last_name text,
    email text,
    cell_phone text,
    office_phone text,
    title text,
    nickname text
);


ALTER TABLE org.contact OWNER TO postgres;

--
-- Name: COLUMN contact.id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact.id IS '@omit create';


--
-- Name: COLUMN contact.app_tenant_id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact.app_tenant_id IS '@omit create, update';


--
-- Name: COLUMN contact.created_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact.created_at IS '@omit create,update';


--
-- Name: COLUMN contact.updated_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact.updated_at IS '@omit create,update';


--
-- Name: COLUMN contact.organization_id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact.organization_id IS '@omit create,update';


--
-- Name: build_contact(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.build_contact(_first_name text, _last_name text, _email text, _cell_phone text, _office_phone text, _title text, _nickname text, _external_id text, _organization_id text) RETURNS org.contact
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  declare
    _app_user auth.app_user;
    _app_tenant_id text;
    _contact org.contact;
    _organization org.organization;
  begin
    _app_user := auth_fn.current_app_user();

    SELECT *
    INTO _organization
    FROM org.organization
    WHERE id = _organization_id;

    IF _organization.id IS NULL THEN
      RAISE EXCEPTION 'No organization exists for id: %', _organization_id;
    END IF;

    SELECT *
    INTO _contact
    FROM org.contact
    WHERE (email = _email AND app_tenant_id = _app_user.app_tenant_id)
    OR (external_id = _external_id AND app_tenant_id = _app_user.app_tenant_id);

    IF _contact.id IS NULL THEN
      INSERT INTO org.contact(
        first_name
        ,last_name
        ,email
        ,cell_phone
        ,office_phone
        ,title
        ,nickname
        ,organization_id
        ,app_tenant_id
      )
      SELECT
        _first_name
        ,_last_name
        ,_email
        ,_cell_phone
        ,_office_phone
        ,_title
        ,_nickname
        ,_organization_id
        ,_organization.app_tenant_id
      RETURNING *
      INTO _contact;
    END IF;

    RETURN _contact;

  end;
  $$;


ALTER FUNCTION org_fn.build_contact(_first_name text, _last_name text, _email text, _cell_phone text, _office_phone text, _title text, _nickname text, _external_id text, _organization_id text) OWNER TO postgres;

--
-- Name: build_contact_location(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.build_contact_location(_contact_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) RETURNS org.contact
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  declare
    _app_user auth.app_user;
    _contact org.contact;
    _location org.location;
  begin
    _app_user := auth_fn.current_app_user();
    
    SELECT *
    INTO _contact
    FROM org.contact c
    WHERE id = _contact_id
    AND auth_fn.app_user_has_access(c.app_tenant_id)
    ;

    IF _contact.id IS NULL THEN
      RAISE EXCEPTION 'No contact for id: %', _contact_id;
    END IF;

    IF _contact.location_id IS NULL THEN
      _location := org_fn.build_location(
        _name
        ,_address1
        ,_address2
        ,_city
        ,_state
        ,_zip
        ,_lat
        ,_lon
      );

      UPDATE org.contact c
      SET location_id = _location.id
      WHERE id = _contact_id
      RETURNING *
      INTO _contact
      ;
    ELSE
      _location := org_fn.modify_location(
        _contact.location_id
        ,_name
        ,_address1
        ,_address2
        ,_city
        ,_state
        ,_zip
        ,_lat
        ,_lon
      )
      ;
    END IF;

    RETURN _contact;

  end;
  $$;


ALTER FUNCTION org_fn.build_contact_location(_contact_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO postgres;

--
-- Name: facility; Type: TABLE; Schema: org; Owner: postgres
--

CREATE TABLE org.facility (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    organization_id text,
    location_id text,
    name text,
    external_id text
);


ALTER TABLE org.facility OWNER TO postgres;

--
-- Name: COLUMN facility.id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.facility.id IS '@omit create';


--
-- Name: COLUMN facility.app_tenant_id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.facility.app_tenant_id IS '@omit create';


--
-- Name: COLUMN facility.created_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.facility.created_at IS '@omit create,update';


--
-- Name: COLUMN facility.updated_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.facility.updated_at IS '@omit create,update';


--
-- Name: build_facility(text, text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.build_facility(_organization_id text, _name text, _external_id text) RETURNS org.facility
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  declare
    _app_user auth.app_user;
    _app_tenant_id text;
    _facility org.facility;
    _organization org.organization;
  begin
    _app_user := auth_fn.current_app_user();

    SELECT *
    INTO _organization
    FROM org.organization
    WHERE id = _organization_id;

    IF _organization.id IS NULL THEN
      RAISE EXCEPTION 'No organization exists for id: %', _organization_id;
    END IF;

    SELECT *
    INTO _facility
    FROM org.facility
    WHERE (name = _name AND organization_id = _organization_id)
    OR (external_id = _external_id AND organization_id = _organization_id)
    ;

    IF _facility.id IS NULL THEN
      INSERT INTO org.facility(
        organization_id
        ,app_tenant_id
        ,name
        ,external_id
      )
      SELECT
        _organization_id
        ,_organization.app_tenant_id
        ,_name
        ,_external_id
      RETURNING *
      INTO _facility;
    END IF;

    RETURN _facility;

  end;
  $$;


ALTER FUNCTION org_fn.build_facility(_organization_id text, _name text, _external_id text) OWNER TO postgres;

--
-- Name: build_facility_location(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.build_facility_location(_facility_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) RETURNS org.facility
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  declare
    _app_user auth.app_user;
    _facility org.facility;
    _location org.location;
  begin
    _app_user := auth_fn.current_app_user();
    
    SELECT *
    INTO _facility
    FROM org.facility o
    WHERE id = _facility_id
    AND auth_fn.app_user_has_access(o.app_tenant_id)
    ;

    IF _facility.id IS NULL THEN
      RAISE EXCEPTION 'No facility for id: %', _facility_id;
    END IF;
    
    IF _facility.location_id IS NULL THEN
      _location := org_fn.build_location(
        _name
        ,_address1
        ,_address2
        ,_city
        ,_state
        ,_zip
        ,_lat
        ,_lon
      );

      UPDATE org.facility
      SET location_id = _location.id
      WHERE id = _facility_id
      RETURNING *
      INTO _facility
      ;
    ELSE
      _location := org_fn.modify_location(
        _facility.location_id
        ,_name
        ,_address1
        ,_address2
        ,_city
        ,_state
        ,_zip
        ,_lat
        ,_lon
      )
      ;
    END IF;

    RETURN _facility;

  end;
  $$;


ALTER FUNCTION org_fn.build_facility_location(_facility_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO postgres;

--
-- Name: location; Type: TABLE; Schema: org; Owner: postgres
--

CREATE TABLE org.location (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    external_id text,
    name text,
    address1 text,
    address2 text,
    city text,
    state text,
    zip text,
    lat text,
    lon text
);


ALTER TABLE org.location OWNER TO postgres;

--
-- Name: COLUMN location.id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.location.id IS '@omit create';


--
-- Name: COLUMN location.app_tenant_id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.location.app_tenant_id IS '@omit create';


--
-- Name: COLUMN location.created_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.location.created_at IS '@omit create,update';


--
-- Name: COLUMN location.updated_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.location.updated_at IS '@omit create,update';


--
-- Name: build_location(text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.build_location(_name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) RETURNS org.location
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
declare
  _app_user auth.app_user;
  _location org.location;
begin
  _app_user := (SELECT auth_fn.current_app_user());

  INSERT INTO org.location(
    name
    ,address1
    ,address2
    ,city
    ,state
    ,zip
    ,lat
    ,lon
    ,app_tenant_id
  )
  SELECT
    _name
    ,_address1
    ,_address2
    ,_city
    ,_state
    ,_zip
    ,_lat
    ,_lon
    ,_app_user.app_tenant_id

  RETURNING *
  INTO _location
  ;

  RETURN _location;

end;
$$;


ALTER FUNCTION org_fn.build_location(_name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO postgres;

--
-- Name: organization; Type: TABLE; Schema: org; Owner: postgres
--

CREATE TABLE org.organization (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    actual_app_tenant_id text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    external_id text,
    name text NOT NULL,
    location_id text,
    primary_contact_id text,
    CONSTRAINT organization_name_check CHECK ((name <> ''::text))
);


ALTER TABLE org.organization OWNER TO postgres;

--
-- Name: COLUMN organization.id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.organization.id IS '@omit create';


--
-- Name: COLUMN organization.app_tenant_id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.organization.app_tenant_id IS '@omit create';


--
-- Name: COLUMN organization.created_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.organization.created_at IS '@omit create,update';


--
-- Name: COLUMN organization.updated_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.organization.updated_at IS '@omit create,update';


--
-- Name: build_organization(text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.build_organization(_name text, _external_id text) RETURNS org.organization
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
declare
  _app_user auth.app_user;
  _organization org.organization;
begin
  _app_user := (SELECT auth_fn.current_app_user());

  SELECT *
  INTO _organization
  FROM org.organization
  WHERE (name = _name AND app_tenant_id = _app_user.app_tenant_id)
  OR (external_id = _external_id AND app_tenant_id = _app_user.app_tenant_id);

  IF _organization.id IS NULL THEN
    INSERT INTO org.organization(
      name
      ,external_id
      ,app_tenant_id
    )
    SELECT
      _name
      ,_external_id
      ,_app_user.app_tenant_id
    RETURNING *
    INTO _organization
    ;
  END IF;

  RETURN _organization;

end;
$$;


ALTER FUNCTION org_fn.build_organization(_name text, _external_id text) OWNER TO postgres;

--
-- Name: build_organization_location(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.build_organization_location(_organization_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) RETURNS org.organization
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  declare
    _app_user auth.app_user;
    _organization org.organization;
    _location org.location;
  begin
    _app_user := auth_fn.current_app_user();
    
    SELECT *
    INTO _organization
    FROM org.organization o
    WHERE id = _organization_id
    AND auth_fn.app_user_has_access(o.app_tenant_id)
    ;

    IF _organization.id IS NULL THEN
      RAISE EXCEPTION 'No organization for id: %', _organization_id;
    END IF;
    
    IF _organization.location_id IS NULL THEN
      _location := org_fn.build_location(
        _name
        ,_address1
        ,_address2
        ,_city
        ,_state
        ,_zip
        ,_lat
        ,_lon
      );

      UPDATE org.organization
      SET location_id = _location.id
      WHERE id = _organization_id
      RETURNING *
      INTO _organization
      ;
    ELSE
      _location := org_fn.modify_location(
        _organization.location_id
        ,_name
        ,_address1
        ,_address2
        ,_city
        ,_state
        ,_zip
        ,_lat
        ,_lon
      )
      ;
    END IF;

    RETURN _organization;

  end;
  $$;


ALTER FUNCTION org_fn.build_organization_location(_organization_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO postgres;

--
-- Name: build_tenant_organization(text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.build_tenant_organization(_name text, _identifier text, _primary_contact_email text, _primary_contact_first_name text, _primary_contact_last_name text) RETURNS org.organization
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
declare
  _app_tenant auth.app_tenant;
  _app_user auth.app_user;
  _organization org.organization;
  _primary_contact org.contact;
begin

  _app_tenant := auth_fn.build_app_tenant(
    _name
    ,_identifier
  );

  SELECT *
  INTO _app_user
  FROM auth.app_user
  WHERE app_tenant_id = _app_tenant.id
  AND username = _primary_contact_email
  ;

  IF _app_user.id IS NULL THEN
    _app_user := auth_fn.build_app_user(
        _app_tenant.id
        ,_primary_contact_email
        ,'badpassword'
        ,_primary_contact_email
        ,'Admin'
      )
    ;
  END IF;

  SELECT *
  INTO _organization
  FROM org.organization
  WHERE name = _name
  AND app_tenant_id = _app_tenant.id
  ;

  IF _organization.id IS NULL THEN
    INSERT INTO
    org.organization(
      name
      ,external_id
      ,app_tenant_id
      ,actual_app_tenant_id
    )
    SELECT
      _name
      ,_identifier
      ,_app_tenant.id
      ,_app_tenant.id
    RETURNING *
    INTO _organization;
  END IF;

  UPDATE auth.app_tenant
  SET identifier = _organization.id
  WHERE id = _app_tenant.id
  RETURNING *
  INTO _app_tenant
  ;

  SELECT *
  INTO _primary_contact
  FROM org.contact
  WHERE organization_id = _organization.id
  AND email = _primary_contact_email;

  IF _primary_contact.id IS NULL THEN
    _primary_contact := org_fn.build_contact(
      _primary_contact_first_name
      ,_primary_contact_last_name
      ,_primary_contact_email
      ,''
      ,''
      ,''
      ,''
      ,''
      ,_organization.id
    );

    INSERT INTO org.contact_app_user(contact_id, app_user_id, app_tenant_id, username)
    SELECT _primary_contact.id, _app_user.id, _app_tenant.id, _app_user.username
    ON conflict do nothing
    ;
  END IF;

  RETURN _organization;

end;
$$;


ALTER FUNCTION org_fn.build_tenant_organization(_name text, _identifier text, _primary_contact_email text, _primary_contact_first_name text, _primary_contact_last_name text) OWNER TO postgres;

--
-- Name: current_app_user_contact(); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.current_app_user_contact() RETURNS org.contact
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
declare
  _app_user auth.app_user;
  _contact org.contact;
begin
  _app_user := (SELECT auth_fn.current_app_user());

  SELECT *
  INTO _contact
  FROM org.contact
  WHERE id = (select contact_id from org.contact_app_user where app_user_id = _app_user.id);

  RETURN _contact;

end;
$$;


ALTER FUNCTION org_fn.current_app_user_contact() OWNER TO postgres;

--
-- Name: modify_location(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: postgres
--

CREATE FUNCTION org_fn.modify_location(_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) RETURNS org.location
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
declare
  _app_user auth.app_user;
  _location org.location;
begin
  _app_user := (SELECT auth_fn.current_app_user());

  SELECT *
  INTO _location
  FROM org.location
  WHERE id = _id
  AND auth_fn.app_user_has_access(app_tenant_id)
  ;

  IF _location.id IS NULL THEN
    RAISE EXCEPTION 'No location for id: %', _id;
  END IF;

  UPDATE org.location
  SET
    name = _name
    ,address1 = _address1
    ,address2 = _address2
    ,city = _city
    ,state = _state
    ,zip = _zip
    ,lat = _lat
    ,lon = _lon
  WHERE id = _location.id
  RETURNING *
  INTO _location
  ;

  RETURN _location;

end;
$$;


ALTER FUNCTION org_fn.modify_location(_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO postgres;

--
-- Name: trim_text(text); Type: FUNCTION; Schema: util_fn; Owner: postgres
--

CREATE FUNCTION util_fn.trim_text(_input text) RETURNS text
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
    _trim_regex text;
    _retval text;
  BEGIN
    -- _app_user := (SELECT auth_fn.current_app_user());
    _trim_regex := '\S(?:.*\S)*';
    _retval = substring(_input, _trim_regex);
    return _retval;
  END;
  $$;


ALTER FUNCTION util_fn.trim_text(_input text) OWNER TO postgres;

--
-- Name: application; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.application (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    external_id text,
    name text,
    key text NOT NULL
);


ALTER TABLE app.application OWNER TO postgres;

--
-- Name: license; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    external_id text,
    name text,
    license_type_id text NOT NULL,
    assigned_to_app_user_id text
);


ALTER TABLE app.license OWNER TO postgres;

--
-- Name: TABLE license; Type: COMMENT; Schema: app; Owner: postgres
--

COMMENT ON TABLE app.license IS '@foreignKey (assigned_to_app_user_id) references org.contact_app_user(app_user_id)';


--
-- Name: license_permission; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license_permission (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    license_id text NOT NULL,
    permission_id text NOT NULL
);


ALTER TABLE app.license_permission OWNER TO postgres;

--
-- Name: license_type; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license_type (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    external_id text,
    name text,
    key text NOT NULL,
    application_id text NOT NULL
);


ALTER TABLE app.license_type OWNER TO postgres;

--
-- Name: license_type_permission; Type: TABLE; Schema: app; Owner: postgres
--

CREATE TABLE app.license_type_permission (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    license_type_id text NOT NULL,
    permission_id text NOT NULL,
    key text NOT NULL
);


ALTER TABLE app.license_type_permission OWNER TO postgres;

--
-- Name: config_auth; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.config_auth (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    key text,
    value text
);


ALTER TABLE auth.config_auth OWNER TO postgres;

--
-- Name: TABLE config_auth; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.config_auth IS '@omit create,update,delete';


--
-- Name: permission; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.permission (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key text,
    CONSTRAINT permission_key_check CHECK ((char_length(key) >= 4))
);


ALTER TABLE auth.permission OWNER TO postgres;

--
-- Name: token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth.token (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_user_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP + '00:20:00'::interval) NOT NULL
);


ALTER TABLE auth.token OWNER TO postgres;

--
-- Name: TABLE token; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON TABLE auth.token IS '@omit create,update,delete';


--
-- Name: COLUMN token.created_at; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.token.created_at IS '@omit create,update';


--
-- Name: COLUMN token.expires_at; Type: COMMENT; Schema: auth; Owner: postgres
--

COMMENT ON COLUMN auth.token.expires_at IS '@omit create,update';


--
-- Name: inventory_lot; Type: TABLE; Schema: lcb; Owner: postgres
--

CREATE TABLE lcb.inventory_lot (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    lcb_license_holder_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    id_origin text NOT NULL,
    inventory_type text NOT NULL,
    description text,
    quantity numeric(10,2),
    units text,
    strain_name text,
    area_identifier text,
    CONSTRAINT ck_inventory_lot_id CHECK ((id <> ''::text)),
    CONSTRAINT ck_inventory_lot_id_origin CHECK ((id_origin <> ''::text)),
    CONSTRAINT ck_inventory_lot_inventory_type CHECK ((inventory_type <> ''::text))
);


ALTER TABLE lcb.inventory_lot OWNER TO postgres;

--
-- Name: lcb_license; Type: TABLE; Schema: lcb; Owner: postgres
--

CREATE TABLE lcb.lcb_license (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    code text NOT NULL,
    CONSTRAINT ck_lcb_license_code CHECK ((code <> ''::text)),
    CONSTRAINT lcb_license_code_check CHECK ((code <> ''::text))
);


ALTER TABLE lcb.lcb_license OWNER TO postgres;

--
-- Name: lcb_license_holder; Type: TABLE; Schema: lcb; Owner: postgres
--

CREATE TABLE lcb.lcb_license_holder (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    lcb_license_id text NOT NULL,
    organization_id text NOT NULL,
    acquisition_date timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    relinquish_date timestamp with time zone
);


ALTER TABLE lcb.lcb_license_holder OWNER TO postgres;

--
-- Name: config_org; Type: TABLE; Schema: org; Owner: postgres
--

CREATE TABLE org.config_org (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    key text,
    value text
);


ALTER TABLE org.config_org OWNER TO postgres;

--
-- Name: TABLE config_org; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON TABLE org.config_org IS '@omit create,update,delete';


--
-- Name: contact_app_user; Type: TABLE; Schema: org; Owner: postgres
--

CREATE TABLE org.contact_app_user (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    contact_id text NOT NULL,
    app_user_id text NOT NULL,
    username text NOT NULL,
    CONSTRAINT contact_app_user_username_check CHECK ((username <> ''::text))
);


ALTER TABLE org.contact_app_user OWNER TO postgres;

--
-- Name: COLUMN contact_app_user.id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact_app_user.id IS '@omit create';


--
-- Name: COLUMN contact_app_user.app_tenant_id; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact_app_user.app_tenant_id IS '@omit create';


--
-- Name: COLUMN contact_app_user.created_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact_app_user.created_at IS '@omit create,update';


--
-- Name: COLUMN contact_app_user.updated_at; Type: COMMENT; Schema: org; Owner: postgres
--

COMMENT ON COLUMN org.contact_app_user.updated_at IS '@omit create,update';


--
-- Name: global_id_sequence; Type: SEQUENCE; Schema: shard_1; Owner: postgres
--

CREATE SEQUENCE shard_1.global_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE shard_1.global_id_sequence OWNER TO postgres;

--
-- Data for Name: application; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.application (id, created_at, updated_at, external_id, name, key) FROM stdin;
01DTWQ2DSFBF3087ZJ5WXWCHVQ	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	Tenant Manager	tenant-manager
01DTWQ2DSF85A278YPYM0E9RYA	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	License Manager	license-manager
01DTWQ2DSFE0NNPH9FN20C97CF	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	address book	address-book
01DTWQ2DSFN05TEG9BTWW5YYJ2	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	LCB Traceability	lcb-traceability
\.


--
-- Data for Name: license; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license (id, app_tenant_id, created_at, updated_at, external_id, name, license_type_id, assigned_to_app_user_id) FROM stdin;
01DTWQ2DSFV3V0NQPABTPZVAF4	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	appsuperadmin - Tenant Manager	01DTWQ2DSF0AH8BFW34EV6V462	01DTWQ2D28455Z8RETA2Q9N2H7
01DTWQ2DSFYX3R4SBH5R6BFSYZ	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	appsuperadmin - License Manager	01DTWQ2DSF1CXH7QW5VHTJKHPK	01DTWQ2D28455Z8RETA2Q9N2H7
01DTWQ2DSFRCPCN9J9PXFNP94S	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_producer_admin - License Manager	01DTWQ2DSF1CXH7QW5VHTJKHPK	01DTWQ2DEGFFTFQ39VPQPY811M
01DTWQ2DSF7J01FGSM9K3KF212	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_processor_admin - License Manager	01DTWQ2DSF1CXH7QW5VHTJKHPK	01DTWQ2DEG70MRECH2F5RPF719
01DTWQ2DSF97ZHPY9WJH1F8465	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_retail_admin - License Manager	01DTWQ2DSF1CXH7QW5VHTJKHPK	01DTWQ2DEGFQ22K76EX777P9SS
01DTWQ2DSFN9S1P5GEJGRYPN30	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	appsuperadmin - Address Book	01DTWQ2DSFC2VB12W5QYKPY4MA	01DTWQ2D28455Z8RETA2Q9N2H7
01DTWQ2DSF9GFC1KHFHKZRV7XV	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_producer_admin - Address Book	01DTWQ2DSFC2VB12W5QYKPY4MA	01DTWQ2DEGFFTFQ39VPQPY811M
01DTWQ2DSFH8ZJ951QSN55EP35	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_producer_user - Address Book	01DTWQ2DSFC2VB12W5QYKPY4MA	01DTWQ2DEGM404YQZHVBWRBCPC
01DTWQ2DSFRWG3CH088JWEZEET	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_processor_admin - Address Book	01DTWQ2DSFC2VB12W5QYKPY4MA	01DTWQ2DEG70MRECH2F5RPF719
01DTWQ2DSF59S9JSDB9Z4RTJP0	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_processor_user - Address Book	01DTWQ2DSFC2VB12W5QYKPY4MA	01DTWQ2DEGXT143WN4M045ZEBT
01DTWQ2DSFNMYX1B3P6Z6AH3EE	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_retail_admin - Address Book	01DTWQ2DSFC2VB12W5QYKPY4MA	01DTWQ2DEGFQ22K76EX777P9SS
01DTWQ2DSFFAPZVKA3MKXS5BEA	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_retail_user - Address Book	01DTWQ2DSFC2VB12W5QYKPY4MA	01DTWQ2DEGH3AASNKDNEWRFRR7
01DTWQ2DSFEBHZXK97Q9QX2P85	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	appsuperadmin - LCB Traceability	01DTWQ2DSFEE29A7KZWK1QES6W	01DTWQ2D28455Z8RETA2Q9N2H7
01DTWQ2DSF290Y47PMBVBV572C	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_producer_admin - LCB Traceability	01DTWQ2DSFEE29A7KZWK1QES6W	01DTWQ2DEGFFTFQ39VPQPY811M
01DTWQ2DSFGF88FMYN5MBB0NRC	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_producer_user - LCB Traceability	01DTWQ2DSFEE29A7KZWK1QES6W	01DTWQ2DEGM404YQZHVBWRBCPC
01DTWQ2DSFJ3WAGKC2ZDZX0749	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_processor_admin - LCB Traceability	01DTWQ2DSFEE29A7KZWK1QES6W	01DTWQ2DEG70MRECH2F5RPF719
01DTWQ2DSFRMAC6YRRHAZSEDSR	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_processor_user - LCB Traceability	01DTWQ2DSFEE29A7KZWK1QES6W	01DTWQ2DEGXT143WN4M045ZEBT
01DTWQ2DSF764VVPQCWA4CM1FT	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_retail_admin - LCB Traceability	01DTWQ2DSFEE29A7KZWK1QES6W	01DTWQ2DEGFQ22K76EX777P9SS
01DTWQ2DSFJBFZ89CEM2W3Q7DN	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	lcb_retail_user - LCB Traceability	01DTWQ2DSFEE29A7KZWK1QES6W	01DTWQ2DEGH3AASNKDNEWRFRR7
\.


--
-- Data for Name: license_permission; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_permission (id, app_tenant_id, created_at, updated_at, license_id, permission_id) FROM stdin;
\.


--
-- Data for Name: license_type; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_type (id, created_at, updated_at, external_id, name, key, application_id) FROM stdin;
01DTWQ2DSF0AH8BFW34EV6V462	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	Tenant Manager	tenant-manager	01DTWQ2DSFBF3087ZJ5WXWCHVQ
01DTWQ2DSF1CXH7QW5VHTJKHPK	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	License Manager	license-manager	01DTWQ2DSF85A278YPYM0E9RYA
01DTWQ2DSFC2VB12W5QYKPY4MA	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	Address Book	address-book	01DTWQ2DSFE0NNPH9FN20C97CF
01DTWQ2DSFEE29A7KZWK1QES6W	2019-11-29 23:13:54.991099+00	2019-11-29 23:13:54.991099+00	\N	LCB Traceability	lcb-traceability	01DTWQ2DSFN05TEG9BTWW5YYJ2
\.


--
-- Data for Name: license_type_permission; Type: TABLE DATA; Schema: app; Owner: postgres
--

COPY app.license_type_permission (id, created_at, updated_at, license_type_id, permission_id, key) FROM stdin;
\.


--
-- Data for Name: app_tenant; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.app_tenant (id, created_at, updated_at, name, identifier) FROM stdin;
01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.2477+00	2019-11-29 23:13:54.2477+00	Anchor Tenant	anchor
01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	Producer-1	G11111
01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	Processor-1	M11111
01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	Retail-1	R11111
\.


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.app_user (id, app_tenant_id, created_at, updated_at, username, recovery_email, password_hash, inactive, password_reset_required, permission_key) FROM stdin;
01DTWQ2D28455Z8RETA2Q9N2H7	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.2477+00	2019-11-29 23:13:54.2477+00	appsuperadmin	appsuperadmin@tst.tst	$2a$06$3BU2TYBEkX6unZyBZTgNFOEV6pG2GeBoMDe7/mjeUgog92V3XS.LS	f	f	SuperAdmin
01DTWQ2DEGFFTFQ39VPQPY811M	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	lcb_producer_admin	lcb_producer_admin@blah.blah	$2a$06$yGQx95dn150BLyNibjRla.1vuMKxgHR/mJnjmDBDYxqk8UtiZDVdC	f	f	Admin
01DTWQ2DEGM404YQZHVBWRBCPC	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	lcb_producer_user	lcb_producer_user@blah.blah	$2a$06$fYsw8Zc/Ve2gNw/F04cHQOe9nVCKe1fHcfzKsUPPMcSaZgAhc0BHO	f	f	User
01DTWQ2DEG70MRECH2F5RPF719	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	lcb_processor_admin	lcb_processor_admin@blah.blah	$2a$06$111ACnSTSu2HYNWaiU2pmeVlGp15Q4SNQclrZG7MVKwGsYym/jq4q	f	f	Admin
01DTWQ2DEGXT143WN4M045ZEBT	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	lcb_processor_user	lcb_processor_user@blah.blah	$2a$06$KnFTKdJiijDLmhp0fAo9rOT7D2eIJ0Kyu0iL2L38HhBmbOFM4NcEK	f	f	User
01DTWQ2DEGFQ22K76EX777P9SS	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	lcb_retail_admin	lcb_retail_admin003@blah.blah	$2a$06$Z715M9HJXDQKLL3x.iLUx.5VPPT3ZdbEZrnK6ucQE13YxUQ0bsyfm	f	f	Admin
01DTWQ2DEGH3AASNKDNEWRFRR7	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	lcb_retail_user	lcb_retail_user@blah.blah	$2a$06$b4oXqLubx1mtClWReOz.EugstMw87VcibML7xknn/JVsObKhAdMb6	f	f	User
\.


--
-- Data for Name: config_auth; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.config_auth (id, key, value) FROM stdin;
\.


--
-- Data for Name: permission; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.permission (id, created_at, key) FROM stdin;
\.


--
-- Data for Name: token; Type: TABLE DATA; Schema: auth; Owner: postgres
--

COPY auth.token (id, app_user_id, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: inventory_lot; Type: TABLE DATA; Schema: lcb; Owner: postgres
--

COPY lcb.inventory_lot (id, app_tenant_id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, units, strain_name, area_identifier) FROM stdin;
\.


--
-- Data for Name: lcb_license; Type: TABLE DATA; Schema: lcb; Owner: postgres
--

COPY lcb.lcb_license (id, created_at, updated_at, code) FROM stdin;
\.


--
-- Data for Name: lcb_license_holder; Type: TABLE DATA; Schema: lcb; Owner: postgres
--

COPY lcb.lcb_license_holder (id, app_tenant_id, created_at, updated_at, lcb_license_id, organization_id, acquisition_date, relinquish_date) FROM stdin;
\.


--
-- Data for Name: config_org; Type: TABLE DATA; Schema: org; Owner: postgres
--

COPY org.config_org (id, key, value) FROM stdin;
\.


--
-- Data for Name: contact; Type: TABLE DATA; Schema: org; Owner: postgres
--

COPY org.contact (id, app_tenant_id, created_at, updated_at, organization_id, location_id, external_id, first_name, last_name, email, cell_phone, office_phone, title, nickname) FROM stdin;
01DTWQ2D28XCBEMTE1GMPJBFRB	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.2477+00	2019-11-29 23:13:54.819843+00	01DTWQ2D28PXTJTV78EEYPN8XW	01DTWQ2DM42JV8VXQX8YFVHE05	appsuperadmin	Super	Admin	appsuperadmin@tst.tst	\N	\N	\N	\N
01DTWQ2DEGFQFJY9HJ4K5QCVZ0	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	01DTWQ2DEGT1ZQ591BB48D2REW	01DTWQ2DM4TTM2GBTACP2NCHTZ	lcb_producer_admin	lcb_producer_admin	Test	lcb_producer_admin@blah.blah	\N	\N	\N	\N
01DTWQ2DEGS90PJ37ZE4GTF8K2	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	01DTWQ2DEGT1ZQ591BB48D2REW	01DTWQ2DM4S9MRS6AFGJ7TEQJ6	lcb_producer_user	lcb_producer_user	Test	lcb_producer_user@blah.blah	\N	\N	\N	\N
01DTWQ2DEG5KFMY16S8ZPBNQMW	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	01DTWQ2DEGYECMREJPATFGZ5D4	01DTWQ2DM40BEC4BQV0TN48B3C	lcb_processor_admin	lcb_processor_admin	Test	lcb_processor_admin@blah.blah	\N	\N	\N	\N
01DTWQ2DEGD5VKE4NQ84SMEPR6	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	01DTWQ2DEGYECMREJPATFGZ5D4	01DTWQ2DM4FK84T1VV3GX2Y04M	lcb_processor_user	lcb_processor_user	Test	lcb_processor_user@blah.blah	\N	\N	\N	\N
01DTWQ2DEGEC9TG0EMGPTWDDX9	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	01DTWQ2DEGJ040Z9QV7889A326	01DTWQ2DM4X3AE2Y47JQVH3DG4	lcb_retail_admin	lcb_retail_admin	Test	lcb_retail_admin003@blah.blah	\N	\N	\N	\N
01DTWQ2DEGHF5WJXTDG9G18QYR	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	01DTWQ2DEGJ040Z9QV7889A326	01DTWQ2DM43YW0Y9J2M75XDKYW	lcb_retail_user	lcb_retail_user	Test	lcb_retail_user@blah.blah	\N	\N	\N	\N
\.


--
-- Data for Name: contact_app_user; Type: TABLE DATA; Schema: org; Owner: postgres
--

COPY org.contact_app_user (id, app_tenant_id, created_at, updated_at, contact_id, app_user_id, username) FROM stdin;
01DTWQ2D28RBQ4MN68QBJRPNF7	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.2477+00	2019-11-29 23:13:54.2477+00	01DTWQ2D28XCBEMTE1GMPJBFRB	01DTWQ2D28455Z8RETA2Q9N2H7	appsuperadmin
01DTWQ2DEGZM23Q79NGAHZM4QX	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	01DTWQ2DEGFQFJY9HJ4K5QCVZ0	01DTWQ2DEGFFTFQ39VPQPY811M	lcb_producer_admin
01DTWQ2DEG8XBJ3F4EK45GCJ8T	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	01DTWQ2DEGS90PJ37ZE4GTF8K2	01DTWQ2DEGM404YQZHVBWRBCPC	lcb_producer_user
01DTWQ2DEGYMS0JB03PCDM4A8K	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	01DTWQ2DEG5KFMY16S8ZPBNQMW	01DTWQ2DEG70MRECH2F5RPF719	lcb_processor_admin
01DTWQ2DEGDRVPYCT7ARCDNFGN	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	01DTWQ2DEGD5VKE4NQ84SMEPR6	01DTWQ2DEGXT143WN4M045ZEBT	lcb_processor_user
01DTWQ2DEGH5YWXEDQVDEHTZWE	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	01DTWQ2DEGEC9TG0EMGPTWDDX9	01DTWQ2DEGFQ22K76EX777P9SS	lcb_retail_admin
01DTWQ2DEG6T3MJD1MHZ6AVRVW	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.640051+00	01DTWQ2DEGHF5WJXTDG9G18QYR	01DTWQ2DEGH3AASNKDNEWRFRR7	lcb_retail_user
\.


--
-- Data for Name: facility; Type: TABLE DATA; Schema: org; Owner: postgres
--

COPY org.facility (id, app_tenant_id, created_at, updated_at, organization_id, location_id, name, external_id) FROM stdin;
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: org; Owner: postgres
--

COPY org.location (id, app_tenant_id, created_at, updated_at, external_id, name, address1, address2, city, state, zip, lat, lon) FROM stdin;
01DTWQ2DM4A9T8JSGJVHBHTY11	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	anchor-org	Anchor Tenant Location	addy 1	addy 2	a city	??	?????	37.5797780	-109.2458130
01DTWQ2DM48N31NEDPTXQFNGMK	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	G11111-org	Producer-1 Location	addy 1	addy 2	a city	??	?????	36.2787630	-96.7323005
01DTWQ2DM4CTPV468736BP6A0D	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	M11111-org	Processor-1 Location	addy 1	addy 2	a city	??	?????	43.2283887	-100.7011131
01DTWQ2DM46QKHG1V40Z4541GR	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	R11111-org	Retail-1 Location	addy 1	addy 2	a city	??	?????	40.8940954	-106.7287604
01DTWQ2DM42JV8VXQX8YFVHE05	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	appsuperadmin	appsuperadmin Location	addy 1	addy 2	a city	??	?????	43.8322688	-109.1875165
01DTWQ2DM4TTM2GBTACP2NCHTZ	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	lcb_producer_admin	lcb_producer_admin Location	addy 1	addy 2	a city	??	?????	43.4991091	-103.6058159
01DTWQ2DM4S9MRS6AFGJ7TEQJ6	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	lcb_producer_user	lcb_producer_user Location	addy 1	addy 2	a city	??	?????	37.6453328	-104.9940197
01DTWQ2DM40BEC4BQV0TN48B3C	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	lcb_processor_admin	lcb_processor_admin Location	addy 1	addy 2	a city	??	?????	36.4854100	-103.9519962
01DTWQ2DM4FK84T1VV3GX2Y04M	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	lcb_processor_user	lcb_processor_user Location	addy 1	addy 2	a city	??	?????	37.7187585	-107.3066515
01DTWQ2DM4X3AE2Y47JQVH3DG4	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	lcb_retail_admin	lcb_retail_admin Location	addy 1	addy 2	a city	??	?????	38.0879184	-96.5639827
01DTWQ2DM43YW0Y9J2M75XDKYW	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.819843+00	2019-11-29 23:13:54.819843+00	lcb_retail_user	lcb_retail_user Location	addy 1	addy 2	a city	??	?????	39.7786481	-108.9594108
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: org; Owner: postgres
--

COPY org.organization (id, app_tenant_id, actual_app_tenant_id, created_at, updated_at, external_id, name, location_id, primary_contact_id) FROM stdin;
01DTWQ2D28PXTJTV78EEYPN8XW	01DTWQ2D28CH8BN9EC3K01YNG3	01DTWQ2D28CH8BN9EC3K01YNG3	2019-11-29 23:13:54.2477+00	2019-11-29 23:13:54.819843+00	anchor-org	Anchor Tenant	01DTWQ2DM4A9T8JSGJVHBHTY11	01DTWQ2D28XCBEMTE1GMPJBFRB
01DTWQ2DEGT1ZQ591BB48D2REW	01DTWQ2DEG6VGFFBK81A4B0HV8	01DTWQ2DEG6VGFFBK81A4B0HV8	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	G11111-org	Producer-1	01DTWQ2DM48N31NEDPTXQFNGMK	01DTWQ2DEGFQFJY9HJ4K5QCVZ0
01DTWQ2DEGYECMREJPATFGZ5D4	01DTWQ2DEG3JRR3NMRP8P94PJ6	01DTWQ2DEG3JRR3NMRP8P94PJ6	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	M11111-org	Processor-1	01DTWQ2DM4CTPV468736BP6A0D	01DTWQ2DEG5KFMY16S8ZPBNQMW
01DTWQ2DEGJ040Z9QV7889A326	01DTWQ2DEGE4D5DMCZP31PKMKC	01DTWQ2DEGE4D5DMCZP31PKMKC	2019-11-29 23:13:54.640051+00	2019-11-29 23:13:54.819843+00	R11111-org	Retail-1	01DTWQ2DM46QKHG1V40Z4541GR	01DTWQ2DEGEC9TG0EMGPTWDDX9
\.


--
-- Name: global_id_sequence; Type: SEQUENCE SET; Schema: shard_1; Owner: postgres
--

SELECT pg_catalog.setval('shard_1.global_id_sequence', 91, true);


--
-- Name: application application_key_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.application
    ADD CONSTRAINT application_key_key UNIQUE (key);


--
-- Name: license_type license_type_key_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT license_type_key_key UNIQUE (key);


--
-- Name: license_type_permission license_type_permission_key_key; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT license_type_permission_key_key UNIQUE (key);


--
-- Name: application pk_application; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.application
    ADD CONSTRAINT pk_application PRIMARY KEY (id);


--
-- Name: license pk_license; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT pk_license PRIMARY KEY (id);


--
-- Name: license_permission pk_license_permission; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT pk_license_permission PRIMARY KEY (id);


--
-- Name: license_type pk_license_type; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT pk_license_type PRIMARY KEY (id);


--
-- Name: license_type_permission pk_license_type_permission; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT pk_license_type_permission PRIMARY KEY (id);


--
-- Name: license uq_license_type_assigned_to; Type: CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT uq_license_type_assigned_to UNIQUE (assigned_to_app_user_id, license_type_id);


--
-- Name: app_tenant app_tenant_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.app_tenant
    ADD CONSTRAINT app_tenant_identifier_key UNIQUE (identifier);


--
-- Name: app_user app_user_recovery_email_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT app_user_recovery_email_key UNIQUE (recovery_email);


--
-- Name: app_user app_user_username_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT app_user_username_key UNIQUE (username);


--
-- Name: app_tenant pk_app_tenant; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.app_tenant
    ADD CONSTRAINT pk_app_tenant PRIMARY KEY (id);


--
-- Name: app_user pk_app_user; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT pk_app_user PRIMARY KEY (id);


--
-- Name: config_auth pk_config_auth; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.config_auth
    ADD CONSTRAINT pk_config_auth PRIMARY KEY (id);


--
-- Name: permission pk_permission; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.permission
    ADD CONSTRAINT pk_permission PRIMARY KEY (id);


--
-- Name: token pk_token; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.token
    ADD CONSTRAINT pk_token PRIMARY KEY (id);


--
-- Name: token token_app_user_id_key; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.token
    ADD CONSTRAINT token_app_user_id_key UNIQUE (app_user_id);


--
-- Name: lcb_license lcb_license_code_key; Type: CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.lcb_license
    ADD CONSTRAINT lcb_license_code_key UNIQUE (code);


--
-- Name: lcb_license_holder lcb_license_holder_lcb_license_id_key; Type: CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT lcb_license_holder_lcb_license_id_key UNIQUE (lcb_license_id);


--
-- Name: inventory_lot pk_inventory_lot; Type: CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT pk_inventory_lot PRIMARY KEY (id);


--
-- Name: lcb_license pk_lcb_license; Type: CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.lcb_license
    ADD CONSTRAINT pk_lcb_license PRIMARY KEY (id);


--
-- Name: lcb_license_holder pk_lcb_license_holder; Type: CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT pk_lcb_license_holder PRIMARY KEY (id);


--
-- Name: contact_app_user contact_app_user_app_user_id_key; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT contact_app_user_app_user_id_key UNIQUE (app_user_id);


--
-- Name: contact_app_user contact_app_user_contact_id_key; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT contact_app_user_contact_id_key UNIQUE (contact_id);


--
-- Name: contact_app_user contact_app_user_username_key; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT contact_app_user_username_key UNIQUE (username);


--
-- Name: organization organization_actual_app_tenant_id_key; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT organization_actual_app_tenant_id_key UNIQUE (actual_app_tenant_id);


--
-- Name: config_org pk_config_org; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.config_org
    ADD CONSTRAINT pk_config_org PRIMARY KEY (id);


--
-- Name: contact pk_contact; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT pk_contact PRIMARY KEY (id);


--
-- Name: contact_app_user pk_contact_app_user; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT pk_contact_app_user PRIMARY KEY (id);


--
-- Name: facility pk_facility; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT pk_facility PRIMARY KEY (id);


--
-- Name: location pk_location; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.location
    ADD CONSTRAINT pk_location PRIMARY KEY (id);


--
-- Name: organization pk_organization; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT pk_organization PRIMARY KEY (id);


--
-- Name: organization uq_app_tenant_external_id; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT uq_app_tenant_external_id UNIQUE (app_tenant_id, external_id);


--
-- Name: contact uq_contact_app_tenant_and_email; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT uq_contact_app_tenant_and_email UNIQUE (app_tenant_id, email);


--
-- Name: contact uq_contact_app_tenant_and_external_id; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT uq_contact_app_tenant_and_external_id UNIQUE (app_tenant_id, external_id);


--
-- Name: facility uq_facility_app_tenant_and_organization_and_name; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT uq_facility_app_tenant_and_organization_and_name UNIQUE (organization_id, name);


--
-- Name: location uq_location_app_tenant_and_external_id; Type: CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.location
    ADD CONSTRAINT uq_location_app_tenant_and_external_id UNIQUE (app_tenant_id, external_id);


--
-- Name: application tg_timestamp_update_application; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_application BEFORE INSERT OR UPDATE ON app.application FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_application();


--
-- Name: license tg_timestamp_update_license; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_license BEFORE INSERT OR UPDATE ON app.license FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_license();


--
-- Name: license_permission tg_timestamp_update_license_permission; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_license_permission BEFORE INSERT OR UPDATE ON app.license_permission FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_license_permission();


--
-- Name: license_type tg_timestamp_update_license_type; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_license_type BEFORE INSERT OR UPDATE ON app.license_type FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_license_type();


--
-- Name: license_type_permission tg_timestamp_update_license_type_permission; Type: TRIGGER; Schema: app; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_license_type_permission BEFORE INSERT OR UPDATE ON app.license_type_permission FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_license_type_permission();


--
-- Name: app_tenant tg_timestamp_update_app_tenant; Type: TRIGGER; Schema: auth; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_app_tenant BEFORE INSERT OR UPDATE ON auth.app_tenant FOR EACH ROW EXECUTE PROCEDURE auth.fn_timestamp_update_app_tenant();


--
-- Name: app_user tg_timestamp_update_app_user; Type: TRIGGER; Schema: auth; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_app_user BEFORE INSERT OR UPDATE ON auth.app_user FOR EACH ROW EXECUTE PROCEDURE auth.fn_timestamp_update_app_user();


--
-- Name: permission tg_timestamp_update_permission; Type: TRIGGER; Schema: auth; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_permission BEFORE INSERT OR UPDATE ON auth.permission FOR EACH ROW EXECUTE PROCEDURE auth.fn_timestamp_update_permission();


--
-- Name: inventory_lot tg_timestamp_update_inventory_lot; Type: TRIGGER; Schema: lcb; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_inventory_lot BEFORE INSERT OR UPDATE ON lcb.inventory_lot FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_inventory_lot();


--
-- Name: lcb_license tg_timestamp_update_lcb_license; Type: TRIGGER; Schema: lcb; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_lcb_license BEFORE INSERT OR UPDATE ON lcb.lcb_license FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_lcb_license();


--
-- Name: lcb_license_holder tg_timestamp_update_lcb_license_holder; Type: TRIGGER; Schema: lcb; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_lcb_license_holder BEFORE INSERT OR UPDATE ON lcb.lcb_license_holder FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_lcb_license_holder();


--
-- Name: contact tg_timestamp_update_contact; Type: TRIGGER; Schema: org; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_contact BEFORE INSERT OR UPDATE ON org.contact FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_contact();


--
-- Name: contact_app_user tg_timestamp_update_contact_app_user; Type: TRIGGER; Schema: org; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_contact_app_user BEFORE INSERT OR UPDATE ON org.contact_app_user FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_contact_app_user();


--
-- Name: facility tg_timestamp_update_facility; Type: TRIGGER; Schema: org; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_facility BEFORE INSERT OR UPDATE ON org.facility FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_facility();


--
-- Name: location tg_timestamp_update_location; Type: TRIGGER; Schema: org; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_location BEFORE INSERT OR UPDATE ON org.location FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_location();


--
-- Name: organization tg_timestamp_update_organization; Type: TRIGGER; Schema: org; Owner: postgres
--

CREATE TRIGGER tg_timestamp_update_organization BEFORE INSERT OR UPDATE ON org.organization FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_organization();


--
-- Name: license fk_license_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: license fk_license_assigned_to_app_user; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_assigned_to_app_user FOREIGN KEY (assigned_to_app_user_id) REFERENCES auth.app_user(id);


--
-- Name: license fk_license_license_type; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_license_type FOREIGN KEY (license_type_id) REFERENCES app.license_type(id);


--
-- Name: license fk_license_permission_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_permission_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: license_permission fk_license_permission_license; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT fk_license_permission_license FOREIGN KEY (license_id) REFERENCES app.license(id);


--
-- Name: license_permission fk_license_permission_permission; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT fk_license_permission_permission FOREIGN KEY (permission_id) REFERENCES auth.permission(id);


--
-- Name: license_type fk_license_type_application; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT fk_license_type_application FOREIGN KEY (application_id) REFERENCES app.application(id);


--
-- Name: license_type_permission fk_license_type_permission_license_type; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT fk_license_type_permission_license_type FOREIGN KEY (license_type_id) REFERENCES app.license_type(id);


--
-- Name: license_type_permission fk_license_type_permission_permission; Type: FK CONSTRAINT; Schema: app; Owner: postgres
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT fk_license_type_permission_permission FOREIGN KEY (permission_id) REFERENCES auth.permission(id);


--
-- Name: app_user fk_app_user_app_tenant; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT fk_app_user_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: token fk_token_user; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth.token
    ADD CONSTRAINT fk_token_user FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id);


--
-- Name: inventory_lot fk_inventory_lot_app_tenant_id; Type: FK CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: inventory_lot fk_inventory_lot_lcb_license_holder; Type: FK CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_lcb_license_holder FOREIGN KEY (lcb_license_holder_id) REFERENCES lcb.lcb_license_holder(id);


--
-- Name: lcb_license_holder fk_lcb_license_holder_app_tenant_id; Type: FK CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: lcb_license_holder fk_lcb_license_holder_license; Type: FK CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_license FOREIGN KEY (lcb_license_id) REFERENCES lcb.lcb_license(id);


--
-- Name: lcb_license_holder fk_lcb_license_holder_organization; Type: FK CONSTRAINT; Schema: lcb; Owner: postgres
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_organization FOREIGN KEY (organization_id) REFERENCES org.organization(id);


--
-- Name: contact fk_contact_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT fk_contact_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: contact_app_user fk_contact_app_user_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT fk_contact_app_user_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: contact_app_user fk_contact_app_user_app_user; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT fk_contact_app_user_app_user FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id);


--
-- Name: contact_app_user fk_contact_app_user_contact; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT fk_contact_app_user_contact FOREIGN KEY (contact_id) REFERENCES org.contact(id);


--
-- Name: contact fk_contact_location; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT fk_contact_location FOREIGN KEY (location_id) REFERENCES org.location(id);


--
-- Name: contact fk_contact_organization; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT fk_contact_organization FOREIGN KEY (organization_id) REFERENCES org.organization(id);


--
-- Name: facility fk_facility_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT fk_facility_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: facility fk_facility_location; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT fk_facility_location FOREIGN KEY (location_id) REFERENCES org.location(id);


--
-- Name: facility fk_facility_organization; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT fk_facility_organization FOREIGN KEY (organization_id) REFERENCES org.organization(id);


--
-- Name: location fk_location_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.location
    ADD CONSTRAINT fk_location_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: organization fk_organization_actual_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT fk_organization_actual_app_tenant FOREIGN KEY (actual_app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: organization fk_organization_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT fk_organization_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: organization fk_organization_location; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT fk_organization_location FOREIGN KEY (location_id) REFERENCES org.location(id);


--
-- Name: organization fk_organization_primary_contact; Type: FK CONSTRAINT; Schema: org; Owner: postgres
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT fk_organization_primary_contact FOREIGN KEY (primary_contact_id) REFERENCES org.contact(id);


--
-- Name: license; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.license ENABLE ROW LEVEL SECURITY;

--
-- Name: license_permission; Type: ROW SECURITY; Schema: app; Owner: postgres
--

ALTER TABLE app.license_permission ENABLE ROW LEVEL SECURITY;

--
-- Name: license rls_app_user_default_app_license; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY rls_app_user_default_app_license ON app.license TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: license_permission rls_app_user_default_app_license_permission; Type: POLICY; Schema: app; Owner: postgres
--

CREATE POLICY rls_app_user_default_app_license_permission ON app.license_permission TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: app_tenant; Type: ROW SECURITY; Schema: auth; Owner: postgres
--

ALTER TABLE auth.app_tenant ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user; Type: ROW SECURITY; Schema: auth; Owner: postgres
--

ALTER TABLE auth.app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user rls_app_user_default_auth_app_user; Type: POLICY; Schema: auth; Owner: postgres
--

CREATE POLICY rls_app_user_default_auth_app_user ON auth.app_user TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: app_tenant rls_auth_app_tenant_auth_app_tenant; Type: POLICY; Schema: auth; Owner: postgres
--

CREATE POLICY rls_auth_app_tenant_auth_app_tenant ON auth.app_tenant TO app_user USING ((auth_fn.app_user_has_access(id) = true));


--
-- Name: inventory_lot; Type: ROW SECURITY; Schema: lcb; Owner: postgres
--

ALTER TABLE lcb.inventory_lot ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_lot rls_app_user_default_lcb_inventory_lot; Type: POLICY; Schema: lcb; Owner: postgres
--

CREATE POLICY rls_app_user_default_lcb_inventory_lot ON lcb.inventory_lot TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: contact; Type: ROW SECURITY; Schema: org; Owner: postgres
--

ALTER TABLE org.contact ENABLE ROW LEVEL SECURITY;

--
-- Name: contact_app_user; Type: ROW SECURITY; Schema: org; Owner: postgres
--

ALTER TABLE org.contact_app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: facility; Type: ROW SECURITY; Schema: org; Owner: postgres
--

ALTER TABLE org.facility ENABLE ROW LEVEL SECURITY;

--
-- Name: location; Type: ROW SECURITY; Schema: org; Owner: postgres
--

ALTER TABLE org.location ENABLE ROW LEVEL SECURITY;

--
-- Name: organization; Type: ROW SECURITY; Schema: org; Owner: postgres
--

ALTER TABLE org.organization ENABLE ROW LEVEL SECURITY;

--
-- Name: contact rls_app_user_default_org_contact; Type: POLICY; Schema: org; Owner: postgres
--

CREATE POLICY rls_app_user_default_org_contact ON org.contact TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: contact_app_user rls_app_user_default_org_contact_app_user; Type: POLICY; Schema: org; Owner: postgres
--

CREATE POLICY rls_app_user_default_org_contact_app_user ON org.contact_app_user TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: facility rls_app_user_default_org_facility; Type: POLICY; Schema: org; Owner: postgres
--

CREATE POLICY rls_app_user_default_org_facility ON org.facility TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: location rls_app_user_default_org_location; Type: POLICY; Schema: org; Owner: postgres
--

CREATE POLICY rls_app_user_default_org_location ON org.location TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: organization rls_app_user_default_org_organization; Type: POLICY; Schema: org; Owner: postgres
--

CREATE POLICY rls_app_user_default_org_organization ON org.organization TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: SCHEMA app; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA app TO app_user;


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA auth TO app_user;
GRANT USAGE ON SCHEMA auth TO app_anonymous;


--
-- Name: SCHEMA auth_fn; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA auth_fn TO app_user;
GRANT USAGE ON SCHEMA auth_fn TO app_anonymous;


--
-- Name: SCHEMA lcb; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA lcb TO app_user;


--
-- Name: SCHEMA lcb_fn; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA lcb_fn TO app_user;


--
-- Name: SCHEMA lcb_hist; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA lcb_hist TO app_user;


--
-- Name: SCHEMA org; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA org TO app_user;


--
-- Name: SCHEMA org_fn; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA org_fn TO app_user;


--
-- Name: SCHEMA shard_1; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA shard_1 TO app_user;


--
-- Name: SCHEMA util_fn; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA util_fn TO app_demon;


--
-- Name: FUNCTION fn_timestamp_update_application(); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_application() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_application() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_license(); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_license() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_license() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_license_permission(); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_license_permission() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_license_permission() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_license_type(); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_license_type() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_license_type() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_license_type_permission(); Type: ACL; Schema: app; Owner: postgres
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_license_type_permission() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_license_type_permission() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_app_tenant(); Type: ACL; Schema: auth; Owner: postgres
--

REVOKE ALL ON FUNCTION auth.fn_timestamp_update_app_tenant() FROM PUBLIC;
GRANT ALL ON FUNCTION auth.fn_timestamp_update_app_tenant() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_app_user(); Type: ACL; Schema: auth; Owner: postgres
--

REVOKE ALL ON FUNCTION auth.fn_timestamp_update_app_user() FROM PUBLIC;
GRANT ALL ON FUNCTION auth.fn_timestamp_update_app_user() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_permission(); Type: ACL; Schema: auth; Owner: postgres
--

REVOKE ALL ON FUNCTION auth.fn_timestamp_update_permission() FROM PUBLIC;
GRANT ALL ON FUNCTION auth.fn_timestamp_update_permission() TO app_user;


--
-- Name: FUNCTION app_user_has_access(_app_tenant_id text, _permission_key text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text) TO app_user;


--
-- Name: FUNCTION authenticate(_username text, _password text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.authenticate(_username text, _password text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.authenticate(_username text, _password text) TO app_anonymous;


--
-- Name: TABLE app_tenant; Type: ACL; Schema: auth; Owner: postgres
--

GRANT INSERT,DELETE,UPDATE ON TABLE auth.app_tenant TO app_super_admin;
GRANT SELECT ON TABLE auth.app_tenant TO app_user;


--
-- Name: FUNCTION build_app_tenant(_name text, _identifier text); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) TO app_user;


--
-- Name: TABLE app_user; Type: ACL; Schema: auth; Owner: postgres
--

GRANT INSERT,DELETE ON TABLE auth.app_user TO app_admin;
GRANT SELECT,UPDATE ON TABLE auth.app_user TO app_user;


--
-- Name: FUNCTION build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) TO app_user;


--
-- Name: FUNCTION current_app_tenant_id(); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.current_app_tenant_id() FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.current_app_tenant_id() TO app_user;


--
-- Name: FUNCTION current_app_user(); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.current_app_user() FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.current_app_user() TO app_user;


--
-- Name: FUNCTION current_app_user_id(); Type: ACL; Schema: auth_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION auth_fn.current_app_user_id() FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.current_app_user_id() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_inventory_lot(); Type: ACL; Schema: lcb; Owner: postgres
--

REVOKE ALL ON FUNCTION lcb.fn_timestamp_update_inventory_lot() FROM PUBLIC;
GRANT ALL ON FUNCTION lcb.fn_timestamp_update_inventory_lot() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_lcb_license(); Type: ACL; Schema: lcb; Owner: postgres
--

REVOKE ALL ON FUNCTION lcb.fn_timestamp_update_lcb_license() FROM PUBLIC;
GRANT ALL ON FUNCTION lcb.fn_timestamp_update_lcb_license() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_lcb_license_holder(); Type: ACL; Schema: lcb; Owner: postgres
--

REVOKE ALL ON FUNCTION lcb.fn_timestamp_update_lcb_license_holder() FROM PUBLIC;
GRANT ALL ON FUNCTION lcb.fn_timestamp_update_lcb_license_holder() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_contact(); Type: ACL; Schema: org; Owner: postgres
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_contact() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_contact() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_contact_app_user(); Type: ACL; Schema: org; Owner: postgres
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_contact_app_user() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_contact_app_user() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_facility(); Type: ACL; Schema: org; Owner: postgres
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_facility() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_facility() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_location(); Type: ACL; Schema: org; Owner: postgres
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_location() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_location() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_organization(); Type: ACL; Schema: org; Owner: postgres
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_organization() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_organization() TO app_user;


--
-- Name: TABLE contact; Type: ACL; Schema: org; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.contact TO app_user;


--
-- Name: FUNCTION build_contact(_first_name text, _last_name text, _email text, _cell_phone text, _office_phone text, _title text, _nickname text, _external_id text, _organization_id text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.build_contact(_first_name text, _last_name text, _email text, _cell_phone text, _office_phone text, _title text, _nickname text, _external_id text, _organization_id text) FROM PUBLIC;


--
-- Name: FUNCTION build_contact_location(_contact_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.build_contact_location(_contact_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: TABLE facility; Type: ACL; Schema: org; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.facility TO app_user;


--
-- Name: FUNCTION build_facility(_organization_id text, _name text, _external_id text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.build_facility(_organization_id text, _name text, _external_id text) FROM PUBLIC;


--
-- Name: FUNCTION build_facility_location(_facility_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.build_facility_location(_facility_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: TABLE location; Type: ACL; Schema: org; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.location TO app_user;


--
-- Name: FUNCTION build_location(_name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.build_location(_name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: TABLE organization; Type: ACL; Schema: org; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.organization TO app_user;


--
-- Name: FUNCTION build_organization(_name text, _external_id text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.build_organization(_name text, _external_id text) FROM PUBLIC;


--
-- Name: FUNCTION build_organization_location(_organization_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.build_organization_location(_organization_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: FUNCTION build_tenant_organization(_name text, _identifier text, _primary_contact_email text, _primary_contact_first_name text, _primary_contact_last_name text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.build_tenant_organization(_name text, _identifier text, _primary_contact_email text, _primary_contact_first_name text, _primary_contact_last_name text) FROM PUBLIC;


--
-- Name: FUNCTION current_app_user_contact(); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.current_app_user_contact() FROM PUBLIC;
GRANT ALL ON FUNCTION org_fn.current_app_user_contact() TO app_user;


--
-- Name: FUNCTION modify_location(_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION org_fn.modify_location(_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: FUNCTION trim_text(_input text); Type: ACL; Schema: util_fn; Owner: postgres
--

REVOKE ALL ON FUNCTION util_fn.trim_text(_input text) FROM PUBLIC;
GRANT ALL ON FUNCTION util_fn.trim_text(_input text) TO app_anonymous;


--
-- Name: TABLE application; Type: ACL; Schema: app; Owner: postgres
--

GRANT INSERT,DELETE,UPDATE ON TABLE app.application TO app_super_admin;
GRANT SELECT ON TABLE app.application TO app_user;


--
-- Name: TABLE license; Type: ACL; Schema: app; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE app.license TO app_user;


--
-- Name: TABLE license_permission; Type: ACL; Schema: app; Owner: postgres
--

GRANT INSERT,DELETE,UPDATE ON TABLE app.license_permission TO app_admin;
GRANT SELECT ON TABLE app.license_permission TO app_user;


--
-- Name: TABLE license_type; Type: ACL; Schema: app; Owner: postgres
--

GRANT INSERT,DELETE,UPDATE ON TABLE app.license_type TO app_super_admin;
GRANT SELECT ON TABLE app.license_type TO app_user;


--
-- Name: TABLE license_type_permission; Type: ACL; Schema: app; Owner: postgres
--

GRANT INSERT,DELETE,UPDATE ON TABLE app.license_type_permission TO app_super_admin;
GRANT SELECT ON TABLE app.license_type_permission TO app_user;


--
-- Name: TABLE permission; Type: ACL; Schema: auth; Owner: postgres
--

GRANT INSERT,DELETE,UPDATE ON TABLE auth.permission TO app_super_admin;
GRANT SELECT ON TABLE auth.permission TO app_user;


--
-- Name: TABLE inventory_lot; Type: ACL; Schema: lcb; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE lcb.inventory_lot TO app_user;


--
-- Name: TABLE lcb_license; Type: ACL; Schema: lcb; Owner: postgres
--

GRANT INSERT,DELETE,UPDATE ON TABLE lcb.lcb_license TO app_super_admin;
GRANT SELECT ON TABLE lcb.lcb_license TO app_user;


--
-- Name: TABLE lcb_license_holder; Type: ACL; Schema: lcb; Owner: postgres
--

GRANT INSERT,DELETE,UPDATE ON TABLE lcb.lcb_license_holder TO app_super_admin;
GRANT SELECT ON TABLE lcb.lcb_license_holder TO app_user;


--
-- Name: TABLE contact_app_user; Type: ACL; Schema: org; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.contact_app_user TO app_user;


--
-- Name: SEQUENCE global_id_sequence; Type: ACL; Schema: shard_1; Owner: postgres
--

GRANT USAGE ON SEQUENCE shard_1.global_id_sequence TO app_user;


--
-- PostgreSQL database dump complete
--

