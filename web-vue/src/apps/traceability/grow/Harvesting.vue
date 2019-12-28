<template>
  <batch-conversion
    :toInventoryType="toInventoryType"
  >
  </batch-conversion>
</template>

<script>
import BatchConversion from './BatchConversion'

export default {
  name: 'Harvesting',
  components: {
    BatchConversion
  },
  data () {
    return {
      toInventoryType: 'WF'
    }
  }
}
</script>

<style>

</style>