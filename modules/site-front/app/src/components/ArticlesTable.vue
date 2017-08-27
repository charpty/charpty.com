<template>
  <main>
    <section class="content-wrap">
      <div class="container">
        <div class="row">
          <main class="col-md-8 main-content">
            <article id=108    class="post">
              <div class="post-head">
                <h1 class="post-title"><a href="/custom-excerpts/">自定义文章摘要（Excerpt）</a></h1>
                <div class="post-meta">
                  <span class="author">作者：<a href="/author/wangsai/">王赛</a></span> &bull;
                  <time class="post-date" datetime="2017年8月9日星期三下午4点57分" title="2017年8月9日星期三下午4点57分">2017年8月9日</time>
                </div>
              </div>
              <div class="post-content">
                <p>
                  随着 Ghost 1.0 和 Hemingway Mode 的发布，今天我们又发布了“自定义文章摘要”功能。 默认情况下，Ghost 会截取文章正文开头部分的文字（一般是55个字）作为文章摘要并显示在文章归档列表中。摘要有助于读者快速了解文章所要表达的内容。但是，如果你希望自己定</p>
              </div>
              <div class="post-permalink">
                <a href="/custom-excerpts/" class="btn btn-default">阅读全文</a>
              </div>

              <footer class="post-footer clearfix">
                <div class="pull-left tag-list">
                  <i class="fa fa-folder-open-o"></i>

                </div>
                <div class="pull-right share">
                </div>
              </footer>
            </article>




          </main>
        </div>
      </div>
    </section>
  </main>

</template>


<script>

  import api from '../api'

  export default {
    data() {
      return {
        articles: []
      }
    },
    created () {
      this.getArticles()
    },
    methods: {
      async getArticles (){
        let data = await api.get("articles");
        this.articles = data;
      }
    }
  }
</script>


<style lang="stylus">
  @import "../stylus/article_post.styl";


</style>
