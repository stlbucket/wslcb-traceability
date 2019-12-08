<template>
  <entity-detail-vuetify
    :fields="fields"
    :entity="application"
  ></entity-detail-vuetify>
</template>

<script>
import EntityDetailVuetify from '@/components/_common/EntityDetailVuetify'

export default {
  name: "ApplicationDetail",
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
          name: "key",
          label: "Key"
        },
        {
          name: "externalId",
          label: "External Id"
        },
      ]
    }
  },
  props: {
    application: { 
      type: Object,
      required: true
    }
  },
  computed: { 
    name () {
      return this.application.name || 'N/A'
    }
  }
}
</script>
