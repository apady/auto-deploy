#!/usr/bin/env bash

if [[ -z `rpm -qa |grep epel-release` ]];then
	rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
fi 

if [[ -z `which jq` ]]; then
  yum -y install jq
fi 