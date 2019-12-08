<template>
  <div>
    <h1>Address Book</h1>
    <v-tabs
      dark
      slider-color="yellow"
    >
      <v-tab
        key="organization-list"
        ripple
      >
        Organizations
      </v-tab>
      <v-tab-item
        key="organization-list"
      >
        <organization-list-view></organization-list-view>
      </v-tab-item>

      <v-tab
        key="contact-list"
        ripple
      >
        Contacts
      </v-tab>
      <v-tab-item
        key="contact-list"
      >
        <contact-list></contact-list>
      </v-tab-item>

      <v-tab
        key="facility-list"
        ripple
      >
        Facilities
      </v-tab>
      <v-tab-item
        key="facility-list"
      >
        <facility-list></facility-list>
      </v-tab-item>
    </v-tabs>
  </div>
</template>

<script>
import OrganizationListView from '@/views/Org/OrganizationListView'
import ContactList from '@/views/Org/ContactListView'
import FacilityList from '@/views/Org/FacilityListView'

  export default {
    components: {
      OrganizationListView,
      ContactList,
      FacilityList
    }
  }
</script>
