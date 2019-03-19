#!/usr/bin/env bash
case "$1"x in
  "install"x )
    cd apady_envd
    bash ./env_install.sh
    bash ./deploy.sh
    cd -
    ;;
  "repair"x )
    cd apady_envd
    bash ./clean.sh 
    bash ./deploy.sh
    cd -
    ;;
  "clean"x )
    cd apady_envd
    bash ./clean.sh all
    cd -
    ;;
  *)
    echo "
      Welcome to use Apady auto deploy script @author lishen chen 

      @email frankchenls@outlook.com

      Usage: apady_env COMMAND

      List of Commands:
      install  Install apady development environment.
      repair   Clean project source code and reinstall the environment.
      config   Configure  prerequisite parameters used in the program.  
      clean    Clean all development environment."
  ;;
esac

echo "Done"
