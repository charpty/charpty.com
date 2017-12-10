<template>
  <main class="man-wrap">
    <main class="main-content">
      <article-md-content></article-md-content>
    </main>
  </main>
</template>

<script>
  import ArticleMdContent from './ArticleMdContent'
  import HeaderBar from './HeaderBar'

  export default {
    components: {
      'header-bar': HeaderBar,
      'article-md-content': ArticleMdContent
    }
  }
</script>

<style>
  @import "../stylus/articles.styl";
</style>
