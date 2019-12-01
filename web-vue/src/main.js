import Vue from 'vue'
import App from './App.vue'
import { createProvider } from './vue-apollo'
import vuetify from './plugins/vuetify';
import router from './router'
import store from './store'

Vue.config.productionTip = false

// from https://medium.com/vuejobs/create-a-global-event-bus-in-vue-js-838a5d9ab03a
Vue.prototype.$eventHub = new Vue(); // Global event bus

new Vue({
  apolloProvider: createProvider(),
  vuetify,
  router,
  store,
  render: h => h(App)
}).$mount('#app')
