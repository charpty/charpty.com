<template lang="html">
  <div id="app" class="body-app">
  <div class="body-header-and-content">
  <header-bar></header-bar>
      <transition name="app-fade">
        <keep-alive>
          <router-view :key="$route.path"></router-view>
        </keep-alive>
      </transition>
  </div>
  <div class="body-footer">
    <footer-bar></footer-bar>
  </div>
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

<style>
  .body-app {
    background: #ebebeb;
    min-height:100%;
    position: relative;
    font-family: "Helvetica Neue", Helvetica, "Microsoft YaHei", "WenQuanYi Micro Hei", Arial, sans-serif;
    font-size: 14px;
    line-height: 2;
  }

  .body-header-and-content {
    width: 100%;
    padding-bottom:75px;
    min-height: 768px;
  }

  .body-footer {
    position: absolute;
    bottom:0;
    width: 100%;
    left: 0;
  }

  .app-fade-enter-active, .fade-leave-active {
    transition: opacity 2s
  }
  .app-fade-enter, .app-fade-leave-to {
    opacity: 0
  }
</style>


