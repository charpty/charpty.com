import Vue from 'vue'
import Router from 'vue-router'
import ArticleList from '../components/ArticleList'
import Article from '../components/Article'

Vue.use(Router);

const routes = [
  {
    path: '/',
    name: 'homepage',
    redirect: '/articles'
  },
  {
    path: '/articles',
    name: 'articleList',
    component: ArticleList
  },
  {
    path: '/article/:articleId',
    name: 'article',
    component: Article
  },
  {
    path: '/y2017',
    name: 'y2017',
    component: Article
  }
];

const router = new Router({
  mode: 'history',
  routes: routes,
  hashbang: false,
  history: true
});

router.beforeEach((to, from, next) => {
  // TODO 那些路由或者情况要置顶
  next();
});

export default router
