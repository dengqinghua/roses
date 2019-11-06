Go 学习
=======

DATE: 2018-06-05

该部分包含了Go的学习计划和相关知识树

阅读完该文档后，您将会了解到:

* Go的相关工具.
* Go的技术栈相关知识点和对应书籍推荐.

--------------------------------------------------------------------------------

提问的智慧
---------
如何提问很重要, 在学习任何知识之前, 需要先学会正确地提问.

- 提问的智慧原文: [这里](http://www.catb.org/~esr/faqs/smart-questions.html)
- 提问的智慧中文版本: [这里](https://github.com/ryanhanwu/How-To-Ask-Questions-The-Smart-Way/blob/master/README-zh_CN.md)

Go Proverbs
-----------
> Simple, Poetic, Pithy

[Go Proverbs - Rob Pike - Gopherfest](http://go-proverbs.github.io/)

- Don't communicate by sharing memory, share memory by communicating.
- Concurrency is not parallelism.
- Channels orchestrate; mutexes serialize.
- The bigger the interface, the weaker the abstraction.
- Make the zero value useful.
- interface{} says nothing.
- Gofmt's style is no one's favorite, yet gofmt is everyone's favorite. **WHO CARES? SHUT UP**
- A little copying is better than a little dependency.
- Syscall must always be guarded with build tags.
- Cgo must always be guarded with build tags.
- Cgo is not Go.
- With the unsafe package there are no guarantees.
- Clear is better than clever.
- Reflection is never clear.
- Errors are values.
- Don't just check errors, handle them gracefully.
- Design the architecture, name the components, document the details.
- Documentation is for users.
- Don't panic.

<iframe class="youtube" src="https://www.youtube.com/embed/PAAkCSZUG1c" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

5 things of Go's success
---------------------------------------------
> As the saying goes... history doesn’t repeat itself, but it often rhymes.

- Formal specification
- Attracted killer apps (Docker, k8s)
- the Open source community
- Made the language hard to change
- Stuck with features they believed in

[5-things-rob-pike-attributes-to-gos-success](https://changelog.com/posts/5-things-rob-pike-attributes-to-gos-success)

Vim-Go
------
> Vim and ONLY Vim.

```shell
plugin 'fatih/vim-go'
:GoInstallBinaries
:help vim-go
```

NOTE: 如果执行 `:GoInstallBinaries` 报错, 请参考 [go_get_timeout_solution](http://blog.dengqinghua.net/go_get_timeout_solution.html)

Go Style
--------
> 规范, 约定大于配置, 好的习惯比什么都重要.

- [Go Style Guide](https://github.com/bahlo/go-styleguide)
- [Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Effective Go](https://golang.org/doc/effective_go.html)

Test
----
> TDD

- [Ginkgo](https://github.com/onsi/ginkgo)
- [Goblin](https://github.com/franela/goblin)
- [Testify](https://github.com/stretchr/testify)
- [Package Testing](https://golang.org/pkg/testing/)

NOTE: 最终选择的是 [Goconvey](https://github.com/smartystreets/goconvey)

测试Case如下:

```go
package golang

import (
	. "github.com/smartystreets/goconvey/convey"
	"testing"
)

// go test -v -run TestBasicMap
func TestBasicMap(t *testing.T) {
	Convey("TestBasicMap", t, func() {
		Convey("get, put", func() {
			Convey("should get right", func() {
				oneMap := make(map[string]int)

				oneMap["dsgv"] = 587

				value, exist := oneMap["dsgv"]

				So(exist, ShouldBeTrue)
				So(value, ShouldEqual, 587)

				value, exist = oneMap["dsg"]

				So(exist, ShouldBeFalse)
				So(value, ShouldEqual, 0)
			})
		})
	})
}
```

### Test Func
测试单独的一个方法

hello_world.go

```go
package main

// go run hello_world.go
// go build hello_world.go
// :GoRun / :GoBuild
func main() {
	println(Sum(5, 5))
}

func Sum(x int, y int) int {
	return x + y
}
```

hello_world_test.go

```go
package main

import "testing"

// go test -run TestSum
func TestSum(t *testing.T) {
	total := Sum(5, 5)

	if total != 5 {
		// t.Errorf; t.Fail; t.Log
		t.Errorf("Sumw was incorrect, got %d, want %d", total, 10)
	}
}

// go test -run TestSum1
func TestSum1(t *testing.T) {
	total := Sum(5, 5)

	if total != 6 {
		// t.Errorf; t.Fail; t.Log
		t.Errorf("Sumw was incorrect, got %d, want %d", total, 10)
	}
}
```

测试全部的case

```shell
go test
```

测试某个case

```shell
go test -run TestSum
```

NOTE: test文件必须写成 `*_test` 的形式. 可以执行 `go help test` 查看更多信息.

INFO: 参考自 [StackOverflow: How to run test cases in a specified file?](https://stackoverflow.com/a/16936314/8186609) 和 [这里](https://golang.org/pkg/testing/#hdr-Subtests_and_Sub_benchmarks), 我的源码例子: [这里](https://github.com/dengqinghua/my_examples/blob/master/golang/hello_world_test.go)

### Mock
学会mock方法. 考察了很多 mock 的插件, 如 [testify/mock](https://github.com/stretchr/testify#mock-package), [Gomock](https://github.com/golang/mock), [Gostub](https://github.com/prashantv/gostub) 等, 最终我们选择了 testify/mock

NOTE: Golang 的 mock, 不像面向对象语言, 她只能对 interface 进行mock. 有人对此也提出了疑问, 详情请见 [How to write mock for structs in Go](https://stackoverflow.com/q/41053280)

代码请见我的[mock_test](https://github.com/dengqinghua/my_examples/blob/master/golang/mock_test.go)

Debugger
-------
> 学会调试, 查看源码, 阅读源码.

- [Delve](https://github.com/derekparker/delve)
- [Vim Godebug](https://github.com/jodosha/vim-godebug)
- [Gdb](https://golang.org/doc/gdb)
- [Vim Delve](https://github.com/sebdah/vim-delve)

NOTE: 由于 [Vim Godebug](https://github.com/jodosha/vim-godebug) 依赖 [Neovim](https://neovim.io/), 而我们一般使用的是vim, 故最终选择的调试工具为 [sebdah/vim-delve](https://github.com/sebdah/vim-delve), vim-delve 依赖 [Shougo/vimshell.vim](https://github.com/Shougo/vimshell.vim).

[![delve-demo](https://github.com/sebdah/vim-delve/raw/master/vim-delve-demo.gif)](https://github.com/sebdah/vim-delve)

基础知识
--------
+ [spec](https://golang.org/ref/spec)
+ [中文版](https://golang.org/ref/spec)

```go
package main
import "fmt"

var a = 1

func main() {
  fmt.Println("Hello World")
}
```

- [Go Tour](https://tour.golang.org/list)
- [The Little Go Book](https://github.com/karlseguin/the-little-go-book)

### Spec部分笔记

#### Predeclared Identifiers and Keywords
Predeclared Identifiers 是可以被使用的

```go
Types:
	bool byte complex64 complex128 error float32 float64
	int int8 int16 int32 int64 rune string
	uint uint8 uint16 uint32 uint64 uintptr

Constants:
	true false iota

Zero value:
	nil

Functions:
	append cap close complex copy delete imag len
	make new panic print println real recover
```

如下面的语法是Okay的

```
bool := 1
fmt.Println(bool)
```

Keywords 是不可以被重复使用的, 包括下面这些

```go
break        default      func         interface    select
case         defer        go           map          struct
chan         else         goto         package      switch
const        fallthrough  if           range        type
continue     for          import       return       var
```

#### Slice
- [Arrays, slices (and strings): The mechanics of 'append'](https://blog.golang.org/slices)
- [go-slices-usage-and-internals](https://blog.golang.org/go-slices-usage-and-internals)
- [slice-tricks](https://github.com/golang/go/wiki/SliceTricks)

A slice is

- a data structure describing a contiguous section of an array stored separately from the slice variable itself
- a data structure with two elements: a length and a pointer to an element of an array

```go
type sliceHeader struct {
    Length        int
    Capacity      int
    ZerothElement *byte
}
```

> A slice cannot be grown beyond its capacity. Attempting to do so will cause a runtime panic.  Similarly,
slices cannot be re­sliced below zero to access earlier elements in the array.

#### Rune
> A rune literal represents a rune constant, an integer value identifying a Unicode code point,
or think of as a character constant is called a rune constant in Go.

见 [Strings, bytes, runes and characters in Go](https://blog.golang.org/strings)

- A string is in effect a read-only slice of bytes

[ASCII, UNICODE 和 UTF-8](http://www.ruanyifeng.com/blog/2007/10/ascii_unicode_and_utf-8.html)

### GoPath
[Code organization](https://golang.org/doc/code.html)

<iframe class="youtube" src="https://www.youtube.com/embed/XCsL89YtqCs" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

```shell
go help
```

### Go Tags in structures
- [What are the use(s) for tags in Go?](https://stackoverflow.com/a/30889373)
- [Spec#Struct_types](https://golang.org/ref/spec#Struct_types)
- [Sam Helman & Kyle Erf - The Many Faces of Struct Tags](https://github.com/gophercon/2015-talks/blob/master/Sam%20Helman%20%26%20Kyle%20Erf%20-%20The%20Many%20Faces%20of%20Struct%20Tags/StructTags.pdf)

并发
----
- [Concurrency in Go Tools and Techniques for Developers](http://shop.oreilly.com/product/0636920046189.do)

### sync Package
TREE:
{
        text: { name: "sync" },
        children: [
            {
                text: { name: "Map" },
            },
            {
                text: { name: "WaitGroup" },
            },
            {
                text: { name: "Once" },
            },
            {
                text: { name: "Mutex, RWMutex" },
            },
            {
                text: { name: "Pool" },
            },
            {
                text: { name: "Cond" },
            },
            {
                text: { name: "Atomic" },
            }
       ]
}

其他
----
- [Go Books](https://github.com/dariubs/GoBooks)
- [Practical Go: Real world advice for writing maintainable Go programs](https://dave.cheney.net/practical-go/presentations/qcon-china.html)
- GC

项目
---
### Go Strings
用Go语言做跟音乐相关的东西, 正在筹划中

Books
-----
- [The Little Go Book](https://github.com/karlseguin/the-little-go-book)
- [Effective Go](https://golang.org/doc/effective_go.html)
- [The Go Programming Language](http://a.co/4HWJ4G6)
- [Go In Action](http://a.co/0hqvvC2)
- [Net Work Programming with Go](http://tumregels.github.io/Network-Programming-with-Go/)
