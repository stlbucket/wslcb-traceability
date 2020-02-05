# LCB Traceability POC
This repo is the result of a weekend project meant to demonstrate basic inventory tracking and conversion for the cannabis industry.
It is not fully configured for production - particularly there are no unit test or properly managed deploy scripts for the db.
Below are rough setup instructions but they have not been tested for fool-proofness and expect the developer to be able to troubleshoot somewhat
## setup
### clone the repo
```
git clone git@github.com:stlbucket/wslcb-traceability.git lcb
cd lcb
```
### db setup
edit db/config.sh to set up your postgres connection.  currently this is configured to use dockerized postgres locally.
run db setup script
```
cd db
./build-all.sh
```
this will create a new db called lcb (or something else if you changed the db name in config.sh)
### api setup
create a .env file
```
cd ../api
cp .env.example .env
```
edit this file for db connection setting according to earlier config.sh for the db migrations
run the api server
```
yarn
yarn serve
```
### run the ui
in another terminal:
```
cd web-vue
yarn
yarn serve
```
this should already be configured to run correctly.
# the stack
The core library in this stack is [postgraphile](https://www.graphile.org/postgraphile/introduction/), which is used to publish a graphql api thru introspection of a postgres db.
The ui is a basic [vue](https://www.vuejs.org) application build using the [vuetify](https://www.vuetifyjs.org) component framework, [vuex](https://vuex.vuejs.org/), and [apollo client](https://www.apollographql.com/)
The database and UI starter components are built using a set of starter schemas and components from another stlbucket repo, [phile-starter](https://github.com/stlbucket/phile-starter).
None of these repos should be considered production ready, but are a good starting point for build SaaS application MVPs that may need to evolve into true scalability.