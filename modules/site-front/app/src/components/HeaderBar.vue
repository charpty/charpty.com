<template>
  <main>
    <header class="site-header">
      <nav class="navbar navbar-default" role="navigation">
        <div class="container-fluid">
          <button type="button" class="navbar-toggle" data-toggle="collapse"
                  data-target="#site-navbar-collapse">
            <span class="sr-only">切换导航</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
        </div>
        <div class="headband"></div>
        <div class="phone-header" v-on:click="getDailyWord()">
          <div class="site-meta">
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
        <div class="collapse navbar-collapse" style="float: none" id="site-navbar-collapse">
          <ul class="nav navbar-nav">
            <li role="presentation" v-on:click="goRoute('/articles')">
              <a aria-controls="profile" role="tab" data-toggle="tab">
                文章列表
              </a></li>
            <li role="presentation" v-on:click="goRoute('/y2017')">
              <a aria-controls="profile" role="tab" data-toggle="tab">
                2017年
              </a></li>
            <li role="presentation"><a aria-controls="profile" role="tab" data-toggle="tab">J2EE设计</a></li>
            <li role="presentation"><a aria-controls="profile" role="tab" data-toggle="tab">结构与存储</a></li>
            <li class="dropdown" aria-controls="profile" role="tab" data-toggle="tab">
              <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                关于我<b class="caret"></b>
              </a>
              <ul class="dropdown-menu">
                <li><a href="#">笔者简介</a></li>
              </ul>
            </li>
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
    data(){
      return {
        dailyWord: "成功=目标，其他语句都是这行代码的注释",
        titleClickCount: 0
      }
    },
    created() {
      this.getDailyWord();
    },
    methods: {
      tryGoHomePage: function () {
        if ((this.titleClickCount++) % 2 === 1) {
          window.location.href = "/";
        } else {
          this.getDailyWord();
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
