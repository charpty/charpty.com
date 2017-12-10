<template>
  <main>
    <section>
      <div class="container">
        <div class="main-content">
          <article v-for="(article,index) in articles" :key="index" class="post">
            <div class="post-head">
              <h1 class="post-title">
                <span v-on:click="goArticleDetail(article.name)">{{ article.title }}</span>
              </h1>
              <div class="post-meta">
                <i class="fa fa-user-circle" aria-hidden="true"></i>
                <span v-on:click="goAboutAuthor()" class="author">{{ article.creator }}</span>
                &nbsp;|&nbsp;&nbsp;<i></i>
                <i class="fa fa-calendar" aria-hidden="true"></i>&nbsp;
                <time class="post-date" datetime="" title="">{{ article.creationDate.split(' ')[0] }}</time>
                &nbsp;|&nbsp;&nbsp;<i class="fa fa-file-word-o" aria-hidden="true"></i>
                <span>{{ article.wordCount < 0 ? '未统计' : article.wordCount }}</span>
              </div>
            </div>
            <div class="featured-media" v-on:click="goArticleDetail(article.name)">
              <img v-if="article.coverImage" v-bind:src="article.coverImage" v-bind:alt="article.title"
                   v-bind:title="article.title">
            </div>
            <div v-on:click="goArticleDetail(article.name)" class="post-content">
              <p v-html="parseSummary(article.summary)">
              </p>
            </div>
            <div class="post-permalink">
              <a v-on:click="goArticleDetail(article.name)" class="btn btn-warning">阅读全文</a>
            </div>
            <footer class="post-footer clearfix">
              <div class="pull-left tag-list">
                <span class="author">阅读量：<a href="#">{{ article.pinged < 0 ? '暂未统计' : article.pinged }}</a></span>
                <span class="author">&nbsp;&nbsp; | &nbsp;&nbsp;喜欢：<a
                  href="#">{{ article.praised < 0 ? '暂未统计' : article.praised }}</a></span>
                <span class="bottom-right-misc1"> &nbsp;&nbsp; | &nbsp;&nbsp;分类：<a href="#">{{ article.groupName
                  }}</a></span>
                <span class="bottom-right-misc2">&nbsp;&nbsp; | &nbsp;&nbsp;评论数：<a
                  href="#">{{ article.commentCount < 0 ? '暂未统计' : article.commentCount }}</a></span>
              </div>
              <div class="pull-right share">
              </div>
            </footer>
          </article>
          <nav class="paging" role="navigation">
              <span class="page-number" v-if="this.currentPage && this.currentPage > 0"
                    v-on:click="previousPage()">上一页</span>
            <span class="page-number">第 {{ currentPage + 1 }} 页 &frasl; 共 {{ Math.ceil(totalCount / everySize)
              }} 页</span>
            <span class="page-number" v-if="(this.everySize*(this.currentPage+1))<this.totalCount"
                  v-on:click="nextPage()">下一页</span>
          </nav>
        </div>
      </div>
    </section>
  </main>

</template>


<script>
  import api from '../api'
  import router from '../router'
  import markdownParser from '../utils/markdown'

  export default {
    data() {
      return {
        articles: [],
        currentPage: 0,
        totalCount: 0,
        everySize: 5
      }
    },
    created() {
      this.listArticles();
    },
    methods: {
      async listArticles() {
        this.countAricles();
        let start = 0;
        if (this.currentPage > 0) {
          start = (this.currentPage * this.everySize);
        }
        let data = await api.get("articles", {
          start: start,
          limit: this.everySize
        });
        this.articles = data;
        document.title = "charpty的文章列表";
      },
      async countAricles() {
        let tc = await api.get("articles/count");
        this.totalCount = tc;
      },
      nextPage: function () {
        this.currentPage++;
        this.listArticles();
        this.toTop();
      },
      previousPage: function () {
        this.currentPage--;
        this.listArticles();
        this.toTop();
      },
      goArticleDetail: function (articleName) {
        this.toTop();
        router.push({name: 'article', params: {articleName: articleName}});
      },
      goAboutAuthor: function () {
        router.push("/about/author");
      },
      parseSummary: function (summary) {
        if (summary && summary.length > 7) {
          return markdownParser.parse(summary);
        }
        return summary;
      },
      toTop: function () {
        if (document.body.animate) {
          document.body.animate({scrollTop: '0px'}, 200);
        }
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
      }
    }
  }
</script>


<style lang="stylus">
  @import "../stylus/common.styl"
  @import "../stylus/front.styl"
  @import "../stylus/articles.styl";
  @import "../stylus/pagination.styl";
</style>
