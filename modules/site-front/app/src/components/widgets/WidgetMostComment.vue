<template lang="html">
  <div class="widget-container">
    <h3>Most Comments</h3>
    <ul>
      <li>
        <router-link to="/">This is an example post</router-link>
        <span class="post-date">November 21,2016</span>
      </li>
       <li>
        <router-link to="/">This is an example post,This is an example post,This is an example post</router-link>
        <span class="post-date">November 21,2016</span>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  data () {
    return {}
  }
}
</script>

<style lang="stylus" scoped>
@import  '../../stylus/widget.styl'
</style>
