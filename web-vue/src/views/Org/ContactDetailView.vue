<template>
  <v-container grid-list-md text-xs-center>
    <v-card>
      <v-card-title class="headline">Contact</v-card-title>
      <v-layout row wrap>
        <v-flex xs4>
          <contact-detail-component
            :contact="contact"
          ></contact-detail-component>
          Location
          <location-detail :location="location"></location-detail>
        </v-flex>
      </v-layout>
    </v-card>
  </v-container>
</template>

<script>
import contactById from '@/graphql/query/contactById.graphql'
import ContactDetailComponent from '@/components/Org/ContactDetail'
import LocationDetail from '@/components/Org/LocationDetail'


export default {
  name: "ContactDetailView",
  components: {
    ContactDetailComponent,
    LocationDetail
  },
  props: {
    id: { 
      type: String,
      required: true
    }
  },
  methods: {
  },
  computed: {
    location () {
      return this.contact.location || { name: 'N/A' }
    }
  },
  data () {
    return {
      contact: {
        name: 'N/A'
      }
    }
  },
  apollo: {
    init: {
      query: contactById,
      fetchPolicy: 'network-only',
      variables () {
        return {
          id: this.id
        }
      },
      update (data) {
        this.contact = data.contactById
      }
    }
  }
}
</script>
