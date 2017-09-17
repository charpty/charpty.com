<template lang="html">
  <div>
    <div class="placeholder"></div>
    <main class="blog content">
      <div class="container">
        <i class="fa fa-ship"></i>
        <p></p>
        <h1>404 Not Found</h1>
        <p>您访问的页面不存在</p>
        <a v-on:click="goHomePage()">返回首页</a>
      </div>
    </main>
  </div>
</template>

<script>
  import router from '../router'

  export default {
  methods:{
      goHomePage() {
        router.push("/")
      }
  }
}
</script>

<style lang="stylus" scoped>
.content
  padding:10px 0
  fullWidth()

.placeholder
  height:16px
  position:relative
  @media (max-width: 641px)
    height:10px
i
  font-size 100px
  color #e95095

h1
  color #333
  font-size 36px
  font-weight 300
  letter-spacing -1
a
  color #e95095
  transition color .3s
  &:hover
    color purple
p
  color #666
.container
  text-align center
  margin 40px auto 50px
  max-width 25rem
</style>
