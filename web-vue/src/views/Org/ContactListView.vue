<template>
  <div>
    <contact-list-component
      :contacts="contacts"
    ></contact-list-component>
  </div>
</template>

<script>
import allContacts from '@/graphql/query/allContacts.graphql'
import allContactsForOrganization from '@/graphql/query/allContactsForOrganization.graphql'
import ContactListComponent from '@/components/Org/ContactList'

export default {
  name: "ContactList",
  components: {
    ContactListComponent
  },
  props: {
    organizationId: {
      type: String,
      required: false
    }
  },
  methods: {
  },
  computed: {
  },
  data () {
    return {
      contacts: []
    }
  },
  apollo: {
    init: {
      query () {
        return this.organizationId !== null && this.organizationId !== undefined ? allContactsForOrganization : allContacts
      },
      fetchPolicy: 'network-only',
      variables () {
        return this.organizationId !== null && this.organizationId !== undefined ? {
          organizationId: this.organizationId
        } : null
      },
      update (data) {
        this.contacts = data.allContacts.nodes
      }
    }
  }
}
</script>
