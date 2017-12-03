#/bin/bash

# just deploy my site

set -e

cd charpty.com
git pull origin master:master
mvn clean package -Dmaven.test.skip=true
cp modules/site-server/target/site-server-*.war ~/site-server.war

oldp=`ps -ef |grep db.username=charptysite |grep -v grep| head -1 | awk '{print $2}'`
test $oldp && kill -9 $oldp 

echo "try to start war..."
cd ~
dburl='jdbc:mysql://127.0.0.1:3306/charptysite?characterEncoding=utf8&useSSL=false'
java -jar -Ddb.url=$dburl -Ddb.username=charptysite -Ddb.password=$(cat dbpwd) site-server.war --server.port=6899 & &> nohub.out

echo '\033[0;32m*******************deploy success***************************'
