<template>
  <main>
    <section>
      <div>
        <article v-for="(article,index) in articles" :key="index" class="post">
          <div class="post-head">
            <h1 class="post-title">
              <span v-on:click="goArticleDetail(article.name)">{{ article.title }}</span>
            </h1>
            <div class="post-meta">
              <i class="fa fa-user-circle" aria-hidden="true"></i>
              <span v-on:click="goAboutAuthor()" class="author">{{ article.creator }}</span>
              |&nbsp;&nbsp;<i class="fa fa-calendar" aria-hidden="true"></i>&nbsp;
              <time class="post-date" datetime="" title="">{{ article.creationDate.split(' ')[0] }}</time>
              |&nbsp;&nbsp;<i class="fa fa-file-word-o" aria-hidden="true"></i>
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
          <footer class="post-footer">
            <div class="tag-list">
              阅读量：
              <span>{{ article.pinged }}</span>
              &nbsp;&nbsp; | &nbsp;&nbsp;
              分类：
              <span class="like-href" v-on:click="resetArticles(article.groupName)">{{ article.groupName }}</span>
              <span>
              &nbsp;&nbsp; | &nbsp;&nbsp;
                  喜欢：<i v-on:click="likeArticle(article)" class="fa fa-heart" aria-hidden="true"></i>
                  {{ article.praised }}
              </span>
              <span class="bottom-right-misc2">
              &nbsp;&nbsp; | &nbsp;&nbsp;
                  评论数：{{ article.commentCount < 0 ? '暂未统计' : article.commentCount }}</span>
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
        everySize: 5,
        groupName: undefined
      }
    },
    created() {
      this.listArticles();

      this.$root.$on('table-update', () => {
        this.resetArticles();
      })
    },
    methods: {
      async resetArticles(groupName) {
        this.groupName = groupName;
        this.currentPage = 0;
        this.listArticles();
        this.toTop();
      },
      async listArticles() {
        let params = {}
        if (this.groupName) {
          params = {"groupName": this.groupName}
          document.title = "分类列表-" + this.groupName;
        } else {
          document.title = "charpty的文章列表";
        }
        this.countArticles(params);
        let start = 0;
        if (this.currentPage > 0) {
          start = (this.currentPage * this.everySize);
        }
        params.start = start;
        params.limit = this.everySize;
        let data = await api.get("articles", params);
        this.articles = data;
      },
      async countArticles(params) {
        this.totalCount = await api.get("articles/count", params);
      },
      async likeArticle(article) {
        article.praised++;
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
        router.push("about/author");
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
