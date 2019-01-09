#!/usr/bin/env bash

# deploy the front files

set -e

base_dir=$1
front_dir=${base_dir}/modules/site-front
compile_dir=${front_dir}/app
dist_dir=${front_dir}/dist
bak_dir=/tmp/.charpty-site-compile-html-bak

cd $compile_dir
npm run build

mkdir -p ${bak_dir}
cd $bak_dir
re_js='s/\(\/static\/js\/[a-z\._A-Z0-9]*\.js\)/\/\/s.charpty.com\/\1/g'
re_css='s/\(\/static\/css\/[a-z\._A-Z0-9]*\.css\)/\/\/s.charpty.com\/\1/g'
re_manifest_prefix='s/\(n\.p=\"\)\/\"/\1\/\/s.charpty.com\/\"/'
# em...can not use '|' in osx like: xxxxx\(png|jpg\)xxxx
re_png='s/\(\/static\/image\/[a-z_A-Z0-9]*\.png\)/\/\/s.charpty.com\/\1/g'
re_jpg='s/\(\/static\/image\/[a-z_A-Z0-9]*\.jpg\)/\/\/s.charpty.com\/\1/g'
sed -ibak_index_js -e ${re_js} ${dist_dir}/index.html
sed -ibak_index_css -e ${re_css} ${dist_dir}/index.html
sed -ibak_manifest_mprefix -e ${re_manifest_prefix} ${dist_dir}/static/js/manifest*.js
sed -ibak_index_image -e ${re_png} -e ${re_jpg} ${dist_dir}/index.html
sed -ibak_appcss_image -e ${re_png} -e ${re_jpg} ${dist_dir}/static/css/app*.css
rm -rf ${bak_dir}

echo '\033[0;32m*******************compile success***************************'
