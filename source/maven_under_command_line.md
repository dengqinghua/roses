Maven In Java
=============

本文档对Maven进行了介绍和分析.

阅读完该文档之后, 您将了解到:

* 如何用命令行的Maven进行Run, Test和Debug.
* Maven核心概念: Lifecycle, Plugin, Phases 和 Goal.

------------------------------------------------------------------------

NOTE: 请到[这里](https://github.com/dengqinghua/my_examples/tree/master/java)查看完整示例代码

maven命令行执行main方法和test
-----------------------------
在开发java的时候, 我们经常重度依赖IDE, 但是IDE的可编辑的区域很小

![badIde](images/badIde.png)

NOTE: 写代码的区域很小, 建议关闭所有的窗口, 只留下写代码的区域.
另外, 可通过ideaVim可以自定制vim的[快捷键](https://github.com/dengqinghua/dotfiles#ideavimrc)
来一键式关闭所有窗口, 也可以使用IDE的默认快捷键.

但是我们需要起main服务或者Run测试怎么办? 一般来说我们会在IDE下运行多个任务

![runTestAndServerBoth](images/runTestAndServerBoth.png)

这样写代码的区域会更少, 而且控制台会一直打开着, 占用写代码的区域.

为了解决上述问题, 我尝试用 Maven 原生的命令行来启动服务, 跑测试用例, 释放IDE.

### mvn exec
在上述的例子, 可以通过执行

```
mvn compile # 进行编译
mvn exec:java -Dexec.mainClass=com.dengqinghua.example.App # Run main方法
```

NOTE: 上述两个命令可以合并成一个 `mvn compile exec:java -Dexec.mainClass=com.dengqinghua.example.App`

启动一个服务

![commandLine](images/incmdRun.png)

INFO: 如果想指定不同的参数, 可以通过 -D 添加:
```
mvn compile exec:java -Dexec.mainClass=com.dengqinghua.example.App -Ddsg=v587
```

![commandLineWithArgus](images/dsgv587Run.png)

NOTE: 输入 mvn --help 可以看到: `-D,--define <arg>  Define a system property`

INFO: 在pom.xml文件中, 我们添加这个plugin, 可以实现增量编译和指定java编译的版本
```
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>${compiler.plugin.version}</version>
  <configuration>
    <!-- 使用增量编译 -->
    <useIncrementalCompilation>false</useIncrementalCompilation>
    <!-- 指定java的版本 -->
    <source>1.8</source>
    <target>1.8</target>
  </configuration>
</plugin>
```

### mvn test
Maven test插件 [maven-sirefile-plugin](http://maven.apache.org/surefire/maven-surefire-plugin/)

她支持

- 并发跑测试
- 指定某个单独的测试case
- 可以命令行执行, 并通过 -D 来添加参数

#### Run所有的测试

```shell
mvn test
```

![mavenTest](images/mavenTest.png)

#### Run指定的class的测试

```shell
mvn test -Dtest=SalaryTest
```

#### Run指定的方法

```shell
mvn test -Dtest="SalaryTest#calculateYearSalary"
```

#### 添加参数
我们有时候需要建立一个client去调用远程的server, 配置的是 IP + 端口号, 而远程的server的地址是可变的, 我们可以写一个client去调用服务, 将服务的IP和端口号通过参数的形式传入.

```
mvn test -Dtest="SalaryTest#calculateYearSalary" -Dhosts=localhost:8000
```

另外一个场景: 我们需要测试不同的用户, 不同的性别下的一些信息, 可以传入多个参数

```shell
mvn test -Dtest="SalaryTest#calculateYearSalary" -DuserId=1024,1025 -Dsex=male
```

最近做的一个角标系统中, 需要传入多个商品id, 以及页面, 来源等信息, 有时候会调用本地服务, 有时候会直接调用线上的服务,
测试case如下

```java
public class ClientTest {
    /**
     * 获取角标数据
     *
     * mvn test -Dtest="ClientTest#getCornerData" -DproductId=1024,1025,1026 -Dchannel=2 -DclientType=2 -DuserType=2 -DuserRole=4 -Dhosts="192.168.11.11:12701"
     *
     */
    @Test public void getCornerData() throws Exception {
        String productId = System.getProperty("productId"),    // 商品id, 以逗号分隔
                channel    = System.getProperty("channel"),    // 页面来源
                clientType = System.getProperty("clientType"), // 客户端来源
                userType   = System.getProperty("userType"),   // 用户身份
                userRole   = System.getProperty("userRole");   // 用户角色

        String hosts = Optional.ofNullable(System.getProperty("hosts")).
          orElse("localhost:12701");

        // ...
    }
}
```

`maven test`除了上述功能外, 还支持输出测试覆盖率, 并发运行测试等, 更多内容请阅读官方文档.

Maven Debug
---------
有时候我们需要在程序进行调试, 如在 main 方法中添加断点

![addBreakPoint](images/addBreakPoint.png)

运行服务的时候此时需要以debug的方式启动.

```shell
mvnDebug compile exec:java -Dexec.mainClass="com.dengqinghua.example.App" -Ddsg=v587
```

此时程序会停止执行, 开启了一个 8000 的端口等待attached

```shell
➜  mvnDebug compile exec:java -Dexec.mainClass="com.dengqinghua.example.App" -Ddsg=v587

Preparing to execute Maven in debug mode
Listening for transport dt_socket at address: 8000
```

INFO: Maven调用了原生的[jdb](https://docs.oracle.com/javase/7/docs/technotes/tools/solaris/jdb.html)

可以使用 IDE 创建一个 [RemoteDebug](https://www.jetbrains.com/help/idea/run-debug-configuration-remote-debug.html)

![addDebug](images/addDebug.png)

![addRemoteDebug](images/addRemoteDebug.png)

填写相应参数

- Host: localhost
- Port: 8000
- Name: mvnDebug
- Module's classpath: my-example

![createMVNDebug](images/createMVNDebug.png)

NOTE: 线上的代码也可以用类似的方式进行debug, 只需要改变Host和Port, 并在启动的时候添加Debug参数即可

运行debug

![runDebug](images/runDebug.png)

最终可以在IDE中捕获到断点, 并进行调试

![goIntoBreakpoint](images/goIntoBreakpoint.png)

Maven Purpose
------------
> Maven’s primary goal is to allow a developer to comprehend the complete state of a development effort in the shortest period of time
INFO: Maven的介绍请查看官网: [What is Maven?](https://maven.apache.org/what-is-maven.html) 和 [Maven In 5 Minutes](https://maven.apache.org/guides/getting-started/maven-in-five-minutes.html)

受到 [Rails](http://rubyonrails.org/)的影响, 由Ruby转到Java的时候, 希望能有像Rails这种基于[Convention Over Configuratoin](https://en.wikipedia.org/wiki/Convention_over_configuration)理念设计的框架. Maven是, 她配置的细节真正地做到了最小化. 基于使用角度和最佳实践的角度.

她提供了完整地一套开发流程, 包括:

- 创建项目
- 包依赖管理, 生成项目文件结构目录
- 测试和测试覆盖率
- 打包等

除此之外, Maven还提供了非常丰富的命令行交互, 包括像上述过程中描述的命令行中Run main方法, debug, test等. 这些对于本人这种喜欢CLI的程序员欣喜若狂.

### Maven Archetype
利用Maven创建项目

```shell
mvn archetype:generate -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false -DarchetypeCatalog=internal\
  -DgroupId=com.dengqinghua.example\
  -DartifactId=my-example\
```

构建的文件目录为:

```shell
▾ src/
  ▾ main/java/com/dengqinghua/example/
      App.java
  ▾ test/java/com/dengqinghua/example/
      AppTest.java
  pom.xml
```

### POM
Project Object Model 是maven的核心配置文件, 我的常用的POM插件和依赖如下:

常用的几个配置属性

       名称        |  释义  |
     --------      | ------ |
   dependencies    | 包依赖  |
    plugins | mvn所开发的插件, 在test, package, install等场景使用. 如 maven-surefire-plugin, 支持完整的 junit 测试框架, 并在其基础上可以实现并发跑测试 |
   properties    |  属性配置, 可以在配置中通过 ${} 进行调用 |

#### POM文件
1. 项目级别的pom, 位于项目下的pom.xml
2. 用户级别的pom, 位于 `~/.m2/settings.xml`
3. 全局配置的pom, 位于 `M2_HOME/conf/settings.xml`

其中优先级为: 项目级别 > 用户级别 > 全局配置

NOTE: M2_HOME 可以通过`mvn --version`查看; 另外, 可以通过`mvn help:effective-pom`查看当前的完整的配置的 pom

Maven LifeCycle
---------------
官方文档: [Introduction to the Build Lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html)

INFO: 建议完整地看完上述文档, 下面的内容没有什么新的东西, 仅仅是上述文档的总结和翻译, 此外, 需要理解 Lifecycle, Phases, Plugin 和 Goal 的区别和关系. 在[这篇文章](https://stackoverflow.com/questions/16205778/what-are-maven-goals-and-phases-and-what-is-their-difference)中有讨论.

### Build Lifecycle
mvn 支持的三个lifecycle 包括:

- defalut
- clean
- site

#### default
一个完整的default lifecycle包括下面几部分:

- validate - validate the project is correct and all necessary information is available
- compile - compile the source code of the project
- test - test the compiled source code using a suitable unit testing framework. These tests should not require the code be packaged or deployed
- package - take the compiled code and package it in its distributable format, such as a JAR.
- verify - run any checks on results of integration tests to ensure quality criteria are met
- install - install the package into the local repository, for use as a dependency in other projects locally
- deploy - done in the build environment, copies the final package to the remote repository for sharing with other developers and projects.

上面是有顺序而且相互依赖的. 比如当执行 mvn test 的时候, 其实也运行了 validate 和 compile 这两个步骤

```
➜  mvn test
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building my-example 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ my-example ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory /Users/dengqinghua/git/learning/java/maven/new-project/my-example/src/main/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.5.1:compile (default-compile) @ my-example ---
[WARNING] File encoding has not been set, using platform encoding UTF-8, i.e. build is platform dependent!
[INFO] Compiling 2 source files to /Users/dengqinghua/git/learning/java/maven/new-project/my-example/target/classes
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ my-example ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory /Users/dengqinghua/git/learning/java/maven/new-project/my-example/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.5.1:testCompile (default-testCompile) @ my-example ---
[WARNING] File encoding has not been set, using platform encoding UTF-8, i.e. build is platform dependent!
[INFO] Compiling 2 source files to /Users/dengqinghua/git/learning/java/maven/new-project/my-example/target/test-classes
[INFO]
[INFO] --- maven-surefire-plugin:2.20.1:test (default-test) @ my-example ---
[INFO]
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.dengqinghua.calculate.SalaryTest
null
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.09 s - in com.dengqinghua.calculate.SalaryTest
[INFO] Running com.dengqinghua.example.AppTest
[INFO] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0 s - in com.dengqinghua.example.AppTest
[INFO]
[INFO] Results:
[INFO]
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.751 s
[INFO] Finished at: 2018-02-12T18:24:49+08:00
[INFO] Final Memory: 17M/167M
[INFO] ------------------------------------------------------------------------
```

可以看到, 其中`mvn test`执行的操作包括(其中validate没有日志输出):

- maven-resources-plugin:2.6:resources
- maven-compiler-plugin:3.5.1:compile
- maven-resources-plugin:2.6:testResources
- maven-compiler-plugin:3.5.1:testCompile
- maven-surefire-plugin:2.20.1:test

所以 上述是一个 "Build Lifecycle" 的过程. 不仅是 mvn test, 像 mvn compile, mvn install, mvn deploy 等, 都是一个 "Build Lifecycle".
在这个过程中, 排在当前命令之前的所有命令都会被执行.

#### mvn clean 和 mvn site
请参考官方文档: [Lifecycle_Reference](http://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html#Lifecycle_Reference)

- clean 删除项目 target 文件夹下的文件
- site 生成项目信息的文档, 包括Dependencies等

### Phases
> A Build Lifecycle is Made Up of Phases

Phases 是指 lifecycle 下的命令

如:

- validate
- compile
- test
- package
- verify
- install
- deploy
- clean
- site

mvn test 中 test 就是一个 Phase

### Plugin 和 Goal
> A Build Phase is Made Up of Plugin Goals

下面的命令:

```
mvn dependency:copy-dependencies
```

其中 `dependency` 为 plugin, `copy-dependencies` 为 goal.

Phase是由一系列的 plugin 和 goal 组成的, 如

```
mvn test
```

测试环节使用到的plugin和goal为

```
mvn surefire:test
```

INFO: 如果单独运行 mvn surefire:test, 则不会经过 compile 的过程

plugin 和 goal 又可以独立存在. 如上述的例子, exec:java 不属于任何Phase

```
mvn exec:java -Dexec.mainClass="com.dengqinghua.example.App" -Ddsg=v587
```

### 多个条件组合执行
Maven支持多个命令组合执行, 比如希望先清除已编译的class文件(clean), 再进行install, 最后运行一个 exec 服务, 可以这样执行

```
mvn clean install exec:java -Dexec.mainClass="com.dengqinghua.example.App" -Ddsg=v587
```

其他命令行
---------
INFO: 如果您使用zsh, 建议在 ~/.zshrc 的 plugins 中添加 mvn
```
plugins=(git brew osx git-flow vue mvn)
```
之后在console中可以进行补全

- mvn dependency:tree
- mvn install -Dmaven.test.skip=true # 忽略测试
- mvn -U clean install # FORCE update-snapshots
- mvn -o clean install # 不检查 dependencies 是否更新
- mvn -Dplugin=install help:describe # 查看plugin的版本
- mvn help:effective-pom # 查看当前生效的pom配置信息

References
----------
- [Maven FAQ](http://maven.apache.org/general.html)
- [Maven In 5 Minutes](http://maven.apache.org/guides/getting-started/maven-in-five-minutes.html)
- [Maven Get Started](http://maven.apache.org/guides/getting-started/index.html)
- [Maven Tutorial](https://www.tutorialspoint.com/maven/)
