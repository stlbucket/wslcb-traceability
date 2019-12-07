
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
            Conversion
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Create Conversions</v-card-title>
          <h3>Parent Lot: {{parentLotDisplay}}</h3>
          <v-combobox
            v-model="selectedInventoryType"
            :items="mappedInventoryTypes"
            label="Select Inventory Type"
          ></v-combobox>
          <v-row>
            <v-col cols="3">
              <v-text-field
                label="Licensee Identifier"
                v-model="licenseeIdentifier"
              ></v-text-field>
            </v-col>
            <v-col cols="3">
              <v-text-field
                label="ULID"
                v-model="ulid"
              ></v-text-field>
              <v-btn @click="generateUlid">Generate ULID</v-btn>
            </v-col>
            <v-col cols="2">
              <v-text-field
                :label="conversionConfig.quantityLabel"
                v-model="quantity"
              ></v-text-field>
              <v-btn @click="conversion" :disabled="conversionDisabled">Create Conversions</v-btn>
            </v-col>
          </v-row>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn :hidden="disabled" @click="dialog=false">Cancel</v-btn>
            <v-btn :hidden="!disabled" @click="dialog=false">OK</v-btn>
            <v-spacer></v-spacer>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>
  import {ulid} from 'ulid'
  import conversionInventory from '@/graphql/mutation/convertInventory.graphql'

  export default {
    name: 'DialogInventoryConversion',
    props: {
      disabled: {
        type: Boolean,
        default: false
      },
      conversionConfig: {
        type: Object,
        required: true
      },
      inventoryTypes: {
        type: Array,
        required: true
      }
    },
    data () {
      return {
        toggleCompleted: false,
        dialog: false,
        quantity: 0,
        ulid: null,
        licenseeIdentifier: null,
        selectedInventoryType: null
      }
    },
    computed: {
      mappedInventoryTypes () {
        return this.inventoryTypes
          .filter(
            it => {
              const fromIds = it.canConvertFrom.nodes.map(ccf => ccf.fromTypeId)
              const sourceInventoryType = this.conversionConfig.parentLot ? this.conversionConfig.parentLot.inventoryType.id : 'N/A'
              return fromIds.indexOf(sourceInventoryType) !== -1
            }
          )
          .map(
            it => {
              return {
                text: `${it.id}: ${it.name}`,
                value: it.id
              }
            }
          )
      },
      parentLotDisplay () {
        const parentLot = this.conversionConfig.parentLot
        return parentLot ? `${parentLot.inventoryType.id} - ${parentLot.id} - ${parentLot.description}` : 'NO PARENT LOT'
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
      conversion () {
        const sourcesInfo = [
          {
            id: this.conversionConfig.parentLot.id,
            quantity: this.quantity
          }
        ]
        const newLotsInfo = [
          {
            description: 'conversion result',
            quantity: this.quantity,
            inventoryType: this.conversionConfig.parentLot.inventoryType.id
          }
        ]

        this.$apollo.mutate({
          mutation: conversionInventory,
          variables: {
            sourcesInfo: sourcesInfo,
            newLotsInfo: newLotsInfo
          }
        })
        .then(result => {
          this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.convertInventory.inventoryLots})
          this.dialog = false
        })
        .catch(error => {
          alert(error.toString())
          console.error(error)
        })
      },
      generateUlid () {
        this.ulid = ulid()
      },

    }
  }
</script>

<style>
.norm-text {
  text-transform: none !important;
}
</style>