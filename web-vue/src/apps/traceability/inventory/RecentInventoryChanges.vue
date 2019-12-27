<template>
  <v-container>
    <v-toolbar 
      class="blue-grey darken-4"
    >
      <h2>Recent Changes</h2>
      <v-spacer></v-spacer>
      <v-btn @click="clearRecentChanges">Clear</v-btn>
    </v-toolbar>
    <v-tabs>
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
  name: "RecentInventoryChanges",
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
    return {}
  }
}
</script>