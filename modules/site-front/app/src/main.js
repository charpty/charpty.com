import Vue from 'vue'
import App from './App'
import router from './router'
import './assets/css/bootstrap.min.css'
import './assets/js/bootstrap.min'

import 'normalize.css'
import './stylus/global.styl'
import 'github-markdown-css'


Vue.$global = Vue.prototype.$global = {};
Vue.$global.showHeader = true;

var vm = new Vue({
  el: '#app',
  router,
  template: '<App/>',
  components: {App}
})
