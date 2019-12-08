module.exports = {
  apps : [{
    name: 'API',
    script: './dist/server.js',

    // Options reference: https://pm2.io/doc/en/runtime/reference/ecosystem-file/
    args: '',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'development',
      APOLLO_ENGINE_API_KEY: 'YOUR_API_KEY',
      SCHEMATA_TO_GRAPHQL: 'auth,auth_fn,org,org_fn,app,lcb,lcb_fn,lcb_ref,lcb_hist',
      POSTGRES_CONNECTION: 'postgres://postgres:b@$$WORD@0.0.0.0/lcb',
      DEFAULT_ROLE: 'app_anonymous',
      JWT_SECRET: 'SUPERSECRET-SUPERSECRET-SUPERSECRET',
      JWT_PG_TYPE_IDENTIFIER: 'auth.jwt_token',
      EXTENDED_ERRORS: 'hint, detail, errcode',
      DISABLE_DEFAULT_MUTATIONS: 'true',
      DYNAMIC_JSON: 'true',
      ENABLE_APOLLO_ENGINE: 'false',
      PORT: '5000',
      WATCH_PG: 'true',
      GRAPHIQL: 'true',
      ENHANCE_GRAPHIQL: 'true',
    },
    env_production: {
      NODE_ENV: 'production',
      APOLLO_ENGINE_API_KEY: 'YOUR_API_KEY',
      SCHEMATA_TO_GRAPHQL: 'auth,auth_fn,org,org_fn,app,lcb,lcb_fn,lcb_ref,lcb_hist',
      POSTGRES_CONNECTION: 'postgres://postgres:b@$$WORD@0.0.0.0/lcb',
      DEFAULT_ROLE: 'app_anonymous',
      JWT_SECRET: 'SUPERSECRET-SUPERSECRET-SUPERSECRET',
      JWT_PG_TYPE_IDENTIFIER: 'auth.jwt_token',
      EXTENDED_ERRORS: 'hint, detail, errcode',
      DISABLE_DEFAULT_MUTATIONS: 'true',
      DYNAMIC_JSON: 'true',
      ENABLE_APOLLO_ENGINE: 'false',
      PORT: '5000',
      WATCH_PG: 'true',
      GRAPHIQL: 'true',
      ENHANCE_GRAPHIQL: 'true',
    }
  }],

  deploy : {
    production : {
      user : 'node',
      host : '212.83.163.1',
      ref  : 'origin/master',
      repo : 'git@github.com:repo.git',
      path : '/var/www/production',
      'post-deploy' : 'npm install && pm2 reload ecosystem.config.js --env production'
    }
  }
};
