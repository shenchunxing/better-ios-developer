# Runloop
 ### runloop和线程有什么关系？

总的说来，Run loop，正如其名，loop表示某种循环，和run放在一起就表示一直在运行着的循环。实际上，run loop和线程是紧密相连的，可以这样说run loop是为了线程而生，没有线程，它就没有存在的必要。Run loops是线程的基础架构部分， Cocoa 和 CoreFundation 都提供了 run loop 对象方便配置和管理线程的 run loop （以下都以 Cocoa 为例）。每个线程，包括程序的主线程（ main thread ）都有与之相应的 run loop 对象。

 runloop 和线程的关系：
 1. 主线程的run loop默认是启动的。
 iOS的应用程序里面，程序启动后会有一个如下的main()函数
 ```Objective-C
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```
 重点是UIApplicationMain()函数，这个方法会为main thread设置一个NSRunLoop对象，这就解释了：为什么我们的应用可以在无人操作的时候休息，需要让它干活的时候又能立马响应。
 
 2. 对其它线程来说，run loop默认是没有启动的，如果你需要更多的线程交互则可以手动配置和启动，如果线程只是去执行一个长时间的已确定的任务则不需要。

 3. 在任何一个 Cocoa 程序的线程中，都可以通过以下代码来获取到当前线程的 run loop 。
 ```Objective-C
NSRunLoop *runloop = [NSRunLoop currentRunLoop];
```
参考链接：[《Objective-C之run loop详解》](http://blog.csdn.net/wzzvictory/article/details/9237973)。

### Runloop的结构
Core Foundation中关于RunLoop的5个类
-   `CFRunLoopRef`
-   `CFRunLoopModeRef`
-   `CFRunLoopSourceRef`
-   `CFRunLoopTimerRef`
-   `CFRunLoopObserverRef`

下图是这几种类的关系

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ab1a948478d440b092d0634f9c9fcfc2~tplv-k3u1fbpfcp-watermark.image?)

#### CFRunLoopModeRef`
-   CFRunLoopModeRef代表RunLoop的运行模式
-   一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer
-   RunLoop启动时只能选择其中一个Mode，作为currentMode
-   如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入
    -   为什么要先退出再进入
    -   不同组的Source0/Source1/Timer/Observer能分隔开来，互不影响
-   如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出

#### CFRunLoopModeRef
常见的2种Mode
-   `kCFRunLoopDefaultMode（NSDefaultRunLoopMode）`：App的默认Mode，通常主线程是在这个Mode下运行
-   `UITrackingRunLoopMode`：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响
-   `kCFRunLoopCommonModes`kCFRunLoopCommonModes默认包括kCFRunLoopDefaultMode、UITrackingRunLoopMode
> `NSDefaultRunLoopMode`、`UITrackingRunLoopMode`才是真正存在的模式  
> `NSRunLoopCommonModes`并不是一个真的模式，它只是一个标记

### runloop的mode作用是什么？
model 主要是用来指定事件在运行循环中的优先级的，分为：
* NSDefaultRunLoopMode（kCFRunLoopDefaultMode）：默认，空闲状态
* UITrackingRunLoopMode：ScrollView滑动时
* UIInitializationRunLoopMode：启动时
* NSRunLoopCommonModes（kCFRunLoopCommonModes）：Mode集合

苹果公开提供的 Mode 有两个：
 1. NSDefaultRunLoopMode（kCFRunLoopDefaultMode）
 2. NSRunLoopCommonModes（kCFRunLoopCommonModes）

讨论区： [《https://github.com/ChenYilong/iOSInterviewQuestions/issues/36》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/36 )

### Runloop休眠的实现原理?
 休眠:mach_msg()这个函数从用户态转入内核态
 唤醒:mach_msg()这个函数从内核态转入用户态
 
 等待消息
 没有消息就让线程休眠
 有消息就唤醒线程

### 以+ scheduledTimerWithTimeInterval...的方式触发的timer，在滑动页面上的列表时，timer会暂定回调，为什么？如何解决？

RunLoop只能运行在一种mode下，如果要换mode，当前的loop也需要停下重启成新的。利用这个机制，ScrollView滚动过程中NSDefaultRunLoopMode（kCFRunLoopDefaultMode）的mode会切换到UITrackingRunLoopMode来保证ScrollView的流畅滑动：只能在NSDefaultRunLoopMode模式下处理的事件会影响ScrollView的滑动。

如果我们把一个NSTimer对象以NSDefaultRunLoopMode（kCFRunLoopDefaultMode）添加到主运行循环中的时候,
ScrollView滚动过程中会因为mode的切换，而导致NSTimer将不再被调度。

同时因为mode还是可定制的，所以：

 Timer计时会被scrollView的滑动影响的问题可以通过将timer添加到NSRunLoopCommonModes（kCFRunLoopCommonModes）来解决。代码如下：

```objective-c
//将timer添加到NSDefaultRunLoopMode中
[NSTimer scheduledTimerWithTimeInterval:1.0
     target:self
     selector:@selector(timerTick:)
     userInfo:nil
     repeats:YES];
//然后再添加到NSRunLoopCommonModes里
NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
     target:self
     selector:@selector(timerTick:)
     userInfo:nil
     repeats:YES];
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
```
如果对本回答有疑问，欢迎参与讨论：  [《第30题，使用dispatch source替换NSTimer #45》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/45 ) 

### runloop内部是如何实现的？
> 一般来讲，一个线程一次只能执行一个任务，执行完成后线程就会退出。如果我们需要一个机制，让线程能随时处理事件但并不退出，通常的代码逻辑
是这样的：

    function loop() {
        initialize();
        do {
            var message = get_next_message();
            process_message(message);
        } while (message != quit);
    }


或使用伪代码来展示下:

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

参考链接：

 1. [《深入理解RunLoop》](http://blog.ibireme.com/2015/05/18/runloop/#base)
 2. 摘自博文[***CFRunLoop***](https://github.com/ming1016/study/wiki/CFRunLoop)，原作者是[微博@我就叫Sunny怎么了](http://weibo.com/u/1364395395)

### 关于runloop的几点说明

1.3.1 Cocoa中的NSRunLoop类并不是线程安全的

我们不能再一个线程中去操作另外一个线程的run loop对象，那很可能会造成意想不到的后果。不过幸运的是CoreFundation中的不透明类CFRunLoopRef是线程安全的，而且两种类型的run loop完全可以混合使用。Cocoa中的NSRunLoop类可以通过实例方法：
- (CFRunLoopRef)getCFRunLoop;
获取对应的CFRunLoopRef类，来达到线程安全的目的。

1.3.2 Run loop的管理并不完全是自动的。

我们仍必须设计线程代码以在适当的时候启动run loop并正确响应输入事件，当然前提是线程中需要用到run loop。而且，我们还需要使用while/for语句来驱动run loop能够循环运行，下面的代码就成功驱动了一个run loop：
 ```Objective-C
     BOOL isRunning = NO;
      do {
            isRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopModebeforeDate:[NSDatedistantFuture]];
     } while (isRunning);
 ```
 
1.3.3 Run loop同时也负责autorelease pool的创建和释放

在使用手动的内存管理方式的项目中，会经常用到很多自动释放的对象，如果这些对象不能够被即时释放掉，会造成内存占用量急剧增大。Run loop就为我们做了这样的工作，每当一个运行循环结束的时候，它都会释放一次autorelease pool，同时pool中的所有自动释放类型变量都会被释放掉。

1.3.4 Run loop的优点

一个run loop就是一个事件处理循环，用来不停的监听和处理输入事件并将其分配到对应的目标上进行处理。如果仅仅是想实现这个功能，你可能会想一个简单的while循环不就可以实现了吗，用得着费老大劲来做个那么复杂的机制？显然，苹果的架构设计师不是吃干饭的，你想到的他们早就想过了。

首先，NSRunLoop是一种更加高明的消息处理模式，他就高明在对消息处理过程进行了更好的抽象和封装，这样才能是的你不用处理一些很琐碎很低层次的具体消息的处理，在NSRunLoop中每一个消息就被打包在input source或者是timer source（见后文）中了。

其次，也是很重要的一点，使用run loop可以使你的线程在有工作的时候工作，没有工作的时候休眠，这可以大大节省系统资源。

 ### Runloop的运行逻辑
 
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7d66006d1dec40ee85be15d1830ca132~tplv-k3u1fbpfcp-watermark.image?)
-   `Source0`
    -   触摸事件处理
    -   performSelector:onThread:
-   `Source1`
    -   基于Port的线程间通信
    -   系统事件捕捉
-   `Timers`
    -   NSTimer
    -   performSelector:withObject:afterDelay:
-   `Observers`
    -   用于监听RunLoop的状态
    -   UI刷新（BeforeWaiting）
    -   Autorelease pool（BeforeWaiting）
    
```
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 函数调用栈
    NSLog(@"111111");
}
```
打印结果：

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/97373409d55d40d18ec7978e899db261~tplv-k3u1fbpfcp-watermark.image?)
```
// UI刷新
self.view.backgroundColor = [UIColor redColor];
UI刷新也是runloop即将进入休眠时才去刷新
```

二、Run loop相关知识点

2.1输入事件来源

Run loop接收输入事件来自两种不同的来源：输入源（input source）和定时源（timer source）。两种源都使用程序的某一特定的处理例程来处理到达的事件。图-1显示了run loop的概念结构以及各种源。


需要说明的是，当你创建输入源，你需要将其分配给run loop中的一个或多个模式（什么是模式，下文将会讲到）。模式只会在特定事件影响监听的源。大多数情况下，run loop运行在默认模式下，但是你也可以使其运行在自定义模式。若某一源在当前模式下不被监听，那么任何其生成的消息只在run loop运行在其关联的模式下才会被传递。


### 输入源

传递异步事件，通常消息来自于其他线程或程序。输入源传递异步消息给相应的处理例程，并调用runUntilDate:方法来退出(在线程里面相关的NSRunLoop对象调用)。

#### 2.1.1.1基于端口的输入源

基于端口的输入源由内核自动发送。

Cocoa和Core Foundation内置支持使用端口相关的对象和函数来创建的基于端口的源。例如，在Cocoa里面你从来不需要直接创建输入源。你只要简单的创建端口对象，并使用NSPort的方法把该端口添加到run loop。端口对象会自己处理创建和配置输入源。

在Core Foundation，你必须人工创建端口和它的run loop源。我们可以使用端口相关的函数（CFMachPortRef，CFMessagePortRef，CFSocketRef）来创建合适的对象。下面的例子展示了如何创建一个基于端口的输入源，将其添加到run loop并启动：

 ```Objective-C
void createPortSource() {
    CFMessagePortRef port = CFMessagePortCreateLocal(kCFAllocatorDefault,CFSTR("com.someport"),myCallbackFunc, NULL,NULL);
    CFRunLoopSourceRef source = CFMessagePortCreateRunLoopSource(kCFAllocatorDefault, port,0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source,kCFRunLoopCommonModes);
    while (pageStillLoading) {
        NSAutoreleasePool *pool = [[NSAutoreleasePoolalloc] init];
        CFRunLoopRun();
        [pool release];
    }
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source,kCFRunLoopDefaultMode);
    CFRelease(source);
}
 ```
#### 2.1.1.2自定义输入源

自定义的输入源需要人工从其他线程发送。为了创建自定义输入源，必须使用Core Foundation里面的CFRunLoopSourceRef类型相关的函数来创建。你可以使用回调函数来配置自定义输入源。Core Fundation会在配置源的不同地方调用回调函数，处理输入事件，在源从run loop移除的时候清理它。

除了定义在事件到达时自定义输入源的行为，你也必须定义消息传递机制。源的这部分运行在单独的线程里面，并负责在数据等待处理的时候传递数据给源并通知它处理数据。消息传递机制的定义取决于你，但最好不要过于复杂。创建并启动自定义输入源的示例如下：

 ```Objective-C
void createCustomSource() {
    CFRunLoopSourceContext context = {0,NULL, NULL,NULL, NULL,NULL, NULL,NULL, NULL,NULL};
    CFRunLoopSourceRef source =CFRunLoopSourceCreate(kCFAllocatorDefault,0, &context);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source,kCFRunLoopDefaultMode);
    while (pageStillLoading) {
        NSAutoreleasePool *pool = [[NSAutoreleasePoolalloc] init];
        CFRunLoopRun();
        [pool release];
    }
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source,kCFRunLoopDefaultMode);
    CFRelease(source);
}
 ```
 
#### 2.1.1.3Cocoa上的Selector源

除了基于端口的源，Cocoa定义了自定义输入源，允许你在任何线程执行selector方法。和基于端口的源一样，执行selector请求会在目标线程上序列化，减缓许多在线程上允许多个方法容易引起的同步问题。不像基于端口的源，一个selector执行完后会自动从run loop里面移除。

当在其他线程上面执行selector时，目标线程须有一个活动的run loop。对于你创建的线程，这意味着线程在你显式的启动run loop之前是不会执行selector方法的，而是一直处于休眠状态。

NSObject类提供了类似如下的selector方法：
 ```Objective-C
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)argwaitUntilDone:(BOOL)wait modes:(NSArray *)array;
 ```
#### 定时源
定时源在预设的时间点同步方式传递消息，这些消息都会发生在特定时间或者重复的时间间隔。定时源则直接传递消息给处理例程，不会立即退出run loop。

需要注意的是，尽管定时器可以产生基于时间的通知，但它并不是实时机制。和输入源一样，定时器也和你的run loop的特定模式相关。如果定时器所在的模式当前未被run loop监视，那么定时器将不会开始直到run loop运行在相应的模式下。类似的，如果定时器在run loop处理某一事件期间开始，定时器会一直等待直到下次run loop开始相应的处理程序。如果run loop不再运行，那定时器也将永远不启动。

创建定时器源有两种方法，

方法一：
 ```Objective-C
NSTimer *timer = [NSTimer timerWithTimeInterval:4.0 target:self selector:@selector(backgroundThreadFire:) userInfo:nil repeats:YES];
[[NSRunLoop currentRunLoop] addTimer:timerforMode:NSDefaultRunLoopMode];
  ```

方法二：
 ```Objective-C
[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(backgroundThreadFire:) userInfo:nil repeats:YES];
  ```

#### 观察者
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4cbfc1c08e2f4efb9e38de0185e06924~tplv-k3u1fbpfcp-watermark.image?)
源是在合适的同步或异步事件发生时触发，而run loop观察者则是在run loop本身运行的特定时候触发。你可以使用run loop观察者来为处理某一特定事件或是进入休眠的线程做准备。你可以将run loop观察者和以下事件关联：
1.  Runloop入口
2.  Runloop何时处理一个定时器
3.  Runloop何时处理一个输入源
4.  Runloop何时进入睡眠状态
5.  Runloop何时被唤醒，但在唤醒之前要处理的事件
6.  Runloop终止
和定时器类似，在创建的时候你可以指定run loop观察者可以只用一次或循环使用。若只用一次，那么在它启动后，会把它自己从run loop里面移除，而循环的观察者则不会。定义观察者并把它添加到run loop，只能使用Core Fundation。下面的例子演示了如何创建run loop的观察者：

 ```Objective-C
- (void)addObserverToCurrentRunloop {
    // The application uses garbage collection, so noautorelease pool is needed.
    NSRunLoop*myRunLoop = [NSRunLoop currentRunLoop];
    // Create a run loop observer and attach it to the runloop.
    CFRunLoopObserverContext  context = {0,self, NULL,NULL, NULL};
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopBeforeTimers,YES, 0, &myRunLoopObserver, &context);
    if (observer) {
        CFRunLoopRef cfLoop = [myRunLoopgetCFRunLoop];
       CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopDefaultMode);
    }
}
 ```
其中，kCFRunLoopBeforeTimers表示选择监听定时器触发前处理事件，后面的YES表示循环监听。

### RunLoop的事件队列
每次运行run loop，你线程的run loop对会自动处理之前未处理的消息，并通知相关的观察者。具体的顺序如下：
```
01、通知Observers：进入Loop
02、通知Observers：即将处理Timers
03、通知Observers：即将处理Sources
04、处理Blocks
05、处理Source0（可能会再次处理Blocks）
06、如果存在Source1，就跳转到第8步
07、通知Observers：开始休眠（等待消息唤醒）
08、通知Observers：结束休眠（被某个消息唤醒）
   01> 处理Timer
   02> 处理GCD Async To Main Queue
   03> 处理Source1
09、处理Blocks
10、根据前面的执行结果，决定如何操作
   01> 回到第02步
   02> 退出Loop
11、通知Observers：退出Loop
```
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8f262705b9e4487683c12139296970c6~tplv-k3u1fbpfcp-watermark.image?)


因为定时器和输入源的观察者是在相应的事件发生之前传递消息，所以通知的时间和实际事件发生的时间之间可能存在误差。如果需要精确时间控制，你可以使用休眠和唤醒通知来帮助你校对实际发生事件的时间。

因为当你运行run loop时定时器和其它周期性事件经常需要被传递，撤销run loop也会终止消息传递。典型的例子就是鼠标路径追踪。因为你的代码直接获取到消息而不是经由程序传递，因此活跃的定时器不会开始直到鼠标追踪结束并将控制权交给程序。

Run loop可以由run loop对象显式唤醒。其它消息也可以唤醒run loop。例如，添加新的非基于端口的源会唤醒run loop从而可以立即处理输入源而不需要等待其他事件发生后再处理。

从这个事件队列中可以看出：

①如果是事件到达，消息会被传递给相应的处理程序来处理， runloop处理完当次事件后，run loop会退出，而不管之前预定的时间到了没有。你可以重新启动run loop来等待下一事件。

②如果线程中有需要处理的源，但是响应的事件没有到来的时候，线程就会休眠等待相应事件的发生。这就是为什么run loop可以做到让线程有工作的时候忙于工作，而没工作的时候处于休眠状态。

### 添加Observer监听RunLoop的所有状态
```
// 监听runloop状态的变化
void observeRunLoopActicities(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"kCFRunLoopEntry");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"kCFRunLoopBeforeTimers");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"kCFRunLoopBeforeSources");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"kCFRunLoopBeforeWaiting");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"kCFRunLoopAfterWaiting");
            break;
        case kCFRunLoopExit:
            NSLog(@"kCFRunLoopExit");
            break;
        default:
            break;
    }
}

// 监听runloop
- (void)observeRunloop {
    // kCFRunLoopCommonModes默认包括kCFRunLoopDefaultMode、UITrackingRunLoopMode
    // 创建Observer
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, observeRunLoopActicities, NULL);
    // 添加Observer到RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    // 释放
    CFRelease(observer);
}

// 验证触摸事件为source0
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"开始触摸操作");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"开始定时器操作");
    });
}
```
运行结果：

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/62a0d403dadb4fbcb60c45ee8c21b8e6~tplv-k3u1fbpfcp-watermark.image?)
 
### 监听runloop mode切换
```
//拖拽一个textView至界面中，并滚动和停止滚动
- (void)observeRunloopModeChagne {
    // 创建Observer
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry: {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopEntry - %@", mode);
                CFRelease(mode);
                break;
            }
                
            case kCFRunLoopExit: {
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopExit - %@", mode);
                CFRelease(mode);
                break;
            }
                
            default:
                break;
        }
    });
    // 添加Observer到RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    // 释放
    CFRelease(observer);
}
```

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/84aa3c51d4ff45d5b1637a1cf627627f~tplv-k3u1fbpfcp-watermark.image?)

### 什么时候使用runloop

仅当在为你的程序创建辅助线程的时候，你才需要显式运行一个run loop。Run loop是程序主线程基础设施的关键部分。所以，Cocoa和Carbon程序提供了代码运行主程序的循环并自动启动run loop。IOS程序中UIApplication的run方法（或Mac OS X中的NSApplication）作为程序启动步骤的一部分，它在程序正常启动的时候就会启动程序的主循环。类似的，RunApplicationEventLoop函数为Carbon程序启动主循环。如果你使用xcode提供的模板创建你的程序，那你永远不需要自己去显式的调用这些例程。

对于辅助线程，你需要判断一个run loop是否是必须的。如果是必须的，那么你要自己配置并启动它。你不需要在任何情况下都去启动一个线程的run loop。比如，你使用线程来处理一个预先定义的长时间运行的任务时，你应该避免启动run loop。Run loop在你要和线程有更多的交互时才需要，比如以下情况：

使用端口或自定义输入源来和其他线程通信
使用线程的定时器
Cocoa中使用任何performSelector…的方法
使线程周期性工作
如果你决定在程序中使用run loop，那么它的配置和启动都很简单。和所有线程编程一样，你需要计划好在辅助线程退出线程的情形。让线程自然退出往往比强制关闭它更好。

  -------- by wangzz

参考文档：

http://developer.apple.com/library/ios/#documentation/cocoa/Conceptual/Multithreading/Introduction/Introduction.html#//apple_ref/doc/uid/10000057i

### Runloop的实际应用
-   控制线程生命周期（线程保活）
-   解决NSTimer在滑动时停止工作的问题
-   监控应用卡顿
-   性能优化

##### 一 解决NSTimer在滑动时停止工作的问题
-   在拖拽时定时器不工作
```
__block int count = 0;
// 默认添加到default模式
[NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
    NSLog(@"%d", ++count);
}];
```
打印结果
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/78bdfbe4a0ad46fa95f1dcbc13e38a0b~tplv-k3u1fbpfcp-watermark.image?)

-   在拖拽时人仍然正常工作
```
static int count = 0;
// 2.添加到指定模式下
NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
    NSLog(@"%d", ++count);
}];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
//    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
// NSDefaultRunLoopMode、UITrackingRunLoopMode才是真正存在的模式
// NSRunLoopCommonModes并不是一个真的模式，它只是一个标记
// timer能在_commonModes数组中存放的模式下工作
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
```
##### 二 线程保活
我们先封装一个长久活命的线程
-   `PermanentThread.h`
```
// 声明一个block - 用于执行任务
typedef void(^PermanentThreadTask)(void);
/** 线程保活 */
@interface PermanentThread : NSObject
// 在当前线程执行一个任务
- (void)executeTask:(PermanentThreadTask)task;
// 结束线程
- (void)stop;
@end
```
-   `PermanentThread.m`

**

```
/** CSThread **/
@interface CSThread : NSThread
@end
@implementation CSThread
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end

@interface PermanentThread()
/** 线程*/
@property(nonatomic,strong)CSThread *thread;
/** 是否停止*/
@property(nonatomic,assign, getter=isStopped)BOOL stopped;
@end
@implementation PermanentThread
// 初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        self.stopped = NO;
        // 初始化线程
        __weak typeof(self) weakSelf = self;
        self.thread = [[CSThread alloc] initWithBlock:^{
            // runloop只有添加事件才会执行
            [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc]init] forMode:NSDefaultRunLoopMode];
            
            // 当当前对象存在并且变量为false的时候,才一直执行
            while (weakSelf && !weakSelf.isStopped) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }];
        // 开启线程
        [self.thread start];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self stop];
}

// 执行任务
- (void)executeTask:(PermanentThreadTask)task {
    // 如果线程释放或者无任务,则退出
    if (!self.thread || !task) {
        return;
    }
    // 开始执行任务
    [self performSelector:@selector(innerExecuteTask:) onThread:self.thread withObject:task waitUntilDone:NO];
}

// 停止
- (void)stop {
    if (!self.thread) {
        return;
    }
    [self performSelector:@selector(innerStop) onThread:self.thread withObject:nil waitUntilDone:YES];
}

// 执行任务
- (void)innerExecuteTask:(PermanentThreadTask)task {
    task();
}

// 停止线程 runloop
- (void)innerStop {
    self.stopped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.thread = nil;
}
@end
```

外部调用:
```
- (void)viewDidLoad {
    [super viewDidLoad];
    // 2.线程保活
    self.thread = [[PermanentThread alloc] init];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.thread executeTask:^{
        NSLog(@"执行任务 - %@", [NSThread currentThread]);
    }];
}

- (void)stopBtnClick {
    [self.thread stop];
}
```
运行结果:
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/61d4d5b7a2044b729964e7b09b52ae44~tplv-k3u1fbpfcp-watermark.image?)