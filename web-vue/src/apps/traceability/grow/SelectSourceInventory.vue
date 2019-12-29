<template>
  <v-container>
    <v-card
      class="mb-12"
      color="green"
    >
      <inventory-lot-collection
        :inventoryLots="inventoryLots"
        v-model="selectedInventoryLots"
        :showSelect="true"
      >
      </inventory-lot-collection>
    </v-card>

    <v-row>
      <v-col cols="3">
        <v-btn
          color="primary"
          @click="$emit('nextStep')"
          :disabled="disabled"
        >
          Continue
        </v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import InventoryLotCollection from '../inventory/InventoryLotCollection'

export default {
  name: 'SelectSourceInventory',
  components: {
    InventoryLotCollection,
  },
  props: {
    conversionRule: {
      type: Object,
      required: true
    },
    inventoryLots: {
      type: Array,
      required: true
    },
    value: {
      type: Array,
      default: ()=>[]
    }
  },
  computed: {
    disabled () {
      return this.value.length === 0
    },
  },
  methods: {
  },
  watch: {
    selectedInventoryLots () {
      this.$emit('input', this.selectedInventoryLots)
    }
  },
  data () {
    return {
      selectedInventoryLots: []
    }
  },
  // mounted () {
  //   this.selectedInventoryLots = this.value
  // }
}
</script>

<style>

</style>


