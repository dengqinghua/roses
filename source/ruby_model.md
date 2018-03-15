Ruby对象模型
============

DATE: 2017-11-28

本文在语言层面上总结了Ruby的对象模型.

阅读完该文档之后, 您将了解到:

* Ruby的基本结构.
* Ruby的变量和常量.
* Ruby的方法查找.
* Ruby的作用域和作用域门.

--------------------------------------------------------------------------------

NOTE: 该文档并非详尽Ruby的一切特性, 而是希望能抓住Ruby本身的特性和迷人之处.

INFO: 推荐两本书: [Ruby metaprogramming](https://book.douban.com/subject/26575429/) 和 [Ruby Under a Microscope](https://book.douban.com/subject/24718740/)

Ruby基本结构
-----------
```ruby
String
Array
Hash
Numeric
Symbol
Object
```

### Symbol
如`:dsg`, symbol用于很多地方, 其很重要一点为: symbol在内存中仅存储一份.

```ruby
:dsg.object_id === :dsg.object_id #=> 返回true
```

而字符串不是.

```ruby
"dsg".object_id == "dsg".object_id #=> 返回false
```

变量和常量
----------
### 变量
#### 普通变量(local variable)
ruby的变量非常简单

如果上下文没有给一个陌生的'变量'赋值, 那么该'变量'不是'变量', 而是方法

```ruby
class User
  attr_accessor :name

  def set_name
    origin_name = name # name为方法, origin_name为变量
    self.name = "reseted #{name}" # name为方法, 重新赋值
  end
end
```

#### 实例变量(instance variable)
存储在对象中的变量, 如下面的 @score

```ruby
class User
  def initialize
    @score = 0
  end
end
```

#### 类实例变量(class instance variable)
ruby中一切都是对象, 类也是对象, 存储在类中的实例变量为类实例变量

```ruby
class People
  @alive = true
end
```

上述的 @alive 为People类的实例变量

NOTE: 类实例变量存储在该类中, 是不被子类共享的.

如

```ruby
class Man < People
end

Man.instance_variable_get(:@alive) #=> 输出是nil, 而不是@alive
```

#### 类变量(class variable)
类变量存在整个继承链中, 被所有继承的子类共享

```ruby
class People
  @@alive = true
end

class Man < People
end

Man.class_variable_get(:@@alive) #=> true

Man.class_variable_set(:@@alive, false)

People.class_variable_get(:@@alive) #=> false
```

INFO: Rails中关于类变量的应用: [mattr_accessor](https://github.com/rails/rails/blob/20c91119903f70eb19aed33fe78417789dbf070f/activesupport/lib/active_support/core_ext/module/attribute_accessors.rb)

#### 全局变量(global variable)
全局共享

```ruby
$DSG = "dsgv587"
```

### 常量
- 常量在内存中只存在一份
- 常量有[查找算法](http://guides.rubyonrails.org/autoloading_and_reloading_constants.html#class-and-module-definitions-are-constant-assignments)
- 如果查找不到该常量, 会走到**Module#const_missing**方法
- Rails通过复写const_missing方法, 使得常量的加载可以自动require该常量对应的文件
- 类名, module名都是常量

方法查找
--------
### 方法定义
在ruby中, 方法只能定义一次, 不支持类似于java中overloading机制.


如

```ruby
class User
  def get_name
  end

  def get_name(type)
  end
end
```

在User类中同时定义了两个同名方法 get_name, 在ruby中, 后定义的方法生效.


### 方法查找
#### ancestors
所有的方法查找都从当前的self对应的类的ancestor中去查找

如下面的例子所示:

```ruby
class People
  def name
    puts "People name"
  end
end

module MixinUser
  def name
    puts "MixinUser"
  end
end

class User < People
  include MixinUser

  def name
    puts "User name"
    super
  end
end
```


```ruby
User.new.name
#=>
User name
MixinUser
```

INFO: 该部分Ruby metaprogramming讲解地非常好. 请查看该书的第二章

方法查找方式

1. 获取所有的祖先链
```ruby
User.ancestors #=> [User, MixinUser, People, Object, Kernel, BasicObject]
```

2. 从祖先链依次遍历, 看其中是否有name方法, 如果是super, 则从祖先链的上一级去找

### 影响祖先链的因素
NOTE: 方法存在类里面

- prepend
- sigleton method
- self
- include
- super

最终如果找不到方法, 则去Object, Kernel, BasicObject找, 如果还找不到, 则进入method_missing方法

### 作用域和作用域门
INFO: 参见Ruby metaprogramming的第四章: Blocks-Blocks Are closures-Scope

三个作用域门(Scope Gates)

- Class definitions
- Module definitions
- Methods

即 `class`, `module`和`def`关键字

在metaprogramming中的例子如下:

```ruby
v1 = 1

class MyClass
  v2 = 2
  local_variables #=> [:v2]

  def my_method
    v3 = 3
    local_variables #=> [:v3]
  end

  local_variables #=> [:v2]
end

local_variables #=> [:v1]
```

NOTE: 可以其他方式打开作用域门, 即: define_method 代替 def, Class.new 代替 class, Module.new 代替 module

后记
----
个人理解中, Ruby是设计得非常好的, Ruby中遵循了[最小惊讶原则: principle of least surprise](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 理解了上面提到的Ruby的数据模型, 变量常量定义, 方法查找, 作用域之后, 基本上Ruby不会再给你其他的惊喜或者特殊的地方.

非常感谢[Paolo Perrotta](https://github.com/nusco), 您的`metaprogramming`给我们打开了Ruby的另一扇门, 让我们能理解到Ruby的精髓和奇妙之处, 也支撑着我们以后学习其他语言如Go, Elixir, Javascript等, 都会思考相同的问题:

- 语言的数据模型是什么?
- 变量和方法是如何定义和寻找?
- 变量的作用域是什么?
- 这些语言提供的特性Ruby有吗?

对比着学习一门语言, 可以让我们事半功倍, 让精通第二门, 第三门语言的时间越来越短, 也能真正地感受到编程之美.

另外一本我们非常喜欢的书为[Ruby Under a Microscope](https://book.douban.com/subject/24718740/), 从C源码分析了Ruby的类, 方法是如何实现的, 尤其是AST, GC部分的分析, 非常地深入浅出. 很值得大家一看.

TODO
----
- GC
- Thread
- Why ruby is slow compared with NodeJS or Java or C?
