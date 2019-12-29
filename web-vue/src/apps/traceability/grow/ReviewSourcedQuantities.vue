<template>
  <v-container>
        <v-card
          class="mb-12"
          color="green"
        >
          <inventory-conversion-source-collection
            :inventoryLots="inventoryLots"
            v-model="itemSourcedQuantities"
            :conversionRule="conversionRule"
          >
          </inventory-conversion-source-collection>
        </v-card>

        <v-row>
          <v-col cols="3">
            <v-btn
              color="primary"
              @click="$emit('nextStep')"
              :disabled="continueDisabledSourceQuantities"
            >
              Continue
            </v-btn>
          </v-col>
          <v-col cols="1">
          </v-col>
          <v-col cols="3">
            <v-btn
              color="primary"
              @click="$emit('previousStep')"
            >
              Back
            </v-btn>
          </v-col>
        </v-row>
      </v-container>
</template>

<script>
import InventoryConversionSourceCollection from './InventoryConversionSourceCollection'

export default {
  name: 'ReviewSourcedQuantities',
  components: {
    InventoryConversionSourceCollection,
  },
  props: {
    inventoryLots: {
      type: Array,
      required: true
    },
    conversionRule: {
      type: Object,
      required: true
    },
    value: {
      type: Object,
      default: ()=>{}
    },
  },
  computed: {
    continueDisabledSourceQuantities () {
      return Object.values(this.itemSourcedQuantities).map(
        item => {
          return parseFloat(item)
        }
      )
      .filter(v => isNaN(v))
      .length > 0
    },
  },
  methods: {
  },
   watch: {
     itemSourcedQuantities () {
      this.$emit('input', this.itemSourcedQuantities)
     }
  },
  data () {
    return {
      itemSourcedQuantities: {}
    }
  },
}
</script>

<style>

</style>


