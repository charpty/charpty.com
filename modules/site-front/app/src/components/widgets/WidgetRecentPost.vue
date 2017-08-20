<template lang="html">
  <div class="widget-container">
    <h3>Recent Post</h3>
    <ul>
      <li v-for="rp in rencentPost">
        <router-link :to="'/posts/'+rp.title">{{rp.title}}</router-link>
        <span class="post-date">{{rp.createTime}}</span>
      </li>
       <!-- <li>
        <router-link to="/">This is an example post,This is an example post,This is an example post</router-link>
        <span class="post-date">November 21,2016</span>
      </li> -->
    </ul>
  </div>
</template>

<script>
import api from '../../api'
export default {
  data () {
    return {
      rencentPost: []
    }
  },
  methods: {
    async fetchRecentPost () {
      try {
        const res = await api.getPostList({
          page: 1,
          limit: 5
        })
        if (res.success) this.rencentPost = res.data.postArr
      } catch (e) {
        console.log(e)
      }
    }
  },
  created () {
    this.fetchRecentPost()
  }
}
</script>

<style lang="stylus" scoped>
@import  '../../stylus/widget.styl'
</style>
