<template>
  <main>
    <header class="site-header">
      <nav class="navbar navbar-default" role="navigation">
        <div class="container">
          <button type="button" id="button-navbar-toggle" class="navbar-toggle" data-toggle="collapse"
                  data-target="#site-navbar-collapse">
            <span class="sr-only">切换导航</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
        </div>
        <div class="headband"></div>
        <div class="phone-header">
          <div class="site-meta" v-on:click="panelClick($event)">
            <span v-on:click="tryGoHomePage()" class="custom-title">知足者常乐</span>
            <span v-on:click="getDailyWord()" class="custom-sub-title">{{ dailyWord }}</span>
          </div>
        </div>
        <div class="main-header">
          <div class="row">
            <div class="col-sm-12">
              <a class="hide" href="" title=""><img src="../assets/main_header.jpg" alt=""></a>
              <h2 class="text-hide"></h2>
              <img src="../assets/main_header.jpg" alt="" class="hide">
            </div>
          </div>
        </div>
        <div class="collapse navbar-collapse" id="site-navbar-collapse" v-on:click="barClick()">
          <ul class="nav navbar-nav">
            <li role="presentation" v-on:click="goRoute('/articles')">
              <a aria-controls="profile" role="tab" data-toggle="tab">
                文章列表
              </a></li>
            <li role="presentation" v-on:click="goRoute('/y2017')">
              <a aria-controls="profile" role="tab" data-toggle="tab">
                2017年
              </a></li>
            <li role="presentation" v-on:click="unsupport()">
              <a aria-disabled="true">
                J2EE设计
              </a></li>
            <li role="presentation" v-on:click="unsupport()">
              <a aria-disabled="true">
                结构与存储
              </a></li>
            <li role="presentation" v-on:click="goRoute('/about/site')">
              <a aria-controls="profile" role="tab" data-toggle="tab">关于本站</a></li>
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

      unsupport: function () {
        console.log("unsupport");
      },
      barClick: function () {
        if ($(window).width() <= 641) {
          $('#button-navbar-toggle').click();
        }
      },
      panelClick: function (event) {
        if (event.target.className == 'site-meta') {
          $('#button-navbar-toggle').click();
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
