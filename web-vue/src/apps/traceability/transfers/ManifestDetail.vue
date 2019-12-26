<template>
<v-container>
  <h1>Manifest Detail - {{id}}</h1>
  <v-card>
    <v-toolbar>
    </v-toolbar>
  </v-card>

</v-container>
</template>

<script>
export default {
  name: 'ManifestDetail',
  components:{
  },
  props: {
    id: {
      type: String,
      required: true
    }
  },
  data () {
    return {
      allLcbLicenseHolders: [],
      selectedLicenseHolder: null
    }
  },
  computed: {
  },
  // apollo: {
  //   init: {
  //     query: allLcbLicenseHolders,
  //     update (data) {
  //       this.allLcbLicenseHolders = data.allLcbLicenseHolders.nodes
  //     }
  //   }
  // }
}
</script>

<style>

</style>