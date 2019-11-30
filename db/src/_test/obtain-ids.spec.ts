import { withRootDb, becomeUser} from "./helpers";
import { Pool } from "pg";
import {inspect} from 'util'

const setupQuery = `
`

test("obtain ids", (done) =>
  withRootDb(async (pgPool: Pool) => {
    try {
      // await pgPool.query(setupQuery)
      await becomeUser(pgPool, 'lcb_producer_admin')

      // console.log('heyo')
      const blah = ( await pgPool.query(`show jwt.claims.app_tenant_id;`)).rows
      console.log('blah', blah)

      const organizations = (await pgPool.query(`select * from org.organization;`)).rows

      console.log('orgs', organizations.map(o=>`${o.id} - ${o.app_tenant_id} - ${o.name}`))

      done()
    } catch (e) {
      console.log(e)
      done(e)
    }
  })
);


