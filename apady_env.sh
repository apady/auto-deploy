#!/usr/bin/env bash

WORK_DIR=/usr/bin

if [[ -z `rpm -qa |grep epel-release` ]]
  rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
fi

case "$1"x in
  "deploy"x )
    cd ${WORK_DIR}/apady_envd
    bash ./env_install.sh deploy
    bash ./deploy.sh
    cd -
    ;;
  "repair"x )
    cd ${WORK_DIR}/apady_envd
    bash ./clean.sh 
    bash ./env_install.sh
    bash ./deploy.sh
    cd -
    ;;
  "clean"x )
    cd ${WORK_DIR}/apady_envd
    bash ./clean.sh all
    cd -
    ;;
  "config"x )
    cd ${WORK_DIR}/apady_envd
    python setup.py
    cd -
    ;;
  *)
    echo "
      Welcome to use Apady auto deploy script @author lishen chen 

      @email frankchenls@outlook.com

      Usage: apady_env COMMAND

      List of Commands:
      deploy   Deploy apady development environment.
      repair   Clean project source code and reinstall the environment.
      config   Configure  prerequisite parameters used in the program.  
      clean    Clean all development environment."
  ;;
esac

