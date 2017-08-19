<template lang="html">

<ul id="example-2">
  <li v-for="(item, index) in items">
    {{ index }} - {{ item.message }}
  </li>
</ul>
</template>

<script>


export default {
  data () {
    return {
        items:[

        ]
    }
  }

}
</script>

