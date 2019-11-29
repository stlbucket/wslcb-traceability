<template>
  <v-container>
    <div class="panel-body">
      <h1>{{header}}</h1><hr>
      <vue-form-generator :schema="schema" :model="model" :options="formOptions"></vue-form-generator>
    </div>
    <v-tabs
      dark
      slider-color="yellow"
    >
      <v-tab
        v-for="child in children"
        :key="child.id"
        ripple
      >
        {{child.__typename}}
      </v-tab>
      <v-tab-item
        v-for="child in children"
        :key="child.id"
      >
        <entity-form
          :data="child"
        ></entity-form>
      </v-tab-item>

      <v-tab
        v-for="collection in collections"
        :key="collection.name"
        :class="customTabTitle"
        ripple
      >
        <div>{{collection.__typename.replace('Connection', '')}}</div>
      </v-tab>
      <v-tab-item
        v-for="collection in collections"
        :key="collection.name"
      >
        <entity-list
          :collection="collection"
        ></entity-list>
      </v-tab-item>

    </v-tabs>
  </v-container>
</template>

<script>
import VueFormGenerator from 'vue-form-generator'
import EntityList from './EntityList'
// import './style.css'
import query from '@/graphql/query/organizationById.graphql'

export default {
  name: "entityForm",
  components: {
    EntityList
  },
  props: {
    data: {
      type: Object,
      default: {}
    }
  },
  computed: {
    header () {
      return this.data.__typename || 'Entity'
    },
    srcType () {
      return this.$store.state.graphqlTypes.find(gt => gt.name === this.data.__typename)
    },
    children () {
      return Object.keys(this.data)
        .reduce(
          (a, f) => {
            return (typeof this.data[f] === 'object' && !(Array.isArray(this.data[f]))) ? [...a, this.data[f]] : a
          }, []
        )
        .filter(c => c.__typename.indexOf('Connection') === -1)
    },
    collections () {
      const c = Object.keys(this.data)
        .filter(f => {
          return (typeof this.data[f] === 'object' && Array.isArray(this.data[f].nodes))
        })
        .map(f => this.data[f])
      return c
    },
    model () {
      return Object.keys(this.data)
        .filter(k => typeof this.data[k] !== 'object')
        .filter(k => Array.isArray(this.data[k]) === false)
        .filter(k => this.ignoreFields.indexOf(k) === -1).reduce(
          (a,k) => {
            return {
              ...a,
              [k]: this.data[k]
            }
          }, {}
        )
    },
    schema () {
      const fields = Object.keys(this.model)
        .map(
          f => {
            const srcField = this.srcType.fields.find(sf => sf.name === f)
            return {
              type: 'input',
              inputType: 'text',
              label: f,
              model: f,
              readonly: true,
              disabled: true
            }
          }
        )
      return {
        fields: fields
      }
    }
  },
  data () {
    return {
      ignoreFields: ['__typename'],
      // model: {},
      // schema: {fields: []},
      formOptions: {
        validateAfterLoad: true,
        validateAfterChanged: true,
        validateAsync: true
      }
    }
  }
}
</script>


<style>
.customTabTitle div {
  text-transform: none;
  font-size: 12px;
}
</style>