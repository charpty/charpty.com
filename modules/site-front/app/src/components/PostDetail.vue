<template>
  <section class="article-list col-main">
    <article class="blog-post">
      <post-content v-if="post"
        :id="post.id"
        :title="post.title"
        :time="post.createTime"
        :imagesrc="post.imagesrc"
        :comments="post.comments"
        :content="post.content"
        :category="post.category"
        :tags="post.tags"
        detailmode=true>
      </post-content>
      <comments v-if="post" @newComment="fetchPostDetail" :comments="post.comments"></comments>
    </article>
  </section>
</template>

<script>
import PostContent from './PostContent'
import api from '../api'
import Comments from './Comments'
export default {
  data () {
    return {
      post: null
    }
  },
  components: {
    PostContent,
    Comments
  },
  methods: {
    async fetchPostDetail () {
      try {
        const res = await api.getPost(this.$route.params.title)
        if (res.success) this.post = res.data
      } catch (e) {
        console.log(e)
      }
    }
  },
  created () {
    this.fetchPostDetail()
  },
  watch: {
    '$route': 'fetchPostDetail'
  }
}
</script>
