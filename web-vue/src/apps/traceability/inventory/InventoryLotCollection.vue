<template>
  <v-container>
    <v-data-table
      :headers="headers"
      :items="mappedInventoryLots"
      class="elevation-1"
      dense
      :single-expand="singleExpand"
      :expanded.sync="expanded"
      item-key="id"
      show-expand
      hide-default-footer
      :items-per-page="100"
      @click:row="inventoryLotSelected"
      :sort-by="'updatedAt'"
      :sort-desc="true"
    >
      <template slot="expanded-item" slot-scope="props">
        <td :colspan="headers.length + 1">
          <h3>Lot History</h3>
          <v-card>
            <v-data-table
              :headers="historyHeaders"
              :items="props.item.histInventoryLots"
              dense
              hide-default-footer
              :items-per-page="100"
              :sort-by="'updatedAt'"
              :sort-desc="true"
            >
            </v-data-table>
          </v-card>
        </td>
      </template>

    </v-data-table>
  </v-container>
</template>

<script>
export default {
  name: "InventoryLotCollection",
  components: {
  },
  props: {
    inventoryLots: {
      type: Array,
      required: true
    },
    onSelectInventoryLot: {
      type: Function,
      required: true
    }
  },
  methods: {
    inventoryLotSelected (inventoryLot) {
      this.onSelectInventoryLot(inventoryLot)
    },
    mapInventoryLot (il) {
      const date = new Date(il.updatedAt)
      const updatedAtDisplay = `${date.getFullYear()}-${date.getDate().toString().padStart(2,'0')}-${(date.getMonth()+1).toString().padStart(2,'0')} @ ${date.getHours().toString().padStart(2,'0')}:${date.getMinutes().toString().padStart(2,'0')}:${date.getSeconds().toString().padStart(2,'0')}`
      const descriptionDisplay = il.description ? `${il.description.slice(0,50)}...` : ''

      return {
        ...il,
        updatedAtDisplay: updatedAtDisplay,
        descriptionDisplay: descriptionDisplay,
        histInventoryLots: il.histInventoryLots.nodes
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
    },
},
  watch: {
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

  },
  data () {
    return {
      expanded: [],
      recentExpanded: [],
      singleExpand: false,
      headers: [
        {
          text: 'Updated At',
          value: 'updatedAtDisplay'
        },
        {
          text: 'ULID',
          value: 'id'
        },
        {
          text: 'Lot Type',
          value: 'lotType'

        },
        // {
        //   text: 'Identifier',
        //   value: 'licenseeIdentifier'
        // },
        {
          text: 'status',
          value: 'reportingStatus'
        },
        {
          text: 'inventory type',
          value: 'inventoryType.id'
        },
        {
          text: 'strain',
          value: 'strainName'
        },
        {
          text: 'description',
          value: 'descriptionDisplay'
        },
        {
          text: 'area',
          value: 'areaIdentifier'
        },
        {
          text: 'quantity',
          value: 'quantity'
        }
      ],
      historyHeaders: [
        {
          text: 'Updated At',
          value: 'updatedAtDisplay'
        },
        // {
        //   text: 'ULID',
        //   value: 'inventoryLotId'
        // },
        // {
        //   text: 'Identifier',
        //   value: 'licenseeIdentifier'
        // },
        {
          text: 'status',
          value: 'reportingStatus'
        },
        // {
        //   text: 'inventory type',
        //   value: 'inventoryType'
        // },
        {
          text: 'strain',
          value: 'strainName'
        },
        {
          text: 'description',
          value: 'descriptionDisplay'
        },
        {
          text: 'area',
          value: 'areaIdentifier'
        },
        {
          text: 'quantity',
          value: 'quantity'
        }
      ]

    }
  }
}
</script>