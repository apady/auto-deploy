#!/usr/bin/env bash
set -x
if [[ -z `which jq` ]]; then
  yum -y install jq
fi

BFS_ENV_DIR=`cat config.json| jq -r '.BFS_ENV_DIR'`
BFS_STORAGE_DIR=`cat config.json| jq -r '.BFS_STORAGE_DIR'`
ProjectDir=`cat config.json| jq -r '.ProjectDir'`
DBName=`cat config.json| jq -r '.DBName'`
DBRootPassword=`cat config.json| jq -r '.DBRootPassword'`
DBPassword=`cat config.json| jq -r '.DBPassword'`

if [ "$1"x = "all"x ]; then
	rm -rf ${BFS_ENV_DIR}
	rm -rf ${BFS_STORAGE_DIR}
fi

rm -rf ${ProjectDir}

mysql -uroot -p${DBRootPassword} -s -e "
drop database  ${DBName} ;
quit"