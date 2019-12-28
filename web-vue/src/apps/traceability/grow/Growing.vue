<template>
  <batch-conversion
    :toInventoryType="toInventoryType"
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
      toInventoryType: 'PL'
    }
  }
}
</script>

<style>

</style>