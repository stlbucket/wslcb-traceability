<template>
  <v-container>
    <h1>Cloning</h1>
    <inventory-lot-collection
      :inventoryLots="inventoryLots"
      :onSelectInventoryLot="onSelectInventoryLot"
    >
    </inventory-lot-collection>
  </v-container>
</template>

<script>
const sourceTypes = ['PL']
import allInventoryLots from '@/graphql/query/allInventoryLots.graphql'
import InventoryLotCollection from '../inventory/InventoryLotCollection'

export default {
  name: 'Cloning',
  components: {
    InventoryLotCollection
  },
  data () {
    return {
      inventoryLots: []
    }
  },
  methods: {
    onSelectInventoryLot (lot) {
      console.log(lot)
    }
  },
  apollo: {
    getInventoryLots: {
      query: allInventoryLots
      ,fetchPolicy: 'network-only'
      ,update (data) {
        this.inventoryLots = (data.inventoryLots || {nodes:[]}).nodes.filter(il => sourceTypes.indexOf(il.inventoryType.id) !== -1)
      }
    },
  }
}
</script>

<style>

</style>