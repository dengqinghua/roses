二维码支付系统
==============

DATE: 2019-03-16

公交二维码支付系统包括 用户体系, 二维码支付 和 营销系统 三部分. 用户可进入app的公交模块, 通过扫二维码进行乘车. 围绕着用户拉新和留存, 我们推出了首次乘车支付返现, 红包抽奖 和 优惠券系统, 优惠月卡等营销活动, 完成了单个城市日单量过万的目标.

阅读完该文档后，您将会了解到:

* 支付系统的模块设计.
* 营销活动设计.
* 风控和安全.

--------------------------------------------------------------------------------

TL;DR
------
![pay-system](images/pay_system.png)

用户体系
-------
### 钱包
我们对每一个进入公交模块的人, 都会创建一个账户. 该账户成为用户的唯一标识.

在用户进行参加活动, 提现时, 会在钱包维度添加写锁, 再判断用户是否可以参加活动

如下面的参加活动的部分伪代码如下

```go
func (account *Account) participateActivity(db *gorm.DB, activityID int) error {
	// 判断用户是否达到参加活动的上限
	if account.ReachedActivityLimitCount(db, activityID) {
		return ActivityError(AlreadyParticipated)
	}

	// 开始一个事务
	return transaction(db, func(db *gorm.DB) error {
		// SELECT * FROM accounts WHERE id = 1 FOR UPDATE
		err := db.Set("gorm:query_option", "FOR UPDATE").
			Where(Account{ID: account.ID}).Find(&account).Error

		if err != nil {
			log.Debugf(fmt.Sprintf("ID: %v, msg: %v", account.ID, err.Error())
			return ActivityError(UnknownError)
		}

		// 再次判断用户是否达到参加活动的上限
		if account.ReachedActivityLimitCount(db, activityID, userRealID) {
			return ActivityError(AlreadyParticipated)
		}

		// 给用户添加金额
		account.Amount += activity.GivenAmount

		if err := db.Save(&account).Error; err != nil {
			log.Debugf(fmt.Sprintf("ID: %v, msg: %v", account.ID, err.Error())
			return ActivityError(UnknownError)
		}

		// 创建流水
		if err := CreatePayDetail(account, activity); err != nil {
			log.Debugf(fmt.Sprintf("ID: %v, msg: %v", account.ID, err.Error())
			return ActivityError(UnknownError)
		}

		return nil
	})
}
```

营销活动
--------
### 活动规则
活动规则可以抽象为

- 订单维度
- 用户维度
- 活动维度

我们通过建立了活动规则表, 将一些常用的配置项做成后台可以配置, 存储为 JSON 形式, 并在代码中进行解析和运算

### 风控和安全
#### 用户真身
什么是"真身"? 我们可以认为是这个用户的身份证的信息.

一个人可以拥有很多手机号, 也可以通过注销账号, 重新注册得到不同的 账号ID

我们的一些营销活动, 如: 首次乘车返5元现金. 这个 `5元现金` 是返给这个用户的真身, 也就是说, 我们存储 营销活动 和 用户的关系时, 需要存储用户的真身信息

| 用户ID   | 真身ID | 活动ID |
| -------- | ------ | ------ |
| 1234     | abc    | 1      |
| 1235     | abc    | 1      |

如上所示, 虽然用户ID 为 1234 和 1235 是两个用户, 但是他们拥有相同的真身ID, 假如活动限制了一个用户只能抽2次红包, 那么

```sql
SELECT COUNT(*) FROM accounts_activities WHERE real_id = abc
```

可以得知, 真身ID为 `abc` 的用户已经参加了2次活动, 不再具备抽奖的资格

#### 风控维度
对于一些核心的接口, 如发红包, 提现等, 需要有风控限制, 简单的风控包括下面几个维度:

1. IP访问限制
2. 用户ID访问频次限制: 1s内接口只能访问一次
3. 限制每个真身参与抽奖/抽优惠券的次数
4. 设置活动维度的每天的总库存/总金额
