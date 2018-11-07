<template>
  <main>
    <article class="post">
      <header class="post-head">
        <h1 class="post-title">{{ article.title }}</h1>
        <section class="post-meta">
          <i class="fa fa-user-circle" aria-hidden="true"></i>
          <span v-on:click="goAboutAuthor()" class="author">{{ article.creator }}</span>
          &nbsp;|&nbsp;&nbsp;<i class="fa fa-calendar" aria-hidden="true"></i>&nbsp;
          <time class="post-date" datetime="" title="">{{ article.creationDate ? article.creationDate.split(' ')[0] : ""
            }}
          </time>
          &nbsp;|&nbsp;&nbsp;<i class="fa fa-file-word-o" aria-hidden="true"></i>
          <span>{{ article.wordCount }}</span>
        </section>
      </header>
      <section>
        <div class="markdown-body" v-html="this.mdHtml">
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
        article: {
          creator: "charpty",
          creationDate: "2017-01-01",
          wordCount: 0
        },
        mdHtml: ""
      }
    },
    created() {
      this.getArticleDetail();
    },
    methods: {
      getArticleDetail: async function () {
        let data = await api.get("article/brief/" + this.$route.params.articleName);
        this.article = data;
        this.mdHtml = this.turnMarkdown2Html(data.content);
        document.title = data.title;
        var self = this;
        setTimeout(() => {
          api.get("article/" + this.$route.params.articleName).then(function (detail) {
            self.mdHtml = self.turnMarkdown2Html(detail.content);
          });
        }, 1024);

      },
      turnMarkdown2Html: function (content) {
        return markdownParser.parse(content);
      },
      goAboutAuthor() {
        router.push("about/author")
      }
    }
  }
</script>

<style lang="stylus">
  @import "../stylus/animation.styl";
  @import "../stylus/front.styl";
  @import "../stylus/articles.styl";
</style>
