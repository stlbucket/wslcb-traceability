
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
            @click="provision"
          >
            Provision
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Provision Inventory Lots</v-card-title>
          <v-combobox
            v-model="selectedInventoryType"
            :items="mappedInventoryTypes"
            label="Select Inventory Type"
          ></v-combobox>
          <v-text-field
            label="Number of ULIDS"
            v-model="provisionCount"
          ></v-text-field>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn @click="dialog=false">Cancel</v-btn>
            <v-btn @click="provisionInventoryLotIds">Provision</v-btn>
            <v-spacer></v-spacer>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>
  import provisionInventoryLotIds from '@/graphql/mutation/provisionInventoryLotIds.graphql'

  export default {
    name: 'DialogInventoryProvision',
    props: {
      disabled: {
        type: Boolean,
        default: false
      },
      mappedInventoryTypes: {
        type: Array,
        required: true
      },
      initialInventoryType: {
        type: Object,
        required: false
      }
    },
    data () {
      return {
        toggleCompleted: false,
        dialog: false,
        provisionCount: 1,
        selectedInventoryType: null
      }
    },
    computed: {
      hidden () {
        return false
      },
      btnDisabled () {
        return this.disabled
      }
    },
    watch: {
    },
    methods: {
      provisionInventoryLotIds () {
        this.$apollo.mutate({
          mutation: provisionInventoryLotIds,
          variables: {
            inventoryType: this.selectedInventoryType.value,
            numberRequested: parseInt(this.provisionCount)
          }
        })
        .then(result => {
          this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.provisionInventoryLotIds.inventoryLots})
          this.dialog = false
        })
        .catch(error => {
          alert(error.toString())
          console.error(error)
          this.dialog = false
        })
      },
      provision () {

      }
    },
    mounted () {
      this.selectedInventoryType = this.initialInventoryType
    }
  }
</script>

<style>
.norm-text {
  text-transform: none !important;
}
</style>