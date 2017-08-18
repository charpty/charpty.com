<template>
<div>
  <div class="placeholder"></div>
  <div class="querybar-back" v-if="$route.query.tag || $route.query.category">
    <div class="querybar">
      <h2 class="query-content">{{$route.query.tag?'Tag':'Category'}} : {{$route.query.tag || $route.query.category}}</h2>
      <div class="query-nav">
        <router-link to="/posts">Blog</router-link> &gt; <span>{{$route.query.tag?'Posts Tagged':'Archive by Category'}} "{{$route.query.tag || $route.query.category}}"</span> </div>
    </div>
  </div>
  <main class="blog content">
    <div class="blog-page col-2">
      <router-view></router-view>
      <side-bar></side-bar>
    </div>
  </main>
</div>
</template>

<script>
import SideBar from './SideBar'
import ExcerptList from './ExcerptList'
export default {
  components: {
    SideBar,
    ExcerptList
  }
}
</script>

<style lang="stylus" scoped>
@import '../stylus/style.styl'
.content
  padding:50px 0
  fullWidth()

.placeholder
  height:156px
  position:relative
  @media (max-width: 601px)
    height:120px

.querybar
  position:relative
  display:flex
  line-height:24px
  padding:2em 20px 2em
  fullWidth()
  justify-content:space-between
  @media (max-width: 601px)
    justify-content:center
    align-items:center
    flex-flow:column
  .query-content
    font-size:1.4rem
    font-weight:400
    display:inline-block
    color:#444
    letter-spacing:1
    text-transform:capitalize
    margin:.3rem 1.5rem .3rem 0

.query-nav
  display:inline-block
  font-size:.7rem
  color:#666
  padding-right:20px
  z-index:2
  line-height:1.4
  margin:.6rem 0 .3rem
  a
    color:#e95095 !important
    transition:color .3s
    &:hover
      color:#7049ba !important

.querybar-back
  background:#f5f5f5
</style>
