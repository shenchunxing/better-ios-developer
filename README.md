主要用于学习和理解ios的知识，

## iOS知识总结
 ### OC基础
 * [OC对象的本质【底层实现、内存布局、继承关系](https://github.com/shenchunxing/better-ios-developer/blob/master/iOS底层原理/OC对象的本质【底层实现、内存布局、继承关系】.md)

| Project | Article |
|:-------:|:------|
| iOS底层原理 | [OC对象的本质【底层实现、内存布局、继承关系】](iOS底层原理/OC对象的本质【底层实现、内存布局、继承关系】.md) <br> [几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质](iOS底层原理/几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质.md) <br> [Category底层结构、App启动时Class与Category装载过程、load、initialize执行、关联对象](iOS底层原理/Category底层结构、App启动时Class与Category装载过程、load、initialize执行、关联对象.md) <br> [KVC](iOS底层原理/KVC.md) <br> [KVO](iOS底层原理/KVO.md) <br> [Block的数据类型、内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用](iOS底层原理/Block的数据类型、内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用.md) <br> [isa详解、class的结构、方法缓存cache_t](isa详解、class的结构、方法缓存cache_t.md) <br> [objc_msgSend的三个阶段(消息发送、动态解析方法、消息转发)、super的本质](iOS底层原理/objc_msgSend的三个阶段(消息发送、动态解析方法、消息转发)、super的本质.md) <br> [Runtime的相关应用](iOS底层原理/Runtime的相关应用.md) <br> [两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer](iOS底层原理/两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer.md) <br> [Runloop的应用](iOS底层原理/Runloop的应用.md) <br> [主队列、串行队列、并行队列、全局并发队列](iOS底层原理/主队列、串行队列、并行队列、全局并发队列.md) <br> [dispatch_get_global_queue与dispatch_(a)sync、单例、线程死锁](iOS底层原理/dispatch_get_global_queue与dispatch_async、单例、线程死锁.md) <br> [栅栏函数dispatch_barrier_async、信号量dispatch_semaphore](iOS底层原理/栅栏函数dispatch_barrier_async、信号量dispatch_semaphore.md) <br> [线程调度组dispatch_group、事件源dispatch Source](iOS底层原理/线程调度组dispatch_group、事件源dispatchSource.md) <br> [了解iOS中的10个线程锁,与线程锁类型：自旋锁、互斥锁、递归锁](iOS底层原理/了解iOS中的10个线程锁,与线程锁类型：自旋锁、互斥锁、递归锁.md) <br> [原子锁atomic、gcdTimer、NSTimer、CADisplayLink](iOS底层原理/原子锁atomic、gcdTimer、NSTimer、CADisplayLink.md) <br> [Mach-O文件、TaggedPointer、对象的内存管理、copy、引用计数、weak指针、autorelease](iOS底层原理/Mach-O文件、TaggedPointer、对象的内存管理、copy、引用计数、weak指针、autorelease.md) |
| Swift | [Swift5常用核心语法1-基础语法](swift/Swift5常用核心语法1-基础语法.md) <br> [Swift5常用核心语法2-面向对象语法1](swift/Swift5常用核心语法2-面向对象语法1.md) <br> [Swift5常用核心语法2-面向对象语法2](swift/Swift5常用核心语法2-面向对象语法2.md) <br> [Swift5常用核心语法3-其他常用语法](swift/Swift5常用核心语法3-其他常用语法.md) <br> [Swift5应用实践常用技术点](swift/Swift5应用实践常用技术点.md) |
| objective-c | [OC语法之OC对象本质](objective-c/OC对象本质.md) <br> [OC语法之Notification](objective-c/Notification.md) <br> [OC语法之KVC](objective-c/KVC.md) <br> [OC语法之KVO](objective-c/KVO.md) <br> [OC语法之Category](objective-c/Category.md) |
| Block | [Block之内存管理](block/block的内存管理.md) <br> [Block之循环引用](block/block的循环引用.md) <br> [深入理解OC/C++闭包](block/深入理解OC/C++闭包.md) |
| Runtime | [Runtime之Runtime的原理](runtime/Runtime之Runtime的原理.md) <br> [Runtime之消息发送机制](runtime/Runtime之消息发送机制.md) <br> [Runtime之Runtime的应用](runtime/Runtime之Runtime的应用.md) |
| Runloop | [Runloop原理和使用](runloop/Runloop.md) |
| 多线程 | [多线程之GCD](multi-threading/多线程之GCD.md) <br> [多线程之线程保活](multi-threading/多线程之线程保活.md) <br> [多线程之线程同步方案](multi-threading/多线程之线程同步方案.md) <br> [@synchronized原理](multi-threading/synchronized.md) |
| 内存管理 | [内存管理之内存布局](memory-management/内存布局.md) <br> [内存管理之属性和成员变量的修饰符](memory-management/属性和成员变量的修饰符.md) <br> [内存管理之TaggedPointer](memory-management/TaggedPointer.md) <br> [内存管理之定时器的循环引用](memory-management/定时器的循环引用.md) <br> [内存管理之3种内存管理机制](memory-management/3种内存管理机制.md) |
| 性能优化 | [iOS各种Crash防护](performance-optimization/iOS各种Crash防护.md) <br> [抖音品质建设 - iOS启动优化《原理篇》](performance-optimization/抖音品质建设-iOS启动优化《原理篇》.md) <br> [性能优化之启动优化](performance-optimization/性能优化之启动优化.md) <br> [性能优化之卡顿优化](performance-optimization/性能优化之卡顿优化.md)|
| Architecture | [谈谈 MVX 中的 Model](architecture/mvx-model.md) <br> [谈谈 MVX 中的 View](architecture/mvx-view.md) <br> [谈谈 MVX 中的 Controller](architecture/mvx-controller.md) <br> [浅谈 MVC、MVP 和 MVVM 架构模式](architecture/mvx.md) |
| 代码技巧和规范 | [Swift提高代码质量的一些Tips](代码技巧和规范/Swift提高代码质量的一些Tips.md) <br> [《Effective Objective-C》干货三部曲（一）：概念篇](代码技巧和规范/《EffectiveObjective-C》干货三部曲（一）：概念篇.md) <br> [《Effective Objective-C 》干货三部曲（二）：规范篇](代码技巧和规范/《EffectiveObjective-C》干货三部曲（二）：规范篇.md) <br> [《Effective Objective-C 》干货三部曲（三）：技巧篇](代码技巧和规范/《EffectiveObjective-C》干货三部曲（三）：技巧篇.md)|


## [iOS第三方库源码解析](https://github.com/shenchunxing/ios-third-party-analysis/blob/master/README.md)


## [Flutter](https://github.com/shenchunxing/better-flutter-developer/blob/master)

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

