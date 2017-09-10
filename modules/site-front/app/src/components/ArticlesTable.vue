<template>
  <main>
    <section>
      <div class="container">
        <div class="row">
          <main class="col-md-8 main-content">
            <article v-for="(article,index) in articles" :key="index" class="post">
              <div class="post-head">
                <h1 class="post-title">
                  <span v-on:click="goArtileDetail(article.id)">{{ article.title }}</span>
                </h1>
                <div class="post-meta">
                  <i class="fa fa-user-circle" aria-hidden="true"></i>
                  <span v-on:click="goAboutAuthor(article.creator)" class="author">{{ article.creator }}</span>
                  &nbsp;|&nbsp;&nbsp;<i></i>
                  <i class="fa fa-calendar" aria-hidden="true"></i>
                  <time class="post-date" datetime="" title="">{{ article.creationDate.split(' ')[0] }}</time>
                </div>
              </div>
              <div class="featured-media" v-on:click="goArtileDetail(article.id)">
                <img v-if="article.coverImage" v-bind:src="article.coverImage" v-bind:alt="article.title" v-bind:title="article.title">
              </div>
              <div v-on:click="goArtileDetail(article.id)" class="post-content">
                <p>
                  {{ article.summary }}
                </p>
              </div>
              <div class="post-permalink" v-on:click="goArtileDetail(article.id)">
                <a class="btn btn-warning">阅读全文</a>
              </div>
              <footer class="post-footer clearfix">
                <div class="pull-left tag-list">
                  <span class="author">阅读量：<a href="#">{{ article.pinged < 0 ? '暂未统计' : article.pinged }}</a></span>
                  <span class="author">&nbsp;&nbsp; | &nbsp;&nbsp;喜欢：<a href="#">{{ article.praised < 0 ? '暂未统计' : article.praised }}</a></span>
                  <span class="bottom-right-misc1"> &nbsp;&nbsp; | &nbsp;&nbsp;分类：<a href="#">{{ article.groupName }}</a></span>
                  <span class="bottom-right-misc2">&nbsp;&nbsp; | &nbsp;&nbsp;评论数：<a href="#">{{ article.commentCount < 0 ? '暂未统计' : article.commentCount }}</a></span>
                </div>
                <div class="pull-right share">
                </div>
              </footer>
            </article>
            <nav class="pagination" role="navigation">
              <span class="page-number" v-if="this.currentPage && this.currentPage > 0" v-on:click="previousPage()">上一页</span>
              <span class="page-number">第 1 页 &frasl; 共 9 页</span>
              <span class="page-number" v-if="(this.everySize*(this.currentPage+1))<this.totalCount" v-on:click="nextPage()">下一页</span>
            </nav>
          </main>
        </div>
      </div>
    </section>
  </main>

</template>


<script>
  import api from '../api'
  import router from '../router'

  export default {
    data() {
      return {
        articles: [],
        currentPage: 0,
        totalCount: 0,
        everySize: 5
      }
    },
    created () {
      this.listArticles();
    },
    methods: {
      async listArticles (){
        this.countAricles();
        let data = await api.get("articles", {
          size: this.everySize,
          page: this.currentPage
        });
        this.articles = data;
      },
      async countAricles() {
        let tc = await api.get("articles/count");
        this.totalCount = tc;
      },
      nextPage: function () {
        this.currentPage++;
        this.listArticles();
      },
      previousPage: function () {
        this.currentPage--;
        this.listArticles();
      },
      goArtileDetail: function (articleId) {
        router.push({name: 'article', params: {articleId: articleId}});
      },
      goAboutAuthor: function (authorName) {
        router.push({name: 'author', params: {name: authorName}});
      }
    },
  }
</script>


<style lang="stylus">
  @import "../stylus/article_post.styl";
  @import "../stylus/pagination.styl";

  @media (max-width: 481px) {
    .bottom-right-misc1 {
      display: none;
    }

    .bottom-right-misc2 {
      display: none;
    }
  }

  @media (max-width: 641px) {
    .bottom-right-misc1 {
      display: none;
    }

    .col-md-8 {
      padding-right: 0px;
      padding-left 0px;
    }
  }

</style>
