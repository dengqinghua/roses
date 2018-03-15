MySQL知识树
==========

DATE: 2017-08-20

该文档涵盖了成为MySQL专家所需要学习的知识.

阅读完该文档后，您将会了解到:

* MySQL基本命令.
* MySQL索引, 锁.
* 如何分析慢查询.
* MySQL规范
* 参考书籍

--------------------------------------------------------------------------------

MySQL基本命令
-------------

点击[这里](http://www.w3school.com.cn/sql/sql_quickref.asp), 查看示例

### 常用命令汇总
#### [DDL(Data Definition Language)](https://dev.mysql.com/doc/refman/5.6/en/innodb-create-index-overview.html#innodb-online-ddl-summary-grid)
- CREATE DB/TABLE
- ADD
- ALTER
- DROP
- TRUNCATE

#### [DML(Data Manipulation Language)](https://dev.mysql.com/doc/refman/5.7/en/sql-syntax-data-manipulation.html)
- SELECT
  * WHERE
  * AND/OR/UNION
  * ORDER BY
  * JOIN(INNER, LEFT, RIGHT, FULL)
  * DISTINCT
  * DATE
  * GROUP
  * HAVING
  * IN/BETWEEN/LIKE
  * COUNT
  * SUM
  * MIN/MAX
- INSERT
- UPDATE
- DELETE

### 其他
- IS NULL

MySQL索引, 锁
-------------
### 索引
- 创建索引 `CREATE INDEX`
- 唯一性索引 `CREATE UNIQ INDEX`
- 删除索引 `DELETE INDEX`
- 查看索引 `SHOW INDEX`

### 锁
- 读/写锁
- 事务, ACID
- MVCC
- 隔离级别
- 乐观/悲观锁
- 死锁
- 获取写锁, 释放写锁

分析慢查询
----------
广义的慢查询问题主要包括下面三个方面

- 单条sql语句查询时间超过100s
- 无法获取写锁
- 高并发下的脏读和脏写

下面主要介绍上述三种情况下可以考虑的解决方案

### sql语句优化
可考虑的优化思路为:

1. 将该sql移至从库
2. 使用 [EXPLAIN](http://dev.mysql.com/doc/refman/5.7/en/explain.html#idm140230885036768)
通过explain可以看到[执行计划](http://www.cnitblog.com/aliyiyi08/archive/2008/09/09/48878.html)

```sql
EXPLAIN for: SELECT `deals`.* FROM `deals`  WHERE ( deals.bg_tag_id > 0 ) AND `deals`.`id` = 1
+----+-------------+-------+-------+-----------------------------------------------+---------+---------+-------+------+-------+
| id | select_type | table | type  | possible_keys                                 | key     | key_len | ref   | rows | Extra |
+----+-------------+-------+-------+-----------------------------------------------+---------+---------+-------+------+-------+
|  1 | SIMPLE      | deals | const | PRIMARY,idx_bg_tag_pub_beg,idx_bg_tag_pub_end | PRIMARY | 4       | const |    1 |       |
+----+-------------+-------+-------+-----------------------------------------------+---------+---------+-------+------+-------+
1 row in set (0.02 sec)
```

其中最重要的几列有:

- 通过`key`列 查看 是否命中索引
key列显示MySQL实际决定使用的键（索引）。如果没有选择索引，键是NULL。要想强制MySQL使用或忽视possible_keys列中的索引，在查询中使用FORCE INDEX、USE INDEX或者IGNORE INDEX。
- 通过`rows`列 显示MySQL认为它执行查询时必须检查的行数。
- 通过`extra`列, 查看 MySQL解决查询的详细信息, 如果出现 `Using filesort` 或 `Using temporary`, 则需要优化查询

3. 根据第二步的执行计划, 可考虑添加相关索引.
4. 如果数据量过大, 添加索引无法解决问题, 则可以考虑分表.
5. 出现`like查询`或者`全文索引`等查询, 需要考虑用其他的方式来解决该慢查询, 如 Solr, EsSearch等

### 无法获取写锁
无法获取到写锁一般有两种情况:

1. 在事务中执行了更新操作, 获取到了写锁, 但是在事务中迟迟没有进行commit, 如

在 A 进程中, 对1024的deal进行了更新操作, 但是由于某个原因

```ruby
ActiveRecord::Base.transction do
  deal = Deal.find(1024)
  deal.pirce = 10.24
  deal.save

  ## 因为某种原因, 该进程被hang住了
  sleep(1000)
end
```

此时在 B 进程中, 对1024的deal再进行更新操作, 则获取不到写锁

```ruby
  deal = Deal.find(1024)
  deal.save # 抛异常: 等待写锁超时
```

2. [死锁](http://dev.mysql.com/doc/refman/5.7/en/glossary.html#glos_deadlock)

### 高并发下的脏读和脏写
该问题基本上是由于 Compare and Set 导致的，常见的场景为: 超卖

超卖的伪代码如下:

```ruby
if product.can_buy_count > 0
  product.can_buy_count = product.can_buy_count - 1
  product.save
end
```

当高并发的情况下, 上述代码将导致 商品 product 的 可买数目 can_buy_count < 0

解决上述的方法为: 添加行间锁, 并添加事务
