Java知识树
=========

DATE: 2018-04-11

该文档涵盖了JVM的一些知识点和总结.

阅读完该文档后，您将会了解到:

* JVM的一些比较好的参考资料.
* 通过一些例子来观察JVM的特性

--------------------------------------------------------------------------------

JVM内存区域
-----------
### 架构图
![jvm_structure](https://cdn.rawgit.com/dengqinghua/roses/master/assets/images/jvm_structure.png)

### 对象的创建
内存分配方式:

- 指针碰撞 Bump the Point
- 空闲列表 Free List

上述跟GC的策略有关系

CMS基于`mark-sweep`, 通过使用的是 空闲列表

JVM研究工具
----------
| --- | --- |
| jps | 查看当前所有的java进程 |
| jstat -gc <vmid> | 查看当前gc情况, 包括GC情况, 新生代/老生代的内存占用情况等 |
| jinfo -v <vmid> | 查看JVM的启动参数 |
| jstack <vmid> | JVM的栈信息 |
| jconsole <vmid> | JVM的可视化工具 |
| jvisualvm <vmid> | 多合一故障处理工具 |

下面仅仅对图形化工具 `jconsole` 和 `jvisualvm` 进行介绍, 并写一些 内存泄漏
和 线程死锁的例子.

### jconsole

References
----------
- [The Java Virtual Machine Specification, Java SE 8 Edition](https://docs.oracle.com/javase/specs/jvms/se8/jvms8.pdf)
- [深入理解Java虚拟机：JVM高级特性与最佳实践（第2版）](https://item.jd.com/11252778.html)
- [JVM公众号总结](https://mp.weixin.qq.com/s/sFnMxEwJiYRjwTiBIjfcZg)
- [JConsole](https://docs.oracle.com/javase/8/docs/technotes/guides/management/jconsole.html)
- [RunTime-DataArea](http://java8.in/java-virtual-machine-run-time-data-areas/)
