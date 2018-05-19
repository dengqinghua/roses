Concurrency In Java
===================

DATE: 2018-05-01

该文档涵盖了Concurrency的基本内容.

阅读完该文档后，您将会了解到:

* 线程安全问题.
* 锁的实现和线程通信模型.
* 线程池设计.

--------------------------------------------------------------------------------

Thread Safety
------------
> Stateless objects are always thread safe.

### Atomicity
#### Race Condition
> Reaching the desired outcome depends  on the relative timing of events.

Compound Actions:

- check then act (lazy  initialization)
- read modify write (increment i++)

需要使得两个线程有序执行

> Sequences of operations that must be executed atomically in order to remain thread safe

NOTE: Atomic类实现了原子化操作, 可以避免 Race Condition 她是无锁的, 而是用的[CAS, Compare and Swap](https://en.wikipedia.org/wiki/Compare-and-swap). 性能上比 synchronized 关键字要好, 我在 [这里](https://github.com/dengqinghua/my_examples/blob/master/java/src/test/java/com/dengqinghua/concurrency/AtomicKlassTest.java#L23) 写了Race Condition的例子, 分别用[atomic](https://github.com/dengqinghua/my_examples/blob/master/java/src/test/java/com/dengqinghua/concurrency/AtomicKlassTest.java#L66) 和 [synchronized](https://github.com/dengqinghua/my_examples/blob/master/java/src/test/java/com/dengqinghua/concurrency/AtomicKlassTest.java#L43) 避免了 Race Condition 的问题.

#### Java Atomic Package
关键词:

- CAS (cmpxchg instruction)
- SpinLock

问题:

- ABA
- 循环时间长

参考: [聊聊并发（五）原子操作的实现原理](http://ifeve.com/atomic-operation/)

Locking
-------
### Thread State
[![threadLifeCycle](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/threadLifeCycle.jpeg)](https://www.uml-diagrams.org/java-thread-uml-state-machine-diagram-example.html?context=stm-examples)

6个状态, 下面是从JDK8.0中摘抄的注释部分:

- NEW not yet started
- RUNNABLE executing in the Java virtual machine
- BLOCKED waiting for a monitor lock.
- WAITING called by `Object#wait()`, `Thread#join()` or `LockSupport#park()`
- TIMED_WAITING  WAITING with timeout, called by `Thread#sleep()`, `Object#wait()`, `Thread#join()`, `LockSupport.parkNanos` or `LockSupport.parkUntil`
- TERMINATED termiated

其中 BLOCKED 和 WAITING 的区别为:

```
BLOCKED 是在等待排他锁, 而 WAITING 是被调用了 `Object#wait()`, `Thread#join()` or `LockSupport#park()` 方法,
而处于等待状态, 并且可以通过 `notify` 或者 `notifyAll` 方法进行唤醒.
```

### 线程通信 Cooperate
为什么需要有 `WAITING` 状态, 是为了进行线程间的通信

#### Share Objects
线程/进程可以通过共享内存的某个值进行通信. 通过不停地轮询某个值, 来判断是否要进行处理某个业务逻辑. 伪代码如下

```java
while (!needHandle) {
    // doNothing
}

doThing
```

上面的方式会一直占有着CPU的时钟, 当会导致CPU的利用率很低

参考 [Thread Signaling](http://tutorials.jenkov.com/java-concurrency/thread-signaling.html)

#### Wait Notify and NotifyAll
wait, notify 和 notifyAll 为 Object 的方法, 故他们可以作用在所有的对象上.

wait方法会使得线程放弃CPU的控制权, 只到他被notify

注意一点, 这三个方法必须在 synchronized 里面使用, 否则会抛出 `IllegalMonitorStateException` 异常

NOTE: 为什么需要在 synchronized 里面使用? 在 [这篇文章](http://www.xyzws.com/Javafaq/why-wait-notify-notifyall-must-be-called-inside-a-synchronized-method-block/127) 和 [Stack Overflow](https://stackoverflow.com/questions/2779484/why-must-wait-always-be-in-synchronized-block) 中都有解释

### Monitor
在JVM内部, synchronized 是用 monitor 的概念实现的. Java 的 Monitor 实现了两种类型的 thread synchronized, `mutual exclusion` 和 `cooperation`, 即排他性 和 协作性.

```java
synchronized { // monitor region begin, 即 monitorenter
    doThingA;
    ...
}              // monitor region end, 即 monitorexit
```

Monitor的模型如下图所示

[![threadmonitor](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/threadmonitor.png)](https://www.artima.com/insidejvm/ed2/threadsynch.html)

- Entry Set: 所有等待锁的线程集合
- The Owner: 获得到锁的线程
- Wait Set: 处于 WAITING 状态的线程

一个线程获取锁的步骤如下:

FLOW:
goonedoor=>start: 线程 通过入口1
进入Entry Set
wantLock=>operation: 通过入口2
尝试获取锁
cond1=>condition: 获取成功
cond1yes=>operation: 进入 The Owner 区域
占有锁
cond1no=>operation: 留在 Entry Set 进行等待
lockavalable=>operation: 发现锁可被占用
finish=>operation: 在Owner区域处理完操作
conditonwait=>condition: 是否主动WAIT
conditonwaityes=>operation: 通过入口3
释放锁, 进入Wait Set区域
conditonwaitno=>operation: 通过入口5
释放锁, 退出
conditionnotify=>condition: 线程进行notify
conditionnotifyyes=>operation: Wait Set 通过入口4
尝试获取锁
end=>end: 退出
condwaitlock=>condition: 获取成功
condwaitlockyes=>operation: 进入 The Owner 区域
占有锁
condwaitlockno=>operation: 在 Wait Set 继续等待
goonedoor(right)->wantLock(right)->cond1
cond1(yes)->cond1yes->finish->conditonwait
cond1(no, left)->cond1no->lockavalable(left)->wantLock
conditonwait(yes, bottom)->conditonwaityes->conditionnotify
conditionnotify(yes, left)->conditionnotifyyes->condwaitlock
conditionnotify(no, right)->end
condwaitlock(yes)->condwaitlockyes
condwaitlock(no)->condwaitlockno
conditonwait(no)->end

NOTE: 上面的步骤也说明了: 一个线程如果要变成 WAITING (Object#wait, 不考虑sleep的情况) 状态, 必须要先进入
The Owner区域获取到锁, 再通过wait方法将锁释放进入Wait Set. 而 `Object#wait` 本身的定义是: 释放锁.
等待被notify, 那么在释放锁之前, 必须要先获得锁. 同样, `Object#notify` 的定义为: 通知Wait Set去获取锁,
那么在notify之前也必须要获得锁, 才能释放给Wait Set.

### Reentrancy
如果是嵌套的 synchronized , 如下所示:

```java
synchronized(this) {
    doSthA

    synchronized(this) {
        doSthA
    }
}
```

Java的锁设计成是可以重复进入的. 线程每次进入一个锁区域的时候 +1, 退出的时候 -1, 如果变为0, 线程则会释放锁

NOTE: 锁的时间尽量短而小, 不然会导致性能比较差

Sharing Objects
--------------

Thread Pool
----------
### Task Execution
- Serial

    单线程: 无法提高 Throughput, 响应缓慢

- Threads Without Limits

    线程的创建和销毁有开销
    线程会占用内存
    线程会占用文件资源(File Descriptor)

    无限制的创建线程容易导致CPU负载过高, 内存泄漏等

- Thread With Limits

    使用线程池, 预先生成线程, 线程个数有限, 可控制资源的占用情况

线程池的使用: [示例源码](https://github.com/dengqinghua/my_examples/blob/master/java/src/main/java/com/dengqinghua/concurrency/ThreadPool.java#L33)

```java
public class ThreadPool {
    private static final int THREAD_COUNT = 100;
    private static final Executor executor = Executors.newFixedThreadPool(THREAD_COUNT);
    public static void runMuiltThreadServerWithThreadPool() throws IOException {
        ServerSocket socket = new ServerSocket(10080);

        while (true) {
            final Socket connection = socket.accept();
            // 这里采用了线程池的方式
            executor.execute(() -> handleConnection(connection));
        }
    }
}
```

#### 源码分析

References
----------
- [What is the difference between atomic/volatile/synchronized?](https://stackoverflow.com/a/9749864/8186609)
- [Thread Synchronization, monitorenter, monitorexit](https://www.artima.com/insidejvm/ed2/threadsynch.html)
