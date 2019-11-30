import { withRootDb, becomeUser} from "./helpers";
import { Pool } from "pg";
import {inspect} from 'util'

const setupQuery = `
CREATE OR REPLACE FUNCTION auth_fn.app_user_has_access(_app_tenant_id text, _permission_key text DEFAULT ''::text)
 RETURNS boolean
 LANGUAGE plpgsql
 STRICT SECURITY DEFINER
AS $function$
  DECLARE
    _app_user auth.app_user;
    _retval boolean;
  BEGIN
    _app_user := (SELECT auth_fn.current_app_user());
raise exception 'dirty jessica';
    _retval := (_app_user.permission_key IN ('SuperAdmin')) OR (_app_user.app_tenant_id = _app_tenant_id);

    IF _permission_key = 'fail' THEN
      _retval := false;
    END IF;

    RETURN _retval;
  end;
  $function$
;
`

test("obtain ids", (done) =>
  withRootDb(async (pgPool: Pool) => {
    try {
      // await pgPool.query(setupQuery)
      await becomeUser(pgPool, 'lcb_producer_admin')

      console.log('heyo')
      // const blah = ( await pgPool.query(`show jwt.claims.app_tenant_id;`)).rows
      // console.log('blah', blah)

      const organizations = (await pgPool.query('select * from org.organization;')).rows

      console.log('orgs', organizations.length)

      done()
    } catch (e) {
      console.log(e)
      done(e)
    }
  })
);


