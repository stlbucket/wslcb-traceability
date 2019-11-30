import { withRootDb, becomeUser} from "./helpers";
import { Pool } from "pg";
import {inspect} from 'util'

const setupQuery = `
`

test("process events", (done) =>
  withRootDb(async (pgPool: Pool) => {
    try {
      const query = 'select * from lcb.lcb_license;'
      console.log('query:', query)

      const result = (await pgPool.query(
        query
      )).rows

      expect(result.length > 0).toEqual(true)

      done()
    } catch (e) {
      console.log(e)
      done(e)
    }
  })
);


