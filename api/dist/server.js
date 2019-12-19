"use strict";

var _express = _interopRequireDefault(require("express"));

var _postgraphile = require("postgraphile");

var _mutationHooks = _interopRequireDefault(require("./mutation-hooks"));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// POSTGRAPHILE
// import pgdbi from "@graphile-contrib/pgdbi";
const app = (0, _express.default)(); // const pluginHook = makePluginHook([pgdbi]);
// app.use(express.static("dist"));
// app.get("/", (req, res) => {
//   res.redirect("/dist/index.html");
// });

const schema = (0, _postgraphile.postgraphile)(process.env.POSTGRES_CONNECTION, process.env.SCHEMATA_TO_GRAPHQL.split(","), {
  // pluginHook,
  enableCors: process.env.ENABLE_CORS === 'true',
  // enablePgdbi: process.env.ENABLE_PGDBI === 'true',
  pgDefaultRole: process.env.PG_DEFAULT_ROLE,
  jwtPgTypeIdentifier: process.env.JWT_PG_TYPE_IDENTIFIER,
  jwtSecret: process.env.JWT_SECRET,
  disableDefaultMutations: true,
  //process.env.DISABLE_DEFAULT_MUTATIONS === 'true',
  appendPlugins: _mutationHooks.default,
  dynamicJson: true,
  disableQueryLog: process.env.DISABLE_QUERY_LOG !== "false",
  watchPg: true,
  extendedErrors: ["detail", "errcode"],
  graphiql: process.env.GRAPHIQL === "true",
  enhanceGraphiql: process.env.ENHANCE_GRAPHIQL === "true",
  allowExplain: process.env.ALLOW_EXPLAIN === "true",
  graphileBuildOptions: {
    showErrorStack: true,
    connectionFilterComputedColumns: false,
    connectionFilterSetofFunctions: false,
    connectionFilterLists: false,
    connectionFilterOperatorNames: {
      equalTo: "eq",
      notEqualTo: "ne",
      lessThan: "lt",
      lessThanOrEqualTo: "lte",
      greaterThan: "gt",
      greaterThanOrEqualTo: "gte",
      in: "in",
      notIn: "nin",
      contains: "cont",
      notContains: "ncont",
      containsInsensitive: "conti",
      notContainsInsensitive: "nconti",
      startsWith: "starts",
      notStartsWith: "nstarts",
      startsWithInsensitive: "startsi",
      notStartsWithInsensitive: "nstartsi",
      endsWith: "ends",
      notEndsWith: "nends",
      endsWithInsensitive: "endsi",
      notEndsWithInsensitive: "nendsi",
      like: "like",
      notLike: "nlike",
      likeInsensitive: "ilike",
      notLikeInsensitive: "nilike"
    }
  } // exportGqlSchemaPath: './schema/soro.schema',
  // exportJsonSchemaPath: './schema/soro_schema.json'

});
app.use(schema);
const server = app.listen(process.env.PORT);
/*
 * When being used in nodemon, SIGUSR2 is issued to restart the process. We
 * listen for this and shut down cleanly.
 */

process.once("SIGUSR2", function () {
  server.close();
  const t = setTimeout(function () {
    process.kill(process.pid, "SIGUSR2");
  }, 200); // Don't prevent clean shutdown:

  t.unref();
});
console.log(`listening on ${process.env.PORT}`);
console.log(`http://localhost:${process.env.PORT}/graphiql`);