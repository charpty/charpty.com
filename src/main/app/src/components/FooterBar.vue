<template>
<footer class="footer">
  <div class="subfooter-top">
    <div class="subfooter-top-container">
      <footer-widget-about></footer-widget-about>
      <footer-widget-gallery></footer-widget-gallery>
      <footer-widget></footer-widget>
    </div>
  </div>
  <div class="subfooter-bottom">
    <div class="subfooter-bottom-container"> <span>
            Copyrights <i class="fa fa-copyright" aria-hidden="true"></i> 2016-2017 <router-link to="/">Domon ji</router-link>
            </span>
      <div class="menu-list"> <span>
                    <router-link to="/">Home</router-link>
                </span> <span>
                    <router-link to="/blog">Blog</router-link>
                </span> <span>
                    <router-link to="/about">About</router-link>
                </span> <span>
                    <router-link to="/photograph">Photograph</router-link>
                </span> </div>
    </div>
  </div>
</footer>
</template>
<script>
import FooterWidget from './footerwidgets/FooterWidget'
import FooterWidgetAbout from './footerwidgets/FooterWidgetAbout'
import FooterWidgetGallery from './footerwidgets/FooterWidgetGallery'
export default {
  components: {
    FooterWidget,
    FooterWidgetAbout,
    FooterWidgetGallery
  }
}
</script>
<style lang="stylus" scoped>
@import  '../stylus/style'
footer
    width:100%
    color:#666
    font:.7em/1.6 fontawesome
    a
        color:#999
        transition:color .3s
        &:hover
            color:#ddd

.subfooter-top
    width:100%
    padding:4em 0
    min-height:300px
    background:#1a1a1a

.subfooter-top-container
    fullWidth()
    padding:0 20px
    display:flex
    justify-content:space-between
    align-items:flex-start
    @media (max-width:901px)
        flex-flow:column

.subfooter-bottom
    height:38px
    background:#222
    line-height:@height

.subfooter-bottom-container
    fullWidth()
    padding:0 20px

.menu-list
    display:inline-block
    @media (max-width:601px)
        display:none
    float:right
    span
        margin:0 8px
</style>
