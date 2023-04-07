//
//  ViewController.m
//  Interview03-RunLoop
//
//  Created by MJ Lee on 2018/5/31.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

// MARK: -  讲讲 RunLoop，项目中有用到吗？
/*
 运行循环
 在程序运行过程中循环做一些事情

 应用范畴
 定时器（Timer）、PerformSelector
 GCD Async Main Queue
 事件响应、手势识别、界面刷新
 网络请求
 AutoreleasePool
 
 实际开发中用到的Runloop:
 控制线程生命周期（线程保活）
 解决NSTimer在滑动时停止工作的问题
 监控应用卡顿
 性能优化


 */

// MARK: - runloop内部实现逻辑？(runloop 是怎么响应用户操作的， 具体流程是什么样的？
/*
 
 Source0
 触摸事件处理，touchBegin
 performSelector:onThread:
 
 Source1
 基于Port的线程间通信
 系统事件捕捉，捕捉好后，还是交给Source0去处理
 
 Timers
 NSTimer
 performSelector:withObject:afterDelay:
 
 Observers
 用于监听RunLoop的状态
 UI刷新（BeforeWaiting）
 Autorelease pool（BeforeWaiting）

 
 01、通知Observers：进入Loop
 02、通知Observers：即将处理Timers
 03、通知Observers：即将处理Sources
 04、处理Blocks
 05、处理Source0（可能会再次处理Blocks）
 06、如果存在Source1，就跳转到第8步
 07、通知Observers：开始休眠（等待消息唤醒）
 08、通知Observers：结束休眠（被某个消息唤醒，是谁唤醒就处理谁）
     01> 处理Timer
     02> 处理GCD Async To Main Queue
     03> 处理Source1
 09、处理Blocks
 10、根据前面的执行结果，决定如何操作
 01> 回到第02步
 02> 退出Loop
 11、通知Observers：退出Loop


 */

// MARK: - runloop和线程的关系？
/*
 每条线程都有唯一的一个与之对应的RunLoop对象
 RunLoop保存在一个全局的Dictionary里，线程作为key，RunLoop作为value
 线程刚创建时并没有RunLoop对象，RunLoop会在第一次获取它时创建
 RunLoop会在线程结束时销毁
 主线程的RunLoop已经自动获取（创建），子线程默认没有开启RunLoop

 */

// MARK: - timer 与 runloop 的关系？
/*
 NSTimer依赖于RunLoop，如果RunLoop的任务过于繁重，可能会导致NSTimer不准时
 而GCD的定时器会更加准时
 */

// MARK: - 程序中添加每3秒响应一次的NSTimer，当拖动tableview时timer可能无法响应要怎么解决？
/*
   修改mode,改成UITrackingRunLoopMode
 */


// MARK: - 说说runLoop的几种状态
/*

 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
 kCFRunLoopEntry = (1UL << 0),//即将进入runloop
 kCFRunLoopBeforeTimers = (1UL << 1),//即将处理Timer
 kCFRunLoopBeforeSources = (1UL << 2),//即将处理Sources
 kCFRunLoopBeforeWaiting = (1UL << 5),//即将进入休眠
 kCFRunLoopAfterWaiting = (1UL << 6),//刚从休眠中唤醒
 kCFRunLoopExit = (1UL << 7),//即将退出runloop
 kCFRunLoopAllActivities = 0x0FFFFFFFU
 };
 */

// MARK: - runloop的mode作用是什么？
/*

 CFRunLoopModeRef代表RunLoop的运行模式
 一个RunLoop包含若干个Mode，每个Mode又包含若干个Source0/Source1/Timer/Observer
 RunLoop启动时只能选择其中一个Mode，作为currentMode
 如果需要切换Mode，只能退出当前Loop，再重新选择一个Mode进入
 不同组的Source0/Source1/Timer/Observer能分隔开来，互不影响
 如果Mode里没有任何Source0/Source1/Timer/Observer，RunLoop会立马退出

 常见的2种Mode
 kCFRunLoopDefaultMode（NSDefaultRunLoopMode）：App的默认Mode，通常主线程是在这个Mode下运行
 UITrackingRunLoopMode：界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响

 */

// MARK: - Runloop休眠的实现原理?
/*
 休眠:mach_msg()这个函数从用户态转入内核态
 唤醒:mach_msg()这个函数从内核态转入用户态
 
 等待消息
 没有消息就让线程休眠
 有消息就唤醒线程

 */

// MARK: - NStimer准吗？谈谈你的看法？如果不准该怎样实现一个精确的NSTimer?
/*
 原因:
 1、NSTimer加在main runloop中，模式是NSDefaultRunLoopMode，main负责所有主线程事件，例如UI界面的操作，复杂的运算，这样在同一个runloop中timer就会产生阻塞。
 
 2、模式的改变。主线程的 RunLoop 里有两个预置的 Mode：kCFRunLoopDefaultMode 和 UITrackingRunLoopMode。
 
 当你创建一个 Timer 并加到 DefaultMode 时，Timer 会得到重复回调，但此时滑动一个ScrollView时，RunLoop 会将 mode 切换为 TrackingRunLoopMode，这时 Timer 就不会被回调，并且也不会影响到滑动操作。所以就会影响到NSTimer不准的情况。
 
 PS:DefaultMode 是 App 平时所处的状态，rackingRunLoopMode 是追踪 ScrollView 滑动时的状态。
 
 
 解决方法:
 1、在主线程中进行NSTimer操作，但是将NSTimer实例加到main runloop的特定mode（模式）中。避免被复杂运算操作或者UI界面刷新所干扰。
 self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(showTime) userInfo:nil repeats:YES];
 [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
 
 2、在子线程中进行NSTimer的操作，再在主线程中修改UI界面显示操作结果；
 - (void)timerMethod2 {
 NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(newThread) object:nil];
 [thread start];
 }
 - (void)newThread
 {
    @autoreleasepool{
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] run];
    }
 }
 总结：
 一开始的时候系统就为我们将主线程的main runloop隐式的启动了。
 在创建线程的时候，可以主动获取当前线程的runloop。每个子线程对应一个runloop
 
 3.直接使用GCD替代！
  [self gcdtimer]
 
 */


//- (void)gcdtimer
//{  //创建一个定时器
//    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, <#dispatchQueue#>);
//    //设置时间间隔
//    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, <#intervalInSeconds#> * NSEC_PER_SEC, <#leewayInSeconds#> * NSEC_PER_SEC);
//    //设置回调
//    dispatch_source_set_event_handler(timer, ^{
//        <#code to be executed when timer fires#>
//    });
//    //启动定时器
//    dispatch_resume(timer);
//}


//MARK:runloop数据结构？
/**
 CFRunLoop：RunLoop对象
 CFRunLoopMode：运行模式
 CFRunLoopSource：输入源/事件源
 CFRunLoopTimer：定时源
  CFRunLoopObserver：观察者
 */

//MARK:runloop状态
/**
 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
        kCFRunLoopEntry         = (1UL << 0), // 即将进入Loop
        kCFRunLoopBeforeTimers  = (1UL << 1), // 即将处理 Timer
        kCFRunLoopBeforeSources = (1UL << 2), // 即将处理 Source
        kCFRunLoopBeforeWaiting = (1UL << 5), // 即将进入休眠
        kCFRunLoopAfterWaiting  = (1UL << 6), // 刚从休眠中唤醒
        kCFRunLoopExit          = (1UL << 7), // 即将退出Loop
    };
 */

//MARK:NSTimer、CADisplayLink原理？
/**
 NSTimer 其实就是 CFRunLoopTimerRef.一个 NSTimer 注册到 RunLoop 后，RunLoop 会为其重复的时间点注册好事件
     CADisplayLink 是一个和屏幕刷新率一致的定时器（但实际实现原理更复杂，和 NSTimer 并不一样，其内部实际是操作了一个 Source）。如果在两次屏幕刷新之间执行了一个长任务，那其中就会有一帧被跳过去（和 NSTimer 相似），造成界面卡顿的感觉。
 */

//MARK:线程保活
/**
 runloop 线程保活前提就是有事情要处理，这里指 timer，source0，source1 事件
 
 //timer方式
 NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
    NSLog(@"timer 定时任务");
 }];
 NSRunLoop *runloop = [NSRunLoop currentRunLoop];
 [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
 [runloop run];
 
 //port方式
 NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
 [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
 [runLoop run];

 */

//MARK:RunLoop的作用是什么？它的内部工作机制了解么？
/**
 字面意思是“消息循环、运行循环”，runloop内部实际上就是一个do-while循环，它在循环监听着各种事件源、消息，对他们进行管理并分发给线程来执行。
         1.通知观察者将要进入运行循环。
             线程和 RunLoop 之间是一一对应的
         2.通知观察者将要处理计时器。
         3.通知观察者任何非基于端口的输入源即将触发。
         4.触发任何准备触发的基于非端口的输入源。
         5.如果基于端口的输入源准备就绪并等待触发，请立即处理该事件。转到第9步。
         6.通知观察者线程即将睡眠。
         7.将线程置于睡眠状态，直到发生以下事件之一:
             事件到达基于端口的输入源。
             计时器运行。
             为运行循环设置的超时值到期。
             运行循环被明确唤醒。
         8.通知观察者线程被唤醒。
         9.处理待处理事件。
             如果触发了用户定义的计时器，则处理计时器事件并重新启动循环。转到第2步。
             如果输入源被触发，则传递事件。
             如果运行循环被明确唤醒但尚未超时，请重新启动循环。转到第2步。
         10.通知观察者运行循环已退出。

 */

//MARK:OC对象释放的流程?
/**
 runloop的循环周期会检查引用计数，释放流程：release->dealloc->dispose
 release：引用计数器减一，直到为0时开始释放
 dealloc：对象销毁的入口
 dispose：销毁对象和释放内存
 objc_destructInstance：调用C++的清理方法和移除关联引用
 clearDeallocating：把weak置nil，销毁当前对象的表结构，通过以下两个方法执行（二选一）
     sidetable_clearDeallocating：清理有指针isa的对象
     clearDeallocating_slow：清理非指针isa的对象
 free：释放内存
 */

//MARK:PerformSelector 的实现原理?
/**
 当调用 NSObject 的 performSelecter:afterDelay: 后，实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop，则这个方法会失效。
     当调用 performSelector:onThread: 时，实际上其会创建一个 Timer 加到对应的线程去，同样的，如果对应线程没有 RunLoop 该方法也会失效
 */

//MARK:PerformSelector:afterDelay:这个方法在子线程中是否起作用?
/**
 不起作用，子线程默认没有 Runloop，也就没有 Timer。
 解决的办法是可以使用 GCD 来实现：Dispatch_after
 */

//MARK:事件响应过程？
/**
 苹果注册了一个 Source1 (基于 mach port 的) 用来接收系统事件，其回调函数为 __IOHIDEventSystemClientQueueCallback()。

     当一个硬件事件(触摸/锁屏/摇晃等)发生后，首先由 IOKit.framework 生成一个 IOHIDEvent 事件并由 SpringBoard 接收。SpringBoard 只接收按键(锁屏/静音等)，触摸，加速，接近传感器等几种 Event，随后用 mach port 转发给需要的 App 进程。随后苹果注册的那个 Source1 就会触发回调，并调用 _UIApplicationHandleEventQueue() 进行应用内部的分发。

     _UIApplicationHandleEventQueue() 会把 IOHIDEvent 处理并包装成 UIEvent 进行处理或分发，其中包括识别 UIGesture/处理屏幕旋转/发送给 UIWindow 等。通常事件比如 UIButton 点击、touchesBegin/Move/End/Cancel 事件都是在这个回调中完成的。
 */

//MARK:手势识别的原理？
/**
 当上面的 _UIApplicationHandleEventQueue()识别了一个手势时，其首先会调用 Cancel 将当前的 touchesBegin/Move/End 系列回调打断。随后系统将对应的 UIGestureRecognizer 标记为待处理。

     苹果注册了一个 Observer 监测 BeforeWaiting (Loop即将进入休眠) 事件，这个 Observer 的回调函数是 _UIGestureRecognizerUpdateObserver()，其内部会获取所有刚被标记为待处理的 GestureRecognizer，并执行GestureRecognizer 的回调。

     当有 UIGestureRecognizer 的变化(创建/销毁/状态改变)时，这个回调都会进行相应处理
 */

//MARK:runloop和线程的关系？
/**
 runloop和线程是一一对应关系
 key：thread ，value ：loop
 一般来讲，一个线程一次只能执行一个任务，执行完成后线程就会退出。
 保持程序的持续运行(ios程序为什么能一直活着不会死)
 处理app中的各种事件（比如触摸事件、定时器事件【NSTimer】、selector事件【选择器·performSelector···】）
 节省CPU资源，提高程序性能，有事情就做事情，没事情就休息
 
 重要性
 如果没有Runloop,那么程序一启动就会退出，什么事情都做不了。
 如果有了Runloop，那么相当于在内部有一个事件循环，能够保证程序的持续运行
 main函数中的Runloop a 在UIApplication函数内部就启动了一个Runloop 该函数返回一个int类型的值 b 这个默认启动的Runloop是跟主线程相关联的

 */

// MARK: - runloop 是否等于 while(1) { do something ... } ？
/*
 不是
 while(1) 是一个忙等的状态，需要一直占用资源。
 runloop 没有消息需要处理时进入休眠状态，消息来了，需要处理时才被唤醒。
 */

// MARK: - runloop的基本模式
/**
 iOS中有五种runLoop模式
 UIInitializationRunLoopMode（启动后进入的第一个Mode，启动完成后就不再使用，切换到 kCFRunLoopDefaultMode）
 kCFRunLoopDefaultMode（App的默认Mode，通常主线程是在这个 Mode 下运行）
 UITrackingRunLoopMode（界面跟踪 Mode，用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他 Mode 影响）
 NSRunLoopCommonModes （这是一个伪Mode，等效于NSDefaultRunLoopMode和NSEventTrackingRunLoopMode的结合 ）
 GSEventReceiveRunLoopMode（接受系统事件的内部 Mode，通常用不到）
 */

// MARK: - runLoop的基本原理
/**
 系统中的主线程会默认开启runloop检测事件，没有事件需要处理的时候runloop会处于休眠状态。
 一旦有事件触发，例如用户点击屏幕，就会唤醒runloop使进入监听状态，然后处理事件。
 事件处理完成后又会重新进入休眠，等待下一次事件唤醒
 */

// MARK: - runloop和线程的关系
/**
 runloop和线程一一对应。
 主线程的创建的时候默认开启runloop，为了保证程序一直在跑。
 支线程的runloop是懒加载的，需要手动开启。
 */

// MARK: - runloop是怎么被唤醒的
/**
 没有消息需要处理时，休眠线程以避免资源占用。从用户态切换到内核态，等待消息；
 有消息需要处理时，立刻唤醒线程，回到用户态处理消息；
 source0通过屏幕触发直接唤醒
 source0通过调用mach_msg()函数来转移当前线程的控制权给内核态/用户态。
 */

// MARK: - runloop的状态
/**
 CFRunLoopObserverRef observerRef = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
         switch (activity) {
             case kCFRunLoopEntry: NSLog(@"runloop启动"); break;
             case kCFRunLoopBeforeTimers: NSLog(@"runloop即将处理timer事件"); break;
             case kCFRunLoopBeforeSources: NSLog(@"runloop即将处理sources事件"); break;
             case kCFRunLoopBeforeWaiting: NSLog(@"runloop即将进入休眠"); break;
             case kCFRunLoopAfterWaiting: NSLog(@"runloop被唤醒"); break;
             case kCFRunLoopExit: NSLog(@"runloop退出"); break;
             default: break;
         }
     });
     CFRunLoopAddObserver(CFRunLoopGetCurrent(), observerRef, kCFRunLoopDefaultMode);
 }
 */

// MARK: - runLoop 卡顿检测的方法
/**
 NSRunLoop 处理耗时主要下面两种情况

 kCFRunLoopBeforeSources 和 kCFRunLoopBeforeWaiting 之间
 kCFRunLoopAfterWaiting 之后


 上述两个时间太长，可以判定此时主线程卡顿
 可以添加Observer到主线程Runloop中，监听Runloop状态切换耗时，监听卡顿

 用一个do-while循环处理路基，信号量设置阈值判断是否卡顿
 dispatch_semaphore_wait 返回值 非0 表示timeout卡顿发生
 获取卡顿的堆栈传至后端，再分析
 */

// MARK: - 怎么启动一个常驻线程
/**
 // 创建线程
 NSThread *thread = [[NSThread alloc]  initWithTarget:self selector:@selector(play) object:nil];
 [thread start];
 ​
 // runloop保活
 [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
 [[NSRunLoop currentRunLoop] run];
     
 // 处理事件
 [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:NO];
 */

// MARK: - NSTimer、CADisplayLink、dispatch_source_t 的优劣
/**
 NSTimer

 优点在于使用的是target-action模式，简单好用
 缺点是容易不小心造成循环引用。需要依赖runloop，runloop如果被阻塞就要延迟到下一次runloop周期才执行，所以时间精度上也略为不足



 CADisplayLink

 优点是精度高，每次刷新结束后都调用，适合不停重绘的计时，例如视频
 缺点容易不小心造成循环引用。selector循环间隔大于重绘每帧的间隔时间，会导致跳过若干次调用机会。不可以设置单次执行。



 dispatch_source_t

 基于GCD，精度高，不依赖runloop，简单好使，最喜欢的计时器
 需要注意的点是使用的时候必须持有计时器，不然就会提前释放。
 */

// MARK: - GCD计时器
/**
 NSTimeInterval interval = 1.0;
 _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
 dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), interval * NSEC_PER_SEC, 0);
 dispatch_source_set_event_handler(_timer, ^{
     NSLog(@"GCD timer test");
 });
 dispatch_resume(_timer);
 */

NSMutableDictionary *runloops; //runloop保存在全局的字典里，线程作为key，runlooo作为value，runloop内部持有当前线程
//NSRunloop是对CFRunloop的包装，内存地址是一样的。都相当于NSRunloop持有CFRunloop
//Source1给予port的线程间通信，捕捉事件，然后让source0去处理

void observeRunLoopActicities(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
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
        case kCFRunLoopAfterWaiting: //唤醒
            NSLog(@"kCFRunLoopAfterWaiting");
            break;
        case kCFRunLoopExit:
            NSLog(@"kCFRunLoopExit");
            break;
        default:
            break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSRunLoop *runloop;
//    CFRunLoopRef runloop2;
//    runloops[thread] = runloop; //runloop里面是线程作为key，runloop作为value
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    CFRunLoopRef runloop2 = CFRunLoopGetCurrent();
    
    NSArray *array;
    CFArrayRef arry2;

    NSString *string;
    CFStringRef string2;

    //第一次获取runloop的时候，会自动创建
    //NSRunLoop是对CFRunLoopGetCurrent的包装，打印的地址NSRunLoop currentRunLoop]和CFRunLoopGetCurrent是不同的
    NSLog(@"%p %p", [NSRunLoop currentRunLoop], [NSRunLoop mainRunLoop]);
    NSLog(@"%p %p", CFRunLoopGetCurrent(), CFRunLoopGetMain());
    
    // 有序的
//    NSMutableArray *array;
//    [array addObject:@"123"];
//    array[0];
    
    // 无序的
//    NSMutableSet *set;
//    [set addObject:@"123"];
//    [set anyObject];
//
//    kCFRunLoopDefaultMode;
//    NSDefaultRunLoopMode;
    NSLog(@"%@", [NSRunLoop mainRunLoop]);
    
    
    //并不是一下子就执行，需要runloop准备休眠了，才执行
//    self.view.backgroundColor = [UIColor redColor];
    
    
    
    // kCFRunLoopCommonModes默认包括kCFRunLoopDefaultMode、UITrackingRunLoopMode
    
    
    // 创建Observer
//    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, observeRunLoopActicities, NULL);
//    // 添加Observer到RunLoop中
//    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
//    // 释放
//    CFRelease(observer);
    
    // 创建Observer
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault,
                                                                       kCFRunLoopAllActivities,
                                                                       YES,
                                                                       0,
                                                                       ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry: { //进入
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopEntry - %@", mode);
                CFRelease(mode);
                break;
            }
                
            case kCFRunLoopExit: { //退出
                CFRunLoopMode mode = CFRunLoopCopyCurrentMode(CFRunLoopGetCurrent());
                NSLog(@"kCFRunLoopExit - %@", mode);
                CFRelease(mode);
                break;
            }
                
            case kCFRunLoopBeforeTimers:
                NSLog(@"kCFRunLoopBeforeTimers");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"kCFRunLoopBeforeSources");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"kCFRunLoopBeforeWaiting");
                break;
            case kCFRunLoopAfterWaiting: //唤醒
                NSLog(@"kCFRunLoopAfterWaiting");
                break;
            default:
                break;
        }
    });
    // 添加Observer到RunLoop中,kCFRunLoopCommonModes同时监听默认和滚动
    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    // 释放
    CFRelease(observer);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //这里打断点bt，可以看到函数调用栈里面__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__，证明存在source0
//    NSLog(@"%s",__func__);
    
    //证明存在timers
    [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"定时器-----------");
    }];
    
}

@end
