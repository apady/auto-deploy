# Apady env auto deploy script
## 使用方法

1.下载脚本后，切换至root用户，并赋予脚本执行权限 `chmod u+x install.sh`

2.修改config.json填写相关参数
```json
{
	"svnUsername":"",
	"svnPassword":"",
	"serverName":"",
	"BFS_ENV_DIR":"/home",
	"BFS_STORAGE_DIR":"/mnt/bfs",
	"ProjectDir":"",
	"DBName":"",
	"DBUser":"",
	"DBRootPassword":"",
	"DBPassword":""
}
```

3.执行脚本 `./install.sh`


