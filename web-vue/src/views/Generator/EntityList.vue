<template>
  <div>
    <h2>{{entityType}}</h2>
    <v-data-table
      :headers="headers"
      :columns="columns"
      :items="items"
      hide-default-footer
    >
      <template slot="items" slot-scope="props">
        <td 
          v-for="column in columns" 
          :key="column.name"
        >
          <router-link 
            v-if="column.routeLink" 
            :to="{ 
              name: column.routeLink.name,
              params: Object.keys(column.routeLink.params).reduce(
                (a, key) => {
                  return Object.assign(a, {
                    [key]: props.item[column.routeLink.params[key]]
                  })
                }, {}
              )
            }"
          >
            {{ props.item[column.name] }}
          </router-link>
          <span v-else>{{ props.item[column.name] }}</span>
        </td>
      </template>
    </v-data-table>
  </div>
</template>

<script>
export default {
  name: "EntityList",
  props: {
    collection: {
      type: Object,
      required: true
    }
  },
  computed: {
    entityType () {
      return this.collection.__typename.replace('Connection', '')
    },
    items () {
    //  console.log('coll', this.collection)
      return this.collection.nodes
    },
    headers () {
      return Object.keys(this.collection.nodes[0])
        .filter(k => ['__typename'].indexOf(k) === -1)
        .filter(k => typeof this.collection.nodes[0][k] !== 'object' )
        .reduce(
          (a, c) => {
            return [...a, {
              text: c
              ,value: c
            }]
          }, []
        )
    },
    columns () {
      return Object.keys(this.collection.nodes[0])
        .filter(k => ['__typename'].indexOf(k) === -1)
        .filter(k => typeof this.collection.nodes[0][k] !== 'object' )
        .reduce(
          (a, c) => {
            return [...a, {
              name: c
            }]
          }, []
        )
    },
  }
}
</script>
