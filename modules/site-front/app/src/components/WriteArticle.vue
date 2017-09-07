<template>
  <main>
    <div style="min-height: 800px">
      <textarea id="write-editor"></textarea>
    </div>
  </main>

</template>

<script>

  import mde from '../utils/mde'

  export default {
    mounted() {
      mde.createMDE(document.getElementById("write-editor"));
    },
  }
</script>
