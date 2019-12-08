<template>
  <entity-detail-vuetify
    :fields="fields"
    :entity="facility"
  ></entity-detail-vuetify>
</template>

<script>
import EntityDetailVuetify from '@/components/_common/EntityDetailVuetify'

export default {
  name: "FacilityDetail",
  components: {
    EntityDetailVuetify
  },
  data () {
    return {
      fields: [
        {
          name: "name",
          label: "Name"
        },
        {
          name: "externalId",
          label: "External Id"
        },
      ]
    }
  },
  props: {
    facility: { 
      type: Object,
      required: true
    }
  },
  computed: { 
    name () {
      return this.facility.name || 'N/A'
    }
  },
}
</script>
