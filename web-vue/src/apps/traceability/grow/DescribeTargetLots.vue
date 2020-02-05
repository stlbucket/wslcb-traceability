<template>
  <v-container>
    <v-card
      class="mb-12"
      color="green"
    >
      <h2>total sourced quantity: {{ totalSourcedQuantity }}</h2>
      <h2 v-if="isSingleLotted">{{singleLottedMessage}}</h2>
      <h3 v-if="conversionRule.isZeroSum">{{this.conversionRule.name}} is zero-sum: total of target quantities must equal source quantities</h3>
      <h3 v-else>{{this.conversionRule.name}} is not zero-sum:  target quantities are not checked against source quantites.</h3>
      <v-btn @click="removeTargetLotInfo" :disabled="selectedTargetLotInfos.length === 0">Remove</v-btn>
      <v-data-table
        :headers="headers"
        :items="targetLotInfos"
        v-model="selectedTargetLotInfos"
        class="elevation-1"
        dense
        item-key="index"
        hide-default-footer
        :items-per-page="100"
        show-select
      >
        <template v-slot:item.quantity="{item}">
          <v-container>
            <v-text-field
              v-model="item.quantity"
              label="quantity"
            >
            </v-text-field>
          </v-container>
        </template>

        <template v-slot:item.areaName="{item}">
          <v-container>
            <v-text-field
              v-model="item.areaName"
              label="area"
            >
            </v-text-field>
          </v-container>
        </template>
      </v-data-table>
    </v-card>

    <v-row>
      <v-col cols="">
        <v-btn
          color="primary"
          @click="$emit('performConversion')"
          :disabled="disabled"
        >
          Perform Conversion
        </v-btn>
      </v-col>
      <v-col cols="1">
      </v-col>
      <v-col cols="2">
        <v-btn
          color="primary"
          @click="$emit('previousStep')"
        >
          Back
        </v-btn>
      </v-col>
      <v-col cols="1">
      </v-col>
      <v-col cols="2">
        <h2>{{totalTargetQuantity}}</h2>
      </v-col>
      <v-col cols="1">
      </v-col>
      <v-col cols="2">
        <v-btn
          color="primary"
          @click="addTargetLotInfo"
        >
          Add Lot
        </v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
export default {
  name: 'DescribeTargetLots',
  components: {
  },
  props: {
    conversionRule: {
      type: Object,
      required: true
    },
    recipe: {
      type: Object,
      required: false
    },
    strain: {
      type: Object,
      required: false
    },
    sourcesInfo: {
      type: Array,
      required: true
    },
    totalSourcedQuantity: {
      type: Number,
      required: true
    },
    value: {
      type: Array,
      default: ()=>[]
    }
  },
  computed: {
    disabled () {
      return this.targetLotInfos.filter(
        tli => {
          const quantity = parseFloat(tli.quantity)
          return(isNaN(quantity) || quantity <= 0)
        }
      ).length > 0
    },
    singleLottedMessage () {
      return `${this.conversionRule.name} is single-lotted.  This action will result in ${this.totalSourcedQuantity} tagged ${this.totalSourcedQuantity > 1 ? 'lots, each' : 'lot'} containing one ${this.conversionRule.toInventoryType.name}`
    },
    isSingleLotted () {
      return this.conversionRule.toInventoryType.isSingleLotted
    }
  },
  methods: {
    removeTargetLotInfo () {
      const indexesToRemove = this.selectedTargetLotInfos.map(tli => tli.index)
      this.targetLotInfos = this.targetLotInfos.filter(tli => indexesToRemove.indexOf(tli.index) === -1).map(
        (tli, index) => {
          return {
            ...tli,
            index: index
          }
        }
      )
      this.selectedTargetLotInfos = []
    },
    addTargetLotInfo () {
      this.targetLotInfos = [...this.targetLotInfos, {
        index: this.targetLotInfos.length,
        inventoryType: this.conversionRule.toInventoryType.id,
        units: this.conversionRule.toInventoryType.units,
        quantity: 0
      }]
    },
    resetTargetLotInfos () {
      const defaultDescription = `${this.conversionRule.toInventoryType.name} ${this.strain ? `- ${this.strain.strainName}` : ''}`

      const areaCounts = this.sourcesInfo.reduce(
        (all, il) => {
          const quantity = (all[il.area.id] ? (parseFloat(all[il.area.id].quantity) + parseFloat(il.quantity)) : parseFloat(il.quantity))

          return {
            ...all,
            [il.area.id]: {
              name: il.area.name,
              quantity: quantity
            }
          }
        }, {}
      )

      this.targetLotInfos = Object.keys(areaCounts).map(
        (areaId, index) => {
          const areaSourceQuantity = areaCounts[areaId].quantity
          // const quantity = this.conversionRule.isZeroSum ? areaSourceQuantity : null
          const quantity = areaSourceQuantity

        return {
            index: index,
            description: this.recipe ? this.recipe.name : defaultDescription,
            inventoryType: this.conversionRule.toInventoryType.id,
            units: this.conversionRule.toInventoryType.units,
            areaName: areaCounts[areaId].name,
            quantity: quantity,
          }
        }
      )
    }
  },
  watch: {
    totalSourcedQuantity () {
      this.resetTargetLotInfos()
    },
    targetLotInfos: {
      deep: true,
      handler () {
        this.totalTargetQuantity = this.targetLotInfos
          .map(tli => tli.quantity)
          .reduce(
            (sum, q) => {
              const quantity = parseFloat(q)
              return !isNaN(quantity) ? sum + quantity : sum
            }, 0
          )
        this.$emit('input', this.targetLotInfos)
      }
    }
  },
  data () {
    return {
      targetLotInfos: [],
      selectedTargetLotInfos: [],
      totalTargetQuantity: 0,
      headers: [
        {
          text: 'target quantity',
          value: 'quantity'
        },
        {
          text: 'units',
          value: 'units'
        },
        {
          text: 'area',
          value: 'areaName'
        },
        {
          text: 'inventory type',
          value: 'inventoryType'
        },
      ]
    }
  },
  mounted () {
    this.resetTargetLotInfos()
  }
}
</script>

<style>

</style>


