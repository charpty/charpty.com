#!/usr/bin/env bash

# deploy the front files

set -e

cd charpty.com
git pull origin master:master

cd modules/site-front/app
npm run build
# 仅仅将html目录setfacl给site用户
rm -rf ~/html-bak
mv /usr/local/openresty/nginx/html/* ~/html-bak/ || true
cp -rf dist/* /usr/local/openresty/nginx/html/

# clean cache files
# TODO
nginx -sreload
echo '\033[0;32m*******************deploy success***************************'
