<template>
  <v-container grid-list-md text-xs-center>
    <v-card>
      <v-card-title class="headline">License</v-card-title>
      <v-layout row wrap>
        <v-flex xs4>
          <license-detail-component
            :license="license"
          ></license-detail-component>
          <v-expansion-panel>
            <!-- <v-expansion-panel-content key="organization">
              <div slot="header">Organization</div>
              <v-card raised>
                <organization-detail-component
                  :organization="organization"
                ></organization-detail-component>
              </v-card>
            </v-expansion-panel-content>
            <v-expansion-panel-content key="assignedToContact">
              <div slot="header">Assigned To</div>
              <v-card raised>
                <contact-detail-component
                  :contact="assignedToContact"
                ></contact-detail-component>
              </v-card>
            </v-expansion-panel-content> -->
            <v-expansion-panel-content key="application">
              <div slot="header">Application</div>
              <v-card raised>
                <application-detail-component
                  :application="application"
                ></application-detail-component>
              </v-card>
            </v-expansion-panel-content>
            <v-expansion-panel-content key="licenseType">
              <div slot="header">LicenseType</div>
              <v-card raised>
                <license-type-detail-component
                  :licenseType="licenseType"
                ></license-type-detail-component>
              </v-card>
            </v-expansion-panel-content>
          </v-expansion-panel>
        </v-flex>
        <v-flex xs4>
          <v-card raised>
            <v-card-title>Owner Organization</v-card-title>
            <organization-detail-component
              :organization="organization"
            ></organization-detail-component>
          </v-card>
          <v-card raised>
            <v-card-title>Assigned To</v-card-title>
            <contact-detail-component
              :contact="assignedToContact"
            ></contact-detail-component>
          </v-card>
          <!-- <v-expansion-panel expand>
            <v-expansion-panel-content key="organization" value="true">
              <div slot="header">Organization</div>
            </v-expansion-panel-content>
            <v-expansion-panel-content key="assignedToContact" value="true">
              <div slot="header">Assigned To</div>
            </v-expansion-panel-content>
          </v-expansion-panel> -->
        </v-flex>
      </v-layout>
    </v-card>
  </v-container>
</template>

<script>
import licenseById from '@/graphql/query/licenseById.graphql'
import LicenseDetailComponent from '@/components/App/LicenseDetail'
import LicenseTypeDetailComponent from '@/components/App/LicenseTypeDetail'
import ApplicationDetailComponent from '@/components/App/ApplicationDetail'
import OrganizationDetailComponent from '@/components/Org/OrganizationDetail'
import ContactDetailComponent from '@/components/Org/ContactDetail'


export default {
  name: "LicenseDetailView",
  components: {
    LicenseDetailComponent,
    LicenseTypeDetailComponent,
    ApplicationDetailComponent,
    OrganizationDetailComponent,
    ContactDetailComponent
  },
  props: {
    id: { 
      type: String,
      required: true
    }
  },
  computed: {
    licenseType () {
      return this.license.licenseType
    },
    application () {
      return this.license.licenseType.application
    },
    organization () {
      console.log(this.license)
      return this.license.appTenant.organization
    },
    assignedToContact () {
      return this.license.assignedToAppUserContact.contact
    }
  },
  data () {
    return {
      license: {
        name: 'N/A',
        appTenant: {
          name: 'N/A',
          organization: {
            name: 'N/A'
          },
        },
        licenseType: {
          name: 'N/A',
          application: {
            name: 'N/A'
          }
        },
        assignedToAppUserContact: {
          contact: {
            firstName: 'N/A'
          }
        }
      }
    }
  },
  apollo: {
    init: {
      query: licenseById,
      fetchPolicy: 'network-only',
      variables () {
        return {
          id: this.id
        }
      },
      update (data) {
        this.license = data.licenseById
       console.log('license', this.license)
      }
    }
  }
}
</script>
