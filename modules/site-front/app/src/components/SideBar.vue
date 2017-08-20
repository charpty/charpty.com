<template>
  <aside class="col-sub" v-scroll="scrollcallback" :style="{marginTop:offsetY+'px'}">
    <widget-recentpost></widget-recentpost>
    <!-- <widget-mostcomment></widget-mostcomment> -->
    <widget-tags></widget-tags>
    <widget-categories></widget-categories>
  </aside>
</template>

<script>
  import WidgetRecentpost from './widgets/WidgetRecentPost'
  import WidgetMostcomment from './widgets/WidgetMostComment'
  import WidgetTags from './widgets/WidgetTags'
  import WidgetCategories from './widgets/WidgetCategories'
  import eventDirective from '../directives/eventListener'
  import utils from '../utils'
  const {
    reduce
  } = Array.prototype
  export default {
    data () {
      return {
        offsetY: 0,
        blogEle: null,
        widgets: null
      }
    },
    components: {
      WidgetRecentpost,
      WidgetMostcomment,
      WidgetTags,
      WidgetCategories
    },
    methods: {
      scrollcallback: utils._throttle(function () {
//      let limit = this.blogEle.offsetHeight - 174 - this.widgets::reduce((a, b) => {
//        return b.offsetHeight + a
//      }, 0)
        let limit = 1;
        this.offsetY = document.documentElement.clientWidth <= 900 ? 35 : window.scrollY > 60 ? window.scrollY - 120 : 0
        this.offsetY = Math.max(Math.min(this.offsetY, limit), 0)
      }, 50, 500)
    },
    directives: {
      scroll: eventDirective('scroll')
    },
    mounted () {
      this.blogEle = document.querySelector('.article-page')
      this.widgets = document.querySelectorAll('.widget-container')
    }
  }
</script>

<style lang="stylus" scoped>
  aside
    transition: margin 1s
</style>
