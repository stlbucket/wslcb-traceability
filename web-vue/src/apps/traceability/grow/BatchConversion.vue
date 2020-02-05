<template>
  <v-container>
    <h1>{{titleDisplay}}</h1>
    <h2>{{ruleInfoDisplay}}</h2>
    <v-row>
      <v-col :cols="3" v-if="allStrains.length > 0">
        <h2>Strain</h2>
        <v-combobox
          placeholder="select strain"
          :items="allStrains"
          :item-text="'strainName'"
          :item-value="'strainId'"
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
      <!-- step 1 - select inventory -->      
      <v-stepper-step
        :key="`select-inventory-step`"
        :step="1"
        :complete="selectInventoryComplete"
      >
        Select Source Inventory
      </v-stepper-step>

      <v-stepper-content
        :key="`select-inventory-content`"
        :step="1"
      >
        <select-source-inventory
          :conversionRule="conversionRule"
          :inventoryLots="allInventoryLots"
          v-model="selectedInventoryLots"
          @nextStep="nextStep"
        >
        </select-source-inventory>
      </v-stepper-content>

      <!-- step 2 - source quantities-->      
      <v-stepper-step
        :key="`source-quantity-step`"
        :step="2"
        :complete="sourceQuantitiesComplete"
      >
        Review Sourced Quantities
      </v-stepper-step>

      <v-stepper-content
        :key="`source-quantity-content`"
        :step="2"
      >
        <review-sourced-quantities
          :inventoryLots="selectedInventoryLots"
          v-model="itemSourcedQuantities"
          :conversionRule="conversionRule"
          @nextStep="nextStep"
          @previousStep="previousStep"
        >
        </review-sourced-quantities>
      </v-stepper-content>

      <!-- step 3 - target lots -->      
      <v-stepper-step
        :key="`target-lots-step`"
        :step="3"
        :complete="currentStep === 4"
      >
        Describe New Inventory Lots and Perform Conversion
      </v-stepper-step>

      <v-stepper-content
        :key="`target-lots-content`"
        :step="3"
      >
        <describe-target-lots
          :conversionRule="conversionRule"
          :totalSourcedQuantity="totalSourcedQuantity"
          :strain="selectedStrain"
          v-model="targetLotInfos"
          :sourcesInfo="sourcesInfoVerbose"
          @performConversion="performConversion"
          @previousStep="previousStep"
        >
        </describe-target-lots>
      </v-stepper-content>

      <v-stepper-step
        :key="`review-results-step`"
        :step="4"
        :complete="currentStep === 4"
      >
        Review Newly Created Inventory Lots
      </v-stepper-step>

      <v-stepper-content
        :key="`review-results-content`"
        :step="4"
      >
        <inventory-lot-collection
          :inventoryLots="newInventoryLots"
        >
        </inventory-lot-collection>
        <v-btn
          @click="reset"
        >{{resetButtonDisplay}}</v-btn>
      </v-stepper-content>
    </v-stepper>
  </v-container>
</template>

<script>
import convertInventory from '@/graphql/mutation/convertInventory.graphql'
import strainInventoryTypeLotCounts from '@/graphql/query/strainInventoryTypeLotCounts.graphql'
import conversionRuleByInventoryTypeId from '@/graphql/query/conversionRuleByInventoryTypeId.graphql'
import inventoryLotsForConversion from '@/graphql/query/inventoryLotsForConversion.graphql'

import InventoryLotCollection from '../inventory/InventoryLotCollection'
import SelectSourceInventory from './SelectSourceInventory'
import ReviewSourcedQuantities from './ReviewSourcedQuantities'
import DescribeTargetLots from './DescribeTargetLots'

export default {
  name: 'BatchConversion',
  components: {
    SelectSourceInventory,
    ReviewSourcedQuantities,
    DescribeTargetLots,
    InventoryLotCollection
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
      if (!this.conversionRule) return 'Batch Conversion - No Rule Specified'
      return `${this.conversionRule.name}`
    },
    ruleInfoDisplay () {
      if (!this.conversionRule) return
      return [
        this.conversionRule.isNonDestructive ? 'non-destructive' : 'destructive',
        this.conversionRule.isZeroSum ? 'zero-sum' : 'not-zero-sum',
        this.conversionRule.toInventoryType.isSingleLotted ? 'single-lotted' : 'multi-lotted',
        this.conversionRule.toInventoryType.isStrainMixable ? 'strain-mixable' : 'strain-specific',
        this.conversionRule.toInventoryType.isStrainOptional ? 'strain-optional' : 'strain-required',
      ]
      .join(" :: ")
    },
    sourceTypesDisplay () {
      if (!this.conversionRule) return []

      return this.conversionRule.conversionRuleSources.nodes
        .map(crs => `${crs.inventoryType.id}: ${crs.inventoryType.name} (${crs.inventoryType.isSingleLotted ? 'single-lotted' : 'multi-lotted'})`)
    },
    targetTypeDisplay () {
      if (!this.conversionRule) return []

      const it = this.conversionRule.toInventoryType
      return `${it.id}: ${it.name}`
    },
    resetButtonDisplay () {
      if (!this.conversionRule) return 'Reset'
      return `Do some more ${this.conversionRule.name}`
    },
    totalSourcedQuantity () {
      return Object.values(this.itemSourcedQuantities).reduce(
        (total, item) => {
          return total + parseFloat(item)
        }, 0
      )

    },
    convertDisabled () {
      return this.selectedInventoryLots.length === 0
    },
    selectInventoryComplete () {
      return this.selectedInventoryLots.length > 0
    },
    sourceQuantitiesComplete () {
      return this.currentStep > 1 && Object.values(this.itemSourcedQuantities).map(
        item => {
          return parseFloat(item)
        }
      )
      .filter(v => isNaN(v))
      .length ===0
    },
    sourcesInfo () {
      return Object.keys(this.itemSourcedQuantities).map(
        id => {
          return {
            id: id,
            quantity: this.itemSourcedQuantities[id]            
          }
        }
      )
    },
    // sourcesInfoVerbose () {
    //   return Object.keys(this.itemSourcedQuantities).map(
    //     id => {
    //       return {
    //         id: id,
    //         quantity: this.itemSourcedQuantities[id],
    //         area: this.selectedInventoryLots.find(il => il.id === id).area
    //       }
    //     }
    //   )
    // }
  },
  methods: {
    nextStep () {
      this.currentStep = this.currentStep + 1
    },
    previousStep () {
      this.currentStep = this.currentStep - 1
    },
    performConversion () {
      const newLotsInfo = this.targetLotInfos.map(
        tli => {
          const {
              index,
              units,
              ...newTli
          } = tli;
          index;units;
          return newTli
        }
      )

      this.$apollo.mutate({
        mutation: convertInventory,
        variables: {
          toInventoryTypeId: this.conversionRule.toInventoryType.id,
          sourcesInfo: this.sourcesInfo,
          newLotsInfo: newLotsInfo
        }
      })
      .then(result => {
        this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.convertInventory.inventoryLots})
        this.newInventoryLots = result.data.convertInventory.inventoryLots
        this.nextStep()
      })
      .catch(error => {
        alert(error.toString())
        console.error(error)
      })
    },
    queryInventoryLots () {
      if (!this.selectedStrain) return;

      this.$apollo.query({
        query: inventoryLotsForConversion,
        fetchPolicy: 'network-only',
        variables: {
          strainId: this.selectedStrain.strainId,
          inventoryTypeIds: this.sourceInventoryTypes.map(it => it.id)
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
      this.$apollo.query({
        query: strainInventoryTypeLotCounts,
        fetchPolicy: 'network-only',
      })
      .then(result => {
        const crsInventoryTypeIds = this.conversionRule.conversionRuleSources.nodes.map(crs => crs.inventoryType.id)
        this.strainInventoryTypeLotCounts = result.data.strainInventoryTypeLotCounts.nodes
        this.allStrains = this.strainInventoryTypeLotCounts
          .filter(sitlc => parseFloat(sitlc.count) > 0 && crsInventoryTypeIds.indexOf(sitlc.inventoryType) > -1)
        this.selectedStrain = this.allStrains.length === 1 ? this.allStrains[0] : null
      })
      .catch(e => {
        console.error(e)
      })
    },
    reset (exceptStrain) {
      this.currentStep = 1
      this.selectedInventoryLots = []
      this.allInventoryLots = []
      this.selectedSourceInventoryType = null;
      if (!exceptStrain) {
        this.selectedStrain = exceptStrain ? this.selectedStrain : null;
        this.queryStrainCounts()
      }
    }
  },
   watch: {
    selectedStrain () {
      if (!this.selectedStrain) { return }
      this.reset(true)
      this.queryInventoryLots()
    },
    conversionRule () {
      if (!this.conversionRule) { return }
      this.sourceInventoryTypes = this.conversionRule.conversionRuleSources.nodes.map(crs => crs.inventoryType)
      this.selectedSourceInventoryType = this.sourceInventoryTypes[0]
      this.queryStrainCounts()
    },
    selectedInventoryLots () {
      this.itemSourcedQuantities = {}
    },
    itemSourcedQuantities: {
      deep: true,
      handler () {
        this.sourcesInfoVerbose = Object.keys(this.itemSourcedQuantities)
        .filter(ilid => this.selectedInventoryLots.find(il => il.id === ilid) !== undefined)
        .map(
          id => {
            return {
              id: id,
              quantity: this.itemSourcedQuantities[id],
              area: this.selectedInventoryLots.find(il => il.id === id).area
            }
          }
        )
      }
    },
    targetLotInfos:{
      deep: true,
      handler () {
        console.log('this.tlis', JSON.stringify(this.targetLotInfos,false,2))
      }
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
      selectedInventoryLots: [],
      newInventoryLots: [],
      allStrains: [],
      selectedStrain: null,
      allAreas: [],
      sourceInventoryTypes: [],
      itemSourcedQuantities: {},
      conversionRule: null,
      targetLotInfos: [],
      strainInventoryTypeLotCounts: [],
      sourcesInfoVerbose: []
    }
  },
  beforeRouteUpdate (to, from, next) {
    this.selectedStrain = null
    this.reset()
    next()
  }
}
</script>

<style>

</style>


