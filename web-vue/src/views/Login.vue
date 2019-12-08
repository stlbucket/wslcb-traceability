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
import loginMutation from '@/graphql/mutation/login.graphql'
import currentAppUser from '@/graphql/query/currentAppUser.graphql'
import {onLogin} from '@/vue-apollo.js'

export default {
  name: "Login",
  methods: {
    login () {
      const variables = {
        username: this.username,
        password: this.password
      }

      this.$apollo.mutate({
        mutation: loginMutation,
        variables: variables
      })
      .then(result => {
        onLogin(this.$apollo, result.data.authenticate.jwtToken)
        this.getCurrentAppUserContact()
        this.$eventHub.$emit('login')
      })
      .catch(error => {
        console.log('ERROR', error)
      })
    },
    getCurrentAppUserContact () {
      this.$apollo.query({
        query: currentAppUser,
        fetchPolicy: 'network-only',
        variables: {}
      })
      .then(result => {
        this.$store.commit('login', { currentAppUser: result.data.allAppUsers.nodes[0] })
        this.$router.push({name: 'home'})
      })
      .catch(error => {
        console.log('ERROR', error)
      })
    }
  },
  computed: {
  },
  data () {
    return {
      username: 'testAdmin001',
      password: 'badpassword'
    }
  },
}
</script>
