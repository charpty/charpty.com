import markdownParser from '../markdown';
import SimpleMDE from 'simplemde';
import 'simplemde/dist/simplemde.min.css';
import '../../assets/css/font-awesome.min.css';


export default {
  /**
   * 创建一个markdown Editor
   *
   * @param render 编辑要渲染的元素位置
   * @returns {*}
   */
  createMDE: function (render) {
    let mde = new SimpleMDE({
      element: render,
      autofocus: true,
      autoDownloadFontAwesome: false,
      status: ["autosave", "lines", "words", "cursor"],
      toolbar: ["bold", "italic", "heading", "strikethrough", "|", "quote", "unordered-list", "ordered-list", "|",
        "horizontal-rule", "table", "|", "link", "image", "code", "|", "preview", 'side-by-side', "fullscreen"],
      previewRender: function (text) {
        return markdownParser.parse(text);
      },
    });
    return mde;
  }

}
