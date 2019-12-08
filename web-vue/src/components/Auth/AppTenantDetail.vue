<template>
  <entity-detail-vuetify
    :fields="fields"
    :entity="appTenant"
  ></entity-detail-vuetify>
</template>

<script>
import EntityDetailVuetify from '@/components/_common/EntityDetailVuetify'

export default {
  name: "AppTenantDetail",
  components: {
    EntityDetailVuetify
  },
  props: {
    appTenant: { 
      type: Object,
      required: true
    }
  },
  data () {
    return {
      fields: [
        {
          name: "name",
          label: "Name"
        },
        {
          name: "identifier",
          label: "Identifier"
        },
      ]
    }
  }
}
</script>
