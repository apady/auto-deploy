#!/usr/bin/env bash


svnUsername=`cat config.json| jq -r '.svnUsername'`
svnPassword=`cat config.json| jq -r '.svnPassword'`
svnRepoURL=`cat config.json| jq -r '.svnRepoURL'`
serverName=`cat config.json| jq -r '.serverName'`

BFS_ENV_DIR=`cat config.json| jq -r '.BFS_ENV_DIR'`
BFS_STORAGE_DIR=`cat config.json| jq -r '.BFS_STORAGE_DIR'`
ProjectDir=`cat config.json| jq -r '.ProjectDir'`

DBName=`cat config.json| jq -r '.DBName'`
DBUser=`cat config.json| jq -r '.DBUser'`
DBRootPassword=`cat config.json| jq -r '.DBRootPassword'`
DBPassword=`cat config.json| jq -r '.DBPassword'`

phpcmd=/usr/bin/php




mysql -uroot -p${DBRootPassword} -s -e "
create database IF NOT EXISTS ${DBName};
grant all on ${DBName}.* to ${DBUser}@localhost identified by '${DBPassword}';
grant all on ${DBName}.* to ${DBUser};
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
  git clone --depth=1 https://github.com/apady/bfs.git
  cd bfs 
  sed -i '4a FUSE_PATH=${BFS_ENV_DIR}/fuse/include' Makefile
  ./build.sh
  cp libbfs_c.so /usr/lib
  ldconfig
fi

#BFS-PHP-SDK
if [[ ! -d ${BFS_ENV_DIR}/bfs-php-extension ]]; then
  cd ${BFS_ENV_DIR}
  git clone --depth=1 https://github.com/apady/bfs-php-extension.git
  cd bfs-php-extension
  chmod 755 build.sh
  ./build.sh
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
  svn co --non-interactive --username ${svnUsername} --password ${svnPassword} ${svnRepoURL} ${ProjectDir}
  if [ ! -d "${ProjectDir}/.svn" ]; then
    echo 'Fail to checkout source code'
    echo 'Run apady_env config to check SVN parameters'
    exit 1
  fi
  chmod -R 755 ${ProjectDir}
  if [[ `getenforce` = "Enforcing" ]];then
    setenforce 0
  fi
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
if [ `firewall-cmd --state` == "running" ]; then
  echo 'Configuring firewall...'
  if [[ -z `firewall-cmd --list-services |grep http` ]];then
    firewall-cmd --zone=public --add-port=80/tcp --permanent
  fi
  if [[ -z `firewall-cmd --list-services |grep https` ]];then
    firewall-cmd --zone=public --add-port=443/tcp --permanent
  fi
  if [[ -z `firewall-cmd --list-services |grep mysql` ]];then
    firewall-cmd --zone=public --add-port=3306/tcp --permanent
  fi
  if [[ -z `firewall-cmd --list-ports |grep 8827` ]];then
    firewall-cmd --zone=public --add-port=8827/tcp --permanent
  fi
  firewall-cmd --reload
fi

echo 'Restarting Apache...'
systemctl restart httpd
echo 'Done.'
