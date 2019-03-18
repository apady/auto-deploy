# Apady env auto deploy script
## 配置

1.赋予脚本执行权限 `chmod u+x apady_env`

2.修改config.json填写相关参数
```json
{
	"svnUsername":"",
	"svnPassword":"",
	"svnRepoURL":"",
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
## 使用方法
1. 安装开发环境 `./apady_env install`

2. 修复环境    `./apady_env repair`

3. 卸载       `./apady_env clean`




