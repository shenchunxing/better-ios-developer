# Runloop的应用

前言
--

> 之前,我们在探索动画及渲染相关原理的时候,我们输出了几篇文章,解答了`iOS动画是如何渲染,特效是如何工作的疑惑`。我们深感系统设计者在创作这些系统框架的时候,是如此脑洞大开,也 **`深深意识到了解一门技术的底层原理对于从事该方面工作的重要性。`**
> 
> 因此我们决定 **`进一步探究iOS底层原理的任务`**。继上一篇文章对RunLoop进行了探索之后,在本篇文章围绕RunLoop在项目中的一些常见应用展开

本文转自:  
作者：国孩  
链接：[juejin.cn/post/688976…](https://juejin.cn/post/6889769418541252615 "https://juejin.cn/post/6889769418541252615")

概述
--

本篇主要是围绕着项目使用到的Runloop的应用场景及衍生出来的知识点，将讲述以下部分：

*   控制线程的生命周期【线程保活】
*   解决NSTimer在滑动过程中停止工作的问题及衍生问题
*   监控应用卡顿
*   性能优化

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c7f2558603ea4907b8e5d27acac97408~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

一、线程保活
------

线程保活问题,从字面意思上就是保护线程的生命周期不结束.正常情况下,当线程执行完一次任务之后,需要进行资源回收,但是当有一个任务,随时都有可能去调用,如果在子线程去执行,并且让子线程一直存活着,为了避免来回多次创建毁线程的动作, 降低性能消耗.

### 情景1

    #import <Foundation/Foundation.h>
    //定义继承自NSThread线程
    @interface ZXYThread : NSThread
    @end
    
    @implementation ZXYThread
    //线程销毁会被调用
    - (void)dealloc
    {
        NSLog(@"%s", __func__);
    }
    @end
    
    
    @implementation ViewController
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.thread = [[ZXYThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        [self.thread start];
    }
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {
        [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
    }
    
    // 子线程需要执行的任务
    - (void)test
    {
        NSLog(@"%s %@", __func__, [NSThread currentThread]);
    }
    
    - (void)run {
        NSLog(@"%s %@", __func__, [NSThread currentThread]);
        NSLog(@"%s ----end----", __func__);
    }
    @end
    复制代码

当执行完上面的代码后,会发现打印出如下-\[子线程也就销毁了\]

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/539e6d06f41a4620920489dba2bb6046~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

但是运行完App,当点击App时没有反应,也可以证明此线程已经销毁.如果改进让线程处于随时接受命令的状态呢?

### 情景2

从Runloop中得知,**如果Mode里没有任何的Source0/Source1/Timer/Observer, Runloop会立马退出.**

所以会想到能不能向其中加入上面中的一个是否可以如下: \[run 方法中\]

    // 这个方法的目的：线程保活
    - (void)run {
        NSLog(@"%s %@", __func__, [NSThread currentThread]);
        // 往RunLoop里面添加Source\Timer\Observer
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    //    [[NSRunLoop currentRunLoop] addTimer:[[NSTimer alloc]init] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
        NSLog(@"%s ----end----", __func__);
    }
    复制代码

通过在run方法中加入上面代码,让线程一直不死,打印屏幕界面:

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ddce92dbfb88475bb5853d86726f878a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

好像上面已经满足了要求,达到了线程不死的状态,但是能不能在销毁页面控制器的时候,也销毁定时器,并且随时停掉定时器.

### 情景3

**知识点:**

> \*\*如何停止runloop?通过CFRunLoopStop(CFRunLoopGetCurrent())方法可停掉定时器,但是对于用\[\[NSRunLoop currentRunLoop\] run\]的Runloop是不会停掉的,因为通过CFRunLoopStop(CFRunLoopGetCurrent())方法仅仅是停掉了本次的Runloop,而不是停掉所有的,但是\[\[NSRunLoop currentRunLoop\] run\]的run方法是一直有runloop循环,所以通过\[\[NSRunLoop currentRunLoop\] run\]方法是不可能被停掉runloop的  
> 那应该改成什么样的? ----\[\[NSRunLoop currentRunLoop\] runMode:NSDefaultRunLoopMode beforeDate:\[NSDate distantFuture\]\];  
> \*\*

下面直接用代码来解释,里面已经写明了代码思路,下面是A页面->B页面->A页面

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4bdfe0741bf548ef8a528f4aaf91083f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

    @interface ViewController ()
    //继承自NSThead的子线程
    @property (strong, nonatomic) ZXYThread *thread;
    //有个暂停定时器的需求,stopped代表是否点击了暂停
    @property (assign, nonatomic, getter=isStoped) BOOL stopped;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        //NSThread使用block的方法,消除循环引用
        __weak typeof(self) weakSelf = self;
        
        self.stopped = NO;
        self.thread = [[ZXYThread alloc] initWithBlock:^{
            NSLog(@"%@----begin----", [NSThread currentThread]);
            
            // 往RunLoop里面添加Source\Timer\Observer
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        
            while (weakSelf && !weakSelf.isStoped) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            
            NSLog(@"%@----end----", [NSThread currentThread]);
        }];
        [self.thread start];
    }
    
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {
        if (!self.thread) return;
        [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
    }
    
    // 子线程需要执行的任务
    - (void)test
    {
        NSLog(@"%s %@", __func__, [NSThread currentThread]);
    }
    
    - (void) stop {
        if (!self.thread) return;
        // 在子线程调用stop（waitUntilDone设置为YES，代表子线程的代码执行完毕后，这个方法才会往下走）
        [self performSelector:@selector(stopThread) onThread:self.thread withObject:nil waitUntilDone:YES];
    }
    
    // 用于停止子线程的RunLoop
    - (void)stopThread
    {
        // 设置标记为YES
        self.stopped = YES;
        
        // 停止RunLoop
        CFRunLoopStop(CFRunLoopGetCurrent());
        NSLog(@"%s %@", __func__, [NSThread currentThread]);
        
        // 清空线程
        self.thread = nil;
    }
    
    - (void)dealloc
    {
        NSLog(@"%s", __func__);
        
        [self stop];
    }
    
    @end
    复制代码

如果想将上面的代码抽取出来应该怎么办呢?

### 情景4

此处封装工具类并不是直接继承自NSThread,而是继承自NSObject\[因为并不想让别人直接能调用NSThread里面的方法.\]这样符合开闭原则

    #import <Foundation/Foundation.h>
    typedef void (^ZXYPermenantThreadTask)(void);
    @interface ZXYPermenantThread : NSObject
    /**
     在当前子线程执行一个任务
     */
    - (void)executeTask:(ZXYPermenantThreadTask)task;
    /**
     结束线程
     */
    - (void)stop;
    
    @end
    
    #import "ZXYPermenantThread.h"
    
    /** ZXYThread **/
    @interface ZXYThread : NSThread
    @end
    @implementation ZXYThread
    - (void)dealloc{
        NSLog(@"%s", __func__);
    }
    @end
    
    /** ZXYPermenantThread **/
    @interface ZXYPermenantThread()
    @property (strong, nonatomic) ZXYThread *innerThread;
    @property (assign, nonatomic, getter=isStopped) BOOL stopped;
    @end
    
    @implementation ZXYPermenantThread
    #pragma mark - public methods
    - (instancetype)init{
        if (self = [super init]) {
            self.stopped = NO;
            __weak typeof(self) weakSelf = self;
            self.innerThread = [[ZXYThread alloc] initWithBlock:^{
                [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
                
                while (weakSelf && !weakSelf.isStopped) {
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }
            }];
            
            [self.innerThread start];
        }
        return self;
    }
    
    - (void)executeTask:(ZXYPermenantThreadTask)task{
        if (!self.innerThread || !task) return;
        
        [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];
    }
    
    - (void)stop{
        if (!self.innerThread) return;
        [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
    }
    
    - (void)dealloc{
        NSLog(@"%s", __func__);
        [self stop];
    }
    
    #pragma mark - private methods
    - (void)__stop{
        self.stopped = YES;
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.innerThread = nil;
    }
    
    - (void)__executeTask:(ZXYPermenantThreadTask)task{
        task();
    }
    
    @end
    复制代码

上面是针对Runloop在实际开发中的第一个使用场景,那么我们是否在一些好的开源项目中使用过呢或者是看到过呢?

_**拓展\[AFNetworking也使用到了Runloop的线程保活\]**_

AFNetworking中的ANURLConnectionOperation是基于NSURLConnection构建,本质是希望能在后台线程接收到Delegate回调.为此AFNetworking单独创建了一个线程, 并在这个线程中开启了一个Runloop:

    + (void)networkRequestThreadEntryPoint:(id)__unused object {
        @autoreleasepool {
            [[NSThread currentThread] setName:@"AFNetworking"];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
            [runLoop run];
        }
    }
     
    + (NSThread *)networkRequestThread {
        static NSThread *_networkRequestThread = nil;
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
            [_networkRequestThread start];
        });
        return _networkRequestThread;
    }
    复制代码

Runloop启动前必须要至少一个Timer/Observer/Source,所以AFNetworking在\[runLoop run\]

之前创建了NSMachPort添加进去了.通常情况下调用者需要持有这个NSMachPort并在外部线程通过这个port发送消息到loop内

    - (void)start {
        [self.lock lock];
        if ([self isCancelled]) {
            [self performSelector:@selector(cancelConnection) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
        } else if ([self isReady]) {
            self.state = AFOperationExecutingState;
            [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
        }
        [self.lock unlock];
    }
    复制代码

当需要这个后台线程执行任务时,AFNetworking通过调用\[NSObject performSelector:onThread:..\] 将这个任务扔到了后台线程的 RunLoop 中

二、NSTimer问题
-----------

在日常开发中,列表经常会用到NSTimer倒计时问题,或者Interview的时候被面试官问到: NSTimer准时嘛等问题?今天就展开讲述一下原因及方案,最后讲述衍生出来的问题循环引用!争取彻底解决NSTimer带来的疑问?

### 问题一、 NSTimer定时器不准

**原因**

*   NSTimer被添加在mainRunloop中,模式是NSDefaultRunLoopMode, mainRunloop负责所有的主线程事件,例如UI界面的操作,负责的运算使当前Runloop持续的时间超过了定时器的间隔时间,那么下一次定时就被延后,这样就造成timer的阻塞
*   模式的切换,当创建的timer被加入到NSDefaultRunLoopMode时,此时如果有滑动UIScrollView的操作时,runloop的mode会切换为TrackingRunloopMode,这时tiemr会停止回调

**解决方案**

1.  Mode方式的改变,兼顾TrackingRunloopMode
2.  在子线程中创建timer,在主线程进行定时任务的操作或者在子线程中创建timer,在子线程中进行定时任务的操作,需要UI的操作时再切换到主线程进行操作
3.  GCD操作: dispatch\_source\_create以及depatch\_resume等方法

**方案一**

主线程的Runloop使用到的主要有两种模式, NSDefaultRunLoopMode与TrackingRunloopMode模式

添加定时器到主线程的CommonMode中

    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    复制代码

**方案二**

子线程创建timer,主线程执行定时或者子线程创建timer,在子线程执行定时,需要刷新再到主线程

_**子线程启动NSTimer**_

    __weak __typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                strongSelf.countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:strongSelf selector:@selector(countDown) userInfo:nil repeats:YES];
                NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                [runloop addTimer:strongSelf.countTimer forMode:NSDefaultRunLoopMode];
                [runloop run];
            }
        });
    复制代码

_**主线程更新UI**_

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.jumpBTN setTitle:[NSString stringWithFormat:@"跳过 %lds",(long)self.count] forState:UIControlStateNormal];
        });
    复制代码

**方案三**

使用 GCD 的定时器。GCD 的定时器是直接跟系统内核挂钩的，而且它不依赖于RunLoop，所以它非常的准时。

    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_SERIAL);
        
        //创建定时器
        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        //设置时间（start:几s后开始执行； interval:时间间隔）
        uint64_t start = 2.0;    //2s后开始执行
        uint64_t interval = 1.0; //每隔1s执行
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
        //设置回调
        dispatch_source_set_event_handler(timer, ^{
           NSLog(@"%@",[NSThread currentThread]);
        });
        //启动定时器
        dispatch_resume(timer);
        NSLog(@"%@",[NSThread currentThread]);
        
        self.timer = timer;
    复制代码

### 问题二、NSTimer循环引用

_**常识**_

这三个方法直接将**timer添加到了当前runloop default mod**e，而不需要我们自己操作，当然这样的代价是runloop只能是当前runloop，模式是default mode:

    + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;
    
    + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
    
    + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
    复制代码

下面五种创建，**不会自动添加到runloop，还需调用addTimer:forMode:**

    + (NSTimer *)timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
    
    + (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;
    
    + (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;
    
    - (instancetype)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)ti target:(id)t selector:(SEL)s userInfo:(id)ui repeats:(BOOL)rep;
    
    - (instancetype)initWithFireDate:(NSDate *)date interval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;
    复制代码

在实际项目开发中,使用NSTimer解决定时发送任务的需求,但是还是会产生循环引用,今天讲述本项目中的解决方案.

循环引用（Circular Reference）是指两个对象之间相互强引用，两者无法按时释放，从而导致内存泄露.如下:

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a963f39fe0c94f06b2bff3c9fa9dc543~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

发现两者相互引用,都不能得以释放,造成了循环引用

**方案一、给self添加中间件**

引入一个对象proxy,proxy弱引用self,然后proxy传入NSTimer. self强引用NSTimer, NSTimer强引用proxy,proxy弱引用着self,这样通过弱引用解决了相互引用,就不会造成环..本项目中使用的方法是引入中间控件HCCProxy1

定义一个继承自NSObject的中间代理对象HCCProxy1,ViewController不持有timer,而是持有HCCProxy1实例, 让HCCProxy1实例弱引用ViewController, timer强引用HCCProxy1实例,如下:

    @interface HCCProxy1 : NSObject
    + (instancetype)proxyWithTarget:(id)target;
    @property (weak, nonatomic) id target;
    @end
    
    @implementation HCCProxy1
    + (instancetype)proxyWithTarget:(id)target{
        HCCProxy1 *proxy = [[HCCProxy1 alloc] init];
        proxy.target = target;
        return proxy;
    }
    - (id)forwardingTargetForSelector:(SEL)aSelector{
        return self.target;
    }
    @end
    复制代码

在项目中使用如下:

    - (void)viewDidLoad {
        [super viewDidLoad];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[HCCProxy1 proxyWithTarget:self] selector:@selector(timerTest) userInfo:nil repeats:YES];
    }
    复制代码

_**拓展:**_

    - (id)forwardingTargetForSelector:(SEL)aSelector是什么？
      消息转发，简单来说就是如果当前对象没有实现这个方法，系统会到这个方法里来找实现对象。
    
    
    本文中由于当前target是HCCProxy1，但是HCCProxy1没有实现方法(当然也不需要它实现)，让系统去找target实例的方法实现，也就是去找ViewController中的方法实现。
    复制代码

**方案二、使用继承自NSProxy类HCCProxy的消息转发**

    @interface HCCProxy : NSProxy
    + (instancetype)proxyWithTarget:(id)target;
    @property (weak, nonatomic) id target;
    @end
    
    @implementation HCCProxy
    + (instancetype)proxyWithTarget:(id)target{
        // NSProxy对象不需要调用init，因为它本来就没有init方法
        HCCProxy *proxy = [HCCProxy alloc];
        proxy.target = target;
        return proxy;
    }
    
    - (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{
        return [self.target methodSignatureForSelector:sel];
    }
    
    - (void)forwardInvocation:(NSInvocation *)invocation{
        [invocation invokeWithTarget:self.target];
    }
    @end
    复制代码

在项目中使用如下:

    - (void)viewDidLoad {
        [super viewDidLoad];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[HCCProxy proxyWithTarget:self] selector:@selector(timerTest) userInfo:nil repeats:YES];
    }
    复制代码

三、监控卡顿
------

卡顿问题主要是主线程上无法响应用户交互的问题, 如果一个App时不时给你卡一下,有时还长时间没有响应,你还会继续使用嘛?答案当然是显然的

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ada637d35cb94ee0a2496e48a4d77082~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

对于iOS开发来说,监控卡顿就是要去找到主线程都做了哪些事情,线程的消息事件依赖于NSRunloop的,所以从NSRunloop入手,就可以知道主线程上都调用了哪些方法.可以监听NSRunloop的状态,就能够发现调用方法是否执行时间过长从而判断是否出现了卡顿.所以推荐的监控卡顿方案是: **通过监控Runloop的状态来判断是否出现卡顿**

下面我们讲解一下Runloop的底层常识吧

### 1、知识-Runloop原理

Runloop的目的是,当有事情要去处理时保持线程忙,当没有事件要处理的时候让线程进入休眠.下面通过CFRunloop的源码来分享下Runloop的原理

**第一步:**

**通知observers: Runloop要开始进入loop了,紧接着进入loop,代码如下:**

    //通知 observers
    if (currentMode->_observerMask & kCFRunLoopEntry ) 
        __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopEntry);
    //进入 loop
    result = __CFRunLoopRun(rl, currentMode, seconds, returnAfterSourceHandled, previousMode);
    复制代码

**第二步**

开启一个 do while 来保活线程。通知 Observers：RunLoop 会触发 Timer 回调、Source0 回调，接着执行加入的 block.

    // 通知 Observers RunLoop 会触发 Timer 回调
    if (currentMode->_observerMask & kCFRunLoopBeforeTimers)
        __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeTimers);
    // 通知 Observers RunLoop 会触发 Source0 回调
    if (currentMode->_observerMask & kCFRunLoopBeforeSources)
        __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeSources);
    // 执行 block
    __CFRunLoopDoBlocks(runloop, currentMode);
    复制代码

接下来，触发 Source0 回调，如果有 Source1 是 ready 状态的话，就会跳转到 handle\_msg 去处理消息

    if (MACH_PORT_NULL != dispatchPort ) {
        Boolean hasMsg = __CFRunLoopServiceMachPort(dispatchPort, &msg)
        if (hasMsg) goto handle_msg;
    }
    复制代码

**第三步**

回调触发后，通知 Observers：RunLoop 的线程将进入休眠（sleep）状态.

    Boolean poll = sourceHandledThisLoop || (0ULL == timeout_context->termTSR);
    if (!poll && (currentMode->_observerMask & kCFRunLoopBeforeWaiting)) {
        __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeWaiting);
    }
    复制代码

**第四步**

进入休眠后，会等待 mach\_port 的消息，以再次唤醒。只有在下面四个事件出现时才会被再次唤醒：

*   基于 port 的 Source 事件；
*   Timer 时间到；
*   RunLoop 超时；
*   被调用者唤醒。

等待唤醒的代码如下:

    do {
        __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort) {
            // 基于 port 的 Source 事件、调用者唤醒
            if (modeQueuePort != MACH_PORT_NULL && livePort == modeQueuePort) {
                break;
            }
            // Timer 时间到、RunLoop 超时
            if (currentMode->_timerFired) {
                break;
            }
    } while (1);
    复制代码

**第五步**

唤醒时通知 Observer：RunLoop 的线程刚刚被唤醒了。代码如下

    if (!poll && (currentMode->_observerMask & kCFRunLoopAfterWaiting))
        __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopAfterWaiting);
    复制代码

**第六步**

RunLoop 被唤醒后就要开始处理消息了：

*   如果是 Timer 时间到的话，就触发 Timer 的回调；
*   如果是 dispatch 的话，就执行 block；
*   如果是 source1 事件的话，就处理这个事件。

消息执行完后，就执行加到 loop 里的 block。代码如下：

    handle_msg:
    // 如果 Timer 时间到，就触发 Timer 回调
    if (msg-is-timer) {
        __CFRunLoopDoTimers(runloop, currentMode, mach_absolute_time())
    } 
    // 如果 dispatch 就执行 block
    else if (msg_is_dispatch) {
        __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
    } 
    
    // Source1 事件的话，就处理这个事件
    else {
        CFRunLoopSourceRef source1 = __CFRunLoopModeFindSourceForMachPort(runloop, currentMode, livePort);
        sourceHandledThisLoop = __CFRunLoopDoSource1(runloop, currentMode, source1, msg);
        if (sourceHandledThisLoop) {
            mach_msg(reply, MACH_SEND_MSG, reply);
        }
    }
    复制代码

**第七步**

根据当前 RunLoop 的状态来判断是否需要走下一个 loop。当被外部强制停止或 loop 超时时，就不继续下一个 loop 了，否则继续走下一个 loop 。代码如下：

    if (sourceHandledThisLoop && stopAfterHandle) {
         // 事件已处理完
        retVal = kCFRunLoopRunHandledSource;
    } else if (timeout) {
        // 超时
        retVal = kCFRunLoopRunTimedOut;
    } else if (__CFRunLoopIsStopped(runloop)) {
        // 外部调用者强制停止
        retVal = kCFRunLoopRunStopped;
    } else if (__CFRunLoopModeIsEmpty(runloop, currentMode)) {
        // mode 为空，RunLoop 结束
        retVal = kCFRunLoopRunFinished;
    }
    复制代码

全部的内部代码如下: 

    /// 用DefaultMode启动
    void CFRunLoopRun(void) {
        CFRunLoopRunSpecific(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, 1.0e10, false);
    }
     
    /// 用指定的Mode启动，允许设置RunLoop超时时间
    int CFRunLoopRunInMode(CFStringRef modeName, CFTimeInterval seconds, Boolean stopAfterHandle) {
        return CFRunLoopRunSpecific(CFRunLoopGetCurrent(), modeName, seconds, returnAfterSourceHandled);
    }
     
    /// RunLoop的实现
    int CFRunLoopRunSpecific(runloop, modeName, seconds, stopAfterHandle) {
        
        /// 首先根据modeName找到对应mode
        CFRunLoopModeRef currentMode = __CFRunLoopFindMode(runloop, modeName, false);
        /// 如果mode里没有source/timer/observer, 直接返回。
        if (__CFRunLoopModeIsEmpty(currentMode)) return;
        
        /// 1. 通知 Observers: RunLoop 即将进入 loop。
        __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopEntry);
        
        /// 内部函数，进入loop
        __CFRunLoopRun(runloop, currentMode, seconds, returnAfterSourceHandled) {
            
            Boolean sourceHandledThisLoop = NO;
            int retVal = 0;
            do {
     
                /// 2. 通知 Observers: RunLoop 即将触发 Timer 回调。
                __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeTimers);
                /// 3. 通知 Observers: RunLoop 即将触发 Source0 (非port) 回调。
                __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeSources);
                /// 执行被加入的block
                __CFRunLoopDoBlocks(runloop, currentMode);
                
                /// 4. RunLoop 触发 Source0 (非port) 回调。
                sourceHandledThisLoop = __CFRunLoopDoSources0(runloop, currentMode, stopAfterHandle);
                /// 执行被加入的block
                __CFRunLoopDoBlocks(runloop, currentMode);
     
                /// 5. 如果有 Source1 (基于port) 处于 ready 状态，直接处理这个 Source1 然后跳转去处理消息。
                if (__Source0DidDispatchPortLastTime) {
                    Boolean hasMsg = __CFRunLoopServiceMachPort(dispatchPort, &msg)
                    if (hasMsg) goto handle_msg;
                }
                
                /// 通知 Observers: RunLoop 的线程即将进入休眠(sleep)。
                if (!sourceHandledThisLoop) {
                    __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopBeforeWaiting);
                }
                
                /// 7. 调用 mach_msg 等待接受 mach_port 的消息。线程将进入休眠, 直到被下面某一个事件唤醒。
                /// • 一个基于 port 的Source 的事件。
                /// • 一个 Timer 到时间了
                /// • RunLoop 自身的超时时间到了
                /// • 被其他什么调用者手动唤醒
                __CFRunLoopServiceMachPort(waitSet, &msg, sizeof(msg_buffer), &livePort) {
                    mach_msg(msg, MACH_RCV_MSG, port); // thread wait for receive msg
                }
     
                /// 8. 通知 Observers: RunLoop 的线程刚刚被唤醒了。
                __CFRunLoopDoObservers(runloop, currentMode, kCFRunLoopAfterWaiting);
                
                /// 收到消息，处理消息。
                handle_msg:
     
                /// 9.1 如果一个 Timer 到时间了，触发这个Timer的回调。
                if (msg_is_timer) {
                    __CFRunLoopDoTimers(runloop, currentMode, mach_absolute_time())
                }
     
                /// 9.2 如果有dispatch到main_queue的block，执行block。
                else if (msg_is_dispatch) {
                    __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(msg);
                }
     
                /// 9.3 如果一个 Source1 (基于port) 发出事件了，处理这个事件
                else {
                    CFRunLoopSourceRef source1 = __CFRunLoopModeFindSourceForMachPort(runloop, currentMode, livePort);
                    sourceHandledThisLoop = __CFRunLoopDoSource1(runloop, currentMode, source1, msg);
                    if (sourceHandledThisLoop) {
                        mach_msg(reply, MACH_SEND_MSG, reply);
                    }
                }
                
                /// 执行加入到Loop的block
                __CFRunLoopDoBlocks(runloop, currentMode);
                
     
                if (sourceHandledThisLoop && stopAfterHandle) {
                    /// 进入loop时参数说处理完事件就返回。
                    retVal = kCFRunLoopRunHandledSource;
                } else if (timeout) {
                    /// 超出传入参数标记的超时时间了
                    retVal = kCFRunLoopRunTimedOut;
                } else if (__CFRunLoopIsStopped(runloop)) {
                    /// 被外部调用者强制停止了
                    retVal = kCFRunLoopRunStopped;
                } else if (__CFRunLoopModeIsEmpty(runloop, currentMode)) {
                    /// source/timer/observer一个都没有了
                    retVal = kCFRunLoopRunFinished;
                }
                
                /// 如果没超时，mode里没空，loop也没被停止，那继续loop。
            } while (retVal == 0);
        }
        
        /// 10. 通知 Observers: RunLoop 即将退出。
        __CFRunLoopDoObservers(rl, currentMode, kCFRunLoopExit);
    }
    复制代码

实际上 RunLoop 就是这样一个函数，其内部是一个 do-while 循环。当你调用 CFRunLoopRun() 时，线程就会一直停留在这个循环里；直到超时或被手动停止，该函数才会返回。

整个Runloop过程,可以总结如下一张图片

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6bf170f8d1e144c7bb30daad98af78fc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 2、如何监测卡顿

要想监听 RunLoop，你就首先需要创建一个 CFRunLoopObserverContext 观察者，代码如下：

    CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
    runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopAllActivities,YES,0,&runLoopObserverCallBack,&context);
    复制代码

将创建好的观察者 runLoopObserver 添加到主线程 RunLoop 的 common 模式下观察。然后，创建一个持续的子线程专门用来监控主线程的 RunLoop 状态。

一旦发现进入睡眠前的 kCFRunLoopBeforeSources 状态，或者唤醒后的状态 kCFRunLoopAfterWaiting，在设置的时间阈值内一直没有变化，即可判定为卡顿。接下来，我们就可以 dump 出堆栈的信息，从而进一步分析出具体是哪个方法的执行时间过长。

开启一个子线程监控的代码如下：

    //创建子线程监控
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //子线程开启一个持续的 loop 用来进行监控
        while (YES) {
            long semaphoreWait = dispatch_semaphore_wait(dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
            if (semaphoreWait != 0) {
                if (!runLoopObserver) {
                    timeoutCount = 0;
                    dispatchSemaphore = 0;
                    runLoopActivity = 0;
                    return;
                }
                //BeforeSources 和 AfterWaiting 这两个状态能够检测到是否卡顿
                if (runLoopActivity == kCFRunLoopBeforeSources || runLoopActivity == kCFRunLoopAfterWaiting) {
                    //将堆栈信息上报服务器的代码放到这里
                } //end activity
            }// end semaphore wait
            timeoutCount = 0;
        }// end while
    });
    复制代码

下面是封装的一个工具类HCCMonitor,用于卡顿监测

    #import <Foundation/Foundation.h>
    @interface HCCMonitor : NSObject
    + (instancetype)shareInstance;
    - (void)beginMonitor; //开始监视卡顿
    - (void)endMonitor;   //停止监视卡顿
    @end
    
    
    #import "HCCMonitor.h"
    #import "HCCCallStack.h"
    #import "HCCCPUMonitor.h"
    
    @interface HCCMonitor() {
        int timeoutCount;
        CFRunLoopObserverRef runLoopObserver;
        @public
        dispatch_semaphore_t dispatchSemaphore;
        CFRunLoopActivity runLoopActivity;
    }
    @property (nonatomic, strong) NSTimer *cpuMonitorTimer;
    @end
    
    @implementation HCCMonitor
    
    #pragma mark - Interface
    + (instancetype)shareInstance {
        static id instance = nil;
        static dispatch_once_t dispatchOnce;
        dispatch_once(&dispatchOnce, ^{
            instance = [[self alloc] init];
        });
        return instance;
    }
    
    - (void)beginMonitor {
        //监测 CPU 消耗
        self.cpuMonitorTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                                 target:self
                                                               selector:@selector(updateCPUInfo)
                                                               userInfo:nil
                                                                repeats:YES];
        //监测卡顿
        if (runLoopObserver) {
            return;
        }
        dispatchSemaphore = dispatch_semaphore_create(0); //Dispatch Semaphore保证同步
        //创建一个观察者
        CFRunLoopObserverContext context = {0,(__bridge void*)self,NULL,NULL};
        runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                  kCFRunLoopAllActivities,
                                                  YES,
                                                  0,
                                                  &runLoopObserverCallBack,
                                                  &context);
        //将观察者添加到主线程runloop的common模式下的观察中
        CFRunLoopAddObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
        
        //创建子线程监控
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //子线程开启一个持续的loop用来进行监控
            while (YES) {
                long semaphoreWait = dispatch_semaphore_wait(dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, 20*NSEC_PER_MSEC));
                if (semaphoreWait != 0) {
                    if (!runLoopObserver) {
                        timeoutCount = 0;
                        dispatchSemaphore = 0;
                        runLoopActivity = 0;
                        return;
                    }
                    //两个runloop的状态，BeforeSources和AfterWaiting这两个状态区间时间能够检测到是否卡顿
                    if (runLoopActivity == kCFRunLoopBeforeSources || runLoopActivity == kCFRunLoopAfterWaiting) {
                        // 将堆栈信息上报服务器的代码放到这里
                        //出现三次出结果
    //                    if (++timeoutCount < 3) {
    //                        continue;
    //                    }
                        NSLog(@"monitor trigger");
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    //                        [HCCCallStack callStackWithType:HCCCallStackTypeAll];
                        });
                    } //end activity
                }// end semaphore wait
                timeoutCount = 0;
            }// end while
        });
        
    }
    
    - (void)endMonitor {
        [self.cpuMonitorTimer invalidate];
        if (!runLoopObserver) {
            return;
        }
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), runLoopObserver, kCFRunLoopCommonModes);
        CFRelease(runLoopObserver);
        runLoopObserver = NULL;
    }
    
    #pragma mark - Private
    
    static void runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
        HCCMonitor *lagMonitor = (__bridge HCCMonitor*)info;
        lagMonitor->runLoopActivity = activity;
        
        dispatch_semaphore_t semaphore = lagMonitor->dispatchSemaphore;
        dispatch_semaphore_signal(semaphore);
    }
    
    
    - (void)updateCPUInfo {
        thread_act_array_t threads;
        mach_msg_type_number_t threadCount = 0;
        const task_t thisTask = mach_task_self();
        kern_return_t kr = task_threads(thisTask, &threads, &threadCount);
        if (kr != KERN_SUCCESS) {
            return;
        }
        for (int i = 0; i < threadCount; i++) {
            thread_info_data_t threadInfo;
            thread_basic_info_t threadBaseInfo;
            mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
            if (thread_info((thread_act_t)threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
                threadBaseInfo = (thread_basic_info_t)threadInfo;
                if (!(threadBaseInfo->flags & TH_FLAGS_IDLE)) {
                    integer_t cpuUsage = threadBaseInfo->cpu_usage / 10;
                    if (cpuUsage > 70) {
                        //cup 消耗大于 70 时打印和记录堆栈
                        NSString *reStr = HCCStackOfThread(threads[i]);
                        //记录数据库中
    //                    [[[HCCDB shareInstance] increaseWithStackString:reStr] subscribeNext:^(id x) {}];
                        NSLog(@"CPU useage overload thread stack：\n%@",reStr);
                    }
                }
            }
        }
    }
    
    @end
    复制代码

四、性能优化
------

当tableview的cell有多个ImageView，并且是大图的话，会不会在滑动的时候导致卡顿，答案是显然意见的。

通过上面讲述Runloop的原理，我们可以使用Runloop每次循环添加一张图片。

    /*
     为什么要优化：
        Runloop会在一次循环中绘制屏幕上所有的点，如果加载的图片过大，过多，就会造成需要绘制很多的
    的点，导致一次循环的时间过长，从而导致UI卡顿。
     */
    复制代码

### 监听Runloop

    //添加runloop监听者
    - (void)addRunloopObserver{
        
        //    获取 当前的Runloop ref - 指针
        CFRunLoopRef current =  CFRunLoopGetCurrent();
        
        //定义一个RunloopObserver
        CFRunLoopObserverRef defaultModeObserver;
        
        //上下文
        /*
         typedef struct {
            CFIndex version; //版本号 long
            void * info;    //这里我们要填写对象（self或者传进来的对象）
            const void *(*retain)(const void *info);        //填写&CFRetain
            void (*release)(const void *info);           //填写&CGFRelease
            CFStringRef (*copyDescription)(const void *info); //NULL
         } CFRunLoopObserverContext;
         */
        CFRunLoopObserverContext context = {
            0,
            (__bridge void *)(self),
            &CFRetain,
            &CFRelease,
            NULL
        };
        
        /*
         1 NULL空指针 nil空对象 这里填写NULL
         2 模式
            kCFRunLoopEntry = (1UL << 0),
            kCFRunLoopBeforeTimers = (1UL << 1),
            kCFRunLoopBeforeSources = (1UL << 2),
            kCFRunLoopBeforeWaiting = (1UL << 5),
            kCFRunLoopAfterWaiting = (1UL << 6),
            kCFRunLoopExit = (1UL << 7),
            kCFRunLoopAllActivities = 0x0FFFFFFFU
         3 是否重复 - YES
         4 nil 或者 NSIntegerMax - 999
         5 回调
         6 上下文
         */
        //    创建观察者
        defaultModeObserver = CFRunLoopObserverCreate(NULL,
                                                      kCFRunLoopBeforeWaiting, YES,
                                                      NSIntegerMax - 999,
                                                      &Callback,
                                                      &context);
        
        //添加当前runloop的观察着
        CFRunLoopAddObserver(current, defaultModeObserver, kCFRunLoopDefaultMode);
        
        //释放
        CFRelease(defaultModeObserver);
    }
    
    @end
    复制代码

### 回调方法

    static void Callback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
        
        //通过info桥接为当前的对象
        ZXYRunloop * runloop = (__bridge ZXYunloop *)info;
        
        //如果没有任务，就直接返回
        if (runloop.tasks.count == 0) {
            return;
        }
        
        BOOL result = NO;
        while (result == NO && runloop.tasks.count) {
            
            //取出任务
            RunloopBlock unit = runloop.tasks.firstObject;
            
            //执行任务
            result = unit();
            
            //删除任务
            [runloop.tasks removeObjectAtIndex:0];
        }
    }
    复制代码

通过上面的两个方法我们可以做到监听Runloop循环，以及每次循环需要处理的事情，这个时候我们只需要对外提供一个添加任务的方法，用数组保存起来。

    //add task 添加任务
    - (void)addTask:(RunloopBlock)unit withId:(id)key{
        //添加任务到数组
        [self.tasks addObject:unit];
        [self.taskKeys addObject:key];
        
        //为了保证加载到图片最大数是20所以要删除
        if (self.tasks.count > self.maxQueue) {
            [self.tasks removeObjectAtIndex:0];
            [self.taskKeys removeObjectAtIndex:0];
        }
    复制代码

在ZXYRunloop初始化方法设置初始化对象和基本信息

    - (instancetype)init{
        self = [super init];
        if (self) {
            //初始化对象／基本信息
            self.maxQueue = 20;
            self.tasks = [NSMutableArray array];
            self.taskKeys = [NSMutableArray array];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001 repeats:YES block:^(NSTimer * _Nonnull timer) { }];
            //添加Runloop观察者
            [self addRunloopObserver];
        }
        return self;
    }
    复制代码

在TableViewCell中使用：

    [[ZXYRunloop shareInstance] addTask:^BOOL{
            [ViewController addCenterImg:cell];
            return YES;
        } withId:indexPath];
    复制代码

总结一下思想

1.  加载图片的代码保存起来，不要直接执行，用一个数组保存 block 
2.  监听我们的Runloop循环 CFRunloop CFRunloopObserver 
3.  每次Runloop循环就让它从数组里面去一个加载图片等任务出来执行 

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