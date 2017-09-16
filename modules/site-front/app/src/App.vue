<template lang="html">
  <div id="app" class="body-app">
  <div class="body-header-and-content">
  <header-bar></header-bar>
      <transition name="fade">
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
    min-height:800px;
    position: relative;
    font-family: "Helvetica Neue", Helvetica, "Microsoft YaHei", "WenQuanYi Micro Hei", Arial, sans-serif;
    font-size: 14px;
    line-height: 2;
    width: 100%;
    overflow: hidden;
  }

  .body-header-and-content {
    width: 100%;
    padding-bottom:35px;
    min-height: 700px;
  }

  @media (max-width: 641px) {
    .body-header-and-content {
      min-height: 500px;
    }
  }

  .body-footer {
    position: relative;
    bottom:0px;
    width: 100%;
    left: 0;
  }

  .fade-enter-active, .fade-leave-active {
    transition: opacity .7s
  }
  .fade-enter, .fade-leave-to /* .fade-leave-active in below version 2.1.8 */ {
    opacity: 0
  }

</style>


