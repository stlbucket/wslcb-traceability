
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
            @click="invalidate"
          >
            Invalidate
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Create Invalidate</v-card-title>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn @click="dialog=false">Cancel</v-btn>
            <v-btn @click="dialog=false">OK</v-btn>
            <v-spacer></v-spacer>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>

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
      invalidate () {
        
      }
    }
  }
</script>

<style>
.norm-text {
  text-transform: none !important;
}
</style>