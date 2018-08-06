Dengqinghua's Blog
===================

Hello, 这里是是邓擎铧的[技术blog](http://blog.dengqinghua.net/)源码.

该源码基于[Rails Guides](https://github.com/rails/rails/tree/master/guides), 主要记录了自己所学时的笔记, 总结和经验, 包括下面这些内容:

* 知识树和技术栈: 如何从0开始理解和学习一门语言.
* 吉他和Ukelele学习.
* 一些随想笔记.

--------------------------------------------------------------------------------

Usage
-----
### 安装环境
```shell
git clone https://github.com/dengqinghua/roses.git
cd roses
bundle install
```

### 编写markdown风格的文档
请参考[markdown格式实例](http://blog.dengqinghua.net/example.html)
将写好的文件放在 `source` 目录下

并在`source/documents.yaml`文件下编写目录.

### 生成html文件
执行脚本

```
./generate_guides
```

即可在`output`文件夹中生成对应的html代码, 其中output/index.html为入口文件.

源码内容简介
--------------
### 知识树
希望通过总结知识树, 可以让自己或他人更快地了解工作中需要的20%的技术知识点, 快速地根据原有自己的技术知识转化为新知识的生产力.

### 技术栈
希望通过总结技术栈, 可以了解计算机语言, 数据结构和算法的细节和本质.

### 吉他
本人是一名吉他爱好者(尤其是指弹) , 喜欢 Chet Atkins, George Benson, Tommy Emmanuel.

这里有一个关于音阶记忆练习的[小程序](https://github.com/dengqinghua/scales_practice)

### Ukulele
Hey! Ukelele!

### 随想笔记
这里什么都有

文章列表
--------
### 推荐
#### [基于内存数据库的角标系统设计](http://blog.dengqinghua.net/badge_system.html)

角标是公司最复杂的系统之一, 每次大促活动的时候, 角标承担着引流的重要责任, 是GMV的保证之一, 角标系统经过几年的演化, 已经变得非常复杂, 我们在近期对角标系统进行了整理和重构, 将角标系统变成了一个基于内存数据库和规则的数据计算系统.

#### [业务流引擎系统](http://blog.dengqinghua.net/witness_flow.html)

随着系统的日益演进, 系统的业务逻辑非常复杂, 尤其是在产品需求频繁变动的情况下, 研发需要不断地进行改动代码, 最终逻辑无人知晓. 为了让核心业务逻辑更清晰, 更快速地响应业务的变更, 我们研发了业务流引擎系统. 通过 代码 + 流程图配置 的方式, 将业务的复杂度变为引擎实现的技术难度.

### Ruby
#### [Ruby知识树](http://blog.dengqinghua.net/ruby_knowledge_tree.html)

开发Ruby和Rails需要了解的20%内容.

#### [Ruby数据模型](http://blog.dengqinghua.net/ruby_knowledge_tree.html)

Ruby的数据模型, 包括方法查找, 变(常)量查找, 作用域.

#### [Arel源码分析](http://blog.dengqinghua.net/arel.html)

基于AST和Vistor模式的arel源码分析, 本人第一遍英文版本的技术文档.

#### [Racc](http://blog.dengqinghua.net/racc.html)

Ruby版本的Yacc, 语法解析器.

#### [业务流引擎系统](http://blog.dengqinghua.net/witness_flow.html)

随着系统的日益演进, 系统的业务逻辑非常复杂, 尤其是在产品需求频繁变动的情况下, 研发需要不断地进行改动代码, 最终逻辑无人知晓. 为了让核心业务逻辑更清晰, 更快速地响应业务的变更, 我们研发了业务流引擎系统. 通过 代码 + 流程图配置 的方式, 将业务的复杂度变为引擎实现的技术难度.

#### [基于Sidekiq的异步任务管理引擎](http://blog.dengqinghua.net/sidekiq_task_event.html)

在系统中有一类常见的问题可抽象为: 批量处理n个任务, 每个任务都比较耗时, 希望可以快速地处理这些任务, 并且能知道每一个任务的执行结果情况. 基于这类问题模型, 我们研发了基于Sidekiq的异步任务管理引擎.

### Java
#### [数据结构](http://blog.dengqinghua.net/data_structures.html)

基于Java语言的数据结构整理.

#### [JVM剖析](http://blog.dengqinghua.net/learn_jvm.html)
JVM的一些知识点和总结.

#### [Concurrency](http://blog.dengqinghua.net/concurrency.html)
Java Concurrency的基本概念, ThreadPool源码分析

#### [Java知识树](http://blog.dengqinghua.net/java_knowledge_tree.html)

开发Java需要了解的20%内容

#### [命令行下的Maven](http://blog.dengqinghua.net/maven_under_command_line.html)

命令行下的maven, 可以大大提高开发效率, 减少对IDE的依赖.

#### [基于内存数据库的角标系统设计](http://blog.dengqinghua.net/badge_system.html)

角标是公司最复杂的系统之一, 每次大促活动的时候, 角标承担着引流的重要责任, 是GMV的保证之一, 角标系统经过几年的演化, 已经变得非常复杂, 我们在近期对角标系统进行了整理和重构, 将角标系统变成了一个基于内存数据库和规则的数据计算系统.

### MySQL
#### [MySQL知识树](http://blog.dengqinghua.net/mysql_knowledge_tree.html)

### Go
#### [GoInstallBinaries i/o timeout问题](http://blog.dengqinghua.net/go_get_timeout_solution.html)

#### [Go知识树](http://blog.dengqinghua.net/go_knowledge_tree.html)

Go的学习计划和相关知识树.

### 音乐
#### [音乐体系学习](http://blog.dengqinghua.net/music_index.html)
一些音乐系统学习资料汇总和索引

#### [City Of Star](http://blog.dengqinghua.net/lalaland-city_of_stars.html)
很喜欢 [爱乐之城] 这部电影, City of Stars为其中的原声音乐之一, 刚好在公众号看到了该曲子的吉他版本和Ukulele版本, 便参考和分析了一下歌曲的和弦走向, 和弦编配等.

#### [あの日の帰り道](http://blog.dengqinghua.net/あの日の帰り道.html)
#### [雨の日はワルツを踊って](http://blog.dengqinghua.net/rain_wwh.html)

#### [Es Ware Schon Gewesen](http://blog.dengqinghua.net/it_could_have_been.html)

### 杂记
#### [markdown格式实例](http://blog.dengqinghua.net/example_markdown.html)

Rails Guides风格的markdown模板.

#### [注释规范](http://blog.dengqinghua.net/comments.html)

我们在项目中使用的注释规范.

#### [零bug落地方案](http://blog.dengqinghua.net/best_programming.html)

可执行的软件开发实践的零bug落地方案.

#### [Memorize My Mentor](http://blog.dengqinghua.net/memorize_my_mentor.html)

纪念一位Mentor

#### [Rails服务的Java Thrift微服务迁移](http://blog.dengqinghua.net/microsystem_refactor.html)

面对日益复杂的业务系统和人员储备问题, 我们做了一个艰难的决定, 将原有的Ruby On Rails项目迁移为Java Thrift微服务, 对现有的业务系统进行了分析和重构, 并对业务微服务化之后的分布式事务一致性, 跨服务数据检索等提供了解决方案.

#### [Raft算法](http://blog.dengqinghua.net/raft.html)

分布式一致性算法Raft的论文阅读笔记.

Issues
------
如果您觉得有文章对您有启发, 或者有任何问题, 可以通过邮箱联系我: dengqinghua.42@gmail.com
