<template>
  <v-container grid-list-md text-xs-center>
    <v-card>
      <v-card-title class="headline">App appTenant</v-card-title>
      <v-layout row wrap>
        <v-flex xs4>
          <appTenant-detail-component
            :appTenant="appTenant"
          ></appTenant-detail-component>
          Organization
          <organization-detail-component
            :organization="organization"
          ></organization-detail-component>
        </v-flex>
        <v-flex xs8>
          <v-card raised>
            <v-tabs
              dark
              slider-color="yellow"
            >
              <!-- <v-tab
                key="contact-list"
                ripple
              >
                Users
              </v-tab>
              <v-tab-item
                key="contact-list"
              >
                <contact-list
                  :contacts="contacts"
                ></contact-list>
              </v-tab-item> -->
              <v-tab
                key="license-list"
                ripple
              >
                Licenses
              </v-tab>
              <v-tab-item
                key="license-list"
              >
                <license-list-component
                  :licenses="licenses"
                ></license-list-component>
              </v-tab-item>
            </v-tabs>
          </v-card>
        </v-flex>
      </v-layout>
    </v-card>
  </v-container>
</template>

<script>
import appTenantById from '@/graphql/query/appTenantById.graphql'
import AppTenantDetailComponent from '@/components/Auth/AppTenantDetail'
import OrganizationDetailComponent from '@/components/Org/OrganizationDetail'
import LicenseListComponent from '@/components/App/LicenseList'


export default {
  name: "AppTenantDetailView",
  components: {
    AppTenantDetailComponent,
    OrganizationDetailComponent,
    LicenseListComponent
  },
  props: {
    id: { 
      type: String,
      required: true
    }
  },
  computed: { 
    organization () {
      return this.appTenant.organization
    },
    licenses () {
      return this.appTenant.licenses.nodes
    }
  },
  data () {
    return {
      appTenant: {
        name: 'N/A',
        organization: {
          name: 'N/A'
        },
        licenses: {
          nodes: []
        }
      }
    }
  },
  apollo: {
    init: {
      query: appTenantById,
      fetchPolicy: 'network-only',
      variables () {
        return {
          id: this.id
        }
      },
      update (data) {
        this.appTenant = data.appTenantById
      //  console.log('app', this.appTenant)

      }
    }
  }
}
</script>
