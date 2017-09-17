<template>
  <main class="simple-article">
    <div class="container">
      <div class="row">
        <div class="col-md-9 main-content">
          <div>
            <h2 class="simple-article-title">关于本站</h2>
            <i class="fa fa-user-circle" aria-hidden="true"></i>&nbsp;
            <span v-on:click="goAboutAuthor()">蔡博</span>&nbsp;&nbsp;
            <i class="fa fa-calendar" aria-hidden="true"></i>&nbsp;
            <span class="blog-post-meta">2017-09-17 </span>&nbsp;&nbsp;
          </div>
        </div>
      </div>
      <br>
      <p>本站由<span v-on:click="goAboutAuthor()"><a>charpty</a></span>编写，主要用于个人博客网站</p>
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
        content: "网站建议欢迎邮件：<a>charpty@gmail.com</a><br><hr>"
        + "前端技术栈：<br>&nbsp;[Vue](https://cn.vuejs.org)、[fetch](https://github.com/github/fetch)、"
        + "[Bootstrap](http://v3.bootcss.com)<br>"
        + "后端技术栈：<br>&nbsp;[Spring Boot](https://projects.spring.io/spring-boot)、"
        + "[JPA](https://projects.spring.io/spring-data-jpa)、[tomato](https://github.com/charpty/tomato)、"
        + "[mysql5.7](https://dev.mysql.com/doc/relnotes/mysql/5.7/en/)<br>"
        + "服务器相关：<br>&nbsp;[OpenResty](https://github.com/openresty)、"
        + "[阿里云CDN](https://help.aliyun.com/document_detail/27101.html)、[阿里云OSS](https://help.aliyun.com/document_detail/31817.html)"
        + "<br><br>本站的代码都开放在<br>[https://github.com/charpty/charpty.com](https://github.com/charpty/charpty.com)"
        + "<br>文章生成都使用<br>[https://github.com/charpty/charpty.com.mds](https://github.com/charpty/charpty.com.mds)"
      }
    },
    created() {
      this.content = markdownParser.parse(this.content);
      document.title = "关于本站";
    },
    methods: {
      goAboutAuthor(){
        router.push("/about/author")
      }
    }
  }

</script>

<style>
  @import "../stylus/simple_article.styl";

  .simple-article-content {
    margin-top: 0;
  }
</style>
