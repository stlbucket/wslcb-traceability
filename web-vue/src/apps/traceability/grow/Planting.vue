<template>
  <batch-conversion
    :toInventoryType="toInventoryType"
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
      toInventoryType: 'SL'
    }
  }
}
</script>

<style>

</style>