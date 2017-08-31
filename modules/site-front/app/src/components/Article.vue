<template>
  <main class="man-wrap">
    <div class="content-wrap">
      <div class="article-content">
        <article-md-content></article-md-content>
      </div>
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
    padding: 40px;
    width: 70%;
    background: #fff;
    min-height: 700px;
    margin-left: 100px;
  }

  .article-content {
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
