<template>
  <div>
    <v-data-table
      :headers="headers"
      :items="items"
      hide-default-footer
    >

      <template v-slot:item.name="{item}">
          <router-link 
            :to="{ 
              name: 'app-tenant-detail',
              params: {
                id: item.id
              }
            }"
          >
            {{ item.name }}
          </router-link>
      </template>

    </v-data-table>
  </div>
</template>

<script>
export default {
  name: "AppTenantList",
  props: {
    appTenants: {
      type: Array,
      default: () => []
    }
  },
  components: {
  },
  methods: {
  },
  computed: {
    items () {
      return this.appTenants.map(
        appTenant => {
          const organization = appTenant.organization || {}

          const location = organization.location || {
            city: 'N/A'
          }

          const primaryContact = organization.primaryContact || {
            firstName: 'N/A',
            lastName: ''
          }

          return {
            id: appTenant.id,
            name: appTenant.name,
            city: location.city,
            primaryContactName: `${primaryContact.firstName} ${primaryContact.lastName}`,
            primaryContactId: primaryContact.id
          }
        }
      )
    }
  },
  data () {
    return {
      headers: [
        { text: 'Name', value: 'name' },
        { text: 'City', value: 'city' },
        { text: 'Primary Contact', value: 'primaryContactName' }
      ]
    }
  }
}
</script>
