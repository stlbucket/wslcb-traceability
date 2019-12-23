<template>
<v-container>
  <h1>Manifest Detail</h1>
  <v-card>
    <v-toolbar>
    </v-toolbar>
    <v-combobox
      v-model="selectedLicenseHolder"
      :items="mappedLicenseHolders"
      label="Recipient"
    ></v-combobox>
  </v-card>

</v-container>
</template>

<script>
import allLcbLicenseHolders from '@/graphql/query/allLcbLicenseHolders.graphql'

export default {
  name: 'ManifestDetail',
  components:{
  },
  props: {
    id: {
      type: String,
      required: false
    }
  },
  data () {
    return {
      allLcbLicenseHolders: [],
      selectedLicenseHolder: null
    }
  },
  computed: {
    mappedLicenseHolders () {
      return this.allLcbLicenseHolders
        .map(
          lh => {
            console.log(lh)
            return `${lh.lcbLicense.code} - ${lh.organization.name}`
          }
        )
    },
  },
  apollo: {
    init: {
      query: allLcbLicenseHolders,
      update (data) {
        this.allLcbLicenseHolders = data.allLcbLicenseHolders.nodes
      }
    }
  }
}
</script>

<style>

</style>