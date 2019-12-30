<template>
  <v-container>
    <v-card
      class="mb-12"
      color="green"
    >
    <v-radio-group row v-model="selectedInventoryTypeId">
      <v-radio v-for="it in availableInventoryTypes" :key="it.id" :label="it.name" :value="it.id"></v-radio>
    </v-radio-group>
      <inventory-lot-collection
        :inventoryLots="filteredInventoryLots"
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
      default: ()=>[]
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
    availableInventoryTypes () {
      return this.conversionRule.conversionRuleSources.nodes.map(crs => crs.inventoryType)
    },
    filteredInventoryLots () {
      return this.inventoryLots.filter(il => il.inventoryType.id === this.selectedInventoryTypeId)
    }
  },
  methods: {
  },
  watch: {
    selectedInventoryLots () {
      this.$emit('input', this.selectedInventoryLots)
    },
    selectedInventoryTypeId () {
      this.selectedInventoryLots = []
    }
  },
  data () {
    return {
      selectedInventoryLots: [],
      selectedInventoryTypeId: null
    }
  },
  mounted () {
    this.selectedInventoryTypeId = this.availableInventoryTypes[0].id
  }
}
</script>

<style>

</style>


