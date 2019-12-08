<template>
  <div>
    <h1>License Manager</h1>
    <hr>
    <license-list-view></license-list-view>
  </div>
</template>

<script>
  import LicenseListView from '@/views/App/LicenseListView'

  export default {
    name: 'LicenseManager',
    components: {
      LicenseListView
    }
  }
</script>
