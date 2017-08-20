<template>
  <header>
    <nav class="navbar navbar-inverse navbar-static-top" role="navigation">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse"
                  data-target="#example-navbar-collapse">
            <span class="sr-only">切换导航</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">
            <img src="../assets/header_logo.png" class="header-logo"/>
          </a>
          <a class="navbar-brand" href="#">知足者常乐</a>
        </div>
        <div class="collapse navbar-collapse" id="example-navbar-collapse">
          <ul class="nav navbar-nav">
            <li class="active"><a href="#">文章列表</a></li>
            <li><a href="#">2017年</a></li>
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
      </div>
    </nav>
  </header>
</template>

<script>
  export default {};
</script>

<style>
  .header-logo {
    width: 24px;
    height: 24px;
  }
</style>
