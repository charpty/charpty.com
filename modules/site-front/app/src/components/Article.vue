<template>
  <main class="man-wrap">
    <article-main></article-main>
  </main>
</template>

<script>
  import ArticleMain from './ArticleMain'

  export default {
    components: {
      'article-main': ArticleMain
    }
  }
</script>

<style>
  .man-wrap {
    align: center;
    overflow: hidden;
    min-height: 500px;
  }

  @media (min-width: 1281px) {
    .man-wrap {
      align: center;
      margin-left: 100px;
      margin-right: 100px;
      overflow: hidden;
    }
  }
</style>
