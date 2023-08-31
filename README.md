主要用于学习和理解ios的知识，

## 持续更新
- 新增VVeboTableView:异步绘制tableViewCell提高性能的一种方案 https://github.com/shenchunxing/better-ios-developer/wiki/VVeboTableView:异步绘制tableViewCell提高性能的一种方案
- 新增使用libextobjc框架的@onExit关键字来实现OC的defer https://github.com/shenchunxing/better-ios-developer/wiki/使用libextobjc框架的@onExit关键字来实现OC的defer
- 新增iOS-Crash防护 https://github.com/shenchunxing/better-ios-developer/wiki/iOS-Crash防护
- 新增耗电检测 https://github.com/shenchunxing/better-ios-developer/wiki/耗电检测
- 新增不要滥用多线程 https://github.com/shenchunxing/better-ios-developer/wiki/不要滥用多线程
- 新增App包体积大小的优化方案 https://github.com/shenchunxing/better-ios-developer/wiki/App包体积大小的优化方案
- 新增APP内存使用达到上限被强杀，怎么查找原因 https://github.com/shenchunxing/better-ios-developer/wiki/APP内存使用达到上限被强杀，怎么查找原因
- 新增App通过注入动态库的方式实现热重载 https://github.com/shenchunxing/better-ios-developer/wiki/App通过注入动态库的方式实现热重载
- 新增iOS12开始Auto Layout目前已经没有性能问题了 https://github.com/shenchunxing/better-ios-developer/wiki/iOS12开始Auto Layout目前已经没有性能问题了
- 新增JavaScriptCore可以做什么 https://github.com/shenchunxing/better-ios-developer/wiki/JavaScriptCore可以做什么
- 新增LLVM编译器 https://github.com/shenchunxing/better-ios-developer/wiki/LLVM编译器
- 新增Mach‐O文件是怎样被加载到内存中的 https://github.com/shenchunxing/better-ios-developer/wiki/Mach‐O文件是怎样被加载到内存中的
- 新增React Native、Flutter跨端方案的选择 https://github.com/shenchunxing/better-ios-developer/wiki/React Native、Flutter跨端方案的选择
- 新增使用Aspects减少Runtime Method Swizzling使用的风险 https://github.com/shenchunxing/better-ios-developer/wiki/使用Aspects减少Runtime Method Swizzling使用的风险
- 新增使用好用的GUI框架来提高界面性能 https://github.com/shenchunxing/better-ios-developer/wiki/使用好用的GUI框架来提高界面性能
- 新增使用静态分析工具查找App内部潜在的代码问题 https://github.com/shenchunxing/better-ios-developer/wiki/使用静态分析工具查找App内部潜在的代码问题
- 新增利用苹果自带的工具和代码就能实现监控CPU和内存 https://github.com/shenchunxing/better-ios-developer/wiki/利用苹果自带的工具和代码就能实现监控CPU和内存
- 新增启动速度怎么做优化与监控 https://github.com/shenchunxing/better-ios-developer/wiki/启动速度怎么做优化与监控
- 新增如何全面监控iOS的崩溃 https://github.com/shenchunxing/better-ios-developer/wiki/如何全面监控iOS的崩溃
- 新增如何利用 RunLoop 原理去监控卡顿 https://github.com/shenchunxing/better-ios-developer/wiki/如何利用 RunLoop 原理去监控卡顿
- 新增无侵入的埋点方案 https://github.com/shenchunxing/better-ios-developer/wiki/无侵入的埋点方案
- 新增链接器：符号是怎么绑定到地址上的 https://github.com/shenchunxing/better-ios-developer/wiki/链接器：符号是怎么绑定到地址上的

## iOS底层原理
- OC对象
   - [OC对象的本质【底层实现、内存布局、继承关系】](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/OC对象的本质【底层实现、内存布局、继承关系】.md)
   - [几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质.md)
  - [Category底层结构、App启动时Class与Category装载过程、load、initialize执行、关联对象](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/Category底层结构、App启动时Class与Category装载过程、load、initialize执行、关联对象.md) 
  - [KVC](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/KVC.md) 
   - [KVO](iOS底层原理/KVO.md) 
- Block
    - [Block的数据类型、内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/Block的数据类型、内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用.md) 
- Runtime 
  - [isa详解、class的结构、方法缓存cache_t](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/isa详解、class的结构、方法缓存cache_t.md) 
  - [objc_msgSend的三个阶段(消息发送、动态解析方法、消息转发)、super的本质](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/objc_msgSend的三个阶段(消息发送、动态解析方法、消息转发)、super的本质.md) 
  - [Runtime的相关应用](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/Runtime的相关应用.md) 
- Runloop 
  - [两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer.md) 
  - [Runloop的应用](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/Runloop的应用.md) 
- 多线程 
  - [主队列、串行队列、并行队列、全局并发队列](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/主队列、串行队列、并行队列、全局并发队列.md) 
  - [dispatch_get_global_queue与dispatch_(a)sync、单例、线程死锁](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/dispatch_get_global_queue与dispatch_async、单例、线程死锁.md) 
  - [栅栏函数dispatch_barrier_async、信号量dispatch_semaphore](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/栅栏函数dispatch_barrier_async、信号量dispatch_semaphore.md) 
  - [线程调度组dispatch_group、事件源dispatch Source](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/线程调度组dispatch_group、事件源dispatchSource.md) 
  - [了解iOS中的10个线程锁,与线程锁类型：自旋锁、互斥锁、递归锁](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/了解iOS中的10个线程锁,与线程锁类型：自旋锁、互斥锁、递归锁.md) 
- 内存管理 
  - [原子锁atomic、gcdTimer、NSTimer、CADisplayLink](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/原子锁atomic、gcdTimer、NSTimer、CADisplayLink.md) 
  - [Mach-O文件、TaggedPointer、对象的内存管理、copy、引用计数、weak指针、autorelease](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/Mach-O文件、TaggedPointer、对象的内存管理、copy、引用计数、weak指针、autorelease.md) 

## C语言
 - [C语言一些tips](https://github.com/shenchunxing/better-ios-developer/blob/master/c语言/tips.md) 

 ## C++
 - [C++一些tips](https://github.com/shenchunxing/better-ios-developer/blob/master/c++/tips.md)

## Swift
 - [Swift5常用核心语法1-基础语法](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/Swift5常用核心语法1-基础语法.md)  
 - [Swift5常用核心语法2-面向对象语法1](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/Swift5常用核心语法2-面向对象语法1.md) 
 - [Swift5常用核心语法2-面向对象语法2](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/Swift5常用核心语法2-面向对象语法2.md) 
 - [Swift5常用核心语法3-其他常用语法](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/Swift5常用核心语法3-其他常用语法.md) 
 - [Swift5应用实践常用技术点](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/Swift5应用实践常用技术点.md) 

## 小码哥Swift课程总结
 - [Swift简介、Swift编译原理、基础语法](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/Swift简介、Swift编译原理、基础语法.md) 
 - [函数、枚举、可选项、集合](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/函数、枚举、可选项、集合.md) 
 - [闭包](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/闭包.md) 
 - [结构体、类](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/结构体、类.md)
 - [属性、inout、方法、下标](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/属性、inout、方法、下标.md)
 - [继承、多态、初始化](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/继承、多态、初始化.md)
 - [可选链、协议、错误处理、泛型](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/可选链、协议、错误处理、泛型.md)
 - [Strin与Array的底层分析、高级运算符、扩展Extension](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/Strin与Array的底层分析、高级运算符、扩展Extension.md)
 - [访问控制、内存管理、指针](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/访问控制、内存管理、指针.md)
 - [字面量、模式匹配](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/字面量、模式匹配.md)
 - [从OC到Swift、函数式编程](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/从OC到Swift、函数式编程.md)
 - [面向协议编程、响应式编程、Swift源码分析](https://github.com/shenchunxing/better-ios-developer/blob/master/swift/面向协议编程、响应式编程、Swift源码分析.md)

## iOS面试题
 - [出一套iOS高级面试题](https://github.com/shenchunxing/better-ios-developer/blob/master/ios-interview-questions/出一套iOS高级面试题.md) 
 - [《招聘一个靠谱的iOS》面试题参考答案（上）](https://github.com/shenchunxing/better-ios-developer/blob/master/ios-interview-questions/《招聘一个靠谱的iOS》面试题参考答案（上）.md) 
 - [《招聘一个靠谱的iOS》面试题参考答案（下）](https://github.com/shenchunxing/better-ios-developer/blob/master/ios-interview-questions/《招聘一个靠谱的iOS》面试题参考答案（下）.md) 
 

## iOS自己总结（找时间和上面合并下）
 * [OC语法之OC对象本质](https://github.com/shenchunxing/better-ios-developer/blob/master/objective-c/OC对象本质.md) 
 * [OC语法之Notification](https://github.com/shenchunxing/better-ios-developer/blob/master/objective-c/Notification.md) 
 * [OC语法之KVC](https://github.com/shenchunxing/better-ios-developer/blob/master/objective-c/KVC.md) 
 * [OC语法之KVO](https://github.com/shenchunxing/better-ios-developer/blob/master/objective-c/KVO.md) 
 * [OC语法之Category](https://github.com/shenchunxing/better-ios-developer/blob/master/objective-c/Category.md) 
 * [Block之内存管理](https://github.com/shenchunxing/better-ios-developer/blob/master/block/block的内存管理.md) 
 * [Block之循环引用](https://github.com/shenchunxing/better-ios-developer/blob/master/block/block的循环引用.md) 
 * [深入理解OC/C++闭包](https://github.com/shenchunxing/better-ios-developer/blob/master/block/深入理解OC/C++闭包.md) 
 * [Runtime之Runtime的原理](https://github.com/shenchunxing/better-ios-developer/blob/master/runtime/Runtime之Runtime的原理.md) 
 * [Runtime之消息发送机制](https://github.com/shenchunxing/better-ios-developer/blob/master/runtime/Runtime之消息发送机制.md) 
 * [Runtime之Runtime的应用](https://github.com/shenchunxing/better-ios-developer/blob/master/runtime/Runtime之Runtime的应用.md) 
 * [Runloop原理和使用](https://github.com/shenchunxing/better-ios-developer/blob/master/runloop/Runloop.md) 
 * [多线程之GCD](https://github.com/shenchunxing/better-ios-developer/blob/master/multi-threading/多线程之GCD.md) 
 * [多线程之线程保活](https://github.com/shenchunxing/better-ios-developer/blob/master/multi-threading/多线程之线程保活.md) 
 * [多线程之线程同步方案](https://github.com/shenchunxing/better-ios-developer/blob/master/multi-threading/多线程之线程同步方案.md) 
 * [@synchronized原理](https://github.com/shenchunxing/better-ios-developer/blob/master/multi-threading/synchronized.md) 
 * [内存管理之内存布局](https://github.com/shenchunxing/better-ios-developer/blob/master/memory-management/内存布局.md) 
 * [内存管理之属性和成员变量的修饰符](https://github.com/shenchunxing/better-ios-developer/blob/master/memory-management/属性和成员变量的修饰符.md) 
 * [内存管理之TaggedPointer](https://github.com/shenchunxing/better-ios-developer/blob/master/memory-management/TaggedPointer.md) 
 * [内存管理之定时器的循环引用](https://github.com/shenchunxing/better-ios-developer/blob/master/memory-management/定时器的循环引用.md) 
 * [内存管理之3种内存管理机制](https://github.com/shenchunxing/better-ios-developer/blob/master/memory-management/3种内存管理机制.md) 

## 性能优化
 - [iOS各种Crash防护](https://github.com/shenchunxing/better-ios-developer/blob/master/performance-optimization/iOS各种Crash防护.md) 
 - [抖音品质建设 - iOS启动优化《原理篇》](https://juejin.cn/post/6887741815529832456?searchId=20230730100732AC05AC8064D01CE7B852) 
 - [抖音品质建设 - iOS启动优化《实战篇》](https://juejin.cn/post/6921508850684133390)
 - [性能优化之启动优化](https://github.com/shenchunxing/better-ios-developer/blob/master/performance-optimization/性能优化之启动优化.md) 
 - [性能优化之卡顿优化](https://github.com/shenchunxing/better-ios-developer/blob/master/performance-optimization/性能优化之卡顿优化.md)
 - [dyld加载过程](https://juejin.cn/post/6844904040149729294)
 - [二进制重排](https://juejin.cn/post/6844904130406793224?searchId=202307261436326489063FD998C416A8C4)
 - [今日头条品质优化 - 图文详情页秒开实践](https://mp.weixin.qq.com/s?__biz=MzI1MzYzMjE0MQ==&mid=2247486645&idx=1&sn=7c9111b70758c65575d7a2b5ee697191&chksm=e9d0c757dea74e418b8002d5eb652166d7edcf38a462dfadfc88377a05815f439ba624fc8565&token=1639618853&lang=zh_CN&scene=21#wechat_redirect)
 - [iOS性能优化实践：头条抖音如何实现OOM崩溃率下降50%+](https://mp.weixin.qq.com/s?__biz=MzI1MzYzMjE0MQ==&mid=2247486858&idx=1&sn=ec5964b0248b3526836712b26ef1b077&chksm=e9d0c668dea74f7e1e16cd5d65d1436c28c18e80e32bbf9703771bd4e0563f64723294ba1324&scene=21#wechat_redirect)
 - [抖音品质建设 - iOS 安装包大小优化实践篇](https://juejin.cn/post/6916317500992913421?searchId=20230730100732AC05AC8064D01CE7B852)
 - [DoKit-滴滴出行的开发工具](https://juejin.cn/user/325111173614365/posts)

## 基础知识
- [深入理解 OC/C++ 闭包](https://juejin.cn/post/7096067729911709732) 
 
 
## 架构和设计模式
 * [谈谈 MVX 中的 Model](https://github.com/shenchunxing/better-ios-developer/blob/master/architecture/mvx-model.md) 
 * [谈谈 MVX 中的 View](https://github.com/shenchunxing/better-ios-developer/blob/master/architecture/mvx-view.md) 
 * [谈谈 MVX 中的 Controller](https://github.com/shenchunxing/better-ios-developer/blob/master/architecture/mvx-controller.md) 
 * [浅谈 MVC、MVP 和 MVVM 架构模式](https://github.com/shenchunxing/better-ios-developer/blob/master/architecture/mvx.md) 


## 书籍和代码规范
 - [Swift提高代码质量的一些Tips](https://github.com/shenchunxing/better-ios-developer/blob/master/代码技巧和规范/Swift提高代码质量的一些Tips.md) 
 - [《Effective Objective-C》干货三部曲（一）：概念篇](https://github.com/shenchunxing/better-ios-developer/blob/master/代码技巧和规范/《EffectiveObjective-C》干货三部曲（一）：概念篇.md) 
 - [《Effective Objective-C 》干货三部曲（二）：规范篇](https://github.com/shenchunxing/better-ios-developer/blob/master/代码技巧和规范/《EffectiveObjective-C》干货三部曲（二）：规范篇.md) 
 - [《Effective Objective-C 》干货三部曲（三）：技巧篇](https://github.com/shenchunxing/better-ios-developer/blob/master/代码技巧和规范/《EffectiveObjective-C》干货三部曲（三）：技巧篇.md) 
 - [《Objective-C 高级编程》干货三部曲（一）：引用计数篇](https://github.com/shenchunxing/better-ios-developer/blob/master/代码技巧和规范/《Objective-C高级编程》干货三部曲（一）：引用计数篇.md) 
 - [《Objective-C 高级编程》干货三部曲（二）：Blocks篇](https://github.com/shenchunxing/better-ios-developer/blob/master/代码技巧和规范/《Objective-C高级编程》干货三部曲（二）：Blocks篇.md) 
 - [《Objective-C 高级编程》干货三部曲（三）：GCD篇](https://github.com/shenchunxing/better-ios-developer/blob/master/代码技巧和规范/《Objective-C高级编程》干货三部曲（三）：GCD篇.md)


## iOS第三方库源码解析系列
- [iOS第三方库源码解析](https://github.com/shenchunxing/ios-third-party-analysis/blob/master/README.md)


## Flutter
- [Flutter](https://github.com/shenchunxing/better-flutter-developer/blob/master)


## 操作系统系列

* [操作系统入门](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-overview.md)
* [操作系统之进程和线程](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-processandthread.md)
* [操作系统之内存管理](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-rammanage.md)
* [操作系统之文件系统](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-filesystem.md)
* [操作系统之输入输出](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-inputoutput.md)
* [操作系统之死锁](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-deadlock.md)
* [操作系统核心概念](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-importantconcept.md)
* [操作系统网站推荐](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-recommand.md)
* [操作系统超全面试题](https://github.com/shenchunxing/better-ios-developer/blob/master/operating-system/os-interview-second.md)

## 计算机网络系列

* [计算机网络基础知识](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/computer-network-basic.md)
* [TCP/IP 基础知识](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/computer-network-tcpip.md)
* [计算机网络应用层](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/computer-application.md)
* [计算机网络传输层](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/computer-translayer.md)
* [计算机网络网络层](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/computer-internet.md)
* [计算机网络数据链路层](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-datalink.md)
* [一文了解 ARP 协议](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-arp.md)
* [一文了解 DNS 协议](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-dns.md)
* [一文了解 ICMP 协议](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-icmp.md)
* [一文了解 DHCP 协议](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-dhcp.md)
* [一文了解 NAT 协议](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-nat.md)
* [Web 页面的请求流程，超详细](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/web-request.md)
* [什么是 Socket](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-socket.md)
* [一文了解路由选择协议](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-routerchoose.md)
* [一文了解 HTTP/2.0](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-http2.0.md)
* [一文了解 QUIC 协议](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-quic.md)
* [一文了解 HTTP/3.0](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-http3.0.md)
* [计算机网络自学指南](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/computer-howtolearn.md)
* [计算机网络核心概念](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-concepts.md)
* [计算机网络发展史](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-history.md)
* [学计算机网络，看计算机自顶向下好还是谢希仁的计算机好](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-network/network-choose.md)

## 计算机入门系列(组成原理)

* [程序员需要了解的硬核知识之 CPU](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-basic/computer-cpu.md)
* [程序员需要了解的硬核知识之内存](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-basic/computer-ram.md)
* [程序员需要了解的硬核知识之二进制](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-basic/computer-binary.md)
* [程序员需要了解的硬核知识之磁盘](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-basic/computer-disk.md)
* [程序员需要了解的硬核知识之压缩算法](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-basic/computer-compression.md)
* [程序员需要了解的硬核知识之操作系统和应用](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-basic/computer-osandapp.md)
* [程序员需要了解的硬核知识之操作系统入门](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-basic/computer-os.md)
* [程序员需要了解的硬核知识之控制硬件](https://github.com/shenchunxing/better-ios-developer/blob/master/computer-basic/computer-hardware.md)

