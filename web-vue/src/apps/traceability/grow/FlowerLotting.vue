<template>
  <batch-conversion
    :toInventoryType="toInventoryType"
  >
  </batch-conversion>
</template>

<script>
import BatchConversion from './BatchConversion'

export default {
  name: 'FlowerLotting',
  components: {
    BatchConversion
  },
  data () {
    return {
      toInventoryType: 'LF'
    }
  }
}
</script>

<style>

</style>