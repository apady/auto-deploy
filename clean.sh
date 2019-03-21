#!/usr/bin/env bash

if [[ -z `which jq` ]]; then
  yum -y install jq
fi

BFS_ENV_DIR=`cat config.json| jq -r '.BFS_ENV_DIR'`
BFS_STORAGE_DIR=`cat config.json| jq -r '.BFS_STORAGE_DIR'`
ProjectDir=`cat config.json| jq -r '.ProjectDir'`
DBName=`cat config.json| jq -r '.DBName'`
DBUser=`cat config.json| jq -r '.DBUser'`
DBPassword=`cat config.json| jq -r '.DBPassword'`

if [ "$1"x = "all"x ]; then
	rm -rf ${BFS_ENV_DIR}/bfs
	rm -rf ${BFS_STORAGE_DIR}
	
fi

rm -rf ${ProjectDir}
rm -rf ${BFS_ENV_DIR}/bfs-php-extension
rm -rf /etc/httpd/conf.d/${serverName}.conf

if [ -z "${DBUser}" ] || [ -z "${DBName}" ] || [ -z "${DBPassword}" ];then
	echo "Please fill in Database parameters in config.json"
	exit
else
	mysql -u${DBUser} -p${DBPassword} -s -e "
	drop database ${DBName} ;
	quit"
fi

#Firewall
if [ `firewall-cmd --state` == "running" ]; then
  firewall-cmd --zone=public --remove-port=80/tcp --permanent
  firewall-cmd --zone=public --remove-port=443/tcp --permanent
  firewall-cmd --zone=public --remove-port=3306/tcp --permanent
  firewall-cmd --zone=public --remove-port=8827/tcp --permanent
  firewall-cmd --reload
fi
