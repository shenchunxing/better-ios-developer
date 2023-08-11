# 两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer
一. RunLoop简介
============

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a7f870596e7247f190afa9bb2ec49535~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

1\. 命令行项目
---------

我们通过Xcode创建一个`命令行项目`的时候,会有一个`main.m`源码文件，里面的`main函数`作为程序的入口,其源码大概如下:

    int main(int argc, char * argv[]) { 
        //......
        
        NSLog(@"Hello World"); 
        
        return 0;
    } 
    复制代码

但每一次编译运行执行代码之后,整个项目就退出了。

2\. iOS项目
---------

而我们通过Xcode创建一个`iOS项目`，当项目运行之后,会链接一个模拟器,而不会自动退出。这时候`main.m`源码文件里面的`main函数`作为程序的入口,其源码也变成了:

    int main(int argc, char * argv[]) {
        @autoreleasepool {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    }
    复制代码

通过运行iOS项目,我们不难得知, 整个程序不会在执行完 return 后边的代码之后, 自动退出。

**那这是什么原因呢？**

3\. Runloop简介
-------------

一般来说，一个线程只能执行一个任务，执行完就会退出，如果我们需要一种机制，让线程能随时处理事件但并不退出，那么 `RunLoop` 就是这样的一个机制。Runloop是事件接收和分发机制的一个实现。

> **RunLoop实际上是一个对象** 这个对象在循环中用来处理程序运行过程中出现的各种事件,比如:
> 
> *   触摸事件
> *   UI刷新事件
> *   定时器事件
> *   Selector事件 从而保持程序的持续运行；  
>     而且在没有事件处理的时候，会进休眠模式，从而节省CPU资源,从而提高程序性能。

简单的说RunLoop是事件驱动的一个大循环，我们可以写一个伪代码模仿一下其实现：

    int main(int argc, char * argv[]) {
         //程序一直运行状态
         while (AppIsRunning) {
              //睡眠状态，等待唤醒事件
              id whoWakesMe = SleepForWakingUp();
              //得到唤醒事件
              id event = GetEvent(whoWakesMe);
              //开始处理事件
              HandleEvent(event);
         }
         return 0;
    }
    复制代码

4\. 小结
------

*   `RunLoop`即是运行循环技术
*   在程序运行过程中循环做一些事情，如果没有`RunLoop`程序执行完毕就会立即退出 ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2b77812698f24fd5990b8ce254bf6d72~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   如果有`RunLoop`程序会一直运行，并且时时刻刻在等待一个可处理事件进行处理 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e6870c760c7a4f46901a5b4685a7e33a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/35d276aa8fef4975bc55a5d14693c11e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   **`RunLoop`可以在需要的时候自己跑起来运行，在没有操作的时候就停下来休息。充分节省CPU资源，提高程序性能**

二. RunLoop基本作用
==============

1.  **保持程序持续运行**
    *   程序一启动就会开一个主线程
    *   主线程一开起来就会跑一个主线程对应的RunLoop
    *   RunLoop保证主线程不会被销毁，也就保证了程序的持续运行
2.  **处理App中的各种事件**（比如：触摸事件，定时器事件，Selector事件等）
3.  **节省CPU资源，提高程序性能**
    *   程序运行起来时，当什么操作都没有做的时候，RunLoop就告诉CPU，现在没有事情做，我要去休息，这时CPU就会将其资源释放出来去做其他的事情
    *   当有事情做的时候RunLoop就会立马起来去做事情

> **我们先通过一张图片来简单看一下RunLoop内部运行原理**

![RunLoop内部运行原理](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/57aa2e57743e40fb888a2dc91dfdcd18~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过图片可以看出:

*   RunLoop在跑圈过程中，当接收到Input sources 或者 Timer sources时就会交给对应的处理方去处理
*   当没有事件消息传入的时候，RunLoop就休息了
*   这里只是简单的理解一下这张图，接下来我们来了解RunLoop对象和其一些相关类，来更深入的理解RunLoop运行流程

三. RunLoop在哪里开启
===============

`UIApplicationMain`函数内启动了`RunLoop`，程序不会马上退出，而是保持运行状态。  
因此每一个应用必须要有一个`RunLoop`,我们知道主线程一开起来,就会跑一个和主线程对应的`RunLoop`。  
那么`RunLoop`一定是在程序的入口`main函数`中开启。

    int main(int argc, char * argv[]) {
        @autoreleasepool {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
    } 
    复制代码

进入`UIApplicationMain`

    UIKIT_EXTERN int UIApplicationMain(int argc, char *argv[], NSString * __nullable principalClassName, NSString * __nullable delegateClassName);
    复制代码

我们发现它返回的是一个`int`类型，那么我们对`main`函数做一些修改

    int main(int argc, char * argv[]) {
        @autoreleasepool {
            NSLog(@"开始");
            int re = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
            NSLog(@"结束");
            return re;
        }
    } 
    复制代码

运行程序，我们发现:

*   只会打印开始，并不会打印结束
*   这说明**在UIApplicationMain函数中，开启了一个和主线程相关的RunLoop，导致UIApplicationMain不会返回，一直在运行中，也就保证了程序的持续运行**
*   我们来看看RunLoop的源码:
    
        // 用DefaultMode启动
        void CFRunLoopRun(void) {	/* DOES CALLOUT */
            int32_t result;
            do {
                result = CFRunLoopRunSpecific(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 1.0e10, false);
                CHECK_FOR_FORK();
            } while (kCFRunLoopRunStopped != result && kCFRunLoopRunFinished != result);
        } 
        复制代码
    

我们发现:

*   `RunLoop`确实是`do while`循环,通过判断`result`的值实现的
*   因此，我们可以把`RunLoop`看成一个死循环
    *   如果没有RunLoop，UIApplicationMain函数执行完毕之后将直接返回，也就没有程序持续运行一说了

四. RunLoop对象
============

1\. 两套RunLoopAPI
----------------

> iOS中有2套API来访问和使用RunLoop:

*   **`Fundation框架:`** NSRunLoop对象
    
*   **`CoreFoundation框架`:** CFRunLoopRef对象
    
*   **`NSRunLoop`** 和 **`CFRunLoopRef`** 都代表着`RunLoop`对象
    
*   `NSRunLoop`是基于`CFRunLoopRef`的一层OC包装 ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a2e30bd0e3de4f599b8d1ba4740eea74~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
    
*   `CFRunLoopRef`是开源的
    
    *   [opensource.apple.com/tarballs/CF…](https://link.juejin.cn?target=https%3A%2F%2Fopensource.apple.com%2Ftarballs%2FCF%2F "https://opensource.apple.com/tarballs/CF/")

2\. 如何获得RunLoop对象
-----------------

    //Foundation
    [NSRunLoop currentRunLoop]; // 获得当前线程的RunLoop对象
    [NSRunLoop mainRunLoop]; // 获得主线程的RunLoop对象
    复制代码

    //Core Foundation
    CFRunLoopGetCurrent(); // 获得当前线程的RunLoop对象
    CFRunLoopGetMain(); // 获得主线程的RunLoop对象 
    复制代码

五. RunLoop和线程间的关系
=================

因为`NSRunLoop`是基于`CFRunLoopRef`的一层OC封装，这里我们主要研究`CFRunLoopRef`源码,来了解下RunLoop:

1\. 阅读 `CFRunLoopRef`源码
-----------------------

    // 拿到当前Runloop 调用_CFRunLoopGet0
    CFRunLoopRef CFRunLoopGetCurrent(void) {
        CHECK_FOR_FORK();
        CFRunLoopRef rl = (CFRunLoopRef)_CFGetTSD(__CFTSDKeyRunLoop);
        if (rl) return rl;
        return _CFRunLoopGet0(pthread_self());
    }
    
    // 查看_CFRunLoopGet0方法内部
    CF_EXPORT CFRunLoopRef _CFRunLoopGet0(pthread_t t) {
        if (pthread_equal(t, kNilPthreadT)) {
    	t = pthread_main_thread_np();
        }
        __CFLock(&loopsLock);
        if (!__CFRunLoops) {
            __CFUnlock(&loopsLock);
    	CFMutableDictionaryRef dict = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    	// 根据传入的主线程获取主线程对应的RunLoop
    	CFRunLoopRef mainLoop = __CFRunLoopCreate(pthread_main_thread_np());
    	// 保存主线程 将主线程-key和RunLoop-Value保存到字典中
    	CFDictionarySetValue(dict, pthreadPointer(pthread_main_thread_np()), mainLoop);
    	if (!OSAtomicCompareAndSwapPtrBarrier(NULL, dict, (void * volatile *)&__CFRunLoops)) {
    	    CFRelease(dict);
    	}
    	CFRelease(mainLoop);
            __CFLock(&loopsLock);
        }
        
        // 从字典里面拿，将线程作为key从字典里获取一个loop
        CFRunLoopRef loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
        __CFUnlock(&loopsLock);
        
        // 如果loop为空，则创建一个新的loop，所以runloop会在第一次获取的时候创建
        if (!loop) {  
    	CFRunLoopRef newLoop = __CFRunLoopCreate(t);
            __CFLock(&loopsLock);
    	loop = (CFRunLoopRef)CFDictionaryGetValue(__CFRunLoops, pthreadPointer(t));
    	
    	// 创建好之后，以线程为key runloop为value，一对一存储在字典中，下次获取的时候，则直接返回字典内的runloop
    	if (!loop) { 
    	    CFDictionarySetValue(__CFRunLoops, pthreadPointer(t), newLoop);
    	    loop = newLoop;
    	}
            // don't release run loops inside the loopsLock, because CFRunLoopDeallocate may end up taking it
            __CFUnlock(&loopsLock);
    	CFRelease(newLoop);
        }
        if (pthread_equal(t, pthread_self())) {
            _CFSetTSD(__CFTSDKeyRunLoop, (void *)loop, NULL);
            if (0 == _CFGetTSD(__CFTSDKeyRunLoopCntr)) {
                _CFSetTSD(__CFTSDKeyRunLoopCntr, (void *)(PTHREAD_DESTRUCTOR_ITERATIONS-1), (void (*)(void *))__CFFinalizeRunLoop);
            }
        }
        return loop;
    }
     
    复制代码

**从上面的代码可以看出:**

*   线程和 `RunLoop` 之间是一一对应的，其关系是保存在一个 `Dictionary` 里
*   所以我们在创建的子线程想要获取`RunLoop`时，只需在子线程中获取当前线程的`RunLoop`对象即可`[NSRunLoop currentRunLoop];`
*   **如果不获取，那子线程就不会创建与之相关联的`RunLoop`**
*   并且只能在一个线程的内部获取其 `RunLoop`
*   `[NSRunLoop currentRunLoop];`方法调用时，会先看一下字典里有没有存子线程相对用的`RunLoop`
    *   如果有则直接返回`RunLoop`
    *   如果没有则会创建一个，并将与之对应的子线程存入字典中
*   当线程结束时，`RunLoop`会被销毁。

2\. 小结
------

> 1.  每条线程都有唯一的一个与之对应的`RunLoop`对象
> 2.  `RunLoop`保存在一个`全局的Dictionary`里，线程作为key,RunLoop作为value
> 3.  `主线程的RunLoop`已经自动创建好了，`子线程的RunLoop`需要主动创建
> 4.  线程刚创建时并没有`RunLoop`对象，`RunLoop`在`第一次获取时创建`，在`线程结束时销毁`

六. RunLoop结构体
=============

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9ff8d226183b47b9a3463284f312c8cc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

1\. `__CFRunLoop`结构体
--------------------

通过源码我们找到`__CFRunLoop`结构体

    struct __CFRunLoop {
        CFRuntimeBase _base;
        pthread_mutex_t _lock;			/* locked for accessing mode list */
        __CFPort _wakeUpPort;			// used for CFRunLoopWakeUp 
        Boolean _unused;
        volatile _per_run_data *_perRunData;              // reset for runs of the run loop
        pthread_t _pthread;
        uint32_t _winthread;
        CFMutableSetRef _commonModes;
        CFMutableSetRef _commonModeItems;
        CFRunLoopModeRef _currentMode;
        CFMutableSetRef _modes;
        struct _block_item *_blocks_head;
        struct _block_item *_blocks_tail;
        CFAbsoluteTime _runTime;
        CFAbsoluteTime _sleepTime;
        CFTypeRef _counterpart;
    };
    
    复制代码

除一些记录性属性外，主要来看一下以下两个成员变量

    CFRunLoopModeRef _currentMode;
    CFMutableSetRef _modes; 
    复制代码

`CFRunLoopModeRef` 其实是指向`__CFRunLoopMode`结构体的指针  
`__CFRunLoopMode`结构体源码如下:

2\. `__CFRunLoopMode`结构体
------------------------

    typedef struct __CFRunLoopMode *CFRunLoopModeRef;
    struct __CFRunLoopMode {
        CFRuntimeBase _base;
        pthread_mutex_t _lock;	/* must have the run loop locked before locking this */
        CFStringRef _name;
        Boolean _stopped;
        char _padding[3];
        CFMutableSetRef _sources0;
        CFMutableSetRef _sources1;
        CFMutableArrayRef _observers;
        CFMutableArrayRef _timers;
        CFMutableDictionaryRef _portToV1SourceMap;
        __CFPortSet _portSet;
        CFIndex _observerMask;
    #if USE_DISPATCH_SOURCE_FOR_TIMERS
        dispatch_source_t _timerSource;
        dispatch_queue_t _queue;
        Boolean _timerFired; // set to true by the source when a timer has fired
        Boolean _dispatchTimerArmed;
    #endif
    #if USE_MK_TIMER_TOO
        mach_port_t _timerPort;
        Boolean _mkTimerArmed;
    #endif
    #if DEPLOYMENT_TARGET_WINDOWS
        DWORD _msgQMask;
        void (*_msgPump)(void);
    #endif
        uint64_t _timerSoftDeadline; /* TSR */
        uint64_t _timerHardDeadline; /* TSR */
    };
    
    复制代码

主要查看以下成员变量

    CFMutableSetRef _sources0;
    CFMutableSetRef _sources1;
    CFMutableArrayRef _observers;
    CFMutableArrayRef _timers;
    复制代码

通过上面分析我们知道，`CFRunLoopModeRef`代表`RunLoop`的运行模式:

*   一个RunLoop包含若干个Mode
*   每个Mode又包含若干个Source0/Source1/Timer/Observer
*   而RunLoop启动时只能选择其中一个Mode作为currentMode。

3.Source1/Source0/Timers/Observer分别代表什么
---------------------------------------

*   1.  `Source1`: 基于`Port`的线程间通信
*   2.  `Source0`: 触摸事件，`PerformSelectors`

### 3.1 Source0

我们通过代码验证一下

    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
        NSLog(@"点击了屏幕");
    } 
    复制代码

打断点之后打印堆栈信息，当XCode工具区打印的堆栈信息不全时，可以在控制台通过“bt”指令打印完整的堆栈信息，由堆栈信息中可以发现，触摸事件确实是会触发`Source0`事件。

![touchesBegan堆栈信息](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/533e33fbc4bb47c7a8868c545dbe7de3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

同样的方式验证performSelector堆栈信息

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self performSelectorOnMainThread:@selector(test) withObject:nil waitUntilDone:YES];
    });
    复制代码

可以发现PerformSelectors同样是触发Source0事件

![performSelector堆栈信息](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e3e072500100401ba15ff62fbf611241~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   其实，当我们触发了事件（触摸/锁屏/摇晃等）后，由`IOKit.framework`生成一个 `IOHIDEvent`事件
*   而`IOKit`是苹果的硬件驱动框架，由它进行底层接口的抽象封装与系统进行交互传递硬件感应的事件，并专门处理用户交互设备，由`IOHIDServices`和`IOHIDDisplays`两部分组成
*   其中`IOHIDServices`是专门处理用户交互的，它会将事件封装成`IOHIDEvents`对象，接着用`mach port`转发给需要的`App`进程
*   随后 `Source1`就会接收`IOHIDEvent`，之后再回调`__IOHIDEventSystemClientQueueCallback()`
*   `__IOHIDEventSystemClientQueueCallback()`内触发`Source0`
*   `Source0` 再触发 `_UIApplicationHandleEventQueue()`。所以触摸事件看到是在 `Source0` 内的。

### 3.2 `Timers` : 定时器，NSTimer

通过代码验证

    [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"NSTimer ---- timer调用了");
    }];
    复制代码

打印完整堆栈信息

![Timer对战信息](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/119f630b8be54c23ab80950a914fc11d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 3.3 `Observer`: 监听器，用于监听RunLoop的状态

七. 详解RunLoop相关类及作用
==================

通过上面的分析，我们对RunLoop内部结构有了大致的了解，接下来来详细分析RunLoop的相关类。

> **RunLoop相关的的5个类**

*   **`CFRunLoopRef`**: 获得当前RunLoop和主RunLoop
*   **`CFRunLoopModeRef`**: RunLoop 运行模式，只能选择一种，在不同模式中做不同的操作
*   **`CFRunLoopSourceRef`**: 事件源，输入源
*   **`CFRunLoopTimerRef`**: 定时器时间
*   **`CFRunLoopObserverRef`**: 观察者

1\. CFRunLoopModeRef
--------------------

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e374da3d48de486aae803950a91a0c54~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) **CFRunLoopModeRef代表RunLoop的运行模式**

*   一个 `RunLoop` 包含若干个 `Mode`
*   每个`Mode`又包含若干个`Source`、`Timer`、`Observer`
*   每次`RunLoop`启动时，只能指定其中一个 `Mode`，这个`Mode`被称作 `CurrentMode`
*   如果需要切换`Mode`，只能退出`RunLoop`，再重新指定一个`Mode`进入
    *   这样做主要是为了分隔开不同组的`Source`、`Timer`、`Observer`，让其互不影响。
*   如果`Mode`里没有任何 `Source0`/`Source1`/`Timer`/`Observer`，`RunLoop`会立马退出 如图所示： ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1f7a437a62b74c5489b27bc2233ec533~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

> **RunLoop必须至少有一个Source或者Timer**

*   注意：一种`Mode`中可以有多个`Source`、`Observer`、 和`Timer`
    *   `Source`(事件源，输入源，基于端口事件源例键盘触摸等)
    *   `Observer`(观察者，观察当前RunLoop运行状态)
    *   `Timer`(定时器事件源)
*   但是`RunLoop`必须至少有一个`Source`或者`Timer`，因为如果`Mode`为空，`RunLoop`运行到空模式不会进行空转，就会立刻退出。

### 1.1 5种`RunLoopMode`

RunLoop 有五种运行模式，其中常见的有1.2两种

*   1.  **`kCFRunLoopDefaultMode`:** **App的默认Mode**，通常主线程是在这个Mode下运行
*   2.  **`UITrackingRunLoopMode`:** **界面跟踪 Mode**，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
*   3.  **`UIInitializationRunLoopMode`:** 在刚启动 App 时第进入的第一个 Mode，启动完成后就不再使用，会切换到kCFRunLoopDefaultMode
*   4.  **`GSEventReceiveRunLoopMode`:** 接受系统事件的内部 Mode，通常用不到
*   5.  **`kCFRunLoopCommonModes`:** 这是一个占位用的Mode，作为标记kCFRunLoopDefaultMode和UITrackingRunLoopMode用，并不是一种真正的Mode

### 1.2 `RunLoopMode`的切换

我们平时在开发中一定遇到过，当我们使用NSTimer每一段时间执行一些事情时滑动  
UIScrollView，NSTimer就会暂停，当我们停止滑动以后，NSTimer又会重新恢复的情况，我们通过一段代码来看一下

**代码中的注释也很重要，展示了我们探索的过程**

    -(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
        // [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(show) userInfo:nil repeats:YES];
        NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(show) userInfo:nil repeats:YES];
        // 加入到RunLoop中才可以运行
        // 1. 把定时器添加到RunLoop中，并且选择默认运行模式NSDefaultRunLoopMode = kCFRunLoopDefaultMode
        // [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        // 当textFiled滑动的时候，timer失效，停止滑动时，timer恢复
        // 原因：当textFiled滑动的时候，RunLoop的Mode会自动切换成UITrackingRunLoopMode模式，因此timer失效，当停止滑动，RunLoop又会切换回NSDefaultRunLoopMode模式，因此timer又会重新启动了
        
        // 2. 当我们将timer添加到UITrackingRunLoopMode模式中，此时只有我们在滑动textField时timer才会运行
        // [[NSRunLoop mainRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
        
        // 3. 那个如何让timer在两个模式下都可以运行呢？
        // 3.1 在两个模式下都添加timer 是可以的，但是timer添加了两次，并不是同一个timer
        // 3.2 使用站位的运行模式 NSRunLoopCommonModes标记，凡是被打上NSRunLoopCommonModes标记的都可以运行，下面两种模式被打上标签
        //0 : <CFString 0x10b7fe210 [0x10a8c7a40]>{contents = "UITrackingRunLoopMode"}
        //2 : <CFString 0x10a8e85e0 [0x10a8c7a40]>{contents = "kCFRunLoopDefaultMode"}
        // 因此也就是说如果我们使用NSRunLoopCommonModes，timer可以在UITrackingRunLoopMode，kCFRunLoopDefaultMode两种模式下运行
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        NSLog(@"%@",[NSRunLoop mainRunLoop]);
    }
    -(void)show{
        NSLog(@"-------");
    }
    
    复制代码

由上述代码可以看出:

*   NSTimer不管用 是因为Mode的切换，因为如果我们在主线程使用定时器，此时RunLoop的Mode为`kCFRunLoopDefaultMode`
    *   即定时器属于`kCFRunLoopDefaultMode`，那么此时我们滑动ScrollView时，RunLoop的Mode会切换到`UITrackingRunLoopMode`
    *   因此在主线程的定时器就不在管用了，调用的方法也就不再执行了
*   当我们停止滑动时，RunLoop的Mode切换回`kCFRunLoopDefaultMode`，所以NSTimer就又管用了。

同样道理的还有ImageView的显示，我们直接来看代码，不再赘述了

    -(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {
        NSLog(@"%s",__func__);
        // performSelector默认是在default模式下运行，因此在滑动ScrollView时，图片不会加载
        // [self.imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"abc"] afterDelay:2.0 ];
        // inModes: 传入Mode数组
        [self.imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"abc"] afterDelay:2.0 inModes:@[NSDefaultRunLoopMode,UITrackingRunLoopMode]];
    
    复制代码

使用GCD也可是创建计时器，而且更为精确我们来看一下代码

    -(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {
        //创建队列
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        //1.创建一个GCD定时器
        /*
         第一个参数:表明创建的是一个定时器
         第四个参数:队列
         */
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        // 需要对timer进行强引用，保证其不会被释放掉，才会按时调用block块
        // 局部变量，让指针强引用
        self.timer = timer;
        //2.设置定时器的开始时间,间隔时间,精准度
        /*
         第1个参数:要给哪个定时器设置
         第2个参数:开始时间
         第3个参数:间隔时间
         第4个参数:精准度 一般为0 在允许范围内增加误差可提高程序的性能
         GCD的单位是纳秒 所以要*NSEC_PER_SEC
         */
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        
        //3.设置定时器要执行的事情
        dispatch_source_set_event_handler(timer, ^{
            NSLog(@"---%@--",[NSThread currentThread]);
        });
        // 启动
        dispatch_resume(timer);
    }
    
    复制代码

2\. CFRunLoopSourceRef事件源（输入源）
------------------------------

### 2.1 Source分为两种

*   **`Source0`:** 非基于Port的 用于用户主动触发的事件（点击button 或点击屏幕）
*   **`Source1`:** 基于Port的 通过内核和其他线程相互发送消息（与内核相关）

触摸事件及PerformSelectors会触发`Source0`事件源在前文已经验证过，这里不在赘述

3\. CFRunLoopObserverRef
------------------------

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ec6602d3010344e1bc4c8e6f87c2f27c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

> **`CFRunLoopObserverRef`是观察者，能够监听RunLoop的状态改变**

我们直接来看代码，给RunLoop添加监听者，监听其运行状态

    -(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
         //创建监听者
         /*
         第一个参数 CFAllocatorRef allocator：分配存储空间 CFAllocatorGetDefault()默认分配
         第二个参数 CFOptionFlags activities：要监听的状态 kCFRunLoopAllActivities 监听所有状态
         第三个参数 Boolean repeats：YES:持续监听 NO:不持续
         第四个参数 CFIndex order：优先级，一般填0即可
         第五个参数 ：回调 两个参数observer:监听者 activity:监听的事件
         */
         /*
         所有事件
         typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
         kCFRunLoopEntry = (1UL << 0),   //   即将进入RunLoop
         kCFRunLoopBeforeTimers = (1UL << 1), // 即将处理Timer
         kCFRunLoopBeforeSources = (1UL << 2), // 即将处理Source
         kCFRunLoopBeforeWaiting = (1UL << 5), //即将进入休眠
         kCFRunLoopAfterWaiting = (1UL << 6),// 刚从休眠中唤醒
         kCFRunLoopExit = (1UL << 7),// 即将退出RunLoop
         kCFRunLoopAllActivities = 0x0FFFFFFFU
         };
         */
        CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
            switch (activity) {
                case kCFRunLoopEntry:
                    NSLog(@"RunLoop进入");
                    break;
                case kCFRunLoopBeforeTimers:
                    NSLog(@"RunLoop要处理Timers了");
                    break;
                case kCFRunLoopBeforeSources:
                    NSLog(@"RunLoop要处理Sources了");
                    break;
                case kCFRunLoopBeforeWaiting:
                    NSLog(@"RunLoop要休息了");
                    break;
                case kCFRunLoopAfterWaiting:
                    NSLog(@"RunLoop醒来了");
                    break;
                case kCFRunLoopExit:
                    NSLog(@"RunLoop退出了");
                    break;
                    
                default:
                    break;
            }
        });
        
        // 给RunLoop添加监听者
        /*
         第一个参数 CFRunLoopRef rl：要监听哪个RunLoop,这里监听的是主线程的RunLoop
         第二个参数 CFRunLoopObserverRef observer 监听者
         第三个参数 CFStringRef mode 要监听RunLoop在哪种运行模式下的状态
         */
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
         /*
         CF的内存管理（Core Foundation）
         凡是带有Create、Copy、Retain等字眼的函数，创建出来的对象，都需要在最后做一次release
         GCD本来在iOS6.0之前也是需要我们释放的，6.0之后GCD已经纳入到了ARC中，所以我们不需要管了
         */
        CFRelease(observer);
    }
    
    复制代码

我们来看一下输出

![监听者监听RunLoop运行状态](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3ede2bff0d8948a88ebe255e3b1fff79~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

以上可以看出，Observer确实用来监听RunLoop的状态，包括唤醒，休息，以及处理各种事件。

八. RunLoop的运行逻辑
===============

通过前面篇幅了解了RunLoop相关的一些数据类型  
这时我们再来分析RunLoop的运行逻辑,就会简单明了很多。  
现在回头看官方文档RunLoop的处理逻辑，对RunLoop的处理逻辑有新的认识。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0c3efdb4bd9c4c57870c56e55938eebd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

1\. 源码解析
--------

下面源码仅保留了主流程代码

    // 共外部调用的公开的CFRunLoopRun方法，其内部会调用CFRunLoopRunSpecific
    void CFRunLoopRun(void) {	/* DOES CALLOUT */
        int32_t result;
        do {
            result = CFRunLoopRunSpecific(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 1.0e10, false);
            CHECK_FOR_FORK();
        } while (kCFRunLoopRunStopped != result && kCFRunLoopRunFinished != result);
    }
    
    // 经过精简的 CFRunLoopRunSpecific 函数代码，其内部会调用__CFRunLoopRun函数
    Int32 CFRunLoopRunSpecific(CFRunLoopRef rl, CFStringRef modeName, CFTimeInterval seconds, Boolean returnAfterSourceHandled) {     /* DOES CALLOUT */
    
        // 通知Observers : 进入Loop
        // __CFRunLoopDoObservers内部会调用 __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__
    函数
        if (currentMode->_observerMask & kCFRunLoopEntry ) __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopEntry);
        
        // 核心的Loop逻辑
        result = __CFRunLoopRun(rl, currentMode, seconds, returnAfterSourceHandled, previousMode);
        
        // 通知Observers : 退出Loop
        if (currentMode->_observerMask & kCFRunLoopExit ) __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
    
        return result;
    }
    
    // 精简后的 __CFRunLoopRun函数，保留了主要代码
    static int32_t __CFRunLoopRun(CFRunLoopRef rl, CFRunLoopModeRef rlm, CFTimeInterval seconds, Boolean stopAfterHandle, CFRunLoopModeRef previousMode) {
        int32_t retVal = 0;
        do {
            // 通知Observers：即将处理Timers
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeTimers); 
            
            // 通知Observers：即将处理Sources
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeSources);
            
            // 处理Blocks
            __CFRunLoopDoBlocks(rl, rlm);
            
            // 处理Sources0
            if (__CFRunLoopDoSources0(rl, rlm, stopAfterHandle)) {
                // 处理Blocks
                __CFRunLoopDoBlocks(rl, rlm);
            }
            
            // 如果有Sources1，就跳转到handle_msg标记处
            if (__CFRunLoopServiceMachPort(dispatchPort, &msg, sizeof(msg_buffer), &livePort, 0, &voucherState, NULL)) {
                goto handle_msg;
            }
            
            // 通知Observers：即将休眠
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopBeforeWaiting);
            
            // 进入休眠，等待其他消息唤醒
            __CFRunLoopSetSleeping(rl);
            __CFPortSetInsert(dispatchPort, waitSet);
            do {
                __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort, poll ? 0 : TIMEOUT_INFINITY, &voucherState, &voucherCopy);
            } while (1);
            
            // 醒来
            __CFPortSetRemove(dispatchPort, waitSet);
            __CFRunLoopUnsetSleeping(rl);
            
            // 通知Observers：已经唤醒
            __CFRunLoopDoObservers(rl, rlm, kCFRunLoopAfterWaiting);
            
        handle_msg: // 看看是谁唤醒了RunLoop，进行相应的处理
            if (被Timer唤醒的) {
                // 处理Timer
                __CFRunLoopDoTimers(rl, rlm, mach_absolute_time());
            }
            else if (被GCD唤醒的) {
                __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
            } else { // 被Sources1唤醒的
                __CFRunLoopDoSource1(rl, rlm, rls, msg, msg->msgh_size, &reply);
            }
            
            // 执行Blocks
            __CFRunLoopDoBlocks(rl, rlm);
            
            // 根据之前的执行结果，来决定怎么做，为retVal赋相应的值
            if (sourceHandledThisLoop && stopAfterHandle) {
                retVal = kCFRunLoopRunHandledSource;
            } else if (timeout_context->termTSR < mach_absolute_time()) {
                retVal = kCFRunLoopRunTimedOut;
            } else if (__CFRunLoopIsStopped(rl)) {
                __CFRunLoopUnsetStopped(rl);
                retVal = kCFRunLoopRunStopped;
            } else if (rlm->_stopped) {
                rlm->_stopped = false;
                retVal = kCFRunLoopRunStopped;
            } else if (__CFRunLoopModeIsEmpty(rl, rlm, previousMode)) {
                retVal = kCFRunLoopRunFinished;
            }
            
        } while (0 == retVal);
        
        return retVal;
    } 
    复制代码

上述源代码中，相应处理事件函数内部还会调用更底层的函数  
内部调用才是真正处理事件的函数，通过上面bt打印全部堆栈信息也可以得到验证。

2\. RunLoop的运行逻辑
----------------

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fb43b60b943347e58bf2e0ac8053d4f2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 此时我们按照源码重新整理一下RunLoop处理逻辑就会很清晰: ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/790da17af38441bababec6da3da6c50a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

九. RunLoop休眠的实现原理
=================

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/65fe550aa16d4766b11c552ef5d55765~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

十. RunLoop退出
============

1.  主线程销毁RunLoop退出
2.  Mode中有一些Timer 、Source、 Observer，这些保证Mode不为空时保证RunLoop没有空转并且是在运行的，当Mode中为空的时候，RunLoop会立刻退出
3.  我们在启动RunLoop的时候可以设置什么时候停止

    [NSRunLoop currentRunLoop]runUntilDate:<#(nonnull NSDate *)#>
    [NSRunLoop currentRunLoop]runMode:<#(nonnull NSString *)#> beforeDate:<#(nonnull NSDate *)#>
    复制代码

十 、面试题
======

最后通过一些面试题检验一下对Runloop的掌握程度

1.  讲讲 RunLoop，项目中有用到吗？
2.  RunLoop内部实现逻辑？
3.  Runloop和线程的关系？
4.  timer 与 Runloop 的关系？
5.  程序中添加每3秒响应一次的NSTimer，当拖动tableview时timer可能无法响应要怎么解决？
6.  Runloop 是怎么响应用户操作的， 具体流程是什么样的？
7.  说说RunLoop的几种状态？
8.  Runloop的mode作用是什么？

参考资料
====

[苹果官方文档](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fmac%2Fdocumentation%2FCocoa%2FConceptual%2FMultithreading%2FRunLoopManagement%2FRunLoopManagement.html "https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html")

[CFRunLoopRef源码](https://link.juejin.cn?target=https%3A%2F%2Fopensource.apple.com%2Ftarballs%2FCF%2F "https://opensource.apple.com/tarballs/CF/")