import Vue from 'vue'
import Router from 'vue-router'
import Home from '../components/Home'
import ArticleList from '../components/ArticleList'
import Article from '../components/Article'

Vue.use(Router);

const routes = [
  {
    path: '/',
    name: 'ArticleList',
    component: ArticleList
  },
  {
    path: '/article/:articleId',
    name: 'article',
    component: Article
  }
];

const router = new Router({
  routes: routes
});

export default router
