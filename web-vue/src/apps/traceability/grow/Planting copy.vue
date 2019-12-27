<template>
  <v-container>
    <h1>{{recipeDefinition.name}}</h1>
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
        
          <h2
            v-for="cfg in sourceQuantitiesConfig"
            :key="`hdr-${cfg.inventoryType.id}`"
          >All {{cfg.inventoryType.name}} Lots</h2>
          <inventory-lot-collection
            v-for="cfg in sourceQuantitiesConfig"
            :key="`dt-${cfg.inventoryType.id}`"
            :inventoryLots="cfg.inventoryLots"
            :onSelectedInventoryLots="onSelectedInventoryLots"
            :showSelect="true"
          >
          </inventory-lot-collection>
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
// import lcbLookupSets from '@/graphql/query/lcbLookupSets.graphql'
import allInventoryLots from '@/graphql/query/allInventoryLots.graphql'
import InventoryConversionSourceCollection from '../inventory/InventoryConversionSourceCollection'
import InventoryLotCollection from '../inventory/InventoryLotCollection'

export default {
  name: 'Planting',
  components: {
    InventoryLotCollection,
    InventoryConversionSourceCollection
  },
  data () {
    return {
      currentStep: 1,
      selectedInventoryLots: [],
      inventoryLots: [],
      // inventoryTypes: [],
      newSeedlings: [],
      itemSourcedQuantities: {},
      recipeDefinition: {
        name: 'Planting',
        sourceTypes: ['SD'],
        targetType: 'SL'
      },
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
    }
  },
  computed: {
    inventoryTypes () {
      return this.$store.state.inventoryTypes
    },
    sourceTypesDisplay () {
      return this.inventoryTypes
        .filter(it => this.recipeDefinition.sourceTypes.indexOf(it.id) > -1)
        .map(it => `${it.id}: ${it.name}`)
    },
    targetTypeDisplay () {
      return this.inventoryTypes
        .filter(it => it.id === this.recipeDefinition.targetType)
        .map(it => `${it.id}: ${it.name}`)[0]
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
    // totalSourcedQuantity () {
    //   return this.selectedInventoryLots.reduce(
    //     (total, il) => {
    //       return total + il.sourced
    //     }
    //   )
    // }
  },
  apollo: {
    getInventoryLots: {
      query: allInventoryLots
      ,fetchPolicy: 'network-only'
      ,update (data) {
        // this.inventoryLots = (data.inventoryLots || {nodes:[]}).nodes.filter(il => this.recipeDefinition.sourceTypes.indexOf(il.inventoryType.id) !== -1)
        this.inventoryLots = (data.inventoryLots || {nodes:[]}).nodes
        console.log('heyoo', data)
        this.sourceQuantitiesConfig = this.recipeDefinition.sourceTypes
        .map(
          st => {
            const inventoryType = this.inventoryTypes.find(it => it.id === st)
            const inventoryLots = this.inventoryLots.filter(il => il.inventoryType.id === st)

            return {
              inventoryType: inventoryType,
              inventoryLots: inventoryLots
            }
          }
        )
        console.log('bayou', this.sourceQuantitiesConfig)
      }
    },
  }
}
</script>

<style>

</style>