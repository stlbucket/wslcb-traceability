<template>
  <div>
    <v-data-table
      :headers="headers"
      :items="items"
      hide-default-footer
    >

      <template v-slot:item.fullName="{item}">
          <router-link 
            :to="{ 
              name: 'contact-detail',
              params: {
                id: item.id
              }
            }"
          >
            {{ item.fullName }}
          </router-link>
      </template>
    </v-data-table>
  </div>
</template>

<script>
export default {
  name: "ContactList",
  components: {
  },
  data () {
    return {
      headers: [
        { text: 'Name', value: 'fullName' },
        { text: 'Email', value: 'email' },
        { text: 'City', value: 'city' },
        { text: 'Organization', value: 'organizationName' },
      ]
    }
  },
  props: {
    contacts: {
      type: Array,
      required: true
    }
  },
  methods: {
  },
  computed: {
    items () {
      return this.contacts.map(
        contact => {
          const organization = contact.organization || {
            name: 'N/A'
          }

          const location = contact.location || {
            city: 'N/A'
          }

          return {
            ...contact,
            organizationName: organization.name,
            city: location.city,
            fullName: `${contact.firstName} ${contact.lastName}`
          }
        }
      )
    }
  },
}
</script>
