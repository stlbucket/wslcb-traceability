<template>
  <entity-detail-vuetify
    :fields="fields"
    :entity="organization"
  ></entity-detail-vuetify>
</template>

<script>
import EntityDetailVuetify from '@/components/_common/EntityDetailVuetify'

export default {
  name: "OrganizationDetail",
  components: {
    EntityDetailVuetify
  },
  props: {
    organization: {
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
          name: "externalId",
          label: "External Id"
        },
      ]
    }
  }
}
</script>
