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
              key: 'trc-seed-sourcing',
              name: 'Seed Sourcing',
              path: '/batch-conversion/SD',
              iconKey: 'grain'
            },
            {
              key: 'trc-planting',
              name: 'Planting',
              path: '/batch-conversion/SL',
              iconKey: 'adjust'
            },
            {
              key: 'trc-cloning',
              name: 'Cloning',
              path: '/batch-conversion/CL',
              iconKey: 'people'
            },
            {
              key: 'trc-growing',
              name: 'Growing',
              path: '/batch-conversion/PL',
              iconKey: 'add_alarm'
            },
            {
              key: 'trc-harvesting',
              name: 'Harvesting',
              path: '/batch-conversion/WF',
              iconKey: 'graphic_eq'
            },
            {
              key: 'trc-curing',
              name: 'Curing',
              path: '/batch-conversion/BF',
              iconKey: 'access_time'
            },
            {
              key: 'trc-flower-lotting',
              name: 'Flower Lotting',
              routeName: 'trc-flower-lotting',
              path: '/batch-conversion/LF',
              iconKey: 'storage'
            },
            // {
            //   key: 'trc-flower-processing',
            //   name: 'Flower Processing',
            //   routeName: 'trc-flower-processing',
            //   iconKey: 'flip_camera_android'
            // },
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
          name: 'Verify',
          appList: [
            {
              key: 'trc-qa-sampling',
              name: 'QA Sampling',
              routeName: 'trc-qa-sampling',
              iconKey: 'check_circle_outline'
            },
            {
              key: 'trc-qa-lab-reporting',
              name: 'QA Results',
              routeName: 'trc-qa-lab-reporting',
              iconKey: 'check_circle'
            },
          ]
        },
        {
          name: 'Transport',
          appList: [
            {
              key: 'trc-manifest',
              name: 'Manifest',
              routeName: 'trc-manifest',
              iconKey: 'format_list_numbered'
            },
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
          ]
        },
        {
          name: 'Sell',
          appList: [
            {
              key: 'trc-retail-sampling',
              name: 'Retail Sampling',
              routeName: 'trc-retail-sampling',
              iconKey: 'blur_on'
            },
            {
              key: 'trc-retail-sales-reporting',
              name: 'Retail Sales',
              routeName: 'trc-retail-sales-reporting',
              iconKey: 'attach_money'
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
              path: '/trc-inv',
              iconKey: 'apartment'
            },
            {
              key: 'address-book',
              name: 'Address Book',
              routeName: 'address-book',
              path: '/address-book',
              iconKey: 'people'
            },
            {
              key: 'license-manager',
              name: 'License Manager',
              routeName: 'license-manager',
              path: '/license-manager',
              iconKey: 'domain'
            },
            {
              key: 'tenant-manager',
              name: 'Tenant Manager',
              routeName: 'tenant-manager',
              path: '/tenant-manager',
              iconKey: 'location_city'
            },
          ]
        }
      ],
    }
  },
}
</script>
