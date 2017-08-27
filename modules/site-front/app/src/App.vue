<template lang="html">
  <div id="app" class="body-app" style="min-height:100%;position: relative;">
  <div style="width: 100%;padding-bottom:75px;">
    <header-bar></header-bar>
      <transition name="component-fade">
        <keep-alive>
          <router-view></router-view>
        </keep-alive>
      </transition>
  </div>
  <div style="position: absolute; bottom:0;width: 100%">
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
  }


</style>


