#!/bin/bash

if [ ! -d "charpty.com.mds" ];then
    git clone https://github.com/charpty/charpty.com.mds
fi

cd charpty.com.mds
git pull origin

cp -rf codes /usr/local/openresty/nginx/html/
cp -rf images /usr/local/openresty/nginx/html/

echo '\033[0;32m*******************update mds success***************************'