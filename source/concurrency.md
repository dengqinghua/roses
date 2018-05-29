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

### 源码分析
线程池简而言之是: **创建了多个线程, 来并行地处理一些任务, 任务可以并发地进行, 进程的数目, 存活状态都由线程池来管理和维护**

在 [Java Concurrency in Practice](https://www.amazon.com/Java-Concurrency-Practice-Brian-Goetz/dp/0321349601/ref=sr_1_1?ie=UTF8&qid=1526810637&sr=8-1&keywords=java+concurrency+in+practice) 一书中, 提到了 `Execution Policities`, 包括下面几点

- **What Thread** tasks will be executed
- **What Order** tasks will be executed(FIFO, LIFP, priority order)
- **How Many** tasks execute concurrently
- **How Many** tasks be queued pengding
- **Which Task** should be selected as a victim when system is overloaded and how the app be notified
- **What actions** should be taken before/after executing a task

使用线程池会带来很多新的问题, 如上所述. 所以说线程池其实是一种 `Resouces Mangement Tool`

#### Executors

在 concurrency 包中, 实现了下面的几种 `Executor`

- newFixedThreadPool
- newCachedThreadPool
- newSingleThreadExecutor
- newScheduledThreadPool

直观上理解为: thread数目固定, thread数目不固定, thread数目为1 和 定时thread 四种. 除了上述四种, 还有 newWorkStealingPool 和 unconfigurableExecutorService等

#### newFixedThreadPool
在 [示例代码](https://github.com/dengqinghua/my_examples/blob/master/java/src/main/java/com/dengqinghua/concurrency/ThreadPool.java#L33) 中使用了固定线程的线程池.

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

在上述示例中, 设置的 `THREAD_COUNT = 100`, 该线程池报名下面的部分:

TREE:
{
        text: { name: "Fixed Thread Pool Executor" },
        children: [
            {
                text: { name: "ThreadPoolExecutor" },
                children: [
                  { text: { name: "corePoolSize 100", title: "线程池中的线程数 即预先生成的线程的数目" } },
                  { text: { name: "maxPoolSize 100", title: "线程池中的最大线程数" } },
                  { text: { name: "keepAliveTime 0ms", title: "当线程数大于 corePoolSize 时, 超出的线程的最大空闲时间" } },
                  { text: { name: "LinkedBlockingQueue <Runnable>", title: "线程池所使用的队列" } }
                ],
            },
            {
                text: { name: "execute Runnable", title: "执行的命令" }
            }
       ]
}

#### ctl, Thread Pool Status and Worker Count
线程池的状态 有下面几种, 下面的内容摘抄自 JDK8.0

> The runState provides the main lifecycle control, taking on values:

TREE:
{
        text: { name: "Lifecycle" },
        children: [
            { text: { name: "RUNNING", title: "Accept new tasks and process queued tasks" } },
            { text: { name: "SHUTDOWN", title: "Don't accept new tasks, but process queued tasks" } },
            { text: { name: "STOP", title: "Don't accept new tasks, don't process queued tasks, and interrupt in-progress tasks" } },
            { text: { name: "TIDYING", title: "All tasks have terminated, workerCount is zero, the thread transitioning to state TIDYING will run the terminated() hook method" } },
            { text: { name: "TERMINATED", title: "terminated() has completed" } }
       ]
}

> **The numerical order among these values matters**, to allow
ordered comparisons. The runState monotonically increases over
time, but need not hit each state.

The transitions are:

```ruby
 RUNNING -> SHUTDOWN
    On invocation of shutdown(), perhaps implicitly in finalize()
 (RUNNING or SHUTDOWN) -> STOP
    On invocation of shutdownNow()
 SHUTDOWN -> TIDYING
    When both queue and pool are empty
 STOP -> TIDYING
    When pool is empty
 TIDYING -> TERMINATED
    When the terminated() hook method has completed
```

部分状态的源码如下:

```java
// 状态信息存储在第30位-第32位
int COUNT_BITS = Integer.SIZE - 3, // 29位
        CAPACITY = (1 << count_bits) - 1;

        int RUNNING = -1 << COUNT_BITS,       // 11100000000000000000000000000000 -536870912
                SHUTDOWN = 0,
                STOP = 1 << COUNT_BITS,       // 00100000000000000000000000000000 536870912
                TIDYING = 2 << COUNT_BITS,    // 01000000000000000000000000000000 1073741824
                TERMINATED = 3 << COUNT_BITS; // 01100000000000000000000000000000 1610612736
```

NOTE: -1在计算机中如何表示? 在这里是使用的是 [Two's Complement](https://www.cs.cornell.edu/~tomf/notes/cps104/twoscomp.html), 在 [这篇文章](http://www.ruanyifeng.com/blog/2009/08/twos_complement.html) 给出有趣的例子和证明. 假设现在有一个数 a, 则 `-a = ~a + 1`, 也就是取 a 的反码再加 1. 则 (假设是32位) -1 = ~00000000000000000000000000000001 + 1 = 11111111111111111111111111111110 + 1 = 11111111111111111111111111111111, 上述中的 running 变量为  11111111111111111111111111111111 << 29, 左移 29 位为: 11100000000000000000000000000000.

在 ThreadPoolExecutor 中, 非常重要的一个参数为 ctl, 在 JDK8.0 解释如下

> The main pool control state, ctl, is an atomic integer packing
two conceptual fields.
**workerCount**, indicating the effective number of threads
**runState**,    indicating whether running, shutting down etc

故从ctl中可以通过一些方法获取到 `workerCount` 和 `runState` 的信息, 而ctl的计算也将包括
`workerCount` 和 `runState` 的信息.

源码如下:

```java
// assertThat(Integeer.toBinaryString(CAPACITY), is("11111111111111111111111111111"));
// assertThat(Integer.toBinaryString(CAPACITY).length(), is(29));

// ctl 包含两部分: runState 为 第30位 至 第32位, workerCount 为 第1位 到 第29位
// 故获取 runState 只需要高位(30-32)信息 为 ctl & ~CAPACITY
// 故获取 workerCount 只需要低位(1-29)信息 为 ctl & CAPACITY

// 这里的 c 为 ctl, 该方法从 ctl 解析出当前的状态, 如 running/shutdown等
private static int runStateOf(int c)     { return c & ~CAPACITY; }

// 这里的 c 为 ctl, 该方法从 ctl 解析出当前的workerCount
private static int workerCountOf(int c)  { return c & CAPACITY; }

// rs 代表 runState, 如上所述的 running/shutdown/stop/tidying/termiated 等值
// wc 代表 workerCount
// 通过 rs 和 wc 得到 ctl 的值
private static int ctlOf(int rs, int wc) { return rs | wc; }
```

INFO: ctl 的生成, 源码中称为 pack, ctl 的解析, 称为 unpack.

NOTE: 思考: 为什么要有一个 ctl 这种值? 引入了 ctl 这个概念? 引入新概念的成本非常高, 而且也需要pack/unpack. 我的理解是如果直接使用
runState 和 workerCount, 那么他需要添加 synchronized 进行控制, 而不是简单地使得 runState 和 workerCount 变为 AtomicInteger, 而真实
的场景中, 这两个值是相互影响的, 与其每次都得添加 synchronized, 不如将这两个值绑定在一起.

```java
// 初始化值为 11100000000000000000000000000000 -536870912, 即 -2^29
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
// rs 代表 runState, 如上所述的 running/shutdown/stop/tidying/termiated 等值
// wc 代表 workerCount
private static int ctlOf(int rs, int wc) { return rs | wc; }
```

知道了 workerCount 和 runState 的计算和原子性设计之后, 便可知道基本的流程如下

FLOW:
fetchCtl=>start: 获取ctl
unpack得到
workCount, runState
workCountCondition=>condition: workerCount小于
corePoolSize
workCountConditionYes=>condition: runState: isRunning?
end=>end: 结束
workCountConditionYesRunning=>operation: 添加Worker :>#worker
fetchCtl->workCountCondition
workCountCondition(yes)->workCountConditionYes
workCountConditionYes(yes)->workCountConditionYesRunning
workCountConditionYes(no)->end
workCountCondition(no)->end

#### Worker

#### BlockingQueue
在 java.util.concurrency 中, 提供了一些并发使用的队列, 他里面有一些方法, 是专门为并发而设计的

- 插入操作
  + add    往队列里面插入一条记录, 成功返回true, 插入不成功将会报错
  + offer  往队列里面插入一条记录, 成功返回true, 插入不成功将返回false

References
----------
- [What is the difference between atomic/volatile/synchronized?](https://stackoverflow.com/a/9749864/8186609)
- [Thread Synchronization, monitorenter, monitorexit](https://www.artima.com/insidejvm/ed2/threadsynch.html)
