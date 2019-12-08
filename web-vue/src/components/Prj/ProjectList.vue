<template>
  <div>
    <entity-list-vuetify
      :headers="headers"
      :items="items"
      :columns="columns"
    ></entity-list-vuetify>
  </div>
</template>

<script>
import EntityListVuetify from '../_common/EntityListVuetify'

export default {
  name: "ProjectList",
  components: {
    EntityListVuetify
  },
  props: {
    projects: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      headers: [
        { text: 'Name', value: 'name' },
        { text: 'Tenant', value: 'appTenantName' },
      ],
      columns: [
        { 
          name: 'name', 
          routeLink: { 
            name: "project-detail", 
            params: {
              id: 'id'
            }
          } 
        },
        { name: 'appTenantName' },
      ]
    }
  },
  computed: {
    items () {
      return this.projects.map(
        project => {
          return {
            id: project.id,
            name: project.name,
            appTenantName: project.organization.name
          }
        }
      )
    }
  },

}
</script>
