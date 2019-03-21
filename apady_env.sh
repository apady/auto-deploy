#!/usr/bin/env bash

WORK_DIR=/usr/bin

if [[ -z `rpm -qa |grep epel-release` ]];then
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
fi

case "$1"x in
  "deploy"x )
    cd ${WORK_DIR}/apady_envd
    bash ./env_install.sh deploy
    bash ./deploy.sh
    ;;
  "repair"x )
    cd ${WORK_DIR}/apady_envd
    bash ./clean.sh 
    bash ./env_install.sh
    bash ./deploy.sh
    ;;
  "clean"x )
    cd ${WORK_DIR}/apady_envd
    bash ./clean.sh all
    ;;
  "config"x )
    cd ${WORK_DIR}/apady_envd
    python setup.py
    ;;
  *)
    echo "
      Welcome to use Apady auto deploy tool @author lishen chen 

      @email frankchenls@outlook.com

      Usage: apady_env COMMAND

      List of Commands:
      deploy   Deploy apady development environment.
      repair   Clean project source code and reinstall the environment.
      config   Configure  prerequisite parameters used in the program.  
      clean    Clean all the development environment."
  ;;
esac

