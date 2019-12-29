import Vue from 'vue'
import Router from 'vue-router'
import Home from './views/Home.vue'
// import Home from './views/Generator/OrgGenerator.vue'

import Login from './views/Login'

import TenantManager from '@/apps/TenantManager'
import AppTenantDetail from './views/Auth/AppTenantDetailView'

import LicenseManager from '@/apps/LicenseManager/'
import LicenseDetail from './views/App/LicenseDetailView'

import AddressBook from '@/apps/AddressBook'
import OrganizationDetail from './views/Org/OrganizationDetailView'
import ContactDetail from './views/Org/ContactDetailView'
import FacilityDetail from './views/Org/FacilityDetailView'

import ProjectManager from '@/apps/ProjectManager'
import ProjectDetail from './views/Prj/ProjectDetailView'

import InventoryManager from '@/apps/traceability/inventory/InventoryManager'
import TransferManager from '@/apps/traceability/transfers/TransferManager'
import ManifestManager from '@/apps/traceability/manifests/ManifestManager'
import ManifestDetail from '@/apps/traceability/transfers/ManifestDetail'
import ReceivingManager from '@/apps/traceability/receiving/ReceivingManager'
import ReturnsManager from '@/apps/traceability/returns/ReturnsManager'
import QaSampling from '@/apps/traceability/qa/QaSampling'
import QaLabReporting from '@/apps/traceability/qa/QaLabReporting'
import RetailSampling from '@/apps/traceability/retail/RetailSampling'
import RetailSalesReporting from '@/apps/traceability/retail/RetailSalesReporting'
// import Planting from '@/apps/traceability/grow/Planting'
// import Cloning from '@/apps/traceability/grow/Cloning'
// import Growing from '@/apps/traceability/grow/Growing'
// import Harvesting from '@/apps/traceability/grow/Harvesting'
// import Curing from '@/apps/traceability/grow/Curing'
// import FlowerLotting from '@/apps/traceability/grow/FlowerLotting'
// import FlowerProcessing from '@/apps/traceability/grow/FlowerProcessing'
// import ProductProcessing from '@/apps/traceability/grow/ProductProcessing'
// import ProductPackaging from '@/apps/traceability/grow/ProductPackaging'
import BatchConversion from '@/apps/traceability/grow/BatchConversion'

Vue.use(Router)

export default new Router({
  beforeEach: (to, from, next) => {
  // just use `this`
    console.log('beforeEach', to,from)
    next()
  },
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: '/tenant-manager',
      name: 'tenant-manager',
      component: TenantManager
    },
    {
      path: '/app-tenant-manager/app-tenant/:id',
      name: 'app-tenant-detail',
      component: AppTenantDetail,
      props: true
    },
    {
      path: '/license-manager',
      name: 'license-manager',
      component: LicenseManager
    },
    {
      path: '/license-manager/license/:id',
      name: 'license-detail',
      component: LicenseDetail,
      props: true
    },
    {
      path: '/address-book',
      name: 'address-book',
      component: AddressBook
    },
    {
      path: '/project-manager',
      name: 'project-manager',
      component: ProjectManager
    },
    {
      path: '/project-manager/project/:id',
      name: 'project-detail',
      component: ProjectDetail,
      props: true
    },
    {
      path: '/address-book/organization/:id',
      name: 'organization-detail',
      component: OrganizationDetail,
      props: true
    },
    {
      path: '/address-book/contact/:id',
      name: 'contact-detail',
      component: ContactDetail,
      props: true
    },
    {
      path: '/address-book/facility/:id',
      name: 'facility-detail',
      component: FacilityDetail,
      props: true
    },
    {
      path: '/trc-inv',
      name: 'trc-inv',
      component: InventoryManager
    },
    {
      path: '/trc-manifest',
      name: 'trc-manifest',
      component: ManifestManager
    },
    {
      path: '/trc-xfer',
      name: 'trc-xfer',
      component: TransferManager
    },
    {
      path: '/trc-manifest-detail/:id',
      name: 'trc-manifest-detail',
      component: ManifestDetail,
      props: true
    },
    {
      path: '/trc-rec',
      name: 'trc-rec',
      component: ReceivingManager
    },
    {
      path: '/trc-ret',
      name: 'trc-ret',
      component: ReturnsManager
    },
    {
      path: '/trc-qa-sampling',
      name: 'trc-qa-sampling',
      component: QaSampling
    },
    {
      path: '/trc-qa-lab-reporting',
      name: 'trc-qa-lab-reporting',
      component: QaLabReporting
    },
    {
      path: '/trc-retail-sampling',
      name: 'trc-retail-sampling',
      component: RetailSampling
    },
    {
      path: '/trc-retail-sales-reporting',
      name: 'trc-retail-sales-reporting',
      component: RetailSalesReporting
    },
    {
      path: '/batch-conversion/:toInventoryType',
      name: 'batch-conversion',
      component: BatchConversion,
      props: true
    },
    {
      path: '/trc-product-processing',
      name: 'trc-product-processing',
      component: BatchConversion
    },
    {
      path: '/trc-product-packaging',
      name: 'trc-product-packaging',
      component: BatchConversion
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (about.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: () => import(/* webpackChunkName: "about" */ './views/About.vue')
    }
  ]
})
