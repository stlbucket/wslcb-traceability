<template>
  <entity-detail-vuetify
    :fields="fields"
    :entity="licenseType"
  ></entity-detail-vuetify>
</template>

<script>
import EntityDetailVuetify from '@/components/_common/EntityDetailVuetify'

export default {
  name: "LicenseTypeDetail",
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
    licenseType: { 
      type: Object,
      required: true
    }
  },
  computed: { 
    name () {
      return this.licenseType.name || 'N/A'
    }
  },
}
</script>
