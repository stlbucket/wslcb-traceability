<template>
  <batch-conversion
    :toInventoryType="toInventoryType"
  >
  </batch-conversion>
</template>

<script>
import BatchConversion from './BatchConversion'

export default {
  name: 'Curing',
  components: {
    BatchConversion
  },
  data () {
    return {
      toInventoryType: 'BF'
    }
  }
}
</script>

<style>

</style>