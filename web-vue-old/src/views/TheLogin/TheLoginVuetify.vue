<template>
  <div>
    <v-text-field
      label="username"
      placeholder="username"
      box
      v-model="username"
    ></v-text-field>
    <v-text-field
      label="password"
      placeholder="password"
      box
      v-model="password"
    ></v-text-field>
    <v-btn @click="login">Login</v-btn>
    <hr>
    <h2>Other logins - same password</h2>
    <ul>
      <li>appsuperadmin</li>
      <li>testUser001</li>
    </ul>
  </div>
</template>

<script>
import TheLoginScript from './TheLoginScript'

export default {
  name: "Login",
  mixins: [TheLoginScript]
}
</script>
