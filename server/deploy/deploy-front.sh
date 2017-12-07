#!/usr/bin/env bash

# deploy the front files

set -e

base_dir=~/charpty.com
front_dir=${base_dir}/modules/site-front
compile_dir=${front_dir}/app
dist_dir=${front_dir}/dist

cd $base_dir
git pull origin master:master

cd $compile_dir
npm run build

# 由于vendor.js偏大（1M左右），服务器带宽却非常少，所以将其放在OSS上
# TODO 目前仅有caibo.ren有证书
cd ~
sed -ibakvendorjs 's/\/static\/js\/vendor\.\w*\.js/https:\/\/s.charpty.com\/s\/vendor.js/' ${dist_dir}/index.html
rm -rf ./bakvendorjs
cp ${dist_dir}/static/js/vendor*.js ~/vendor.js
cd ~
python upload_s.py vendor.js

# 仅仅将html目录setfacl给site用户
rm -rf ~/html-bak
mkdir -p ~/html-bak
mv /usr/local/openresty/nginx/html/* ~/html-bak/ || true
cp -rf ${dist_dir}/* /usr/local/openresty/nginx/html/

# clean cache files
# TODO
# nginx -sreload
echo '\033[0;32m*******************deploy success***************************'
