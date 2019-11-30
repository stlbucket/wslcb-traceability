<template>
  <entity-detail-vuetify
    :fields="fields"
    :entity="license"
  ></entity-detail-vuetify>
</template>

<script>
import LicenseDetailScript from './LicenseDetailScript'
import EntityDetailVuetify from '@/components/_common/EntityDetailVuetify'

export default {
  name: "LicenseDetail",
  mixins: [LicenseDetailScript],
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
  }
}
</script>
