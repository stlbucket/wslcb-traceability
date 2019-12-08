<template>
  <div>
    <h1>Tenant Manager</h1>
    <hr>
    <app-tenant-list-view></app-tenant-list-view>
  </div>
</template>

<script>
  import AppTenantListView from '@/views/Auth/AppTenantListView'

  export default {
    name: 'LicenseManager',
    components: {
      AppTenantListView
    }
  }
</script>
