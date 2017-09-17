import Vue from 'vue';
import Router from 'vue-router';
import ArticleList from '../components/ArticleList.vue';
import Article from '../components/Article.vue';
import WriteArticle from '../components/WriteArticle.vue';
import AboutSite from '../components/AboutSite.vue';
import Y2017 from '../components/Y2017.vue';

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
    path: '/write',
    name: 'writeArticle',
    component: WriteArticle
  },
  {
    path: '/about/site',
    name: 'aboutSite',
    component: AboutSite
  },
  {
    path: '/y2017',
    name: 'y2017',
    component: Y2017
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
