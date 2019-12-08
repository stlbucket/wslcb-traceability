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

import LcbTraceability from '@/apps/LcbTraceability'

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
      path: '/lcb-traceability',
      name: 'lcb-traceability',
      component: LcbTraceability
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
