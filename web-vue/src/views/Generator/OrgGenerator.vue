<template>
  <v-layout>
    <entity-form 
      :data="data"
    ></entity-form>
  </v-layout>
</template>

<script>
import EntityForm from './EntityForm'
import VueFormGenerator from 'vue-form-generator'
// import './style.css'
import query from '@/graphql/query/organizationById.graphql'

export default {
  components: {
    EntityForm
  },
  computed: {
  },
  apollo: {
    init: {
      query: query,
      variables () {
        return {
          id: "2082191189993325583"
        }
      },
      networkPolicy: 'fetch-only',
      update (data) {
      //  console.log('data', data.organizationById)
        this.data = data.organizationById
      }
    }
  },
  data () {
    return {
      ignoreFields: ['__typename'],
      data: {},
      model: {},
      schema: {fields: []},
      formOptions: {
        validateAfterLoad: true,
        validateAfterChanged: true,
        validateAsync: true
      }
    }
  }
}
</script>
