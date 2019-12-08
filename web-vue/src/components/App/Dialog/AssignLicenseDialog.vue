
<template>
    <div>
      <v-dialog v-model="dialog" persistent width="400">
        <template v-slot:activator="{ on }">
          <v-btn
            small
            dark
            v-on="on"
            :disabled="btnDisabled"
            :hidden="hidden"
            class="text-none"
          >
            {{ assignedToDisplay }}
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Provision Inventory Lots</v-card-title>
          <v-combobox
            v-model="selectedAppUser"
            :items="mappedAppUsers"
            label="Select User"
          ></v-combobox>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn @click="dialog=false">Cancel</v-btn>
            <v-btn @click="assignLicense">Provision</v-btn>
            <v-spacer></v-spacer>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>
  import assignLicense from '@/graphql/mutation/assignLicense.graphql'

  export default {
    name: 'AssignLicenseDialog',
    props: {
      disabled: {
        type: Boolean,
        default: false
      },
      license: {
        type: Object,
        required: true
      },
      appUsers: {
        type: Array,
        required: true
      }
    },
    data () {
      return {
        toggleCompleted: false,
        dialog: false,
        selectedAppUser: null
      }
    },
    computed: {
      hidden () {
        return false
      },
      btnDisabled () {
        return this.disabled
      },
      mappedAppUsers () {
        return this.appUsers
          .map(
            au => {
              return {
                text: `${au.contactAppUser.contact.firstName} ${au.contactAppUser.contact.lastName}`,
                value: `${au.id}`
              }
            }
          )
      },
      assignedToDisplay () {
        return this.license.assignedTo
      }
    },
    watch: {
    },
    methods: {
      assignLicense () {
        this.$apollo.mutate({
          mutation: assignLicense,
          variables: {
            licenseId: this.license,
            assignedToAppUserId: this.assignedToAppUserId
          }
        })
        .then(result => {
          console.log(result)
          this.dialog = false
        })
        .catch(error => {
          alert(error.toString())
          console.error(error)
          this.dialog = false
        })
      },
    },
    mounted () {
      this.selectedAppUser = this.license.assignedToAppUserId
    }
  }
</script>

<style>
.norm-text {
  text-transform: none !important;
}
</style>