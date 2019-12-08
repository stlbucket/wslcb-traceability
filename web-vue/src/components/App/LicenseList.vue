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
              name: 'license-detail',
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
  name: "LicenseList",
  components: {
  },
  props: {
    licenses: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      headers: [
        { text: 'Name', value: 'name' },
        { text: 'Tenant', value: 'appTenantName' },
        { text: 'Key', value: 'licenseTypeKey' },
        { text: 'Application', value: 'applicationName' },
        { text: 'Assigned To', value: 'AssignedTo' },
      ],
    }
  },
  computed: {
    items () {
      return this.licenses.map(
        license => {
          // console.log('license', license)
          const assignedToContact = (license.assignedToAppUserContact || {}).contact || {
            firstName: 'Unassigned',
            lastName: ''
          }

          return {
            id: license.id,
            name: license.name,
            appTenantName: license.appTenant.name,
            licenseTypeKey: license.licenseType.key,
            applicationName: license.licenseType.application.name,
            assignedTo: `${assignedToContact.firstName} ${assignedToContact.lastName}`
          }
        }
      )
    }
  },
}
</script>
