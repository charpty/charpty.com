<template>
  <main>
    <article class="post">
      <header class="post-head">
        <h1 class="post-title">{{ article.title }}</h1>
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
        console.log(this.$refs);
        console.log(this.$refs.ccccc);
      }
    }
  }
</script>

<style>
  @import "../stylus/article_post.styl";

  @media (max-width: 641px) {
    .post {
      padding: 35px;
      background: #fff;
      margin-bottom: 35px;
      position: relative;
      overflow: hidden;
    }

    .post-head {
      margin-top: 30px;
    }

    .post-title-article {
      display: inline-block;
      overflow: hidden;
      font-size: 5.1vw !important;
      font-family: Georgia, sans;
      font-weight: 700;
    }

  }

  .markdown-body {
    background: white;
    overflow: hidden;
    display: block;
  }

</style>
