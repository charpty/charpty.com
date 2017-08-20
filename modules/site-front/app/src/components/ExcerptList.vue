<template>
  <section class="article-list col-main">
    <article class="blog-post">
      <post-content v-for="post in postList"
                    :key="post._id"
                    :id="post._id"
                    :imagesrc="post.imagesrc"
                    :title="post.title"
                    :time="post.createTime"
                    :tags="post.tags"
                    :comments="post.comments"
                    :content="post.excerpt"
                    :category="post.category">
      </post-content>
    </article>
    <nav class="pagination">
      <a href="javascript:void(0)" @click="toPage(currentPage-1)" class="page-numbers next-page" v-show="currentPage > 1">&lt;</a>
      <a href="javascript:void(0)" @click="toPage(n)" v-for="n in totalPage" :class="[{'current-page':n==currentPage},'page-numbers']">{{n}}</a>
      <a href="javascript:void(0)" @click="toPage(currentPage+1)" class="page-numbers next-page" v-show="currentPage < totalPage">&gt;</a>
    </nav>
  </section>
</template>

<script>
  import PostContent from './PostContent'
  import api from '../api'
  export default {
    components: {
      PostContent
    },
    props: {
      postLimit: {
        type: Number,
        default: 10
      }
    },
    data () {
      return {
        postList: [],
        totalPage: 2,
        currentPage: ~~this.$route.query.page || 1
      }
    },
    created () {
      this.fetchPostList()
    },
    methods: {
      async fetchPostList () {
        try {
          const res = await api.getPostList({
            page: this.currentPage,
            limit: this.postLimit,
            tag: this.$route.query.tag || '',
            category: this.$route.query.category || ''
          })
          if (res.success) {
            this.postList = res.data.postArr
            this.totalPage = Math.ceil(res.data.totalNumber / this.postLimit)
          }
        } catch (e) {
          console.log(e)
        }
      },
      toPage (n) {
        this.$router.push({
          path: 'posts',
          query: {
            page: n,
            limit: this.postLimit,
            tag: this.$route.query.tag,
            category: this.$route.query.category
          }
        })
        this.currentPage = n
      }
    },
    watch: {
      '$route': 'fetchPostList'
    }
  }
</script>

<style lang="stylus">
  .pagination
    .page-numbers
      background: white
      color: #666
      display: inline-block
      vertical-align: top
      text-align: center
      font-size: 17px
      line-height: 50px
      height: 50px
      width: 50px
      margin: 3px
      position: relative
      overflow: hidden
      z-index: 1
      border-radius: 50%
      box-shadow: 0 0 0 2px #e8e8e8 inset
      transition: all .3s
      &::before
        display: block
        content: ''
        position: absolute
        background: #e95095
        top: 0
        left: 0
        height: 0
        width: 100%
        transition: height 0.3s
        z-index: -1
      &:hover
        color: white
        &::before
          height: 100%

    .current-page
      color: white
      background: #e95095
      box-shadow: none
</style>
