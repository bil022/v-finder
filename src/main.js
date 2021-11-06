import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'
import Vue from 'vue'
import App from './App.vue'

import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'
//import Vuetify from 'vuetify/dist/vuetify'

Vue.config.productionTip = false

//Vue.use(Vuetify)
Vue.use(BootstrapVue)
Vue.use(IconsPlugin)

new Vue({
  render: h => h(App),
}).$mount('#app')
