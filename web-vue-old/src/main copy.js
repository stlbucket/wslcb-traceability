import Vue from 'vue'
import './plugins/vuetify'
import App from './App.vue'
import router from './router'
import store from './store'
import { createProvider } from './vue-apollo'

import VueFormGenerator from 'vue-form-generator'
import 'vue-form-generator/dist/vfg.css'
Vue.use(VueFormGenerator)

Vue.config.productionTip = false

// from https://medium.com/vuejobs/create-a-global-event-bus-in-vue-js-838a5d9ab03a
Vue.prototype.$eventHub = new Vue(); // Global event bus


new Vue({
  router,
  store,
  apolloProvider: createProvider(),
  render: h => h(App)
}).$mount('#app')
