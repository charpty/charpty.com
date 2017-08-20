<template lang="html">
  <div id="app">
    <header-bar></header-bar>
      <transition name="component-fade">
        <keep-alive>
          <router-view></router-view>
        </keep-alive>
      </transition>
    <footer-bar></footer-bar>
  </div>
</template>

<script>
  import HeaderBar from './components/HeaderBar'
  import FooterBar from './components/FooterBar'
  export default {
    name: 'app',
    components: {
      'header-bar':HeaderBar,
      'footer-bar':FooterBar
    }
  }

</script>


<style lang="stylus">
  @import './stylus/style.styl'

  #app
    display: flex
    flex-flow:column
    min-height: 100vh

  main
    flex:1
</style>


