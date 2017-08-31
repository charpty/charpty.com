<template>
  <main>
    <div class="markdown-body" v-if="this.showContent" v-html="this.mdHtml">
    </div>
  </main>
</template>

<script>
  import api from '../api'
  import router from '../router'
  import marked from '../markdown'

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
        this.mdHtml = this.turnMarkdown2Html(data.content);
      },

      turnMarkdown2Html: function (content) {
        return marked(content);
      }
    }

  }
</script>

<style>

  .markdown-body {
    background: white;
    overflow: hidden;
    display: block;
  }

</style>
