<template>
  <v-container>
    <h1>TRACEABILITY</h1>
    <v-tabs>
      <v-tab key="inventory">
        Inventory
      </v-tab>
      <v-tab-item key="inventory">
        <inventory-manager>
        </inventory-manager>
      </v-tab-item>
      <v-tab key="transfers">
        Transfers
      </v-tab>
      <v-tab-item key="transfers">
        TRANSFERS
      </v-tab-item>
    </v-tabs>
  </v-container>
</template>

<script>
import InventoryManager from './traceability/inventory/InventoryManager'

export default {
  name: "Traceability",
  components: {
    InventoryManager,
  },
}
</script>