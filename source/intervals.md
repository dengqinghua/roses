音程
====

该文档涵盖了音程的相关知识.

阅读完该文档后，您将会了解到:

* 音程的概念.
* 音程的性质.
* 音程的练习代码.

--------------------------------------------------------------------------------

音程的概念
----------
两个音之间的关系称之为音程.

音程可分为:

- 旋律音程, 即两个音先后发生
- 和声音程, 即两个音同时发生

音程的性质
----------
### 音程和音数对应关系

```ruby
INTERVAL_BY_STEP = {
  0.0 => %w(U unison 纯一度),
  0.5 => %w(m2 minor_second 小二度),
  1.0 => %w(M2 major_second 大二度),
  1.5 => %w(m3 minor_third 小三度),
  2.0 => %w(M3 major_third 大三度),
  2.5 => %w(P4 perfect_fourth 纯四度),
  3.0 => %w(augmented_forth diminished_fifrth tritone A4 D5 TT 增四度 减五度),
  3.5 => %w(P5 perfect_fifth 纯五度),
  4.0 => %w(m6 minor_sixth 小六度),
  4.5 => %w(M6 major_sixth 大六度),
  5.0 => %w(m7 minor_seventh 小七度),
  5.5 => %w(M7 major_seventh 大七度),
  6.0 => %w(Oct octave 纯八度)
}
```

### 音程和音阶对应关系

```ruby
MAP = {
  U:  [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7]], # step: 0.0
  m2: [[3, 4], [7, 1]],                                         # step: 0.5
  M2: [[1, 2], [2, 3], [4, 5], [5, 6], [6, 7]],                 # step: 1.0
  m3: [[2, 4], [3, 5], [6, 1], [7, 2]],                         # step: 1.5
  M3: [[1, 3], [4, 6], [5, 7]],                                 # step: 2.0
  P4: [[1, 4], [2, 5], [3, 6], [5, 1], [6, 2], [7, 3]],         # step: 2.5
  A4: [[4, 7]],                                                 # step: 3.0
  D5: [[7, 4]],                                                 # step: 3.0
  P5: [[1, 5], [2, 6], [3, 7], [4, 1], [5, 2], [6, 3]],         # step: 3.5
  m6: [[3, 1], [6, 4], [7, 5]],                                 # step: 4.0
  M6: [[1, 6], [2, 7], [4, 2], [5, 3]],                         # step: 4.5
  m7: [[2, 1], [3, 2], [5, 4], [6, 5], [7, 6]],                 # step: 5.0
  M7: [[1, 7], [4, 3]]                                          # step: 5.5
  #Oct: [[...]],                                                # step: 6.0
}
```

音程的简单转换方式
------------------

操作  | 名称
----- | ----
纯音程, 大音程上增半音 | 增音程
纯音程, 小音程上减半音 | 减音程
增(减)音程上增(减)半音 | 倍增(减)音程

音程的和谐度划分
----------------

和谐度 | 音程
------ | ----
极和谐 | 纯一度, 纯八度
较和谐 | 纯四度, 纯五度
轻微不和谐 | 大小六度, 大小三度
不和谐 | 大小二度, 大小七度
极不和谐 | 增减音程

> 和谐程度和其音数有关系, 音程是否和谐, 体现在和声当中

Excercise1
----------
1. 弹奏各种音程(和声音程)
2. 给旋律配置自然音程(即无 #,b 的音程)
3. 给旋律配音程时, 应该配置下行走向音

```
   下行           上行
<------------- ------------->
1 2 3 4 5 6 7 1 2 3 4 5 6 7 1
```

Excercise2
----------
1. 音程音阶练习

```
三度: 1 3 2 4 3 5 4 6 5 7 6 1 7 2 1
四度: 1 4 2 5 3 6 4 7 5 1 6 2 7 3 1
五度: 1 5 2 6 3 7 4 1 5 2 6 3 7 4 1
六度: 1 6 2 7 3 1 4 2 5 3 6 4 7 5 1
七度: 1 7 2 1 3 2 4 3 5 4 6 5 7 6 1
...
```

复音程
------
超过八度即为复音程

复音程在去掉高低音的音程数上加七. 并保持原有的大小增减属性.

```
1- 2. 大九度 (大二度 + 7 = 大九度)
```

练习代码
--------
```shell
ruby pratice.rb

#
# Begin to guess interval
# == Guess 1 ==
# 6-3
#
```

参考文档
--------
http://www.guitarlessonworld.com/lessons/intervals.htm
