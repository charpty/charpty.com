<template>
  <main class="man-wrap">
    <div class="content-wrap">
      <article-md-content></article-md-content>
    </div>
  </main>
</template>

<script>
  import ArticleMdContent from './ArticleMdContent'

  export default {
    components: {
      'article-md-content': ArticleMdContent
    }
  }
</script>

<style>
  .man-wrap {
    overflow: hidden;
    min-height: 500px;
  }

  .content-wrap {
    float: left;
    box-sizing: border-box;
    padding: 30px;
    width: 70%;
    background: #fff;
    min-height: 700px;
    margin-left: 10px;
    margin-right: 10px;
  }

  @media (max-width: 641px) {
    .content-wrap {
      box-sizing: border-box;
      padding: 8px;
      width: 100%;
      background: #fff;
      min-height: 700px;
      margin-left: 1px;
      margin-right: 1px;
    }
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
