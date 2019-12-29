<template>
  <v-container>
    <v-card
      class="mb-12"
      color="green"
    >
      <h2>total sourced quantity: {{ totalSourcedQuantity }}</h2>
      <h2 v-if="isSingleLotted">{{singleLottedMessage}}</h2>
      <v-container v-for="tli in targetLotInfos" :key="tli.index">
        <v-row>
          <v-col cols="1">
            <h3>Quantity</h3>
          </v-col>
          <v-col cols="2">
            <h3>Description</h3>
          </v-col>
          <v-col cols="1">
          </v-col>
          <v-col cols="2">
            <h3>Area</h3>
          </v-col>
          <v-col cols="1">
          </v-col>
          <v-col cols="2">
          </v-col>
        </v-row>
        <v-row>
          <v-col cols="1">
            <v-text-field
              v-if="!isSingleLotted"
              label="quantity"
              :value="tli.quantity"
              :disabled="isSingleLotted"
            ></v-text-field>
            <h3 v-else>{{tli.quantity}}</h3>
          </v-col>
          <v-col cols="2">
            <h3>{{tli.description}}</h3>
          </v-col>
          <v-col cols="1">
          </v-col>
          <v-col cols="2">
            <h3>{{tli.areaName}}</h3>
          </v-col>
          <v-col cols="1">
          </v-col>
          <v-col cols="2">
            <v-btn
              v-if="!isSingleLotted"
              @click="addTargetLotInfo"
            >Add Lot</v-btn>
          </v-col>
        </v-row>

      </v-container>
    </v-card>

    <v-row>
      <v-col cols="3">
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
export default {
  name: 'SelectSourceInventory',
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
      return false // this.value.length === 0
    },
    singleLottedMessage () {
      return `${this.conversionRule.name} is single-lotted.  This action will result in ${this.totalSourcedQuantity} tagged ${this.totalSourcedQuantity > 1 ? 'lots, each' : 'lot'} containing one ${this.conversionRule.toInventoryType.name}`
    },
    isSingleLotted () {
      return this.conversionRule.toInventoryType.isSingleLotted
    }
  },
  methods: {
    addTargetLotInfo () {
      this.targetLotInfos = [...this.targetLotInfos, {quantity: 0}]
    },
  },
  watch: {
    totalSourcedQuantity () {
      const defaultDescription = `${this.conversionRule.toInventoryType.name} ${this.strain ? `- ${this.strain.strain_name}` : ''}`

      const areaCounts = this.sourcesInfo.reduce(
        (all, il) => {
          return {
            ...all,
            [il.area.id]: {
              name: il.area.name,
              quantity: (all[il.area.id] ? (parseFloat(all[il.area.id].quantity) + parseFloat(il.quantity)) : parseFloat(il.quantity))
            }
          }
        }, {}
      )

      this.targetLotInfos = Object.keys(areaCounts).map(
        areaId => {
          return {
            description: this.recipe ? this.recipe.name : defaultDescription,
            quantity: areaCounts[areaId].quantity,
            inventoryType: this.conversionRule.toInventoryType.id,
            areaName: areaCounts[areaId].name
          }
        }
      )
      this.$emit('input', this.targetLotInfos)
    },
    targetLotInfos () {
      this.$emit('input', this.targetLotInfos)
    }
  },
  data () {
    return {
      targetLotInfos: []
    }
  }
}
</script>

<style>

</style>


