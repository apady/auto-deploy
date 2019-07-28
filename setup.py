#!/usr/bin/env python
# coding=utf-8   
import os,shutil,sys,stat
import json
import getpass

INSTALL_DIR = '/usr/bin/'	
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
deploy_dir = os.path.join(INSTALL_DIR,'apady_envd')


def store(data):
    with open(os.path.join(BASE_DIR,'config.json'), 'w') as json_file:
        json_file.write(json.dumps(data,sort_keys=True, indent=4, separators=(',', ': ')))
def load():
    with open(os.path.join(deploy_dir,'config.json')) as json_file:
        data = json.load(json_file)
        return data

def config():
	
	serverName =  raw_input("Please input server domain name:")
	DBName =  raw_input("Database name:")
	DBUser =  raw_input("Database user:")
	DBPassword =  getpass.getpass("User password for database:")
	DBRootPassword =  getpass.getpass("Root password for your database:")
	ProjectDir =  raw_input("Please input project directory path(/var/www/html) :")
	if not ProjectDir: ProjectDir = "/var/www/html"
	
	BFS_ENV_DIR =  raw_input("Directory path for Baidu File System(/home):")
	if not BFS_ENV_DIR: BFS_ENV_DIR = "/home"
	
	BFS_STORAGE_DIR =  raw_input("Directory path for BFS storage(/mnt/bfs):")
	if not BFS_STORAGE_DIR: BFS_STORAGE_DIR = "/mnt/bfs"

	config_data = {
	"serverName":serverName,
	"BFS_ENV_DIR":BFS_ENV_DIR,
	"BFS_STORAGE_DIR":BFS_STORAGE_DIR,
	"ProjectDir":ProjectDir,
	"DBName":DBName,
	"DBUser":DBUser,
	"DBRootPassword":DBRootPassword,
	"DBPassword":DBPassword}
	return config_data
def reconfig():

	config = load()

	serverName =  raw_input("Please input server domain name(%s):" % (config['serverName']))
	if serverName: config['serverName'] = serverName 

	DBName =  raw_input("Database name(%s):" % (config['DBName']))
	if  DBName: config['DBName'] = DBName 

	DBUser =  raw_input("Database user(%s):" % (config['DBUser']))
	if  DBUser: config['DBUser'] = DBUser 

	DBPassword =  getpass.getpass("User password for database:")
	if DBPassword: config['DBPassword'] = DBPassword

	DBRootPassword =  getpass.getpass("Root password for your database:")
	if DBRootPassword: config['DBRootPassword'] = DBRootPassword

	ProjectDir =  raw_input("Please input project directory path(%s):" % (config['ProjectDir']))
	if  ProjectDir: config['ProjectDir'] = ProjectDir 
	
	BFS_ENV_DIR =  raw_input("Directory path for Baidu File System(%s):" % (config['BFS_ENV_DIR']))
	if  BFS_ENV_DIR:  config['BFS_ENV_DIR'] = BFS_ENV_DIR 
	
	BFS_STORAGE_DIR = raw_input("Directory path for BFS storage(%s):" % (config['BFS_STORAGE_DIR']))
	if  BFS_STORAGE_DIR: config['BFS_STORAGE_DIR'] = BFS_STORAGE_DIR 

	return config

def clear_config():
	if os.path.isfile('./config.json'):
		os.remove('./config.json')

def repo_install():
	os.system('bash repo.sh')

def install():
	
	uninstall()
	os.mkdir(deploy_dir)
	if not os.path.isfile('./config.json'):
		if(raw_input("Configuration file does not exist. Try it again? (Y/N):").upper()=='Y'):
			config_data=config()
			store(config_data)	
	shutil.copy(os.path.join(BASE_DIR,'apady_env.sh'), os.path.join(INSTALL_DIR,'apady_env'))
	shutil.copy(os.path.join(BASE_DIR,'clean.sh'), os.path.join(deploy_dir,'clean.sh'))
	shutil.copy(os.path.join(BASE_DIR,'env_install.sh'), os.path.join(deploy_dir,'env_install.sh'))
	shutil.copy(os.path.join(BASE_DIR,'deploy.sh'), os.path.join(deploy_dir,'deploy.sh'))
	shutil.copy(os.path.join(BASE_DIR,'config.json'), os.path.join(deploy_dir,'config.json'))
	shutil.copy(os.path.join(BASE_DIR,'setup.py'), os.path.join(deploy_dir,'setup.py'))
	os.chmod(os.path.join(INSTALL_DIR,'apady_env'),stat.S_IXOTH) 
	


def uninstall():

    if not os.path.isdir(deploy_dir):
    	return
    shutil.rmtree(deploy_dir)

    if os.path.isfile(os.path.join(INSTALL_DIR,'apady_env')):
    	os.remove(os.path.join(INSTALL_DIR,'apady_env'))
	

 
if __name__ == '__main__':
	if len(sys.argv) > 1 :
		if sys.argv[1] == 'update':
			install()
			print('Successfully updated.')
		elif sys.argv[1] == 'uninstall':
			clear_config()
			uninstall()
			print('Successfully uninstalled.')
	else:
		if not os.path.isfile('./config.json'):
			config_data=config()
			store(config_data)
			repo_install()
			install()
			print('Successfully installed.')
		else:
			config_data= reconfig()
			store(config_data)


	








	
