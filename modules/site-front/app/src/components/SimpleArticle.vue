<template>
  <main class="simple-article">
    <div class="simple-container">
      <div class="simple-col">
        <div>
          <h2 class="simple-article-title">{{ article.title }}</h2>
          <i class="fa fa-user-circle" aria-hidden="true"></i>&nbsp;<span>{{ article.creator }}</span>&nbsp;&nbsp;
          <i class="fa fa-calendar" aria-hidden="true"></i>&nbsp;
          <span class="simple-meta">{{ article.creationDate }}</span>&nbsp;&nbsp;
          <div class="simple-article-content" v-html="this.mdHtml">
            <i></i>
          </div>
        </div>
      </div>
    </div>
  </main>
</template>

<script>
  import api from '../api'
  import router from '../router'
  import markdownParser from '../utils/markdown'

  export default {
    data() {
      return {
        article: {
          creator: "charpty",
          creationDate: "2017-01-01",
          wordCount: 0
        },
        mdHtml: ""
      }
    },
    created() {
      this.getSimpleArticle();
    },
    methods: {
      getSimpleArticle: async function () {
        this.article = await api.get("article/" + this.$route.params.articleName);
        this.mdHtml = markdownParser.parse(this.article.content);
        document.title = this.article.title;
      }
    }
  }

</script>

<style>
  @import "../stylus/animation.styl";
  @import "../stylus/front.styl";
  @import "../stylus/simple_article.styl";
</style>
