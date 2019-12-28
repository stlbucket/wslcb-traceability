<template>
  <batch-conversion
    :toInventoryType="toInventoryType"
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
      toInventoryType: 'CL'
    }
  }
}
</script>

<style>

</style>