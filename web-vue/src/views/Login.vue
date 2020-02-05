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
      this.$apollo.mutate({
        mutation: currentAppUser,
        fetchPolicy: 'no-cache',
        variables: {}
      })
      .then(result => {
        this.$store.commit('login', { currentAppUser: result.data.currentAppUser.appUser })
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
      username: 'producer_1_admin',
      password: 'badpassword',
      users: [
        'appsuperadmin',
        'producer_1_admin',
        'processor_1_admin',
        'producer_processor_1_admin',
        'retailer_1_admin',
        'lab_1_admin',
        'tribe_1_admin',
        'co_op_1_admin',
        'transporter_1_admin',
        'producer_1_user',
        'processor_1_user',
        'producer_processor_1_user',
        'retailer_1_user',
        'lab_1_user',
        'tribe_1_user',
        'co_op_1_user',
        'transporter_1_user'   
      ]
    }
  },
}
</script>
