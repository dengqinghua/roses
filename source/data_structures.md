数据结构
========

DATE: 2018-03-20

该文档涵盖了计算机基础的数据结构设计.

阅读完该文档后，您将会了解到:

* 基础的数据结构设计如 List, Queue, Stack.
* 基于基础数据结构之上的复杂结构如 Graph, Tree
* 数据结构的基本组成部分

--------------------------------------------------------------------------------


List
----
Java中的Collection框架

![Collection_interfaces](images/Collection_interfaces.png)

基础操作

 操作  |  释义    |
----   | ------   |
get    | 获取数据 |
set    | 设置数据 |
add    | 添加数据 |
remove | 移除数据 |
size   | 获取长度 |

NOTE: 为什么接口中要提供一个`Iterator`? 个人理解为: 遍历一个长度为 N 的List的时候, ArrayList的复杂度为 N * O(1) = O(N), LinkedList的复杂度为 N * O(N) = O(N * N), 而对于 Iterator, 她提供了 `next` 和 `hasNext` 方法, 遍历的时候为稳定的复杂度: O(N)

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
下面是 Java 8 的源码

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

新增的容量为原有容量的1.5倍

NOTE: >> 符号为[位移](http://www.cnblogs.com/hongten/p/hongten_java_yiweiyunsuangfu.html)操作, 可以看下[测试code](https://github.com/dengqinghua/my_examples/blob/master/java/src/test/java/com/dengqinghua/algorithms/QuickSortTest.java#L72)

#### modCount
在Iterator的实现中, 有一个非常奇怪的变量: modCount

> * The number of times this list has been <i>structurally modified</i>.
> * Structural modifications are those that change the size of the
> * list, or otherwise perturb it in such a fashion that iterations in
> * progress may yield incorrect results.

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

```java
final void checkForComodification() {
    if (modCount != expectedModCount) {
        throw new ConcurrentModificationException();
    }
}
```

#### RandomAccess
她支持`RandomAccess`, 在 [二分法查找](https://github.com/dengqinghua/my_examples/blob/master/java/src/main/java/com/dengqinghua/algorithms/BinarySearch.java#L30) 的时候比 LinkedList 更加有优势

### LinkedList

References
----------
- [Grokking Algorithms: An illustrated guide for programmers and other curious people](https://www.amazon.com/Grokking-Algorithms-illustrated-programmers-curious/dp/1617292230/ref=sr_1_1?ie=UTF8&qid=1519440970&sr=8-1&keywords=Grokking+Algorithms)
- [Data Structures and Algorithm Analysis in Java](https://www.amazon.com/Data-Structures-Algorithm-Analysis-Java/dp/0132576279/ref=sr_1_1?s=books&ie=UTF8&qid=1519441056&sr=1-1&keywords=Data+Structures+Algorithm+Analysis+java)
