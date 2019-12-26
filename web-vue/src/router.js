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
import ManifestDetail from '@/apps/traceability/transfers/ManifestDetail'
import ReceivingManager from '@/apps/traceability/receiving/ReceivingManager'
import ReturnsManager from '@/apps/traceability/returns/ReturnsManager'
import QaManager from '@/apps/traceability/qa/QaManager'
import Planting from '@/apps/traceability/grow/Planting'
import Cloning from '@/apps/traceability/grow/Cloning'
import Growing from '@/apps/traceability/grow/Growing'
import Harvesting from '@/apps/traceability/grow/Harvesting'
import Curing from '@/apps/traceability/grow/Curing'
import FlowerLotting from '@/apps/traceability/grow/FlowerLotting'
import FlowerProcessing from '@/apps/traceability/grow/FlowerProcessing'
import ProductProcessing from '@/apps/traceability/grow/ProductProcessing'
import ProductPackaging from '@/apps/traceability/grow/ProductPackaging'

Vue.use(Router)

export default new Router({
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
      path: '/trc-qa',
      name: 'trc-qa',
      component: QaManager
    },
    {
      path: '/trc-planting',
      name: 'trc-planting',
      component: Planting
    },
    {
      path: '/trc-cloning',
      name: 'trc-cloning',
      component: Cloning
    },
    {
      path: '/trc-growing',
      name: 'trc-growing',
      component: Growing
    },
    {
      path: '/trc-harvesting',
      name: 'trc-harvesting',
      component: Harvesting
    },
    {
      path: '/trc-curing',
      name: 'trc-curing',
      component: Curing
    },
    {
      path: '/trc-flower-lotting',
      name: 'trc-flower-lotting',
      component: FlowerLotting
    },
    {
      path: '/trc-flower-processing',
      name: 'trc-flower-processing',
      component: FlowerProcessing
    },
    {
      path: '/trc-product-processing',
      name: 'trc-product-processing',
      component: ProductProcessing
    },
    {
      path: '/trc-product-packaging',
      name: 'trc-product-packaging',
      component: ProductPackaging
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
