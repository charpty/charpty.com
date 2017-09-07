<template>
  <main>
    <div style="min-height: 800px">
      <textarea id="abcdefg"></textarea>
    </div>
  </main>

</template>

<script>

  import SimpleMDE from 'simpleMDE';
  import 'simplemde/dist/simplemde.min.css';
  import '../assets/css/font-awesome.min.css';
  import markdownParser from '../markdown'

  export default {
    mounted() {
      let mde = new SimpleMDE({
        element: document.getElementById("abcdefg"),
        autoDownloadFontAwesome: false,
        status: true,
        previewRender: function (plainText) {
          return markdownParser.parse(plainText);
        },
      });
    },
  }
</script>
