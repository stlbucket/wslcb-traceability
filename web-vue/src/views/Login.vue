<template>
  <div>
    <!-- <v-text-field
      label="username"
      placeholder="username"
      rounded
      v-model="username"
    ></v-text-field> -->
    <v-combobox
      v-model="username"
      :items="users"
    >
    </v-combobox>
    <v-text-field
      label="password"
      placeholder="password"
      rounded
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
      username: 'lcb_producer_admin',
      password: 'badpassword',
      users: [
        'appsuperadmin',
        'lcb_producer_admin',
        'lcb_processor_admin',
        'lcb_retail_admin',
        'lcb_qa_lab_admin',
        'lcb_producer_user',
        'lcb_processor_user',
        'lcb_retail_user',
        'lcb_qa_lab_user'
      ]
    }
  },
}
</script>
