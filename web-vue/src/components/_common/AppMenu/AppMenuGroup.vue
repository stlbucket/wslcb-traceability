<template>
  <v-container>
    <v-list :hidden="!showAppList" dense>
      <v-list-item
        v-for="app in allowedAppList"
        @click="appSelected(app)"
        :key="app.key"
      >
        <v-list-item-action>
          <v-icon>{{ app.iconKey }}</v-icon>
        </v-list-item-action>
        <v-list-item-content>
          <v-list-item-title>{{ app.name }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
    <h2 :hidden="showAppList">Login for apps</h2>
  </v-container>
</template>

<script>
export default {
  name: "AppMenuGroup",
  components: {
  },
  methods: {
    appSelected (app) {
      console.log('app', app)
      this.$router.push({
        path: app.path,
        params: app.params
      })
      .catch(err => { err })
    },
  },
  computed: {
    allowedAppList () {
      return this.appGroup.appList.reduce(
        (a, app) => {
          const userLicense = this.currentAppUser ? this.currentAppUser.licenses.nodes.find(l => l.licenseType.application.key === app.key) : null
          return userLicense ? a.concat([app]) : a
        }, []
      )
    },
    showAppList () {
      return this.$store.state.currentAppUser !== null
    },
    currentAppUser () {
      return this.$store.state.currentAppUser
    }
  },
  watch: {
  },
  props: {
    appGroup: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
    }
  },
}
</script>
