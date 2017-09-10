<template>
  <main class="man-wrap">
    <main class="col-md-8 main-content">
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
  .man-wrap {
    overflow: hidden;
    min-height: 500px;
    overflow-x: hidden
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
      padding: 10px;
      width: 100%;
      background: #fff;
      min-height: 700px;
      margin-left: 10px;
      margin-right: 10px;
    }

    .col-md-8 {
      padding-right: 0px;
      padding-left: 0px;
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
