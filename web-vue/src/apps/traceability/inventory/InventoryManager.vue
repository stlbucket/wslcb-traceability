<template>
  <v-container>
    <h1>Inventory</h1>
    <inventory-lot-detail
      :inventoryLot="selectedInventoryLot"
    >
    </inventory-lot-detail>
    <v-tabs>
      <v-tab key="recent">
        Recent Changes
      </v-tab>
      <v-tab-item key="recent">
        <recent-inventory-changes
          :inventoryLots="recentChanges"
          :onSelectInventoryLot="onSelectInventoryLot"
        >
        </recent-inventory-changes>
      </v-tab-item>
      <v-tab key="all">
        All Inventory
      </v-tab>
      <v-tab-item key="all">
        <sorted-inventory
          :inventoryLots="inventoryLots"
          :onSelectInventoryLot="onSelectInventoryLot"
        ></sorted-inventory>
      </v-tab-item>
    </v-tabs>

  </v-container>
</template>

<script>
import allInventoryLots from '@/graphql/query/allInventoryLots.graphql'
import lcbLookupSets from '@/graphql/query/lcbLookupSets.graphql'
import {ulid} from 'ulid'
import InventoryLotDetail from './InventoryLotDetail'
import SortedInventory from './SortedInventory'
import RecentInventoryChanges from './RecentInventoryChanges'

export default {
  name: "InventoryManager",
  components: {
    InventoryLotDetail,
    SortedInventory,
    RecentInventoryChanges
  },
  methods: {
    generateUlid () {
      this.nextUlid = ulid()
      this.ulid = this.nextUlid
      this.selectedInventoryLot = null
    },
    inventoryLotSelected (inventoryLot) {
      this.selectedInventoryLot = inventoryLot
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
    onSelectInventoryLot (inventoryLot) {
      this.selectedInventoryLot = inventoryLot
    },
  },
  watch: {
    selectedInventoryLot () {
      const il = this.selectedInventoryLot

      this.selectedInventoryType = il ? {
        text: `${il.inventoryType.id}: ${il.inventoryType.name}`,
        value: il.inventoryType.id
      } : this.selectedInventoryType
      this.ulid = il ? il.id : this.nextUlid
      this.reportingStatus = il ? il.reportingStatus : null
      this.licenseeIdentifier = il ? il.licenseeIdentifier : null
      this.strainName = il ? il.strainName : this.strainName
      this.description = il ? il.description : this.description
      this.areaName = il ? il.areaName : this.areaName
      this.quantity = il ? il.quantity : null

      this.nextUlid = null
    }
  },
  computed: {
    mappedInventoryTypes () {
      return this.inventoryTypes
        .map(
          it => {
            return {
              text: `${it.id}: ${it.name}`,
              value: it.id
            }
          }
        )
    },
    mappedInventoryLots () {
      return this.inventoryLots
        .map(
          il => {
            return this.mapInventoryLot(il)
          }
        )
    },
    mappedRecentChanges() {
      return this.$store.state.recentInventoryLotChanges
        .map(
          il => {
            return this.mapInventoryLot(il)
          }
        )
    },
    activeLots() {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'ACTIVE')
    },
    provisionedLots() {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'PROVISIONED')
    },
    destroyedLots() {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'DESTROYED')
    },
    invalidatedLots() {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'INVALIDATED')
    },
    dataIsDirty () {
      if (this.selectedInventoryLot) {
        if (
          this.selectedInventoryLot.licenseeIdentifier !== this.licenseeIdentifier
          || this.selectedInventoryLot.strainName !== this.strainName
          || this.selectedInventoryLot.description !== this.description
          || this.selectedInventoryLot.areaName !== this.areaName
          || this.selectedInventoryLot.quantity !== this.quantity
        ) {
          return true
        } else {
          return false
        }
      } else {
        return true
      }
    },
    actualSelectedInventoryType () {
      if (this.selectedInventoryType) {
        return this.inventoryTypes.find(it => it.id === this.selectedInventoryType.value)
      } else {
        return null
      }
    },
    quantityLabel () {
      if (this.actualSelectedInventoryType) {
        return `Quantity: ${this.actualSelectedInventoryType.units}`
      } else {
        return 'Quantity'
      }
    },
    recentChanges () {
      return this.$store.state.recentInventoryLotChanges
    }
  },
  data () {
    return {
      ulid: null,
      reportingStatus: null,
      licenseeIdentifier: null,
      strainName: null,
      description: null,
      areaName: null,
      quantity: null,
      inventoryLots: [],
      inventoryTypes: [],
      selectedInventoryType: null,
      selectedInventoryLot: null,
      expanded: [],
      recentExpanded: [],
      singleExpand: false,
      nextUlid: null,
      safeMode: true,
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
          value: 'areaName'
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
          value: 'areaName'
        },
        {
          text: 'quantity',
          value: 'quantity'
        }
      ]

    }
  },
  apollo: {
    getInventoryLots: {
      query: allInventoryLots
      ,fetchPolicy: 'network-only'
      ,update (data) {
        this.inventoryLots = (data.inventoryLots || {nodes:[]}).nodes
      }
    },
    lcbLookupSets: {
      query: lcbLookupSets
      ,fetchPolicy: 'network-only'
      ,update (data) {
        this.inventoryTypes = (data.inventoryTypes || {nodes:[]}).nodes
      }
    }
  }
}
</script>