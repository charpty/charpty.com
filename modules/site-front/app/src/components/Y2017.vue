<template>
  <main class="y2017-post">
    <div class="container">
      <div class="row">
        <div class="col-sm-8 blog-main">
          <div class="y2017-post">
            <h2 class="blog-post-title">2017年了</h2>
            <i class="fa fa-user-circle" aria-hidden="true"></i>&nbsp;<span>蔡博</span>&nbsp;&nbsp;
            <i class="fa fa-calendar" aria-hidden="true"></i>&nbsp;
            <span class="blog-post-meta">2017-01-02 </span>&nbsp;&nbsp;
          </div>
        </div>
      </div>
      <div v-html="this.content">
        <i></i>
      </div>
    </div>

  </main>
</template>

<script>
  import markdownParser from '../utils/markdown'

  export default {
    data() {
      return {
        content: "2017年了，一个崭新的开始，我也做了去年一直想做的事情，就是自己维护一个博客网站，其实之前也尝试过，" +
        "但是总是由于种种原因不是特别顺利，特别是对于数据备份和管理不是特别熟悉，也就迟迟没有做好。不知不觉已是2017年，16年是最累的一年，也是收获比较多的一年。" +
        "自己也操作过了价值不菲的各类生产环境服务器，有信心维护好这样一个个人博客网站。" +
        "<br><br>慢慢的我也会把我在```csdn```和微博上写的那些小文章挪过来，虽然都是些微不足道的小文章，有的甚至就是一些埋怨的话，但是也总算是自己人生中的经历，算是给自己的一种鼓励吧"
      }
    },
    created() {
      this.content = markdownParser.parse(this.content);
      document.title = "charpty的2017年";
    }
  }

</script>

<style>
  .y2017-post {
    align-self: center;
    align: center;
    margin-bottom: 20px;
    background: ghostwhite;
    overflow: hidden;
  }

</style>
