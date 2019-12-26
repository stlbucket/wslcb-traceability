<template>
<v-container>
  <h1>Transfers</h1>
  <v-card>
    <v-toolbar>
      <dialog-create-manifest>
      </dialog-create-manifest>
    </v-toolbar>
  </v-card>
  <v-data-table
    :headers="headers"
    :items="mappedManifests"
  >
    <template v-slot:item.id="{item}">
        <router-link 
          :to="{ 
            name: 'trc-manifest-detail',
            params: {
              id: item.id
            }
          }"
        >
          {{ item.id }}
        </router-link>
    </template>
  </v-data-table>

</v-container>
</template>

<script>
import DialogCreateManifest from './DialogCreateManifest'
import allManifests from '@/graphql/query/allManifests.graphql'

export default {
  name: 'TransferManager',
  components:{
    DialogCreateManifest
  },
  data () {
    return {
      allManifests: [],
      headers: [
        {
          text: 'id',
          value: 'id'
        },
        {
          text: 'fromLicense',
          value: 'fromLicense'
        },
        {
          text: 'toLicense',
          value: 'toLicense'
        },
        {
          text: 'itemCount',
          value: 'itemCount'
        },
        {
          text: 'scheduled',
          value: 'scheduledTransferTimestamp'
        }
      ]
    }
  },
  computed: {
    mappedManifests () {
      return this.allManifests
        .map(
          m => {
            return {
              ...m,
              fromLicense: `${m.fromLcbLicenseHolder.lcbLicense.code} - ${m.fromLcbLicenseHolder.organization.name}`,
              toLicense: `${m.toLcbLicenseHolder.lcbLicense.code} - ${m.toLcbLicenseHolder.organization.name}`,
              itemCount: m.manifestItems.totalCount
            }
          }
        )
    }
  },
  apollo: {
    init: {
      query: allManifests,
      update (data) {
        console.log('data', data)
        this.allManifests = data.allManifests.nodes
      }
    }
  }
}
</script>

<style>

</style>