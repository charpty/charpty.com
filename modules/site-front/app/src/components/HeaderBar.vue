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
            <li class="active"><a>
              <router-link to="/articles">文章列表</router-link>
            </a></li>
            <li><a>
              <router-link to="/y2017">2017年</router-link>
            </a></li>
            <li><a href="#">结构与存储</a></li>
            <li><a href="#">J2EE设计</a></li>
            <li><a href="#">心得随记</a></li>
            <li class="dropdown">
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
  export default {};
</script>

<style>
  .navbar .nav, .navbar .nav > li {
    float: none;
    display: inline-block;
  }

  .navbar-toggle {
    top: 30px;
    left: 20px;
    position: absolute;
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
      background-image: url("../assets/main_header.jpg");
      height: 150px;
    }
  }

  /* portrait e-readers (Nook/Kindle), smaller tablets @ 600 or @ 640 wide. */
  @media (min-width: 481px) {
    .main-header {
      background-image: url("../assets/main_header.jpg");
      height: 120px;
    }
  }

  /* portrait tablets, portrait iPad, landscape e-readers, landscape 800x480 or 854x480 phones */
  @media (min-width: 641px) {

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
