import Vue from 'vue'
import Router from 'vue-router'
import Hello from '../components/Home'

Vue.use(Router);

const routes = [
  {
    path: '/',
    name: 'home',
    component: Hello
  },
];

const router = new Router({
  routes: routes
});

export default router
