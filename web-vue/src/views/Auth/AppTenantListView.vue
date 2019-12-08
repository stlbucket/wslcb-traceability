<template>
  <div>
    <appTenant-list-component
      :appTenants="appTenants"
    ></appTenant-list-component>
  </div>
</template>

<script>
import allAppTenants from '@/graphql/query/allAppTenants.graphql'
import AppTenantListComponent from '@/components/Auth/AppTenantList'

export default {
  name: "AppTenantList",
  components: {
    AppTenantListComponent
  },
  methods: {
  },
  computed: {
  },
  data () {
    return {
      appTenants: []
    }
  },
  apollo: {
    init: {
      query: allAppTenants,
      fetchPolicy: 'network-only',
      update (data) {
      //  console.log('ten', data)
        this.appTenants = data.allAppTenants.nodes
      }
    }
  }
}
</script>
