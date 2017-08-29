<template>
  <main>
    <div class="blog-header">
      <h1 class="blog-title">The Bootstrap Blog</h1>
      <p class="lead blog-description">The official example template of creating a blog with Bootstrap.</p>
    </div>

    <div class="row">

      <div class="col-sm-8 blog-main">

        <div class="blog-post">
          <h2 class="blog-post-title">Sample blog post</h2>
          <p class="blog-post-meta">January 1, 2014 by <a href="#">Mark</a></p>

        </div>
      </div>
    </div>

  </main>
</template>

<script>
  import api from '../api'
  import router from '../router'

  export default {
    data() {
      return {
        article: {}
      }
    },
    created () {
      this.getArticleDetail();
    },
    methods: {
      getArticleDetail: async function () {
        let r = api.get("/article/" + this.$route.params.articleId);
        this.article = r;
      }
    }
  }
</script>

<style>
  .blog-post {
    margin-bottom: 60px;
  }

  .blog-post-title {
    margin-bottom: 5px;
    font-size: 40px;
  }

  .blog-post-meta {
    margin-bottom: 20px;
    color: #999;
  }

  .blog-masthead {
    background-color: #428bca;
    -webkit-box-shadow: inset 0 -2px 5px rgba(0, 0, 0, .1);
    box-shadow: inset 0 -2px 5px rgba(0, 0, 0, .1);
  }

  .blog-nav-item {
    position: relative;
    display: inline-block;
    padding: 10px;
    font-weight: 500;
    color: #cdddeb;
  }

  .blog-nav-item:hover,
  .blog-nav-item:focus {
    color: #fff;
    text-decoration: none;
  }

  .blog-nav .active {
    color: #fff;
  }

  .blog-nav .active:after {
    position: absolute;
    bottom: 0;
    left: 50%;
    width: 0;
    height: 0;
    margin-left: -5px;
    vertical-align: middle;
    content: " ";
    border-right: 5px solid transparent;
    border-bottom: 5px solid;
    border-left: 5px solid transparent;
  }

  .blog-header {
    padding-top: 20px;
    padding-bottom: 20px;
  }

  .blog-title {
    margin-top: 30px;
    margin-bottom: 0;
    font-size: 60px;
    font-weight: normal;
  }

  .blog-description {
    font-size: 20px;
    color: #999;
  }

  .blog-main {
    font-size: 18px;
    line-height: 1.5;
  }


</style>
