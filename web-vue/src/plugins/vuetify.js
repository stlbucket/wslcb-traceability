import Vue from 'vue';
import Vuetify from 'vuetify/lib';
// import 'vuetify/src/stylus/app.styl'
import 'vuetify/src/styles/main.sass'
import 'material-design-icons-iconfont/dist/material-design-icons.css' // Ensure you are using css-loader

Vue.use(Vuetify);

export default new Vuetify({
  icons: {
    iconfont: 'mdi',
  },
  theme: {
    dark: true,
  },
});
