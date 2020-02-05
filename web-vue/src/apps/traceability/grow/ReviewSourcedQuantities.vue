<template>
  <v-container>
        <v-card
          class="mb-12"
          color="green"
        >
          <v-container>
            <h3 v-if="conversionRule.isNonDestructive">* non-destructive conversions do not require source quantities</h3>
            <v-data-table
              :headers="headers"
              :items="mappedInventoryLots"
              class="elevation-1"
              dense
              item-key="id"
              hide-default-footer
              :items-per-page="100"
              @click:row="inventoryLotSelected"
              :sort-by="'updatedAt'"
              :sort-desc="true"
            >
              <template v-slot:item.sourcedQuantity="{item}">
                <v-container>
                  <v-text-field
                    v-if="!conversionRule.isNonDestructive"
                    v-model="itemSourcedQuantities[item.id]"
                    label="Sourced Quantity"
                  >
                  </v-text-field>
                  <h3 v-else>{{itemSourcedQuantities[item.id]}}</h3>
                </v-container>
              </template>
            </v-data-table>
          </v-container>
        </v-card>

        <v-row>
          <v-col cols="3">
            <v-btn
              color="primary"
              @click="$emit('nextStep')"
              :disabled="continueDisabledSourceQuantities"
            >
              Continue
            </v-btn>
          </v-col>
          <v-col cols="1">
          </v-col>
          <v-col cols="3">
            <v-btn
              color="primary"
              @click="$emit('previousStep')"
            >
              Back
            </v-btn>
          </v-col>
        </v-row>
      </v-container>
</template>

<script>

export default {
  name: 'ReviewSourcedQuantities',
  components: {
  },
  props: {
    inventoryLots: {
      type: Array,
      required: true
    },
    conversionRule: {
      type: Object,
      required: true
    },
    value: {
      type: Object,
      default: ()=>{}
    },
  },
  computed: {
    continueDisabledSourceQuantities () {
      return Object.values(this.itemSourcedQuantities).map(
        item => {
          return parseFloat(item)
        }
      )
      .filter(v => isNaN(v))
      .length > 0
    },
    mappedInventoryLots() {
      return this.inventoryLots
        .map(
          il => {
            return this.mapInventoryLot(il)
          }
        )
    },
    headers () {
      const qtyHeaders = [
        {
          text: 'sourced quantity',
          value: 'sourcedQuantity'
        },
        {
          text: 'available quantity',
          value: 'quantity'
        },
        {
          text: 'units',
          value: 'units'
        }
      ]
      const idHeaders = [
        {
          text: 'ULID',
          value: 'id'
        },
        {
          text: 'inventory type',
          value: 'inventoryType.id'
        },
        {
          text: 'strain',
          value: 'strainName'
        }
      ]

      return this.conversionRule.isNonDestructive ? [...idHeaders] : [...qtyHeaders, ...idHeaders]
    }
  },
  methods: {
    inventoryLotSelected (inventoryLot) {
      if (this.onSelectInventoryLot) this.onSelectInventoryLot(inventoryLot)
    },
    mapInventoryLot (il) {
      const date = new Date(il.updatedAt)
      const updatedAtDisplay = `${date.getFullYear()}-${date.getDate().toString().padStart(2,'0')}-${(date.getMonth()+1).toString().padStart(2,'0')} @ ${date.getHours().toString().padStart(2,'0')}:${date.getMinutes().toString().padStart(2,'0')}:${date.getSeconds().toString().padStart(2,'0')}`
      const descriptionDisplay = il.description ? `${il.description.slice(0,50)}...` : ''
      const isSingleLotted = il.inventoryType.isSingleLotted

      return {
        ...il,
        units: il.inventoryType.units,
        updatedAtDisplay: updatedAtDisplay,
        descriptionDisplay: descriptionDisplay,
        isSingleLotted: isSingleLotted,
        histInventoryLots: {
          nodes: il.histInventoryLots.nodes
          .map(
            hil => {
              const date = new Date(hil.updatedAt)
              const updatedAtDisplay = `${date.getFullYear()}-${date.getDate().toString().padStart(2,'0')}-${(date.getMonth()+1).toString().padStart(2,'0')} @ ${date.getHours().toString().padStart(2,'0')}:${date.getMinutes().toString().padStart(2,'0')}:${date.getSeconds().toString().padStart(2,'0')}`
              const descriptionDisplay = hil.description ? `${hil.description.slice(0,50)}...` : ''
              return {
                ...hil,
                descriptionDisplay: descriptionDisplay,
                updatedAtDisplay: updatedAtDisplay,
              }          
            }
          )
        }
      }
    },
  },
   watch: {
    inventoryLots: {
      deep: true,
      handler () {
        this.itemSourcedQuantities = this.inventoryLots.reduce(
          (sq, il) => {
            return {
              ...sq,
              [il.id]: this.itemSourcedQuantities[il.id] || il.quantity
            }
          }, {}
        )
      }
    },
    itemSourcedQuantities: {
      deep: true,
      handler () {
        this.$emit('input', this.itemSourcedQuantities)
      }
    }
  },
  data () {
    return {
      itemSourcedQuantities: {}
    }
  },
}
</script>

<style>

</style>


