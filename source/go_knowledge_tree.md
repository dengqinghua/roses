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

<iframe width="560" height="315" src="https://www.youtube.com/embed/PAAkCSZUG1c" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

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

Debugger
-------
> 学会调试, 查看源码, 阅读源码.

- [Delve](https://github.com/derekparker/delve)
- [Vim Godebug](https://github.com/jodosha/vim-godebug)
- [Gdb](https://golang.org/doc/gdb)
- [Vim Delve](https://github.com/sebdah/vim-delve)

NOTE: [Vim Godebug](https://github.com/jodosha/vim-godebug) 依赖 [Neovim](https://neovim.io/), 最终选择的调试工具为 [sebdah/vim-delve](https://github.com/sebdah/vim-delve), vim-delve 需要安装 [Shougo/vimshell.vim](https://github.com/Shougo/vimshell.vim).

[![delve-demo](https://github.com/sebdah/vim-delve/raw/master/vim-delve-demo.gif)](https://github.com/sebdah/vim-delve)

基础知识
--------
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

### GoPath
[Code organization](https://golang.org/doc/code.html)

<iframe width="560" height="315" src="https://www.youtube.com/embed/XCsL89YtqCs" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

```shell
go help
```

并发
----
- [Mastering Concurrency in Go](https://www.packtpub.com/application-development/mastering-concurrency-go)

其他
----
- [Go Books](https://github.com/dariubs/GoBooks)
- [gRPC](https://github.com/grpc/grpc-go)
- [Net Work Programming with Go](https://github.com/tumregels/Network-Programming-with-Go)
- [Building Web Apps with Go](https://codegangsta.gitbooks.io/building-web-apps-with-go/content/)
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
