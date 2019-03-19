#!/usr/bin/env python
# coding=utf-8   
import os,shutil
import json
import getpass

INSTALL_DIR = '/usr/local/bin/'	
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
deploy_dir = os.path.join(INSTALL_DIR,'apady_envd')


def store(data):
    with open('config.json', 'w') as json_file:
        json_file.write(json.dumps(data,sort_keys=True, indent=4, separators=(',', ': ')))

def config():
	svnRepoURL =  raw_input("Please input SVN repository URL:")
	svnUsername =  raw_input("Please input SVN user name:")
	svnPassword =  getpass.getpass("Please input SVN password:")
	serverName =  raw_input("Please input server domain name:")
	DBName =  raw_input("Database name:")
	DBUser =  raw_input("Database user:")
	DBPassword =  getpass.getpass("User password for database:")
	DBRootPassword =  getpass.getpass("Root password for your database:")
	ProjectDir =  raw_input("Please input project directory path(/var/www/html/apady) :")
	if not ProjectDir: ProjectDir = "/var/www/html/apady"
	
	BFS_ENV_DIR =  raw_input("Directory path for Baidu File System(/home):")
	if not BFS_ENV_DIR: BFS_ENV_DIR = "/home"
	
	BFS_STORAGE_DIR =  raw_input("Directory path for BFS storage(/mnt/bfs):")
	if not BFS_STORAGE_DIR: BFS_STORAGE_DIR = "/mnt/bfs"

	config_data = {"svnUsername":svnUsername,
	"svnPassword":svnPassword,
	"svnRepoURL":svnRepoURL,
	"serverName":serverName,
	"BFS_ENV_DIR":BFS_ENV_DIR,
	"BFS_STORAGE_DIR":BFS_STORAGE_DIR,
	"ProjectDir":ProjectDir,
	"DBName":DBName,
	"DBUser":DBUser,
	"DBRootPassword":DBRootPassword,
	"DBPassword":DBPassword}
	return config_data
def install():
	
	uninstall()
	os.mkdir(deploy_dir)
	
	shutil.copy(os.path.join(BASE_DIR,'apady_env.sh'), os.path.join(INSTALL_DIR,'apady_env'))
	shutil.copy(os.path.join(BASE_DIR,'clean.sh'), os.path.join(deploy_dir,'clean.sh'))
	shutil.copy(os.path.join(BASE_DIR,'env_install.sh'), os.path.join(deploy_dir,'env_install.sh'))
	shutil.copy(os.path.join(BASE_DIR,'deploy.sh'), os.path.join(deploy_dir,'deploy.sh'))
	shutil.copy(os.path.join(BASE_DIR,'config.json'), os.path.join(deploy_dir,'config.json'))
	shutil.copy(os.path.join(BASE_DIR,'setup.py'), os.path.join(deploy_dir,'setup.py'))


def uninstall():

    if not os.path.isdir(deploy_dir):
    	return
    files = os.listdir(deploy_dir)
    try:
        for file in files:
            filePath=os.path.join(deploy_dir,file)
            if os.path.isfile(filePath):
                os.remove(filePath)
            elif os.path.isdir(filePath):
                removeDir(filePath)
        os.rmdir(deploy_dir)
    except Exception,e:
    	print e

    if os.path.isfile(os.path.join(INSTALL_DIR,'apady_env')):
		os.remove(os.path.join(INSTALL_DIR,'apady_env'))
	

 
if __name__ == '__main__':
	if not os.path.isfile('./config.json'):
		config_data=config()
		store(config_data)
	install()








	