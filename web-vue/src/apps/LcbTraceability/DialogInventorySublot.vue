
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
            Sublot
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Create Sublots</v-card-title>
          <h3>Parent Lot: {{parentLotDisplay}}</h3>
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
                :label="sublotConfig.quantityLabel"
                v-model="quantity"
              ></v-text-field>
              <v-btn @click="sublot" :disabled="sublotDisabled">Create Sublots</v-btn>
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
  import sublotInventory from '@/graphql/mutation/sublotInventory.graphql'

  export default {
    name: 'DialogInventorySublot',
    props: {
      disabled: {
        type: Boolean,
        default: false
      },
      sublotConfig: {
        type: Object,
        required: true
      }
    },
    data () {
      return {
        toggleCompleted: false,
        dialog: false,
        quantity: 0,
        ulid: null,
        licenseeIdentifier: null
      }
    },
    computed: {
      parentLotDisplay () {
        const parentLot = this.sublotConfig.parentLot
        return parentLot ? `${parentLot.id } - ${parentLot.description}` : 'NO PARENT LOT'
      },
      hidden () {
        return false
      },
      btnDisabled () {
        return this.disabled
      },
      sublotDisabled () {
        return false
      }
    },
    watch: {
    },
    methods: {
      sublot () {
        const sublotInventoryInput = {
          id: this.ulid,
          licenseeIdentifier: this.licenseeIdentifier,
          quantity: this.quantity
        }

        this.$apollo.mutate({
          mutation: sublotInventory,
          variables: {
            parentLotId: this.sublotConfig.parentLot.id,
            sublotsInfo: [sublotInventoryInput]
          }
        })
        .then(result => {
          this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.sublotInventory.inventoryLots})
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