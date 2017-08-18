<template>
<div class="comments-list-container" id="comments">
  <h4 class="title"><span>{{comments.length || 0}} comments</span></h4>
  <div class="comments-list">
    <div class="comments-item" v-for="comment in comments">
      <div class="comments-item-meta">
        <img v-if="comment.userAvator" class="avator" :src="comment.userAvator" alt="">
        <div class="author">{{comment.user}}</div>
        <div class="date">{{comment.createTime}}</div>
      </div>
      <div class="comments-item-text markdown-body" v-html="comment.content"></div>
    </div>
  </div>
  <div class="comments-item-reply">
    <textarea id="editor" style="opacity:0"></textarea>
    <span class="username comment-meta-input">
        Username: <input v-model="username" type="text">
    </span>
    <span class="email comment-meta-input">
        Email: <input v-model="email" type="text">
    </span>
    <span id="post-comment" @click="submitComment()">Comment</span>
  </div>
</div>
</template>

<script>
import api from '../api'
import utils from '../utils'
import md2html from '../markdown'
let smde
export default {
  props: {
    comments: {
      type: Array,
      default: () => []
    }
  },
  date() {
    return {
      username: '',
      email: ''
    }
  },
  mounted() {
    smde = new SimpleMDE({
      placeholder: 'Please type your comment here...\n\nMarkdown supported.',
      autoDownloadFontAwesome: false,
      element: document.getElementById('editor'),
      spellChecker: false,
      toolbar: []
    })
    smde.codemirror
  },
  methods: {
    async submitComment() {
      if (!utils.trim(md2html(smde.value()))) {
        return
      }
      await api.postComment({
        content: md2html(smde.value()),
        user: this.username || 'anonymous',
        email: this.email,
        postTitle: this.$route.params.title
      })
      smde.value('')
      this.$emit('newComment')
    }
  }
}
</script>

<style lang="stylus" scoped>
.title
  color #444
  font-size 24px
  &:before
    display inline-block
    vertical-align top
    content '\f086'
    font-family fontawesome
    margin-right .8rem
    opacity .33
  border-top 1px solid #eee
  padding 2rem 0
.comments-list-container
  margin 4em 0
  overflow hidden

.comments-list
  margin 2em 0

.comments-item-reply
  margin 2em 0
  padding 2em 1em

.comments-item
  padding 0 0 2rem 0
  margin-bottom 2rem
  position relative
  border-bottom 1px solid #eee

.comments-item-meta
  margin-bottom 1rem
  margin-left calc(50px + 1.3rem)
  div
    display inline-block
  .author
    margin-right 1rem
    font-weight 600
    color:#666
  .date
    opacity .5

.comments-item-text
  margin-left calc(50px + 1.3rem)
  color #666
  font-weight 400

.avator
  position absolute
  width 50px
  border-radius 50%
  overflow hidden
  top 2rem
  left 0

#post-comment
  cursor pointer
  display:inline-block
  margin:25px 0 0 0
  color:#666
  font-weight:800
  font-family:Verdana
  font-size:15px
  line-height:2
  padding:0 1.8em
  letter-spacing:0
  text-transform: uppercase
  box-shadow: 0 0 0 2px #e8e8e8
  border-radius: 0.3em
  position:relative
  overflow:hidden
  border:none
  float right
  &::before
      display: block;
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 0;
      background-color: rgba(0,0,0,.1);
      transition: height 0.3s;
  &:hover
    &::before
      height 42px

.comment-meta-input
  color #666
  font-size 18px
  padding 0 1.6em 0 0
  line-height 4.5

.CodeMirror-scroll
  min-height 100px
  height 100px
</style>
