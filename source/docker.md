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

NOTE: 在mac上, docker 基于 virtualbox, 需要先生成一个本地的VM

```
docker-machine create --driver virtualbox default
```

#### IP和端口的映射关系

NOTE: 通过 `docker-machine ls`, 可以看到绑定的地址

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
