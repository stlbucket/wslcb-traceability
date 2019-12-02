<template>
  <v-container>
    <h1>WSLCB TRACEABILITY</h1>
    <v-card>
      <v-row>
        <v-col cols="3">
          <v-combobox
            v-model="selectedInventoryType"
            :items="mappedInventoryTypes"
            label="Select Inventory Type"
            :disabled="inventoryTypeSelectDisabled"
          ></v-combobox>
        </v-col>
        <v-col cols="3">
          <v-text-field
            label="ULID"
            v-model="ulid"
          ></v-text-field>
          <v-btn @click="generateUlid">Generate</v-btn>
        </v-col>
        <v-col cols="3">
          <v-text-field
            label="Licensee Identifier"
            v-model="licenseeIdentifier"
          ></v-text-field>
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
        <v-col cols="3">
          <v-text-field
            label="Strain"
            v-model="strainName"
          ></v-text-field>
        </v-col>
        <v-col cols="8">
          <v-text-field
            label="Description"
            v-model="description"
          ></v-text-field>
        </v-col>
      </v-row>
      <v-row>
        <v-col cols="3">
          <v-text-field
            label="Area"
            v-model="areaIdentifier"
          ></v-text-field>
        </v-col>
        <v-col cols="2">
          <v-text-field
            :label="quantityLabel"
            v-model="quantity"
          ></v-text-field>
        </v-col>
        <v-col cols="2">
          <v-btn @click="reportInventory" :disabled="reportDisabled">Report</v-btn>
        </v-col>
        <v-col cols="2">
          <v-btn :disabled="destroyDisabled" @click="destroyInventoryLots">Destroy</v-btn>
          <v-btn :disabled="invalidateDisabled" @click="invalidateInventoryLots">Invalidate</v-btn>
        </v-col>
        <v-col cols="2">
          <v-text-field
            label="Number of ULIDS"
            v-model="provisionCount"
          ></v-text-field>
          <v-btn :disabled="provisionDisabled" @click="provisionInventoryLotIds">Provision</v-btn>
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
    <v-data-table
      :headers="headers"
      :items="mappedRecentChanges"
      class="elevation-1"
      dense
      :single-expand="singleExpand"
      :expanded.sync="recentExpanded"
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

    <v-toolbar 
      class="blue-grey darken-4"
    >
      <h2>Inventory Lots</h2>
    </v-toolbar>
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
import provisionInventoryLotIds from '@/graphql/mutation/provisionInventoryLotIds.graphql'
import invalidateInventoryLotIds from '@/graphql/mutation/invalidateInventoryLotIds.graphql'
import destroyInventoryLotIds from '@/graphql/mutation/destroyInventoryLotIds.graphql'
import {ulid} from 'ulid'

export default {
  name: "WSLCBTraceability",
  components: {
  },
  methods: {
    generateUlid () {
      this.nextUlid = ulid()
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
        this.selectedInventoryLot = null
        this.$apollo.queries.getInventoryLots.refetch()
      })
      .catch(error => {
        alert(error.toString())
        console.error(error)
      })
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
    destroyInventoryLots () {
      this.$apollo.mutate({
        mutation: destroyInventoryLotIds,
        variables: {
          ids: [this.selectedInventoryLot.id]
        }
      })
      .then(result => {
        this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.destroyInventoryLotIds.inventoryLots})
        this.selectedInventoryLot = null
        this.$apollo.queries.getInventoryLots.refetch()
      })
      .catch(error => {
        alert(error.toString())
        console.error(error)
      })
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
      } else if (this.selectedInventoryType && this.ulid) {
        const quantity = parseFloat(this.quantity)
        const notNum = isNaN(quantity)
        console.log(quantity, notNum, quantity >= 0)

        if (notNum) {
          return true
        } else {
          return quantity < 0
        }
      } else if (this.selectedInventoryType && this.licenseeIdentifier) {
        const quantity = parseFloat(this.quantity)
        const notNum = isNaN(quantity)
        console.log(quantity, notNum, quantity >= 0)

        if (notNum) {
          return true
        } else {
          return quantity < 0
        }
      } else {
        return true
      }
    },
    destroyDisabled () {
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
      return !this.selectedInventoryType || this.provisionCount < 1
    },
    quantityLabel () {
      if (this.selectedInventoryType) {
        const inventoryType = this.inventoryTypes.find(it => it.id === this.selectedInventoryType.value)
        return `Quantity: ${inventoryType.units}`
      } else {
        return 'Quantity'
      }
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
      recentChanges: [],
      selectedInventoryType: null,
      selectedInventoryLot: null,
      expanded: [],
      recentExpanded: [],
      singleExpand: false,
      provisionCount: 0,
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
          text: 'Identifier',
          value: 'licenseeIdentifier'
        },
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
        {
          text: 'ULID',
          value: 'inventoryLotId'
        },
        {
          text: 'Identifier',
          value: 'licenseeIdentifier'
        },
        {
          text: 'status',
          value: 'reportingStatus'
        },
        {
          text: 'inventory type',
          value: 'inventoryType'
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