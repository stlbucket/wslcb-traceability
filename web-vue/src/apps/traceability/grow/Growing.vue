<template>
  <batch-conversion
    :recipeDefinition="recipeDefinition"
  >
  </batch-conversion>
</template>

<script>
import BatchConversion from './BatchConversion'

export default {
  name: 'Growing',
  components: {
    BatchConversion
  },
  data () {
    return {
      recipeDefinition: {
        name: 'Growing',
        sourceTypes: ['CL', 'SL'],
        targetType: 'PL'
      },
    }
  }
}
</script>

<style>

</style>