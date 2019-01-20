import Vue from 'vue';
import Router from 'vue-router';
import ArticleList from '../components/ArticleList.vue';
import Article from '../components/Article.vue';
import SimpleArticle from '../components/SimpleArticle.vue';

import NotFound from '../components/NotFound.vue'

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
    path: '/article/:articleName',
    name: 'article',
    component: Article
  },
  {
    path: '/simple/article/:articleName',
    name: 'simpleArticle',
    component: SimpleArticle
  },
  {
    path: '*',
    name: 'notFound',
    component: NotFound
  }
];

const router = new Router({
  mode: 'history',
  routes: routes,
  hashbang: false,
  history: true
});

router.beforeEach((to, from, next) => {
  next();
});

export default router
