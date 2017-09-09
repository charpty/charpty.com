<template>
  <main>
    <article class="post">
      <header class="post-head">
        <span class="post-title">{{ article.title }}</span>
        <section class="post-meta">
          <span v-on:click="goAboutAuthor(article.creator)" class="author">作者：{{ article.creator }}</span> &bull;
          <time class="post-date" datetime="" title="">{{ article.creationDate ? article.creationDate.split(' ')[0] : "" }}</time>
        </section>
      </header>
      <br><br>
      <section>
        <div class="markdown-body" v-if="this.showContent" v-html="this.mdHtml">
        </div>
      </section>
    </article>
  </main>
</template>

<script>
  import api from '../api'
  import router from '../router'
  import markdownParser from '../utils/markdown'

  export default {
    data() {
      return {
        article: {},
        showContent: true,
        mdHtml: "",
        articleId: -1
      }
    },
    created() {
      this.getArticleDetail();
    },
    methods: {
      getArticleDetail: async function () {
        let data = await api.get("/article/" + this.$route.params.articleId);
        this.article = data;
        this.mdHtml = this.turnMarkdown2Html(data.content);
      },

      turnMarkdown2Html: function (content) {
        return markdownParser.parse(content);
      }
    },
    watch: {
      'article.title': function (t) {
        console.log(t);
      }
    }
  }
</script>

<style>
  @import "../stylus/article_post.styl";

  @media (max-width: 641px) {
    .post {
      padding: 25px;
      background: #fff;
      margin-bottom: 35px;
      position: relative;
      overflow: hidden;
    }

    .post-head {
      margin-top: 30px;
    }

    .post-title {
      display: inline-block;
      overflow: hidden;
      /*font-size: 50px;*/
      /*font-size: 5vw !important;*/
    }

  }

  .markdown-body {
    background: white;
    overflow: hidden;
    display: block;
  }

</style>
