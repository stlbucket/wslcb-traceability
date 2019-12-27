<template>
  <v-container>
    <v-toolbar 
      class="blue-grey darken-4"
    >
      <h2>Inventory Lots</h2>
    </v-toolbar>
    <v-tabs v-model="activeTab">
      <v-tab
        key="active"
      >
        Active
      </v-tab>
      <v-tab-item
        key="active"
      >
        <inventory-lot-collection
          :inventoryLots="activeLots"
          :onSelectInventoryLot="onSelectInventoryLot"
        >
        </inventory-lot-collection>
      </v-tab-item>
      
      <v-tab
        key="provisioned"
      >
        Provisioned
      </v-tab>
      <v-tab-item
        key="provisioned"
      >
        <inventory-lot-collection
          :inventoryLots="provisionedLots"
          :onSelectInventoryLot="onSelectInventoryLot"
        >
        </inventory-lot-collection>
      </v-tab-item>
      
      <v-tab
        key="depleted"
      >
        Depleted
      </v-tab>
      <v-tab-item
        key="depleted"
      >
        <inventory-lot-collection
          :inventoryLots="depletedLots"
          :onSelectInventoryLot="onSelectInventoryLot"
        >
        </inventory-lot-collection>
      </v-tab-item>
      
      <v-tab
        key="destroyed"
      >
        Destroyed
      </v-tab>
      <v-tab-item
        key="destroyed"
      >
        <inventory-lot-collection
          :inventoryLots="destroyedLots"
          :onSelectInventoryLot="onSelectInventoryLot"
        >
        </inventory-lot-collection>
      </v-tab-item>
      
      <v-tab
        key="invalidated"
      >
        Invalidated
      </v-tab>
      <v-tab-item
        key="invalidated"
      >
        <inventory-lot-collection
          :inventoryLots="invalidatedLots"
          :onSelectInventoryLot="onSelectInventoryLot"
        >
        </inventory-lot-collection>
      </v-tab-item>

    </v-tabs>
  </v-container>
</template>

<script>
import InventoryLotCollection from './InventoryLotCollection'

export default {
  name: "SortedInventory",
  components: {
    InventoryLotCollection
  },
  methods: {
    clearRecentChanges () {
      this.$store.commit('clearRecentChanges')
    },
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
  watch: {
    activeTab () {
      this.$store.commit('setUserTabStatus', { 
        tabName: 'sortedInventory',
        tabValue: this.activeTab
      })
    }
  },
  computed: {
    activeLots() {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'ACTIVE')
    },
    provisionedLots() {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'PROVISIONED')
    },
    depletedLots () {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'DEPLETED')
    },
    destroyedLots() {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'DESTROYED')
    },
    invalidatedLots() {
      return this.inventoryLots
        .filter(il => il.reportingStatus === 'INVALIDATED')
    },
  },
  data () {
    return {
      activeTab: 0
    }
  },
  mounted () {
    const tabStatus = this.$store.state.userAppState.tabStatus.find(ts => ts.tabName === 'sortedInventory')
    this.activeTab = tabStatus ? tabStatus.tabValue : 0
  }
}
</script>