import Vue from 'vue'
import App from './App.vue'

import BootstrapVue from 'bootstrap-vue'
import './css/main.scss'
// import Promise from './polyfills.js'

Vue.use(BootstrapVue);
// Vue.config.productionTip = false


new Vue({
  el: '#app',
  render: h => h(App)
})
