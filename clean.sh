#!/usr/bin/env bash
set -x
BFS_ENV_DIR=`cat config.json| jq -r '.BFS_ENV_DIR'`
BFS_STORAGE_DIR=`cat config.json| jq -r '.BFS_STORAGE_DIR'`
ProjectDir=`cat config.json| jq -r '.ProjectDir'`
DBName=`cat config.json| jq -r '.DBName'`
DBUser=`cat config.json| jq -r '.DBUser'`
DBPassword=`cat config.json| jq -r '.DBPassword'`
serverName=`cat config.json| jq -r '.serverName'`

echo 'Cleaing...Please wait.'
if [[ -n `ps -fe|grep bfs_mount|grep -v grep` ]];then
	umount ${BFS_STORAGE_DIR}
fi

rm -rf ${BFS_STORAGE_DIR}

if [ "$1"x = "repair"x ]; then
	cd ${BFS_ENV_DIR}/bfs/sandbox && ./clear.sh
fi

if [ "$1"x = "all"x ]; then
	rm -rf ${BFS_ENV_DIR}/bfs
	if [ `firewall-cmd --state` == "running" ]; then
		if [[ -z `firewall-cmd --list-all |grep http|grep https|grep mysql|grep 8827` ]];then
			firewall-cmd --zone=public --remove-port=80/tcp --permanent
			firewall-cmd --zone=public --remove-port=443/tcp --permanent
			firewall-cmd --zone=public --remove-port=3306/tcp --permanent
			firewall-cmd --zone=public --remove-port=8827/tcp --permanent
		fi
		firewall-cmd --reload
	fi

fi

rm -rf ${ProjectDir}/cauc-mooc
rm -rf ${BFS_ENV_DIR}/bfs-php-extension
rm -rf /etc/nginx/conf.d/${serverName}.conf

if [ -z "${DBUser}" ] || [ -z "${DBName}" ] || [ -z "${DBPassword}" ];then
	echo "Please fill in Database parameters in config.json"
	exit
else
	mysql -u${DBUser} -p${DBPassword} -s -e "
	drop database ${DBName} ;
	quit"
fi


