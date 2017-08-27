<template>
  <main>
    <!--<article-jumbotron></article-jumbotron>-->
    <!--<div>-->
      <!--<div class="articles-table-wrap">-->
        <!--<articles-table></articles-table>-->
      <!--</div>-->
      <!--<articles-recently></articles-recently>-->
      <!--<right-misc></right-misc>-->
    <!--</div>-->
  </main>
</template>


<script>
  import Jumbotron from './ArticleJumbotron'
  import ArticleTable from './ArticlesTable'
  import RightMisc from './RightMisc'

  export default {
    components: {
      'article-jumbotron': Jumbotron,
      'articles-table': ArticleTable,
      'right-misc': RightMisc
    }
  }

</script>

<style lang="css">
  .articles-table-wrap {
    float: left;
  }


</style>
