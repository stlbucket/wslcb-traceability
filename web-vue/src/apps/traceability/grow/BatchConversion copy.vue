<template>
  <v-container>
    <h1>{{titleDisplay}}</h1>
    <v-row>
      <v-col :cols="3">
        <h2>Source Types</h2>
        <h3 v-for="st in sourceTypesDisplay" :key="st">{{st}}</h3>
      </v-col>
      <v-col :cols="3">
        <h2>Target Type</h2>
        <h3>{{targetTypeDisplay}}</h3>
      </v-col>
    </v-row>

    <v-stepper v-model="currentStep" non-linear>
      <v-stepper-step
        :key="`select-inventory-step`"
        :step="1"
        :complete="selectedInventoryLots.length > 0"
      >
        Select Source Inventory
      </v-stepper-step>

      <v-stepper-content
        :key="`select-inventory-content`"
        :step="1"
      >
        <v-card
          class="mb-12"
          color="grey lighten-1"
        >
          <v-container 
            v-for="cfg in sourceQuantitiesConfig"
            :key="`${cfg.inventoryType.id}`"
          >
            <h2>All {{cfg.inventoryType.name}} Lots</h2>
            <inventory-lot-collection
              :inventoryLots="cfg.inventoryLots"
              :onSelectedInventoryLots="onSelectedInventoryLots"
              :showSelect="true"
            >
            </inventory-lot-collection>
          </v-container>
        </v-card>

        <v-btn
          color="primary"
          @click="nextStep()"
          :disabled="continueDisabledSelectLots"
        >
          Continue
        </v-btn>

      </v-stepper-content>

      <v-stepper-step
        :key="`source-quantity-step`"
        :step="2"
      >
        Specify Sourced Quantities
      </v-stepper-step>

      <v-stepper-content
        :key="`source-quantity-content`"
        :step="2"
      >
        <v-card
          class="mb-12"
          color="grey lighten-1"
        >
          <inventory-conversion-source-collection
            :inventoryLots="selectedInventoryLots"
            :onItemSourcedQuantitiesChanged="onItemSourcedQuantitiesChanged"
          >
          </inventory-conversion-source-collection>
        </v-card>

        <v-btn
          color="primary"
          @click="currentStep += 1"
          :disabled="continueDisabledSourceQuantities"
        >
          Continue
        </v-btn>

        <v-btn
          color="primary"
          @click="currentStep -= 1"
        >
          Back
        </v-btn>
      </v-stepper-content>

      <v-stepper-step
        :key="`target-lots-step`"
        :step="3"
      >
        Describe New Inventory Lots
      </v-stepper-step>

      <v-stepper-content
        :key="`target-lots-content`"
        :step="3"
      >
        <v-card
          class="mb-12"
          color="grey lighten-1"
        >
          <h2>total sourced quantity: {{ totalSourcedQuantity }}</h2>
        </v-card>

        <v-btn
          color="primary"
          @click="currentStep += 1"
          :disabled="continueDisabledDescribeNewLots"
        >
          Continue
        </v-btn>

        <v-btn
          color="primary"
          @click="currentStep -= 1"
        >
          Back
        </v-btn>
        <v-btn
          @click="convert"
          :disabled="convertDisabled"
        >
          Plant Seeds
        </v-btn>
      </v-stepper-content>

      <v-stepper-step
        :key="`review-results-step`"
        :step="4"
      >
        Review Newly Created Inventory Lots
      </v-stepper-step>

      <v-stepper-content
        :key="`review-results-content`"
        :step="4"
      >
        <v-card
          class="mb-12"
          color="grey lighten-1"
        >
          <h2>pizza</h2>
          <h2>New Seedlings</h2>
          <inventory-conversion-source-collection
            :inventoryLots="newSeedlings"
            :onItemSourcedQuantitiesChanged="onItemSourcedQuantitiesChanged"
          >
          </inventory-conversion-source-collection>
        </v-card>

        <v-btn
          color="primary"
          @click="currentStep += 1"
          :disabled="continueDisabledReviewCreatedLots"
        >
          Continue
        </v-btn>

        <v-btn
          color="primary"
          @click="currentStep -= 1"
        >
          Back
        </v-btn>
      </v-stepper-content>
    </v-stepper>
  </v-container>
</template>

<script>
import allInventoryLots from '@/graphql/query/allInventoryLots.graphql'
import conversionRuleByInventoryTypeId from '@/graphql/query/conversionRuleByInventoryTypeId.graphql'
import InventoryConversionSourceCollection from '../inventory/InventoryConversionSourceCollection'
import InventoryLotCollection from '../inventory/InventoryLotCollection'

export default {
  name: 'BatchConversion',
  components: {
    InventoryLotCollection,
    InventoryConversionSourceCollection
  },
  props: {
    toInventoryType: {
      type: String,
      required: true
    },
    appName: {
      type: String,
      required: false
    }
  },
  data () {
    return {
      currentStep: 1,
      selectedInventoryLots: [],
      inventoryLots: null,
      newSeedlings: [],
      itemSourcedQuantities: {},
      conversionRule: null,
      sourceQuantitiesConfig: [
        {
          inventoryType: { id: 'N/A', name: 'N/A' },
          inventoryLots: []
        }
      ] 
    }
  },
  methods: {
    nextStep () {
      this.currentStep = this.currentStep + 1
    },
    onSelectedInventoryLots (lots) {
      this.selectedInventoryLots = lots
    },
    onItemSourcedQuantitiesChanged (itemSourcedQuantities) {
      this.itemSourcedQuantities = itemSourcedQuantities
    },
    convert () {
      const sourcesInfo = Object.keys(this.itemSourcedQuantities).map(
        id => {
          return {
            id: id,
            quantity: this.itemSourcedQuantities[id]
          }
        }
      )
      // const newLotsInfo = [
      //   {
      //     description: 'conversion result',
      //     quantity: this.quantity,
      //     inventoryType: this.conversionConfig.parentLot.inventoryType.id
      //   }
      // ]

      console.log('sources', sourcesInfo)
      // console.log('newLots', newLotsInfo)

      // this.$apollo.mutate({
      //   mutation: conversionInventory,
      //   variables: {
      //     sourcesInfo: sourcesInfo,
      //     newLotsInfo: newLotsInfo
      //   }
      // })
      // .then(result => {
      //   this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.convertInventory.inventoryLots})
      //   this.dialog = false
      // })
      // .catch(error => {
      //   alert(error.toString())
      //   console.error(error)
      // })
    },
    buildSourceQuantitiesConfig () {
      if (!this.conversionRule || !this.inventoryLots) { return }

      this.sourceQuantitiesConfig = this.conversionRule.conversionRuleSources.nodes
      .map(
        st => {
          const inventoryType = st.inventoryType
          const inventoryLots = this.inventoryLots.filter(il => il.inventoryType.id === inventoryType.id && il.reportingStatus === 'ACTIVE')

          return {
            inventoryType: inventoryType,
            inventoryLots: inventoryLots
          }
        }
      )
    }
  },
  computed: {
    titleDisplay () {
      return this.conversionRule ? `Batch Conversion to ${this.conversionRule.name}` : 'Batch Conversion'
      // return this.conversionRule ? `Batch Conversion to ${this.conversionRule.toInventoryType.name}` : 'Batch Conversion'
    },
    inventoryTypes () {
      return this.$store.state.inventoryTypes
    },
    sourceTypesDisplay () {
      if (!this.conversionRule) return []

      return this.conversionRule.conversionRuleSources.nodes
        .map(crs => `${crs.inventoryType.id}: ${crs.inventoryType.name}`)
    },
    targetTypeDisplay () {
      if (!this.conversionRule) return []

      const it = this.conversionRule.toInventoryType
      return `${it.id}: ${it.name}`
    },
    totalSourcedQuantity () {
      return Object.values(this.itemSourcedQuantities).reduce(
        (total, item) => {
          return total + parseFloat(item)
        }, 0
      )

    },
    continueDisabledSelectLots () {
      return this.selectedInventoryLots.length === 0
    },
    continueDisabledSourceQuantities () {
      return Object.values(this.itemSourcedQuantities).map(
        item => {
          return parseFloat(item)
        }
      )
      .filter(v => isNaN(v))
      .length > 0
    },
    continueDisabledDescribeNewLots () {
      return this.selectedInventoryLots.length === 0
    },
    continueDisabledReviewCreatedLots () {
      return false
    },
    convertDisabled () {
      return this.selectedInventoryLots.length === 0
    },
  },
  watch: {
    conversionRule () {
      this.buildSourceQuantitiesConfig()
    },
    inventoryLots () {
      this.buildSourceQuantitiesConfig()
    }
  },
  apollo: {
    initConversionRule: {
      query: conversionRuleByInventoryTypeId,
      fetchPolicy: 'network-only',
      variables () {
        return {
          toInventoryTypeId: this.toInventoryType
        }
      },
      update (data) {
        this.conversionRule = data.conversionRuleByToInventoryTypeId
        // this.sourceQuantitiesConfig = this.conversionRule.conversionRuleSources.nodes
        // .map(
        //   st => {
        //     const inventoryType = st.inventoryType
        //     const inventoryLots = this.inventoryLots.filter(il => il.inventoryType.id === inventoryType.id && il.reportingStatus === 'ACTIVE')

        //     return {
        //       inventoryType: inventoryType,
        //       inventoryLots: inventoryLots
        //     }
        //   }
        // )
      }
    },
    getInventoryLots: {
      query: allInventoryLots
      ,fetchPolicy: 'network-only'
      ,update (data) {
        this.inventoryLots = (data.inventoryLots || {nodes:[]}).nodes
      }
    },
  }
}
</script>

<style>

</style>