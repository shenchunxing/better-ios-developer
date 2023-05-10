前言
==

> 之前,我们在探索动画及渲染相关原理的时候,我们输出了几篇文章,解答了`iOS动画是如何渲染,特效是如何工作的疑惑`。我们深感系统设计者在创作这些系统框架的时候,是如此脑洞大开,也 **`深深意识到了解一门技术的底层原理对于从事该方面工作的重要性。`**
> 
> 因此我们决定 **`进一步探究iOS底层原理的任务`**。继上一篇文章了解了【iOS中的10个线程锁,与线程锁类型：自旋锁、互斥锁、递归锁】 探索之后,本篇文章将继续对GCD多线程底层原理的探索

一、原子锁atomic
===========

1\. atomic
----------

`atomic`用于保证属性`setter、getter`的原子性操作，相当于在`getter和setter`内部加了线程同步的锁

原子性：原子即为最小的物理单位，意味不可再分割；即代码都为一个整体在同一线程进行操作

`atomic`只是保证`setter、getter`是线程安全的，并不能保证使用属性的过程是线程安全的

2\. 从源码分析`getter和setter`对于`atomic`的使用
-------------------------------------

我们在`objc4`中的`objc-accessors.mm`中找到对应的`getter和setter`的实现

`getter`的实现

    // getter
    id objc_getProperty(id self, SEL _cmd, ptrdiff_t offset, BOOL atomic) {
        if (offset == 0) {
            return object_getClass(self);
        }
    
        // Retain release world
        id *slot = (id*) ((char*)self + offset);
        if (!atomic) return *slot;
            
        // Atomic retain release world
        spinlock_t& slotlock = PropertyLocks[slot];
        slotlock.lock();
        id value = objc_retain(*slot);
        slotlock.unlock();
        
        // for performance, we (safely) issue the autorelease OUTSIDE of the spinlock.
        return objc_autoreleaseReturnValue(value);
    }
    复制代码

`setter`的实现

    static inline void reallySetProperty(id self, SEL _cmd, id newValue, ptrdiff_t offset, bool atomic, bool copy, bool mutableCopy)
    {
        if (offset == 0) {
            object_setClass(self, newValue);
            return;
        }
    
        id oldValue;
        id *slot = (id*) ((char*)self + offset);
    
        if (copy) {
            newValue = [newValue copyWithZone:nil];
        } else if (mutableCopy) {
            newValue = [newValue mutableCopyWithZone:nil];
        } else {
            if (*slot == newValue) return;
            newValue = objc_retain(newValue);
        }
    
        if (!atomic) {
            oldValue = *slot;
            *slot = newValue;
        } else {
            spinlock_t& slotlock = PropertyLocks[slot];
            slotlock.lock();
            oldValue = *slot;
            *slot = newValue;        
            slotlock.unlock();
        }
    
        objc_release(oldValue);
    }
    复制代码

从源码可以看出只有`automic`的属性才会进行加锁操作

二、iOS中的读写安全方案 线程锁的选择
====================

思考以下场景，怎么做最合适

*   同一时间，只能有1个线程进行写的操作
*   同一时间，允许有多个线程进行读的操作
*   同一时间，不允许既有写的操作，又有读的操作

上面的场景就是典型的“多读单写”，经常用于文件等数据的读写操作，iOS中的实现方案有以下两个

*   `pthread_rwlock`：读写锁
*   `dispatch_barrier_async`：异步栅栏调用

1\. pthread\_rwlock
-------------------

`pthread_rwlock`是专用于读写文件的锁，其本质也是互斥锁，等待锁的线程会进入休眠

使用代码如下

    @interface ViewController ()
    @property (assign, nonatomic) pthread_rwlock_t lock;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        // 初始化锁
        pthread_rwlock_init(&_lock, NULL);
        
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        
        for (int i = 0; i < 10; i++) {
            dispatch_async(queue, ^{
                [self read];
            });
            dispatch_async(queue, ^{
                [self write];
            });
        }
    }
    
    
    - (void)read {
        // 加上读取数据的锁
        pthread_rwlock_rdlock(&_lock);
        
        sleep(1);
        NSLog(@"%s", __func__);
        
        pthread_rwlock_unlock(&_lock);
    }
    
    - (void)write
    {
        // 加上写入数据的锁
        pthread_rwlock_wrlock(&_lock);
        
        sleep(1);
        NSLog(@"%s", __func__);
        
        pthread_rwlock_unlock(&_lock);
    }
    
    - (void)dealloc
    {
        // 释放时要销毁锁
        pthread_rwlock_destroy(&_lock);
    }
    
    
    @end
    复制代码

2\. dispatch\_barrier\_async
----------------------------

`dispatch_barrier_async`也叫栅栏函数，意在用于拦截多线程异步并发操作，只保证同时有一条线程在操作

用栅栏函数也可以保证多读单写的操作

使用代码如下

    @interface ViewController ()
    @property (strong, nonatomic) dispatch_queue_t queue;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);
        
        for (int i = 0; i < 10; i++) {
            dispatch_async(self.queue, ^{
                [self read];
            });
            
            dispatch_async(self.queue, ^{
                [self read];
            });
            
            dispatch_async(self.queue, ^{
                [self read];
            });
            
            // 这个函数传入的并发队列必须是自己通过dispatch_queue_cretate创建的
            dispatch_barrier_async(self.queue, ^{
                [self write];
            });
        }
    }
    
    
    - (void)read {
        sleep(1);
        NSLog(@"read");
    }
    
    - (void)write
    {
        sleep(1);
        NSLog(@"write");
    }
    
    @end
    复制代码

三、定时器
=====

我们日常使用的定时器有以下几个:

*   CADisplayLink
*   NSTimer
*   GCD定时器

1\. CADisplayLink
-----------------

`CADisplayLink`是用于同步屏幕刷新频率的定时器

### 1.1 CADisplayLink和NSTimer的区别

*   iOS设备的屏幕刷新频率是固定的，`CADisplayLink`在正常情况下会在每次刷新结束都被调用，精确度相当高
*   `NSTimer`的精确度就显得低了点，比如`NSTimer`的触发时间到的时候，`runloop`如果在阻塞状态，触发时间就会推迟到下一个`runloop`周期。并且`NSTimer`新增了`tolerance`属性，让用户可以设置可以容忍的触发的时间的延迟范围
*   `CADisplayLink`使用场合相对专一，适合做UI的不停重绘，比如自定义动画引擎或者视频播放的渲染。`NSTimer`的使用范围要广泛的多，各种需要单次或者循环定时处理的任务都可以使用。在UI相关的动画或者显示内容使用`CADisplayLink`比起用`NSTimer`的好处就是我们不需要在格外关心屏幕的刷新频率了，因为它本身就是跟屏幕刷新同步的。

### 1.2 CADisplayLink在使用中会出现的循环引用问题

`CADisplayLink`在日常使用中，可能会出现循环引用问题，见示例代码

    @interface ViewController ()
    @property (strong, nonatomic) CADisplayLink *link;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(linkTest)];
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    - (void)linkTest
    {
        NSLog(@"%s", __func__);
    }
    
    - (void)dealloc
    {
        NSLog(@"%s", __func__);
        [self.link invalidate];
    }
    
    @end
    复制代码

由于`ViewController`里有个`link属性`指向这`CADisplayLink对象`，`CADisplayLink对象`里的`target`又指向着`ViewController`里的`linkTest`，都是强引用，所以会造成循环引用，无法释放

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/58aa0be11d474746b229c4eb18c75697~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 1.3 解决方案

增加第三个对象，通过第三个对象将target调用的方法转发出去，具体如下图所示

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5b5b730b309749fa8a3b05a425396a18~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

实现代码如下

    @interface HPProxy : NSObject
    
    + (instancetype)proxyWithTarget:(id)target;
    @property (weak, nonatomic) id target;
    @end
    
    @implementation HPProxy
    
    + (instancetype)proxyWithTarget:(id)target
    {
        LLProxy *proxy = [[LLProxy alloc] init];
        proxy.target = target;
        return proxy;
    }
    
    - (id)forwardingTargetForSelector:(SEL)aSelector
    {
        return self.target;
    }
    
    @end
    
    // ViewController.m文件中
    #import "ViewController.h"
    #import "HPProxy.h"
    
    @interface ViewController ()
    @property (strong, nonatomic) CADisplayLink *link;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.link = [CADisplayLink displayLinkWithTarget:[HPProxy proxyWithTarget:self] selector:@selector(linkTest)];
        [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    - (void)linkTest
    {
        NSLog(@"%s", __func__);
    }
    
    - (void)dealloc
    {
        NSLog(@"%s", __func__);
        [self.link invalidate];
    }
    
    @end
    复制代码

2\. NSTimer
-----------

`NSTimer`也是定时器，相比`CADisplayLink`使用范围更广，更灵活，但精确度会低一些

### 2.1 NSTimer在使用中会出现的循环引用问题

`NSTimer`在使用时也会存在循环引用问题，同`CADisplayLink`

    @interface ViewController ()
    
    @property (strong, nonatomic) NSTimer *timer;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTest) userInfo:nil repeats:YES];
    }
    
    - (void)timerTest
    {
        NSLog(@"%s", __func__);
    }
    
    
    - (void)dealloc
    {
        NSLog(@"%s", __func__);
        
        [self.timer invalidate];
    }
    
    @end
    复制代码

### 2.2 解决方案

【第一种】借助第三对象并将方法转发，同`CADisplayLink`

    @interface ViewController ()
    
    @property (strong, nonatomic) NSTimer *timer;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[HPProxy proxyWithTarget:self] selector:@selector(timerTest) userInfo:nil repeats:YES];    
    }
    
    - (void)timerTest
    {
        NSLog(@"%s", __func__);
    }
    
    
    - (void)dealloc
    {
        NSLog(@"%s", __func__);
        
        [self.timer invalidate];
    }
    
    @end
    复制代码

【第二种】使用`NSTimer`的`block回调`来调用方法，并将`self`改为弱指针

    __weak typeof(self) weakSelf = self;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
       [weakSelf timerTest];
    }];
    复制代码

3\. 统一优化方案
----------

### 3.1 NSProxy

`NSProxy`是唯一一个没有继承自`NSObject`的类，它是专门用来做消息转发的

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/58810490656d40dd98c8fc6bec46e758~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 3.2 特点

*   不继承`NSObject`，也是基类类型
*   没有`init方法`，直接用`alloc方法`来初始化
*   没有`forwardingTargetForSelector方法`，只支持消息转发

### 3.3 优化方案

将`HPProxy`继承自`NSProxy`，然后在消息转发里替换`target`

这么做的好处在于`NSProxy`相比`NSObject`少了消息发送先从父类查找的过程，以及不经过`forwardingTargetForSelector`，相比之下性能会高

替换代码如下

    @interface HPProxy : NSProxy
    + (instancetype)proxyWithTarget:(id)target;
    @property (weak, nonatomic) id target;
    @end
    
    @implementation LLProxy
    
    + (instancetype)proxyWithTarget:(id)target
    {
        // NSProxy对象不需要调用init，因为它本来就没有init方法
        LLProxy *proxy = [LLProxy alloc];
        proxy.target = target;
        return proxy;
    }
    
    - (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
    {
        return [self.target methodSignatureForSelector:sel];
    }
    
    - (void)forwardInvocation:(NSInvocation *)invocation
    {
        [invocation invokeWithTarget:self.target];
    }
    @end
    复制代码

### 3.4 从源码实现来分析

我们先查看下面这句代码打印什么

    ViewController *vc = [[ViewController alloc] init];
    HPProxy *proxy = [HPProxy proxyWithTarget:vc];
       
    NSLog(@"%d, [proxy isKindOfClass:[ViewController class]]);
    复制代码

打印结果为1，可以看出`NSProxy`的`isKindOfClass`和`NSObject`的`isKindOfClass`有所差别

我们可以通过`GNUstep`来查看`NSProxy`的源码实现，发现其内部会直接调用消息转发的方法，才会有我们将target替换成了`ViewController`对象，所以最后调用`isKindOfClass`的是`ViewController对象`，那么结果也就知晓了

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc25f16ccfd44edc87b36116ab25e38f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从该方法可以反观`NSProxy`的其他方法内部实现，都会主动触发消息转发的实现

4\. GCD定时器
----------

`GCD定时器`相比其他两个定时器是最准时的，因为和系统内核直接挂钩

使用代码如下

我们将`GCD定时器`封装到自定义的`LLTimer`文件来使用

    // HPTimer.h文件
    @interface HPTimer : NSObject
    
    + (NSString *)execTask:(void(^)(void))task
               start:(NSTimeInterval)start
            interval:(NSTimeInterval)interval
             repeats:(BOOL)repeats
               async:(BOOL)async;
    
    + (NSString *)execTask:(id)target
                  selector:(SEL)selector
                     start:(NSTimeInterval)start
                  interval:(NSTimeInterval)interval
                   repeats:(BOOL)repeats
                     async:(BOOL)async;
    
    + (void)cancelTask:(NSString *)name;
    
    
    // HPTimer.m文件
    #import "HPTimer.h"
    
    @implementation HPTimer
    
    static NSMutableDictionary *timers_;
    static dispatch_semaphore_t semaphore_;
    
    + (void)initialize
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            timers_ = [NSMutableDictionary dictionary];
            
            // 加锁来保证多线程创建定时器和取消定时器同时只能有一个操作
            semaphore_ = dispatch_semaphore_create(1);
        });
    }
    
    + (NSString *)execTask:(void (^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async
    {
        if (!task || start < 0 || (interval <= 0 && repeats)) return nil;
        
        // 队列
        dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue();
        
        // 创建定时器
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        // 设置时间
        // dispatch_time_t start：几秒后开始执行
        // uint64_t interval：执行间隔
        dispatch_source_set_timer(timer,
                                  dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC),
                                  interval * NSEC_PER_SEC, 0);
        
        
        dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
        // 定时器的唯一标识
        NSString *name = [NSString stringWithFormat:@"%zd", timers_.count];
        // 存放到字典中
        timers_[name] = timer;
        dispatch_semaphore_signal(semaphore_);
        
        // 设置回调
        dispatch_source_set_event_handler(timer, ^{
            task();
            
            if (!repeats) { // 不重复的任务
                [self cancelTask:name];
            }
        });
        
        // 启动定时器
        dispatch_resume(timer);
        
        return name;
    }
    
    + (NSString *)execTask:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async
    {
        if (!target || !selector) return nil;
        
        return [self execTask:^{
            if ([target respondsToSelector:selector]) {
                
    // 去掉警告
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [target performSelector:selector];
    #pragma clang diagnostic pop
            }
        } start:start interval:interval repeats:repeats async:async];
    }
    
    + (void)cancelTask:(NSString *)name
    {
        if (name.length == 0) return;
        
        dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
        
        dispatch_source_t timer = timers_[name];
        if (timer) {
            dispatch_source_cancel(timer);
            [timers_ removeObjectForKey:name];
        }
    
        dispatch_semaphore_signal(semaphore_);
    }
    
    @end
    复制代码

然后在控制器里调用

    #import "ViewController.h"
    #import "HPTimer.h"
    
    @interface ViewController ()
    
    @property (copy, nonatomic) NSString *task;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        NSLog(@"begin");
        
        // selector方式
        self.task = [HPTimer execTask:self
                             selector:@selector(doTask)
                                start:2.0
                             interval:1.0
                              repeats:YES
                                async:YES];
        
        // block方式
    //    self.task = [HPTimer execTask:^{
    //        NSLog(@"111111 - %@", [NSThread currentThread]);
    //    } start:2.0 interval:-10 repeats:NO async:NO];
    }
    
    - (void)doTask
    {
        NSLog(@"doTask - %@", [NSThread currentThread]);
    }
    
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {
        [HPTimer cancelTask:self.task];
    }
    复制代码

### 4.1 HPTimer

*   在`initialize方法`里只执行一次字典的创建和锁的创建（只有用到该类时才创建，并且避免多次调用）
*   内部创建一个全局的字典用来保存多个定时器的创建（`定时器的个数递增`作为key，`timer`为value）
*   外部支持多个参数来控制定时器在哪个线程创建，以及是否只调用一次
*   注意细节的优化，对于传入的时间、是否有任务，以及定时器的标识都对应做校验
*   在多线程环境下，保证创建定时器和取消删除定时器同一时间只能有一个线程在执行

四、 面试题
======

从网上搜罗了一些面试题，我们不妨通过一些面试题来检查一下对知识点的掌握

1.看下面两段代码，会不会造成死锁
-----------------

    // 段1
    - (void)viewDidLoad {
        [super viewDidLoad];
        
    	NSLog(@"执行任务1");
    	    
    	dispatch_queue_t queue = dispatch_get_main_queue();
    	dispatch_sync(queue, ^{
    	   NSLog(@"执行任务2");
    	});
    	    
    	NSLog(@"执行任务3");
    }
    
    // 段2
    - (void)viewDidLoad {
        [super viewDidLoad];
        
    	NSLog(@"执行任务1");
    	    
    	dispatch_queue_t queue = dispatch_get_main_queue();
    	dispatch_async(queue, ^{
    	   NSLog(@"执行任务2");
    	});
    	    
    	NSLog(@"执行任务3");
    }
    复制代码

第一段会死锁，第二段不会

因为整个函数`viewDidLoad`的执行都是在主队列中串行执行的，所以要等函数执行完才会执行任务2，但是`dispatch_sync`又是同步的，在主线程中是要执行`dispatch_sync`之后才会执行任务3的代码，所以互相之前都要等待，就造成了死锁

而`dispatch_async`不会，因为需要等待一会才会执行任务2的代码，所以会先执行任务再执行任务2，不需要马上执行；但是不会开启新的线程

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9657988eac98419bb2ca7bd030e054a1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2.看下面这段代码，会不会造成死锁？将队列改为并发队列，会不会死锁
---------------------------------

    NSLog(@"执行任务1");
        
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
        
    dispatch_async(queue, ^{ // block0
       NSLog(@"执行任务2");
       
       dispatch_sync(queue, ^{ // block1
           NSLog(@"执行任务3");
       });
       
       NSLog(@"执行任务4");
    });
        
    NSLog(@"执行任务5");
    复制代码

会的。 原因是由于是`dispatch_async`，所以会先执行任务1和任务5，然后由于是串行队列，那么先会执行`block0`，再执行`block1`；但是任务2执行完，后面的是`dispatch_sync`，就表示要马上执行任务3，可任务3的执行又是要等`block0`执行完才可以，于是就会造成死锁

改为并发队列后不会死锁，虽然都是同一个并发队列，但是可以同时执行多个任务，不需要等待

3.看下面这段代码，会不会造成死锁？将队列2改为并发队列，会不会死锁
----------------------------------

    NSLog(@"执行任务1");
        
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t queue2 = dispatch_queue_create("myqueu2", DISPATCH_QUEUE_SERIAL);
        
    dispatch_async(queue, ^{ // block0
       NSLog(@"执行任务2");
       
       dispatch_sync(queue2, ^{ // block1
           NSLog(@"执行任务3");
       });
       
       NSLog(@"执行任务4");
    });
        
    NSLog(@"执行任务5");
    复制代码

都不会。因为两个任务都是在两个队列里，所以不会有等待情况

4.看下面代码打印结果是什么，为什么，怎么改
----------------------

    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        
    dispatch_async(queue, ^{
       NSLog(@"1");
       [self performSelector:@selector(test) withObject:nil afterDelay:.0];
       NSLog(@"3");
    });
    
    - (void)test
    {
        NSLog(@"2");
    }
    复制代码

打印1、3。

因为`performSelector: withObject: afterDelay:`这个方法是属于`RunLoop`的库的，有`afterDelay:` 参数的本质都是往`RunLoop`中添加定时器的，由于当前是在子线程中，不会创建`RunLoop`，所以创建`RunLoop`后就可以执行该调用，并打印1、3、2

由于该方法的实现`RunLoop`是没有开源的，我们要想了解方法实现的本质，可以通过`GNUstep`开源项目来查看，这个项目将`Cocoa的OC库`重新开源实现了一遍，虽然不是官网源码，但也有一定的参考价值

源码地址：[www.gnustep.org/resources/d…](https://link.juejin.cn?target=http%3A%2F%2Fwww.gnustep.org%2Fresources%2Fdownloads.php "http://www.gnustep.org/resources/downloads.php")

我们在官网上找到`GNUstep Base`进行下载

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8e322f96bb384681ae0c72d70edcff75~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

然后找到`RunLoop.m`中`performSelector: withObject: afterDelay:`的实现

    - (void) performSelector: (SEL)aSelector
    	      withObject: (id)argument
    	      afterDelay: (NSTimeInterval)seconds {
    	      
      NSRunLoop	 *loop = [NSRunLoop currentRunLoop];
      GSTimedPerformer *item;
    
      item = [[GSTimedPerformer alloc] initWithSelector: aSelector
    					     target: self
    					   argument: argument
    					      delay: seconds];
      [[loop _timedPerformers] addObject: item];
      RELEASE(item);
      [loop addTimer: item->timer forMode: NSDefaultRunLoopMode];
    }
    复制代码

找到`GSTimedPerformer`的构造方法里面可以看到，会创建一个`timer的定时器`，然后将它加到`RunLoop`中

    - (id) initWithSelector: (SEL)aSelector
    		 target: (id)aTarget
    	       argument: (id)anArgument
    		  delay: (NSTimeInterval)delay
    {
      self = [super init];
      if (self != nil)
        {
          selector = aSelector;
          target = RETAIN(aTarget);
          argument = RETAIN(anArgument);
          timer = [[NSTimer allocWithZone: NSDefaultMallocZone()]
    	initWithFireDate: nil
    		interval: delay
    		  target: self
    		selector: @selector(fire)
    		userInfo: nil
    		 repeats: NO];
        }
      return self;
    }
    复制代码

如此一来就印证了我们的分析，下面我们就手动在子线程创建`RunLoop`来查看

    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        
    dispatch_async(queue, ^{
       NSLog(@"1");
       // 这句代码的本质是往Runloop中添加定时器
       [self performSelector:@selector(test) withObject:nil afterDelay:.0];
       NSLog(@"3");
       
       [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    });
    
    - (void)test
    {
        NSLog(@"2");
    }
    复制代码

创建空的`RunLoop`之前因为已经通过`performSelector: withObject: afterDelay:`创建了一个定时器加了进去，所以`RunLoop`就不为空了，不需要我们再添加一个`Source1`了，这样也保证`RunLoop`不会退出

运行程序，打印结果为1、3、2

最后打印2是因为`RunLoop`被唤醒处理事件有时间延迟，所以会晚一些打印

5.看下面代码打印结果是什么，为什么，怎么改
----------------------

    - (void)test
    {
        NSLog(@"2");
    }
    
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
        NSThread *thread = [[NSThread alloc] initWithBlock:^{
           NSLog(@"1");
        }];
      
        [thread start];
            
        [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
    }
    复制代码

打印结果为1，并且崩溃了。

因为执行线程的`block`和`performSelector`几乎是同时的，所以先执行了`block`后的线程就被销毁了，这时再在该线程上发消息就是会报错

解决办法也是创建`RunLoop`并让子线程不被销毁

    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
        NSThread *thread = [[NSThread alloc] initWithBlock:^{
            NSLog(@"1");
            
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }];
        [thread start];
        
        [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
    }
    复制代码

6.`dispatch_once`是怎么做到只创建一次的，内部是怎么实现的
-------------------------------------

我们知道`GCD`中的`dispatch_once`的使用如下代码，可以做的只执行一次，一般用来创建单例

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"单例应用");
    });
    复制代码

我们可以通过源码来分析内部实现，在`once.c`中找到`dispatch_once`的实现

    void
    dispatch_once(dispatch_once_t *val, dispatch_block_t block)
    {
    	// val是onceToken静态变量
    	dispatch_once_f(val, block, _dispatch_Block_invoke(block));
    }
    复制代码

其中的`_dispatch_Block_invoke`是一个宏定义，用来包装`block`

    #define _dispatch_Block_invoke(bb) \
    		((dispatch_function_t)((struct Block_layout *)bb)->invoke)
    复制代码

找到其底层是通过`dispatch_once_f`实现的

    void
    dispatch_once_f(dispatch_once_t *val, void *ctxt, dispatch_function_t func)
    {
    	// 将外界传入的静态变量val转变为dispatch_once_gate_t类型的变量l
    	dispatch_once_gate_t l = (dispatch_once_gate_t)val;
    
    #if !DISPATCH_ONCE_INLINE_FASTPATH || DISPATCH_ONCE_USE_QUIESCENT_COUNTER
    	// 获取任务标识符v
    	uintptr_t v = os_atomic_load(&l->dgo_once, acquire);
    	// 如果v == DLOCK_ONCE_DONE，表示任务已经执行过了，直接return
    	if (likely(v == DLOCK_ONCE_DONE)) {
    		return;
    	}
    #if DISPATCH_ONCE_USE_QUIESCENT_COUNTER
    	// 如果加锁失败走到这里，再次进行存储，并标记为DLOCK_ONCE_DONE
    	if (likely(DISPATCH_ONCE_IS_GEN(v))) {
    		return _dispatch_once_mark_done_if_quiesced(l, v);
    	}
    #endif
    #endif
    	if (_dispatch_once_gate_tryenter(l)) { // 尝试进入任务
    		return _dispatch_once_callout(l, ctxt, func);
    	}
    	
    	// 此时已有任务，则进入无限等待
    	return _dispatch_once_wait(l);
    }
    复制代码

**`dispatch_once_f`函数的详细调用分析**

1.`os_atomic_load`这个宏用来获取任务标识

    #define os_atomic_load(p, m) \
    		atomic_load_explicit(_os_atomic_c11_atomic(p), memory_order_##m)
    复制代码

2.通过`_dispatch_once_mark_done_if_quiesced`进行再次存储和标记

    DISPATCH_ALWAYS_INLINE
    static inline void
    _dispatch_once_mark_done_if_quiesced(dispatch_once_gate_t dgo, uintptr_t gen)
    {
    	if (_dispatch_once_generation() - gen >= DISPATCH_ONCE_GEN_SAFE_DELTA) {
    		/*
    		 * See explanation above, when the quiescing counter approach is taken
    		 * then this store needs only to be relaxed as it is used as a witness
    		 * that the required barriers have happened.
    		 */
    		
    		// 再次存储，并标记为DLOCK_ONCE_DONE
    		os_atomic_store(&dgo->dgo_once, DLOCK_ONCE_DONE, relaxed);
    	}
    }
    复制代码

3.通过`_dispatch_once_gate_tryenter`内部进行比较并加锁

    DISPATCH_ALWAYS_INLINE
    static inline bool
    _dispatch_once_gate_tryenter(dispatch_once_gate_t l)
    {
    	// 进行比较，如果没问题，则进行加锁，并标记为DLOCK_ONCE_UNLOCKED
    	return os_atomic_cmpxchg(&l->dgo_once, DLOCK_ONCE_UNLOCKED,
    			(uintptr_t)_dispatch_lock_value_for_self(), relaxed);
    }
    复制代码

4.通过`_dispatch_once_callout`来执行回调

    DISPATCH_NOINLINE
    static void
    _dispatch_once_callout(dispatch_once_gate_t l, void *ctxt,
    		dispatch_function_t func)
    {
    	// 回调执行
    	_dispatch_client_callout(ctxt, func);
    	// 进行广播
    	_dispatch_once_gate_broadcast(l);
    }
    复制代码

`_dispatch_client_callout`内部就是执行`block回调`

    DISPATCH_ALWAYS_INLINE
    static inline void
    _dispatch_client_callout(void *ctxt, dispatch_function_t f)
    {
    	return f(ctxt);
    }
    复制代码

`_dispatch_once_gate_broadcast`内部会调用`_dispatch_once_mark_done`

    DISPATCH_ALWAYS_INLINE
    static inline void
    _dispatch_once_gate_broadcast(dispatch_once_gate_t l)
    {
    	dispatch_lock value_self = _dispatch_lock_value_for_self();
    	uintptr_t v;
    #if DISPATCH_ONCE_USE_QUIESCENT_COUNTER
    	v = _dispatch_once_mark_quiescing(l);
    #else
    	v = _dispatch_once_mark_done(l);
    #endif
    	if (likely((dispatch_lock)v == value_self)) return;
    	_dispatch_gate_broadcast_slow(&l->dgo_gate, (dispatch_lock)v);
    }
    复制代码

`_dispatch_once_mark_done`内部就是赋值并标记，即解锁

    DISPATCH_ALWAYS_INLINE
    static inline uintptr_t
    _dispatch_once_mark_done(dispatch_once_gate_t dgo)
    {
    	// 如果不相同，则改成相同，并标记为DLOCK_ONCE_DONE
    	return os_atomic_xchg(&dgo->dgo_once, DLOCK_ONCE_DONE, release);
    }
    复制代码

五、总结：
=====

GCD单例中，有两个重要参数，`onceToken`和`block`，其中`onceToken`是静态变量，具有唯一性，在底层被封装成了`dispatch_once_gate_t`类型的变量`l`，`l`主要是用来获取底层原子封装性的关联，即变量`v`，通过`v`来查询任务的状态，如果此时`v`等于`DLOCK_ONCE_DONE`，说明任务已经处理过一次了，直接`return`

如果此时任务没有执行过，则会在底层通过`C++函数`的比较，将任务进行加锁，即任务状态置为`DLOCK_ONCE_UNLOCK`，目的是为了保证当前任务执行的唯一性，防止在其他地方有多次定义。加锁之后进行block回调函数的执行，执行完成后，将当前任务解锁，将当前的任务状态置为`DLOCK_ONCE_DONE`，在下次进来时，就不会在执行，会直接返回

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ccc79ba5757943f3b4bc99f353c0d464~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

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