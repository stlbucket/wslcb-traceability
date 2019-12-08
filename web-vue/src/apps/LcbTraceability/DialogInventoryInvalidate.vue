
<template>
    <div>
      <v-dialog v-model="dialog" persistent width="1400">
        <template v-slot:activator="{ on }">
          <v-btn
            small
            dark
            v-on="on"
            :disabled="btnDisabled"
            :hidden="hidden"
            class="text-none"
          >
            Invalidate
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Invalidate Lots</v-card-title>
          <h2>Are you sure you want to invalidate this lot?</h2>
          {{ lotDisplay }}
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn @click="dialog=false">Cancel</v-btn>
            <v-btn @click="invalidateInventoryLots">OK</v-btn>
            <v-spacer></v-spacer>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>
  import invalidateInventoryLotIds from '@/graphql/mutation/invalidateInventoryLotIds.graphql'

  export default {
    name: 'DialogInventoryInvalidate',
    props: {
      disabled: {
        type: Boolean,
        default: false
      },
      inventoryLot: {
        type: Object,
        required: false
      }
    },
    data () {
      return {
        toggleCompleted: false,
        dialog: false,
      }
    },
    computed: {
      lotDisplay () {
        return this.inventoryLot ? `${this.inventoryLot.id } - ${this.inventoryLot.description}` : 'NO INVENTORY LOT'
      },
      hidden () {
        return false
      },
      btnDisabled () {
        return this.disabled
      }
    },
    watch: {
    },
    methods: {
      invalidateInventoryLots () {
      this.$apollo.mutate({
        mutation: invalidateInventoryLotIds,
        variables: {
          ids: [this.inventoryLot.id]
        }
      })
      .then(result => {
        this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.invalidateInventoryLotIds.inventoryLots})
        this.dialog = false
      })
      .catch(error => {
        alert(error.toString())
        console.error(error)
      })
    },
  }
  }
</script>

<style>
.norm-text {
  text-transform: none !important;
}
</style>