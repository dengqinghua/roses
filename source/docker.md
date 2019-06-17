Docker Learning
================

DATE: 2019-04-09

该文档涵盖了 Docker 的一些学习笔记.

阅读完该文档之后, 您将了解到:

* Docker 架构.
* Docker 使用
* Docker 的源码分析和架构思考.

--------------------------------------------------------------------------------

架构
----
### Componets
TREE:
{
        text: { name: "Docker" },
        children: [
            { text: { name: "Engine: Client and Server" } },
            { text: { name: "Images" } },
            { text: { name: "Registers" } },
            { text: { name: "Containers" } }
       ]
}

### Key Technical Components
- libcontainer
- Linux Kernel namespaces
- Isolation
  + Filesystem
  + Process
  + Network
- Resource Isolation and Grouping
- Copy on Write of filesystem
- Logging from STDIN, STDOUT and STDERR of container
- Interactive Shell

交互
----
### 启动, 监控和统计
INFO: 下面的 `guides` 均为 container_name

```bash
docker run --name guides -i -t ubuntu /bin/bash
```

```bash
docker start/stop guides
docker attach guides # 进入容器
```

监控和统计

```bash
docker top guides
docker stats
```

INFO: i: interactive, t: pseudo-tty

NOTE: docker run 的运行方式是什么样的? 如果生成多个 container 的时候, 会占用多少容量呢?

### 搜索, 拉取和自定义 images
```bash
docker search ruby

# NAME DESCRIPTION       STARS OFFICIAL AUTOMATED
# ruby Ruby is a dynamic 1648  [OK]

docker pull ruby
```

#### Dockerfile
NOTE: 相关命令见[这里](https://docs.docker.com/engine/reference/builder/)

```bash
# Version: 0.0.1
FROM ubuntu:16.04
MAINTAINER dengqinghua "dengqinghua.42@gmail.com"
RUN apt-get update; apt-get install -y nginx
RUN echo "Hi, I am in your container" > /var/www/html/index.html
EXPOSE 80
```

从当前目录构建新的镜像

```bash
docker build -t="dengqinghua/static_web:v1" .
```

INFO: -t tag

NOTE: ~~在mac上, docker 基于 virtualbox, 需要先生成一个本地的VM~~

#### IP和端口的映射关系
NOTE: 如果使用的 `virtualbox` 作为 VM, 通过 `docker-machine ls`, 可以看到绑定的地址

```bash
docker-machine ls
NAME      ACTIVE   DRIVER       STATE     URL                         SWARM   DOCKER     ERRORS
default   *        virtualbox   Running   tcp://192.168.99.106:2376           v18.09.3
```

可以看到 docker 在本机的地址为 `192.168.99.106`

当我们执行 docker run , 并且想暴露端口时候, 可以添加 `-p` 参数, 如

```bash
docker run -d -p 80 --name static_web dengqinghua/static_web:v2 nginx
```

可以通过 `docker ps -l` 看到绑定关系

```
docker ps -l

CONTAINER ID        IMAGE                       COMMAND  PORTS                   NAMES
3417f368d461        dengqinghua/static_web:v2   "nginx"  0.0.0.0:32777->80/tcp   static_web
```

可以看到 IP和端口的绑定关系:

Docker     0.0.0.0:32777
Container  80

而结合docker在本机的地址为 192.168.99.106:32777

则在浏览器访问 192.168.99.106:32777, 则可以访问到 nginx 的静态index文件

### 进入某个docker
```bash
docker exec -it container_name bash

-i, --interactive   Keep STDIN open even if not attached
    --privileged    Give extended privileges to the command
-t, --tty           Allocate a pseudo-TTY
```

Docker需要解决的问题
-------------------
1. 隔离, 分配不同的用户权限
2. 文件的共享, 一些数据是不能在 Dockerfile 里面的, 如数据, 代码等
3. 环境变量, 参数设置(如 http_proxy)
4. 基础组件的安装, 前置/后置命令的执行 (ON/BEFORE/AFTER BUILD)
5. 和docker的通信(信号量等), 端口暴露和端口映射
6. 自动化, AutoBuild/CI 等
7. 端口的映射

### CMD 和 ENTRYPOINT
CMD: 为 container 启动之后, 执行的命令, 可以被命令行`docker run`覆盖, 在 Dockerfile 中仅能申明一个 CMD 指令
ENTRYPOINT: The ENTRYPOINT instruction provides a command that isn’t as easily overridden.

Network Interface
-----------------
### docker internal networking

docker container生成的时候, 均会接口(interface0)分配对应的IP地址, 网段为 `172.17-172.30`


Volume
------
### docker volume
volume 可以认为是docker的持久化文件机制

通过

```
docker volume ls
```

可以看到当前的目录

```bash
docker volume ls

DRIVER              VOLUME NAME
local               4f80cc3ae270bf3c82abab71548bb1eaba8a0b2f7305e9ea862d5c96b1409009
local               5f1f3a638561b6ade35715fb320ce32dd96e86326cf85fd93e1b452350ccafb6
local               9d49d86bca227497d834a097dc08c972238ab4c8fc426f9889a03b500c3de470
local               33c3f1acba2d22e340f8bc24913a8a4501b689ee4f800f93d1d1e4e155356f1f
local               43b47ab7587f536bcc922eb5d8fa43d0075eb7d9e7e4648b395c89fd201f9d9c
local               5829ba6a91108cddaddd821e72edd7f9f0dc131ce25eafa9ddb72cf790a279af
local               6412489d1e1bff99a4b28f3c4fd6d7789724c5a0909a63ecc3d2fce51e9631f6
local               eefedf7a7e4aa781344c5dc40625fc813883a1ea73936461c54a1f0f39f4980c
local               f39f79523354563e72774100583c070a8077766b6ed4134995c7a468d77555a6
```

我们可以看到每一个 VOLUME 对应的本机的文件目录地址

```bash
docker volume inspect 4f80cc3ae270bf3c82abab71548bb1eaba8a0b2f7305e9ea862d5c96b1409009

[
    {
        "CreatedAt": "2019-05-12T08:16:36Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/4f80cc3ae270bf3c82abab71548bb1eaba8a0b2f7305e9ea862d5c96b1409009/_data",
        "Name": "4f80cc3ae270bf3c82abab71548bb1eaba8a0b2f7305e9ea862d5c96b1409009",
        "Options": null,
        "Scope": "local"
    }
]
```

这里 `"Mountpoint": "/var/lib/docker/volumes/4f80cc3ae270bf3c82abab71548bb1eaba8a0b2f7305e9ea862d5c96b1409009/_data"` 为本机的目录

NOTE: 如果您用的是 MacOS, 上面的目录是无法打开的, 因为docker在mac中, 是通过 VM实现的. 需要先进入VM, 再进去上述的地址. 进入 VM 的方式跟您的 Mac 版本和 Docker 的版本相关. 我的方式为 `screen ~/Library/Containers/com.docker.docker/Data/vms/0/tty`, 参考 StackOverflow 的这篇文章 [Where is /var/lib/docker on Mac/OS X](https://stackoverflow.com/q/38532483)

容器编排,服务发现和集群
----------------------
### 容器编排 DockerCompose

### 服务发现 Consul

### 集群 Swarm
