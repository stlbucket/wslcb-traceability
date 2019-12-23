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
          key: 'tenant-manager',
          name: 'Tenant Manager',
          routeName: 'tenant-manager',
          iconKey: 'location_city'
        },
        {
          key: 'license-manager',
          name: 'License Manager',
          routeName: 'license-manager',
          iconKey: 'domain'
        },
        {
          key: 'address-book',
          name: 'Address Book',
          routeName: 'address-book',
          iconKey: 'people'
        },
        {
          key: 'trc-inv',
          name: 'Inventory',
          routeName: 'trc-inv',
          iconKey: 'apartment'
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
        {
          key: 'trc-qa',
          name: 'QA Manager',
          routeName: 'trc-qa',
          iconKey: 'check'
        }
      ]
    }
  },
}
</script>
