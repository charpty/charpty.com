#!/usr/bin/env bash

# deploy the front files

set -e

base_dir=~/charpty.com
front_dir=$base_dir/modules/site-front
dist_dir=$front_dir/dist
html_bak=/tmp/.charpt-site-html-bak

cd $base_dir
git pull origin master:master

sh compile-front.sh $base_dir

rm -rf $html_bak
mkdir -p $html_bak
mv /usr/local/openresty/nginx/html/* $html_bak/ || true
cp -rf $dist_dir/* /usr/local/openresty/nginx/html/

# dc is an alias: for destroy the nginx cache and restart nginx
dc
echo '\033[0;32m*******************deploy success***************************'
