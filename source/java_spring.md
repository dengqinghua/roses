Spring
======

DATE: 2020-03-19

该文档涵盖了 Spring 的基本概念 和 核心代码 分析

阅读完该文档后，您将会了解到:

* Spring 的核心概念
* Bean 的生命周期
* Spring 全家桶

--------------------------------------------------------------------------------

重要概念
-------
### IoC
Ioc, `Inversion of Control`, 控制权反转，即： 将 对象的控制权，交由给第三方处理。在 Spring 上下文中，这个第三方就是 容器【Container】。控制权反转之后，创建对象将由容器来完成

### DI
DI, `Dependency Injection`, 依赖注入, 即: 在进行 IOC 之后，需要管理对象之前的依赖关系。一般来说，对象之间的依赖关系是在 RUNTIME 决定的，依赖注入做的事情就是管理和校验依赖关系，提高组件的效率

NOTE: **IOC 和 Factory**:
IOC 为 push 机制，依赖于 配置，在一个地方配置所有的组件。Factory 为 pull, 类之间的依赖需要依赖 Factory Method，实现需要各种类.
使用 Factory 模式，则主要责任是在于 类 本身，而 IOC 则是将 责任外包出去，由框架去组装对象的生成

### AOP
AOP, `Aspect oriented programming`, DI 解决的是依赖之间的解耦, 而 AOP 是行为之间的解耦. 在 Spring 中, 是以拦截器(interceptors)的方式
来做对应的 AOP. 经常使用的 interceptors 有 Loggers, Transactions, security, cache 等等

NOTE: 在 Ruby on Rails 中, AOP 的实现是以 Callback 的形式呈现的

> DI helps you decouple your application objects from it’s dependencies,
while AOP helps you decouple cross-cutting concerns from the objects.

### Container
- BeanFactory Container
- ApplicationContext Container

NOTE: 元数据 + Beans -> 容器 = 一个启动的应用程序 

Bean
----
### Scope
- singletion 默认
- prototype 每次都创建新的 bean
- request, session 和 global-session 和网络请求相关的 bean 的作用域

### 三级缓存

Name | 作用
---|---
singletonObjects【一级缓存】 | 已经初始化完成的 Bean 对象
earlySingletonObjects【二级缓存】 | 已经初始化但是未初始化好的 Bean 对象
singletonFactories【三级缓存】 | 存放工厂对象

见 [源码](https://github.com/spring-projects/spring-framework/blob/8f369ffed55dad6021624105b961884c2e42d605/spring-beans/src/main/java/org/springframework/beans/factory/support/DefaultSingletonBeanRegistry.java#L180)

查询方式: 先在 singletonObjects 找, 再去 earlySingletonObjects 找, 最后去 singletonFactories 找, 通过这种方式解决了 **循环依赖** 的问题

INFO: 理论上是不应该支持 `循环依赖` 的功能的, 如果是直接得循环依赖，而且实时创建依赖的 Bean, 则会[报错], 但是 Spring 支持了其他方式，所以才出现了这样的设计

```java
protected Object getSingleton(String beanName, boolean allowEarlyReference) {
  Object singletonObject = this.singletonObjects.get(beanName);
  if (singletonObject == null && isSingletonCurrentlyInCreation(beanName)) {
    synchronized (this.singletonObjects) {
      singletonObject = this.earlySingletonObjects.get(beanName);
      if (singletonObject == null && allowEarlyReference) {
        ObjectFactory<?> singletonFactory = this.singletonFactories.get(beanName);
        if (singletonFactory != null) {
          singletonObject = singletonFactory.getObject();
          this.earlySingletonObjects.put(beanName, singletonObject);
          this.singletonFactories.remove(beanName);
        }
      }
    }
  }
  return singletonObject;
}
```

Event
-----
ApplicationContext 管理着 Bean 的生命周期, 当一些 bean 发生变化的时候，会通过 Event 的形式发布消息

> By default spring events are synchronous,
the `doStuffAndPublishAnEvent()` method blocks
until all listeners finish processing the event.
