import Vue from 'vue'
import Router from 'vue-router'
import Home from '../components/Home'
import ArticleList from '../components/ArticleList'

Vue.use(Router);

const routes = [
  {
    path: '/',
    name: 'ArticleList',
    component: ArticleList
  }
];

const router = new Router({
  routes: routes
});

export default router
