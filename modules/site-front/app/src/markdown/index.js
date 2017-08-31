import Vue from 'vue'
import marked from 'marked'
import hljs from 'highlight.js';
import 'highlight.js/styles/monokai-sublime.css';

marked.setOptions({
  renderer: new marked.Renderer(),
  gfm: true,
  tables: true,
  breaks: false,
  pedantic: false,
  sanitize: false,
  smartLists: true,
  smartypants: true,
  highlight: function (code) {
    return hljs.highlightAuto(code).value;
  }
})

export default str => marked(str)
