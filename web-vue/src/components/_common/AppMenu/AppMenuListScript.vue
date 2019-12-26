<script>
export default {
  name: "AppMenuListScript",
  components: {
  },
  methods: {
    appSelected (app) {
      this.$router.push({name: app.routeName})
    //  this.$eventHub.$emit('app-selected');
    },
  },
  computed: {
    allowedAppList () {
      return this.appList.reduce(
        (a, app) => {
          const userLicense = this.currentAppUser ? this.currentAppUser.licenses.nodes.find(l => l.licenseType.application.key === app.key) : null
          return userLicense ? a.concat([app]) : a
        }, []
      )
    },
    showAppList () {
      return this.$store.state.currentAppUser !== null
    },
    currentAppUser () {
      return this.$store.state.currentAppUser
    }
  },
  watch: {
  },
  data () {
    return {
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
  },
}
</script>
