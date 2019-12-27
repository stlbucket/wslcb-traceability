<template>
  <batch-conversion
    :recipeDefinition="recipeDefinition"
  >
  </batch-conversion>
</template>

<script>
import BatchConversion from './BatchConversion'

export default {
  name: 'Planting',
  components: {
    BatchConversion
  },
  data () {
    return {
      recipeDefinition: {
        name: 'Planting',
        sourceTypes: ['SD'],
        targetType: 'SL'
      },
    }
  }
}
</script>

<style>

</style>