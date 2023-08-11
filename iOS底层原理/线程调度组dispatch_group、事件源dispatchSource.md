一、线程调度组dispatch\_group
======================

1.1 调度组介绍
---------

> 调度组最直接的作用就是控制任务的执行顺序

*   `dispatch_group_create` ：创建调度组
*   `dispatch_group_async` ：进组的任务 执行
*   `dispatch_group_notify` ：进组任务执行完毕的通知
*   `dispatch_group_wait` ： 进组任务执行等待时间
*   `dispatch_group_enter` ：任务进组
*   `dispatch_group leave` ：任务出组

1.2 调度组举例
---------

下面举个调度组的应用举例

> 给图片添加水印，有两张水印照片需要网络请求，水印照片请求，完成之后，再添加到本地图片上面显示！

    //创建调度组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // 水印 1
    dispatch_group_async(group , queue, ^{
            NSString *logoStr1 = @"https://thirdqq.qlogo.cn/g?b=sdk&k=zeIp1PmCE6jff6BGSbjicKQ&s=140&t=1556562300";
            NSData *data1 = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoStr1]];
            UIImage *image1 = [UIImage imageWithData:data1];
            [self.mArray addObject:image1];
    });
    // 水印 1
    dispatch_group_async(group , queue, ^{
            NSString *logoStr2 = @"https://thirdwx.qlogo.cn/mmopen/vi_32/Q0j4TwGTfTJKuHEuLLyYK0Rbw9s9G8jpcnMzQCNsuYJRIRjCvltH6NibibtP73EkxXPR9RaWGHvmHT5n69wpKV2w/132";
            NSData *data2 = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoStr2]];
            UIImage *image2 = [UIImage imageWithData:data2];
            [self.mArray addObject:image2];
    });
    // 水印请求完成
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            UIImage *newImage = nil;
            NSLog(@"请求完毕，添加水印");
            for (int i = 0; i<self.mArray.count; i++) {
                    UIImage *waterImage = self.mArray[i];
                    newImage =[JP_ImageTool jp_WaterImageWithWaterImage:waterImage backImage:newImage waterImageRect:CGRectMake(20, 100*(i+1), 120, 60)];
            }
            self.imageView.image = newImage;
    
    });
    复制代码

*   添加水印前

![模拟器运行结果—添加水印前](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fc91fef224cf477caa0e706d0247e8cc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   添加水印后

![模拟器运行结果—添加水印后](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f3891c49a83a472a9abfbbaa24789d9b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 当组内的任务全部执行完成了，`dispatch_group_notify`会通知，任务已经完成了，内部添加水印的工作可以开始了！

> 上面的例子还可以使用`dispatch_group_enter` 和`dispatch_group leave` 搭配使用，如下：

![进组和出组搭配使用](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bccb437645d2440cb9c17bb28aad86de~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> 从上面的两个例子代码可以发现，`dispatch_group_async` 相当于是`dispatch_group_enter` + `dispatch_group leave` 的作用！

**`注意`**：`dispatch_group_enter` 和`dispatch_group leave` 搭配使用，但是顺序不能反，否则会奔溃，如下:

![奔溃截图](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ba65769478a84ecf8b45d5f3138dffc9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `dispatch_group_enter` 和`dispatch_group leave` 搭配使用，除了顺序不发，个数也得保持一致，人家是出入成双成对，你不能把它们分开，否则也会罢工或者奔溃的！

*   `dispatch_group_enter`进组不出组情况

![进组不出组情况](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/149c493c91224a9cbfd282c65e0ccf32~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> `dispatch_group_enter`进组不出组，那么`dispatch_group_notify`就不会收到任务执行完成的通知，`dispatch_group_notify`内的任务就执行不了

*   不进组就出组 `dispatch_group leave` 情况

![不进组就出组](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0a15bdcd1c8b49a19af99c5b1694c38b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> 不进组就出组，程序会奔溃，都没有任务进去，你去出去，出个锤子哦！😢

*   `dispatch_group_wait`等待 举例

![dispatch_group_wait举例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/70f4b96103124c59a6cd28bc2da67077~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) `dispatch_group_wait`有点栅栏的感觉，堵住了组里面前面的任务，但是并没有阻塞主线程。那么再看看下面这个例子

![dispatch_group_wait举例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f70d37bf49924e56bea3a2453c4f364b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   这里使用了`dispatch_group_wait`进行等待
*   `dispatch_group_wait`函数会一直等到前面`group`中的任务执行完，再执行下面代码，但会产生阻塞线程的问题，导致了主线程中的`任务5`不能正常运行，直到任务组的任务完成才能被调用。

> **`思考`**：
> 
> > 1.  那么调度组是如何工作，为什么可以调度任务呢？
> > 2.  `dispatch_group_enter`进组和`dispatch_group_leave`出组为什么能够起到与调度组`dispatch_group_async`一样的效果呢?
> 
> 现在去看看源码寻找答案！

二、调度组源码分析
=========

2.1 dispatch\_group\_create
---------------------------

*   `dispatch_group_create`

    dispatch_group_t
    dispatch_group_create(void)
    {
    	return _dispatch_group_create_with_count(0);
    }
    复制代码

创建调度组会调用`_dispatch_group_create_with_count`方法，并默认传入`0`

*   `_dispatch_group_create_with_count`

    static inline dispatch_group_t
    _dispatch_group_create_with_count(uint32_t n)
    {
    	dispatch_group_t dg = _dispatch_object_alloc(DISPATCH_VTABLE(group),
    			sizeof(struct dispatch_group_s));
    	dg->do_next = DISPATCH_OBJECT_LISTLESS;
    	dg->do_targetq = _dispatch_get_default_queue(false);
    	if (n) {
    		os_atomic_store2o(dg, dg_bits,
    				(uint32_t)-n * DISPATCH_GROUP_VALUE_INTERVAL, relaxed);
    		os_atomic_store2o(dg, do_ref_cnt, 1, relaxed); // <rdar://22318411>
    	}
    	return dg;
    }
    复制代码

`_dispatch_group_create_with_count`方法里面通过`os_atomic_store2o`来把传入的 `n`进行保存，这里的写法和信号量很像(如下图)，是模仿的信号量的写法自己写了一个，但并不是调度组底层是使用信号量实现的。

![dispatch_semaphore_create](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b7d2ed7450744d55945b871bf50e04ee~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2.2 dispatch\_group\_enter
--------------------------

*   `dispatch_group_enter`

![dispatch_group_enter](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/668ef8ea7f974f25a76327c35c3e116f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 通过`os_atomic_sub_orig2o`会进行`0`的减减操作，此时的`old_bits`等于`-1`。

2.3 dispatch\_group\_leave
--------------------------

*   `dispatch_group_leave`

![dispatch_group_leave](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a1fb313be090406cba0a62762acb34e4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

这里通过`os_atomic_add_orig2o`把`-1`加加操作，`old_state`就等于`0`，`0 & DISPATCH_GROUP_VALUE_MASK`的结果依然等于`0`，也就是`old_value`等于`0`。`DISPATCH_GROUP_VALUE_1`的定义如下代码： ![DISPATCH_GROUP_VALUE_1](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/91ed1bd6f0b546f6af3f6f319647efce~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从代码中可以看出`old_value`是不等于`DISPATCH_GROUP_VALUE_MASK`的，所以代码会执行到外面的`if`中去，并调用`_dispatch_group_wake`方法进行唤醒，唤醒的就是`dispatch_group_notify`方法。

也就是说，如果不调用`dispatch_group_leave`方法，也就不会唤醒`dispatch_group_notify`，下面的流程也就不会执行了。

2.4 dispatch\_group\_notify
---------------------------

*   `dispatch_group_notify`

![dispatch_group_notify](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4123f5311b564c2cbb5f72cb6f82112a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 在`old_state`等于`0`的情况下，才会去唤醒相关的同步或者异步函数的执行，也就是 `block`里面的执行，就是调用同步、异步的那个[callout](https://juejin.cn/post/6996994013807001613 "https://juejin.cn/post/6996994013807001613")执行。

*   在`dispatch_group_leave`分析中，我们已经得到`old_state`结果等于`0`
*   所以这里也就解释了`dispatch_group_enter`和`dispatch_group_leave`为什么要配合起来使用的原因，通过信号量的控制，避免异步的影响，能够及时唤醒并调用`dispatch_group_notify`方法
*   在`dispatch_group_leave`里面也有调用`_dispatch_group_wake`方法，这是因为异步的执行，任务是执行耗时的，有可能`dispatch_group_leave`这行代码还没有走，就先走了`dispatch_group_notify`方法，但这时候`dispatch_group_notify`方法里面的任务并不会执行，只是把任务添加到 `group`
*   它会等`dispatch_group_leave`执行了被唤醒才执行，这样就保证了异步时，`dispatch_group_notify`里面的任务不丢弃，可以正常执行。如下图所示：

![示意图](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0653e761ff5e45d4bbc98beb77b59250~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   当执行`任务 2`的时候，是耗时任务(sleep(5)模拟耗时)，异步不会堵塞，会执行后面的代码，就是图中①，`dispatch_group_notify`里面的任务会包装起来，进`group`
*   包装完成，异步执行完，这时候就走 ②了，又回到`dispatch_group_leave`处去执行了，这时候就可以通过 `group` 拿到`任务 4`，直接去调用`_dispatch_group_wake`把`任务 4`唤醒执行了。
*   这一波是非常的细节，苹果工程师真是妙啊！

![苹果工程师牛逼](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cda8ea18000b44debb8878380675cecb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2.5 dispatch\_group\_async
--------------------------

> **`猜想`**：`dispatch_group_async`里面应该是封装了`dispatch_group_enter`和`dispatch_group_leave`，所以才能起到一样的作业效果！

*   `dispatch_group_async`

![dispatch_group_async](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ee792aad920c478992d9c9d1c83b5729~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> `dispatch_continuation_t`的处理，也就是任务的包装处理，还做了一些标记处理，最后走`_dispatch_continuation_group_async`

*   `_dispatch_continuation_group_async`

![_dispatch_continuation_group_async](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bc6d6430e134f3c854fe2f2b1c7a8b6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

靓仔！看到没有，和猜想的是一样的，内部果然封装了`dispatch_group_enter`方法，向组中添加任务时，就调用了dispatch\_group\_enter方法，将信号量`0`变成了`-1`。那么现在去找下`dispatch_group_leave`的在哪里！继续跟踪流程。。。

*   `_dispatch_continuation_async`

![_dispatch_continuation_async](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc0ebf1fa14e4587843144699152e596~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

这一波又是非常的熟悉了，这个`dx_push`我们都已经非常熟悉了，异步、同步的时候经常见这个方法，这里就不再赘述了（[传送门](https://link.juejin.cn?target=https%3A%2F%2Fblog.csdn.net%2Fzjpjay%2Farticle%2Fdetails%2F119730541%3Fspm%3D1001.2014.3001.5501 "https://link.juejin.cn?target=https%3A%2F%2Fblog.csdn.net%2Fzjpjay%2Farticle%2Fdetails%2F119730541%3Fspm%3D1001.2014.3001.5501"))，会调用:

*   `_dispatch_root_queue_push` -- >
*   `_dispatch_root_queue_push_inline` -- >
*   `_dispatch_root_queue_poke` -- >
*   `_dispatch_root_queue_poke_slow` -- >
*   `_dispatch_root_queues_init` -- >
*   `_dispatch_root_queues_init_once` -- >
*   `_dispatch_worker_thread2` -- > `_dispatch_root_queue_drain`![_dispatch_root_queue_drain](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d47b856776544c91a2110b8a5d6d0af6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 然后`_dispatch_root_queue_drain -- > _dispatch_continuation_pop_inline -- > _dispatch_continuation_with_group_invoke`

![_dispatch_continuation_with_group_invoke](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/11a6d74d143d417b8559d5f538e94d98~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> 在最后`_dispatch_continuation_with_group_invoke`里面我们找到了出组的方法`dispatch_group_leave` 在这里完成`_dispatch_client_callout`函数调用，紧接着调用`dispatch_group_leave`方法，将信号量由`-1`变成了`0`。

至此完成闭环，完整的分析了调度组、进组、出组、通知的底层原理和关系。

三、 Dispatch Source 介绍
=====================

3.1 Dispatch Source简介
---------------------

`Dispatch Source` 是`BSD`系统内核惯有功能`kqueue`的包装，`kqueue`是在`XNU`内核中发生事件时在应用程序编程方执行处理的技术。

它的`CPU`负荷非常小，尽量不占用资源。当事件发生时，`Dispatch Source` 会在指定的`Dispatch Queue`中执行事件的处理。

*   `dispatch_source_create` ：创建源
*   `dispatch_source_set_event_handler`： 设置源的回调
*   `dispatch_source_merge_data`： 源事件设置数据
*   `dispatch_source_get_data`： 获取源事件的数据
*   `dispatch_resume`：恢复继续
*   `dispatch_suspend`：挂起

我们在日常开发中，经常会使用计时器`NSTimer`，例如发送短信的倒计时，或者进度条的更新。但是`NSTimer`需要加入到`NSRunloop`中，还受到`mode`的影响。收到其他事件源的影响，被打断，当滑动`scrollView的`时候，模式切换，定时器就会停止，从而导致`timer`的计时不准确。

`GCD`提供了一个解决方案`dispatch_source`来出来类似的这种需求场景。

*   时间较准确，`CPU`负荷小，占用资源少
*   可以使用子线程，解决定时器跑在主线程上卡UI问题
*   可以暂停，继续，不用像`NSTimer`一样需要重新创建

3.2 Dispatch Source 使用
----------------------

创建事件源的代码：

    // 方法声明
    dispatch_source_t dispatch_source_create(
            dispatch_source_type_t type,
            uintptr_t handle,
            unsigned long mask,
            dispatch_queue_t _Nullable queue);
    
    // 实现过程
    dispatch_source_t source =  dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0,  dispatch_get_main_queue());
    复制代码

创建的时候，需要传入两个重要的参数：

*   `dispatch_source_type_t` 要创建的源类型
*   `dispatch_queue_t` 事件处理的调度队列

3.3 Dispatch Source 种类
----------------------

*   **Dispatch Source 种类:**

1.  `DISPATCH_SOURCE_TYPE_DATA_ADD` 变量增加
2.  `DISPATCH_SOURCE_TYPE_DATA_OR` 变量 `OR`
3.  `DISPATCH_SOURCE_TYPE_DATA_REPLACE` 新获得的数据值替换现有的
4.  `DISPATCH_SOURCE_TYPE_MACH_SEND MACH` 端口发送
5.  `DISPATCH_SOURCE_TYPE_MACH_RECV MACH` 端口接收
6.  `DISPATCH_SOURCE_TYPE_MEMORYPRESSURE` 内存压力 (注：iOS8后可用)
7.  `DISPATCH_SOURCE_TYPE_PROC` 检测到与进程相关的事件
8.  `DISPATCH_SOURCE_TYPE_READ` 可读取文件映像
9.  `DISPATCH_SOURCE_TYPE_SIGNAL` 接收信号
10.  `DISPATCH_SOURCE_TYPE_TIMER` 定时器
11.  `DISPATCH_SOURCE_TYPE_VNODE` 文件系统有变更
12.  `DISPATCH_SOURCE_TYPE_WRITE` 可写入文件映像

设计一个定时器举例: ![创建定时器方法](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fcb47cbd3ceb4ef2a0afaa76a89e8b68~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   点击屏幕开始

![定时器控制方法](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/028c8c1a30714ec3a33ed6f30aaa12d5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 使用`dispatch_source`的计时器，能够暂停、开始，同时不受主线程影响，不会受 `UI事件`的影响，所以它的计时是准确的。如下图所示：

![运行结果](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9a8c1aeed32640c3825283ccb166007e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3.4 使用时注意事项
-----------

**`注意事项`**

1.  source 需要手动启动

`Dispatch Source` 使用最多的就是用来实现定时器，`source`创建后默认是暂停状态，需要手动调用 `dispatch_resume`启动定会器。 `dispatch_after`只是封装调用了`dispatch source`定时器，然后在回调函数中执行定义的`block`.

2.  循环引用

因为 `dispatch_source_set_event_handle`回调是`block`，在添加到`source`的链表上时会执行`copy`并被`source`强引用，如果`block`里持有了`self`，`self`又持有了`source`的话，就会引起循环引用。所以正确的方法是使用`weak+strong`或者提前调`dispatch_source_cancel`取消`timer`。

3.  resume、suspend 调用次数保持平衡

`dispatch_resume` 和 `dispatch_suspend` 调用次数需要平衡，如果重复调用 `dispatch_resume`则会崩溃，因为重复调用会让`dispatch_resume` 代码里`if`分支不成立，从而执行了 `DISPATCH_CLIENT_CRASH(“Over-resume of an object”)` 导致崩溃。

4.  source 创建与释放时机

`source`在`suspend`状态下，如果直接设置 `source = nil` 或者重新创建 `source` 都会造成 `crash`。正确的方式是在`resume`状态下调用 `dispatch_source_cancel(source)`后再重新创建。

四、 Dispatch Source源码分析
======================

那么去底层源码看看，为什么会出现上面的一些问题。

4.1 dispatch\_resume
--------------------

*   `dispatch_resume`

    void
    dispatch_resume(dispatch_object_t dou)
    {
    	DISPATCH_OBJECT_TFB(_dispatch_objc_resume, dou);
    	if (unlikely(_dispatch_object_is_global(dou) ||
    			_dispatch_object_is_root_or_base_queue(dou))) {
    		return;
    	}
    	if (dx_cluster(dou._do) == _DISPATCH_QUEUE_CLUSTER) {
    		_dispatch_lane_resume(dou._dl, DISPATCH_RESUME);
    	}
    }
    复制代码

`dispatch_resume``会去执行_dispatch_lane_resume`

*   `_dispatch_lane_resume`

![_dispatch_lane_resume](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b9a82686536e43ad92524d40a08132e4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 这里的方法是对事件源的相关状态进行判断，如果过度`resume`恢复，则会`goto`走到`over_resume`流程，直接调起`DISPATCH_CLIENT_CRASH`崩溃。

这里还有对挂起计数的判断，挂起计数包含所有挂起和非活动位的挂起计数。`underflow`下溢意味着需要过度恢复或暂停计数转移到边计数，也就是说如果当前计数器还没有到可运行的状态，需要连续恢复。

4.2 dispatch\_suspend
---------------------

*   挂起`dispatch_suspend`

![dispatch_suspend](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/990c47bde0324209bafc4674eac0da05~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 在`dispatch_suspend`的定义里面也可以发现，恢复和挂起一定要`保持平衡`，挂起的对象不会调用与其关联的任何`block`。 在与对象关联的任何运行的 `block`完成后，对象将被挂起。

    void
    dispatch_suspend(dispatch_object_t dou)
    {
    	DISPATCH_OBJECT_TFB(_dispatch_objc_suspend, dou);
    	if (unlikely(_dispatch_object_is_global(dou) ||
    			_dispatch_object_is_root_or_base_queue(dou))) {
    		return;
    	}
    	if (dx_cluster(dou._do) == _DISPATCH_QUEUE_CLUSTER) {
    		return _dispatch_lane_suspend(dou._dl);
    	}
    }
    复制代码

*   `_dispatch_lane_suspend`

![_dispatch_lane_suspend](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8d9bc3e6b0ed4f6bb1ceebaf39e17357~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   `_dispatch_lane_suspend_slow`

![_dispatch_lane_suspend_slow](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/242a4568d50e4a69931a4d45810fc1bf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 同样这里维护一个暂停挂起的计数器，如果连续调用`dispatch_suspend`挂起方法，减法的无符号下溢可能发生，因为其他线程可能在我们尝试获取锁时触及了该值，或者因为另一个线程争先恐后地执行相同的操作并首先获得锁。

所以不能重复的挂起或者恢复，一定要你一个我一个，你两个我也两个，保持一个`balanced`。

五、总结
====

5.1 线程调度组
---------

*   调度组最直接的作用就是控制任务的执行顺序
*   `dispatch_group_notify` ：进组任务执行完毕的通知
*   `dispatch_group_wait` 函数会一直等到前面`group`中的任务执行完，后面的才可以执行
*   `dispatch_group_enter` 和`dispatch_group leave` 成对使用
*   `dispatch_group_async` 内部封装了`dispatch_group_enter` 和`dispatch_group leave` 的使用

5.2 事件源
-------

*   使用定时器`NSTimer`需要加入到`NSRunloop`，导致计数不准确，可以使用`Dispatch Source`来解决
    
*   `Dispatch Source`的使用，要注意`恢复`和`挂起`要`平衡`
    
*   `source`在`suspend`状态下，如果直接设置 `source = nil` 或者重新创建 `source` 都会造成 `crash`。正确的方式是在`resume`状态下调用 `dispatch_source_cancel(source)`后再重新创建。
    
*   因为 `dispatch_source_set_event_handle`回调是`block`，在添加到`source`的链表上时会执行`copy`并被`source`强引用，如果`block`里持有了`self`，`self`又持有了`source`的话，就会引起循环引用。所以正确的方法是使用`weak+strong`或者提前调`dispatch_source_cancel`取消`timer`。
    