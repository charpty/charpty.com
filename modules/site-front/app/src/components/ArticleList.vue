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

<style lang="css">

  .articles-table-wrap {
    float: left;
    width: 70%;
  }

  .right-misc-wrap {
    float: right;
    width: 30%;
  }

  @media (max-width: 981px) {
    .right-misc-wrap {
      visibility: hidden;
      height: 0px;
    }

    .articles-table-wrap {
      width: 100%;
    }
  }

  .man-wrap {
    align: center;
    overflow: hidden;
  }

  @media (min-width: 1281px) {
    .man-wrap {
      align: center;
      margin-left: 100px;
      margin-right: 100px;
      overflow: hidden;
    }
  }

</style>
