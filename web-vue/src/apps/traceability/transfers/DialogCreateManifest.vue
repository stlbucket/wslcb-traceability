
<template>
    <div>
      <v-dialog v-model="dialog" persistent width="600">
        <template v-slot:activator="{ on }">
          <v-btn
            small
            dark
            v-on="on"
            :disabled="btnDisabled"
            :hidden="hidden"
            class="text-none"
          >
            Create Manifest
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Create Manifest</v-card-title>
          <v-combobox
            v-model="selectedLicenseHolder"
            :items="mappedLicenseHolders"
            label="Recipient"
          ></v-combobox>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn @click="dialog=false">Cancel</v-btn>
            <v-btn @click="createManifest">OK</v-btn>
            <v-spacer></v-spacer>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>
  import allLcbLicenseHolders from '@/graphql/query/allLcbLicenseHolders.graphql'
  import createManifest from '@/graphql/mutation/createManifest.graphql'

  export default {
    name: 'DialogCreateManifest',
    props: {
      disabled: {
        type: Boolean,
        default: false
      }
    },
    data () {
      return {
        toggleCompleted: false,
        dialog: false,
        quantity: 0,
        ulid: null,
        licenseeIdentifier: null,
        allLcbLicenseHolders: [],
        selectedLicenseHolder: null
      }
    },
    computed: {
      mappedLicenseHolders () {
        return this.allLcbLicenseHolders

          .map(
            lh => {
              return {
                text: `${lh.lcbLicense.code} - ${lh.organization.name}`,
                value: lh.id
              }
            }
          )
      },
      hidden () {
        return false
      },
      btnDisabled () {
        return this.disabled
      },
      conversionDisabled () {
        return false
      }
    },
    watch: {
    },
    methods: {
      createManifest () {
        this.$apollo.mutate({
          mutation: createManifest,
          variables: {
            toLcbLicenseHolderId: this.selectedLicenseHolder.value,
            scheduledTransferDate: (new Date()).toISOString(),
            inventoryLotIds: []
          }
        })
        .then(result => {
          console.log(result)
          this.dialog = false
        })
        .catch(error => {
          alert(error.toString())
          console.error(error)
        })
      }
    },
    apollo: {
      init: {
        query: allLcbLicenseHolders,
        update (data) {
          this.allLcbLicenseHolders = data.allLcbLicenseHolders.nodes
        }
      }
    }
  }
</script>

<style>
.norm-text {
  text-transform: none !important;
}
</style>