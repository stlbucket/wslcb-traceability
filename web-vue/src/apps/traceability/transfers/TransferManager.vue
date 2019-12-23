<template>
<v-container>
  <h1>Transfers</h1>
  <v-card>
    <v-toolbar>
      <dialog-create-manifest>
      </dialog-create-manifest>
    </v-toolbar>
  </v-card>

</v-container>
</template>

<script>
import DialogCreateManifest from './DialogCreateManifest'

export default {
  name: 'TransferManager',
  components:{
    DialogCreateManifest
  } 
}
</script>

<style>

</style>