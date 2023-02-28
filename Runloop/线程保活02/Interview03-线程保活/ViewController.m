//
//  ViewController.m
//  Interview03-线程保活
//
//  Created by MJ Lee on 2018/6/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJThread.h"

@interface ViewController ()
@property (strong, nonatomic) MJThread *thread;
@end

@implementation ViewController

// MARK: - 进程和线程的区别
/**
 进程：进程是指在系统中正在运行的一个应用程序，一个进程拥有多个线程。
 线程：线程是进程中的一个单位，一个进程想要执行任务， 必须至少有一条线程。应程序启动默认开启主线程。
 */

// MARK: - 进程都有什么状态
/**
 Not Running：未运行。
 Inactive：前台非活动状态。处于前台，但是不能接受事件处理。
 Active：前台活动状态。处于前台，能接受事件处理。
 Background：后台状态。进入后台，如果又可执行代码，会执行代码，代码执行完毕，程序进行挂起。
 Suspended：挂起状态。进入后台，不能执行代码，如果内存不足，程序会被杀死。
 */

// MARK: - 怎样保证线程安全？
/**
 通过线程加锁
 pthread_mutex 互斥锁（C语言）
 @synchronized
 NSLock 对象锁
 NSRecursiveLock 递归锁
 NSCondition & NSConditionLock 条件锁
 dispatch_semaphore GCD信号量实现加锁
 OSSpinLock自旋锁（不建议使用）
 os_unfair_lock自旋锁（IOS10以后替代OSSpinLock）
 */

// MARK: - iOS开发中有多少类型的线程？分别说说
/**
 1、pthread

 C语言实现的跨平台通用的多线程API
 使用难度大，没有用过


 2、NSThread

 OC面向对象的多线程API
 简单易用，可以直接操作线程对象。
 需要手动管理生命周期


 3、GCD

 C语言实现的多核并行CPU方案，能更合理的运行多核CPU
 可以自动管理生命周期


 4、NSOperation

 OC基于GCD的封装
 完全面向对象的多线程方案
 可以自动管理生命周期
 */

// MARK: - 线程同步的方式
/**
 GCD的串行队列，任务都一个个按顺序执行
 NSOperationQueue设置maxConcurrentOperationCount = 1，同一时刻只有1个NSOperation被执行
 使用dispatch_semaphore信号量阻塞线程，直到任务完成再放行
 dispatch_group也可以阻塞到所有任务完成才放行
 */

// MARK: - dispatch_once实现原理
/**
 dispatch_once需要传入dispatch_once_t类型的参数，其实是个长整形
 处理block前会判断传入的dispatch_once_t是否为0，为0表示block 尚未执行。
 执行后把token的值改为1，下次再进来的时候判断非0直接不处理了。
 */

// MARK: - performSelector和runloop的关系
/**
 调用 performSelecter:afterDelay: ，其内部会创建一个Timer并添加到当前线程的RunLoop 。
 如果当前线程Runloop没有跑起来，这个方法会失效。
 其他的performSelector系列方法是类似的
 */

// MARK: - 子线程执行 [p performSelector:@selector(func) withObject:nil afterDelay:4] 会发生什么？
/**
 上面这个方法放在子线程，其实内部会创建一个NSTimer定时器。
 子线程不会默认开启runloop，如果需要执行func函数得手动开启runloop
 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
     dispatch_async(queue, ^{
         // [[NSRunLoop currentRunLoop] run]; 放在上面无效
         // 只开启runloop但是里面没有任何事件，开启失败
         [self performSelector:@selector(test) withObject:nil afterDelay:2];
         [[NSRunLoop currentRunLoop] run];
 });
 */

// MARK: - 为什么只在主线程刷新UI
/**
 UIKit是线程不安全的，UI操作涉及到渲染和访问View的属性，异步操作会存在读写问题，为其加锁则会耗费大量资源并拖慢运行速度。
 程序的起点UIApplication在主线程初始化，所有的用户事件（触摸交互）都在主线程传递，所以view只能在主线程上才能对事件进行响应。
 */

// MARK: - 一个队列负责插入数据操作，一个队列负责读取操作，同时操作一个存储的队列，如何保证顺利进行
/**
 使用GCD栅栏函数实现多度单写
 读取的时候使用 dispatch_sync 立刻返回数据
 写入的时候使用 dispatch_barrier_async 阻塞其他操作后写入
 注意尽量不要使用全局队列，因为全局队列里还有其他操作
 */

// MARK: - 什么是互斥锁
/**
 如果共享数据已经有了其他线程加锁了，线程会进行休眠状态等待锁
 一旦被访问的资源被解锁，则等待资源的线程会被唤醒。
 任务复杂的时间长的情况建议使用互斥锁
 优点
 获取不到资源时线程休眠，cpu可以调度其他的线程工作

 缺点
 存在线程调度的开销
 如果任务时间很短，线程调度降低了cpu的效率
 */

// MARK: - 什么是自旋锁
/**
 如果共享数据已经有其他线程加锁了，线程会以死循环的方式等待锁
 一旦被访问的资源被解锁，则等待资源的线程会立即执行
 适用于持有锁较短时间
 优点：

 自旋锁不会引起线程休眠，不会进行线程调度和CPU时间片轮转等耗时操作。
 如果能在很短的时间内获得锁，自旋锁效率远高于互斥锁。


 缺点：

 自旋锁一直占用CPU，未获得锁的情况下处于忙等状态。
 如果不能在很短的时间内获得锁，使CPU效率降低。
 自旋锁不能实现递归调用。
 */

// MARK: - 说说@synchronized
/**
 原理

 内部应该是一个可重入互斥锁（recursive_mutex_t）
 底层是链表，存储SyncData，SyncData里面包含一个 threadCount，就是访问资源的线程数量。
 objc_sync_enter(obj)，objc_sync_exit(obj)，通过obj的地址作为hash传参查找SyncData，上锁解锁。
 传入的obj被释放或为nil，会执行锁的释放


 优点

 不需要创建锁对象也能实现锁的功能
 使用简单方便，代码可读性强


 缺点

 加锁的代码尽量少
 性能没有那么好
 注意锁的对象必须是同一个OC对象
 */

// MARK: - 说说NSLock
/**
 遵循NSLocking协议
 注意点
   同一线程lock和unlock需要成对出现
   同一线程连续lock两次会造成死锁
 */

// MARK: - 说说NSRecursiveLock
/**
 NSRecursiveLock是递归锁
 注意点
   同一个程lock多次而不造成死锁
   同一线程当lock & unlock数量一致的时候才会释放锁，其他线程才能上锁
 */

// MARK: - 说说NSCondition & NSConditionLock
/**
 条件锁：满足条件执行锁住的代码；不满足条件就阻塞线程，直到另一个线程发出解锁信号。
 NSCondition对象实际上作为一个锁和一个线程检查器

 锁保护数据源，执行条件引发的任务。
 线程检查器根据条件判断是否阻塞线程。
 需要手动等待和手动信号解除等待
 一个wait必须对应一个signal，一次唤醒全部需要使用broadcast


 NSConditionLock是NSCondition的封装

 通过不同的condition值触发不同的操作
 解锁时通过unlockWithCondition 修改condition实现任务依赖
 通过condition自动判断阻塞还是唤醒线程
 */

// MARK: - 说说GCD信号量实现锁
/**
 dispatch_semaphore_creat(0)生成一个信号量semaphore = 0（ 传入的值可以控制并行任务的数量）
 dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER) 使semaphore - 1，当值小于0进入等待
 dispatch_semaphore_signal(semaphore)发出信号，使semaphore + 1，当值大于等于0放行
 */

// MARK: - 说说OSSpinLock
/**
 OSSpinLock是自旋锁，忙等锁


 自旋锁存在优先级反转的问题，线程有优先级的时候可能导致下列情况。

 一个优先级低的线程先访问某个数据，此时使用自旋锁进行了加锁。
 一个优先级高的线程又去访问这个数据，优先级高的线程会一直占着CPU资源忙等访问
 结果导致优先级低的线程没有CPU资源完成任务，也无法释放锁。



 由于自旋锁本身存在的问题，所以苹果已经废弃了OSSpinLock。
 */

// MARK: - 说说 os_unfair_lock
/**
 iOS10以后替代OSSpinLock的锁，不再忙等
 获取不到资源时休眠，获取到资源时由内核唤醒线程
 没有加强公平性和顺序，释放锁的线程可能立即再次加锁，之前等待锁的线程唤醒后可能也没能加锁成功。
 虽然解决了优先级反转，但也造成了饥饿（starvation）
 starvation 指贪婪线程占用资源事件太长，其他线程无法访问共享资源。
 */

// MARK: - Objective-C中的原子和非原子属性
/**
 OC在定义属性时有nonatomic和atomic两种选择
 atomic：原子属性，为setter/getter方法都加锁（默认就是atomic），线程安全，需要消耗大量的资源
 nonatomic：非原子属性，不加锁，非线程安全

 atomic加锁原理:
 property (assign, atomic) int age;
  - (void)setAge:(int)age
 {
     @synchronized(self) {
        _age = age;
     }
 }
 ​
 - （int）age {
   int age1 = 0;
   @synchronized(self) {
     age1 = _age;
   }
 }
 */

// MARK: - atomic 修饰的属性 int a，在不同的线程执行 self.a = self.a + 1 执行一万次，这个属性的值会是一万吗？
/**
 不会，左边的点语法调用的是setter，右边调用的是getter，这行语句并不是原子性的。
 */

// MARK: - atomic就一定能保证线程安全么？
/**
 不能，只能保证setter和getter在当前线程的安全
 一个线程在连续多次读取某条属性值的时候，别的线程同时在改值，最终无法得出期望值
 一个线程在获取当前属性的值， 另外一个线程把这个属性释放调了，有可能造成崩溃
 */

// MARK: - nonatomic是非原子操作符，为什么用nonatomic不用atomic？
/**
 如果该对象无需考虑多线程的情况，请加入这个属性修饰，这样会让编译器少生成一些互斥加锁代码，可以提高效率。
 使用atomic，编译器会在setter和getter方法里面自动生成互斥锁代码，避免该变量读写不同步。
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.thread = [[MJThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [self.thread start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO]; //waitUntilDone是否等子线程任务完成才执行，no:不卡住，立即执行
    NSLog(@"123");
}

// 子线程需要执行的任务
- (void)test
{
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
}

// 这个方法的目的：线程保活
- (void)run {
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
    
    // 往RunLoop里面添加Source\Timer\Observer，如果没有Source\Timer\Observer，runloop会退出
    [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"%s ----end----", __func__);
}

@end
