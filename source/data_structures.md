数据结构
========

DATE: 2018-03-20

该文档涵盖了计算机基础的数据结构设计.

阅读完该文档后，您将会了解到:

* 基础的数据结构设计如 List, Queue, Stack.
* 基于基础数据结构之上的复杂结构如 Graph, Tree
* 数据结构的基本组成部分

--------------------------------------------------------------------------------

TL;DR
-----
### Java Collections
![Collection_interfaces](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/Collection_interfaces.png)

INFO: 推荐阅读[这篇文章](https://www.ntu.edu.sg/home/ehchua/programming/java/J5c_Collection.html), 了解Java(1.7)的Collections框架

WARNING: 源码基于 **1.8.0_144**

```shell
➜ java -version
java version "1.8.0_144"
Java(TM) SE Runtime Environment (build 1.8.0_144-b01)
Java HotSpot(TM) 64-Bit Server VM (build 25.144-b01, mixed mode)
```

List
----
1. 基础操作

|     操作  |  释义    |
|    ----   | ------   |
|    get    | 获取数据 |
|    set    | 设置数据 |
|    add    | 添加数据 |
|    remove | 移除数据 |
|    size   | 获取长度 |

2. Java中List的接口关系图

    ![Collection_interfacesList](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/Collection_ListImplementation.png)

NOTE: 为什么接口中要提供一个`iterator`? 我的理解包括下面几点: iterator 要求在获取数据的时候, List没有被修改, 否则就报错(`ConcurrentModificationException`), 这样相对更安全, 更多讨论请查看StackOverflow上的[讨论](https://stackoverflow.com/a/27984817/8186609)

### ArrayList
#### ArrayList implements Iterable
在 ArrayList 里面, 需要有一个 `iterator` 方法, 这里用到了 inner class

```java
public class MyArrayList<AnyType> implements Iterable<AnyType> {
    private AnyType[] theItems;

    public java.util.Iterator<AnyType> iterator() {
        return new ArrayListIterator<AnyType>();
    }

    private static class ArrayListIterator<AnyType> implements java.util.Iterator<AnyType> {
        private int current = 0;

        public AnyType next() {
            return theItems[current++];
        }

        // ...
    }
}
```

使用 inner class 的原因是: 我们在 inner class 里面可以获取当前对象的fields. 在这里是: `theItems`

#### ensureCapacity
List和数组最大的一个特点是不用设置长度

但是ArrayList是用 Array 来实现的, 每一个数组需要在初始化的时候就将长度设置好, 那 ArrayList 是如何做到的呢?

```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable {
    private static final int DEFAULT_CAPACITY = 10;

    private void ensureExplicitCapacity(int minCapacity) {
        modCount++;

        // 在这里判断容量不够用了, 就对容量进行增长
        if (minCapacity - elementData.length > 0) {
            grow(minCapacity);
        }
    }

    /**
     * Increases the capacity to ensure that it can hold at least the
     * number of elements specified by the minimum capacity argument.
     *
     * @param minCapacity the desired minimum capacity
     */
    private void grow(int minCapacity) {
        // overflow-conscious code
        int oldCapacity = elementData.length;
        int newCapacity = oldCapacity + (oldCapacity >> 1);
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // minCapacity is usually close to size, so this is a win:
        elementData = Arrays.copyOf(elementData, newCapacity);
    }
}
```

在上面看到了几个关键的方法

- ensureExplicitCapacity
- grow

在 grow 方法中, 可以看到关键的一行

```java
newCapacity = oldCapacity + (oldCapacity >> 1)
```

NOTE: >> 符号为[位移](http://www.cnblogs.com/hongten/p/hongten_java_yiweiyunsuangfu.html)操作, 可以看下[测试code](https://github.com/dengqinghua/my_examples/blob/master/java/src/test/java/com/dengqinghua/algorithms/QuickSortTest.java#L72)

新增的容量为原有容量的1.5倍

INFO: ArrayList能动态地增长长度, 当容量不够的时候, 会进行`grow`操作, 将所有的数据拷贝(Arrays.copyOf)到一个新的数组中, 并进行数组的扩容处理.

#### modCount
在Iterator的实现中, 有一个非常奇怪的变量: modCount, 源码中对她的解释为:

> The number of times this list has been <i>structurally modified</i>.
Structural modifications are those that change the size of the
list, or otherwise perturb it in such a fashion that iterations in
progress may yield incorrect results.

我们在源码中可以看到, 只要对该ArrayList进行任何操作, 都会修改这个值. 我的理解是 modCount 为 modifications count 的缩写, 即修改的次数. 它用在哪儿呢?

在 Iterator 中, 定义了一个 `expectedModCount`

```java
public class MyArrayList<AnyType> implements Iterable<AnyType> {
    private AnyType[] theItems;

    public java.util.Iterator<AnyType> iterator() {
        return new ArrayListIterator<AnyType>();
    }

    private static class ArrayListIterator<AnyType> implements java.util.Iterator<AnyType> {
        int expectedModCount = modCount;

        // ...
    }
}
```

expectedModCount 初始值为 modCount 的值, 如果发现 Iterator 对象在使用的时候, 发现两个值不相等, 则会抛出`ConcurrentModificationException`异常

INFO: modCount确保了在使用Iterator的过程中, 这个List没有被修改过. 在LinkedList也有相同的变量.

```java
final void checkForComodification() {
    if (modCount != expectedModCount) {
        throw new ConcurrentModificationException();
    }
}
```

#### 支持RandomAccess
她支持`RandomAccess`, 在 [二分法查找](https://github.com/dengqinghua/my_examples/blob/master/java/src/main/java/com/dengqinghua/algorithms/BinarySearch.java#L30) 的时候比 LinkedList 更加有优势

### LinkedList
![linkedList](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/linkedList.png)

#### Doubly Linked
在Java中, LinkedList是双向的, 他还实现了 [Deque](https://docs.oracle.com/javase/7/docs/api/java/util/Deque.html), double ended queue

在 数据结构中, 有一个 inner class: `Node`

```java
public class LinkedList<E> {
    private static class Node<E> {
        E item;
        Node<E> next;
        Node<E> prev;

        Node(Node<E> prev, E element, Node<E> next) {
            this.item = element;
            this.next = next;
            this.prev = prev;
        }
    }
}
```

其中包含`next`和`prev`两个field

#### Sentinel Nodes
- head node
- tail node

一些使用场景如下:

1. clearNode

    当清空该 LinkedList 的时候, 只需要设置

    ```java
    head.next = tail
    ```

2. addAll

    将两个LinkedList连接, 只需要直接处理 head 和 tail 即可

3. 查找某个位置的节点数据
    在源码中可以看到, 有了size, head 和 tail node, 如果要找位置index的node, 则可以判断 index 和 size 之间的关系:

    如果 index < size / 2, 则从head开始找, 否则从tail开始找

    ```java
        Node<E> node(int index) {
          // 如果 index < size / 2, 则从head开始找, 否则从tail开始找
          if (index < (size >> 1)) {
              Node<E> x = head;
              for (int i = 0; i < index; i++)
                  x = x.next;
              return x;
          } else {
              Node<E> x = tail;
              for (int i = size - 1; i > index; i--)
                  x = x.prev;
              return x;
          }
      }
    ```

#### 不支持RandomAccess
二分查找法的时候, 总的来说平均时间比 ArrayList 要慢. 在原生的Java的二分查找的时候, 对非RandomAccess的List做了不同的处理

```java
public class Collections {
    public static <T> int binarySearch(List<? extends T> list, T key, Comparator<? super T> c) {
        if (c==null)
            return binarySearch((List<? extends Comparable<? super T>>) list, key);

        if (list instanceof RandomAccess || list.size()<BINARYSEARCH_THRESHOLD)
            return Collections.indexedBinarySearch(list, key, c);
        else
            return Collections.iteratorBinarySearch(list, key, c);
    }
}
```

### LinkedList和ArrayList的使用场景
见 StackOverflow: [When to use LinkedList over ArrayList?](https://stackoverflow.com/a/322742/8186609)

INFO: 所经历的项目中没有使用过LinkedList.

Stack
------
![stack](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/stack.png)

Java8中用`Vector`来实现栈的数据结构

```java
class Stack extends Vector {}
class Vector extends AbstractList implements List, RandomAccess {}
```

|  操作  |  释义    |
| ----   | ------   |
| pop    | 出栈 |
| push   | 入栈 |
| size   | 栈的高度 |
| peek   | top data |
| size   | 获取长度 |

### Vector
#### elementData
Vector使用数组来存储数据

```java
class Vector {
    protected Object[] elementData;
}
```

和 ArrayList 类似, 她也有一个初始的容量 10:

```java
class Vector {
    /**
     * Constructs an empty vector so that its internal data array
     * has size {@code 10} and its standard capacity increment is
     * zero.
     */
    public Vector() {
        this(10);
    }
}
```

支持在容量不够的时候, 自动地`grow`. 实现方式和ArrayList类似, 这里不再重复

#### synchronized
Vector 有很多方法是添加了 `synchronized` 关键词.

```
class Vector {
    public synchronized void trimToSize() {}
    public synchronized void ensureCapacity(int minCapacity) {}
}
```

#### 官方不建议使用Vector
>  As of the Java 2 platform v1.2, this class was retrofitted to
implement the {@link List} interface, making it a member of the
Java Collections Framework.  Unlike the new collection
implementations, Vector is synchronized.  If a thread-safe
implementation is not needed, it is recommended to use ArrayList
in place of Vector.

建议用 ArrayList 替换 Vector

### 一些使用栈的场景
#### Balancing Symbols
检查一些符号, 如`(\['"` 是否封闭

算法思路: 以`()`的检测举例子, 遇到 `(` 的时候, 入栈, 遇到 `)` 的出栈. 最终在所有的符号都结束之后, 看下栈里面是否有数据, 如果有, 则说明`()`是未封闭的

```
(a == 1) && (b == 2)  // 检测通过
(a == 1) && (b == 2   // 检测不通过, 栈内还存在元素: (
```

Queue
-----
![queue](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/queue.png)

|  操作  |  释义    |
| ----   | ------   |
| pop    | 出队列 |
| push   | 入队列 |
| size   | 队列长度 |

核心fields:

- theItems 数组, 记录队列的值
- front    队列头的位置
- back     队列尾的位置
- size     队列长度

### Circular Array
可以使用环状的数组来存储Queue的数据. 初始化的时候, 而 back 的位置为 `N - 1`, front 的位置为 `N - k - 1`. 其中 N 为数组的长度, k 为初始队列的数据的个数

入队列, 则从数组的头开始. 入队列和出队列就是改变 front 和 back 的过程

空Queue的条件为

```
back = front - 1
```

另外, 还需要注意Queue满的情况,此时需要考虑扩容.

### Queue的Java实现
Java中, LinkedList实现了 Deque, Deque继承自Queue

```java
class LinkedList implements Deque {}
interface Deque extends Queue {}
```

NOTE: Deque: A linear collection that supports element insertion and removal at
both ends.  The name <i>deque</i> is short for "double ended queue"
and is usually pronounced "deck".  Most {@code Deque}
implementations place no fixed limits on the number of elements
they may contain, but this interface supports capacity-restricted
deques as well as those with no fixed size limit.

Tree
----
![tree](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/tree.png)

1. 基础概念

    |   名称    | 释义                                                              |
    |  ----     | ------                                                            |
    |  node     | 节点                                                              |
    |  edge     | 连接线                                                            |
    |  path     | 节点到节点之间的路径                                              |
    |  length   | path所经过的edge的个数                                            |
    |  root     | 根节点                                                            |
    |  depth    | 深度,是指从root节点到该节点经过某一个path的length.节点J的depth为2 |
    |  height   | 高度,是指节点到最远的一个leaf的length,节点E的hieght为2           |
    |  leaves   | 叶子节点                                                          |
    |  siblings | 兄弟节点                                                          |
    |  child    | 子树                                                              |
    |  preorderTraversal   | 前序遍历 ![pre_order_traversal](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/preorder_traversal.jpeg) |
    |  inorderTraversal    | 中序遍历 ![in_order_traversal](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/inorder_traversal.jpeg) |
    |  postorderTraversal  | 后序遍历 ![post_order_traversal](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/postorder_traversal.jpeg) |

### Binary Tree
![binary_tree](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/binary_tree.png)

#### 基本结构

- element
- leftNode
- rightNode

#### 使用场景
##### 表达式
将表达式转化为postfix形式, 再用栈创建一颗可以中序遍历的树

```
(a + b) * (c * (d + e))
```

利用栈, 转变为postfix形式:

```
a b + c d e + * *
```

利用栈, 转化为树.

NOTE: `a b + c d e + * *` 依次入栈, 遇到 a, b 创建树, 分别入栈, 遇到 `+` 将 `a, b` 出栈, `a, b, +` 组成一个新的树, 最终的树为下图所示. 最终可以通过中序遍历进行运算. 另外, 可以后序遍历恢复为 `a b + c d e + * *``

![tree_example](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/tree_example.png)

INFO: `Operand` 操作数, 如 a, b, c, d, e; `Operator` 操作符, 如 `+ *`

##### BST BinarySearchTree
- leftNode <= parentNode <= rightNode

一些重要的方法包括

```java
- .build              构建一棵树
- #insert             插入某个数字
- #remove             移除
- #contains           是否包含某个数字
- #preOrderTraversal  先序遍历
- #inOrderTraversal   中序遍历
- #postOrderTraversal 后序遍历
```

上述方法的实现请见例子: [BinarySearchTree](https://github.com/dengqinghua/my_examples/blob/master/java/src/main/java/com/dengqinghua/algorithms/BinarySearchTree.java) 和 对应的测试用例: [BinarySearchTreeTest](https://github.com/dengqinghua/my_examples/blob/master/java/src/test/java/com/dengqinghua/algorithms/BinarySearchTreeTest.java)

### AVL Tree
AVL (Adelson-Velskii and Landis), a balanced Tree

- Binary Tree
- 任何一个节点的左右子树的高度差的绝对值 <= 1

NOTE: depth: 深度,是指从root节点到该节点经过某一个path的length, height: 高度, 是指节点到最远的一个leaf的length

如下图所示, 只有 左边是 AVL Tree, 右边不是, 右边的 2 的高度为2, 8 的高度为0, 不满足 左右子树的高度差的绝对值 <= 1 的条件

![avl_tree](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/avl_tree.png)

平衡的情况包括四种

1. 左子树 的 左子树 插入 一个节点

    ```shell
     如下图 10 的 左子树 5, 插入 节点 1

                      20                     10
                10        30    ->       5        20
             5     15                  1        15   30
          1

     以20为节点, 向右旋转20的左节点10
    ```

2. 右子树 的 右子树 插入 一个节点

    ```shell
    如下图 30 的 右子树 40, 插入 节点 50

          20                           30
     10        30          ->    20         40
             25   40           10  25          50
                     50

    以20为节点, 向左旋转20的右节点30
    ```

3. 左子树 的 右子树 插入 一个节点

    ```shell
    如下图 10 的 右子树 15, 插入 节点 18

                  20                        15
         10             30    ->    10             20
       8    15                    8             18    30
              18

    分两步: 先按照case2旋转10, 再按照case1旋转20
    ```

4. 右子树 的 左子树 插入 一个节点

    ```shell
    如下图 30 的 左子树 25, 插入 节点 21

               20                     25
        10            30     ->    20    30
                   25    50      10 21     50
                21
    ```

算法代码: [这里](https://github.com/dengqinghua/my_examples/blob/master/java/src/main/java/com/dengqinghua/algorithms/AVLTree.java)

### B(+) Tree

> Disk accesses are incredibly expensive!

B 树的高度一般为3层左右, 通过一些冗余的搜索信息, 可以快速地进行数据的定位

- 数据存储在叶子节点中
- 非叶子节点保存搜索信息

#### B 和 B+ 的区别
参考这里 [Difference between B Tree and B+ Tree](http://www.differencebetween.info/difference-between-b-tree-and-b-plus-tree)


Map
---
![Collection_MapImplementation](images/Collection_MapImplementation.png)

### HashMap
Hash包含两个元素

- Hash Function
- Storage, 一般是Array

例子:

```java
Map<String, String> map = new HashMap<>();
map.put("ds", "v587");
```

上述过程的伪代码包括:

```java
mapInMemory = map.getMemory        // 预获取内存的一块区域
hashValue = hash("ds")             // 获取到一个内存地址
mapInMemory.set(hashValue, "v587") // 设置值
```

参考: [hashtable_and_perfect_hashing](https://www.cnblogs.com/gaochundong/p/hashtable_and_perfect_hashing.html)

#### Collision
当不同的key, 调用hash函数的时候, 返回的值相同([示例代码](https://github.com/dengqinghua/my_examples/blob/master/java/src/test/java/com/dengqinghua/EverythingTest.java#L42)), 这样的情况称为 Collision

```
hash("ds1") === hash("ds2")
```

尽量减少 Collision 情况的发生, 需要是的 hash() 不重复

在 [Data Structures and Algorithm Analysis in Java](https://www.amazon.com/Data-Structures-Algorithm-Analysis-Java/dp/0132576279/ref=sr_1_1?s=books&ie=UTF8&qid=1519441056&sr=1-1&keywords=Data+Structures+Algorithm+Analysis+java) 这本书书中, 介绍了两种处理冲突的方案

1. Separate Chaining

    用LinkedList存储Collision的数据

    NOTE: 一般来说, 会对 tableSize 进行 mod 运算, 作为数组的下标值

2. Open Addressing

    将数据按照某种方法存储在相邻的位置, 需要更小的`Load Factor`

    - Linear Probing
    - Quadratic Probing
    - Double Hashing

参考 [Hash Collision Probabilities](http://preshing.com/20110504/hash-collision-probabilities/)

#### Load Factor
真实的数据的个数/分配的内存区域的个数

在java中设置了一个 `DEFAULT_LOAD_FACTOR` 参数, 初始化 threshold = table.length * DEFAULT_CAPACITY
当 实际数据的size 大于 threshold 这个值, 说明内存区域不够了, 有更大地概率产生 collision, 故
需要进行rehash

NOTE: 尽量减少她rehash的概率, 如果确定了HashMap的Size, 可以在新建的时候就设置好

```
// 预先设置大小为 100
Map<String, String> map = new HashMap<>(100);
```

NOTE: Java中的 DEFAULT_LOAD_FACTOR 为 0.75, 初始的容量 DEFAULT_INITIAL_CAPACITY 为 16

建议阅读: [What is the significance of load factor in HashMap?](https://stackoverflow.com/q/10901752/8186609)

#### equals and hashCode
hashCode: 用于 hash 函数中

NOTE: 在String类中会有一个field为`hash`, 默认为0, 如果一个string被调用了hashCode方法,
该hash值会被自动赋值, 即使用 `String#hash` 做了hashCode的缓存.

equals: 在SDK中, 解决Collision的方式为 Chaining, 即使用一条链表来存储对应的冲突记录, 此时获取一个key对应的value时,
假如链表中有多个值, 则使用`equals`方法对 key 进行比对, 如果相等, 则取该key对于的value值返回

#### HashMap源码分析
FLOW:
initMap=>start: 初始化HashMap
initDatas=>operation: 设置相关参数:
capacity: 16
loadFactor: 0.75f
threshold: 16 * 0.75 = 12
table: Node<String, String>[16]
putView=>operation: hashMap.put("key", "dsgv587")
setHash=>operation: hash运算: hash("key"):>#hash-function
calculateI=>operation: 计算hash值对应的table中的位置i:>#table-index
cond1=>condition: 位置i不为空
cond1yes=>operation: table[i] = new Node("key", "dsgv587")
cond2=>condition: 检查key值冲突
cond2yes=>operation: 添加一个新的节点,
将原有节点放在该节点后面
trySplit=>operation: 如果发现位置i中的冲突的节点数大于
TREEIFY_THRESHOLD - 1 (7)
makeTree=>operation: 将冲突的所有节点变成一颗红黑树
cond2no=>operation: 更新该节点
isOverflowed=>condition: table已经使用的
size大于threshold
double=>operation: 进行resize
创建一个2倍容量的table
将原有的值rehash写入新的table:>#resize
initMap->putView->initDatas->setHash->calculateI->cond1
cond1(yes)->cond1yes->isOverflowed
cond1(no)->cond2
cond2(yes)->cond2yes->trySplit
trySplit->makeTree(right)->isOverflowed
cond2(no)->cond2no
isOverflowed(yes)->double

##### hash function
java的hash函数很有意思, `h >>> 16` 是指对h的指往右移16位, 然后再做异或门(XOR)操作, 这样做是为了让高位值分布更加均匀一些

```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```

>  Computes key.hashCode() and spreads (XORs) higher bits of hash
to lower.  Because the table uses power-of-two masking, sets of
hashes that vary only in bits above the current mask will
always collide. (Among known examples are sets of Float keys
holding consecutive whole numbers in small tables.)  So we
apply a transform that spreads the impact of higher bits
downward. There is a tradeoff between speed, utility, and
quality of bit-spreading. Because many common sets of hashes
are already reasonably distributed (so don't benefit from
spreading), and because we use trees to handle large sets of
collisions in bins, we just XOR some shifted bits in the
cheapest possible way to reduce systematic lossage, as well as
to incorporate impact of the highest bits that would otherwise
never be used in index calculations because of table bounds.

[Back](#hashmap源码分析)

##### table index
如何计算这个hash值在table中对应的index是什么呢? 代码如下:

```java
i = (table.length - 1) & hash
```

即取hash的低位, 比如初始化的table大小为 16,

假如 hash 函数的返回值为 9, 则 i 为 9

```
1111 & 1001 = 1001
```

假如 hash 函数的返回值为 18, 则 i 为 2

```
1111 & 1 0010 = 0010
```

NOTE: 在JDK的设计中, table.length 为 2的幂次方.

[Back](#hashmap源码分析)

##### resize
`resize` 会将hash的table的 threshold变为两倍: `newThr = oldThr << 1`.
容量capacity变成两倍: `newCap = oldCap << 1`.

NOTE: 这里设置了table的最大的threshold: `1 << 30`

部分源码如下:

```java
if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY && oldCap >= DEFAULT_INITIAL_CAPACITY) {
  newThr = oldThr << 1; // double threshold
}
```

[Back](#hashmap源码分析)

INFO: resize 在并发更新的时候, 可能会产生死循环(Before JDK 1.6), 见 [A Beautiful Race Condition](http://mailinator.blogspot.com/2009/06/beautiful-race-condition.html) 和 [Infinite Loop in Hashmap](http://javabypatel.blogspot.in/2016/01/infinite-loop-in-hashmap.html)

NOTE: 阅读源码真的获益匪浅, 学到很多位操作如: `^`, `>>>`, `<<` 和 `++size > threshold` 等,
惊叹一些代码的简洁性. Hash算法本身不难, 但是很精妙, 该部分只是涉及到了HashMap的很小一部分,
关于`Object#hashCode()`方法, 有时间的时候还需要再研究一下.

Hash部分的FAQ可以参考: [HashMap Interview Questions](http://www.javarticles.com/2012/11/hashmap-faq.html)

### ConcurrentHashMap

NOTE: ConcurrentHashMap 不允许 **null** 作为 Key和Value

ConcurrentHashMap 和 HashMap 的处理逻辑类似, 但是为了解决并发写入的问题, 引入了ConcurrentLevel的概念

#### ConcurrentLevel
ConcurrentLevel 设置了同时更新该map的参考线程数. 默认值为: 16

#### ~~Segement(1.7版本, 已过时)~~
如果以Segement的角度来看待ConcurrentHashMap, 结构如下
![concurrencyHashMap](images/concurrencyHashMap.png)

可以看做 Segement 是将Map的数据进行打散并重新分配, 类似于算法中的 [Divide and Conquer](https://en.wikipedia.org/wiki/Divide_and_conquer_algorithm)

每一个Segement都持有自己的lock, 故不同的Segement更新互不干扰的.

INFO: 另外一种Map的数据结构: **Hashtable**, 她的相关操作都是添加了 **synchronized** 关键词的, 是整个table都添加了锁.
下图是 Hashtable 和 ConcurrentHashMap 的获取锁的对比图

![lock_compare](images/lock_compare.png)

参考: [How-does-segmentation-works-in-ConcurrentHashMap](https://www.quora.com/How-does-segmentation-works-in-ConcurrentHashMap)

更新: Java8 去掉了 Segement 的概念, 将锁加在了bucket维度, 也即是node维度, 部分代码如下:

```java
public class ConcurrentHashMap {
    /** Implementation for put and putIfAbsent */
    final V putVal(K key, V value, boolean onlyIfAbsent) {
            if (key == null || value == null) throw new NullPointerException();
        int hash = spread(key.hashCode());
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;

            // 中间代码省略...

            // 获取到节点
            f = tabAt(tab, i = (n - 1) & hash);

            // 更新节点
            synchronized (f) {
            }
    }
}
```

#### Volatile Read
ConcurrentHashMap 的 读是`lock-free`的, 她使用了volatile 关键字保证了内存可见性, 如下面的定义Map的节点的结构为

```java
public class ConcurrentHashMap {
    static class Node<K,V> implements Map.Entry<K,V> {
        final int hash;
        final K key;
        volatile V val;
        volatile Node<K,V> next;
}
```

关于读写锁的问题, 参考[ConcurrentHashMap read and write locks](https://stackoverflow.com/q/16105554/8186609)

关于 HashMap, ConcurrentHashMap 和 Hashtable 的区别, 可参考这里 [Popular HashMap and ConcurrentHashMap Interview Questions](https://howtodoinjava.com/interview-questions/popular-hashmap-and-concurrenthashmap-interview-questions/)

Bloom Filter
------------
布隆过滤器 经常使用与 黑名单过滤 的场景, 黑名单中的数据一定不会漏过, 但是有可能会误判. 属于 `宁可错杀, 不放过` 的过滤器.

题目如下:

```
现在有 100亿 个黑名单URL, 一个URL的长度为64B, 需要判断一个 URL 是否在黑名单中, 允许万分之一的误判率, 使用空间不超过30G
```

如果直接使用Hash算法, Key 和 Value 大概占有 64B, 100亿则为 640GB, 不满足空间要求. 在一定的误判率下, 可以使用 [Bloom Filter](https://en.wikipedia.org/wiki/Bloom_filter)

她的思路如下:

1. 数据准备

    1. 将 10亿 个数据源, 通过 K 个 HashFunction 计算出结果
    2. 设计一个长度为 M(M > N) 的 Array, 数据里面的类型都是 bit, 只有0和1两个取值
    3. 将 1 的计算结果对 M 取余(%M), 将获取到的值, 对应为数字的坐标, 设置对应的值为1

![bloom-filter](images/bloom-filter.png)

2. 判断是否是黑名单URL

    1. 将待查的 URL, 通过 K 个 HashFunction 计算出结果
    2. 将 1 的计算结果对 M 取余(%M), 将获取到的值, 去 Array 中按照坐标查询
    3. 如果有一个值为0, 则说明不在黑名单中. 如果全部为1, 则认为在黑名单中

### 基本元素
- Input n
- bitArray m
- HashFunction k

### 误判问题
由于 HashFunction 算出来的值是有可能产生 collision 的, 所以可能存在有一个 URL 不在黑名单, 但是通过 K 和 HashFunction
计算之后, 对应到 bitArray 中, 所有的值都为1

### 最优解
可以通过 N 和 可容忍的误判率 P, 计算合理的 M 和 K 值, 详情见[这里](https://en.wikipedia.org/wiki/Bloom_filter)

References
----------
- [Grokking Algorithms: An illustrated guide for programmers and other curious people](https://www.amazon.com/Grokking-Algorithms-illustrated-programmers-curious/dp/1617292230/ref=sr_1_1?ie=UTF8&qid=1519440970&sr=8-1&keywords=Grokking+Algorithms)
- [Data Structures and Algorithm Analysis in Java](https://www.amazon.com/Data-Structures-Algorithm-Analysis-Java/dp/0132576279/ref=sr_1_1?s=books&ie=UTF8&qid=1519441056&sr=1-1&keywords=Data+Structures+Algorithm+Analysis+java)
