Concurrency In Java
===================

DATE: 2018-05-01

该文档涵盖了Concurrency的基本内容.

阅读完该文档后，您将会了解到:

* 线程安全问题.
* 内存的共享问题.
* 线程池设计.
* 线程模型.
* Java中的线程处理.

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

##### Java Atomic Package
关键词:

- CAS (cmpxchg instruction
- SpinLock

问题:

- ABA
- 循环时间长

参考: [聊聊并发（五）原子操作的实现原理](http://ifeve.com/atomic-operation/)

### Locking

### Thread
#### 状态
![threadLifeCycle](images/threadLifeCycle.jpeg)

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

#### 线程通信
为什么需要有 `WAITING` 状态, 是为了进行线程间的通信

##### Share Objects
线程/进程可以通过共享内存的某个值进行通信. 通过不停地轮询某个值, 来判断是否要进行处理某个业务逻辑. 伪代码如下

```java
while (!needHandle) {
    // doNothing
}

doThing
```

上面的方式会一直占有着CPU的时钟, 当会导致CPU的利用率很低


参考 [Thread Signaling](http://tutorials.jenkov.com/java-concurrency/thread-signaling.html)

##### Wait Notify and NotifyAll
wait, notify 和 notifyAll 为 Object 的方法, 故他们可以作用在所有的对象上.

wait方法会使得线程放弃CPU的控制权, 只到他被notify

注意一点, 这三个方法必须在 synchronized 里面使用, 否则会抛出 `IllegalMonitorStateException` 异常

NOTE: 为什么需要在 synchronized 里面使用? 在 [这篇文章](http://www.xyzws.com/Javafaq/why-wait-notify-notifyall-must-be-called-inside-a-synchronized-method-block/127) 和 [Stack Overflow](https://stackoverflow.com/questions/2779484/why-must-wait-always-be-in-synchronized-block) 中都有解释

References
----------
- [What is the difference between atomic/volatile/synchronized?](https://stackoverflow.com/a/9749864/8186609)
- [Thread Synchronization, monitorenter, monitorexit](https://www.artima.com/insidejvm/ed2/threadsynch.html)
