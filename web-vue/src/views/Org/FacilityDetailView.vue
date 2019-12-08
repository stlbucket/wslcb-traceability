<template>
  <v-container grid-list-md text-xs-center>
    <v-card>
      <v-card-title class="headline">Facility</v-card-title>
      <v-layout row wrap>
        <v-flex xs4>
          <facility-detail-component
            :facility="facility"
          ></facility-detail-component>
          Location
          <location-detail :location="location"></location-detail>
        </v-flex>
      </v-layout>
    </v-card>
  </v-container>
</template>

<script>
import facilityById from '@/graphql/query/facilityById.graphql'
import FacilityDetailComponent from '@/components/Org/FacilityDetail'
import LocationDetail from '@/components/Org/LocationDetail'


export default {
  name: "FacilityDetailView",
  components: {
    FacilityDetailComponent,
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
      return this.facility.location || { name: 'N/A' }
    }
  },
  data () {
    return {
      facility: {
        name: 'N/A'
      }
    }
  },
  apollo: {
    init: {
      query: facilityById,
      fetchPolicy: 'network-only',
      variables () {
        return {
          id: this.id
        }
      },
      update (data) {
        this.facility = data.facilityById
      }
    }
  }
}
</script>
