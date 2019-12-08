<template>
  <v-container>
    <h1>WSLCB TRACEABILITY</h1>
    <v-card>
      <v-toolbar>
        <v-spacer></v-spacer>
        <dialog-inventory-sublot :disabled="sublotDisabled" :sublotConfig="sublotConfig"></dialog-inventory-sublot>
        <dialog-inventory-conversion :disabled="conversionDisabled" :conversionConfig="conversionConfig" :inventoryTypes="inventoryTypes"></dialog-inventory-conversion>
        <dialog-inventory-qa-sample :disabled="qaSampleDisabled" :qaSampleConfig="qaSampleConfig"></dialog-inventory-qa-sample>
        <dialog-inventory-rt-sample :disabled="rtSampleDisabled" :rtSampleConfig="rtSampleConfig"></dialog-inventory-rt-sample>
        <dialog-inventory-destroy :disabled="destroyDisabled" :inventoryLot="selectedInventoryLot"></dialog-inventory-destroy>
        <dialog-inventory-invalidate :disabled="invalidateDisabled" :inventoryLot="selectedInventoryLot"></dialog-inventory-invalidate>
        <dialog-inventory-provision :disabled="provisionDisabled" :mappedInventoryTypes="mappedInventoryTypes" :initialInventoryType="selectedInventoryType"></dialog-inventory-provision>
        <v-spacer></v-spacer>
      </v-toolbar>
      <v-row>
        <v-col cols="2">
          <v-combobox
            v-model="selectedInventoryType"
            :items="mappedInventoryTypes"
            label="Inventory Type"
            :disabled="inventoryTypeSelectDisabled"
          ></v-combobox>
        </v-col>
        <v-col cols="2">
          <v-text-field
            label="Reporting Status"
            v-model="reportingStatus"
            disabled
          ></v-text-field>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="2">
          <v-text-field
            label="Strain"
            v-model="strainName"
          ></v-text-field>
        </v-col>
        <v-col cols="6">
          <v-text-field
            label="Description"
            v-model="description"
          ></v-text-field>
        </v-col>
        <v-col cols="2">
          <v-text-field
            label="Area"
            v-model="areaIdentifier"
          ></v-text-field>
        </v-col>
      </v-row>
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
          <v-btn @click="generateUlid">Generate</v-btn>
        </v-col>
        <v-col cols="2">
          <v-text-field
            :label="quantityLabel"
            v-model="quantity"
          ></v-text-field>
          <v-btn @click="reportInventory" :disabled="reportDisabled">Report</v-btn>
        </v-col>
      </v-row>
    </v-card>

    <v-toolbar 
      class="blue-grey darken-4"
    >
      <h2>Recent Changes</h2>
      <v-spacer></v-spacer>
      <v-btn @click="clearRecentChanges">Clear</v-btn>
    </v-toolbar>
    <inventory-lot-collection
      :inventoryLots="recentChanges"
      :onSelectInventoryLot="inventoryLotSelected"
    >
    </inventory-lot-collection>

    <v-toolbar 
      class="blue-grey darken-4"
    >
      <h2>Inventory Lots</h2>
    </v-toolbar>
    <v-tabs>
      <v-tab>Active</v-tab>
      
      <v-tab>Provisioned</v-tab>
      <v-tab>Depleted</v-tab>
      <v-tab>Destroyed</v-tab>
      <v-tab>Invalidated</v-tab>
    </v-tabs>
    <inventory-lot-collection
      :inventoryLots="inventoryLots"
      :onSelectInventoryLot="inventoryLotSelected"
    >
    </inventory-lot-collection>
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
import DialogInventoryConversion from './LcbTraceability/DialogInventoryConversion'
import DialogInventoryDestroy from './LcbTraceability/DialogInventoryDestroy'
import DialogInventoryInvalidate from './LcbTraceability/DialogInventoryInvalidate'
import DialogInventoryProvision from './LcbTraceability/DialogInventoryProvision'
import DialogInventoryQaSample from './LcbTraceability/DialogInventoryQaSample'
import DialogInventoryRtSample from './LcbTraceability/DialogInventoryRtSample'
import DialogInventorySublot from './LcbTraceability/DialogInventorySublot'
import InventoryLotCollection from './LcbTraceability/InventoryLotCollection'

export default {
  name: "WSLCBTraceability",
  components: {
    DialogInventoryConversion,
    DialogInventoryDestroy,
    DialogInventoryInvalidate,
    DialogInventoryProvision,
    DialogInventoryQaSample,
    DialogInventoryRtSample,
    DialogInventorySublot,
    InventoryLotCollection
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
    clearRecentChanges () {
      this.$store.commit('clearRecentChanges')
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
    sublotInventoryLots () {

    },
    convertInventoryLots () {

    },
    sampleInventoryLots () {

    }
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
    mappedInventoryLots() {
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
      // } else if (this.selectedInventoryType && this.ulid) {
      //   const quantity = parseFloat(this.quantity)
      //   const notNum = isNaN(quantity)
      //   console.log(quantity, notNum, quantity >= 0)

      //   if (notNum) {
      //     return true
      //   } else {
      //     return quantity < 0
      //   }
      // } else if (this.selectedInventoryType && this.licenseeIdentifier) {
      //   const quantity = parseFloat(this.quantity)
      //   const notNum = isNaN(quantity)
      //   console.log(quantity, notNum, quantity >= 0)

      //   if (notNum) {
      //     return true
      //   } else {
      //     return quantity < 0
      //   }
      // } else {
      //   return true
      // }
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
      // return !this.selectedInventoryType || this.provisionCount < 1
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
      // recentChanges: [],
      selectedInventoryType: null,
      selectedInventoryLot: null,
      expanded: [],
      recentExpanded: [],
      singleExpand: false,
      // provisionCount: 0,
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