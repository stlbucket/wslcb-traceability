<template>
  <div>
    <license-list-component
      :licenses="licenses"
      :appUsers="appUsers"
    ></license-list-component>
  </div>
</template>

<script>
import allLicenses from '@/graphql/query/allLicenses.graphql'
import LicenseListComponent from '@/components/App/LicenseList'

export default {
  name: "LicenseList",
  components: {
    LicenseListComponent
  },
  data () {
    return {
      licenses: [],
      appUsers: []
    }
  },
  apollo: {
    init: {
      query: allLicenses,
      fetchPolicy: 'network-only',
      update (data) {
        this.licenses = data.allLicenses.nodes
        this.appUsers = data.allAppUsers.nodes
      }
    }
  }
}
</script>
