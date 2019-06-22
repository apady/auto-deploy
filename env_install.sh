#!/usr/bin/env bash

# Database

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
  
  yum  --enablerepo=epel -y install nodejs wget unzip git svn zlib-devel redis psmisc gcc-c++ autoconf libtool gettext-devel nginx net-tools
  wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
  yum -y install yarn
  #PHP 7.1
  yum -y --enablerepo=epel install php71w php71w-fpm php71w-devel php71w-mysqlnd php71w-xml php71w-mbstring php71w-gd php71w-pecl-redis
    #php-fpm
  if [[  -f /etc/php-fpm.d/www.conf ]]; then
    sed -i '8c user = nginx' /etc/php-fpm.d/www.conf
    sed -i '10c group = nginx' /etc/php-fpm.d/www.conf
    sed -i '22c listen = 127.0.0.1:9000' /etc/php-fpm.d/www.conf
    sed -i '366,370c env[HOSTNAME] = $HOSTNAME\
    env[PATH] = /usr/local/bin:/usr/bin:/bin\
    env[TMP] = /tmp\
    env[TMPDIR] = /tmp\
    env[TEMP] = /tmp' /etc/php-fpm.d/www.conf
    systemctl start php-fpm
    systemctl enable php-fpm
  else
    echo 'Can not find php-fpm config file'
    exit 1
  fi
fi


