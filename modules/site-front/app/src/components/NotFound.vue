<template lang="html">
  <div>
    <main class="main404">
      <div class="container404">
        <h1 class="h404">404 Not Found</h1>
        <p class="p404">您访问的页面不存在</p>
        <a class="a404" v-on:click="goHomePage()">返回首页</a>
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

<style lang="stylus">
.h404
  color #333
  font-size 36px
  font-weight 300
  letter-spacing -1
.a404
  color #e95095
  transition color .3s
  &:hover
    color purple
.p404
  color #666
.container404
  text-align center
  margin 40px auto 50px
  max-width 25rem
</style>
