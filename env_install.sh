#!/usr/bin/env bash

# Database
set -x

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

if [[ -z `which jq` ]]; then
  yum -y install jq
fi

DBRootPassword=`cat config.json| jq -r '.DBRootPassword'`

if [[ -z ` which mysql ` ]];then
  yum -y install mariadb mariadb-server
  systemctl start mariadb
  systemctl enable mariadb
  mysql -s -e "
  use mysql
  update user set password=password('${DBRootPassword}') where user='root';
  flush privileges;
  quit"
fi

if [ "$1"x == "deploy"x ];then
  yum -y remove php*
  yum -y remove httpd* 
fi

yum  --enablerepo=epel -y install nodejs wget unzip git svn zlib-devel redis psmisc gcc-c++ autoconf libtool gettext-devel httpd net-tools
wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
yum -y install yarn
#PHP 7.1
yum -y --enablerepo=epel install php71w php71w-devel php71w-mysqlnd php71w-xml php71w-mbstring php71w-gd php71w-pecl-redis
  
