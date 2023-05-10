前言
==

> 之前,我们在探索动画及渲染相关原理的时候,我们输出了几篇文章,解答了`iOS动画是如何渲染,特效是如何工作的疑惑`。我们深感系统设计者在创作这些系统框架的时候,是如此脑洞大开,也 **`深深意识到了解一门技术的底层原理对于从事该方面工作的重要性。`**
> 
> 因此我们决定 **`进一步探究iOS底层原理的任务`**。继上一篇文章对`GCD`的 `dispatch_get_global全局并发队列_queue+dispatch_sync同步函数`、`dispatch_get_global全局并发队列_queue+dispatch_sync异步函数`、`GCD单例`、`GCD线程死锁`探索之后,本篇文章将继续对GCD多线程底层原理的探索

一、栅栏函数基本介绍dispatch\_barrier\_async与dispatch\_barrier\_sync
==========================================================

1.1 栅栏函数的作用
-----------

**栅栏函数的作⽤**：

> 最直接的作⽤: `控制任务执⾏顺序`，也就是达到同步的效果

*   `dispatch_barrier_async`：前面的任务执行完毕，才会来到这里
*   `dispatch_barrier_sync`：作用相同，但是这个会堵塞线程，影响后面的执行

> **`注意`** ：栅栏函数只能控制同一并发队列

1.2 栅栏函数使用举例
------------

*   `dispatch_barrier_async` 举例

![dispatch_barrier_async举例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/28b1fe14c3074a258413b6e4ff9d11d8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   运行结果如下：

![控制台打印结果](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e70c9b91c1734a609bb10fe1a16e8301~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   在同一个队列里面，`栅栏函数`前面的任务执行完了，栅栏函数里面的任务可以执行，但是不会`堵塞线程`。
*   栅栏函数后面的任务还是可以执行的。但是栅栏函数前面的任务，是一定在栅栏函数内部任务之前执行的。

> 也就是`任务 1` 和`任务 2` 是必然在栅栏函数前面执行。

*   `dispatch_barrier_sync`：

代码还是👆上面的代码，就是把`栅栏函数`的`异步`改成`同步`了，看看会发生什么样的效果？

![dispatch_barrier_sync举例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b68f0fd2128c4418a45e2aafc7c6d495~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   控制台打印结果如下：

![打印结果](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/00b65163de934e7bae842fadec87ab59~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   栅栏函数前面的任务还是正常执行了，但是后面的任务在栅栏函数的后面执行
*   栅栏函数堵塞了线程，栅栏函数后面的任务在栅栏函数的任务执行完成，才会去执行

> 还记得上面的一句话吗：`栅栏函数只能控制同一并发队列`，那么我们试试不是同一个并发队列情况，栅栏函数是否可以拦截住呢？

![不是同一个队列情况举例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1fbf9e5a78234183b043fff21197fd42~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们把`栅栏函数`放在了另一个并发的队列里面，发现并没有`拦截`住任务的执行，那么是不是`异步`的原因呢？

那么现在去改成`同步`看看能不能拦住呢？

![不是同一个队列情况举例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/44e6599b908c44739748032e715dea95~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从运行的结果来看，发现还是拦不住，说明不是同一个并发的队列，不管栅栏函数是不是同步或者异步，都是拦截不住的，只能是同一个并发队列才可以！

我们再来举个例子🌰，使用`全局并发队列`看看

![全局并发队列举例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/943cfbc49ee74482a4050a97ed9b6ac9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从打印结果来看，`全局并发队列`也是拦不住的，只能是`自定义`的`并发队列`才可以，这是为什么呢？去底层源码看看是否可以找到答案！

二、 栅栏函数源码分析
===========

2.1 流程跟踪
--------

上面已经对`栅栏函数`的作用有一个大致的认识，那么底层的实现逻辑是怎么样的呢？现在就去探索一下。

在源码里面搜索`dispatch_barrier_sync`，跟流程会走到`_dispatch_barrier_sync_f` \-- > `_dispatch_barrier_sync_f_inline`

![_dispatch_barrier_sync_f_inline](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/be1c3ba7fdc94364a8c8767acfb96963~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

这个`_dispatch_barrier_sync_f_inline` 方法我们之前分析`死锁`的时候来过这里面，通过符号断点，这里会走`_dispatch_sync_f_slow`方法，这里设置了`DC_FLAG_BARRIER`的标签，对栅栏做标记！

![_dispatch_sync_f_slow](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b52894aff9454b8b91d8de2dae134aa3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

这里也是之前同步产生死锁的时候来过的，通过下符号断点继续跟踪流程。

![符号断点跟踪调试](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1c3e136fc4ea48a38c5bceff2abb0451~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

由此跟踪的流程为：`_dispatch_sync_f_slow` --> `_dispatch_sync_invoke_and_complete_recurse` --> `_dispatch_sync_complete_recurse`，继续在源码里面跟踪发现定位到了这个`_dispatch_sync_complete_recurse`方法。

![_dispatch_sync_complete_recurse](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87df9d38ebe4466c816e337043f4b1f8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

这里是一个 `do while`循环，判断当前队列里面是否有`barrier`，有的话就`dx_wakeup`唤醒执行，直到任务执行完成了，才会执行`_dispatch_lane_non_barrier_complete`，表示当前队列任务已经执行完成了，并且没有栅栏函数了就会继续往下面的流程走。

    #define dx_wakeup(x, y, z) dx_vtable(x)->dq_wakeup(x, y, z)
    复制代码

那么现在去看看`dq_wakeup`

![dq_wakeup](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f5fbd421cd9a43f1b0303d4952c6e45a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

这里我们之前分析同步和异步的时候也来过这里，这里全局并发的是 `_dispatch_root_queue_wakeup`,串行和并发的是`_dispatch_lane_wakeup`，那么两者有什么不一样呢？

2.2 自定义的并发队列分析
--------------

我们先去看看自定义的并发队列的`_dispatch_lane_wakeup`

    _dispatch_lane_wakeup(dispatch_lane_class_t dqu, dispatch_qos_t qos,
    		dispatch_wakeup_flags_t flags)
    {
    	dispatch_queue_wakeup_target_t target = DISPATCH_QUEUE_WAKEUP_NONE;
    
    	if (unlikely(flags & DISPATCH_WAKEUP_BARRIER_COMPLETE)) {
    		return _dispatch_lane_barrier_complete(dqu, qos, flags);
    	}
    	if (_dispatch_queue_class_probe(dqu)) {
    		target = DISPATCH_QUEUE_WAKEUP_TARGET;
    	}
    	return _dispatch_queue_wakeup(dqu, qos, flags, target);
    }
    复制代码

*   判断是否为`barrier`形式的，会调用`_dispatch_lane_barrier_complete`方法处理
*   如果没有`barrier`形式的，则走正常的并发队列流程，调用`_dispatch_queue_wakeup`方法。
*   \_dispatch\_lane\_barrier\_complete

![_dispatch_lane_barrier_complete](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8ab0e59de834ca7905884889ccac8c8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   如果是串行队列，则会进行等待，等待其他的任务执行完成，再按顺序执行
*   如果是并发队列，则会调用`_dispatch_lane_drain_non_barriers`方法将栅栏之前的任务执行完成。
*   最后会调用`_dispatch_lane_class_barrier_complete`方法，也就是把栅栏拔掉了，不拦了，从而执行栅栏之后的任务。

![_dispatch_lane_class_barrier_complete](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1557769cc7124f41ab269d4aab4712cd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2.3 全局并发队列分析
------------

*   全局并发队列，`dx_wakeup`对应的是`_dispatch_root_queue_wakeup`方法，查看源码实现

    void
    _dispatch_root_queue_wakeup(dispatch_queue_global_t dq,
    		DISPATCH_UNUSED dispatch_qos_t qos, dispatch_wakeup_flags_t flags)
    {
    	if (!(flags & DISPATCH_WAKEUP_BLOCK_WAIT)) {
    		DISPATCH_INTERNAL_CRASH(dq->dq_priority,
    				"Don't try to wake up or override a root queue");
    	}
    	if (flags & DISPATCH_WAKEUP_CONSUME_2) {
    		return _dispatch_release_2_tailcall(dq);
    	}
    }
    复制代码

*   全局并发队列这个里面，并没有对`barrier`的判断和处理，就是按照正常的并发队列来处理。
*   全局并发队列为什么没有对栅栏函数进行处理呢？因为全局并发队列除了被我们使用，系统也在使用。
*   如果添加了栅栏函数，会导致队列运行的阻塞，从而影响系统级的运行，所以栅栏函数也就不适用于全局并发队列。

三、 信号量dispatch\_semaphore
=========================

3.1 信号量介绍
---------

信号量在`GCD`中是指`Dispatch Semaphore`，是一种持有计数的信号的东西。有如下三个方法。

*   `dispatch_semaphore_create` : 创建信号量
*   `dispatch_semaphore_wait` : 信号量等待
*   `dispatch_semaphore_signal` : 信号量释放

3.2 信号量举例
---------

在并发队列里面，可以使用信号量控制，最大并发数，如下代码：

![信号量举例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2d077ed2b5e0491f941714e17a778a45~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   信号量举例打印结果

![信号量举例打印结果](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2b72eb89e2ee482b941ef68e2da3d889~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

这里一共创建了 `4` 个任务，异步并发执行，我在创建信号量的时候，设置了最大并发数为 `2`

      dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_semaphore_t sem = dispatch_semaphore_create(2);
    复制代码

> 从运行的动图，可以看到，每次都是两个任务一起执行了，打印的结果一目了然。

那么再举个例子看看，设置信号量并发数为`0`会怎么样呢？

![设置信号量并发数为0](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/034795f6c97345f49689d02905452bf0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 设置信号量并发数为`0`，就相当于加锁的作用，`dispatch_semaphore_wait`堵住了`任务1`让其等待，等`任务 2`执行完了，`dispatch_semaphore_signal`发送信号，我执行完了，你去执行吧！

> 这样到底信号量是怎么样等待，又是怎么样发送信号的呢？

3.3 信号量分析
---------

看看`dispatch_semaphore_create`的 `api`的说明

![dispatch_semaphore_create](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fe55ec2a1fbc4cf488c7d8d48a5876b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   当两个线程需要协调特定事件的完成时，为该值传递`0`很有用。
*   传递大于`0`的值对于管理有限的资源池很有用，其中池大小等于该值。
*   信号量的起始值。 传递小于`信号量的起始值。 传递小于零的值将导致返回 NULL。`的值将导致返回 `NULL`，也就是小于`0`就不会正常执行。

> 总结来说，就是可以控制线程池中的最多并发数量

### 3.3.1 dispatch\_semaphore\_signal

*   **`dispatch_semaphore_signal`**

![dispatch_semaphore_signal](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6818d0de8f9a4f0890651dbc221adf53~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   在`dispatch_semaphore_signal`里面`os_atomic_inc2o`原子操作自增加`1`，然后会判断，如果`value > 0`，就会返回`0`。
*   例如 `value`加`1` 之后还是小于 `0`，说明是一个`负数`，也就是调用`dispatch_semaphore_wait`次数太多了，`dispatch_semaphore_wait`是做减操作的，等会后面会分析。
*   加一次后依然小于`0`就报异常`"Unbalanced call to dispatch_semaphore_signal()`，然后会调用`_dispatch_semaphore_signal_slow`方法的，做容错的处理，`_dispatch_sema4_signal`是一个`do while` 循环

    _dispatch_semaphore_signal_slow(dispatch_semaphore_t dsema)
    {
    	_dispatch_sema4_create(&dsema->dsema_sema, _DSEMA4_POLICY_FIFO);
    	_dispatch_sema4_signal(&dsema->dsema_sema, 1);
    	return 1;
    }
    复制代码

*   \_dispatch\_sema4\_signal

    void
    _dispatch_sema4_signal(_dispatch_sema4_t *sema, long count)
    {
    	do {
    		int ret = sem_post(sema);
    		DISPATCH_SEMAPHORE_VERIFY_RET(ret);
    	} while (--count);
    }
    复制代码

### 3.3.2 dispatch\_semaphore\_wait

*   **`dispatch_semaphore_wait`**

`dispatch_semaphore_wait` 源码如下： ![dispatch_semaphore_wait](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/644387eb4f5246c88850a37a1a296bee~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   `os_atomic_dec2o`进行原子自减`1`操作，也就是对`value`值进行减操作，控制可并发数。
*   如果可并发数为`2`，则调用该方法后，变为`1`，表示现在并发数为 `1`，剩下还可同时执行`1`个任务。如果初始值是`0`，减操作之后为`负数`，则会调用`_dispatch_semaphore_wait_slow`方法。

`_dispatch_semaphore_wait_slow`方法源码如下：

*   `_dispatch_semaphore_wait_slow`

![_dispatch_semaphore_wait_slow](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd44db66b546428ea79875cf29cb522e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   这里对`dispatch_time_t timeout` 进行判断处理，我们前面的例子里面传的是`DISPATCH_TIME_FOREVER`，那么会调用`_dispatch_sema4_wait`方法

    void
    _dispatch_sema4_wait(_dispatch_sema4_t *sema)
    {
    	kern_return_t kr;
    	do {
    		kr = semaphore_wait(*sema);
    	} while (kr == KERN_ABORTED);
    	DISPATCH_SEMAPHORE_VERIFY_KR(kr);
    }
    复制代码

`_dispatch_sema4_wait`方法里面是一个`do-while`循环，当不满足条件时，会一直循环下去，从而导致流程的阻塞。这也就解释了上面举例案里面的执行结果。

上面举例里面就相当于，下图中的情况

![分析](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3d324b0d957e4e56a89fa096f63e585f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

在上图框框的地方，① 相当于②，这里是`do-while`循环，所以会执行`任务 2`，`任务 1`一直在循环等待。

三、 总结
=====

3.1 栅栏函数
--------

*   使用栅栏函数的时候，要和其他需要执行的任务必须在同一个队列中
*   使用栅栏函数不能使用全局并发队列
*   除了我们使用，系统也在使用。
*   如果添加了栅栏函数，会导致队列运行的阻塞，影响系统级的运行

3.2 信号量
-------

*   `dispatch_semaphore_wait` 信号量等待，内部是对并发数做自减操作，如果为 小于 `0`，会执行`_dispatch_semaphore_wait_slow`然后调用`_dispatch_sema4_wait`是一个`do-while`，知道满足条件结束循环
*   `dispatch_semaphore_signal` 信号量释放 ，内部是对并发数做自加操作，直到大于`0`时，为可操作
*   保持`线程同步`，将`异步执行`任务转换为`同步执行`任务
*   保证`线程安全`，为`线程加锁`，相当于`互斥锁`

专题系列文章
======

### 1.前知识

*   **[01-探究iOS底层原理|综述](https://juejin.cn/post/7089043618803122183/ "https://juejin.cn/post/7089043618803122183/")**
*   **[02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】](https://juejin.cn/post/7093842449998561316/ "https://juejin.cn/post/7093842449998561316/")**
*   **[03-探究iOS底层原理|LLDB](https://juejin.cn/post/7095079758844674056 "https://juejin.cn/post/7095079758844674056")**
*   **[04-探究iOS底层原理|ARM64汇编](https://juejin.cn/post/7115302848270696485/ "https://juejin.cn/post/7115302848270696485/")**

### 2\. 基于OC语言探索iOS底层原理

*   **[05-探究iOS底层原理|OC的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")**
*   **[06-探究iOS底层原理|OC对象的本质](https://juejin.cn/post/7094503681684406302 "https://juejin.cn/post/7094503681684406302")**
*   **[07-探究iOS底层原理|几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012")**
*   **[08-探究iOS底层原理|Category底层结构、App启动时Class与Category装载过程、load 和 initialize 执行、关联对象](https://juejin.cn/post/7096480684847415303 "https://juejin.cn/post/7096480684847415303")**
*   **[09-探究iOS底层原理|KVO](https://juejin.cn/post/7115318628563550244/ "https://juejin.cn/post/7115318628563550244/")**
*   **[10-探究iOS底层原理|KVC](https://juejin.cn/post/7115320523805949960/ "https://juejin.cn/post/7115320523805949960/")**
*   **[11-探究iOS底层原理|探索Block的本质|【Block的数据类型(本质)与内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用】](https://juejin.cn/post/7115809219319693320/ "https://juejin.cn/post/7115809219319693320/")**
*   **[12-探究iOS底层原理|Runtime1【isa详解、class的结构、方法缓存cache\_t】](https://juejin.cn/post/7116103432095662111 "https://juejin.cn/post/7116103432095662111")**
*   **[13-探究iOS底层原理|Runtime2【消息处理(发送、转发)&&动态方法解析、super的本质】](https://juejin.cn/post/7116147057739431950 "https://juejin.cn/post/7116147057739431950")**
*   **[14-探究iOS底层原理|Runtime3【Runtime的相关应用】](https://juejin.cn/post/7116291178365976590/ "https://juejin.cn/post/7116291178365976590/")**
*   **[15-探究iOS底层原理|RunLoop【两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer】](https://juejin.cn/post/7116515606597206030/ "https://juejin.cn/post/7116515606597206030/")**
*   **[16-探究iOS底层原理|RunLoop的应用](https://juejin.cn/post/7116521653667889165/ "https://juejin.cn/post/7116521653667889165/")**
*   **[17-探究iOS底层原理|多线程技术的底层原理【GCD源码分析1:主队列、串行队列&&并行队列、全局并发队列】](https://juejin.cn/post/7116821775127674916/ "https://juejin.cn/post/7116821775127674916/")**
*   **[18-探究iOS底层原理|多线程技术【GCD源码分析1:dispatch\_get\_global\_queue与dispatch\_(a)sync、单例、线程死锁】](https://juejin.cn/post/7116878578091819045 "https://juejin.cn/post/7116878578091819045")**
*   **[19-探究iOS底层原理|多线程技术【GCD源码分析2:栅栏函数dispatch\_barrier\_(a)sync、信号量dispatch\_semaphore】](https://juejin.cn/post/7116897833126625316 "https://juejin.cn/post/7116897833126625316")**
*   **[20-探究iOS底层原理|多线程技术【GCD源码分析3:线程调度组dispatch\_group、事件源dispatch Source】](https://juejin.cn/post/7116898446358888485/ "https://juejin.cn/post/7116898446358888485/")**
*   **[21-探究iOS底层原理|多线程技术【线程锁：自旋锁、互斥锁、递归锁】](https://juejin.cn/post/7116898868737867789/ "https://juejin.cn/post/7116898868737867789/")**
*   **[22-探究iOS底层原理|多线程技术【原子锁atomic、gcd Timer、NSTimer、CADisplayLink】](https://juejin.cn/post/7116907029465137165 "https://juejin.cn/post/7116907029465137165")**
*   **[23-探究iOS底层原理|内存管理【Mach-O文件、Tagged Pointer、对象的内存管理、copy、引用计数、weak指针、autorelease](https://juejin.cn/post/7117274106940096520 "https://juejin.cn/post/7117274106940096520")**

### 3\. 基于Swift语言探索iOS底层原理

关于`函数`、`枚举`、`可选项`、`结构体`、`类`、`闭包`、`属性`、`方法`、`swift多态原理`、`String`、`Array`、`Dictionary`、`引用计数`、`MetaData`等Swift基本语法和相关的底层原理文章有如下几篇:

*   [Swift5核心语法1-基础语法](https://juejin.cn/post/7119020967430455327 "https://juejin.cn/post/7119020967430455327")
*   [Swift5核心语法2-面向对象语法1](https://juejin.cn/post/7119510159109390343 "https://juejin.cn/post/7119510159109390343")
*   [Swift5核心语法2-面向对象语法2](https://juejin.cn/post/7119513630550261774 "https://juejin.cn/post/7119513630550261774")
*   [Swift5常用核心语法3-其它常用语法](https://juejin.cn/post/7119714488181325860 "https://juejin.cn/post/7119714488181325860")
*   [Swift5应用实践常用技术点](https://juejin.cn/post/7119722433589805064 "https://juejin.cn/post/7119722433589805064")

其它底层原理专题
========

### 1.底层原理相关专题

*   [01-计算机原理|计算机图形渲染原理这篇文章](https://juejin.cn/post/7018755998823219213 "https://juejin.cn/post/7018755998823219213")
*   [02-计算机原理|移动终端屏幕成像与卡顿 ](https://juejin.cn/post/7019117942377807908 "https://juejin.cn/post/7019117942377807908")

### 2.iOS相关专题

*   [01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理](https://juejin.cn/post/7019193784806146079 "https://juejin.cn/post/7019193784806146079")
*   [02-iOS底层原理|iOS动画渲染原理](https://juejin.cn/post/7019200157119938590 "https://juejin.cn/post/7019200157119938590")
*   [03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理](https://juejin.cn/post/7019497906650497061/ "https://juejin.cn/post/7019497906650497061/")
*   [04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案](https://juejin.cn/post/7020613901033144351 "https://juejin.cn/post/7020613901033144351")

### 3.webApp相关专题

*   [01-Web和类RN大前端的渲染原理](https://juejin.cn/post/7021035020445810718/ "https://juejin.cn/post/7021035020445810718/")

### 4.跨平台开发方案相关专题

*   [01-Flutter页面渲染原理](https://juejin.cn/post/7021057396147486750/ "https://juejin.cn/post/7021057396147486750/")

### 5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较

*   [01-Native、WebApp、跨平台开发三种方案性能比较](https://juejin.cn/post/7021071990723182606/ "https://juejin.cn/post/7021071990723182606/")

### 6.Android、HarmonyOS页面渲染专题

*   [01-Android页面渲染原理](https://juejin.cn/post/7021840737431978020/ "https://juejin.cn/post/7021840737431978020/")
*   [02-HarmonyOS页面渲染原理](# "#") (`待输出`)

### 7.小程序页面渲染专题

*   [01-小程序框架渲染原理](https://juejin.cn/post/7021414123346853919 "https://juejin.cn/post/7021414123346853919")