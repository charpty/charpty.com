<template>
  <main>
    <div class="markdown-body" v-if="this.showContent" v-html="this.mdHtml"></div>

  </main>
</template>

<script>
  import api from '../api'
  import router from '../router'
  import markdownDirective from '../markdown'
  import marked from 'marked'

  export default {
    data() {
      return {
        article: {},
        showContent: true,
        mdHtml: ""
      }
    },
    created() {
      this.getArticleDetail();
    },
    methods: {
      getArticleDetail: async function () {
        let data = await api.get("/article/" + this.$route.params.articleId);
        this.article = data;
        alert(1);
        alert(JSON.stringify(data));
        this.mdHtml = this.turnMarkdown2Html(data.content);
      },

      turnMarkdown2Html: function (content) {
        alert(content);
        return marked(content);
      },
      test: function ([status, statusText, data]) {
        alert("fuc:" + data);
      }

    },
    directives: {
      md: markdownDirective
    }
  }
</script>

<style>

  .markdown-body {
    color: #444;
    font-size: .9rem;
    margin: 12px 0;
    padding: 12px 0;
  }
</style>
