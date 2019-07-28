#!/usr/bin/env bash
set -x
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



#Nginx Redis
systemctl enable nginx
systemctl enable redis
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
if [[ -z `ps -fe|grep nameserver|grep -v grep` ]]; then
  cd  ${BFS_ENV_DIR}/bfs
  if [ ! -d "${BFS_STORAGE_DIR}" ]; then
    mkdir ${BFS_STORAGE_DIR}
  fi
  chown -R nginx:nginx ${BFS_STORAGE_DIR}
  cd sandbox && ./deploy.sh && ./start_bfs.sh
  cd ../
  sudo -u nginx ./bfs_mount ${BFS_STORAGE_DIR}  -c 127.0.0.1:8827 -p /
fi

#composer
if [[ -z `which composer` ]];then
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
fi

#mooc-project
if [ ! -d "${ProjectDir}/cauc-mooc" ]; then
  cd ${ProjectDir}
  git clone --depth=1 https://github.com/apady/cauc-mooc.git
  if [ ! -d "${ProjectDir}/cauc-mooc/.git" ]; then
    echo 'Fail to checkout source code'
    exit 1
  fi
  chmod -R 755 ${ProjectDir}/cauc-mooc
  if [[ `getenforce` == "Enforcing" ]];then
    setenforce 0
  fi
  cd ${ProjectDir}/cauc-mooc
  composer install
  yarn install
  $phpcmd bin/console make:migration -n
  $phpcmd bin/console doctrine:schema:drop --force 
  $phpcmd bin/console doctrine:migrations:migrate -n
  yarn encore dev 
  chown -R nginx:nginx ${ProjectDir}/cauc-mooc
  chown -R nginx:nginx /var/lib/php/session/ 
fi


#VHost 
if [[ ! -f /etc/nginx/conf.d/${serverName}.conf ]]; then
  touch /etc/nginx/conf.d/${serverName}.conf
  echo "server {
    server_name ${serverName};
    root ${ProjectDir}/cauc-mooc/public;
    client_max_body_size 20M;

    location / {
        # try to serve file directly, fallback to index.php
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;

        # optionally set the value of the environment variables used in the application
        # fastcgi_param APP_ENV prod;
        # fastcgi_param APP_SECRET <app-secret-id>;
        fastcgi_param DATABASE_URL "mysql://${DBUser}:${DBPassword}@127.0.0.1:3306/${DBName}";

        # When you are using symlinks to link the document root to the
        # current version of your application, you should pass the real
        # application path instead of the path to the symlink to PHP
        # FPM.
        # Otherwise, PHP's OPcache may not properly detect changes to
        # your PHP files (see https://github.com/zendtech/ZendOptimizerPlus/issues/126
        # for more information).
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT \$realpath_root;
        # Prevents URIs that include the front controller. This will 404:
        # http://domain.tld/index.php/some-path
        # Remove the internal directive to allow URIs like this
        internal;
    }

    # return 404 for all other php files not matching the front controller
    # this prevents access to other php files you don't want to be accessible.
    location ~ \.php$ {
        return 404;
    }

    error_log /var/log/nginx/${serverName}_error.log;
    access_log /var/log/nginx/${serverName}_access.log;
  }
  ">/etc/nginx/conf.d/${serverName}.conf
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

echo 'Restarting Nginx...'
systemctl restart nginx
systemctl restart php-fpm
echo 'Done.'
