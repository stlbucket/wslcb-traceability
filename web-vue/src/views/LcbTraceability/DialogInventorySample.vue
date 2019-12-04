
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
            Sample
          </v-btn>
        </template>
        <v-card>
          <v-card-title class="headline">Create Sample</v-card-title>
          <v-text-field label="Name" v-model="currentName" :disabled="disabled"></v-text-field>
          <v-card-actions>
            <v-spacer></v-spacer>
            <v-btn :hidden="disabled" @click="dialog=false">Cancel</v-btn>
            <v-btn :hidden="!disabled" @click="dialog=false">OK</v-btn>
            <v-spacer></v-spacer>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
</template>

<script>

  export default {
    name: 'DialogInventorySample',
    props: {
      disabled: {
        type: Boolean,
        default: false
      },
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
    }
  }
</script>

<style>
.norm-text {
  text-transform: none !important;
}
</style>