<template lang="html">
  <div class="widget-container">
    <h3>Tags</h3>
    <div class="tagcloud">
        <router-link v-for="(tag, index) in tags" :key="index" :to="'/posts?tag='+tag.name" :style="{fontSize: '23px'}">{{tag.name}} </router-link>
    </div>
  </div>
</template>

<script>
import api from '../../api'
export default {
  data () {
    return {
      tags: []
    }
  },
  methods: {
    async fetchTags () {
      try {
        const res = await api.getAllTags()
        if (res.success) this.tags = res.data
      } catch (e) {
        console.log(e)
      }
    }
  },
  created () {
    this.fetchTags()
  }
}
</script>

<style lang="stylus" scoped>
@import  '../../stylus/widget.styl'

.tagcloud
    margin:16px 0
    a
        color:#999
</style>
