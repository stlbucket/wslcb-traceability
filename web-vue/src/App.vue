<template>
  <v-app id="inspire"
  >
 
    <v-app-bar
      app
      clipped-right
    >
      <v-spacer></v-spacer>
      <v-spacer></v-spacer>
      <v-spacer></v-spacer>
      <v-spacer></v-spacer>
      <v-spacer></v-spacer>
      <v-spacer></v-spacer>
      <v-spacer></v-spacer>
      <current-app-user-contact></current-app-user-contact>
      <v-spacer></v-spacer>
      <login-manager></login-manager>
      <v-spacer></v-spacer>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
    </v-app-bar>

    <v-hover v-slot:default="{ hover }">
      <v-navigation-drawer
        v-model="drawer"
        :clipped="true"
        app
        right
        :width="300"
        disable-route-watcher
      >
        <app-menu></app-menu>
      </v-navigation-drawer>
    </v-hover>

   <v-content
    >
      <v-container
        justify-start
        ma-2
        pa-2
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
import lcbLookupSets from '@/graphql/query/lcbLookupSets.graphql'
import AppMenu from '@/components/_common/AppMenu/AppMenuList'
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
    closeDrawer () {
      this.drawer = false
    }
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
    },
    lcbLookupSets: {
      query: lcbLookupSets
      ,fetchPolicy: 'network-only'
      ,update (data) {
        this.$store.commit('setInventoryTypes', {
          inventoryTypes: (data.inventoryTypes || {nodes:[]}).nodes
        })
      }
    }
  },
  created() {
      this.$eventHub.$on('app-selected', this.closeDrawer);
  },
  beforeDestroy() {
      this.$eventHub.$off('app-selected');
  }
}
</script>
