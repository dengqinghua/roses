注释规范
========

DATE: 2016-09-01

该文档涵盖了文档注释的基本规范.

阅读完该文档后，您将会了解到:

* 注释的模板格式.
* 如何写注释.
* 写注释的注意事项.

--------------------------------------------------------------------------------

NOTE: 程序员最痛恨的两件事:
1. 别人的代码没有注释: WTF, 这行代码到底是什么意思?
2. 别人要求自己写注释: WTF, 我哪里有时间写注释?

NOTE: 写注释原则:
1. 沉住气;
2. 别急;
3. 慢慢写;
4. 写完后自己读一遍, 要能读通顺, 没有错别字, 意思要表达清楚.

注释的模板
----------
最重要的四个参数

- Description,    描述你的代码是做什么用的.
- Parameters,     代码所需要的参数是什么
- Usage/Examples, 举出调用的例子
- Returns,        列举出返回的内容的形式

INFO: 注释以`##`开始, 每一部分以空格分割, 注释的最后一行留空.

```ruby
class User < ActiveRecord::Base

  ##
  # ==== Description
  #   判断当前角色是否可以执行某个操作
  #
  # ==== Parameters
  #   auth_key|[auth_key1, auth_key2, ..., auth_keyn]
  #
  # ==== Examples
  #   User.first.can?(:view_1024)
  #   User.first.can?([:view_1024, :rock_roll])
  #
  # ==== Returns
  #   true|false
  #
  def can?(keys)
    # code implement
  end
end
```

Controller注释
--------------
Controller注释需要添加两点:

- Parameters 浏览器传入的参数, 这个非常重要
- URL        请求的地址

```ruby
##
# ==== Description
#   检查订单是否合法
#
# ==== Parameter
#   id: 订单编号
#
# ==== URL
#   POST /orders/:id/check
#
# ==== Returns
#   redirect_to|raise errors
#
def check
  # code implement
end
```
