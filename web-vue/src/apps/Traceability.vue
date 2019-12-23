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
        <transfer-manager>
        </transfer-manager>
      </v-tab-item>
    </v-tabs>
  </v-container>
</template>

<script>
import InventoryManager from './traceability/inventory/InventoryManager'
import TransferManager from './traceability/transfers/TransferManager'

export default {
  name: "Traceability", 
  components: {
    InventoryManager,
    TransferManager
  },
}
</script>