<template>
  <v-container>
    <v-card>
      <v-toolbar>
        <v-spacer></v-spacer>
        <dialog-inventory-sublot :disabled="sublotDisabled" :sublotConfig="sublotConfig"></dialog-inventory-sublot>
        <dialog-inventory-conversion :disabled="conversionDisabled" :conversionConfig="conversionConfig" :inventoryTypes="inventoryTypes"></dialog-inventory-conversion>
        <dialog-inventory-qa-sample :disabled="qaSampleDisabled" :qaSampleConfig="qaSampleConfig"></dialog-inventory-qa-sample>
        <dialog-inventory-rt-sample :disabled="rtSampleDisabled" :rtSampleConfig="rtSampleConfig"></dialog-inventory-rt-sample>
        <dialog-inventory-destroy :disabled="destroyDisabled" :inventoryLot="inventoryLot"></dialog-inventory-destroy>
        <dialog-inventory-invalidate :disabled="invalidateDisabled" :inventoryLot="inventoryLot"></dialog-inventory-invalidate>
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
        <v-col cols="1"></v-col>
        <v-col cols="2">
          <v-btn
            @click="makeDemoData"
          >Make Demo Data</v-btn>
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
            v-model="areaName"
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

    <v-switch
      label="safe mode"
      v-model="safeMode"
    >
    </v-switch>
    
  </v-container>
</template>

<script>
import lcbLookupSets from '@/graphql/query/lcbLookupSets.graphql'
import reportInventoryLots from '@/graphql/mutation/reportInventoryLots.graphql'
import invalidateInventoryLotIds from '@/graphql/mutation/invalidateInventoryLotIds.graphql'
import {ulid} from 'ulid'
import DialogInventoryConversion from './DialogInventoryConversion'
import DialogInventoryDestroy from './DialogInventoryDestroy'
import DialogInventoryInvalidate from './DialogInventoryInvalidate'
import DialogInventoryProvision from './DialogInventoryProvision'
import DialogInventoryQaSample from './DialogInventoryQaSample'
import DialogInventoryRtSample from './DialogInventoryRtSample'
import DialogInventorySublot from './DialogInventorySublot'

export default {
  name: "InventoryLotDetail",
  components: {
    DialogInventoryConversion,
    DialogInventoryDestroy,
    DialogInventoryInvalidate,
    DialogInventoryProvision,
    DialogInventoryQaSample,
    DialogInventoryRtSample,
    DialogInventorySublot,
  },
  props: {
    inventoryLot: {
      type: Object,
      required: false
    }
  },
  methods: {
    generateUlid () {
      this.nextUlid = ulid()
      this.ulid = this.nextUlid
      // this.inventoryLot = null
    },
    reportInventory () {
      const inventoryInfo = {
        id: this.ulid,
        inventoryType: this.selectedInventoryType.value,
        licenseeIdentifier: this.licenseeIdentifier,
        strainName: this.strainName,
        description: this.description,
        areaName: this.areaName,
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
        // this.inventoryLot = null
        // this.$apollo.queries.getInventoryLots.refetch()
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
          ids: [this.inventoryLot.id]
        }
      })
      .then(result => {
        this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.invalidateInventoryLotIds.inventoryLots})
        // this.inventoryLot = null
        // this.$apollo.queries.getInventoryLots.refetch()
      })
      .catch(error => {
        alert(error.toString())
        console.error(error)
      })
    },
    makeDemoData () {
      this.$apollo.mutate({
        mutation: reportInventoryLots,
        variables: {
          input: demoDataVariables
        }
      })
      .then(result => {
        this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.reportInventoryLot.inventoryLots})
        // this.inventoryLot = null
        // this.$apollo.queries.getInventoryLots.refetch()
      })
      .catch(error => {
        alert(error.toString())
        console.error(error)
      })
    }
  },
  watch: {
    inventoryLot () {
      const il = this.inventoryLot

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
    dataIsDirty () {
      if (this.inventoryLot) {
        if (
          this.inventoryLot.licenseeIdentifier !== this.licenseeIdentifier
          || this.inventoryLot.strainName !== this.strainName
          || this.inventoryLot.description !== this.description
          || this.inventoryLot.areaName !== this.areaName
          || this.inventoryLot.quantity !== this.quantity
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
      if (this.inventoryLot) {
        return !this.dataIsDirty || ['ACTIVE', 'PROVISIONED'].indexOf(this.inventoryLot.reportingStatus) === -1
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
      return this.inventoryLot === null || this.inventoryLot.reportingStatus !== 'ACTIVE'
    },
    sublotDisabled () {
      if (!this.safeMode) return false
      return this.inventoryLot === null || this.inventoryLot.reportingStatus !== 'ACTIVE'
    },
    qaSampleDisabled () {
      if (!this.safeMode) return false
      return this.inventoryLot === null || this.inventoryLot.reportingStatus !== 'ACTIVE'
    },
    rtSampleDisabled () {
      if (!this.safeMode) return false
      return this.inventoryLot === null || this.inventoryLot.reportingStatus !== 'ACTIVE'
    },
    conversionDisabled () {
      if (!this.safeMode) return false
      return this.inventoryLot === null || this.inventoryLot.reportingStatus !== 'ACTIVE'
    },
    invalidateDisabled () {
      if (!this.safeMode) return false
      return this.inventoryLot === null || this.inventoryLot.reportingStatus !== 'PROVISIONED'
    },
    inventoryTypeSelectDisabled () {
      if (!this.safeMode) return false
      return this.inventoryLot !== null
    },
    provisionDisabled () {
      if (!this.safeMode) return false
      return false
      // return !this.selectedInventoryType || this.provisionCount < 1
    },
    sublotConfig () {
      return {
        parentLot: this.inventoryLot,
        parentInventoryType: this.actualSelectedInventoryType,
        quantityLabel: this.quantityLabel
      }
    },
    qaSampleConfig () {
      return {
        parentLot: this.inventoryLot,
        parentInventoryType: this.actualSelectedInventoryType,
        quantityLabel: this.quantityLabel
      }
    },
    rtSampleConfig () {
      return {
        parentLot: this.inventoryLot,
        parentInventoryType: this.actualSelectedInventoryType,
        quantityLabel: this.quantityLabel
      }
    },
    conversionConfig () {
      return {
        parentLot: this.inventoryLot,
        parentInventoryType: this.actualSelectedInventoryType,
        quantityLabel: this.quantityLabel,
        conversionRules: this.conversionRules
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
      conversionRules: [],
      // recentChanges: [],
      selectedInventoryType: null,
      // inventoryLot: null,
      expanded: [],
      recentExpanded: [],
      singleExpand: false,
      // provisionCount: 0,
      nextUlid: null,
      safeMode: true,
    }
  },
  apollo: {
    lcbLookupSets: {
      query: lcbLookupSets
      ,fetchPolicy: 'network-only'
      ,update (data) {
        this.inventoryTypes = (data.inventoryTypes || {nodes:[]}).nodes
        this.conversionRules = (data.conversionRules || {nodes:[]}).nodes
      }
    }
  }
}

const demoDataVariables = [
  // seeds
  {
    "id": null,
    "inventoryType": "SD",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "100"
  },
  {
    "id": null,
    "inventoryType": "SD",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "100"
  },
  {
    "id": null,
    "inventoryType": "SD",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "hoth",
    "quantity": "100"
  },
  // seedlings
  {
    "id": null,
    "inventoryType": "SL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "SL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "SL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "SL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },
  // plants
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "PL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },
  // clones
  {
    "id": null,
    "inventoryType": "CL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "CL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "CL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "CL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "CL",
    "licenseeIdentifier": null,
    "strainName": "boba fett",
    "description": null,
    "areaName": "hoth",
    "quantity": "1"
  },
  {
    "id": null,
    "inventoryType": "CL",
    "licenseeIdentifier": null,
    "strainName": "yoda",
    "description": null,
    "areaName": "dagobah",
    "quantity": "1"
  },

]
</script>