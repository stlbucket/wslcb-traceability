<template>
  <div>
    <organization-list-component
      :organizations="organizations"
    ></organization-list-component>
  </div>
</template>

<script>
import OrganizationListComponent from '@/components/Org/OrganizationList'
import allOrganizations from '@/graphql/query/allOrganizations.graphql'

export default {
  name: "OrganizationListView",
  components: {
    OrganizationListComponent
  },
  methods: {
  },
  computed: {
  },
  data () {
    return {
      organizations: []
    }
  },
  apollo: {
    init: {
      query: allOrganizations
      ,fetchPolicy: 'network-only'
      ,update (data) {
        this.organizations = data.allOrganizations.nodes
      }
    }
  }
}
</script>
