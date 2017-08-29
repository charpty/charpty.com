<template>
  <main>
    <section class="content-wrap">
      <div class="container">
        <div class="row">
          <main class="col-md-8 main-content">

            <article v-for="(article,index) in articles" :key="index" class="post">
              <div class="post-head">
                <h1 class="post-title">
                  <span v-on:click="goArtileDetail(article.id)">{{ article.title }}</span>
                </h1>
                <div class="post-meta">
                  <span v-on:click="goAboutAuthor(article.creator)" class="author">作者：{{ article.creator }}</span> &bull;
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
          </main>
        </div>
      </div>
    </section>
    <nav class="pagination" role="navigation">
      <span class="page-number" v-if="this.currentPage && this.currentPage > 0" v-on:click="previousPage()">上一页</span>
      <span class="page-number">第 1 页 &frasl; 共 9 页</span>
      <span class="page-number" v-if="(this.everySize*(this.currentPage+1))<this.totalCount" v-on:click="nextPage()">下一页</span>
    </nav>
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
      this.countAricles();
      this.listArticles();
    },
    methods: {
      async listArticles (){
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
        router.push({name: 'article', params: {id: articleId}});
      },
      goAboutAuthor: function (authorName) {
        router.push({name: 'author', params: {name: authorName}});
      }
    }
  }
</script>


<style lang="stylus">
  @import "../stylus/article_post.styl";

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
  }

  .pagination {
    margin: 0 0 35px;
    text-align: center;
    display: block;
  }

  .pagination a {
    text-align: center;
    display: inline-block;
    color: #ffffff;
    background: #e67e22;
    border-radius: 2px;
  }

  .pagination a a:hover {
    background: #505050;
    text-decoration: none;
    color: #ffffff;
  }

  .pagination a i {
    width: 36px;
    height: 36px;
    line-height: 36px;
  }

  .pagination .page-number {
    background: #e67e22;
    color: #ffffff;
    margin: 0 3px;
    display: inline-block;
    line-height: 36px;
    padding: 0 14px;
    border-radius: 2px;
  }

  .fa {
    display: inline-block;
    font: normal normal normal 14px / 1 FontAwesome;
    font-size: inherit;
    text-rendering: auto;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    transform: translate(0, 0)
  }

  .fa-lg {
    font-size: 1.33333333em;
    line-height: .75em;
    vertical-align: -15%
  }

</style>
