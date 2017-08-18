<template lang="html">
  <div class="widget-container">
    <h3>Categories</h3>
    <ul>
      <li v-for="cat in plainCats">
        <router-link :to="'/posts?category='+cat.name">{{cat.name}}</router-link>
        <span class="post-number">(3)</span>
        <ul v-if="cat.sub" v-for="sub in cat.sub">
            <li>
            <router-link :to="'/posts?category='+sub.name">{{sub.name}}</router-link>
            <span class="post-number">(1)</span>
            </li>
        </ul>
      </li>
    </ul>
  </div>
</template>

<script>
import api from '../../api'
export default {
  data () {
    return {
      categories: []
    }
  },
  computed: {
    plainCats () {
      let result = this.categories.slice()
      this.categories.forEach((cat, index, arr) => {
        if (cat.sub) {
          for (let sub in cat.sub) {
            result.splice(result.indexOf(sub))
          }
        }
      })
      return result
    }
  },
  created () {
    this.fetCategory()
  },
  methods: {
    async fetCategory () {
      try {
        const res = await api.getCategories()
        if (res.success) this.categories = res.data
      } catch (e) {
        console.log(e)
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
@import  '../../stylus/widget.styl'
</style>
