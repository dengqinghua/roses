markdown格式实例
================

DATE: 2017-04-08

这个是您的文档简介.

阅读完该文档之后, 您将了解到:

* 您最想表述的观点1.
* 您最想表述的观点2.
* 您最想表述的观点3.

--------------------------------------------------------------------------------

主目录1
-------
### 标题1-1

内容XXX

NOTE: 这里是需要记录的点

INFO: 这里是提示的点

WARNING: 这个是需要提醒的点

这是代码块

```
Hey, do you know the dsg?
Yeah, I know: DSGV587!
```

#### 下一级标题1-1

### 标题1-2
#### 下一级标题1-2

内容XXX

主目录2
-------
### 标题2-1

内容XXX

NOTE: 这里是需要记录的点

INFO: 这里是提示的点

WARNING: 这个是需要提醒的点

#### 下一级标题2-1

### 标题2-2
#### 下一级标题2-2
```
# 吉他和弦图案
# 特殊符号: <C-K>开始
# ×  *X
# ₁  1s
# ₋  -s
# ₊  +s
# Ⅰ  1R 2160 8544 ROMAN NUMERAL ONE
# Ⅱ  2R 2161 8545 ROMAN NUMERAL TWO
# Ⅲ  3R 2162 8546 ROMAN NUMERAL THREE
# Ⅳ  4R 2163 8547 ROMAN NUMERAL FOUR
# Ⅴ  5R 2164 8548 ROMAN NUMERAL FIVE
# Ⅵ  6R 2165 8549 ROMAN NUMERAL SIX
# Ⅶ  7R 2166 8550 ROMAN NUMERAL SEVEN
# Ⅷ  8R 2167 8551 ROMAN NUMERAL EIGHT
# Ⅸ  9R 2168 8552 ROMAN NUMERAL NINE
# Ⅹ  aR 2169 8553 ROMAN NUMERAL TEN
# Ⅺ  bR 216A 8554 ROMAN NUMERAL ELEVEN
# Ⅻ  cR 216B 8555 ROMAN NUMERAL TWELVE

# SUBSCRIPT NUMBERS ZERO ~ NINE
₀
₁
₂
₃
₄
₅
₆
₇
₈
₉

# SUPERSCRIPT NUMBERS ZERO ~ NINE
⁰
¹
²
³
⁴
⁵
⁶
⁷
⁸
⁹

# 可以通过 :help digraph-table 查看所有的特殊字符

C和弦

×     o   o
-----------
| | | | ₁ |
-----------
| | ₂ | | |
-----------
| ₃ | | | |  Ⅲ
-----------
```

Mardown的扩展
-------------
### 五线谱
INFO: Thanks to [abcjs](http://abcjs.net)

NOTE: 使用教程: [Learn Abc](http://abcnotation.com/learn), [abc_notation](http://www.lesession.co.uk/abc/abc_notation.htm), [abc:standard](http://abcnotation.com/wiki/abc:standard:v2.1)

MUSIC:
X: 1
T: Cooley's
M: 4/4
L: 1/8
R: reel
K: Emin
|:D2|EB{c}BA B2 EB|~B2 AB dBAG|FDAD BDAD|FDAD dAFD|
EBBA B2 EB|B2 AB defg|afe^c dBAF|DEFD E2:|
|:gf|eB B2 efge|eB B2 gedB|A2 FA DAFA|A2 FA defg|
eB B2 eBgB|eB B2 defg|afe^c dBAF|DEFD E2:|

NOTE: Thanks to [abcjs](https://abcjs.net/)

```
MUSIC:
X: 1
T: Cooley's
M: 4/4
L: 1/8
R: reel
K: Emin
|:D2|EB{c}BA B2 EB|~B2 AB dBAG|FDAD BDAD|FDAD dAFD|
EBBA B2 EB|B2 AB defg|afe^c dBAF|DEFD E2:|
|:gf|eB B2 efge|eB B2 gedB|A2 FA DAFA|A2 FA defg|
eB B2 eBgB|eB B2 defg|afe^c dBAF|DEFD E2:|
```

### 和弦
INFO: Thanks to [chordy-svg](https://github.com/andygock/chordy-svg)

Em9: `3 7 #4 5 7`

CHORD: 02400x

```
CHORD: 02400x
```

### 流程图
INFO: Thanks to [flowchart](https://flowchart.js.org)

FLOW:
init=>start: Follower无法接收到Leader发出的
Heartbeat(即Election Timeout)
be_candidate=>operation: Follower变成Candidate
时间序列Term++
vote=>operation: Candidate
让剩下的nodes
进行Vote
reply=>operation: 其他的nodes进行vote
become_leader=>condition: Candidate
获取到大多数
nodes的投票
become_leader_yes=>operation: Candidate变成Leader
send_heartbeat=>end: 发送Heartbeat信息
停止其他节点的election
init->be_candidate->vote->reply->become_leader
become_leader(yes)->become_leader_yes->send_heartbeat
become_leader(no)->be_candidate

```
FLOW:
init=>start: Follower无法接收到Leader发出的
Heartbeat(即Election Timeout)
be_candidate=>operation: Follower变成Candidate
时间序列Term++
vote=>operation: Candidate
让剩下的nodes
进行Vote
reply=>operation: 其他的nodes进行vote
become_leader=>condition: Candidate
获取到大多数
nodes的投票
become_leader_yes=>operation: Candidate变成Leader
send_heartbeat=>end: 发送Heartbeat信息
停止其他节点的election
init->be_candidate->vote->reply->become_leader
become_leader(yes)->become_leader_yes->send_heartbeat
become_leader(no)->be_candidate
```

### 树形结构
INFO: Thanks to [Trent](http://fperucic.github.io/treant-js/)

TREE:
{
        text: { name: "Fixed Thread Pool Executor" },
        children: [
            {
                text: { name: "ThreadPoolExecutor" },
                children: [
                  {
                    text: {
                      name: "corePoolSize 100",
                      title: "执行任务的线程数. When a new task is submitted, and fewer than corePoolSize threads are running, a new thread is created to handle the request, even if other worker threads are idle"
                      }
                  },
                  {
                    text: {
                      name: "maxPoolSize 100",
                      title: "执行任务的最大线程数. If there are more than corePoolSize but less than maximumPoolSize threads running, a new thread will be created only if the queue is full"
                    },
                  },
                  { text: { name: "keepAliveTime 0ms", title: "当线程数大于 corePoolSize 时, 超出的线程的最大空闲时间, 在对队列进行poll的时候使用" } },
                  { text: { name: "LinkedBlockingQueue <Runnable>", title: "线程池所使用的队列" } }
                ],
            },
            {
                text: { name: "execute Runnable", title: "执行的命令" }
            }
       ]
}

```
TREE:
{
        text: { name: "Fixed Thread Pool Executor" },
        children: [
            {
                text: { name: "ThreadPoolExecutor" },
                children: [
                  {
                    text: {
                      name: "corePoolSize 100",
                      title: "执行任务的线程数. When a new task is submitted, and fewer than corePoolSize threads are running, a new thread is created to handle the request, even if other worker threads are idle"
                      }
                  },
                  {
                    text: {
                      name: "maxPoolSize 100",
                      title: "执行任务的最大线程数. If there are more than corePoolSize but less than maximumPoolSize threads running, a new thread will be created only if the queue is full"
                    },
                  },
                  { text: { name: "keepAliveTime 0ms", title: "当线程数大于 corePoolSize 时, 超出的线程的最大空闲时间, 在对队列进行poll的时候使用" } },
                  { text: { name: "LinkedBlockingQueue <Runnable>", title: "线程池所使用的队列" } }
                ],
            },
            {
                text: { name: "execute Runnable", title: "执行的命令" }
            }
       ]
}
```
