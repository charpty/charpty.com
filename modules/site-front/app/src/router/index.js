import Vue from 'vue'
import Router from 'vue-router'
import Home from '../components/Home'
import BlogList from '../components/BlogList'

Vue.use(Router);

const routes = [
  {
    path: '/',
    name: 'blogList',
    component: BlogList
  }
];

const router = new Router({
  routes: routes
});

export default router
