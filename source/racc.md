Racc
=====

DATE: 2018-05-11

这个是Racc的使用示例介绍.

阅读完该文档之后, 您将了解到:

* Rex和Racc的关系
* 如何使用Racc进行自定义

--------------------------------------------------------------------------------

Rex 和 Racc 的来源
------------------
### Yacc和Lexical
Racc和Rex分别来源于单词 [Yacc](https://en.wikipedia.org/wiki/Yacc) 和 `Lexical Analyser`

在我们定义一个语言的时候, 需要解决两个问题

1. 有哪些词汇(patterns)?
2. 有哪些语法(grammar)?

其中 Lexical 就是`词汇`的抽象, Yacc 就是`语法`的抽象

下面是一个语法解析的过程示例:

![racc_example](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/racc_example.png)

图片和对应的文档来源于[这里](http://epaperpress.com/lexandyacc/intro.html)

对应Racc和Rex, 也是做相同的事情, 仅仅是解析和定义的语言为Ruby, 所以用R开头

### Git地址
- [Racc](https://github.com/tenderlove/racc)
- [Rexical](https://github.com/tenderlove/rexical)

Rex
---
### 示例
在示例代码 [calculator.rex](https://github.com/dengqinghua/my_examples/blob/master/ruby/racc/calculator.rex) 定义了词汇

如规则

```ruby
macro
  DIGIT_MACRO     \d+

rule
  {DIGIT_MACRO} { [:DIGIT, text.to_i] }
```

表示的是 遇到了数字, 那么解析成 [:DIGIT, 数字] 的形式, 即

```
输入 1024, 解析为词汇 [:DIGIT, 1024]
```

为什么要有一个 `:DIGIT` 的标识呢? 是因为我们需要将相同属性的东西进行标记, 下一步进行语法申明的时候可以用到

NOTE: 参考: [a-tester-learns-rex-and-racc-part-1](http://testerstories.com/2012/06/a-tester-learns-rex-and-racc-part-1/)

Racc
----
### 示例
有了词汇之后, 我们就可以定义语法了.

在示例代码 [calculator.y](https://github.com/dengqinghua/my_examples/blob/master/ruby/racc/calculator.y) 定义了语法

```ruby
rule
  expression
    :
    DIGIT
    | DIGIT ADD DIGIT { return val[0] + val[2] }
    | DIGIT SUBSTRACT DIGIT { return val[0] - val[2] }
    | DIGIT MULTIPLY DIGIT { return val[0] * val[2] }
    | DIGIT DIVIDE DIGIT { return val[0] / val[2] }
end
```

一些注释如下

1. expression 仅仅是一个名词, 可以起名为abc, bcd都行, 他可以被复用, 即规则可以嵌套使用.  ":"后面是代表各种不同的情况, | 代表 或
2. DIGIT ADD SUBSTRACT 等, 均为 calculator.rex 中申明的词汇(patterns)
3. val是指匹配成功之后, 对应的值

    如字符串 `2 + 2`, 匹配到了 `DIGIT ADD DIGIT` 这部分, 则

    ```ruby
    val[0] = 2
    val[1] = "+"
    val[2] = 2
    ```

4. {} 表示的是ruby代码, 即如何处理该语法.

编译
---
编译的过程是生成ruby代码的过程, 包括 rex 和 racc 两部分

执行

```shell
rex calculator.rex -o calculator.rex.rb
racc calculator.y -o calculator.racc.rb
```

NOTE: 在这之前需要安装 racc 这个gem. 可以通过 `gem install racc` 进行安装

此时有一个 `calculator.racc.rb` 文件. 我们可以起一个pry进行测试

NOTE: 希望之后可以添加Rspec测试, 这样更加直观和规范

```shell
pry -r ./calculator.racc.rb
```

在console中输入

```ruby
Calculator.new.parse("2 + 2") #=> 输出 4
Calculator.new.parse("2 - 2") #=> 输出 0
Calculator.new.parse("2 * 3") #=> 输出 6
Calculator.new.parse("2 / 1") #=> 输出 2
Calculator.new.parse("2 | 1") #=> 抛出异常, 因为 | 无法解析: parse error on value 2 (DIGIT)
```

可以看到对应的结果.

References
----------
- [Lex and Yacc](http://epaperpress.com/lexandyacc/intro.html)
- [Rex-and-Racc](http://testerstories.com/category/language-building/rex-and-racc/)
