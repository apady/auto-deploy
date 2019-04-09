  #!/usr/bin/env bash

  WORK_DIR=/usr/bin

  if [[ ! -f ${WORK_DIR}/apady_envd/config.json ]]; then
    echo 'Configuration file does not exit!'
    exit 1
  fi

  case "$1"x in
  "deploy"x )
  cd ${WORK_DIR}/apady_envd
  bash ./env_install.sh deploy
  bash ./deploy.sh
  ;;
  "repair"x )
  cd ${WORK_DIR}/apady_envd
  bash ./clean.sh repair
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
