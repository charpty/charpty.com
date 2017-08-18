<template lang="html">
  <div class="footer-widget">
      <h4>Gallery</h4>
      <div class="photos-container">
        <router-link class="photo-item" to="/"></router-link>
        <router-link class="photo-item" to="/"></router-link>
        <router-link class="photo-item" to="/"></router-link>
        <router-link class="photo-item" to="/"></router-link>
        <router-link class="photo-item" to="/"></router-link>
        <router-link class="photo-item" to="/"></router-link>
      </div>
  </div>
</template>

<script>
export default {}
</script>

<style lang="stylus" scoped>
@import  '../../stylus/widget.styl'
.photos-container
    margin:15px -1px

.photo-item
    display:inline-block
    margin:0
    padding:30% 0 0 0
    background:url('../../assets/img-1-1024x768.jpg') no-repeat center / cover
    width:30%
    height:30px
</style>
