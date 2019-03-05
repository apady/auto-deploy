#!/usr/bin/env bash

BFS_ENV_DIR=/home
BFS_STORAGE_DIR=/mnt/bfs
ProjectDir=/var/www/html/apady

#SvnUserName
svnUsername=

#SvnPassword
svnPassword=

#ServerDomainName
serverName=

phpcmd=/usr/bin/php

#env
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum -y install nodejs wget unzip git svn zlib-devel redis psmisc gcc-c++ autoconf libtool gettext-devel httpd net-tools
wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
yum -y install yarn

#PHP 7.1
if [[ -z `rpm -qa|grep php` ]];then

yum -y install php71w php71w-devel php71w-mysqlnd php71w-xml php71w-mbstring php71w-gd php71w-pecl-redis
fi

#Database
if [[ -z `rpm -qa|grep mariadb-server` ]];then
yum -y install mariadb mariadb-server
systemctl start mariadb
systemctl enable mariadb
mysql -s -e "
use mysql
update user set password=password('Apady2018') where user='root';
flush privileges;
quit"
fi

mysql -uroot -pApady2018 -s -e "
create database IF NOT EXISTS mooc;
grant all on mooc.* to apady@localhost identified by 'Apady2018';
grant all on mooc.* to apady;
flush privileges;
quit"


#Apache Redis
systemctl enable httpd
systemctl enable redis
systemctl start httpd
systemctl start redis

#libfuse
if [[ ! -d ${BFS_ENV_DIR}/fuse ]]; then
cd ${BFS_ENV_DIR}
wget https://github.com/libfuse/libfuse/archive/fuse-2.9.8.zip
unzip fuse-2.9.8.zip
mv libfuse-fuse-2.9.8 fuse
cd fuse
./makeconf.sh
./configure
make && make install
cd ..
fi

#BFS
if [[ ! -d ${BFS_ENV_DIR}/bfs ]]; then
cd ${BFS_ENV_DIR}
git clone https://github.com/apady/bfs.git
cd bfs 
sed -i '4a FUSE_PATH=${BFS_ENV_DIR}/fuse/include' Makefile
./build.sh
cp libbfs_c.so /usr/lib
ldconfig
cd -
fi

#BFS-PHP-SDK
if [[ ! -d ${BFS_ENV_DIR}/bfs-php-extension ]]; then
git clone https://github.com/apady/bfs-php-extension.git
cd bfs-php-extension
chmod 755 build.sh
./build.sh
cd -
fi

#bfs_mount
if [[ -z `netstat -ant|grep 8827` ]]; then
cd  ${BFS_ENV_DIR}/bfs
if [ ! -d "${BFS_STORAGE_DIR}" ]; then
mkdir ${BFS_STORAGE_DIR}
fi
chown -R apache:apache ${BFS_STORAGE_DIR}
cd sandbox && ./deploy.sh && ./start_bfs.sh
cd ../
sudo -u apache ./bfs_mount ${BFS_STORAGE_DIR}  -c 127.0.0.1:8827 -p /
fi

#composer
if [[ -z `which composer` ]];then
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
fi

#mooc-project
if [ ! -d "${ProjectDir}" ]; then
mkdir ${ProjectDir}
svn co --non-interactive --username ${svnUsername} --password ${svnPassword} https://store.apady.cn/svn/apady/ ${ProjectDir}
chmod -R 755 ${ProjectDir}
setenforce 0
cd ${ProjectDir}
composer install
yarn install
$phpcmd bin/console make:migration -n
$phpcmd bin/console doctrine:schema:drop --force 
$phpcmd bin/console doctrine:migrations:migrate -n
yarn encore dev 
chown -R apache:apache ${ProjectDir}
chown -R apache:apache /var/lib/php/session/ 
fi

#VHost 
if [[ ! -f /etc/httpd/conf.d/${serverName}.conf ]]; then
touch /etc/httpd/conf.d/${serverName}.conf
echo "<VirtualHost *:80>
   ServerName ${serverName}
 
   ## Vhost docroot
   DocumentRoot "${ProjectDir}/public"
 
   ## Directories, there should at least be a declaration for /var/www/html
 
   <Directory "${ProjectDir}/public">
     Options Indexes FollowSymlinks MultiViews
     AllowOverride All
     Require all granted
     DirectoryIndex index.html
   </Directory>
 
   ## Logging
   ErrorLog "/var/log/httpd/${serverName}.log"
   ServerSignature Off
   CustomLog "/var/log/httpd/${serverName}.log" combined
 </VirtualHost>">/etc/httpd/conf.d/${serverName}.conf
fi

#Firewall
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --zone=public --add-port=3306/tcp --permanent
firewall-cmd --zone=public --add-port=8827/tcp --permanent
firewall-cmd --reload

systemctl restart httpd
echo "Done"
