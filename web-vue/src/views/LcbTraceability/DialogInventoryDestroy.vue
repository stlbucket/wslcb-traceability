
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
            @click="activate"
          >
            Destroy
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Create Destroy</v-card-title>
          <h2>Are you sure you want to destroy this lot?</h2>
          {{ inventoryLot.id }} - {{ inventoryLot.description }}
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn @click="dialog=false">Cancel</v-btn>
            <v-btn @click="destroyInventoryLots">OK</v-btn>
            <v-spacer></v-spacer>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>
  import destroyInventoryLotIds from '@/graphql/mutation/destroyInventoryLotIds.graphql'

  export default {
    name: 'DialogInventoryDestroy',
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
      destroyInventoryLots () {
      this.$apollo.mutate({
        mutation: destroyInventoryLotIds,
        variables: {
          ids: [this.inventoryLot.id]
        }
      })
      .then(result => {
        this.$store.commit('addRecentInventoryLotChange', { newChanges: result.data.destroyInventoryLotIds.inventoryLots})
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