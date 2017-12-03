#!/usr/bin/env bash

# deploy the front files

set -e

cd charpty.com
git pull origin master:master

cd modules/site-front/app
npm run build
mv /usr/local/openresty/nginx/html /usr/local/openresty/nginx/html-bak
cp dist/* /usr/local/openresty/nginx/html/

# clean cache files
# TODO
nginx -sreload
echo '\033[0;32m*******************deploy success***************************'
