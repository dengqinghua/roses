Raft算法
=======

DATE: 2018-05-11

本文档总结了Raft的知识树.

阅读完该文档后，您将会了解到Raft算法的

* Status Change
* Leader Election
* Log Replication
* Append Entries

--------------------------------------------------------------------------------

Overview
-------
NOTE: 推荐这篇Paper: [In Search of an Understandable Consensus Algorithm](https://raft.github.io/raft.pdf)

- Leader Election
- Log Replication
- Safety

### Replicated state machine architecture
分布式数据一致性算法的一个经典的架构为 Replication state machine, 即

- 记录多个日志(Replicated Log)
- 维护了一个最终状态的状态机(State Machine).

任何一台服务器挂掉或者无法进行通信时,
新的服务器可通过日志进行数据的回溯和重算. 得到当前的最终的状态, 并代替原有服务器, 和client进行通信

![replicated_state_machine_architecture](images/replicated_state_machine_architecture.png)

Client 和 Server 通信的时候(上图中的步骤1), Server端会写log, 其中log记录的是 **数据的变化过程**, 并同步到多个机器中(步骤2),
存在一个状态机, 状态机保存的是数据的**最终结果**(步骤3), 状态机计算完结果之后, 将结果返回给Client通信成功(步骤4)

论文原文摘录:

> Keeping the replicated log consistent is the job of the consensus algorithm. The consensus module on a server receives commands from clients and adds them to its log. It communicates with the consensus modules on other servers to **ensure that every log eventually contains the same requests in the same order, even if some servers fail**. Once **commands** are properly replicated, each server’s state machine processes them in log order, and the outputs are returned to clients. As a result, the servers appear to form a single, highly reliable state machine.

NOTE: 在Kafka的[高可用策略](https://zhuanlan.zhihu.com/p/27587872)中, 也采用了相应的策略: Leader先写日志, 在成功同步到半数以上的Follower之后, 才返回给客户端ack.

Status
------
Raft算法每一个节点都有三个状态, 也可以认为是三种身份:

- Follower
- Candidate
- Leader

所有的交互都是跟 Leader 进行, 变化会写入 Leader 的log, 再进行 Log Replication, 采用的方式为 Append Entries.

状态变化如下图:

![raft_status_change](images/raft_status_change.png)

大型的分布式系统都会有一个 `replicated state machine`

> Large-scale systems that have a single cluster leader, such as GFS, HDFS, and RAMCloud, typically use a separate **replicated state machine** to manage leader election and store configuration information that must survive leader crashes. Examples of replicated state machines include Chubby and ZooKeeper.

Leader Election
---------------
### Overview
FLOW:
f=>operation: Follower
c=>operation: Candidate
l=>operation: Leader
f(right)->c(right)->l

FLOW:
init=>start: Follower无法接收到Leader的心跳
be_candidate=>operation: Follower变成Candidate
vote=>operation: Candidate
让剩下的nodes
进行Vote
reply=>operation: 其他的nodes进行vote
become_leader=>condition: Candidate
获取到大多数
nodes的投票
become_leader_yes=>operation: Candidate变成Leader
init->be_candidate->vote->reply->become_leader
become_leader(yes)->become_leader_yes
become_leader(no)->be_candidate

### 超时问题

### 同时变为Candidate

Log Replication
---------------

```
leader_write_log # 写日志(不提交)
leader_send_replicate # 复制节点, 发送给follower
leader_get_majority_of_followers_ack # 获得大多数的follower的确认可写入
leader_commit # leader 提交写入
leader_send_commit_signal_to_followers # 通知followers写入
```

Timeout Setting
----------------
### Election Timeout
Timeout 之后就换人, Vote for itself

### Heartbeat Timeout
利用 Append Entries 进行heartbeat

如果心跳不对了, 即 Follower 接收不到心跳, 则他成为一个 Candidate, 重新进行选举

什么都有可能失败, 同步超时了 或者 失败了, 应该如何处理?

References
----------
- [Raft](https://raft.github.io)
- [Raft Live](http://thesecretlivesofdata.com/raft/)
- [Raft Refloated: Do We Have Consensus?](https://www.cl.cam.ac.uk/~ms705/pub/papers/2015-osr-raft.pdf)
- [In Search of an Understandable Consensus Algorithm](https://raft.github.io/raft.pdf)
