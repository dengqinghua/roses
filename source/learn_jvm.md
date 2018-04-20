JVM剖析
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
#### JVM
HotSpotJVMArchitecture
![HotSpotJVMArchitecture](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/HotSpotJVMArchitecture.png)

如果更细分地认识, 可以按照下面的方式划分:
![jvm_structure](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/jvm_structure.png)

#### Heap
![HotSpotHeapStructure](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/HotSpotHeapStructure.png)

### 对象的创建
内存分配方式:

- 指针碰撞 Bump the Point
- 空闲列表 Free List

上述跟GC的策略有关系

CMS基于`mark-sweep`, 通过使用的是 空闲列表

### GC
#### 判断对象是否存活

| 算法 | 描述 | 优点 | 缺点 |
| -------- | ------ | ---- | --- |
| Reference Counting | 给对象添加引用计算器 | 简单 | 难以解决对象之间相互引用问题 |
| Reachability Analysis | 设置 GC root, 构造一颗树, 看一个对象是否和GC root相连 | 复杂,需要遍历整棵树 | 解决了相互引用问题 |

#### 垃圾收集算法
1. Mark Sweep, 标记, 清除. 会产生大量的内存碎片, 可能会导致程序在分配内存时获取不到连续的内存空间, 而不得不进行第二次GC操作
2. Copying, 复制算法. 将内存按容量划分为两块, 每次只用其中的一块. 用完了就将存活的对象拷贝到另外一块, 再将原来的清除

Copying算法太耗内存, HotSpot的收集算法其实考虑到这一点, 调整了复制的比例. 所以产生了所谓的Eden, Survivor, Tenured等区域

#### 引用概念
> 我们希望能描述这样一类对象: 当内存空间还足够时, 则能保留在内存之中; 如果内存空间在进行垃圾收集后还是非常紧张, 则可以抛弃这些对象. 所以对象的引用不仅仅只有一种, 衍生出来了 Soft, Weak, Phantom 等形式

- StrongReference, 即 Object
- SoftReference
- WeakReference
- PhantomReference

JVM研究工具
----------
| jps | 查看当前所有的java进程 |
|    --------     |   ------   |
| jstat -gc <vmid> | 查看当前gc情况, 包括GC情况, 新生代/老生代的内存占用情况等 |
| jinfo <vmid> | 查看JVM的启动参数 |
| jstack <vmid> | JVM的栈信息 |
| jconsole <vmid> | JVM的可视化工具 |
| jvisualvm <vmid> | 多合一故障处理工具 |

下面仅仅对图形化工具 `jconsole` 和 `jvisualvm` 进行介绍, 并写一些 内存泄漏
和 线程死锁的例子.

References
----------
- [The Java Virtual Machine Specification, Java SE 8 Edition](https://docs.oracle.com/javase/specs/jvms/se8/jvms8.pdf)
- [深入理解Java虚拟机：JVM高级特性与最佳实践（第2版）](https://item.jd.com/11252778.html)
- [JVM公众号总结](https://mp.weixin.qq.com/s/sFnMxEwJiYRjwTiBIjfcZg)
- [JConsole](https://docs.oracle.com/javase/8/docs/technotes/guides/management/jconsole.html)
- [RunTime-DataArea](http://java8.in/java-virtual-machine-run-time-data-areas/)
- [Java Garbage Collection Basics](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html)
- [G1收集器与CMS收集器的对比与实战](http://blog.chriscs.com/2017/06/20/g1-vs-cms/)
