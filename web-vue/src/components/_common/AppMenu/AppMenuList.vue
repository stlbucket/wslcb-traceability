<template>
  <v-container>
    <v-list :hidden="!showAppList" dense>
      <v-expansion-panels
        accordian
        multiple
      >
        <v-expansion-panel
          v-for="group in appGroups"
          :key="group.name"
        >
          <v-expansion-panel-header>{{group.name}}</v-expansion-panel-header>
          <v-expansion-panel-content>
            <app-menu-group
              :key="group.name"
              :appGroup="group"
            >
            </app-menu-group>
          </v-expansion-panel-content>
        </v-expansion-panel>
      </v-expansion-panels>
    </v-list>
    <h2 :hidden="showAppList">Login for apps</h2>
  </v-container>
</template>

<script>
import AppMenuGroup from './AppMenuGroup'

export default {
  name: "AppMenuList",
  components: {
    AppMenuGroup
  },
  methods: {
  },
  computed: {
    showAppList () {
      return this.$store.state.currentAppUser !== null
    },
  },
  watch: {
  },
  data () {
    return {
      appGroups: [
        {
          name: 'Grow',
          appList: [
            {
              key: 'trc-planting',
              name: 'Planting',
              routeName: 'trc-planting',
              iconKey: 'adjust'
            },
            {
              key: 'trc-cloning',
              name: 'Cloning',
              routeName: 'trc-cloning',
              iconKey: 'people'
            },
            {
              key: 'trc-growing',
              name: 'Growing',
              routeName: 'trc-growing',
              iconKey: 'add_alarm'
            },
            {
              key: 'trc-harvesting',
              name: 'Harvesting',
              routeName: 'trc-harvesting',
              iconKey: 'graphic_eq'
            },
            {
              key: 'trc-curing',
              name: 'Curing',
              routeName: 'trc-curing',
              iconKey: 'access_time'
            },
            {
              key: 'trc-flower-lotting',
              name: 'Flower Lotting',
              routeName: 'trc-flower-lotting',
              iconKey: 'storage'
            },
            {
              key: 'trc-flower-processing',
              name: 'Flower Processing',
              routeName: 'trc-flower-processing',
              iconKey: 'flip_camera_android'
            },
          ]
        },
        {
          name: 'Process',
          appList: [
            {
              key: 'trc-product-processing',
              name: 'Product Processing',
              routeName: 'trc-product-processing',
              iconKey: 'control_camera'
            },
            {
              key: 'trc-product-packaging',
              name: 'Product Packaging',
              routeName: 'trc-product-packaging',
              iconKey: 'dashboard'
            },
          ]
        },
        {
          name: 'Move',
          appList: [
            {
              key: 'trc-xfer',
              name: 'Transfers',
              routeName: 'trc-xfer',
              iconKey: 'local_shipping'
            },
            {
              key: 'trc-rec',
              name: 'Receiving',
              routeName: 'trc-rec',
              iconKey: 'receipt'
            },
            {
              key: 'trc-ret',
              name: 'Returns',
              routeName: 'trc-ret',
              iconKey: 'keyboard_return'
            },
            {
              key: 'trc-qa',
              name: 'QA Manager',
              routeName: 'trc-qa',
              iconKey: 'check'
            },
          ]
        },
        {
          name: 'Admin',
          appList: [
            {
              key: 'trc-inv',
              name: 'Inventory Admin',
              routeName: 'trc-inv',
              iconKey: 'apartment'
            },
            {
              key: 'address-book',
              name: 'Address Book',
              routeName: 'address-book',
              iconKey: 'people'
            },
            {
              key: 'license-manager',
              name: 'License Manager',
              routeName: 'license-manager',
              iconKey: 'domain'
            },
            {
              key: 'tenant-manager',
              name: 'Tenant Manager',
              routeName: 'tenant-manager',
              iconKey: 'location_city'
            },
          ]
        }
      ],
    }
  },
}
</script>
