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


Debugger
-------
> 学会调试, 查看源码, 阅读源码.

- [Delve](https://github.com/derekparker/delve)
- [Vim Godebug](https://github.com/jodosha/vim-godebug)
- [Gdb](https://golang.org/doc/gdb)


基础知识
--------
```go
package main
import "fmt"

func main() {
  fmt.Println("Hello World")
}
```

- [Go Tour](https://tour.golang.org/list)
- [The Little Go Book](https://github.com/karlseguin/the-little-go-book)

### GoPath
[Code organization](https://golang.org/doc/code.html)

<iframe width="560" height="315" src="https://www.youtube.com/embed/XCsL89YtqCs" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

```
go help
```

并发
----
- [Mastering Concurrency in Go](https://www.packtpub.com/application-development/mastering-concurrency-go)

其他
----
- [gRPC](https://github.com/grpc/grpc-go)
- [Net Work Programming with Go](https://github.com/tumregels/Network-Programming-with-Go)
- [Building Web Apps with Go](https://codegangsta.gitbooks.io/building-web-apps-with-go/content/)
- GC

项目
---
### Go Strings
用Go语言做跟音乐相关的东西, 正在筹划中
