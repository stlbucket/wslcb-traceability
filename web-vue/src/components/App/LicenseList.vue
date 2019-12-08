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

      <template v-slot:item.assignedTo="{item}">
        <assign-license-dialog
          :license="item"
          :appUsers="appUsers"
        >
        </assign-license-dialog>
      </template>

    </v-data-table>
  </div>
</template>

<script>
import AssignLicenseDialog from './Dialog/AssignLicenseDialog'

export default {
  name: "LicenseList",
  components: {
    AssignLicenseDialog
  },
  props: {
    licenses: {
      type: Array,
      required: true
    },
    appUsers: {
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
        { text: 'Assigned To', value: 'assignedTo' },
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
