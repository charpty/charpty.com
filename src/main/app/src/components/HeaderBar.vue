<template>
<header v-scroll="scrollcallback">
  <div class="subheader-back" :class="{scrolled:scrolled}">
    <div class="subheader">
      <div class="subheader-partition left">
        <div class="subheader-cell"><i class="fa fa-phone"></i> <span>+86 15061883140</span></div>
        <div class="subheader-cell"><i class="fa fa-envelope"></i> <a href="mailto:domonji95@gmail.com">domonji95@gmail.com</a></div>
        <div class="subheader-cell"><i class="fa fa-lock"></i>
          <router-link to="/login">Login</router-link>
        </div>
        <div class="subheader-cell"><a class="selector" href="javascript:void(0)">English</a></div>
      </div>
      <div class="subheader-partition right">
        <div class="social-icon instagram">
          <a href="https://www.instagram.com/domonji95/" target="_blank"> <i class="fa fa-instagram fa-2" aria-hidden="true"></i> </a>
        </div>
        <div class="social-icon github">
          <a href="https://github.com/domonji" target="_blank"> <i class="fa fa-github fa-2" aria-hidden="true"></i> </a>
        </div>
      </div>
    </div>
  </div>
  <div class="header-back" :class="{scrolled:scrolled}">
    <div class="header">
      <router-link to="/">
        <div class="logo"></div>
      </router-link>
      <nav :class="[{'showup':menuShowUp},'navigator']" v-scroll="menuClickHandler">
        <router-link class="navigator-button" to="/" @click="menuShowUp=false">
          <div>Home</div>
        </router-link>
        <router-link class="navigator-button" to="/posts" @click="menuShowUp=false">
          <div>Blog</div>
        </router-link>
        <router-link class="navigator-button" to="/about" @click="menuShowUp=false">
          <div>About</div>
        </router-link>
        <router-link class="navigator-button" to="/photograph" @click="menuShowUp=false">
          <div>Photograph</div>
        </router-link> <span class="search"><i class="fa fa-search" aria-hidden="true"></i></span> <i class="fa fa-bars fa-2 nav-mobile" aria-hidden="true" @mouseover="inMenuArea=true" @mouseout="inMenuArea=false" v-click="menuClickHandler" v-show="!menuShowUp"></i>        </nav>
    </div>
  </div>
</header>
</template>

<script>
import eventDirective from '../directives/eventListener'
export default {
  data () {
    return {
      scrolled: false,
      inMenuArea: false,
      menuShowUp: false
    }
  },
  methods: {
    scrollcallback () {
      this.scrolled = window.scrollY > 60
    },
    menuClickHandler () {
      this.menuShowUp = this.inMenuArea
    }
  },
  directives: {
    scroll: eventDirective('scroll'),
    click: eventDirective('click')
  }
}
</script>

<style lang="stylus" scoped>
@import '../stylus/style.styl'

subheader_h = 36px
header_h = 120px

header
  position:fixed
  width:100%
  z-index:2

.subheader-back
  width:100%
  background:#f5f5f5
  transition:all .3s
  height:subheader_h
  @media (max-width:600px)
    display:none

.subheader-back.scrolled
  height:0
  overflow:hidden

.header-back
  width:100%
  background:white
  box-shadow:0 1px 1px rgba(0,0,0,.1)
  height:header_h
  transition:all .3s

.header-back.scrolled
  height: (header_h / 1.8)

.header
  fullWidth()
  line-height:header_h
  padding:0 20px
  transition:all .3s

.header-back.scrolled .header
  line-height:(header_h / 1.8)
  height:(header_h / 1.8)

.logo,.navigator
  display:inline-block

.nav-mobile
  font-size:24px
  cursor:pointer
  transition:all .3s
  &:hover
    color:#e95095
  @media (min-width:900px)
    display:none

.navigator
  float:right
  color:#666
  text-align:right
  a,span
    display:inline-block
    height:100%
    padding:0 20px
    @media (max-width:901px)
      text-align:left
      line-height:66px
      display:none
      potition:relative
      background:white
      box-shadow: 0 0px 2px rgba(0,0,0,0.1)
      border:solid 1px rgba(0,0,0,.05)
      transform:translateY(40%)
      animation:showup .3s reverse

@keyframes showup{
  from {
    height:0
    opacity:0
  }
  to {
    height:66px
    opacity:1
  }
}

.navigator.showup
  a,span
    @media (max-width:901px)
      display:block
      height:66px
      opacity:1
      animation:showup .3s ease

.navigator-button div
  display:inline-block
  position:relative
  &::after
    display:block
    content:''
    position:absolute
    left:0
    bottom:(50% - 20px)
    @media (max-width: 901px)
      bottom:(50% - 30px)
    margin:0 auto -2px
    height:2px
    width:100%
    opacity:0
    transition:all .3s
    background:#e95095

.navigator a:hover
  div
    &::after
      opacity:1
      bottom:(50% - 10px)
      @media (max-width: 901px)
        bottom:(50% - 20px)

.header-back.scrolled .navigator a:hover
  div
    &::after
      bottom:(50% - 18px)

.subheader
  fullWidth()
  color:#999
  line-height:subheader_h
  font:14px/1.5 fontawesome
  @media (max-width: 901px)
    font-size:11px
  display:flex
  align-items:center
  justify-content:space-between
  padding:0 20px

.subheader-partition
  display:flex
  width:auto
  justify-content:flex-start
  align-items:center

.right
  justify-content:flex-end
  align-items:center


.subheader-cell
  display:inline-block
  text-align:center
  margin:0 20px 0 0

a,.social-icon,.search
  transition:color .3s
  cursor:pointer

a:hover,.search:hover
    color:#e95095

a.selector
  position:relative
  &::after
    display:block
    position:absolute
    top:50%
    right:-1.4rem
    content:'\f107'
    font-size:1.4rem
    line-height:30px
    margin-top:-15px

.social-icon
  height:subheader_h
  width:@height
  font-size:1.5rem
  text-align:center
  background:transparent
  transition:all .5s
  a
    transition:all .3s
  &:hover
    a
      color:white

.logo
  background:url('../assets/monkov_logo.svg') no-repeat center /contain
  width:180px
  @media (max-width: 901px)
    width:120px
  height:header_h
  transition:all .3s

.scrolled .logo
  height:(header_h/1.8)


</style>
