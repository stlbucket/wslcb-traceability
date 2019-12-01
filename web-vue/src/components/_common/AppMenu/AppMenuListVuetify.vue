<template>
  <div>
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
  </div>
</template>

<script>
import AppMenuListScript from './AppMenuListScript'

export default {
  name: "AppMenuList",
  mixins: [AppMenuListScript]
}
</script>
