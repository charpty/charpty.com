<template>
  <main class="simple-article">
    <div class="simple-container">
      <div class="simple-col">
        <div>
          <h2 class="simple-article-title">2017年了</h2>
          <i class="fa fa-user-circle" aria-hidden="true"></i>&nbsp;
          <span v-on:click="goAboutAuthor()">蔡博</span>&nbsp;&nbsp;
          <i class="fa fa-calendar" aria-hidden="true"></i>&nbsp;
          <span class="simple-blog-post-meta">2017-01-02 </span>&nbsp;&nbsp;
        </div>
      </div>
      <div class="simple-article-content" v-html="this.content">
        <i></i>
      </div>
    </div>
  </main>
</template>

<script>
  import markdownParser from '../utils/markdown'
  import router from '../router'

  export default {
    data() {
      return {
        content: "2017年了，又一个崭新的开始，我也做了去年一直想做的事情：自己维护一个博客网站。其实之前也尝试过，" +
        "但是总是由于种种原因不是特别顺利，后来尝试了WordPress也陷入找主题、装插件的无尽循环。<br>" +
        "既然自己会写些代码，也操作过价值不菲的各类生产环境服务器，为何不直接自己写一个呢，" +
        "于是就有了这么个自设计、自编码、自运维的博客网站。" +
        "<br><br>慢慢的我也会把我在CSDN和微博上写的那些小文章挪过来，虽然都是些微不足道的小文章，有的甚至就是一些埋怨的话，但是也总算是自己人生中的经历，算是给自己的一种鼓励吧。"
      }
    },
    created() {
      this.content = markdownParser.parse(this.content);
      document.title = "charpty的2017年";
    },
    methods: {
      goAboutAuthor: function () {
        router.push("/about/author");
      },
    }
  }

</script>

<style>
  @import "../stylus/animation.styl";
  @import "../stylus/front.styl";
  @import "../stylus/simple_article.styl";
</style>
