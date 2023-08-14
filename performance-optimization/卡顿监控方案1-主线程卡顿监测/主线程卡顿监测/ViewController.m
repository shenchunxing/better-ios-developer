//
//  ViewController.m
//  主线程卡顿监测
//
//  Created by 沈春兴 on 2023/8/13.
//

#import "ViewController.h"
/**
 主线程卡顿监控。通过子线程监测主线程的runLoop，判断两个状态区域之间的耗时是否达到一定阈值。
 通过采用检测主线程每次执行消息循环的时间，当这一时间大于规定的阈值时，就记为发生了一次卡顿的方式来监控。 这也是美团的移动端采用的性能监控Hertz 方案，微信团队也在实践过程中提出来类似的方案--微信读书 iOS 性能优化总结。
 方案的提出，是根据滚动引发的Sources事件或其它交互事件总是被快速的执行完成，然后进入到kCFRunLoopBeforeWaiting状态下；假如在滚动过程中发生了卡顿现象，那么RunLoop必然会保持kCFRunLoopAfterWaiting或者kCFRunLoopBeforeSources这两个状态之一。 所以监控主线程卡顿的方案一：

 开辟一个子线程，然后实时计算 `kCFRunLoopBeforeSources` 和 `kCFRunLoopAfterWaiting` 两个状态区域之间的耗时是否超过某个阀值，来断定主线程的卡顿情况。 但是由于主线程的`RunLoop`在闲置时基本处于`Before Waiting`状态，这就导致了即便没有发生任何卡顿，这种检测方式也总能认定主线程处在卡顿状态。 为了解决这个问题寒神(南栀倾寒)给出了自己的解决方案，`Swift`的卡顿检测第三方`ANREye`。这套卡顿监控方案大致思路为：创建一个子线程进行循环检测，每次检测时设置标记位为YES，然后派发任务到主线程中将标记位设置为NO。接着子线程沉睡超时阙值时长，判断标志位是否成功设置成NO，如果没有说明主线程发生了卡顿。 结合这套方案，当主线程处在`Before Waiting`状态的时候，通过派发任务到主线程来设置标记位的方式处理常态下的卡顿检测
 */
#import <Foundation/Foundation.h>

@interface LSLBacktraceLogger : NSObject

+ (void)logMain;

@end

@implementation LSLBacktraceLogger


/// TODO:这里看到只能打印子线程的调用栈，我需要的是主线程。。。需要查看源码再探究下。
+ (void)logMain {
    NSLog(@"Thread Backtrace:\n%@", [NSThread callStackSymbols]);
}

+ (NSArray<NSString *> *)captureMainThreadBacktrace {
    // Obtain the main thread's backtrace symbols
    return NSThread.callStackSymbols;
}

@end

#import <Foundation/Foundation.h>

@interface LSLAppFluencyMonitor : NSObject

+ (instancetype)monitor;
- (void)startMonitoring;
- (void)stopMonitoring;

@end

@interface LSLAppFluencyMonitor ()

@property (nonatomic, assign) BOOL isMonitoring;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, assign) NSTimeInterval timeOutInterval;

@end

@implementation LSLAppFluencyMonitor

+ (instancetype)monitor {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _isMonitoring = NO;
        _timeOutInterval = 0.05;
    }
    return self;
}

- (void)startMonitoring {
    if (self.isMonitoring) { return; }
    self.isMonitoring = YES;
    self.semaphore = dispatch_semaphore_create(0);

    dispatch_queue_t monitorQueue = dispatch_queue_create("com.myapp.monitor_queue", NULL);
    dispatch_async(monitorQueue, ^{
        while (self.isMonitoring) {
            __block BOOL timedOut = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                timedOut = NO;
                dispatch_semaphore_signal(self.semaphore);
            });
            
            [NSThread sleepForTimeInterval:self.timeOutInterval];

            //如果超时还没完成任务，timedOut就还是YES
            if (timedOut) {
                [LSLBacktraceLogger logMain];
            }

            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        }
    });
}

- (void)stopMonitoring {
    if (!self.isMonitoring) { return; }
    self.isMonitoring = NO;
}

@end

@interface ViewController ()

@property (nonatomic, strong) UIView *laggyView;
@property (nonatomic, strong) LSLAppFluencyMonitor *fluencyMonitor;
@property (nonatomic, strong) UILabel *stallLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create and add a simulated laggy view
    self.laggyView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    self.laggyView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.laggyView];

    // Create and add the stall label
    self.stallLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    self.stallLabel.center = CGPointMake(self.view.center.x, CGRectGetMaxY(self.view.frame) - 50);
    self.stallLabel.textAlignment = NSTextAlignmentCenter;
    self.stallLabel.textColor = [UIColor redColor];
    self.stallLabel.hidden = YES;
    [self.view addSubview:self.stallLabel];

    // Start monitoring
    self.fluencyMonitor = [LSLAppFluencyMonitor monitor];
    [self.fluencyMonitor startMonitoring];

    // Simulate a laggy situation after a delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i = 0; i < 1000; i++) {
            double value = sqrt(arc4random_uniform(1000000));
            NSLog(@"Value: %f", value);
        }
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.fluencyMonitor stopMonitoring];
}

@end
