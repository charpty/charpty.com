export default[
  {
    path: '/',
    component: resolve => require(['./components/Home'], resolve)
  }, {
    path: '/posts',
    component: resolve => require(['./components/Blog'], resolve),
    children: [
      {
        path: '',
        component: resolve => require(['./components/ExcerptList'], resolve)
      }, {
        path: ':title',
        component: resolve => require(['./components/PostDetail'], resolve)
      }
    ]
  }, {
    path: '/about',
    component: resolve => require(['./components/About'], resolve)
  }, {
    path: '/photograph',
    component: resolve => require(['./components/Photograph'], resolve)
  }, {
    path: '*',
    component: resolve => require(['./components/NotFound'], resolve)
  }
]
