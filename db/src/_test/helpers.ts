export const logger = {
  info: console.log
}

import { Pool } from "pg";

const pools: {[key: string]: any} = {};

const testDatabaseUrl = process.env.TEST_DATABASE_URL || 'postgres://app:1234@0.0.0.0/lcb'

// Make sure we release those pgPools so that our tests exit!
afterAll(() => {
  const keys = Object.keys(pools);
  return Promise.all(
    keys.map(async key => {
      try {
        const pool = pools[key];
        delete pools[key];
        await pool.end();
      } catch (e) {
        console.error("Failed to release connection!");
        console.error(e);
      }
    })
  );
});

const withDbFromUrl = async (url: string, fn: Function) => {
  if (!pools[url]) {
    pools[url] = new Pool({ connectionString: url });
  }
  const pool = pools[url];
  const client = await pool.connect();
  await client.query("BEGIN ISOLATION LEVEL SERIALIZABLE;");

  try {
    await fn(client);
  } catch (e) {
    // Error logging can be helpful:
    if (typeof e.code === "string" && e.code.match(/^[0-9A-Z]{5}$/)) {
      console.error([e.message, e.code, e.detail, e.hint, e.where].join("\n"));
    }
    throw e;
  } finally {
    await client.query("ROLLBACK;");
    await client.query("RESET ALL;"); // Shouldn't be necessary, but just in case...
    await client.release();
  }
};

export const withRootDb = (fn: Function) =>
  withDbFromUrl(testDatabaseUrl, fn);


const getUserInfo = async (client: Pool, username: string) => {
  const result = await client.query(
    "select * from auth.app_user where username = $1",
    [username]
  );
  return result.rows[0]
}

export const becomeUser = async (pgPool: Pool, username: string) => {
  const userInfo = await getUserInfo(pgPool, username)
  console.log('userInfo', userInfo);
  await pgPool.query(`set jwt.claims.app_user_id = '${userInfo.id}';`)
  await pgPool.query(`set jwt.claims.app_tenant_id = '${userInfo.app_tenant_id}';`)
  await pgPool.query(`set jwt.claims.role = '${userInfo.permission_key  }';`)
  return
}
