import marked from 'marked'
import hljs from 'highlight.js';
import 'highlight.js/styles/monokai-sublime.css';

hljs.configure({
  languages: ["Bash", "SQL", "C++", "Java", "JavaScript", "Markdown", "HTTP", "CSS",
    "Shell Session", "JSON", "Nginx", "Python", "HTML", "XML"]
});

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
