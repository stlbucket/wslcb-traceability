<template>
  <v-app id="inspire">
    <v-hover v-slot:default="{ hover }">
      <v-navigation-drawer
        v-model="drawer"
        :clipped="true"
        app
        :width="hover ? 500 : 200"
        disable-route-watcher
      >
        <app-menu></app-menu>
      </v-navigation-drawer>
    </v-hover>

    <v-app-bar
      app
      clipped-left
    >
      <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
      <current-app-user-contact></current-app-user-contact>
      <login-manager></login-manager>
    </v-app-bar>

    <v-content>
      <v-container
        justify-start
         ma-0 
         pa-0
      >
        <router-view></router-view>
      </v-container>
    </v-content>

    <v-footer app>
      <span>&copy; 2019</span>
    </v-footer>
  </v-app>
</template>

<script>
import AppMenu from '@/components/_common/AppMenu/AppMenuListVuetify'
import CurrentAppUserContact from '@/components/_common/CurrentAppUserContact/CurrentAppUserContactVuetify'
import LoginManager from '@/components/_common/LoginManager/LoginManagerVuetify'
import introspection from '@/graphql/query/introspection.graphql'

export default {
  name: 'App',
  components: {
    CurrentAppUserContact,
    LoginManager,
    AppMenu
  },
  computed: {
  },
  methods: {
  },
  data () {
    return {
      drawer: true,
      hasToken: false
    }
  },
  apollo: {
    init: {
      query: introspection,
      networkPolicy: 'fetch-only',
      update (data) {
        const schema = data.__schema || {types: []}
        this.$store.commit('setGraphqlTypes', schema.types)
      }
    }
  }
}
</script>
