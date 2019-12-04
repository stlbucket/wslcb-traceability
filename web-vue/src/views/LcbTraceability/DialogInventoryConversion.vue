
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
            @click="convert"
          >
            Convert
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Create Conversion</v-card-title>
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
    name: 'DialogInventoryConversion',
    props: {
      disabled: {
        type: Boolean,
        default: false
      },
      parentLot: {
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
      convert () {
        
      }
    }
  }
</script>

<style>
.norm-text {
  text-transform: none !important;
}
</style>