[Apady Environment Auto Deploy Tool](https://github.com/apady/auto-deploy)
======

`apady_env` is a linux command-line environment deployment tool designed for the apady MOOC project.
### Compatibility
 
        
   **CentOS 7** minimal install only!

## Installation

Run the following python script to install
```
sudo python setup.py
```
After configuring all the prerequisite parameters, try to run `apady_env`. When seeing this, it's done!
```
 Welcome to use Apady auto deploy tool @author lishen chen 

      @email frankchenls@outlook.com

      Usage: apady_env COMMAND

      List of Commands:
      deploy   Deploy apady development environment.
      repair   Clean project source code and reinstall the environment.
      config   Configure  prerequisite parameters used in the program.  
      clean    Clean all development environment."
```

## Usage

1. Deploy apady development environment.

```
apady_env deploy
```

2. Clean project source code and reinstall the environment.
```
apady_env repair
```
3. Configure prerequisite parameters used in the program
```
apady_env config
```

4. Clean all the development environment.
```
apady_env clean
```

## Update
Run the following command to update
```
sudo python setup.py update
```

## Uninstallation

Run the following command to uninstall
```
sudo python setup.py uninstall
```


