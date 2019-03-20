#!/usr/bin/env bash
set -x -e
# Database

if [[ -z ` rpm -qa | grep mariadb-server ` ]];then
  yum -y install mariadb mariadb-server
  systemctl start mariadb
  systemctl enable mariadb
  mysql -s -e "
  use mysql
  update user set password=password('${DBRootPassword}') where user='root';
  flush privileges;
  quit"
fi

rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum -y install epel-release nodejs wget unzip git svn zlib-devel redis psmisc gcc-c++ autoconf libtool gettext-devel httpd net-tools
wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
yum -y install yarn
#PHP 7.1
yum -y install php71w php71w-devel php71w-mysqlnd php71w-xml php71w-mbstring php71w-gd php71w-pecl-redis
  
