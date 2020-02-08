Java知识树
=========

DATE: 2018-03-19

该文档涵盖了Java从初级程序员至高级程序员, 最终成为系统架构师需要掌握的知识点.

阅读完该文档后，您将会了解到:

* Java的初级，中级，高级技巧.
* Web架构设计
* 设计模式，计算机原理，数据与数据结构等

--------------------------------------------------------------------------------

NOTE: 部分和[Ruby知识树](./ruby_knowledge_tree.html)重叠

提问的智慧
---------
如何提问很重要, 在学习任何知识之前, 需要先学会正确地提问.

- 提问的智慧原文: [这里](http://www.catb.org/~esr/faqs/smart-questions.html)
- 提问的智慧中文版本: [这里](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/master/README-zh_CN.md)

IDEA学习
------
### idea
[judasn/IntelliJ-IDEA-Tutorial](https://github.com/judasn/IntelliJ-IDEA-Tutorial)

### vim
- [ideavim](https://plugins.jetbrains.com/plugin/164-ideavim)
- [vim7.2学习手册](https://pan.baidu.com/s/1nvrC9Hf)

您可以参考或者使用我的[ideavimrc配置](https://github.com/dengqinghua/dotfiles#vim)

Linux操作
---------
建议推荐学习[鸟哥私房菜础篇](http://linux.vbird.org/linux_basic/)

### 基础命令
    ls
    history
    su/sudo
    mkdir/rmdir
    touch
    chmod
    chown
    apt-get/apt-cache,
    tar
    date
    cat
    cp
    mv
    pwd
    cd
    grep
    man,
    ps aux|grep
    kill/pkill
    whereis
    alias
    df/du
    rm
    echo
    diff
    wget
    ifconfig
    netstat
    top
    crontab
    scp
    curl
    tail -f
    ssh
    yum

关于每个命令的具体用法，可以查询下方给出的网站: [Linux命令便捷查询手册](http://linux.51yip.com/)。
需要了解linux的标准输入，标准输出，标准错误。

### 资料
* [Linux 新手应该知道的 26 个命令](https://linux.cn/article-6160-1.html)
* [41个Linux基础命令介绍--整理自鸟哥私房菜](http://blog.csdn.net/xiaoguaihai/article/details/8705992)
* [Linux命令便捷查询手册](http://linux.51yip.com)

git和git-flow
------------
### git
#### 常用命令
```shell
git --help

usage: git [--version] [--help] [-C <path>] [-c name=value]
           [--exec-path[=<path>]] [--html-path] [--man-path] [--info-path]
           [-p | --paginate | --no-pager] [--no-replace-objects] [--bare]
           [--git-dir=<path>] [--work-tree=<path>] [--namespace=<name>]
           <command> [<args>]

The most commonly used git commands are:
   add        Add file contents to the index
   bisect     Find by binary search the change that introduced a bug
   branch     List, create, or delete branches
   checkout   Checkout a branch or paths to the working tree
   clone      Clone a repository into a new directory
   commit     Record changes to the repository
   diff       Show changes between commits, commit and working tree, etc
   fetch      Download objects and refs from another repository
   grep       Print lines matching a pattern
   init       Create an empty Git repository or reinitialize an existing one
   log        Show commit logs
   merge      Join two or more development histories together
   mv         Move or rename a file, a directory, or a symlink
   pull       Fetch from and integrate with another repository or a local branch
   push       Update remote refs along with associated objects
   rebase     Forward-port local commits to the updated upstream head
   reset      Reset current HEAD to the specified state
   rm         Remove files from the working tree and from the index
   show       Show various types of objects
   status     Show the working tree status
   tag        Create, list, delete or verify a tag object signed with GPG
```

#### 问题
- Git的三颗树： `working dir`, `Index`, `HEAD`分别是什么？
- `git add`, `git commit`, `git stash` 做了什么操作，文件是如何标志和转移的？

#### 资料
- [Git简明指南](http://rogerdudler.github.io/git-guide/index.zh.html)
- [Git基础](https://git-scm.com/book/zh/v2/起步-Git-基础)
- [书籍: Git Pro 第一二三章](https://progit2.s3.amazonaws.com/zh/2015-09-10-63cab/progit-zh.823.pdf)
- [Git权威指南](http://pan.baidu.com/wap/shareview?&shareid=10796367&uk=3037357787&dir=%2FGit%26GitHub&page=1&num=20&fsid=1751268102&third=0)

### git-flow
#### 工作原理
- [git-flow](https://github.com/nvie/gitflow)
- [why-arent-you-using-git-flow](http://jeffkreeftmeijer.com/2010/why-arent-you-using-git-flow/)

#### 常用命令
- git flow init
- git flow feature start
- git flow feature publish
- git flow feature track
- git flow feature finish
- git flow release [start|publlish|track|finish]

#### 问题
- Git Flow 解决了什么问题, 其基本思想是什么?
- Git Flow中的分支从哪里而来，最后到哪里去?
- Git Flow中的命令和Git中的命令是如何对应的?

Java语言
--------
### 基础语法
- [Java Tutorial Point](https://www.tutorialspoint.com/java/index.htm)
- [Core Java](https://www.amazon.com/Core-Java-I-Fundamentals-10th/dp/0134177304)

### Maven
- [Maven FAQ](http://maven.apache.org/general.html)
- [Maven In 5 Minutes](http://maven.apache.org/guides/getting-started/maven-in-five-minutes.html)
- [Maven Get Started](http://maven.apache.org/guides/getting-started/index.html)
- [Maven Tutorial](https://www.tutorialspoint.com/maven/)
- [Maven Under Command Line](./maven_under_command_line.html)

### JUnit测试
- [JUnit Tutorial](https://www.tutorialspoint.com/junit/index.htm)
- [assertThat using Hamcrest Matcher](http://www.vogella.com/tutorials/Hamcrest/article.html)
- [Mockito](https://static.javadoc.io/org.mockito/mockito-core/2.16.0/org/mockito/Mockito.html)

#### JUnit5
TREE:
{
  text: { name: "JUnit5" },
          children: [
          { text: { name: "Platform" } },
          { text: { name: "Jupiter" } },
          { text: { name: "Vintage" } }
          ]
}

NOTE: 官方推荐第三方的 Assertion: `AssertJ`, `Hamcrest` 和 `Truth`, 在 spring-boot-starter-test 中, 引用了前两者

```bash
+- org.springframework.boot:spring-boot-starter-test:jar:2.2.1.RELEASE:test
|  +- org.junit.jupiter:junit-jupiter:jar:5.5.2:test
|  |  \- org.junit.jupiter:junit-jupiter-params:jar:5.3.2:test
|  +- org.mockito:mockito-junit-jupiter:jar:3.1.0:test
|  +- org.assertj:assertj-core:jar:3.13.2:test
|  +- org.hamcrest:hamcrest:jar:2.1:test
|  +- org.mockito:mockito-core:jar:3.1.0:test
|  |  +- net.bytebuddy:byte-buddy:jar:1.10.2:test
|  |  +- net.bytebuddy:byte-buddy-agent:jar:1.10.2:test
|  |  \- org.objenesis:objenesis:jar:2.6:test
```

### 类库
#### The Collection Framework
[Collection Reference](https://www.ntu.edu.sg/home/ehchua/programming/java/J5c_Collection.html)
![Collection_interfaces](images/Collection_interfaces.png)

NOTE: List, Stack 是Java常使用的数据结构, 在[Data Structures and Algorithm Analysis in Java](https://www.amazon.com/Data-Structures-Algorithm-Analysis-Java/dp/0132576279)这本书讲解了她的基本实现.

#### Java 8 Lambdas
- [Java 8 Lambdas](http://shop.oreilly.com/product/0636920030713.do)

NOTE: 个人觉得lambda表达式大大简化了Java, 建议阅读 Java 8 Lambdas 这本书

关键词:

- Optional
- Predicate/Consumer/Function/Runnable/Supplier/UnaryOperator/BinaryOperator
- Stream/filter/map/max/min/sort
- Default methods in Interface
- Method References
- peek(和ruby的tap很相似)

### JVM
[JVM剖析](./learn_jvm.html)

### Concurrency

代码规范
--------
- [阿里巴巴Java开发手册](https://github.com/alibaba/p3c/blob/master/%E9%98%BF%E9%87%8C%E5%B7%B4%E5%B7%B4Java%E5%BC%80%E5%8F%91%E6%89%8B%E5%86%8C%EF%BC%88%E7%BA%AA%E5%BF%B5%E7%89%88%EF%BC%89.pdf)

Spring
------
- [Spring Tutorial](https://www.tutorialspoint.com/spring/index.htm)

服务间通信
----------
- 设计原则及实例
- 接口
- 队列
  + kakfa

Web前端
------
* 浏览器：firebug、渲染模型
* html
* css
* javascript
* ajax
* 提高篇
  - Web流行框架
  - node
  - react
  - angular
  - vue

数据库
------
- 数据库表结构设计
- 如何建立高效索引
- 慢查询优化
- 主从
- 高可用

网络安全
---------
- 白帽子讲web安全
- 黑客攻防技术宝典
- 数据库注入
- XXS攻击

设计原则
--------
- Head first设计模式
- 重构
- 敏捷软件开发：原则、模式与实践

计算机基础
----------
- 操作系统
  + 深入理解计算机系统
- 算法结构
  + Java
  + 编程珠玑
  + 框架核心算法

HTTP协议
--------
- HTTP The Definitive Guide
- TCP/IP详解

缓存框架
--------
- 浏览器端
- CDN
- varnish
- nginx
- Redis

异步处理框架
----------
- Redis
- Kafka

搜索框架
--------
ElasticSearch

服务器框架
---------
- nginx
- passenger
