Arel Inspection
===============

DATE: 2015-07-15

This guide covers basic understanding of the Arel gem.

After reading this guide, you will know:

* How to use Arel to generate SQL string.
* How the Arel works in perspection of its source code.

-------------------------------------------------------

NOTE: This artical is inspired and collected by this [video](http://railscasts-china.com/episodes/kenshin54-source-code-analysis-arel). Thanks to [kenshin54](https://github.com/kenshin54).

What is Arel?
--------------
[Arel](https://github.com/rails/arel) is a SQL.
[AST](http://en.wikipedia.org/wiki/Abstract_syntax_tree)
manager for Ruby. It

1. Simplifies the generation of complex SQL queries
2. Adapts to various RDBMSes

INFO: Arel might be a short for ActiveRelation

Generate SQL string with Arel
-----------------------------

The method `Arel::Nodes::Node#to_sql` could generate SQL string.

NOTE: The gem `active_record` has required Arel gem, and the bind between
Arel and active_record is very close, because Arel needs a `engine` to work,
which is very confused to me.

```ruby
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter:  'mysql2',
  database: 'test',
  host:     'localhost',
  username: 'root',
  password: '1024'
)

user = Arel::Table.new('users')
arel = user.
  project('id', 'user_name').        # select
  where(user[:nick_name].eq('dsg')). # where
  order('created_at DESC').          # order
  skip(10).                          # offset
  take(5);                           # limit

sql = arel.to_sql
#=>
# SELECT  id, user_name FROM `users`
#   WHERE `user`.`nick_name` = 'dsg'
#   ORDER BY created_at DESC
#   LIMIT 5
#   OFFSET 10
```

When we get the sql, we can use `ActiveRecord::Base.find_by_sql(sql)` to get
the record.

WARNING: An ActiveRecord::Base.connection is needed here, but the generating-sql
progress is no business of the connecion.

Another example usage of Arel in Rails.

```ruby
#
#  SELECT `roles`.` FROM `roles`
#     WHERE(
#       `roles`.`id` < 10
#          AND `roles`.`id` > 0
#          OR  `roles`.`id` = 1024
#     )

t = Role.arel_table
Role.where(
  t[:id].
    lt(10).
    and(t[:id].gt 0).
    or(t[:id].eq 1024)
)
```

The Arel-SQL mapping
--------------------

To know the Arel-SQL mapping, we should first know two concepts:

  - Abstract Syntax Tree
  - SQL Design Pattern

### Abstract Syntax Tree
Abstract Syntax Tree is a tree representation of the abstract syntactic
structure of source code written in a programming language.

An example of AST can be as below:

```ruby
while b!=0 do
  if a > b
    a = a - b
  else
    b = b - a
  end
end

return a
```

![AST](images/AST.png)

### SQL Design Pattern
Take the `SELECT` part as an example:

INFO: The design comes from [SQL As Understood By SQLite](https://www.sqlite.org/lang_select.html)

  * select\_statement

  ![select-stmt](images/factored-select-stmt.gif)

  * select\_core

  ![select-core](images/select-core.gif)

The `SELECT` part can be seen as below:

    |-- SelectCore
    |   |-- Projections(id, user_name, ...)
    |   |-- Where
    |   |-- Group
    |-- Order
    |-- Limit
    |-- Limit
    |-- Offset

### Arel Design Pattern
Come back to the sql

```ruby
user = Arel::Table.new('users')
arel = user.
  project('id', 'user_name').        # select
  where(user[:nick_name].eq('dsg')). # where
  order('created_at DESC').          # order
  skip(10).                          # offset
  take(5);                           # limit
```

We can get the sql

```sql
  SELECT  id, user_name FROM `users`
    WHERE `user`.`nick_name` = 'dsg'
    ORDER BY created_at DESC
    LIMIT 5
    OFFSET 10
```

Arel gives a method to draw an AST image.

```ruby
File.write('arel.dot', arel.to_dot)
system %x(dot arel.dot -T png -o arel.png)
```

Then we get the map of Arel

  ![Arel-AST](images/arel.png)

From the AST, we know
* The concept of select\_statement and select\_core comes from
`SQL Design Pattern`
* The left, right branch concept comes from
`Abstract Syntax Tree`

Arel Source Code Inspection
---------------------------
TIP: Everything goes to the method: `to_sql`

An tiny example of sql transferring

```ruby
id    = Arel::Nodes::SqlLiteral.new('id')
count = id.count
count.to_sql
```

We could use pry's `show-method count.to_sql` to find the method

```ruby
# From: lib/arel/nodes/node.rb @ line 34:
# Owner: Arel::Nodes::Node
# Visibility: public
# Number of lines: 3

def to_sql engine = Table.engine
  engine.connection.visitor.accept self
end
```

To find the method `accept`, we should know the ancestor chain of
`Arel::Table.engine.connection.visitor`

```ruby
visitor = Arel::Table.engine.connection.visitor
visitor.class.ancestors
#=>
#
# [
#     [ 0] ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter::BindSubstitution < Arel::Visitors::MySQL,
#     [ 1] Arel::Visitors::BindVisitor,
#     [ 2] Arel::Visitors::MySQL < Arel::Visitors::ToSql,
#     [ 3] Arel::Visitors::ToSql < Arel::Visitors::Visitor,
#     [ 4] Arel::Visitors::Visitor < Object,
#     [ 5] Object < BasicObject,
#     [ 6] JSON::Ext::Generator::GeneratorMethods::Object,
#     [ 7] ActiveSupport::Dependencies::Loadable,
#     [ 8] PP::ObjectMixin,
#     [ 9] Kernel,
#     [10] BasicObject
# ]
```

```ruby
# Arel::Visitors::Visitor
def accept object
  visit object
end
```

The object here is `id.count`. Inspect the class of `id.count`
```ruby
id.count.class #=> Arel::Nodes::Count
```

Then we seek the `visit` method, which is the core of the Arel gem.

INFO: The **accept, visit** concepts come from the
[Visitor Pattern](http://en.wikipedia.org/wiki/Visitor_pattern),
while it's not the same with the traditional `Visitor Pattern`. Check this
[reference](http://web.info.uvt.ro/~oaritoni/inginerie/Cursuri/DesignPatterns/L7/Visitor/nordberg.ps.pdf)
if you are intersted.

```ruby
def visit object
  send dispatch[object.class], object
rescue NoMethodError => e
  raise e if respond_to?(dispatch[object.class], true)
  superklass = object.class.ancestors.find { |klass|
    respond_to?(dispatch[klass], true)
  }
  raise(TypeError, "Cannot visit #{object.class}") unless superklass
  dispatch[object.class] = dispatch[superklass]
  retry
end
```

Very intersting, just `send dispatch[object.class]`, that is

```ruby
send dispatch[Arel::Nodes::Count], object
#=> visit_Arel_Nodes_Count(id.count)
```

Finally, find the `visit_Arel_Nodes_Count` method

```ruby
# Arel::Visitors::ToSql
def visit_Arel_Nodes_Count o
  "COUNT(#{o.distinct ? 'DISTINCT ' : ''}#{o.expressions.map { |x|
  visit x
  }.join(', ')})#{o.alias ? " AS #{visit o.alias}" : ''}"
end
```

Go through more complexed sql

```ruby
user = Arel::Table.new('users')

arel = user.
  project('id', 'user_name').
  where(user[:nick_name].eq('dsg')).
  order('created_at DESC').
  skip(10).
  take(5);

arel.to_sql
```

Is there a simple way to create SQL strings?
--------------------------------------------
The AST, SQL Lang Pattern, Visitor Pattern may be a little complexed?
Maybe there is a simple way to create SQL strings as below:

```ruby
class NewArel
  attr_accessor :where, :select, :order, :skip, :limit

  def where(string)
    @wheres ||= []
    @wheres << string

    self
  end

  def select(*args)
    @selects ||= []
    @selects = @selects.concat(args).compact.uniq

    self
  end

  def order(string)
    @orders ||= []
    @orders << string

    self
  end

  # ... omited

  def to_sql
    [
      "SELECT #{@selects.join(', ')}",
      "WHERE #{@where.join('AND ')}"
    ].join(' ')
  end
end

arel = NewArel.new.
  where('id < 10').
  where('id > 5').
  select(:id, :user_name)

arel.to_sql
```

What's more about Arel
----------------------
- TreeManage
  * SelectManager
  * UpdateManager
  * InsertManager
  * DeleteManager
- visitors
  * mysql
  * sqlite
  * mssql
  * ....

Reference
---------
* [kenshin54-source-code-analysis-arel](http://pan.baidu.com/s/1hqDvjfu)
* [visitor-pattern-in-arel](http://web.info.uvt.ro/~oaritoni/inginerie/Cursuri/DesignPatterns/L7/Visitor/nordberg.ps.pdf)
* [visitor-pattern-and-double-dispatch](http://blog.bigbinary.com/2013/07/07/visitor-pattern-and-double-dispatch.html)
* [arel-guide](http://jpospisil.com/2014/06/16/the-definitive-guide-to-arel-the-sql-manager-for-ruby.html)
