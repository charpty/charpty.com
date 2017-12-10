<template>
  <main class="man-wrap">
    <div class="articles-table-wrap">
      <articles-table></articles-table>
    </div>
    <div class="right-misc-wrap">
      <right-misc></right-misc>
    </div>
  </main>
</template>

<script>
  import ArticleTable from './ArticlesTable'
  import RightMisc from './RightMisc'

  export default {
    components: {
      'articles-table': ArticleTable,
      'right-misc': RightMisc
    }
  }
</script>

<style lang="stylus">
  @import "../stylus/articles.styl"
</style>
