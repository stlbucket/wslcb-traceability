<template>
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
        <v-text-field
          v-model="itemSourcedQuantities[item.id]"
          label="Sourced Quantity"
        >
        </v-text-field>
      </template>
    </v-data-table>
  </v-container>
</template>

<script>
export default {
  name: "InventoryConversionSourceCollection",
  components: {
  },
  props: {
    inventoryType: {
      type: Object,
      required: true
    },
    conversionRule: {
      type: Object,
      required: true
    },
    inventoryLots: {
      type: Array,
      required: true
    },
    onSelectInventoryLot: {
      type: Function,
      required: false
    },
    showSelect: {
      type: Boolean,
      default: false
    },
    onItemSourcedQuantitiesChanged: {
      type: Function,
      required: true
    }
  },
  methods: {
    captureItemSourcedQuantity (item) {
      console.log(item)
      const ref = this.$refs[item.id]
      console.log('ref', ref)
    },
    inventoryLotSelected (inventoryLot) {
      if (this.onSelectInventoryLot) this.onSelectInventoryLot(inventoryLot)
    },
    mapInventoryLot (il) {
      const date = new Date(il.updatedAt)
      const updatedAtDisplay = `${date.getFullYear()}-${date.getDate().toString().padStart(2,'0')}-${(date.getMonth()+1).toString().padStart(2,'0')} @ ${date.getHours().toString().padStart(2,'0')}:${date.getMinutes().toString().padStart(2,'0')}:${date.getSeconds().toString().padStart(2,'0')}`
      const descriptionDisplay = il.description ? `${il.description.slice(0,50)}...` : ''

      return {
        ...il,
        units: il.inventoryType.units,
        updatedAtDisplay: updatedAtDisplay,
        descriptionDisplay: descriptionDisplay,
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
    selectedItems () {
      console.log('selected', this.selectedItems)
    },
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
        this.onItemSourcedQuantitiesChanged(this.itemSourcedQuantities)
      }
    }
  },
  computed: {
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
  data () {
    return {
      expanded: [],
      recentExpanded: [],
      singleExpand: false,
      itemSourcedQuantities: {},
      selectedItems: [],
    }
  },
}
</script>