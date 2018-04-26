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

GC
--
### 判断对象是否存活

| 算法 | 描述 | 优点 | 缺点 |
| -------- | ------ | ---- | --- |
| Reference Counting | 给对象添加引用计算器 | 简单 | 难以解决对象之间相互引用问题 |
| Reachability Analysis | 设置 GC root, 构造一颗树, 看一个对象是否和GC root相连 | 复杂,需要遍历整棵树 | 解决了相互引用问题 |

### 对象引用概念
> 我们希望能描述这样一类对象: 当内存空间还足够时, 则能保留在内存之中; 如果内存空间在进行垃圾收集后还是非常紧张, 则可以抛弃这些对象. 所以对象的引用不仅仅只有一种, 衍生出来了 Soft, Weak, Phantom 等形式

- StrongReference, 即 Object
- SoftReference
- WeakReference
- PhantomReference

### 垃圾收集算法
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

### HotSpot GC算法
#### 结构
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

NOTE: 各个Generation的内存分配比例默认为: **Young Generation** 中, **Eden** 和 **Survivor** 的默认比例为8:1, 可以通过 -XX:SurvivorRatio=8 进行设置,
而 **Old Generation** 和 **Young Generation** 比例为 2: 1, 可以通过 -XX:NewRatio=2 进行配置. 参考: [Java HotSpot VM Options](http://www.oracle.com/technetwork/java/javase/tech/vmoptions-jsp-140102.html)

### 内存分配和回收策略(Serial)
FLOW:
init=>start: 创建新的对象
toEden=>operation: 将对象放到Eden
checkFull=>condition: Eden full?
EdenGC=>operation: Young Generation GC(Minor GC)
包括Eden和Survivor区域
mark=>operation: 标记对象是否有引用
remove=>operation: 将还在引用的对象放入survivor区域:>#survivor-choose
survivorFull=>condition: survivor(0/1) full?
promotionCondition=>condition: 对象存活时间超过threshold:>#object-age
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

#### object age
JVM给了每一个对象一个Age计数器, 当对象在`survivor`经历一次`Minor GC`的时候, Age便加1
当Age达到threshold(默认为15, 通过-XX:MaxTenuringThreshold=15进行设置), 则会进行
`Promotion`

#### survivor choose
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

### GC触发条件
- Eden full(Minor)
- Tenured full(Major)
- System.gc(Major)

### Garbage Collectors
- Serial GC (Young: Copying, Old: Mark Compact)
- Paralle Scavange GC(Young(MultiThread): Copying, Old(SingleThread): Mark Compact)
- CMS, Concurrent Mark Sweep
- G1

#### CMS
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

### GC日志
参数设置

```
-XX:+DisableExplicitGC
-XX:+PrintGCDetails
-XX:+PrintGCApplicationStoppedTime
-XX:+PrintGCApplicationConcurrentTime
-XX:+PrintGCDateStamps
-Xloggc:gclog.log
-XX:+UseGCLogFileRotation
-XX:NumberOfGCLogFiles=5
-XX:GCLogFileSize=2000k
```

INFO: 如果是用 **maven exec:java** 来执行, 可以添加配置
```
export MAVEN_OPTS="-XX:+DisableExplicitGC -XX:+PrintGCDetails -XX:+PrintGCApplicationStoppedTime -XX:+PrintGCApplicationConcurrentTime -XX:+PrintGCDateStamps -Xloggc:gclog.log -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=5 -XX:GCLogFileSize=2000k -Xmx30M"
```

参考: [Enabling and Analyzing the Garbage Collection Log](https://dzone.com/articles/enabling-and-analysing-the-garbage-collection-log)

### GC研究工具
#### SDK自带工具
| 名称 | 描述 |
|    --------     |   ------   |
| jps | 查看当前所有的java进程 |
| jstat -gc | 查看当前gc情况, 包括GC情况, 新生代/老生代的内存占用情况等 |
| jinfo | 查看JVM的启动参数 |
| jstack | JVM的栈信息 |
| jconsole | JVM的可视化工具 |
| jvisualvm | 多合一故障处理工具 |
| jmap | 内存映象工具, heapdump |

下面仅仅对图形化工具 `jconsole` 和 `jvisualvm` 进行介绍, 并写一些 内存泄漏
和 线程死锁的例子.

#### 第三方工具
- [greys-anatomy](https://github.com/oldmanpushcart/greys-anatomy)
- [sysdig](https://github.com/draios/sysdig/)

class File
----------
INFO: 参考自[0xCAFEBABE ? - java class file format, an overview](https://blog.lse.epita.fr/articles/69-0xcafebabe-java-class-file-format-an-overview.html) , [JAVA BYTECODE STRUCTURE](https://www.csie.ntu.edu.tw/~comp2/2001/byteCode/byteCode.html) 和 [Understanding Jvm Internals](https://www.cubrid.org/blog/understanding-jvm-internals/)

### 架构图
SE7的架构如下: `Major Version: 0x0033`, 即51

![class_file_overview](https://cdn.rawgit.com/dengqinghua/roses/master/assets/images/class_file_overview.png)

### javap分析class文件
通过`javap`可以解析class文件

```shell
git clone https://github.com/dengqinghua/my_examples.git
cd my_examples/java
mvn compile
javap -v target/classes/com/dengqinghua/calculate/Salary.class
```

INFO: 如果想直接查看16进制的存储, 可以用shell命令: **xxd target/classes/com/dengqinghua/calculate/Salary.class**

如java源码为:

```java
package com.dengqinghua.calculate;

public class Salary {
    private int monthSalary;
    private int bonus;

    /**
     * 计算一年的总的薪水
     *
     * @return 返回总薪水值
     */
    public long calculateYearSalary() {
        return this.monthSalary * 12 + bonus;
    }

    public Salary(int monthSalary, int bonus) {
        this.monthSalary = monthSalary;
        this.bonus = bonus;
    }
}
```

解析后的class文件为

```shell
Classfile my_examples/java/target/classes/com/dengqinghua/calculate/Salary.class
  Last modified Apr 25, 2018; size 505 bytes
  MD5 checksum 57ea37e27fa44146cdcf54c9c532799d
  Compiled from "Salary.java"
public class com.dengqinghua.calculate.Salary
  minor version: 0
  major version: 52
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Fieldref           #4.#20         // com/dengqinghua/calculate/Salary.monthSalary:I
   #2 = Fieldref           #4.#21         // com/dengqinghua/calculate/Salary.bonus:I
   #3 = Methodref          #5.#22         // java/lang/Object."<init>":()V
   #4 = Class              #23            // com/dengqinghua/calculate/Salary
   #5 = Class              #24            // java/lang/Object
   #6 = Utf8               monthSalary
   #7 = Utf8               I
   #8 = Utf8               bonus
   #9 = Utf8               calculateYearSalary
  #10 = Utf8               ()J
  #11 = Utf8               Code
  #12 = Utf8               LineNumberTable
  #13 = Utf8               LocalVariableTable
  #14 = Utf8               this
  #15 = Utf8               Lcom/dengqinghua/calculate/Salary;
  #16 = Utf8               <init>
  #17 = Utf8               (II)V
  #18 = Utf8               SourceFile
  #19 = Utf8               Salary.java
  #20 = NameAndType        #6:#7          // monthSalary:I
  #21 = NameAndType        #8:#7          // bonus:I
  #22 = NameAndType        #16:#25        // "<init>":()V
  #23 = Utf8               com/dengqinghua/calculate/Salary
  #24 = Utf8               java/lang/Object
  #25 = Utf8               ()V
{
  public long calculateYearSalary();
    descriptor: ()J
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=1, args_size=1
         0: aload_0
         1: getfield      #1                  // Field monthSalary:I
         4: bipush        12
         6: imul
         7: aload_0
         8: getfield      #2                  // Field bonus:I
        11: iadd
        12: i2l
        13: lreturn
      LineNumberTable:
        line 13: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      14     0  this   Lcom/dengqinghua/calculate/Salary;

  public com.dengqinghua.calculate.Salary(int, int);
    descriptor: (II)V
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=3, args_size=3
         0: aload_0
         1: invokespecial #3                  // Method java/lang/Object."<init>":()V
         4: aload_0
         5: iload_1
         6: putfield      #1                  // Field monthSalary:I
         9: aload_0
        10: iload_2
        11: putfield      #2                  // Field bonus:I
        14: return
      LineNumberTable:
        line 16: 0
        line 17: 4
        line 18: 9
        line 19: 14
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      15     0  this   Lcom/dengqinghua/calculate/Salary;
            0      15     1 monthSalary   I
            0      15     2 bonus   I
}
SourceFile: "Salary.java"
```

如何理解上面这个文件呢?

java原始代码的这一行

```java
private int monthSalary;
```

对应着 class 文件的这一行:

```java
Constant pool:
   #1 = Fieldref           #4.#20         // com/dengqinghua/calculate/Salary.monthSalary:I
```

即字段 `monthSalary` 的定义.

- `#1` 代表索引, 通过该索引可以找到对应的数据
- `#4.#20` 代表 Fieldref 下对应的class和name_and_type的索引值, 即 class_index 和 name_and_type_index
  + `#4`为 **class_index**, 描述了她的class为 com/dengqinghua/calculate/Salary, 即 `com.dengqinghua.calculate.Salary`
  + `#20`为 **name_and_type_index**, 描述了字段的名称为: `monthSalary`, 字段的类型为 I, 即 int
- `com/dengqinghua/calculate/Salary.monthSalary:I` 为注释

比较难理解的是 `#4.#20` 部分. `#4` 是 `CONSTANT_Class` 索引, `#20` 是 `CONSTANT_NameAndType` 索引.

我们找到 class 文件的 `#4` 和 `#20` 部分如下:

```
#4  = Class              #23            // com/dengqinghua/calculate/Salary
#20 = NameAndType        #6:#7          // monthSalary:I
```

Fieldref 和其相关的数据结构为:

```java
// u1, u2 分别代表 1个字节, 2个字节

// 字段
CONSTANT_Fieldref_info {
    u1 tag;                 // 标识她的身份属性
    u2 class_index;         // 对应的 CONSTANT_Class 的索引
    u2 name_and_type_index; // 对应的 CONSTANT_NameAndType 的索引
}

// class 或者 interface
CONSTANT_Class_info {
  u1 tag;
  u2 name_index; // 对应的 字符串 CONSTANT_Utf8 的索引
}

// 字符串的表示
CONSTANT_Utf8_info {
  u1 tag;
  u2 length;
  u1 bytes[length];
}

// 标示一个字段或者一个方法
CONSTANT_NameAndType_info {
  u1 tag;
  u2 name_index; // 对应的 字符串 CONSTANT_Utf8 的索引
  u2 descriptor_index; // 对应的描述符标示, 对应的 字符串 CONSTANT_Utf8 的索引, 如 int 用 I 表示
}
```

在上面的 `CONSTANT_NameAndType_info` 中, descriptor_index 的值有下面这几种

| 名称   | 释义         |
| --- | ---          |
| B   | Byte         |
| C   | Char         |
| D   | Double       |
| F   | Float        |
| I   | int          |
| J   | long         |
| S   | short        |
| Z   | boolean      |
| V   | void         |
| L   | 所有的Object, 如Ljava/lang/Object |
| \[   | Array,如果是int[], 则表示为 \[I |
|  ()  | 方法描述, 如 Object method(int i, int[] j) 表示为 (I\[I)Ljava/lang/Object |

### Constant Pool
Constant Pool(常量池), 定义了Java中用到的常量, 包括总的常量数, 常量类型, 常量索引值等

![Constant_pool](https://cdn.rawgit.com/dengqinghua/roses/master/assets/images/Constant_pool.png)

### Access Flags
描述了可见性等参数

![access_flags](https://cdn.rawgit.com/dengqinghua/roses/master/assets/images/Access_flag.png)

### Fields
Fields为字段内容, 如上面提到的 `monthSalary`

```java
field_info {
  u2 access_flags; // 可申明多个flags, 如 public static int oneField;
  u2 name_index;
  u2 descriptor_index;
  u2 attributes_count; // attributes 的数目

  // 如果是常量, 如 final, 会存储在 attribute_info 中
  // 注意, 可变的初始化变量是不会存储在这儿的
  attribute_info attributes[attributes_count];
}
```

常量的数据结构为:

```java
ConstantValue_attribute {
  u2 attribute_name_index;
  u4 attribute_length;
  u2 constantvalue_index;
}
```

### Attributes
属性表可以认为是认为是基本的util, Filed, Method, Class 都会根据自己需要存储 Attribute

#### Code Attribute
下面是Code部分中的attribute

![Code_attribute](https://cdn.rawgit.com/dengqinghua/roses/master/assets/images/Code_attribute.png)

### Methods

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
