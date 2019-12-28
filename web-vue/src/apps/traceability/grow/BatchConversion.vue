<template>
  <v-container>
    <h1>{{titleDisplay}}</h1>
    <h2 v-if="conversionRule && conversionRule.isNonDestructive">non-destructive</h2>
    <v-row>
      <v-col :cols="3" v-if="allStrains.length > 0">
        <h2>Strain</h2>
        <!-- <div v-if="allStrains.length === 1">
          <h3>{{selectedStrain.name}}</h3>
        </div> -->
        <v-combobox
          placeholder="select strain"
          :items="allStrains"
          :item-text="'strain_name'"
          :item-value="'strain_id'"
          v-model="selectedStrain"
        >
        </v-combobox>
      </v-col>
      <v-col :cols="3" v-else>
        <h2>Sorry, bro.  You got no inventory to convert.</h2>
      </v-col>

      <v-col :cols="2">
      </v-col>

      <v-col :cols="3">
        <h2>Target Type</h2>
        <h3>{{targetTypeDisplay}}</h3>
      </v-col>

      <v-col :cols="3">
        <h2>Source Inventory Type</h2>
        <h3 v-for="st in sourceTypesDisplay" :key="st">{{st}}</h3>
      </v-col>
    </v-row>

    <v-stepper v-model="currentStep" non-linear v-if="allInventoryLots.length > 0">
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
          color="green"
        >
          <inventory-lot-collection
            :inventoryLots="allInventoryLots"
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
          color="green"
        >
          <inventory-conversion-source-collection
            :inventoryLots="selectedInventoryLots"
            :onItemSourcedQuantitiesChanged="onItemSourcedQuantitiesChanged"
            :inventoryType="selectedSourceInventoryType"
            :conversionRule="conversionRule"
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
          color="green"
        >
          <h2>total sourced quantity: {{ totalSourcedQuantity }}</h2>
          <v-container v-for="tli in targetLotInfos" :key="tli.index">
            <v-text-field
              label="quantity"
            ></v-text-field>
          </v-container>
          <v-btn
            @click="addTargetLotInfo"
          >Add Lot</v-btn>
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
          color="green"
        >
          <!-- <h2>pizza</h2>
          <h2>New Seedlings</h2>
          <inventory-conversion-source-collection
            :inventoryLots="newSeedlings"
            :onItemSourcedQuantitiesChanged="onItemSourcedQuantitiesChanged"
          >
          </inventory-conversion-source-collection> -->
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
import conversionRuleByInventoryTypeId from '@/graphql/query/conversionRuleByInventoryTypeId.graphql'
// import strainCountsForInventoryTypes from '@/graphql/query/strainCountsForInventoryTypes.graphql'
import strainInventoryTypeLotCounts from '@/graphql/mutation/strainInventoryTypeLotCounts.graphql'
import inventoryLotsForConversion from '@/graphql/query/inventoryLotsForConversion.graphql'
// import inventoryTypeLotCountsForStrain from '@/graphql/query/inventoryTypeLotCountsForStrain.graphql'

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
  computed: {
    titleDisplay () {
      return `Batch Conversion ${this.selectedSourceInventoryType ? `${this.selectedSourceInventoryType.name}` : ''} ${this.conversionRule ? `to ${this.conversionRule.name}` : ''}`
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
    queryInventoryLots () {
      this.$apollo.query({
        query: inventoryLotsForConversion,
        fetchPolicy: 'network-only',
        variables: {
          strainId: this.selectedStrain.strain_id,
          inventoryTypeIds: this.inventoryTypes.map(it => it.id)
        }
      })
      .then(result => {
        this.allInventoryLots = result.data.allInventoryLots.nodes
        this.availableSourceInventoryTypes = this.allInventoryLots.map(il => il.inventoryType).reduce(
          (all, it) => {
            const existing = all.find(a => a.id === it.id)
            return existing ? all : [...all, it]
          }, []
        )
      })
      .catch(e => {
        console.error(e)
      })
    },
    queryStrainCounts () {
      // const inventoryTypeIds = this.conversionRule.conversionRuleSources.nodes.map(csr => csr.inventoryType.id)
      this.$apollo.mutate({
        mutation: strainInventoryTypeLotCounts,
        fetchPolicy: 'no-cache',
      })
      .then(result => {
        const crsInventoryTypeIds = this.conversionRule.conversionRuleSources.nodes.map(crs => crs.inventoryType.id)
        this.strainInventoryTypeLotCounts = result.data.strainInventoryTypeLotCounts.json
        this.allStrains = this.strainInventoryTypeLotCounts
          .filter(sitlc => sitlc.count > 0 && crsInventoryTypeIds.indexOf(sitlc.inventory_type) > -1)
        this.selectedStrain = this.allStrains.length === 1 ? this.allStrains[0] : null
      })
      .catch(e => {
        console.error(e)
      })
    },
    addTargetLotInfo () {
      this.targetLotInfos = [...this.targetLotInfos, {quantity: 0}]
    },
  },
   watch: {
    selectedStrain () {
      if (!this.selectedStrain) { return }
      // this.availableSourceInventoryTypes = this.sourceInventoryTypes.filter(
      //   it => {
      //     const sitlc = this.strainInventoryTypeLotCounts.filter(sitlc => sitlc.strain_id === this.selectedStrain.id && sitlc.inventory_type === it.id)
      //     return sitlc ? true : false
      //   }
      // )
      this.queryInventoryLots()
    },
    selectedSourceInventoryType () {
      if (!this.selectedSourceInventoryType) { return }
      // this.queryInventoryLots()
    },
    conversionRule () {
      if (!this.conversionRule) { return }
      this.sourceInventoryTypes = this.conversionRule.conversionRuleSources.nodes.map(crs => crs.inventoryType)
      this.selectedSourceInventoryType = this.sourceInventoryTypes[0]
      this.queryStrainCounts()
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
      }
    },
  },
  data () {
    return {
      currentStep: 1,
      allInventoryLots: [],
      allStrains: [],
      selectedStrain: null,
      allAreas: [],
      sourceInventoryTypes: [],
      availableSourceInventoryTypes: [],
      selectedSourceInventoryType: null,
      selectedInventoryLots: [],
      itemSourcedQuantities: {},
      conversionRule: null,
      targetLotInfos: [],
      strainInventoryTypeLotCounts: []
    }
  },
  beforeRouteUpdate (to, from, next) {
    this.selectedStrain = null
    this.selectedInventoryLots = []
    this.allInventoryLots = []
    this.selectedSourceInventoryType = null;
    this.$apollo.queries.initConversionRule.refetch()
    next()
  }
}
</script>

<style>

</style>


