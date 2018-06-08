解决Go Get Timeout问题
=====================

DATE: 2017-11-08

本文解决对于在国内无法访问golang.org, 导致无法安装go的相关包问题, 提供了相应的解决方案.

阅读完该文档之后, 您将了解到:

* 如何安装VPN lantern.
* 如何在mac上设置http_proxy和https_proxy的环境变量.
* 如何解决go get某个包超时的问题.

--------------------------------------------------------------------------------

问题起因
--------
我们选择go的编辑器为: [vim](http://www.vim.org/)

vim中使用的go的plugin为: [fatih/vim-go](https://github.com/fatih/vim-go)

在使用vim中集成的一些自带的功能时候, 如 [:GoTest](https://github.com/fatih/vim-go/blob/master/doc/vim-go.txt#L368)

发现会要求安装一些包, 提示

```shell
vim-go: could not find 'gotests'. Run :GoInstallBinaries to fix it
```

执行 `:GoInstallBinaries`

则会看到报错信息

```shell
Error: Command failed: go get -u -v github.com/cweill/gotests/...
github.com/cweill/gotests (download)
Fetching https://golang.org/x/tools/imports?go-get=1
https fetch failed: Get https://golang.org/x/tools/imports?go-get=1: dial tcp 216.239.37.1:443: i/o timeout
golang.org/x/tools (download)
```

解决方案
-------
### 安装lantern

地址: [getlantern/lantern](https://github.com/getlantern/lantern)

我的是mac版本, 下载后双击后即可.

### 获取代理的地址
点击安装好的lantern, 并打开配置页面

![lanten](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/lanten.png)


查看SOCKS代理服务器地址

![lanten](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/lantern_config.png)

### 设置http_proxy和https_proxy
根据上图的SOCKS代理服务器的地址, 如: 127.0.0.1:63709
设置代理

在bash中执行

```shell
export http_proxy=127.0.0.1:63708
export https_proxy=127.0.0.1:63708
```

### 验证
配置完毕后, 在bash中执行

```shell
go get -v github.com/zmb3/gogetdoc
```

可看到输出结果

```shell
Fetching https://golang.org/x/tools/go/buildutil?go-get=1
Parsing meta tags from https://golang.org/x/tools/go/buildutil?go-get=1 (status code 200)
get "golang.org/x/tools/go/buildutil": found meta tag main.metaImport{Prefix:"golang.org/x/tools", VCS:"git", RepoRoot:"https://go.googlesource.com/tools"} at https://golang.org/x/tools/go/buildutil?go-get=1
get "golang.org/x/tools/go/buildutil": verifying non-authoritative meta tag
Fetching https://golang.org/x/tools?go-get=1
Parsing meta tags from https://golang.org/x/tools?go-get=1 (status code 200)
golang.org/x/tools (download)
Fetching https://golang.org/x/tools/go/loader?go-get=1
Parsing meta tags from https://golang.org/x/tools/go/loader?go-get=1 (status code 200)
get "golang.org/x/tools/go/loader": found meta tag main.metaImport{Prefix:"golang.org/x/tools", VCS:"git", RepoRoot:"https://go.googlesource.com/tools"} at https://golang.org/x/tools/go/loader?go-get=1
get "golang.org/x/tools/go/loader": verifying non-authoritative meta tag
golang.org/x/tools/go/buildutil
golang.org/x/tools/go/ast/astutil
golang.org/x/tools/go/loader
github.com/zmb3/gogetdoc
```

不再出现 `i/o timeout` 提示. 已经成功安装go的相关插件. 故可以在vim中再次执行`:GoInstallBinaries`即可.
