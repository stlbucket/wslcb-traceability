<template>
  <batch-conversion
    :toInventoryType="toInventoryType"
  >
  </batch-conversion>
</template>

<script>
import BatchConversion from './BatchConversion'

export default {
  name: 'Recipe',
  components: {
    BatchConversion
  },
  props: {
    recipeId: {
      type: String,
      required: true
    }
  },
  data () {
    return {
    }
  }
}
</script>

<style>

</style>