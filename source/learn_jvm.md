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

### GC
#### 判断对象是否存活

| 算法 | 描述 | 优点 | 缺点 |
| -------- | ------ | ---- | --- |
| Reference Counting | 给对象添加引用计算器 | 简单 | 难以解决对象之间相互引用问题 |
| Reachability Analysis | 设置 GC root, 构造一颗树, 看一个对象是否和GC root相连 | 复杂,需要遍历整棵树 | 解决了相互引用问题 |

#### 对象引用概念
> 我们希望能描述这样一类对象: 当内存空间还足够时, 则能保留在内存之中; 如果内存空间在进行垃圾收集后还是非常紧张, 则可以抛弃这些对象. 所以对象的引用不仅仅只有一种, 衍生出来了 Soft, Weak, Phantom 等形式

- StrongReference, 即 Object
- SoftReference
- WeakReference
- PhantomReference

#### 垃圾收集算法
1. Mark Sweep, 标记, 清除. 会产生大量的内存碎片, 可能会导致程序在分配内存时获取不到连续的内存空间, 而不得不进行第二次GC操作
2. Copying, 复制算法. 将内存按容量划分为两块, 每次只用其中的一块. 用完了就将存活的对象拷贝到另外一块, 再将原来的清除
3. Mark Compact. 标记, 整理. Compact的意思是, 让存活的对象往一段移动, 避免大量的内存碎片
4. Generational Collection. 分代收集, 1,2,3的结合体, 在不同的情况采取不同的方式.

NOTE: 推荐阅读这篇文章: [Java Garbage Collection Basics](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html),
她讲述了GC收集算法是如何从最初的 **Mark Sweep** 到最后的 **Generational Collection**

FLOW:
day1=>operation: Mark Sweep
导致内存碎片
day2=>operation: Mark Compact
频繁地进行compacting
但是很多对象的存活时间很短
day3=>parallel: Copying
需要冗余内存
day4=>operation: Generational Collection
根据存活时间分为不同年代
不同年代的占比不同
没有内存碎片,冗余内存少
day1->day2->day3->day4

#### HotSpot GC算法
##### 结构
![HotSpotHeapStructure](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/HotSpotHeapStructure.png)

1. Young Generation
    - 新分配对象分配会存在这里
    - 该部分的GC收集为`Minor Garbage Collection`, 属于 `Stop the World Event`

2. Old Generation
    - 存放长期存活的对象(是否长期存活, 有对应的配置值, 从Young Generation转移过来)
    - 该部分的GC收集为`Major Garbage Collection`, 也属于 `Stop the World Event`

3. Permanent Generation
    - 存放Java的一些方法和Class, 可以认为是`Method Area`
    - 在`Full Garbage Collection`的时候, 会清理该部分

NOTE: 各个Generation的内存分配比例默认为?

#### 步骤
FLOW:
init=>start: 创建新的对象
toEden=>operation: 将对象放到Eden
checkFull=>condition: Eden full?
EdenGC=>operation: Young Generation GC(Minor GC)
包括Eden和Survivor区域
mark=>operation: 标记对象是否有引用
remove=>operation: 将还在引用的对象放入survivor区域:>#survivor-choose
survivorFull=>condition: survivor(0/1) full?
promotionCondition=>condition: 对象存活时间超过threshold
promotion=>operation: Promotion
对象由Young Generation变成Old Generation
被转移至Tenured区域
majorGCcheck=>condition: Tenured full?
majorGC=>operation: Old Generation GC(Major GC)
end=>end: 结束
init->toEden->checkFull
checkFull(yes)->EdenGC->mark->remove->survivorFull
checkFull(no)->end
survivorFull(yes)->promotion
survivorFull(no)->promotionCondition
promotionCondition(yes)->promotion

如果 `Old Generation` 区域, 即 `Tenured` 区域满了之后, 会触发 `Major GC`

##### survivor choose
我们知道有两个survivor区

![HotSpotHeapStructure](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/HotSpotHeapStructure.png)

S0和S1有一个为冗余内存, 类似于 `Copying` 算法的冗余内存, S0和S1始终有一块为空

处理步骤为:

FLOW:
init=>start: Minor GC
S0=>condition: S0为空
S0Yes=>operation: 将Eden和S1存活的对象放入S0中
S1Yes=>operation: 将Eden和S0存活的对象放入S1中
init->S0
S0(yes)->S0Yes
S0(no)->S1Yes

[Back](#%E6%AD%A5%E9%AA%A4)

NOTE: 为什么需要有两个区域? 我的理解是为了避免内存碎片问题, 在StackOverflow的 [这篇回答] (https://stackoverflow.com/a/10695418/8186609)中有解释.
另外, 拆分出两个区域可以使得算法变得更简单.

#### GC触发条件
- Eden full(Minor)
- Tenured full(Major)
- System.gc(Major)

#### Garbage Collectors
- Serial GC
- Paralle/ParalleOld GC
- CMS (Concurrent Mark Sweep)
- G1

##### CMS
FLOW:
Init=>start: Init
(Stop the World)寻找GC roots
Concurrent-Mark=>operation: Concurrent Mark
标记对象的引用状态
remark=>operation: Remark
(Stop the World)标记上一步引用状态变化的对象
sweep=>end: Sweep
Init->Concurrent-Mark->remark->sweep

参考: [Garbage Collectors - Serial vs. Parallel vs. CMS vs. G1 (and what’s new in Java 8)](https://blog.takipi.com/garbage-collectors-serial-vs-parallel-vs-cms-vs-the-g1-and-whats-new-in-java-8/)

NOTE: 吞吐量 Throughput 为 CPU用于运行用户代码的时间 / (运行用户代码的时间 + GC时间), 一般来说,
当 Generation 的空间变小之后, 一次GC的时间更快, 但是GC会更频繁, 这样的话在相同的时间内, GC的总时间
不一定会更快

JVM研究工具
----------
### SDK自带工具
| 名称 | 描述 |
|    --------     |   ------   |
| jps | 查看当前所有的java进程 |
| jstat -gc <vmid> | 查看当前gc情况, 包括GC情况, 新生代/老生代的内存占用情况等 |
| jinfo <vmid> | 查看JVM的启动参数 |
| jstack <vmid> | JVM的栈信息 |
| jconsole <vmid> | JVM的可视化工具 |
| jvisualvm <vmid> | 多合一故障处理工具 |

下面仅仅对图形化工具 `jconsole` 和 `jvisualvm` 进行介绍, 并写一些 内存泄漏
和 线程死锁的例子.

### 第三方工具
- [greys-anatomy](https://github.com/oldmanpushcart/greys-anatomy)
- [sysdig](https://github.com/draios/sysdig/)

References
----------
- [The Java Virtual Machine Specification, Java SE 8 Edition](https://docs.oracle.com/javase/specs/jvms/se8/jvms8.pdf)
- [深入理解Java虚拟机：JVM高级特性与最佳实践（第2版）](https://item.jd.com/11252778.html)
- [JVM公众号总结](https://mp.weixin.qq.com/s/sFnMxEwJiYRjwTiBIjfcZg)
- [JConsole](https://docs.oracle.com/javase/8/docs/technotes/guides/management/jconsole.html)
- [RunTime-DataArea](http://java8.in/java-virtual-machine-run-time-data-areas/)
- [Java Garbage Collection Basics](http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html)
- [G1收集器与CMS收集器的对比与实战](http://blog.chriscs.com/2017/06/20/g1-vs-cms/)
- [Java (JVM) Memory Model – Memory Management in Java](https://www.journaldev.com/2856/java-jvm-memory-model-memory-management-in-java)
- [Safepoint in HotSpot](http://blog.ragozin.info/2012/10/safepoints-in-hotspot-jvm.html)
