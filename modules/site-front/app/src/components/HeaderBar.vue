<template>
  <main>
    <header class="site-header">
      <nav class="navbar">
        <button type="button" id="button-navbar-toggle"
                class="navbar-toggle" v-on:click="navbarToggle()">
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <div class="phone-header">
          <div class="site-meta" v-on:click="panelClick($event)">
            <span v-on:click="tryGoHomePage()" class="custom-title">知足者常乐</span>
            <span v-on:click="getDailyWord()" class="custom-sub-title">{{ dailyWord }}</span>
          </div>
        </div>
        <div class="main-header">
        </div>
        <div class="navbar-collapse" id="site-navbar-collapse" v-on:click="barClick()">
          <ul class="nav navbar-nav">
            <li v-on:click="goRoute('/articles')">
              <a>文章列表</a></li>
            <li v-on:click="goRoute('/y2017')">
              <a>2017年</a></li>
            <li>
              <a>J2EE设计</a></li>
            <li>
              <a>结构与存储</a></li>
            <li v-on:click="goRoute('/about/site')">
              <a>关于本站</a></li>
          </ul>
        </div>
      </nav>
    </header>
  </main>
</template>

<script>
  import router from '../router';
  import api from '../api';

  export default {
    data() {
      return {
        dailyWord: "成功=目标，其他语句都是这行代码的注释",
        titleClickCount: 0,
        panelClickCount: 1
      }
    },
    created() {
      this.getDailyWord();
    },
    methods: {
      navbarToggle: function () {
        var nav = document.getElementById("site-navbar-collapse");
        if (nav.style.visibility && nav.style.visibility == "visible") {
          nav.style.visibility = "hidden"
          nav.style.height = "0";
        } else {
          nav.style.visibility = "visible"
          nav.style.height = "auto";
        }
      },
      barClick: function () {
        if (window.width <= 641) {
          document.getElementById('button-navbar-toggle').click();
        }
      },
      panelClick: function (event) {
        if (event.target.className == 'site-meta') {
          document.getElementById('button-navbar-toggle').click();
        }
        if ((this.panelClickCount++) % 3 === 1) {
          this.getDailyWord();
        }
      },
      tryGoHomePage: function () {
        if (this.$route && this.$route.name == 'articleList') {
          window.location.href = "/";
        } else {
          router.push('/');
        }
      },
      goRoute: function (path) {
        if (path === "/articles") {
          this.$root.$emit("table-update");
        }
        router.push(path);
      },
      async getDailyWord() {
        let r = await api.get("word/random");
        if (r && r.length > 4) {
          this.dailyWord = r;
        }
      }
    }
  };
</script>

<style>
  @import "../stylus/header.styl";
</style>
