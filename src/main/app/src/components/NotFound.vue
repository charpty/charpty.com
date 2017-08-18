<template lang="html">
  <div>
    <div class="placeholder"></div>
    <main class="blog content">
      <div class="container">
        <i class="fa fa-ship"></i>
        <p></p>
        <h1>404 Not Found</h1>
        <p>The link you followed does not exist, or the page may have been removed.</p>
        <a href="#" @click="$router.go(-1)">Return Back</a>
      </div>
    </main>
  </div>
</template>

<script>
export default {
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
  margin 80px auto 150px
  max-width 25rem
</style>
