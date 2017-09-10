<template>
  <main>
    <header class="site-header">
      <nav class="navbar navbar-default" role="navigation">
        <div class="container-fluid">
          <button type="button" class="navbar-toggle" data-toggle="collapse"
                  data-target="#example-navbar-collapse">
            <span class="sr-only">切换导航</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
        </div>
        <div class="headband"></div>
        <div class="phone-header">
          <div class="site-meta">
            <span class="custom-title">知足者常乐</span>
            <span class="custom-sub-title">{{ dailyWord }}</span>
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
        <div class="collapse navbar-collapse" style="float: none" id="example-navbar-collapse">
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

  export default {
    data(){
      return {
        dailyWord: "面对困难不要放弃，别人会比你更艰难"
      }
    },
    create() {
    },
    methods: {
      goRoute: function (path) {
        router.push(path);
      }
    }
  };
</script>

<style>
  @import "../stylus/header.styl";
</style>
