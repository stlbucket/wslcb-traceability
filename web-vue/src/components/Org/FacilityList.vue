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
              name: 'facility-detail',
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
  name: "FacilityList",
  components: {
  },
  data () {
    return {
      headers: [
        { text: 'Name', value: 'name' },
        { text: 'City', value: 'city' },
        { text: 'Organization', value: 'organizationName' }
      ]
    }
  },
  props: {
    facilities: {
      type: Array,
      required: true,
    }
  },
  methods: {
  },
  computed: {
    items () {
      return (this.facilities || []).map(
        facility => {
          const organization = facility.organization || {
            name: 'N/A'
          }

          const location = facility.location || {
            city: 'N/A'
          }

          return {
            id: facility.id,
            name: facility.name || 'N/A',
            city: location.city,
            organizationName: organization.name
          }
        }
      )
    }
  }
}
</script>
