#!/usr/bin/env bash

# deploy the front files

set -e

cd charpty.com
git pull origin master:master

cd modules/site-front/app
npm run build

cd ..
# 由于vendor.js偏大（1M左右），服务器带宽却非常少，所以将其放在OSS上
# TODO 目前仅有caibo.ren有证书
sed -ibakvendorjs 's/\/static\/js\/vendor.*\.js/https:\/\/caibo.ren\/s\/vendor.js/' dist/index.html
rm -rf ./bakvendorjs
cp dist/static/js/vendor*.js vendor.js
python upload_imags_alioss.py vendor.js

# 仅仅将html目录setfacl给site用户
rm -rf ~/html-bak
mkdir -p ~/html-bak
mv /usr/local/openresty/nginx/html/* ~/html-bak/ || true
cp -rf dist/* /usr/local/openresty/nginx/html/

# clean cache files
# TODO
nginx -sreload
echo '\033[0;32m*******************deploy success***************************'
