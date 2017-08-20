<template>
  <main>
    <div class="jumbotron">
      <div class="container">
        <h1 v-if="articles.length>0">{{ articles[0].title }}</h1>
        <p v-if="articles.length>0">
          {{ articles[0].summary }}
        <p><a class="btn btn-primary btn-lg" href="#" role="button">阅读全文 &raquo;</a></p>
      </div>
    </div>

    <div class="container">
      <div class="row">
        <div v-for="(article,index) in articles" :key="index" v-if="index!=0" class="col-md-4">
          <h2>{{ article.title }}</h2>
          <p>{{ article.summary }}</p>
          <p><a class="btn btn-default" href="#" role="button">阅读更多 &raquo;</a></p>
          <br>
        </div>
      </div>
    </div>
    <hr>
  </main>
</template>

<script>

  import api from '../api'

  export default {
    data() {
      return {
        articles: []
      }
    },
    created () {
      this.getArticles()
    },
    methods: {
      async getArticles (){
        let data = await api.get("articles");
        this.articles = data;
      }
    }
  }
</script>
