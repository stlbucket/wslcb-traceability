<template>
  <div>
    <license-list-component
      :licenses="licenses"
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
      licenses: []
    }
  },
  apollo: {
    init: {
      query: allLicenses,
      fetchPolicy: 'network-only',
      update (data) {
        this.licenses = data.allLicenses.nodes
      }
    }
  }
}
</script>
