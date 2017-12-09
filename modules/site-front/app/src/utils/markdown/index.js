import marked from 'marked'
import hljs from '../highlight'

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

export default {
  // 解析markdown文本
  parse(text) {
    return marked(text);
  }
}
