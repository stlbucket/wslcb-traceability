
<template>
    <div>
      <v-dialog v-model="dialog" persistent width="800">
        <template v-slot:activator="{ on }">
          <v-btn
            small
            dark
            v-on="on"
            :disabled="btnDisabled"
            :hidden="hidden"
            class="text-none"
          >
            RT Sample
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Create Samples</v-card-title>
          <h3>Parent Lot: {{parentLotDisplay}}</h3>
          <v-row>
            <v-col cols="3">
              <v-text-field
                label="Licensee Identifier"
                v-model="licenseeIdentifier"
              ></v-text-field>
              <v-btn :hidden="disabled" @click="dialog=false">Cancel</v-btn>
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
                :label="rtSampleConfig.quantityLabel"
                v-model="quantity"
              ></v-text-field>
              <v-btn @click="rtSample" :disabled="sampleDisabled">Make Samples</v-btn>
            </v-col>
          </v-row>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>
  import {ulid} from 'ulid'
  import rtSampleInventory from '@/graphql/mutation/rtSampleInventory.graphql'

  export default {
    name: 'DialogInventoryRtSample',
    props: {
      disabled: {
        type: Boolean,
        default: false
      },
      rtSampleConfig: {
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
        const parentLot = this.rtSampleConfig.parentLot
        return parentLot ? `${parentLot.id } - ${parentLot.description}` : 'NO PARENT LOT'
      },
      hidden () {
        return false
      },
      btnDisabled () {
        return this.disabled
      },
      sampleDisabled () {
        return false
      }
    },
    watch: {
    },
    methods: {
      rtSample () {
        const sampleInventoryInput = {
          id: this.ulid,
          licenseeIdentifier: this.licenseeIdentifier,
          quantity: this.quantity
        }

        this.$apollo.mutate({
          mutation: rtSampleInventory,
          variables: {
            parentLotId: this.rtSampleConfig.parentLot.id,
            samplesInfo: [sampleInventoryInput]
          }
        })
        .then(result => {
          this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.rtSampleInventory.inventoryLots})
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