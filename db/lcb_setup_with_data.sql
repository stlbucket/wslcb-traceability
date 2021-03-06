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
-- Name: app; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA app;


ALTER SCHEMA app OWNER TO app;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO app;

--
-- Name: auth_fn; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA auth_fn;


ALTER SCHEMA auth_fn OWNER TO app;

--
-- Name: lcb; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA lcb;


ALTER SCHEMA lcb OWNER TO app;

--
-- Name: lcb_fn; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA lcb_fn;


ALTER SCHEMA lcb_fn OWNER TO app;

--
-- Name: lcb_hist; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA lcb_hist;


ALTER SCHEMA lcb_hist OWNER TO app;

--
-- Name: lcb_ref; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA lcb_ref;


ALTER SCHEMA lcb_ref OWNER TO app;

--
-- Name: org; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA org;


ALTER SCHEMA org OWNER TO app;

--
-- Name: org_fn; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA org_fn;


ALTER SCHEMA org_fn OWNER TO app;

--
-- Name: shard_1; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA shard_1;


ALTER SCHEMA shard_1 OWNER TO app;

--
-- Name: util_fn; Type: SCHEMA; Schema: -; Owner: app
--

CREATE SCHEMA util_fn;


ALTER SCHEMA util_fn OWNER TO app;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: jwt_token; Type: TYPE; Schema: auth; Owner: app
--

CREATE TYPE auth.jwt_token AS (
	role text,
	app_user_id text,
	app_tenant_id text,
	token text
);


ALTER TYPE auth.jwt_token OWNER TO app;

--
-- Name: permission_key; Type: TYPE; Schema: auth; Owner: app
--

CREATE TYPE auth.permission_key AS ENUM (
    'Admin',
    'SuperAdmin',
    'Demon',
    'User'
);


ALTER TYPE auth.permission_key OWNER TO app;

--
-- Name: report_inventory_lot_input; Type: TYPE; Schema: lcb_fn; Owner: app
--

CREATE TYPE lcb_fn.report_inventory_lot_input AS (
	id text,
	licensee_identifier text,
	inventory_type text,
	description text,
	quantity numeric(10,2),
	strain_name text,
	area_identifier text
);


ALTER TYPE lcb_fn.report_inventory_lot_input OWNER TO app;

--
-- Name: fn_timestamp_update_application(); Type: FUNCTION; Schema: app; Owner: app
--

CREATE FUNCTION app.fn_timestamp_update_application() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_timestamp_update_application() OWNER TO app;

--
-- Name: fn_timestamp_update_license(); Type: FUNCTION; Schema: app; Owner: app
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


ALTER FUNCTION app.fn_timestamp_update_license() OWNER TO app;

--
-- Name: fn_timestamp_update_license_permission(); Type: FUNCTION; Schema: app; Owner: app
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


ALTER FUNCTION app.fn_timestamp_update_license_permission() OWNER TO app;

--
-- Name: fn_timestamp_update_license_type(); Type: FUNCTION; Schema: app; Owner: app
--

CREATE FUNCTION app.fn_timestamp_update_license_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_timestamp_update_license_type() OWNER TO app;

--
-- Name: fn_timestamp_update_license_type_permission(); Type: FUNCTION; Schema: app; Owner: app
--

CREATE FUNCTION app.fn_timestamp_update_license_type_permission() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION app.fn_timestamp_update_license_type_permission() OWNER TO app;

--
-- Name: fn_timestamp_update_app_tenant(); Type: FUNCTION; Schema: auth; Owner: app
--

CREATE FUNCTION auth.fn_timestamp_update_app_tenant() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION auth.fn_timestamp_update_app_tenant() OWNER TO app;

--
-- Name: fn_timestamp_update_app_user(); Type: FUNCTION; Schema: auth; Owner: app
--

CREATE FUNCTION auth.fn_timestamp_update_app_user() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION auth.fn_timestamp_update_app_user() OWNER TO app;

--
-- Name: fn_timestamp_update_permission(); Type: FUNCTION; Schema: auth; Owner: app
--

CREATE FUNCTION auth.fn_timestamp_update_permission() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION auth.fn_timestamp_update_permission() OWNER TO app;

--
-- Name: app_user_has_access(text, text); Type: FUNCTION; Schema: auth_fn; Owner: app
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


ALTER FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text) OWNER TO app;

--
-- Name: FUNCTION app_user_has_access(_app_tenant_id text, _permission_key text); Type: COMMENT; Schema: auth_fn; Owner: app
--

COMMENT ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text) IS 'Verify if a user has access to an entity via the app_tenant_id';


--
-- Name: authenticate(text, text); Type: FUNCTION; Schema: auth_fn; Owner: app
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


ALTER FUNCTION auth_fn.authenticate(_username text, _password text) OWNER TO app;

--
-- Name: FUNCTION authenticate(_username text, _password text); Type: COMMENT; Schema: auth_fn; Owner: app
--

COMMENT ON FUNCTION auth_fn.authenticate(_username text, _password text) IS 'Creates a JWT token that will securely identify a contact and give them certain permissions.';


--
-- Name: generate_ulid(); Type: FUNCTION; Schema: util_fn; Owner: app
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


ALTER FUNCTION util_fn.generate_ulid() OWNER TO app;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: app_tenant; Type: TABLE; Schema: auth; Owner: app
--

CREATE TABLE auth.app_tenant (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    name text NOT NULL,
    identifier text NOT NULL,
    CONSTRAINT app_tenant_identifier_check CHECK ((identifier <> ''::text))
);


ALTER TABLE auth.app_tenant OWNER TO app;

--
-- Name: TABLE app_tenant; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON TABLE auth.app_tenant IS '@omit create,update,delete';


--
-- Name: COLUMN app_tenant.id; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.app_tenant.id IS '@omit create';


--
-- Name: COLUMN app_tenant.created_at; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.app_tenant.created_at IS '@omit create,update';


--
-- Name: COLUMN app_tenant.updated_at; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.app_tenant.updated_at IS '@omit create,update';


--
-- Name: build_app_tenant(text, text); Type: FUNCTION; Schema: auth_fn; Owner: app
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


ALTER FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) OWNER TO app;

--
-- Name: FUNCTION build_app_tenant(_name text, _identifier text); Type: COMMENT; Schema: auth_fn; Owner: app
--

COMMENT ON FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) IS 'Creates a new app user';


--
-- Name: app_user; Type: TABLE; Schema: auth; Owner: app
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


ALTER TABLE auth.app_user OWNER TO app;

--
-- Name: TABLE app_user; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON TABLE auth.app_user IS '@omit create,update,delete';


--
-- Name: COLUMN app_user.id; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.app_user.id IS '@omit create';


--
-- Name: COLUMN app_user.created_at; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.app_user.created_at IS '@omit create,update';


--
-- Name: COLUMN app_user.updated_at; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.app_user.updated_at IS '@omit create,update';


--
-- Name: COLUMN app_user.password_hash; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.app_user.password_hash IS '@omit';


--
-- Name: build_app_user(text, text, text, text, auth.permission_key); Type: FUNCTION; Schema: auth_fn; Owner: app
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


ALTER FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) OWNER TO app;

--
-- Name: FUNCTION build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key); Type: COMMENT; Schema: auth_fn; Owner: app
--

COMMENT ON FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) IS 'Creates a new app user';


--
-- Name: current_app_tenant_id(); Type: FUNCTION; Schema: auth_fn; Owner: app
--

CREATE FUNCTION auth_fn.current_app_tenant_id() RETURNS text
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
  BEGIN
    return current_setting('jwt.claims.app_tenant_id')::text;
  end;
  $$;


ALTER FUNCTION auth_fn.current_app_tenant_id() OWNER TO app;

--
-- Name: FUNCTION current_app_tenant_id(); Type: COMMENT; Schema: auth_fn; Owner: app
--

COMMENT ON FUNCTION auth_fn.current_app_tenant_id() IS '@omit';


--
-- Name: current_app_user(); Type: FUNCTION; Schema: auth_fn; Owner: app
--

CREATE FUNCTION auth_fn.current_app_user() RETURNS auth.app_user
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _app_user_id text;
    _app_user auth.app_user;
  BEGIN
    _app_user_id := current_setting('jwt.claims.app_user_id')::text;

    SELECT *
    INTO _app_user
    FROM auth.app_user
    WHERE id = _app_user_id
    ;

    return _app_user;
  end;
  $$;


ALTER FUNCTION auth_fn.current_app_user() OWNER TO app;

--
-- Name: current_app_user_id(); Type: FUNCTION; Schema: auth_fn; Owner: app
--

CREATE FUNCTION auth_fn.current_app_user_id() RETURNS text
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  DECLARE
  BEGIN
    return current_setting('jwt.claims.app_user_id')::text;
  end;
  $$;


ALTER FUNCTION auth_fn.current_app_user_id() OWNER TO app;

--
-- Name: FUNCTION current_app_user_id(); Type: COMMENT; Schema: auth_fn; Owner: app
--

COMMENT ON FUNCTION auth_fn.current_app_user_id() IS '@omit';


--
-- Name: fn_timestamp_update_conversion(); Type: FUNCTION; Schema: lcb; Owner: app
--

CREATE FUNCTION lcb.fn_timestamp_update_conversion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION lcb.fn_timestamp_update_conversion() OWNER TO app;

--
-- Name: fn_timestamp_update_conversion_result(); Type: FUNCTION; Schema: lcb; Owner: app
--

CREATE FUNCTION lcb.fn_timestamp_update_conversion_result() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION lcb.fn_timestamp_update_conversion_result() OWNER TO app;

--
-- Name: fn_timestamp_update_inventory_lot(); Type: FUNCTION; Schema: lcb; Owner: app
--

CREATE FUNCTION lcb.fn_timestamp_update_inventory_lot() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION lcb.fn_timestamp_update_inventory_lot() OWNER TO app;

--
-- Name: fn_timestamp_update_lcb_license(); Type: FUNCTION; Schema: lcb; Owner: app
--

CREATE FUNCTION lcb.fn_timestamp_update_lcb_license() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION lcb.fn_timestamp_update_lcb_license() OWNER TO app;

--
-- Name: fn_timestamp_update_lcb_license_holder(); Type: FUNCTION; Schema: lcb; Owner: app
--

CREATE FUNCTION lcb.fn_timestamp_update_lcb_license_holder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    NEW.updated_at = current_timestamp;
    RETURN NEW;
  END; $$;


ALTER FUNCTION lcb.fn_timestamp_update_lcb_license_holder() OWNER TO app;

--
-- Name: inventory_lot; Type: TABLE; Schema: lcb; Owner: app
--

CREATE TABLE lcb.inventory_lot (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    parent_id text,
    licensee_identifier text,
    app_tenant_id text NOT NULL,
    lcb_license_holder_id text NOT NULL,
    reporting_status text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    id_origin text NOT NULL,
    inventory_type text NOT NULL,
    description text,
    quantity numeric(10,2),
    strain_name text,
    area_identifier text,
    CONSTRAINT ck_inventory_lot_id CHECK ((id <> ''::text)),
    CONSTRAINT ck_inventory_lot_id_origin CHECK ((id_origin <> ''::text)),
    CONSTRAINT ck_inventory_lot_inventory_type CHECK ((inventory_type <> ''::text))
);


ALTER TABLE lcb.inventory_lot OWNER TO app;

--
-- Name: deplete_inventory_lot_ids(text[]); Type: FUNCTION; Schema: lcb_fn; Owner: app
--

CREATE FUNCTION lcb_fn.deplete_inventory_lot_ids(_ids text[]) RETURNS SETOF lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- only active ids can be locked
    if 0 < (select count(*) from lcb.inventory_lot where id = ANY(_ids) and reporting_status != 'ACTIVE') then
      raise exception 'illegal operation - batch cancelled: only active ids can be depleted.';
    end if;

    update lcb.inventory_lot set
      reporting_status = 'DEPLETED',
      quantity = 0
    where id = ANY(_ids);

    RETURN QUERY SELECT * FROM lcb.inventory_lot WHERE id = ANY(_ids);
  END;
  $$;


ALTER FUNCTION lcb_fn.deplete_inventory_lot_ids(_ids text[]) OWNER TO app;

--
-- Name: destroy_inventory_lot_ids(text[]); Type: FUNCTION; Schema: lcb_fn; Owner: app
--

CREATE FUNCTION lcb_fn.destroy_inventory_lot_ids(_ids text[]) RETURNS SETOF lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- only active ids can be locked
    if 0 < (select count(*) from lcb.inventory_lot where id = ANY(_ids) and reporting_status != 'ACTIVE') then
      raise exception 'illegal operation - batch cancelled: only active ids can be destroyed.';
    end if;

    update lcb.inventory_lot set
      reporting_status = 'DESTROYED',
      quantity = 0
    where id = ANY(_ids);

    RETURN QUERY SELECT * FROM lcb.inventory_lot WHERE id = ANY(_ids);
  END;
  $$;


ALTER FUNCTION lcb_fn.destroy_inventory_lot_ids(_ids text[]) OWNER TO app;

--
-- Name: invalidate_inventory_lot_ids(text[]); Type: FUNCTION; Schema: lcb_fn; Owner: app
--

CREATE FUNCTION lcb_fn.invalidate_inventory_lot_ids(_ids text[]) RETURNS SETOF lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- only provisioned ids can be invalidated
    if 0 < (select count(*) from lcb.inventory_lot where id = ANY(_ids) and reporting_status != 'PROVISIONED') then
      raise exception 'illegal operation - batch cancelled: only provisioned ids can be invalidated.';
    end if;

    update lcb.inventory_lot set
      reporting_status = 'INVALIDATED'
    where id = ANY(_ids);

    RETURN QUERY SELECT * FROM lcb.inventory_lot WHERE id = ANY(_ids);
  END;
  $$;


ALTER FUNCTION lcb_fn.invalidate_inventory_lot_ids(_ids text[]) OWNER TO app;

--
-- Name: provision_inventory_lot_ids(text, integer); Type: FUNCTION; Schema: lcb_fn; Owner: app
--

CREATE FUNCTION lcb_fn.provision_inventory_lot_ids(_inventory_type text, _number_requested integer) RETURNS SETOF lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot lcb.inventory_lot;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    -- raise exception '%, %', _current_app_user.app_tenant_id, _lcb_license_holder_id;

    RETURN QUERY INSERT INTO lcb.inventory_lot(
      app_tenant_id,
      lcb_license_holder_id,
      id_origin,
      reporting_status,
      inventory_type
    )
    SELECT
      _current_app_user.app_tenant_id,
      _lcb_license_holder_id,
      'WSLCB',
      'PROVISIONED',
      _inventory_type
    FROM
      generate_series(1, _number_requested)
    RETURNING *
    ;
  end;
  $$;


ALTER FUNCTION lcb_fn.provision_inventory_lot_ids(_inventory_type text, _number_requested integer) OWNER TO app;

--
-- Name: report_inventory_lot(lcb_fn.report_inventory_lot_input[]); Type: FUNCTION; Schema: lcb_fn; Owner: app
--

CREATE FUNCTION lcb_fn.report_inventory_lot(_input lcb_fn.report_inventory_lot_input[]) RETURNS SETOF lcb.inventory_lot
    LANGUAGE plpgsql STRICT
    AS $$
  DECLARE
    _current_app_user auth.app_user;
    _lcb_license_holder_id text;
    _inventory_lot_input lcb_fn.report_inventory_lot_input;
    _inventory_lot lcb.inventory_lot;
    _inventory_lot_id text;
  BEGIN
    _current_app_user := auth_fn.current_app_user();

    -- this is not really correct.  need mechanism to switch between licenses
    select id
    into _lcb_license_holder_id
    from lcb.lcb_license_holder
    where app_tenant_id = _current_app_user.app_tenant_id;

    foreach _inventory_lot_input in ARRAY _input
    loop

      -- if _inventory_lot_input.id is null or _inventory_lot_input.id = '' then
      --   raise exception 'illegal operation - batch cancelled:  all inventory lots must have id defined.';
      -- end if;

      -- make sure this lot can be identified later
      if _inventory_lot_input.id is null or _inventory_lot_input.id = '' then
        if _inventory_lot_input.licensee_identifier is null or _inventory_lot_input.licensee_identifier = '' then
          raise exception 'illegal operation - batch cancelled:  all inventory lots must have id OR licensee_identifier defined.';
        end if;
        _inventory_lot_id := util_fn.generate_ulid();
      else
        -- _inventory_lot_input.id should be verified as a valid ulid here
        _inventory_lot_id := _inventory_lot_input.id;
      end if;
      
      -- find existing lot if it's there
      select *
      into _inventory_lot
      from lcb.inventory_lot
      where id = _inventory_lot_id;

      if _inventory_lot.id is null then
        insert into lcb.inventory_lot(
          id,
          licensee_identifier,
          app_tenant_id,
          lcb_license_holder_id,
          id_origin,
          reporting_status,
          inventory_type,
          description,
          quantity,
          strain_name,
          area_identifier
        )
        SELECT
          COALESCE(_inventory_lot_input.id, util_fn.generate_ulid()),
          _inventory_lot_input.licensee_identifier,
          _current_app_user.app_tenant_id,
          _lcb_license_holder_id,
          case when _inventory_lot_input.id is null then 'WSLCB' else 'LICENSEE' end,
          case when _inventory_lot_input.quantity > 0 then 'ACTIVE' else 'DEPLETED' end,
          _inventory_lot_input.inventory_type::text,
          _inventory_lot_input.description::text,
          _inventory_lot_input.quantity::numeric(10,2),
          _inventory_lot_input.strain_name::text,
          _inventory_lot_input.area_identifier::text
        RETURNING * INTO _inventory_lot;
      else
        if _inventory_lot.reporting_status != 'ACTIVE' and _inventory_lot.reporting_status != 'PROVISIONED' then
          raise exception 'illegal operation - batch cancelled:  can only report on ACTIVE or PROVISIONED inventory lots: %', _inventory_lot.id;
        end if;

        if _inventory_lot_input.inventory_type != _inventory_lot.inventory_type then
          raise exception 'illegal operation - batch cancelled:  cannot change inventory type of an existing inventory lot: %', _inventory_lot.id;
        end if;

        -- update lcb.inventory_lot set
        --   licensee_identifier = _inventory_lot_input.licensee_identifier::text,
        --   description = _inventory_lot_input.description::text,
        --   quantity = _inventory_lot_input.quantity::numeric(10,2),
        --   strain_name = _inventory_lot_input.strain_name::text,
        --   area_identifier = _inventory_lot_input.area_identifier::text,
        --   reporting_status = case when _inventory_lot_input.quantity::numeric(10,2) > 0 then 'ACTIVE' else 'DEPLETED' end
        -- where id = _inventory_lot_id
        -- and (
        --   _inventory_lot_input.licensee_identifier::text != licensee_identifier
        --   OR _inventory_lot_input.description::text != description
        --   OR _inventory_lot_input.quantity::numeric(20,2) != quantity
        --   OR _inventory_lot_input.strain_name::text != strain_name
        --   OR _inventory_lot_input.area_identifier::text != area_identifier
        -- )
        -- returning * into _inventory_lot
        -- ;
        if   coalesce(_inventory_lot_input.licensee_identifier::text, '') != coalesce(_inventory_lot.licensee_identifier, '')
          OR coalesce(_inventory_lot_input.description::text, '')         != coalesce(_inventory_lot.description, '')
          OR coalesce(_inventory_lot_input.quantity::numeric(20,2), -1)   != coalesce(_inventory_lot.quantity, -1)
          OR coalesce(_inventory_lot_input.strain_name::text, '')         != coalesce(_inventory_lot.strain_name, '')
          OR coalesce(_inventory_lot_input.area_identifier::text, '')     != coalesce(_inventory_lot.area_identifier, '')
        then
          update lcb.inventory_lot set
            licensee_identifier = _inventory_lot_input.licensee_identifier::text,
            description = _inventory_lot_input.description::text,
            quantity = _inventory_lot_input.quantity::numeric(10,2),
            strain_name = _inventory_lot_input.strain_name::text,
            area_identifier = _inventory_lot_input.area_identifier::text,
            reporting_status = case when _inventory_lot_input.quantity::numeric(10,2) > 0 then 'ACTIVE' else 'DEPLETED' end
          where id = _inventory_lot_id
          returning * into _inventory_lot
          ;
        end if;

-- raise exception 'wtf %', _inventory_lot_input.quantity::numeric(10,2);
        SELECT * INTO _inventory_lot FROM lcb.inventory_lot WHERE id = _inventory_lot_id;
      end if;

      return next _inventory_lot;

    end loop;

    RETURN;


  end;
  $$;


ALTER FUNCTION lcb_fn.report_inventory_lot(_input lcb_fn.report_inventory_lot_input[]) OWNER TO app;

--
-- Name: fn_timestamp_update_contact(); Type: FUNCTION; Schema: org; Owner: app
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


ALTER FUNCTION org.fn_timestamp_update_contact() OWNER TO app;

--
-- Name: fn_timestamp_update_contact_app_user(); Type: FUNCTION; Schema: org; Owner: app
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


ALTER FUNCTION org.fn_timestamp_update_contact_app_user() OWNER TO app;

--
-- Name: fn_timestamp_update_facility(); Type: FUNCTION; Schema: org; Owner: app
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


ALTER FUNCTION org.fn_timestamp_update_facility() OWNER TO app;

--
-- Name: fn_timestamp_update_location(); Type: FUNCTION; Schema: org; Owner: app
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


ALTER FUNCTION org.fn_timestamp_update_location() OWNER TO app;

--
-- Name: fn_timestamp_update_organization(); Type: FUNCTION; Schema: org; Owner: app
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


ALTER FUNCTION org.fn_timestamp_update_organization() OWNER TO app;

--
-- Name: contact; Type: TABLE; Schema: org; Owner: app
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


ALTER TABLE org.contact OWNER TO app;

--
-- Name: COLUMN contact.id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact.id IS '@omit create';


--
-- Name: COLUMN contact.app_tenant_id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact.app_tenant_id IS '@omit create, update';


--
-- Name: COLUMN contact.created_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact.created_at IS '@omit create,update';


--
-- Name: COLUMN contact.updated_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact.updated_at IS '@omit create,update';


--
-- Name: COLUMN contact.organization_id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact.organization_id IS '@omit create,update';


--
-- Name: build_contact(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.build_contact(_first_name text, _last_name text, _email text, _cell_phone text, _office_phone text, _title text, _nickname text, _external_id text, _organization_id text) OWNER TO app;

--
-- Name: build_contact_location(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.build_contact_location(_contact_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO app;

--
-- Name: facility; Type: TABLE; Schema: org; Owner: app
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


ALTER TABLE org.facility OWNER TO app;

--
-- Name: COLUMN facility.id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.facility.id IS '@omit create';


--
-- Name: COLUMN facility.app_tenant_id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.facility.app_tenant_id IS '@omit create';


--
-- Name: COLUMN facility.created_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.facility.created_at IS '@omit create,update';


--
-- Name: COLUMN facility.updated_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.facility.updated_at IS '@omit create,update';


--
-- Name: build_facility(text, text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.build_facility(_organization_id text, _name text, _external_id text) OWNER TO app;

--
-- Name: build_facility_location(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.build_facility_location(_facility_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO app;

--
-- Name: location; Type: TABLE; Schema: org; Owner: app
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


ALTER TABLE org.location OWNER TO app;

--
-- Name: COLUMN location.id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.location.id IS '@omit create';


--
-- Name: COLUMN location.app_tenant_id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.location.app_tenant_id IS '@omit create';


--
-- Name: COLUMN location.created_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.location.created_at IS '@omit create,update';


--
-- Name: COLUMN location.updated_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.location.updated_at IS '@omit create,update';


--
-- Name: build_location(text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.build_location(_name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO app;

--
-- Name: organization; Type: TABLE; Schema: org; Owner: app
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


ALTER TABLE org.organization OWNER TO app;

--
-- Name: COLUMN organization.id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.organization.id IS '@omit create';


--
-- Name: COLUMN organization.app_tenant_id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.organization.app_tenant_id IS '@omit create';


--
-- Name: COLUMN organization.created_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.organization.created_at IS '@omit create,update';


--
-- Name: COLUMN organization.updated_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.organization.updated_at IS '@omit create,update';


--
-- Name: build_organization(text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.build_organization(_name text, _external_id text) OWNER TO app;

--
-- Name: build_organization_location(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.build_organization_location(_organization_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO app;

--
-- Name: build_tenant_organization(text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.build_tenant_organization(_name text, _identifier text, _primary_contact_email text, _primary_contact_first_name text, _primary_contact_last_name text) OWNER TO app;

--
-- Name: current_app_user_contact(); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.current_app_user_contact() OWNER TO app;

--
-- Name: modify_location(text, text, text, text, text, text, text, text, text); Type: FUNCTION; Schema: org_fn; Owner: app
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


ALTER FUNCTION org_fn.modify_location(_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) OWNER TO app;

--
-- Name: trim_text(text); Type: FUNCTION; Schema: util_fn; Owner: app
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


ALTER FUNCTION util_fn.trim_text(_input text) OWNER TO app;

--
-- Name: application; Type: TABLE; Schema: app; Owner: app
--

CREATE TABLE app.application (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    external_id text,
    name text,
    key text NOT NULL
);


ALTER TABLE app.application OWNER TO app;

--
-- Name: license; Type: TABLE; Schema: app; Owner: app
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


ALTER TABLE app.license OWNER TO app;

--
-- Name: TABLE license; Type: COMMENT; Schema: app; Owner: app
--

COMMENT ON TABLE app.license IS '@foreignKey (assigned_to_app_user_id) references org.contact_app_user(app_user_id)';


--
-- Name: license_permission; Type: TABLE; Schema: app; Owner: app
--

CREATE TABLE app.license_permission (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_tenant_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    license_id text NOT NULL,
    permission_id text NOT NULL
);


ALTER TABLE app.license_permission OWNER TO app;

--
-- Name: license_type; Type: TABLE; Schema: app; Owner: app
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


ALTER TABLE app.license_type OWNER TO app;

--
-- Name: license_type_permission; Type: TABLE; Schema: app; Owner: app
--

CREATE TABLE app.license_type_permission (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    license_type_id text NOT NULL,
    permission_id text NOT NULL,
    key text NOT NULL
);


ALTER TABLE app.license_type_permission OWNER TO app;

--
-- Name: config_auth; Type: TABLE; Schema: auth; Owner: app
--

CREATE TABLE auth.config_auth (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    key text,
    value text
);


ALTER TABLE auth.config_auth OWNER TO app;

--
-- Name: TABLE config_auth; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON TABLE auth.config_auth IS '@omit create,update,delete';


--
-- Name: permission; Type: TABLE; Schema: auth; Owner: app
--

CREATE TABLE auth.permission (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    key text,
    CONSTRAINT permission_key_check CHECK ((char_length(key) >= 4))
);


ALTER TABLE auth.permission OWNER TO app;

--
-- Name: token; Type: TABLE; Schema: auth; Owner: app
--

CREATE TABLE auth.token (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    app_user_id text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp with time zone DEFAULT (CURRENT_TIMESTAMP + '00:20:00'::interval) NOT NULL
);


ALTER TABLE auth.token OWNER TO app;

--
-- Name: TABLE token; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON TABLE auth.token IS '@omit create,update,delete';


--
-- Name: COLUMN token.created_at; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.token.created_at IS '@omit create,update';


--
-- Name: COLUMN token.expires_at; Type: COMMENT; Schema: auth; Owner: app
--

COMMENT ON COLUMN auth.token.expires_at IS '@omit create,update';


--
-- Name: conversion; Type: TABLE; Schema: lcb; Owner: app
--

CREATE TABLE lcb.conversion (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    app_tenant_id text NOT NULL,
    from_inventory_lot_id text NOT NULL,
    sourced_quantity numeric(10,2) NOT NULL
);


ALTER TABLE lcb.conversion OWNER TO app;

--
-- Name: conversion_result; Type: TABLE; Schema: lcb; Owner: app
--

CREATE TABLE lcb.conversion_result (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    app_tenant_id text NOT NULL,
    conversion_id text NOT NULL,
    inventory_lot_id text NOT NULL
);


ALTER TABLE lcb.conversion_result OWNER TO app;

--
-- Name: lcb_license; Type: TABLE; Schema: lcb; Owner: app
--

CREATE TABLE lcb.lcb_license (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    code text NOT NULL,
    CONSTRAINT ck_lcb_license_code CHECK ((code <> ''::text)),
    CONSTRAINT lcb_license_code_check CHECK ((code <> ''::text))
);


ALTER TABLE lcb.lcb_license OWNER TO app;

--
-- Name: lcb_license_holder; Type: TABLE; Schema: lcb; Owner: app
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


ALTER TABLE lcb.lcb_license_holder OWNER TO app;

--
-- Name: hist_inventory_lot; Type: TABLE; Schema: lcb_hist; Owner: app
--

CREATE TABLE lcb_hist.hist_inventory_lot (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    parent_id text,
    licensee_identifier text,
    inventory_lot_id text NOT NULL,
    app_tenant_id text NOT NULL,
    lcb_license_holder_id text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    deleted_at timestamp with time zone,
    id_origin text NOT NULL,
    reporting_status text NOT NULL,
    inventory_type text NOT NULL,
    description text,
    quantity numeric(10,2),
    units text,
    strain_name text,
    area_identifier text
);


ALTER TABLE lcb_hist.hist_inventory_lot OWNER TO app;

--
-- Name: conversion_rule; Type: TABLE; Schema: lcb_ref; Owner: app
--

CREATE TABLE lcb_ref.conversion_rule (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    from_type_id text NOT NULL,
    to_inventory_type_id text NOT NULL
);


ALTER TABLE lcb_ref.conversion_rule OWNER TO app;

--
-- Name: inventory_lot_reporting_status; Type: TABLE; Schema: lcb_ref; Owner: app
--

CREATE TABLE lcb_ref.inventory_lot_reporting_status (
    id text NOT NULL,
    CONSTRAINT ck_inventory_lot_reporting_status_id CHECK ((id <> ''::text))
);


ALTER TABLE lcb_ref.inventory_lot_reporting_status OWNER TO app;

--
-- Name: inventory_type; Type: TABLE; Schema: lcb_ref; Owner: app
--

CREATE TABLE lcb_ref.inventory_type (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    units text NOT NULL,
    CONSTRAINT ck_inventory_type_id CHECK ((id <> ''::text))
);


ALTER TABLE lcb_ref.inventory_type OWNER TO app;

--
-- Name: transfer_status; Type: TABLE; Schema: lcb_ref; Owner: app
--

CREATE TABLE lcb_ref.transfer_status (
    id text NOT NULL,
    CONSTRAINT ck_transfer_status_id CHECK ((id <> ''::text))
);


ALTER TABLE lcb_ref.transfer_status OWNER TO app;

--
-- Name: config_org; Type: TABLE; Schema: org; Owner: app
--

CREATE TABLE org.config_org (
    id text DEFAULT util_fn.generate_ulid() NOT NULL,
    key text,
    value text
);


ALTER TABLE org.config_org OWNER TO app;

--
-- Name: TABLE config_org; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON TABLE org.config_org IS '@omit create,update,delete';


--
-- Name: contact_app_user; Type: TABLE; Schema: org; Owner: app
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


ALTER TABLE org.contact_app_user OWNER TO app;

--
-- Name: COLUMN contact_app_user.id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact_app_user.id IS '@omit create';


--
-- Name: COLUMN contact_app_user.app_tenant_id; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact_app_user.app_tenant_id IS '@omit create';


--
-- Name: COLUMN contact_app_user.created_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact_app_user.created_at IS '@omit create,update';


--
-- Name: COLUMN contact_app_user.updated_at; Type: COMMENT; Schema: org; Owner: app
--

COMMENT ON COLUMN org.contact_app_user.updated_at IS '@omit create,update';


--
-- Name: global_id_sequence; Type: SEQUENCE; Schema: shard_1; Owner: app
--

CREATE SEQUENCE shard_1.global_id_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE shard_1.global_id_sequence OWNER TO app;

--
-- Data for Name: application; Type: TABLE DATA; Schema: app; Owner: app
--

COPY app.application (id, created_at, updated_at, external_id, name, key) FROM stdin;
01DV777SQS3Q80T1HMX8Y7YNAA	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	Tenant Manager	tenant-manager
01DV777SQS27KX9XV54BX57276	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	License Manager	license-manager
01DV777SQSNTKW4TR05QCJV8N8	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	address book	address-book
01DV777SQSF4W6DBKDNE3V1WN3	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	LCB Traceability	lcb-traceability
\.


--
-- Data for Name: license; Type: TABLE DATA; Schema: app; Owner: app
--

COPY app.license (id, app_tenant_id, created_at, updated_at, external_id, name, license_type_id, assigned_to_app_user_id) FROM stdin;
01DV777SQSZGD5KJFFYD13JEAJ	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_producer_admin - License Manager	01DV777SQSGZRZ7VWH3VFC49H9	01DV777RNKXMGC0CZSGBP9K40F
01DV777SQSC1CPQ4HD5GZ28TNR	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_processor_admin - License Manager	01DV777SQSGZRZ7VWH3VFC49H9	01DV777RNKKRYHNRQG5WB5BJPA
01DV777SQS163NXGWZY6HA9Y2S	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_retail_admin - License Manager	01DV777SQSGZRZ7VWH3VFC49H9	01DV777RNK9EMPF49V4EZ6M8QA
01DV777SQSX4VVGGMSBWRDJ8TK	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_producer_admin - Address Book	01DV777SQSX5M29JG0AW4D0JK0	01DV777RNKXMGC0CZSGBP9K40F
01DV777SQS3A7E0XPP79EYZRJ1	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_producer_user - Address Book	01DV777SQSX5M29JG0AW4D0JK0	01DV777RNKKVBBPM7YA1KQWB51
01DV777SQSW4H9FJP6RAZ0QACX	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_processor_admin - Address Book	01DV777SQSX5M29JG0AW4D0JK0	01DV777RNKKRYHNRQG5WB5BJPA
01DV777SQST0MZ05GR6FDP3SC6	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_processor_user - Address Book	01DV777SQSX5M29JG0AW4D0JK0	01DV777RNK1C50TSH31GZT3D2Z
01DV777SQSFM33MWWKCSBB4ZE7	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_retail_admin - Address Book	01DV777SQSX5M29JG0AW4D0JK0	01DV777RNK9EMPF49V4EZ6M8QA
01DV777SQS3PRACEMXMVYDB40C	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_retail_user - Address Book	01DV777SQSX5M29JG0AW4D0JK0	01DV777RNKTYE2K9F90PPNF7CY
01DV777SQS63VH0GBX46SPSM6N	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_producer_admin - LCB Traceability	01DV777SQSCSR4QGX1TXVNM16X	01DV777RNKXMGC0CZSGBP9K40F
01DV777SQSFVZ5AE4XH85E0X91	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_producer_user - LCB Traceability	01DV777SQSCSR4QGX1TXVNM16X	01DV777RNKKVBBPM7YA1KQWB51
01DV777SQS7Z0E6XXGYG3TM6QD	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_processor_admin - LCB Traceability	01DV777SQSCSR4QGX1TXVNM16X	01DV777RNKKRYHNRQG5WB5BJPA
01DV777SQS7CQ9KZ9YZXR69ES4	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_processor_user - LCB Traceability	01DV777SQSCSR4QGX1TXVNM16X	01DV777RNK1C50TSH31GZT3D2Z
01DV777SQS401WS41ZY5W30YH1	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_retail_admin - LCB Traceability	01DV777SQSCSR4QGX1TXVNM16X	01DV777RNK9EMPF49V4EZ6M8QA
01DV777SQSASYFB51CR49337D8	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	lcb_retail_user - LCB Traceability	01DV777SQSCSR4QGX1TXVNM16X	01DV777RNKTYE2K9F90PPNF7CY
\.


--
-- Data for Name: license_permission; Type: TABLE DATA; Schema: app; Owner: app
--

COPY app.license_permission (id, app_tenant_id, created_at, updated_at, license_id, permission_id) FROM stdin;
\.


--
-- Data for Name: license_type; Type: TABLE DATA; Schema: app; Owner: app
--

COPY app.license_type (id, created_at, updated_at, external_id, name, key, application_id) FROM stdin;
01DV777SQSR5HGWESGX52XHMAW	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	Tenant Manager	tenant-manager	01DV777SQS3Q80T1HMX8Y7YNAA
01DV777SQSGZRZ7VWH3VFC49H9	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	License Manager	license-manager	01DV777SQS27KX9XV54BX57276
01DV777SQSX5M29JG0AW4D0JK0	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	Address Book	address-book	01DV777SQSNTKW4TR05QCJV8N8
01DV777SQSCSR4QGX1TXVNM16X	2019-12-04 01:08:52.601497+00	2019-12-04 01:08:52.601497+00	\N	LCB Traceability	lcb-traceability	01DV777SQSF4W6DBKDNE3V1WN3
\.


--
-- Data for Name: license_type_permission; Type: TABLE DATA; Schema: app; Owner: app
--

COPY app.license_type_permission (id, created_at, updated_at, license_type_id, permission_id, key) FROM stdin;
\.


--
-- Data for Name: app_tenant; Type: TABLE DATA; Schema: auth; Owner: app
--

COPY auth.app_tenant (id, created_at, updated_at, name, identifier) FROM stdin;
01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	Producer-1	G11111
01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	Processor-1	M11111
01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	Retail-1	R11111
\.


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: auth; Owner: app
--

COPY auth.app_user (id, app_tenant_id, created_at, updated_at, username, recovery_email, password_hash, inactive, password_reset_required, permission_key) FROM stdin;
01DV777RNKXMGC0CZSGBP9K40F	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	lcb_producer_admin	lcb_producer_admin@blah.blah	$2a$06$b95Qi6FHf9vqUOpBgbv7LePHGt5VGE5P/31nOB7fhwYIZD3Y05GSS	f	f	Admin
01DV777RNKKVBBPM7YA1KQWB51	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	lcb_producer_user	lcb_producer_user@blah.blah	$2a$06$pbV0Pb8v1BuOxG6lkds5DO8lL0Ic0u4t7M3/PKkDBVZUVpMGarmji	f	f	User
01DV777RNKKRYHNRQG5WB5BJPA	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	lcb_processor_admin	lcb_processor_admin@blah.blah	$2a$06$EKk/M86Tx6SfNxpXf/hcS.y4d3Eutftv2MaVmX.YTHNgqYBRYqUgC	f	f	Admin
01DV777RNK1C50TSH31GZT3D2Z	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	lcb_processor_user	lcb_processor_user@blah.blah	$2a$06$xeUlOfmne7C4xBAbYn6fluKvIDalrJi5.57yLaY3ldnFTeyBhLOfC	f	f	User
01DV777RNK9EMPF49V4EZ6M8QA	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	lcb_retail_admin	lcb_retail_admin003@blah.blah	$2a$06$i6YoozhGFqZ2kModwx33SeFT0LDyzi33igwuqzj/rspGfRf6QRHJy	f	f	Admin
01DV777RNKTYE2K9F90PPNF7CY	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	lcb_retail_user	lcb_retail_user@blah.blah	$2a$06$II/chTkM8T5iukef7Mi2POTB65WSQfBXOF4oBlvJS4.fHjKTX2TPK	f	f	User
\.


--
-- Data for Name: config_auth; Type: TABLE DATA; Schema: auth; Owner: app
--

COPY auth.config_auth (id, key, value) FROM stdin;
\.


--
-- Data for Name: permission; Type: TABLE DATA; Schema: auth; Owner: app
--

COPY auth.permission (id, created_at, key) FROM stdin;
\.


--
-- Data for Name: token; Type: TABLE DATA; Schema: auth; Owner: app
--

COPY auth.token (id, app_user_id, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: conversion; Type: TABLE DATA; Schema: lcb; Owner: app
--

COPY lcb.conversion (id, created_at, updated_at, app_tenant_id, from_inventory_lot_id, sourced_quantity) FROM stdin;
\.


--
-- Data for Name: conversion_result; Type: TABLE DATA; Schema: lcb; Owner: app
--

COPY lcb.conversion_result (id, created_at, updated_at, app_tenant_id, conversion_id, inventory_lot_id) FROM stdin;
\.


--
-- Data for Name: inventory_lot; Type: TABLE DATA; Schema: lcb; Owner: app
--

COPY lcb.inventory_lot (id, parent_id, licensee_identifier, app_tenant_id, lcb_license_holder_id, reporting_status, created_at, updated_at, deleted_at, id_origin, inventory_type, description, quantity, strain_name, area_identifier) FROM stdin;
\.


--
-- Data for Name: lcb_license; Type: TABLE DATA; Schema: lcb; Owner: app
--

COPY lcb.lcb_license (id, created_at, updated_at, code) FROM stdin;
01DV777SNB2AB742VHJ5V3YEBT	2019-12-04 01:08:52.522755+00	2019-12-04 01:08:52.522755+00	G11111
01DV777SNBD4XMRYS1TAEYJPRJ	2019-12-04 01:08:52.522755+00	2019-12-04 01:08:52.522755+00	M11111
01DV777SNBJ0AD2MYBZ22P3K9J	2019-12-04 01:08:52.522755+00	2019-12-04 01:08:52.522755+00	R11111
\.


--
-- Data for Name: lcb_license_holder; Type: TABLE DATA; Schema: lcb; Owner: app
--

COPY lcb.lcb_license_holder (id, app_tenant_id, created_at, updated_at, lcb_license_id, organization_id, acquisition_date, relinquish_date) FROM stdin;
01DV777SNB92ZMW9HREK9HVAVJ	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:52.522755+00	2019-12-04 01:08:52.522755+00	01DV777SNB2AB742VHJ5V3YEBT	01DV777RNK2AESXHCS172G0140	2019-12-04 01:08:52.522755+00	\N
01DV777SNBWXVV3NGXPV4PDCZT	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:52.522755+00	2019-12-04 01:08:52.522755+00	01DV777SNBD4XMRYS1TAEYJPRJ	01DV777RNKZMKWFB95T5XW624A	2019-12-04 01:08:52.522755+00	\N
01DV777SNBJ2GV4CEEYBH5PKWD	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:52.522755+00	2019-12-04 01:08:52.522755+00	01DV777SNBJ0AD2MYBZ22P3K9J	01DV777RNKW3FKFS3MN1NNQBJH	2019-12-04 01:08:52.522755+00	\N
\.


--
-- Data for Name: hist_inventory_lot; Type: TABLE DATA; Schema: lcb_hist; Owner: app
--

COPY lcb_hist.hist_inventory_lot (id, parent_id, licensee_identifier, inventory_lot_id, app_tenant_id, lcb_license_holder_id, created_at, updated_at, deleted_at, id_origin, reporting_status, inventory_type, description, quantity, units, strain_name, area_identifier) FROM stdin;
\.


--
-- Data for Name: conversion_rule; Type: TABLE DATA; Schema: lcb_ref; Owner: app
--

COPY lcb_ref.conversion_rule (id, from_type_id, to_inventory_type_id) FROM stdin;
01DV777KN09DH2E7BDK0QEQ9MN	SD	CL
01DV777KN02C4C2XS9502NWBA9	CL	PL
01DV777KN0047KEQ1K8AWQB6ZH	PL	WF
01DV777KN0MT24RN7A00TJ3893	WF	BF
01DV777KN004RW77QD560EKZPH	BF	LF
01DV777KN0W24AQMYC7SBHQ1V8	LF	UM
01DV777KN0ZNBN6AEK106W5JGH	LF	PM
01DV777KN0B2V3FTKY1N1RASPC	LF	PR
01DV777KN0BH3NYG37F4XCBDTN	LF	UM
\.


--
-- Data for Name: inventory_lot_reporting_status; Type: TABLE DATA; Schema: lcb_ref; Owner: app
--

COPY lcb_ref.inventory_lot_reporting_status (id) FROM stdin;
PROVISIONED
INVALIDATED
ACTIVE
DESTROYED
DEPLETED
\.


--
-- Data for Name: inventory_type; Type: TABLE DATA; Schema: lcb_ref; Owner: app
--

COPY lcb_ref.inventory_type (id, name, description, units) FROM stdin;
WF	Wet Flower	\N	g
BF	Bulk Flower	\N	g
LF	Lot Flower	\N	g
UM	Usable Marijuana	\N	g
PM	Packaged Marijuana	\N	g
PR	Pre-roll Joints	\N	ct
CL	Clones	\N	ct
SD	Seeds	\N	ct
PL	Plants	\N	ct
IS	Infused Solid Edible	\N	ct
IL	Infused Liquid Edible	\N	ct
\.


--
-- Data for Name: transfer_status; Type: TABLE DATA; Schema: lcb_ref; Owner: app
--

COPY lcb_ref.transfer_status (id) FROM stdin;
SCHEDULED
DEPARTED
DELIVERED
RECEIVED
REJECTED
CANCELLED
\.


--
-- Data for Name: config_org; Type: TABLE DATA; Schema: org; Owner: app
--

COPY org.config_org (id, key, value) FROM stdin;
\.


--
-- Data for Name: contact; Type: TABLE DATA; Schema: org; Owner: app
--

COPY org.contact (id, app_tenant_id, created_at, updated_at, organization_id, location_id, external_id, first_name, last_name, email, cell_phone, office_phone, title, nickname) FROM stdin;
01DV777RNKQQ60SFSZ5S4C9Z6W	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNK2AESXHCS172G0140	\N	lcb_producer_admin	lcb_producer_admin	Test	lcb_producer_admin@blah.blah	\N	\N	\N	\N
01DV777RNKPNGNZFX3QAFBJ6GT	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNK2AESXHCS172G0140	\N	lcb_producer_user	lcb_producer_user	Test	lcb_producer_user@blah.blah	\N	\N	\N	\N
01DV777RNK3196PV1HFB8AMRSP	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNKZMKWFB95T5XW624A	\N	lcb_processor_admin	lcb_processor_admin	Test	lcb_processor_admin@blah.blah	\N	\N	\N	\N
01DV777RNKC6ATTG9GPS5A6X9C	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNKZMKWFB95T5XW624A	\N	lcb_processor_user	lcb_processor_user	Test	lcb_processor_user@blah.blah	\N	\N	\N	\N
01DV777RNKQC009G33Q4BR4FK8	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNKW3FKFS3MN1NNQBJH	\N	lcb_retail_admin	lcb_retail_admin	Test	lcb_retail_admin003@blah.blah	\N	\N	\N	\N
01DV777RNK68W6EGPWJAN76R0A	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNKW3FKFS3MN1NNQBJH	\N	lcb_retail_user	lcb_retail_user	Test	lcb_retail_user@blah.blah	\N	\N	\N	\N
\.


--
-- Data for Name: contact_app_user; Type: TABLE DATA; Schema: org; Owner: app
--

COPY org.contact_app_user (id, app_tenant_id, created_at, updated_at, contact_id, app_user_id, username) FROM stdin;
01DV777RNK2WQ2HZ4K21MEQQRT	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNKQQ60SFSZ5S4C9Z6W	01DV777RNKXMGC0CZSGBP9K40F	lcb_producer_admin
01DV777RNK94STDR8FX8NB5CHF	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNKPNGNZFX3QAFBJ6GT	01DV777RNKKVBBPM7YA1KQWB51	lcb_producer_user
01DV777RNKSZWRRH3TZD6NV1G3	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNK3196PV1HFB8AMRSP	01DV777RNKKRYHNRQG5WB5BJPA	lcb_processor_admin
01DV777RNKX1ZV090SS8NMGDGW	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNKC6ATTG9GPS5A6X9C	01DV777RNK1C50TSH31GZT3D2Z	lcb_processor_user
01DV777RNKFP87QH3DV7ZMVD7E	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNKQC009G33Q4BR4FK8	01DV777RNK9EMPF49V4EZ6M8QA	lcb_retail_admin
01DV777RNKZMQKHANRCRQ56QVM	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	01DV777RNK68W6EGPWJAN76R0A	01DV777RNKTYE2K9F90PPNF7CY	lcb_retail_user
\.


--
-- Data for Name: facility; Type: TABLE DATA; Schema: org; Owner: app
--

COPY org.facility (id, app_tenant_id, created_at, updated_at, organization_id, location_id, name, external_id) FROM stdin;
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: org; Owner: app
--

COPY org.location (id, app_tenant_id, created_at, updated_at, external_id, name, address1, address2, city, state, zip, lat, lon) FROM stdin;
\.


--
-- Data for Name: organization; Type: TABLE DATA; Schema: org; Owner: app
--

COPY org.organization (id, app_tenant_id, actual_app_tenant_id, created_at, updated_at, external_id, name, location_id, primary_contact_id) FROM stdin;
01DV777RNK2AESXHCS172G0140	01DV777RNK2JWTP3BG78MP4Q91	01DV777RNK2JWTP3BG78MP4Q91	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	G11111-org	Producer-1	\N	\N
01DV777RNKZMKWFB95T5XW624A	01DV777RNK8E477XZ1SN3PA9A3	01DV777RNK8E477XZ1SN3PA9A3	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	M11111-org	Processor-1	\N	\N
01DV777RNKW3FKFS3MN1NNQBJH	01DV777RNKCR50CYT023X0KZ8T	01DV777RNKCR50CYT023X0KZ8T	2019-12-04 01:08:51.507312+00	2019-12-04 01:08:51.507312+00	R11111-org	Retail-1	\N	\N
\.


--
-- Name: global_id_sequence; Type: SEQUENCE SET; Schema: shard_1; Owner: app
--

SELECT pg_catalog.setval('shard_1.global_id_sequence', 1, false);


--
-- Name: application application_key_key; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.application
    ADD CONSTRAINT application_key_key UNIQUE (key);


--
-- Name: license_type license_type_key_key; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT license_type_key_key UNIQUE (key);


--
-- Name: license_type_permission license_type_permission_key_key; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT license_type_permission_key_key UNIQUE (key);


--
-- Name: application pk_application; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.application
    ADD CONSTRAINT pk_application PRIMARY KEY (id);


--
-- Name: license pk_license; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT pk_license PRIMARY KEY (id);


--
-- Name: license_permission pk_license_permission; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT pk_license_permission PRIMARY KEY (id);


--
-- Name: license_type pk_license_type; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT pk_license_type PRIMARY KEY (id);


--
-- Name: license_type_permission pk_license_type_permission; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT pk_license_type_permission PRIMARY KEY (id);


--
-- Name: license uq_license_type_assigned_to; Type: CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT uq_license_type_assigned_to UNIQUE (assigned_to_app_user_id, license_type_id);


--
-- Name: app_tenant app_tenant_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.app_tenant
    ADD CONSTRAINT app_tenant_identifier_key UNIQUE (identifier);


--
-- Name: app_user app_user_recovery_email_key; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT app_user_recovery_email_key UNIQUE (recovery_email);


--
-- Name: app_user app_user_username_key; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT app_user_username_key UNIQUE (username);


--
-- Name: app_tenant pk_app_tenant; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.app_tenant
    ADD CONSTRAINT pk_app_tenant PRIMARY KEY (id);


--
-- Name: app_user pk_app_user; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT pk_app_user PRIMARY KEY (id);


--
-- Name: config_auth pk_config_auth; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.config_auth
    ADD CONSTRAINT pk_config_auth PRIMARY KEY (id);


--
-- Name: permission pk_permission; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.permission
    ADD CONSTRAINT pk_permission PRIMARY KEY (id);


--
-- Name: token pk_token; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.token
    ADD CONSTRAINT pk_token PRIMARY KEY (id);


--
-- Name: token token_app_user_id_key; Type: CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.token
    ADD CONSTRAINT token_app_user_id_key UNIQUE (app_user_id);


--
-- Name: conversion conversion_id_key; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.conversion
    ADD CONSTRAINT conversion_id_key UNIQUE (id);


--
-- Name: conversion_result conversion_result_id_key; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.conversion_result
    ADD CONSTRAINT conversion_result_id_key UNIQUE (id);


--
-- Name: inventory_lot inventory_lot_id_key; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT inventory_lot_id_key UNIQUE (id);


--
-- Name: lcb_license lcb_license_code_key; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.lcb_license
    ADD CONSTRAINT lcb_license_code_key UNIQUE (code);


--
-- Name: lcb_license_holder lcb_license_holder_lcb_license_id_key; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT lcb_license_holder_lcb_license_id_key UNIQUE (lcb_license_id);


--
-- Name: conversion pk_conversion; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.conversion
    ADD CONSTRAINT pk_conversion PRIMARY KEY (id);


--
-- Name: conversion_result pk_conversion_result; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.conversion_result
    ADD CONSTRAINT pk_conversion_result PRIMARY KEY (id);


--
-- Name: inventory_lot pk_inventory_lot; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT pk_inventory_lot PRIMARY KEY (id);


--
-- Name: lcb_license pk_lcb_license; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.lcb_license
    ADD CONSTRAINT pk_lcb_license PRIMARY KEY (id);


--
-- Name: lcb_license_holder pk_lcb_license_holder; Type: CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT pk_lcb_license_holder PRIMARY KEY (id);


--
-- Name: hist_inventory_lot hist_inventory_lot_id_key; Type: CONSTRAINT; Schema: lcb_hist; Owner: app
--

ALTER TABLE ONLY lcb_hist.hist_inventory_lot
    ADD CONSTRAINT hist_inventory_lot_id_key UNIQUE (id);


--
-- Name: conversion_rule conversion_rule_id_key; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT conversion_rule_id_key UNIQUE (id);


--
-- Name: inventory_lot_reporting_status fk_inventory_lot_reporting_status; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.inventory_lot_reporting_status
    ADD CONSTRAINT fk_inventory_lot_reporting_status PRIMARY KEY (id);


--
-- Name: transfer_status fk_transfer_status; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.transfer_status
    ADD CONSTRAINT fk_transfer_status PRIMARY KEY (id);


--
-- Name: inventory_lot_reporting_status inventory_lot_reporting_status_id_key; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.inventory_lot_reporting_status
    ADD CONSTRAINT inventory_lot_reporting_status_id_key UNIQUE (id);


--
-- Name: inventory_type inventory_type_id_key; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.inventory_type
    ADD CONSTRAINT inventory_type_id_key UNIQUE (id);


--
-- Name: inventory_type inventory_type_name_key; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.inventory_type
    ADD CONSTRAINT inventory_type_name_key UNIQUE (name);


--
-- Name: conversion_rule pk_conversion_rule; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT pk_conversion_rule PRIMARY KEY (id);


--
-- Name: inventory_type pk_inventory_type; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.inventory_type
    ADD CONSTRAINT pk_inventory_type PRIMARY KEY (id);


--
-- Name: transfer_status transfer_status_id_key; Type: CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.transfer_status
    ADD CONSTRAINT transfer_status_id_key UNIQUE (id);


--
-- Name: contact_app_user contact_app_user_app_user_id_key; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT contact_app_user_app_user_id_key UNIQUE (app_user_id);


--
-- Name: contact_app_user contact_app_user_contact_id_key; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT contact_app_user_contact_id_key UNIQUE (contact_id);


--
-- Name: contact_app_user contact_app_user_username_key; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT contact_app_user_username_key UNIQUE (username);


--
-- Name: organization organization_actual_app_tenant_id_key; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT organization_actual_app_tenant_id_key UNIQUE (actual_app_tenant_id);


--
-- Name: config_org pk_config_org; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.config_org
    ADD CONSTRAINT pk_config_org PRIMARY KEY (id);


--
-- Name: contact pk_contact; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT pk_contact PRIMARY KEY (id);


--
-- Name: contact_app_user pk_contact_app_user; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT pk_contact_app_user PRIMARY KEY (id);


--
-- Name: facility pk_facility; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT pk_facility PRIMARY KEY (id);


--
-- Name: location pk_location; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.location
    ADD CONSTRAINT pk_location PRIMARY KEY (id);


--
-- Name: organization pk_organization; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT pk_organization PRIMARY KEY (id);


--
-- Name: organization uq_app_tenant_external_id; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT uq_app_tenant_external_id UNIQUE (app_tenant_id, external_id);


--
-- Name: contact uq_contact_app_tenant_and_email; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT uq_contact_app_tenant_and_email UNIQUE (app_tenant_id, email);


--
-- Name: contact uq_contact_app_tenant_and_external_id; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT uq_contact_app_tenant_and_external_id UNIQUE (app_tenant_id, external_id);


--
-- Name: facility uq_facility_app_tenant_and_organization_and_name; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT uq_facility_app_tenant_and_organization_and_name UNIQUE (organization_id, name);


--
-- Name: location uq_location_app_tenant_and_external_id; Type: CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.location
    ADD CONSTRAINT uq_location_app_tenant_and_external_id UNIQUE (app_tenant_id, external_id);


--
-- Name: application tg_timestamp_update_application; Type: TRIGGER; Schema: app; Owner: app
--

CREATE TRIGGER tg_timestamp_update_application BEFORE INSERT OR UPDATE ON app.application FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_application();


--
-- Name: license tg_timestamp_update_license; Type: TRIGGER; Schema: app; Owner: app
--

CREATE TRIGGER tg_timestamp_update_license BEFORE INSERT OR UPDATE ON app.license FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_license();


--
-- Name: license_permission tg_timestamp_update_license_permission; Type: TRIGGER; Schema: app; Owner: app
--

CREATE TRIGGER tg_timestamp_update_license_permission BEFORE INSERT OR UPDATE ON app.license_permission FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_license_permission();


--
-- Name: license_type tg_timestamp_update_license_type; Type: TRIGGER; Schema: app; Owner: app
--

CREATE TRIGGER tg_timestamp_update_license_type BEFORE INSERT OR UPDATE ON app.license_type FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_license_type();


--
-- Name: license_type_permission tg_timestamp_update_license_type_permission; Type: TRIGGER; Schema: app; Owner: app
--

CREATE TRIGGER tg_timestamp_update_license_type_permission BEFORE INSERT OR UPDATE ON app.license_type_permission FOR EACH ROW EXECUTE PROCEDURE app.fn_timestamp_update_license_type_permission();


--
-- Name: app_tenant tg_timestamp_update_app_tenant; Type: TRIGGER; Schema: auth; Owner: app
--

CREATE TRIGGER tg_timestamp_update_app_tenant BEFORE INSERT OR UPDATE ON auth.app_tenant FOR EACH ROW EXECUTE PROCEDURE auth.fn_timestamp_update_app_tenant();


--
-- Name: app_user tg_timestamp_update_app_user; Type: TRIGGER; Schema: auth; Owner: app
--

CREATE TRIGGER tg_timestamp_update_app_user BEFORE INSERT OR UPDATE ON auth.app_user FOR EACH ROW EXECUTE PROCEDURE auth.fn_timestamp_update_app_user();


--
-- Name: permission tg_timestamp_update_permission; Type: TRIGGER; Schema: auth; Owner: app
--

CREATE TRIGGER tg_timestamp_update_permission BEFORE INSERT OR UPDATE ON auth.permission FOR EACH ROW EXECUTE PROCEDURE auth.fn_timestamp_update_permission();


--
-- Name: conversion tg_timestamp_update_conversion; Type: TRIGGER; Schema: lcb; Owner: app
--

CREATE TRIGGER tg_timestamp_update_conversion BEFORE INSERT OR UPDATE ON lcb.conversion FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_conversion();


--
-- Name: conversion_result tg_timestamp_update_conversion_result; Type: TRIGGER; Schema: lcb; Owner: app
--

CREATE TRIGGER tg_timestamp_update_conversion_result BEFORE INSERT OR UPDATE ON lcb.conversion_result FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_conversion_result();


--
-- Name: inventory_lot tg_timestamp_update_inventory_lot; Type: TRIGGER; Schema: lcb; Owner: app
--

CREATE TRIGGER tg_timestamp_update_inventory_lot BEFORE INSERT OR UPDATE ON lcb.inventory_lot FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_inventory_lot();


--
-- Name: lcb_license tg_timestamp_update_lcb_license; Type: TRIGGER; Schema: lcb; Owner: app
--

CREATE TRIGGER tg_timestamp_update_lcb_license BEFORE INSERT OR UPDATE ON lcb.lcb_license FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_lcb_license();


--
-- Name: lcb_license_holder tg_timestamp_update_lcb_license_holder; Type: TRIGGER; Schema: lcb; Owner: app
--

CREATE TRIGGER tg_timestamp_update_lcb_license_holder BEFORE INSERT OR UPDATE ON lcb.lcb_license_holder FOR EACH ROW EXECUTE PROCEDURE lcb.fn_timestamp_update_lcb_license_holder();


--
-- Name: contact tg_timestamp_update_contact; Type: TRIGGER; Schema: org; Owner: app
--

CREATE TRIGGER tg_timestamp_update_contact BEFORE INSERT OR UPDATE ON org.contact FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_contact();


--
-- Name: contact_app_user tg_timestamp_update_contact_app_user; Type: TRIGGER; Schema: org; Owner: app
--

CREATE TRIGGER tg_timestamp_update_contact_app_user BEFORE INSERT OR UPDATE ON org.contact_app_user FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_contact_app_user();


--
-- Name: facility tg_timestamp_update_facility; Type: TRIGGER; Schema: org; Owner: app
--

CREATE TRIGGER tg_timestamp_update_facility BEFORE INSERT OR UPDATE ON org.facility FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_facility();


--
-- Name: location tg_timestamp_update_location; Type: TRIGGER; Schema: org; Owner: app
--

CREATE TRIGGER tg_timestamp_update_location BEFORE INSERT OR UPDATE ON org.location FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_location();


--
-- Name: organization tg_timestamp_update_organization; Type: TRIGGER; Schema: org; Owner: app
--

CREATE TRIGGER tg_timestamp_update_organization BEFORE INSERT OR UPDATE ON org.organization FOR EACH ROW EXECUTE PROCEDURE org.fn_timestamp_update_organization();


--
-- Name: license fk_license_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: license fk_license_assigned_to_app_user; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_assigned_to_app_user FOREIGN KEY (assigned_to_app_user_id) REFERENCES auth.app_user(id);


--
-- Name: license fk_license_license_type; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_license_type FOREIGN KEY (license_type_id) REFERENCES app.license_type(id);


--
-- Name: license fk_license_permission_app_tenant; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license
    ADD CONSTRAINT fk_license_permission_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: license_permission fk_license_permission_license; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT fk_license_permission_license FOREIGN KEY (license_id) REFERENCES app.license(id);


--
-- Name: license_permission fk_license_permission_permission; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_permission
    ADD CONSTRAINT fk_license_permission_permission FOREIGN KEY (permission_id) REFERENCES auth.permission(id);


--
-- Name: license_type fk_license_type_application; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_type
    ADD CONSTRAINT fk_license_type_application FOREIGN KEY (application_id) REFERENCES app.application(id);


--
-- Name: license_type_permission fk_license_type_permission_license_type; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT fk_license_type_permission_license_type FOREIGN KEY (license_type_id) REFERENCES app.license_type(id);


--
-- Name: license_type_permission fk_license_type_permission_permission; Type: FK CONSTRAINT; Schema: app; Owner: app
--

ALTER TABLE ONLY app.license_type_permission
    ADD CONSTRAINT fk_license_type_permission_permission FOREIGN KEY (permission_id) REFERENCES auth.permission(id);


--
-- Name: app_user fk_app_user_app_tenant; Type: FK CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.app_user
    ADD CONSTRAINT fk_app_user_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: token fk_token_user; Type: FK CONSTRAINT; Schema: auth; Owner: app
--

ALTER TABLE ONLY auth.token
    ADD CONSTRAINT fk_token_user FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id);


--
-- Name: conversion fk_conversion_app_tenant; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.conversion
    ADD CONSTRAINT fk_conversion_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: conversion_result fk_conversion_app_tenant; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.conversion_result
    ADD CONSTRAINT fk_conversion_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: conversion fk_conversion_from_inventory_lot; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.conversion
    ADD CONSTRAINT fk_conversion_from_inventory_lot FOREIGN KEY (from_inventory_lot_id) REFERENCES lcb.inventory_lot(id);


--
-- Name: conversion_result fk_conversion_result_to_inventory_lot; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.conversion_result
    ADD CONSTRAINT fk_conversion_result_to_inventory_lot FOREIGN KEY (inventory_lot_id) REFERENCES lcb.inventory_lot(id);


--
-- Name: inventory_lot fk_inventory_lot_app_tenant_id; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: inventory_lot fk_inventory_lot_inventory_type; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_inventory_type FOREIGN KEY (inventory_type) REFERENCES lcb_ref.inventory_type(id);


--
-- Name: inventory_lot fk_inventory_lot_lcb_license_holder; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_lcb_license_holder FOREIGN KEY (lcb_license_holder_id) REFERENCES lcb.lcb_license_holder(id);


--
-- Name: inventory_lot fk_inventory_lot_reporting_status; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.inventory_lot
    ADD CONSTRAINT fk_inventory_lot_reporting_status FOREIGN KEY (reporting_status) REFERENCES lcb_ref.inventory_lot_reporting_status(id);


--
-- Name: lcb_license_holder fk_lcb_license_holder_app_tenant_id; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: lcb_license_holder fk_lcb_license_holder_license; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_license FOREIGN KEY (lcb_license_id) REFERENCES lcb.lcb_license(id);


--
-- Name: lcb_license_holder fk_lcb_license_holder_organization; Type: FK CONSTRAINT; Schema: lcb; Owner: app
--

ALTER TABLE ONLY lcb.lcb_license_holder
    ADD CONSTRAINT fk_lcb_license_holder_organization FOREIGN KEY (organization_id) REFERENCES org.organization(id);


--
-- Name: hist_inventory_lot fk_hist_inventory_lot_app_tenant_id; Type: FK CONSTRAINT; Schema: lcb_hist; Owner: app
--

ALTER TABLE ONLY lcb_hist.hist_inventory_lot
    ADD CONSTRAINT fk_hist_inventory_lot_app_tenant_id FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: hist_inventory_lot fk_hist_inventory_lot_inventory_lot; Type: FK CONSTRAINT; Schema: lcb_hist; Owner: app
--

ALTER TABLE ONLY lcb_hist.hist_inventory_lot
    ADD CONSTRAINT fk_hist_inventory_lot_inventory_lot FOREIGN KEY (inventory_lot_id) REFERENCES lcb.inventory_lot(id);


--
-- Name: conversion_rule fk_conversion_rule_from; Type: FK CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT fk_conversion_rule_from FOREIGN KEY (from_type_id) REFERENCES lcb_ref.inventory_type(id);


--
-- Name: conversion_rule fk_conversion_rule_to; Type: FK CONSTRAINT; Schema: lcb_ref; Owner: app
--

ALTER TABLE ONLY lcb_ref.conversion_rule
    ADD CONSTRAINT fk_conversion_rule_to FOREIGN KEY (to_inventory_type_id) REFERENCES lcb_ref.inventory_type(id);


--
-- Name: contact fk_contact_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT fk_contact_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: contact_app_user fk_contact_app_user_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT fk_contact_app_user_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: contact_app_user fk_contact_app_user_app_user; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT fk_contact_app_user_app_user FOREIGN KEY (app_user_id) REFERENCES auth.app_user(id);


--
-- Name: contact_app_user fk_contact_app_user_contact; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact_app_user
    ADD CONSTRAINT fk_contact_app_user_contact FOREIGN KEY (contact_id) REFERENCES org.contact(id);


--
-- Name: contact fk_contact_location; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT fk_contact_location FOREIGN KEY (location_id) REFERENCES org.location(id);


--
-- Name: contact fk_contact_organization; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.contact
    ADD CONSTRAINT fk_contact_organization FOREIGN KEY (organization_id) REFERENCES org.organization(id);


--
-- Name: facility fk_facility_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT fk_facility_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: facility fk_facility_location; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT fk_facility_location FOREIGN KEY (location_id) REFERENCES org.location(id);


--
-- Name: facility fk_facility_organization; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.facility
    ADD CONSTRAINT fk_facility_organization FOREIGN KEY (organization_id) REFERENCES org.organization(id);


--
-- Name: location fk_location_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.location
    ADD CONSTRAINT fk_location_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: organization fk_organization_actual_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT fk_organization_actual_app_tenant FOREIGN KEY (actual_app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: organization fk_organization_app_tenant; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT fk_organization_app_tenant FOREIGN KEY (app_tenant_id) REFERENCES auth.app_tenant(id);


--
-- Name: organization fk_organization_location; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT fk_organization_location FOREIGN KEY (location_id) REFERENCES org.location(id);


--
-- Name: organization fk_organization_primary_contact; Type: FK CONSTRAINT; Schema: org; Owner: app
--

ALTER TABLE ONLY org.organization
    ADD CONSTRAINT fk_organization_primary_contact FOREIGN KEY (primary_contact_id) REFERENCES org.contact(id);


--
-- Name: license; Type: ROW SECURITY; Schema: app; Owner: app
--

ALTER TABLE app.license ENABLE ROW LEVEL SECURITY;

--
-- Name: license_permission; Type: ROW SECURITY; Schema: app; Owner: app
--

ALTER TABLE app.license_permission ENABLE ROW LEVEL SECURITY;

--
-- Name: license rls_app_user_default_app_license; Type: POLICY; Schema: app; Owner: app
--

CREATE POLICY rls_app_user_default_app_license ON app.license TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: license_permission rls_app_user_default_app_license_permission; Type: POLICY; Schema: app; Owner: app
--

CREATE POLICY rls_app_user_default_app_license_permission ON app.license_permission TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: app_tenant; Type: ROW SECURITY; Schema: auth; Owner: app
--

ALTER TABLE auth.app_tenant ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user; Type: ROW SECURITY; Schema: auth; Owner: app
--

ALTER TABLE auth.app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: app_user rls_app_user_default_auth_app_user; Type: POLICY; Schema: auth; Owner: app
--

CREATE POLICY rls_app_user_default_auth_app_user ON auth.app_user TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: app_tenant rls_auth_app_tenant_auth_app_tenant; Type: POLICY; Schema: auth; Owner: app
--

CREATE POLICY rls_auth_app_tenant_auth_app_tenant ON auth.app_tenant TO app_user USING ((auth_fn.app_user_has_access(id) = true));


--
-- Name: inventory_lot; Type: ROW SECURITY; Schema: lcb; Owner: app
--

ALTER TABLE lcb.inventory_lot ENABLE ROW LEVEL SECURITY;

--
-- Name: inventory_lot rls_app_user_default_lcb_inventory_lot; Type: POLICY; Schema: lcb; Owner: app
--

CREATE POLICY rls_app_user_default_lcb_inventory_lot ON lcb.inventory_lot TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: hist_inventory_lot; Type: ROW SECURITY; Schema: lcb_hist; Owner: app
--

ALTER TABLE lcb_hist.hist_inventory_lot ENABLE ROW LEVEL SECURITY;

--
-- Name: hist_inventory_lot rls_app_user_default_org_contact_app_user; Type: POLICY; Schema: lcb_hist; Owner: app
--

CREATE POLICY rls_app_user_default_org_contact_app_user ON lcb_hist.hist_inventory_lot TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: contact; Type: ROW SECURITY; Schema: org; Owner: app
--

ALTER TABLE org.contact ENABLE ROW LEVEL SECURITY;

--
-- Name: contact_app_user; Type: ROW SECURITY; Schema: org; Owner: app
--

ALTER TABLE org.contact_app_user ENABLE ROW LEVEL SECURITY;

--
-- Name: facility; Type: ROW SECURITY; Schema: org; Owner: app
--

ALTER TABLE org.facility ENABLE ROW LEVEL SECURITY;

--
-- Name: location; Type: ROW SECURITY; Schema: org; Owner: app
--

ALTER TABLE org.location ENABLE ROW LEVEL SECURITY;

--
-- Name: organization; Type: ROW SECURITY; Schema: org; Owner: app
--

ALTER TABLE org.organization ENABLE ROW LEVEL SECURITY;

--
-- Name: contact rls_app_user_default_org_contact; Type: POLICY; Schema: org; Owner: app
--

CREATE POLICY rls_app_user_default_org_contact ON org.contact TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: contact_app_user rls_app_user_default_org_contact_app_user; Type: POLICY; Schema: org; Owner: app
--

CREATE POLICY rls_app_user_default_org_contact_app_user ON org.contact_app_user TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: facility rls_app_user_default_org_facility; Type: POLICY; Schema: org; Owner: app
--

CREATE POLICY rls_app_user_default_org_facility ON org.facility TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: location rls_app_user_default_org_location; Type: POLICY; Schema: org; Owner: app
--

CREATE POLICY rls_app_user_default_org_location ON org.location TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: organization rls_app_user_default_org_organization; Type: POLICY; Schema: org; Owner: app
--

CREATE POLICY rls_app_user_default_org_organization ON org.organization TO app_user USING ((auth_fn.app_user_has_access(app_tenant_id) = true));


--
-- Name: SCHEMA app; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA app TO app_user;


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA auth TO app_user;
GRANT USAGE ON SCHEMA auth TO app_anonymous;


--
-- Name: SCHEMA auth_fn; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA auth_fn TO app_user;
GRANT USAGE ON SCHEMA auth_fn TO app_anonymous;


--
-- Name: SCHEMA lcb; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA lcb TO app_user;


--
-- Name: SCHEMA lcb_fn; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA lcb_fn TO app_user;


--
-- Name: SCHEMA lcb_hist; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA lcb_hist TO app_user;


--
-- Name: SCHEMA lcb_ref; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA lcb_ref TO app_user;


--
-- Name: SCHEMA org; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA org TO app_user;


--
-- Name: SCHEMA org_fn; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA org_fn TO app_user;


--
-- Name: SCHEMA shard_1; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA shard_1 TO app_user;


--
-- Name: SCHEMA util_fn; Type: ACL; Schema: -; Owner: app
--

GRANT USAGE ON SCHEMA util_fn TO app_demon;
GRANT USAGE ON SCHEMA util_fn TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_application(); Type: ACL; Schema: app; Owner: app
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_application() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_application() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_license(); Type: ACL; Schema: app; Owner: app
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_license() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_license() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_license_permission(); Type: ACL; Schema: app; Owner: app
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_license_permission() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_license_permission() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_license_type(); Type: ACL; Schema: app; Owner: app
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_license_type() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_license_type() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_license_type_permission(); Type: ACL; Schema: app; Owner: app
--

REVOKE ALL ON FUNCTION app.fn_timestamp_update_license_type_permission() FROM PUBLIC;
GRANT ALL ON FUNCTION app.fn_timestamp_update_license_type_permission() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_app_tenant(); Type: ACL; Schema: auth; Owner: app
--

REVOKE ALL ON FUNCTION auth.fn_timestamp_update_app_tenant() FROM PUBLIC;
GRANT ALL ON FUNCTION auth.fn_timestamp_update_app_tenant() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_app_user(); Type: ACL; Schema: auth; Owner: app
--

REVOKE ALL ON FUNCTION auth.fn_timestamp_update_app_user() FROM PUBLIC;
GRANT ALL ON FUNCTION auth.fn_timestamp_update_app_user() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_permission(); Type: ACL; Schema: auth; Owner: app
--

REVOKE ALL ON FUNCTION auth.fn_timestamp_update_permission() FROM PUBLIC;
GRANT ALL ON FUNCTION auth.fn_timestamp_update_permission() TO app_user;


--
-- Name: FUNCTION app_user_has_access(_app_tenant_id text, _permission_key text); Type: ACL; Schema: auth_fn; Owner: app
--

REVOKE ALL ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text) TO app_user;


--
-- Name: FUNCTION authenticate(_username text, _password text); Type: ACL; Schema: auth_fn; Owner: app
--

REVOKE ALL ON FUNCTION auth_fn.authenticate(_username text, _password text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.authenticate(_username text, _password text) TO app_anonymous;


--
-- Name: TABLE app_tenant; Type: ACL; Schema: auth; Owner: app
--

GRANT INSERT,DELETE,UPDATE ON TABLE auth.app_tenant TO app_super_admin;
GRANT SELECT ON TABLE auth.app_tenant TO app_user;


--
-- Name: FUNCTION build_app_tenant(_name text, _identifier text); Type: ACL; Schema: auth_fn; Owner: app
--

REVOKE ALL ON FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.build_app_tenant(_name text, _identifier text) TO app_user;


--
-- Name: TABLE app_user; Type: ACL; Schema: auth; Owner: app
--

GRANT INSERT,DELETE ON TABLE auth.app_user TO app_admin;
GRANT SELECT,UPDATE ON TABLE auth.app_user TO app_user;


--
-- Name: FUNCTION build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key); Type: ACL; Schema: auth_fn; Owner: app
--

REVOKE ALL ON FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.build_app_user(_app_tenant_id text, _username text, _password text, _recovery_email text, _permission_key auth.permission_key) TO app_user;


--
-- Name: FUNCTION current_app_tenant_id(); Type: ACL; Schema: auth_fn; Owner: app
--

REVOKE ALL ON FUNCTION auth_fn.current_app_tenant_id() FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.current_app_tenant_id() TO app_user;


--
-- Name: FUNCTION current_app_user(); Type: ACL; Schema: auth_fn; Owner: app
--

REVOKE ALL ON FUNCTION auth_fn.current_app_user() FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.current_app_user() TO app_user;


--
-- Name: FUNCTION current_app_user_id(); Type: ACL; Schema: auth_fn; Owner: app
--

REVOKE ALL ON FUNCTION auth_fn.current_app_user_id() FROM PUBLIC;
GRANT ALL ON FUNCTION auth_fn.current_app_user_id() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_inventory_lot(); Type: ACL; Schema: lcb; Owner: app
--

REVOKE ALL ON FUNCTION lcb.fn_timestamp_update_inventory_lot() FROM PUBLIC;
GRANT ALL ON FUNCTION lcb.fn_timestamp_update_inventory_lot() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_lcb_license(); Type: ACL; Schema: lcb; Owner: app
--

REVOKE ALL ON FUNCTION lcb.fn_timestamp_update_lcb_license() FROM PUBLIC;
GRANT ALL ON FUNCTION lcb.fn_timestamp_update_lcb_license() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_lcb_license_holder(); Type: ACL; Schema: lcb; Owner: app
--

REVOKE ALL ON FUNCTION lcb.fn_timestamp_update_lcb_license_holder() FROM PUBLIC;
GRANT ALL ON FUNCTION lcb.fn_timestamp_update_lcb_license_holder() TO app_user;


--
-- Name: TABLE inventory_lot; Type: ACL; Schema: lcb; Owner: app
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE lcb.inventory_lot TO app_user;


--
-- Name: FUNCTION provision_inventory_lot_ids(_inventory_type text, _number_requested integer); Type: ACL; Schema: lcb_fn; Owner: app
--

REVOKE ALL ON FUNCTION lcb_fn.provision_inventory_lot_ids(_inventory_type text, _number_requested integer) FROM PUBLIC;
GRANT ALL ON FUNCTION lcb_fn.provision_inventory_lot_ids(_inventory_type text, _number_requested integer) TO app_user;


--
-- Name: FUNCTION report_inventory_lot(_input lcb_fn.report_inventory_lot_input[]); Type: ACL; Schema: lcb_fn; Owner: app
--

REVOKE ALL ON FUNCTION lcb_fn.report_inventory_lot(_input lcb_fn.report_inventory_lot_input[]) FROM PUBLIC;
GRANT ALL ON FUNCTION lcb_fn.report_inventory_lot(_input lcb_fn.report_inventory_lot_input[]) TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_contact(); Type: ACL; Schema: org; Owner: app
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_contact() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_contact() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_contact_app_user(); Type: ACL; Schema: org; Owner: app
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_contact_app_user() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_contact_app_user() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_facility(); Type: ACL; Schema: org; Owner: app
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_facility() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_facility() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_location(); Type: ACL; Schema: org; Owner: app
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_location() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_location() TO app_user;


--
-- Name: FUNCTION fn_timestamp_update_organization(); Type: ACL; Schema: org; Owner: app
--

REVOKE ALL ON FUNCTION org.fn_timestamp_update_organization() FROM PUBLIC;
GRANT ALL ON FUNCTION org.fn_timestamp_update_organization() TO app_user;


--
-- Name: TABLE contact; Type: ACL; Schema: org; Owner: app
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.contact TO app_user;


--
-- Name: FUNCTION build_contact(_first_name text, _last_name text, _email text, _cell_phone text, _office_phone text, _title text, _nickname text, _external_id text, _organization_id text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.build_contact(_first_name text, _last_name text, _email text, _cell_phone text, _office_phone text, _title text, _nickname text, _external_id text, _organization_id text) FROM PUBLIC;


--
-- Name: FUNCTION build_contact_location(_contact_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.build_contact_location(_contact_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: TABLE facility; Type: ACL; Schema: org; Owner: app
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.facility TO app_user;


--
-- Name: FUNCTION build_facility(_organization_id text, _name text, _external_id text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.build_facility(_organization_id text, _name text, _external_id text) FROM PUBLIC;


--
-- Name: FUNCTION build_facility_location(_facility_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.build_facility_location(_facility_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: TABLE location; Type: ACL; Schema: org; Owner: app
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.location TO app_user;


--
-- Name: FUNCTION build_location(_name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.build_location(_name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: TABLE organization; Type: ACL; Schema: org; Owner: app
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.organization TO app_user;


--
-- Name: FUNCTION build_organization(_name text, _external_id text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.build_organization(_name text, _external_id text) FROM PUBLIC;


--
-- Name: FUNCTION build_organization_location(_organization_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.build_organization_location(_organization_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: FUNCTION build_tenant_organization(_name text, _identifier text, _primary_contact_email text, _primary_contact_first_name text, _primary_contact_last_name text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.build_tenant_organization(_name text, _identifier text, _primary_contact_email text, _primary_contact_first_name text, _primary_contact_last_name text) FROM PUBLIC;


--
-- Name: FUNCTION current_app_user_contact(); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.current_app_user_contact() FROM PUBLIC;
GRANT ALL ON FUNCTION org_fn.current_app_user_contact() TO app_user;


--
-- Name: FUNCTION modify_location(_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text); Type: ACL; Schema: org_fn; Owner: app
--

REVOKE ALL ON FUNCTION org_fn.modify_location(_id text, _name text, _address1 text, _address2 text, _city text, _state text, _zip text, _lat text, _lon text) FROM PUBLIC;


--
-- Name: FUNCTION trim_text(_input text); Type: ACL; Schema: util_fn; Owner: app
--

REVOKE ALL ON FUNCTION util_fn.trim_text(_input text) FROM PUBLIC;
GRANT ALL ON FUNCTION util_fn.trim_text(_input text) TO app_anonymous;


--
-- Name: TABLE application; Type: ACL; Schema: app; Owner: app
--

GRANT INSERT,DELETE,UPDATE ON TABLE app.application TO app_super_admin;
GRANT SELECT ON TABLE app.application TO app_user;


--
-- Name: TABLE license; Type: ACL; Schema: app; Owner: app
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE app.license TO app_user;


--
-- Name: TABLE license_permission; Type: ACL; Schema: app; Owner: app
--

GRANT INSERT,DELETE,UPDATE ON TABLE app.license_permission TO app_admin;
GRANT SELECT ON TABLE app.license_permission TO app_user;


--
-- Name: TABLE license_type; Type: ACL; Schema: app; Owner: app
--

GRANT INSERT,DELETE,UPDATE ON TABLE app.license_type TO app_super_admin;
GRANT SELECT ON TABLE app.license_type TO app_user;


--
-- Name: TABLE license_type_permission; Type: ACL; Schema: app; Owner: app
--

GRANT INSERT,DELETE,UPDATE ON TABLE app.license_type_permission TO app_super_admin;
GRANT SELECT ON TABLE app.license_type_permission TO app_user;


--
-- Name: TABLE permission; Type: ACL; Schema: auth; Owner: app
--

GRANT INSERT,DELETE,UPDATE ON TABLE auth.permission TO app_super_admin;
GRANT SELECT ON TABLE auth.permission TO app_user;


--
-- Name: TABLE lcb_license; Type: ACL; Schema: lcb; Owner: app
--

GRANT INSERT,DELETE,UPDATE ON TABLE lcb.lcb_license TO app_super_admin;
GRANT SELECT ON TABLE lcb.lcb_license TO app_user;


--
-- Name: TABLE lcb_license_holder; Type: ACL; Schema: lcb; Owner: app
--

GRANT INSERT,DELETE,UPDATE ON TABLE lcb.lcb_license_holder TO app_super_admin;
GRANT SELECT ON TABLE lcb.lcb_license_holder TO app_user;


--
-- Name: TABLE hist_inventory_lot; Type: ACL; Schema: lcb_hist; Owner: app
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE lcb_hist.hist_inventory_lot TO app_user;


--
-- Name: TABLE inventory_lot_reporting_status; Type: ACL; Schema: lcb_ref; Owner: app
--

GRANT DELETE ON TABLE lcb_ref.inventory_lot_reporting_status TO app_super_admin;
GRANT SELECT ON TABLE lcb_ref.inventory_lot_reporting_status TO app_user;


--
-- Name: COLUMN inventory_lot_reporting_status.id; Type: ACL; Schema: lcb_ref; Owner: app
--

GRANT INSERT(id),UPDATE(id) ON TABLE lcb_ref.inventory_lot_reporting_status TO app_super_admin;


--
-- Name: TABLE inventory_type; Type: ACL; Schema: lcb_ref; Owner: app
--

GRANT DELETE ON TABLE lcb_ref.inventory_type TO app_super_admin;
GRANT SELECT ON TABLE lcb_ref.inventory_type TO app_user;


--
-- Name: COLUMN inventory_type.id; Type: ACL; Schema: lcb_ref; Owner: app
--

GRANT INSERT(id),UPDATE(id) ON TABLE lcb_ref.inventory_type TO app_super_admin;


--
-- Name: COLUMN inventory_type.name; Type: ACL; Schema: lcb_ref; Owner: app
--

GRANT INSERT(name),UPDATE(name) ON TABLE lcb_ref.inventory_type TO app_super_admin;


--
-- Name: COLUMN inventory_type.description; Type: ACL; Schema: lcb_ref; Owner: app
--

GRANT INSERT(description),UPDATE(description) ON TABLE lcb_ref.inventory_type TO app_super_admin;


--
-- Name: TABLE contact_app_user; Type: ACL; Schema: org; Owner: app
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE org.contact_app_user TO app_user;


--
-- Name: SEQUENCE global_id_sequence; Type: ACL; Schema: shard_1; Owner: app
--

GRANT USAGE ON SEQUENCE shard_1.global_id_sequence TO app_user;


--
-- PostgreSQL database dump complete
--

