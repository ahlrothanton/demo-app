import Vue from 'vue'
import App from './App.vue'
import axios from 'axios'

Vue.config.productionTip = false

axios.defaults.baseURL = process.env.VUE_APP_API_URL || 'http://localhost:5000/api';

new Vue({
  render: h => h(App),
}).$mount('#app')
