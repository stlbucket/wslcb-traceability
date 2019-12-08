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
              name: 'organization-detail',
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
  name: "OrganizationList",
  data () {
    return {
      headers: [
        { text: 'Name', value: 'name' },
        { text: 'City', value: 'city' },
        { text: 'Primary Contact', value: 'primaryContactName' }
      ]
    }
  },
  props: {
    organizations: {
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
      const retval = this.organizations.map(
        organization => {
          const location = organization.location || {
            city: 'N/A'
          }

          const primaryContact = organization.primaryContact || {
            firstName: 'N/A',
            lastName: ''
          }

          return {
            id: organization.id,
            name: organization.name,
            city: location.city,
            primaryContactName: `${primaryContact.firstName} ${primaryContact.lastName}`,
            primaryContactId: primaryContact.id
          }
        }
      )
      return retval
    }
  },
}
</script>
