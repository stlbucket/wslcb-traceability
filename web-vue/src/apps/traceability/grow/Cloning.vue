<template>
  <batch-conversion
    :recipeDefinition="recipeDefinition"
  >
  </batch-conversion>
</template>

<script>
import BatchConversion from './BatchConversion'

export default {
  name: 'Cloning',
  components: {
    BatchConversion
  },
  data () {
    return {
      recipeDefinition: {
        name: 'Cloning',
        sourceTypes: ['PL'],
        targetType: 'CL'
      },
    }
  }
}
</script>

<style>

</style>