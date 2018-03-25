Rails服务的Java Thrift微服务迁移
===============================

DATE: 2017-07-28

面对日益复杂的业务系统和人员储备问题, 我们做了一个艰难的决定, 将原有的Ruby On Rails项目迁移为Java Thrift微服务, 对现有的业务系统进行了分析和重构, 并对业务微服务化之后的分布式事务一致性, 跨服务数据检索等提供了解决方案.

阅读完该文档后，您将会了解到:

* 为什么要拆分为微服务
* 服务拆分颗粒度分析
* 如何解决服务间的事物一致性问题
* 如何解决跨服的数据查询问题

--------------------------------------------

为什么要做基于Java的微服务化
---------------------------

> Rails is an APPLICATION, not a SYSTEM  ---- 亚历山大 K Liu

### Ruby生态圈问题
公司的其他核心服务是Java语言写的, 基于Dubbo的RPC Thrift框架, 服务之间的消息队列为kafak, 数据的汇总和收集使用的是Hive和ES.

对于Ruby而言, 上述技术相关的插件支持度不是很好, 对应的客户端也有很多问题, 为了解决上述问题, 我们不得不花大量时间去看源码, 并给插件打补丁, 降低了团队的整体的开发效率

### 跨服务的调用很难保证一致性
Rails虽然提供了很多AOP操作, 其中一些和事务相关, 如[after_save, after_commit, after_rollback](http://guides.rubyonrails.org/active_record_callbacks.html#transaction-callbacks), 但是我们的系统中, 一些核心业务是用Java写的, 服务之间通过RPC Thrift进行调用. 一个跨服务的例子为:

```ruby
class Activity
  ##
  # ==== Description
  #  创建商品
  #
  #  1. 创建活动基本信息
  #  2. 如果设置了优惠, 将调用优惠系统的接口, 将商品相关信息录入到优惠系统中 (优惠系统是另外一个java语言的系统)
  #  3. 保存优惠id至活动关联表中
  #
  def self.generate_activity(params)
    activity = create_activity(params) # 新创建一个活动

    if activity.has_set_discount?
      data = generate_discount_info(activity.id) # 调用外部接口, 创建优惠
      save_discount_id # 保存优惠id至关联表关系
    end
  end
end
```

上述是一个简单的例子, 如果一切都正常, 则商品表中正常存储了优惠的id, 优惠信息也成功录入至优惠系统中.

优惠系统慢慢演进之后, 我们发现了很多活动创建优惠失败了, 排查之后, 发现优惠添加了新的校验, 由于业务逻辑上使得优惠无法添加成功, 于是代码优化为:

```ruby
class Activity
  ##
  # ==== Description
  #  创建商品
  #
  #  0. 创建事务
  #  1. 创建活动基本信息
  #  2. 如果设置了优惠, 将调用优惠系统的接口, 将商品相关信息录入到优惠系统中 (优惠系统是另外一个java语言的系统)
  #  3. 保存优惠id至商品关联表中
  #
  def self.generate_activity(params)
    # 创建一个事务, 如果接口返回失败, 则整体回滚
    Activity.transaction do
      activity = create_activity(params) # 新创建一个活动

      if activity.has_set_discount?
        data = generate_discount_info(activity.product_id) # 调用外部接口, 创建优惠
        save_discount_id # 保存优惠id至关联表关系
      end
    end
  end
end
```

此时我们又发现一些bug: 优惠系统里面有该活动对应的商品id, 但是活动没有创建成功! 是因为

```ruby
save_discount_id
```

在保存discount_id的时候报错了, 导致了整个事务回滚, 但是接口部分的数据没有办法回滚, 依旧有数据不一致的情况

### 人员培养问题
随着Python, Go, NodeJS的流行, 业界中Ruby的使用者越来越少, 很多Rubyist都慢慢地转向了其他的语言. 从而使得招聘困难, 团队整体的压力变大, 不利于需求的快速响应和处理, 大量需求超期, 造成恶性循环.

### Java微服务优点

- 服务调用情况可以很好的被监控
- 服务可进行更好地进行降级和伸缩
- Java生态圈完善

服务拆分原则
-----------
### 减少服务之间双向调用
如果服务之间耦合紧密, 在一个方法中需要循环调用, 如

```java
  Service A#method1 -> Service B#method1 -> Service A#method2
```

服务A 调用 B 之后, B 再调用 服务 A, 这样如果其中一个出错, 整体进行回滚, 此时无法保证两个服务中三个表的整体的事务一致性.

所以对于上述这种情况, 我们选择将`A`和`B`合并为一个服务

### 对于统计类的数据服务抽离成单独的服务
一到月末, 年末的时候, 便会出现很多数据汇总, 邮件等需求, 该业务需求存活周期短, 响应要求高. 我们将这类的统计需求放在一个独立的服务中, 如

- 对账服务
- 绩效考核统计
- 卖家评分数据计算
- 管理员工作台数据

### 建立基础服务
在项目中, 对于一些常用的组件, 我们将他抽离成一个单独的基础服务, 如

- 服务监控
- 日志收集
- 一致性事务监控
- 工作流引擎

跨服务的事务一致性
-----------------
### 事务一致性表

```sql
sync_transactions | CREATE TABLE `sync_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `target_id` int(11) NOT NULL DEFAULT '0' COMMENT '业务系统的主键id',
  `target_type` int(11) NOT NULL DEFAULT '0' COMMENT '业务系统名称字典',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '处理状态：0-未处理 1-已处理',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_target_id_type` (`target_id`,`target_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='同步事务表'
```

我们使用一致性事务表来保证事务一致性, 对于强一致性的业务, 我们的处理步骤如下:

```ruby
class Activity
  def self.generate_activity(params)
    Activity.transaction do
      activity = create_activity(params) # 新创建一个活动

      if activity.has_set_discount?
        # 仅仅在事务中创建一条事务记录
        transaction = create_sync_transactions(activity.id, activity.name, stauts: "待处理")
      end
    end

    # 在事务外进行处理
    if activity.has_set_discount?
      begin
        data = generate_discount_info(activity.product_id) # 调用外部接口, 创建优惠
        save_discount_id # 保存优惠id至关联表关系
        transaction.set_status("处理完成")
      rescue
        Rails.logger.error("处理失败")
        push_to_transction_queue(transaction.id)
      end
    end
  end
end
```

我们创建了一条事务队列, 对于失败的事务, 会推入队列中处理, 如果在队列中失败多次, 则进行业务报警.

### 优缺点分析
#### 优点
- 将调用外部服务抽离出了MySQL的事务, 使得系统的事务变得更轻量, 性能更好
- 将事务的一致性问题转变为: 事务队列 + 重试报警. 一些逻辑上的问题可以预知, 并提前处理

#### 缺点
- sync_transactions表中增长非常快, 需要及时进行清理
- 在队列中轮询的时候要原有业务系统的数据状态, 可能会导致脏读和幻读的问题

跨服务查询
---------
### 例子
我们在业务系统中有一个这样的需求:

```
查询 卖家等级为 A, 而且 商品的 dsr < 5 的商品列表
```

我们拆分了微服务之后, `卖家的数据` 和 `商品的数据` 已经在不同的数据库实例了, 没有办法简单地进行关联查询.

可选择的方案为

```
1. 商品服务调用卖家服务接口, 或者卖家等级为A的所有卖家id: sellerIds = requestALevelSellersService
2. 查询所有的商品中, 卖家id为步骤1返回的数据:  SELECT * FROM products WHERE seller_id IN (sellerIds) LIMIT 20
```

这种方式可以查出数据, 但是存在下面几个问题

- IN 查询中, 查询的id太多, 性能很差
- 分页排序错乱

NOTE: 在数据中心出现之前, 我们经常拒绝该类需求, 而是通过异步导出的方式给业务方提供数据.

### 数据中心
我们建立了基于卖家平台的数据中心系统, 他实现了

- 定制数据视图和相应的字段
- 监控不同数据库实例binlog的变化, 同步更新数据到一个新的数据视图中
- 提供统一的查询接口

#### 优缺点
数据中心能解决跨服务查询的问题, 但是他存在一些问题

- 数据更新延迟
- ES的更新策略是基于乐观锁, 一些幻读和脏读可能导致数据不正确

但是总的来说, 我们将数据写入和数据查询剥离, 整体的复杂度降低了, 团队开发效率得到了极大的提升.
