<template>
  <entity-detail-vuetify
    :fields="fields"
    :entity="license"
  ></entity-detail-vuetify>
</template>

<script>
import EntityDetailVuetify from '@/components/_common/EntityDetailVuetify'

export default {
  name: "LicenseDetail",
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
    license: { 
      type: Object,
      required: true
    }
  },
  computed: {
    txt () {
      return JSON.stringify(this.license,null,2)
    }
  }
}
</script>
