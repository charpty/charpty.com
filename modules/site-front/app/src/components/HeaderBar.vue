<template>
  <main>
    <header>
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
        <div class="phone-header">
          <div class="site-meta">
            <span class="custom-title">知足者常乐</span>
            <span class="custom-sub-title">{{ dailyWord }}</span>
          </div>
        </div>
        <div class="main-header">
          <div class="row">
            <div class="col-sm-12">
              <a class="hide" href="" title=""><img
                src="../assets/main_header.jpg" alt=""></a>
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
  }
  ;
</script>

<style>
  .site-meta {
    position: relative;
    text-align: center;
  }

  .phone-header {
    visibility: hidden;
    height: 110px;
    width: 100%;
    padding: 20px;
    background: #222;
  }

  .custom-title {
    opacity: 1;
    font-size: 20px;
    font-weight: 400;
    font-family: Lato, "PingFang SC", "Microsoft YaHei", sans-serif;
    color: white;
  }

  .custom-sub-title {
    display: block;
    opacity: 1;
    margin-top: 0px;
    font-size: 13px;
    color: white;
  }

  .active {
    border-bottom: 2px solid #e67e22;
    margin-bottom: -2px;
  }

  .navbar .nav, .navbar .nav > li {
    float: none;
    display: inline-block;
  }

  .navbar-toggle {
    top: 20px;
    left: 20px;
    position: absolute;
    background: 0 0;
    z-index: 1000;
  }

  @media (min-width: 768px) {
    .navbar-nav {
      width: 100%;
      text-align: center;
    }

    .navbar-nav > li {
      float: none;
      display: inline-block;
    }

    .navbar-nav > li.navbar-right {
      float: right !important;
    }
  }

  .main-header {
    background-image: url("../assets/main_header.jpg");
    height: 220px;
  }

  /* smartphones, iPhone, portrait 480x320 phones */
  @media (min-width: 320px) {
    .main-header {
      height: 150px;
    }
  }

  /* portrait e-readers (Nook/Kindle), smaller tablets @ 600 or @ 640 wide. */
  @media (min-width: 481px) {
    .main-header {
      height: 120px;
    }
  }

  /* portrait tablets, portrait iPad, landscape e-readers, landscape 800x480 or 854x480 phones */
  @media (max-width: 641px) {
    .navbar {
      margin-bottom: 3px;
    }

    .phone-header {
      visibility: visible;
    }

    .main-header {
      height: 0px;
      visibility: hidden;
    }
  }

  /* tablet, landscape iPad, lo-res laptops ands desktops */
  @media (min-width: 961px) {
  }

  /* big landscape tablets, laptops, and desktops */
  @media (min-width: 1025px) {
  }

  /* hi-res laptops and desktops */
  @media (min-width: 1281px) {
    .main-header {
      background-image: url("../assets/main_header.jpg");
      height: 220px;
    }
  }

</style>
