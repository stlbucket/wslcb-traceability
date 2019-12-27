import Vue from 'vue'
import Vuex from 'vuex'
import createPersistedState from 'vuex-persistedstate'

Vue.use(Vuex)

export default new Vuex.Store({
  plugins: [
    createPersistedState()
  ],
  state: {
    isLoggedIn: false,
    currentAppUser: null,
    graphqlTypes: [],
    recentInventoryLotChanges: [],
    userAppState: {
      tabStatus: []
    },
    inventoryTypes: []
  },
  mutations: {
    login (state, payload) {
      state.currentAppUser = payload.currentAppUser
      state.isLoggedIn = payload.currentAppUser !== null && payload.currentAppUser !== undefined
      state.recentInventoryLotChanges = []
    },
    logout (state) {
      state.isLoggedIn = false
      state.currentAppUser = null
      state.recentInventoryLotChanges = []
    },
    setGraphqlTypes (state, payload) {
      state.graphqlTypes = payload
    },
    addRecentInventoryLotChange (state, payload) {
      const newChanges = payload.newChanges
      const changedIds = newChanges.map(nc => nc.id)
      const existingChanges = state.recentInventoryLotChanges.filter(cc => changedIds.indexOf(cc.id) === -1)
      state.recentInventoryLotChanges = [...existingChanges, ...newChanges]
    },
    clearRecentChanges (state) {
      state.recentInventoryLotChanges = []
    },
    setUserTabStatus (state, payload) {
      const tabName = payload.tabName
      const tabValue = payload.tabValue
      const others = state.userAppState.tabStatus.filter(ts => ts.tabName !== tabName)


      state.userAppState = {
        ...state.userAppState,
        tabStatus: [
          ...others,
          {
            tabName: tabName,
            tabValue: tabValue
          }
        ]
      }
    },
    setInventoryTypes (state, payload) {
      state.inventoryTypes = payload.inventoryTypes
    }
  },
  actions: {

  }
})
