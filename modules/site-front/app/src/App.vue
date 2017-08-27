<template lang="html">
  <div id="app" class="body-app">
  <div class="body-header-and-content">
    <header-bar></header-bar>
      <transition name="component-fade">
        <keep-alive>
          <router-view></router-view>
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
  }

  .body-header-and-content {
    width: 100%;
    padding-bottom:75px;
  }

  .body-footer {
    position: absolute;
    bottom:0;
    width: 100%;
    left: 0;
  }

</style>


