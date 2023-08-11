一、 dispatch\_get\_global\_queue全局并发队列+dispatch\_sync同步函数
========================================================

`dq->dq_width == 1` 为串行队列，那么并发队列该怎么走呢？ 如下图，走的是下面的框框中流程 ![_dispatch_sync_f_inline](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/08ef812965bf44d6bc34f180c644930a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 但是这么多的分支，到底是走的哪一个呢？通过对`_dispatch_sync_f_slow`、 `_dispatch_sync_recurse` 、`_dispatch_introspection_sync_begin` 、`_dispatch_sync_invoke_and_complete`方法下符号断点，进行跟踪调试。

*   符号断点调试

![符号断点调试](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9c1f9163e1174338ae4658ce5759c224~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 通过下符号断点跟踪，发现走了`_dispatch_sync_f_slow`，如下图所示：

![断点在_dispatch_sync_f_slow处](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e1b7ad4850a740f19cbb9d3a00e25767~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 通过阅读源码，发现一个有意思的事情，就是`_dispatch_sync_invoke_and_complete`方法

![_dispatch_sync_invoke_and_complete](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3302cf52cbdb4f86a2e7793c9f49ff9e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   `_dispatch_sync_invoke_and_complete`

![_dispatch_sync_invoke_and_complete](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ede863392ebf4521a829ca848c66dfea~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

在这个`_dispatch_sync_invoke_and_complete`方法的第三个参数是`func` 也是需要执行的任务，但是 `func` 的后面的整体也是一个参数，也就是 `DISPATCH_TRACE_ARG( _dispatch_trace_item_sync_push_pop(dq, ctxt, func, dc_flags))` 整体为一个参数，这就有意思了，中间居然没有逗号分隔开。老铁，你这很特别啊！够长的啊！

那么去`DISPATCH_TRACE_ARG`定义看看 ![DISPATCH_TRACE_ARG](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2da90d238fe141b3b52528f488d7568c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 在`DISPATCH_TRACE_ARG`的宏定义里面，你们有没有发现，这里居然把`逗号`放在了里面，好家伙，宏定义里面还可以这么玩，苹果工程师还真有意思哈！ ![DISPATCH_TRACE_ARG](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3bf0221ae4c540f1aa9467cbedefdff5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 通过全局的搜索，发现这个宏定义有两处，一个有逗号，一个没有逗号，这就是根据不同的条件，进行设置，相当于是一个`可选的参数`，这一波操作又是非常的细节了！

既然下符号断点会走`_dispatch_sync_f_slow`方法，现在就去看看这个方法

*   `_dispatch_sync_f_slow`

![_dispatch_sync_f_slow](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d3728fab7f484e7da58c4779fd5cbdd6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 这里又是很多的分支，又通过下符号断点，发现走的是`_dispatch_sync_function_invoke`方法里面

*   `_dispatch_sync_function_invoke`

    static void
    _dispatch_sync_function_invoke(dispatch_queue_class_t dq, void *ctxt,
    		dispatch_function_t func)
    {
    	_dispatch_sync_function_invoke_inline(dq, ctxt, func);
    }
    复制代码

*   `_dispatch_sync_function_invoke_inline`

    static inline void
    _dispatch_sync_function_invoke_inline(dispatch_queue_class_t dq, void *ctxt,
    		dispatch_function_t func)
    {
    	dispatch_thread_frame_s dtf;
    	_dispatch_thread_frame_push(&dtf, dq);
    	_dispatch_client_callout(ctxt, func);
    	_dispatch_perfmon_workitem_inc();
    	_dispatch_thread_frame_pop(&dtf);
    }
    复制代码

*   `push` 之后调用`callout`执行，最后再 `pop`，所以可以同步的执行任务

二、 dispatch\_async异步函数
======================

`dispatch_async`异步函数的任务，是包装在 `qos`里面的，那么现在跟踪流程，去看看

*   `dispatch_async`

![dispatch_async](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8b2c38423ab4cbdbb3cbfe5d4c03cb9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   `_dispatch_continuation_async`

![_dispatch_continuation_async](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a320c4df113d468d9cad2112a0251718~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   `dx_push`

![dx_push](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9da386cad473466b8adcb59d6df2093f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 搜索`dx_push`调用的地方 ![在这里插入图片描述](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/45afe3b750c045d2b598d651688980fa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 这里就先去看看并发队列里面的`dq_push`吧，

*   \_dispatch\_lane\_concurrent\_push

![_dispatch_lane_concurrent_push](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc2913518e2f4b93adc004683b11df12~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 这里`if`里面有对`栅栏函数`（\_dispatch\_object\_is\_barrier）的判断，栅栏函数这里就不分析了，后续的博客里面会分析的。

在`_dispatch_lane_concurrent_push`里面会去调用`_dispatch_lane_push`方法，在上面搜索`dx_push`的图里面，可以看到，在串行队列里面是直接调用了`_dispatch_lane_push`，也就是说`串行`和`并发`都会走这个方法。

*   \_dispatch\_lane\_push

![_dispatch_lane_push](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e701d6eae25a4228944baed1bab1dde7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 最后去调用`dx_wakeup`，再去搜索看看 ![dx_wakeup](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ef9a2f9bb142452396f98aae5dffd576~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `dx_wakeup` 是一个宏定义，看看`dq_wakeup`哪里调用了 ![dx_wakeup调用地方](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c806100e888249bc989d1ba93a0bbcdc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 如上图可以发现，串行和并发都是`_dispatch_lane_wakeup`，全局的是`_dispatch_root_queue_wakeup` ![_dispatch_lane_wakeup](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8060f73dc7084d2e8e3eec5d60f37813~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   \_dispatch\_queue\_wakeup

![_dispatch_queue_wakeup](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b397479f56340319e820784cc0813bc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过下符号断点会走`_dispatch_lane_class_barrier_complete` ![_dispatch_lane_class_barrier_complete](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/92df7531e1b04bfcbcdbe7702b58bd33~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `_dispatch_lane_class_barrier_complete`里面循环递归一些操作，还看到了一个系统的函数`os_atomic_rmw_loop2o`，在这个方法里面要么返回`dx_wakeup`或者做其他的一些处理。

![并发队列信息](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bf3ee8d3cfd843ae958eeb2e79adb4cc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![_dispatch_lane_concurrent_push](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/96d3ad16e48c4e5ab18c6833e8e6309d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![_dispatch_continuation_redirect_push](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0f55b628af6e4842a3d5e15589420312~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

    #define dx_push(x, y, z) dx_vtable(x)->dq_push(x, y, z)
    复制代码

通过跟流程和下符号断点，会走全局并发队列的`_dispatch_root_queue_push`方法。通过下符号断点，跟踪源码，最终定位到一个重要的方法`_dispatch_root_queue_poke_slow`

    dispatch_root_queue_push_inline(dispatch_queue_global_t dq,
    		dispatch_object_t _head, dispatch_object_t _tail, int n)
    {
    	struct dispatch_object_s *hd = _head._do, *tl = _tail._do;
    	if (unlikely(os_mpsc_push_list(os_mpsc(dq, dq_items), hd, tl, do_next))) {
    		return _dispatch_root_queue_poke(dq, n, 0);
    	}
    }
    复制代码

*   \_dispatch\_root\_queue\_poke

![_dispatch_root_queue_poke](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/993c25efc3954f0eb67da5f7bf277db3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   \_dispatch\_root\_queue\_poke\_slow

![_dispatch_root_queue_poke_slow](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4a1130cc2535440498341c5a8f23b17a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `_dispatch_root_queues_init方法`使用了单例。

    static inline void
    _dispatch_root_queues_init(void)
    {
    	dispatch_once_f(&_dispatch_root_queues_pred, NULL,
    	_dispatch_root_queues_init_once);
    }
    复制代码

在该方法中，采用单例的方式进行了线程池的初始化处理、工作队列的配置、工作队列的初始化等工作。同时这里有一个关键的设置，执行函数的设置，也就是将任务执行的函数被统一设置成了`_dispatch_worker_thread2`。见下图： ![_dispatch_root_queues_init_once](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e10beb6a3ee4e34a193905a4ebf59bd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   调用堆栈验证

![堆栈信息](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e9f7e64925f34812b6230eeaf326f12b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

调用执行是通过`workloop`工作循环调用起来的，也就是说并不是及时调用的，而是通过`os`完成调用，说明异步调用的关键是在需要执行的时候能够获取对应的方法，进行异步处理，而同步函数是直接调用。

在上面的流程中`_dispatch_root_queue_poke_slow` 方法，还没有继续分析，现在就去分析，如果是全局队列，此时会创建线程进行执行任务 ![全局队列处理](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4802d28ee7ba46f3bdf3ff53eca18c73~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 对线程池进行处理，从线程池中获取线程，执行任务，同时判断线程池的变化 ![线程池进行处理](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b3f044a012f54774901e5002201e548f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `remaining`可以理解为当前可用线程数，当可用线程数等于`0`时，线程池已满`pthread pool is full`，直接`return`。底层通过`pthread`完成线程的开辟 ![在这里插入图片描述](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c0dc99067cba4c46af27e5af6cd92620~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 就是`_dispatch_worker_thread2`是通过`pthread`完成`oc_atmoic`原子触发

> 那么我们的线程可以开辟多少线程条呢？

![线程池初始化](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0c5208a77d0f439ea3049f51ab2048ae~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

队列线程池的大小为：`dgq_thread_pool_size`。`dgq_thread_pool_size = thread_pool_size` ，默认大小如下： ![DISPATCH_WORKQ_MAX_PTHREAD_COUNT](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e87bdb75a7fa45f5a89ff30e0de0cfed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `255`表示理论上线程池的最大数量。但是实际能开辟多少呢，这个不确定。在苹果官方完整[Thread Management](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Farchive%2Fdocumentation%2FCocoa%2FConceptual%2FMultithreading%2FCreatingThreads%2FCreatingThreads.html%23%2F%2Fapple_ref%2Fdoc%2Fuid%2F10000057i-CH15-SW7 "https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Farchive%2Fdocumentation%2FCocoa%2FConceptual%2FMultithreading%2FCreatingThreads%2FCreatingThreads.html%23%2F%2Fapple_ref%2Fdoc%2Fuid%2F10000057i-CH15-SW7")中，有相关的说明，辅助线程的最小允许堆栈大小为 `16` KB，并且堆栈大小必须是`4`KB 的倍数。见下图： ![Thread Management](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/342f12f0a62943bc93d4fc5d98c0e026~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 也就是说，一个辅助线程的栈空间是`512KB`，而一个线程所占用的最小空间是`16KB`，也就是说栈空间一定的情况下，开辟线程所需的内存越大，所能开辟的线程数就越小。针对一个`4GB`内存的`iOS`真机来说，内存分为内核态和用户态，如果内核态全部用于创建线程，也就是`1GB`的空间，也就是说最多能开辟`1024KB / 16KB`个线程。当然这也只是一个理论值。

三、 单例
=====

上面提到了单例，那么接下来就去分析一下单例 来看看简单的单例使用：

       static dispatch_once_t token;
    
       dispatch_once(&token, ^{
           // 代码执行
       });
    复制代码

*   单例的定义如下：

![单例定义](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4f94ce139e4740aea00a54876d260535~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

    void
    _dispatch_once(dispatch_once_t *predicate,
    		DISPATCH_NOESCAPE dispatch_block_t block)
    {
    	if (DISPATCH_EXPECT(*predicate, ~0l) != ~0l) {
    		dispatch_once(predicate, block);
    	} else {
    		dispatch_compiler_barrier();
    	}
    	DISPATCH_COMPILER_CAN_ASSUME(*predicate == ~0l);
    }
    #undef dispatch_once
    #define dispatch_once _dispatch_once
    #endif
    #endif // DISPATCH_ONCE_INLINE_FASTPATH
    复制代码

针对不同的情况作了一些特殊处理，比如`栅栏函数`等，这里只分析`dispatch_once`，进入`dispatch_once`实现 ![dispatch_once](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ece1a1739d794fdb962d0a0c764d0df3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 单例是只会执行一次，那么这里就是利用 `val`参数来进行控制的，接着去`dispatch_once_f`里面看看 ![在这里插入图片描述](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a1431089b4534613b511caa811a0db97~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 对`l`的底层原子性进行关联，关联到`uintptr_t v`的一个变量，通过`os_atomic_load`从底层取出，关联到变量`v`上。如果`v`这个值等于`DLOCK_ONCE_DONE`，也就是已经处理过一次了，就会直接`return`返回

*   `_dispatch_once_gate_tryenter`

    static inline bool
    _dispatch_once_gate_tryenter(dispatch_once_gate_t l)
    {
    	return os_atomic_cmpxchg(&l->dgo_once, DLOCK_ONCE_UNLOCKED,
    			(uintptr_t)_dispatch_lock_value_for_self(), relaxed);
    }
    复制代码

`_dispatch_once_gate_tryenter`里面是进行原子操作，就是锁的处理，如果之前没有执行过，原子处理会比较它状态，进行解锁，最终会返回一个`bool`值，多线程情况下，只有一个能够获取锁返回`yes`。

    if (_dispatch_once_gate_tryenter(l)) {
         return _dispatch_once_callout(l, ctxt, func);
    }
    复制代码

通过`_dispatch_lock_value_for_self`上了一把锁，保证多线程安全。如果返回`yes`，就会执行`_dispatch_once_callout`方法，执行单例对应的任务，并对外广播

*   `_dispatch_once_callout`

    static void
    _dispatch_once_callout(dispatch_once_gate_t l, void *ctxt,
    		dispatch_function_t func)
    {
    	_dispatch_client_callout(ctxt, func);
    	_dispatch_once_gate_broadcast(l);
    }
    复制代码

*   `_dispatch_client_callout`执行任务
*   `_dispatch_once_gate_broadcast`对外广播，标记为 `done`
*   `_dispatch_once_gate_broadcast`广播

![_dispatch_once_gate_broadcast](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/78e0668404c4447295c6dbbdc973c0a2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 将`token`通过原子比对，如果不是`done`，则设为`done`。同时对`_dispatch_once_gate_tryenter`方法中的锁进行处理。

*   `_dispatch_once_mark_done`

![_dispatch_once_mark_done](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d3b8a7e388754c5dbbf99e7758f4b10a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `os_atomic_cmpxchg` 是一个宏定义，先进行比较再改变，先比较 `dgo`，在设置标记为`DLOCK_ONCE_DONE`也就是 `done`![os_atomic_cmpxchg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d1141832fcd9464297316b3829f62bcf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

当`token`标记为`done`之后，就会直接返回，如存在多线程处理，没有获取锁的情况，就会调用`_dispatch_once_wait`，如下下： ![单例执行方法](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f588266765104e4f9fbb1653ff673b0b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `_dispatch_once_wait`，进行等待，这里开启了`自旋锁`，内部进行原子处理，在`loop`过程中，如果发现已经被其他线程设置`once_done`了，则会进行放弃处理 ![_dispatch_once_wait](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29073600541a49439db22f86ee9185e3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 那么任务的执行交给谁了呢？ ![堆栈信息](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/88adb8ae943245b3812a582a05c60f49~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 通过打印堆栈信息，发现是交给了下层的线程，通过一些包装，给了底层的`pthread` ![在这里插入图片描述](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4ce41d957c3849dd93654a26a76f018d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 这就可以说 `GCD`底层是封装了`pthread` ，不管是 `iOS`还是 `Java`都是封装了底层的通用线程机制`pthread` 。

这里的执行是通过工作循环`workloop`,工作循环的调起受 OS（受 CPU调度执行的。）管控的，异步线程的异步体现在哪里呢？就是体现在是否可以获得，而不是立即执行，而同步函数是直接调用执行的，而这里并没有看到异步的直接调用执行。

四、 sync 和 async 的区别
===================

*   是否可以开启新的线程执行任务
*   任务的回调是否具有异步行、同步性
*   是否产生死锁问题

五、 死锁 源码分析
==========

在前面篇幅的分析中,我们得知,同步 `sync`函数的流程是:

*   `_dispatch_sync_f` -- >
*   `_dispatch_sync_f_inline` -- >
*   `_dispatch_barrier_sync_f`

![_dispatch_sync_f_inline](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5a565067489441591fdce56bbcde25a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 走到`_dispatch_barrier_sync_f`流程中，这与上篇博客的分析是一致的，因为这里`dq_width=1`，所以是`串行队列`，如果是`并发队列`，则会走到`_dispatch_sync_f_slow`，现在去`_dispatch_barrier_sync_f`方法里面看看

*   `_dispatch_barrier_sync_f`

    static void
    _dispatch_barrier_sync_f(dispatch_queue_t dq, void *ctxt,
    		dispatch_function_t func, uintptr_t dc_flags)
    {
    	_dispatch_barrier_sync_f_inline(dq, ctxt, func, dc_flags);
    }
    复制代码

这个方法又会调用`_dispatch_barrier_sync_f_inline`方法

![_dispatch_barrier_sync_f_inline](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/574f8480e96249fbbf9b0703e8c2f8aa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 在这个方法里面，会对队列进行判断，是否存在等待或者挂起状态

    //判断是否挂起、等待
    if (unlikely(!_dispatch_queue_try_acquire_barrier_sync(dl, tid))){
        // 添加任务
        return _dispatch_sync_f_slow(dl, ctxt, func, DC_FLAG_BARRIER, dl,
    				DC_FLAG_BARRIER | dc_flags);
    }
    复制代码

在之前的[博客里面](https://link.juejin.cn?target=https%3A%2F%2Fblog.csdn.net%2Fzjpjay%2Farticle%2Fdetails%2F119603586%3Fspm%3D1001.2014.3001.5501 "https://link.juejin.cn?target=https%3A%2F%2Fblog.csdn.net%2Fzjpjay%2Farticle%2Fdetails%2F119603586%3Fspm%3D1001.2014.3001.5501")也提到了`死锁`相关的内容，出现死锁会报和`_dispatch_sync_f_slow`相关的错误，如下：

![死锁](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/276a2af22b9f44a8a7d67e2994721292~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 虽然死锁会走`_dispatch_sync_f_slow`方法，但是死锁的报错不是`_dispatch_sync_f_slow`这个报错，而是如下图中所示的`0`处报错了

![死锁报错](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d08f143dd0f84086ae7dc32ecdc17a7f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

真报错的是`__DISPATCH_WAIT_FOR_QUEUE__`，那么现在去验证一下

*   `_dispatch_sync_f_slow`

![_dispatch_sync_f_slow](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7df8cf17031341dca18ab620dbf092c5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 在`_dispatch_sync_f_slow`方法内部，我们发现了刚刚死锁报错的`__DISPATCH_WAIT_FOR_QUEUE__`，现在去内部看看

*   `__DISPATCH_WAIT_FOR_QUEUE__`

![DISPATCH_WAIT_FOR_QUEUE](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/27541f107eeb4440809bd2f6c2ea3f90~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

在`__DISPATCH_WAIT_FOR_QUEUE__`内部，发现了和死锁报错信息基本一样，意思是：

> `dispatch_sync` 在当前线程已经拥有的队列上调用 ，对不起兄弟，我已经拥有她了，你来晚一步了

    if (unlikely(_dq_state_drain_locked_by(dq_state, dsc->dsc_waiter))) {
    		DISPATCH_CLIENT_CRASH((uintptr_t)dq_state,
    				"dispatch_sync called on queue "
    				"already owned by current thread");
    }
    复制代码

这个`dsc_waiter`是由前面`_dispatch_sync_f_slow`方法里面传过来来的

![dsc_waiter](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4e11287b417049e2be89bc8a9d3ea60d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> `_dispatch_tid_self()`是线程 `id`，定义如下

![_dispatch_tid_self()](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/50414e1166e04787b7cb33469e037e5a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

`_dispatch_thread_port`是线程的通道，现在再去看看线程状态的匹配

    //状态
    uint64_t dq_state = _dispatch_wait_prepare(dq);
    if (unlikely(_dq_state_drain_locked_by(dq_state, dsc->dsc_waiter))) {
            DISPATCH_CLIENT_CRASH((uintptr_t)dq_state,
                    "dispatch_sync called on queue "
                    "already owned by current thread");
    }
    复制代码

*   `_dq_state_drain_locked_by`

    static inline bool
    _dq_state_drain_locked_by(uint64_t dq_state, dispatch_tid tid)
    {
    	return _dispatch_lock_is_locked_by((dispatch_lock)dq_state, tid);
    }
    复制代码

*   `_dispatch_lock_is_locked_by`

    static inline bool
    _dispatch_lock_is_locked_by(dispatch_lock lock_value, dispatch_tid tid)
    {
    	// equivalent to _dispatch_lock_owner(lock_value) == tid
    	return ((lock_value ^ tid) & DLOCK_OWNER_MASK) == 0;
    }
    复制代码

*   `DLOCK_OWNER_MASK`

    #define DLOCK_OWNER_MASK			((dispatch_lock)0xfffffffc)
    复制代码

这里就是死锁的判断：`异或`再作`与`操作，也就是结果为`0`就是死锁。翻译一下就是`dq_state ^ dsc->dsc_waiter` 的结果为 `0`再和`DLOCK_OWNER_MASK`作`与`操作等于`0`。

那么`dq_state ^ dsc->dsc_waiter` 的结果什么情况下会为 `0`呢？异或是相同为`0`，因为`DLOCK_OWNER_MASK`是一个非常大的整数，所以`dq_state` 和 `dsc->dsc_waiter` 都是为`0`。

当前队列里面要等待的线程 `id` 和我调用的是一样，我已经处于`等待状态`，你现在有新的任务过来需要使用我去执行，这样产生了矛盾，进入`相互等待`状态，进而产生`死锁`。这就是串行队列执行同步任务产生死锁的原因！