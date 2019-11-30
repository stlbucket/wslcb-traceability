import Vue from 'vue'
import App from './App.vue'
import { createProvider } from './vue-apollo'
import vuetify from './plugins/vuetify';
import router from './router'

Vue.config.productionTip = false

new Vue({
  apolloProvider: createProvider(),
  vuetify,
  router,
  render: h => h(App)
}).$mount('#app')
