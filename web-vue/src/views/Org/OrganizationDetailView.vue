<template>
  <v-container grid-list-md text-xs-center>
    <v-card>
      <v-card-title class="headline">Organization</v-card-title>
      <v-layout row wrap>
        <v-flex xs4>
          <organization-detail-component
            :organization="organization"
          ></organization-detail-component>
          Location
          <location-detail :location="location"></location-detail>
        </v-flex>
        <v-flex xs8>
          <v-card raised>
            <v-tabs
              dark
              slider-color="yellow"
            >
              <v-tab
                key="contact-list"
                ripple
              >
                Contacts
              </v-tab>
              <v-tab-item
                key="contact-list"
              >
                <contact-list
                  :contacts="contacts"
                ></contact-list>
              </v-tab-item>
              <v-tab
                key="facility-list"
                ripple
              >
                Facilities
              </v-tab>
              <v-tab-item
                key="facility-list"
              >
                <facility-list
                  :facilities="facilities"
                ></facility-list>
              </v-tab-item>
            </v-tabs>
          </v-card>
        </v-flex>
      </v-layout>
    </v-card>
  </v-container>
</template>

<script>
import organizationById from '@/graphql/query/organizationById.graphql'
import OrganizationDetailComponent from '@/components/Org/OrganizationDetail'
import ContactList from '@/components/Org/ContactList'
import FacilityList from '@/components/Org/FacilityList'
import LocationDetail from '@/components/Org/LocationDetail'


export default {
  name: "OrganizationDetailView",
  components: {
    ContactList,
    FacilityList,
    LocationDetail,
    OrganizationDetailComponent
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
    contacts () {
      return this.organization.contacts ? this.organization.contacts.nodes || [] : []
    },
    facilities () {
      return this.organization.facilities ? this.organization.facilities.nodes || [] : []
    },
    location () {
      return this.organization.location || { name: 'N/A' }
    }
  },
  data () {
    return {
      organization: {
        name: 'N/A'
      }
    }
  },
  apollo: {
    init: {
      query: organizationById,
      fetchPolicy: 'network-only',
      variables () {
        return {
          id: this.id
        }
      },
      update (data) {
        console.log(data)
        this.organization = data.organizationById
      }
    }
  }
}
</script>
