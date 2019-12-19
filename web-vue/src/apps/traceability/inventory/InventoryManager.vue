<template>
  <v-container>
    <h1>Inventory Manager</h1>
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


    <v-switch
      label="safe mode"
      v-model="safeMode"
    >
    </v-switch>
    
  </v-container>
</template>

<script>
import allInventoryLots from '@/graphql/query/allInventoryLots.graphql'
import lcbLookupSets from '@/graphql/query/lcbLookupSets.graphql'
import reportInventoryLots from '@/graphql/mutation/reportInventoryLots.graphql'
import invalidateInventoryLotIds from '@/graphql/mutation/invalidateInventoryLotIds.graphql'
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
    reportInventory () {
      const inventoryInfo = {
        id: this.ulid,
        inventoryType: this.selectedInventoryType.value,
        licenseeIdentifier: this.licenseeIdentifier,
        strainName: this.strainName,
        description: this.description,
        areaIdentifier: this.areaIdentifier,
        quantity: this.quantity,
      }

      this.$apollo.mutate({
        mutation: reportInventoryLots,
        variables: {
          input: [inventoryInfo]
        }
      })
      .then(result => {
        this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.reportInventoryLot.inventoryLots})
        this.selectedInventoryLot = null
        this.$apollo.queries.getInventoryLots.refetch()
      })
      .catch(error => {
        alert(error.toString())
        console.error(error)
      })

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
    invalidateInventoryLots () {
      this.$apollo.mutate({
        mutation: invalidateInventoryLotIds,
        variables: {
          ids: [this.selectedInventoryLot.id]
        }
      })
      .then(result => {
        this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.invalidateInventoryLotIds.inventoryLots})
        this.selectedInventoryLot = null
        this.$apollo.queries.getInventoryLots.refetch()
      })
      .catch(error => {
        alert(error.toString())
        console.error(error)
      })
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
      this.areaIdentifier = il ? il.areaIdentifier : this.areaIdentifier
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
          || this.selectedInventoryLot.areaIdentifier !== this.areaIdentifier
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
    reportDisabled () {
      if (!this.safeMode) return false
      if (this.selectedInventoryLot) {
        return !this.dataIsDirty || ['ACTIVE', 'PROVISIONED'].indexOf(this.selectedInventoryLot.reportingStatus) === -1
      } else {
        const quantity = parseFloat(this.quantity)
        const notNum = isNaN(quantity)
        console.log(quantity, notNum, quantity >= 0)

        if (notNum) {
          return true
        } else {
          return quantity < 0
        }
      }
    },
    destroyDisabled () {
      if (!this.safeMode) return false
      return this.selectedInventoryLot === null || this.selectedInventoryLot.reportingStatus !== 'ACTIVE'
    },
    sublotDisabled () {
      if (!this.safeMode) return false
      return this.selectedInventoryLot === null || this.selectedInventoryLot.reportingStatus !== 'ACTIVE'
    },
    qaSampleDisabled () {
      if (!this.safeMode) return false
      return this.selectedInventoryLot === null || this.selectedInventoryLot.reportingStatus !== 'ACTIVE'
    },
    rtSampleDisabled () {
      if (!this.safeMode) return false
      return this.selectedInventoryLot === null || this.selectedInventoryLot.reportingStatus !== 'ACTIVE'
    },
    conversionDisabled () {
      if (!this.safeMode) return false
      return this.selectedInventoryLot === null || this.selectedInventoryLot.reportingStatus !== 'ACTIVE'
    },
    invalidateDisabled () {
      if (!this.safeMode) return false
      return this.selectedInventoryLot === null || this.selectedInventoryLot.reportingStatus !== 'PROVISIONED'
    },
    inventoryTypeSelectDisabled () {
      if (!this.safeMode) return false
      return this.selectedInventoryLot !== null
    },
    provisionDisabled () {
      if (!this.safeMode) return false
      return false
    },
    sublotConfig () {
      return {
        parentLot: this.selectedInventoryLot,
        parentInventoryType: this.actualSelectedInventoryType,
        quantityLabel: this.quantityLabel
      }
    },
    qaSampleConfig () {
      return {
        parentLot: this.selectedInventoryLot,
        parentInventoryType: this.actualSelectedInventoryType,
        quantityLabel: this.quantityLabel
      }
    },
    rtSampleConfig () {
      return {
        parentLot: this.selectedInventoryLot,
        parentInventoryType: this.actualSelectedInventoryType,
        quantityLabel: this.quantityLabel
      }
    },
    conversionConfig () {
      return {
        parentLot: this.selectedInventoryLot,
        parentInventoryType: this.actualSelectedInventoryType,
        quantityLabel: this.quantityLabel
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
      areaIdentifier: null,
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