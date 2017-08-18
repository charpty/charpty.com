// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import VueRouter from 'vue-router'
import routers from './routers'
import './assets/css/bootstrap.min.css'
import './assets/js/bootstrap.min'

import 'normalize.css'
import './stylus/global.styl'
import 'github-markdown-css'

Vue.config.productionTip = false

Vue.use(VueRouter)

const router = new VueRouter({
  router: routers
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  template: '<App/>',
  components: {App}
})
