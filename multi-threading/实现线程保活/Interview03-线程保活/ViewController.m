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
@property (assign, nonatomic, getter=isStoped) BOOL stopped;
@end

@implementation ViewController

//完善逻辑，导航返回的时候，也能销毁runloop
- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    //设置标志位
    self.stopped = NO;
    //创建线程
    self.thread = [[MJThread alloc] initWithBlock:^{
        //打印子线程
        NSLog(@"%@----begin----", [NSThread currentThread]);
        
        // 添加一个端口是为了确保运行循环不会在没有源（sources）、定时器（timers）或观察者（observers）的情况下立即退出。通过添加空的端口，我们提供了一个持久的输入源，使得运行循环可以持续运行而不退出。这通常用于在子线程中创建一个长期运行的运行循环，以便在其中执行任务或等待任务的到来。
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    
        //这里self可能为空，返回的时候释放了，所以要加判断self是否存在
        //runMode是运行循环的实际启动和执行方法，用于处理运行循环中的事件
        //如果没有while循环，会导致子线程的运行循环在执行一次后立即退出，而不会持续监听和处理事件。
        while (weakSelf && !weakSelf.isStoped) {
            //运行子线程runloop
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        NSLog(@"%@----end----", [NSThread currentThread]);
    }];
    //start后，立刻执行block内部代码
    [self.thread start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.thread) return; //线程被销毁，就不要在里面做事情
    //子线程执行test方法
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
}

// 子线程需要执行的任务
- (void)test {
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
}

- (IBAction)stop {
    if (!self.thread) return; //线程被销毁，就不要在里面做事情
    // 在子线程调用stop（waitUntilDone设置为YES，代表子线程的代码执行完毕后，这个方法才会往下走）
    [self performSelector:@selector(stopThread) onThread:self.thread withObject:nil waitUntilDone:YES];
}

// stopThread方法在子线程执行，停止子线程的runloop，并销毁子线程
- (void)stopThread {
    // 设置标记为YES，表示停止子线程
    self.stopped = YES;
    // 停止RunLoop
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
    // 销毁线程
    self.thread = nil;
}


/// 让ViewController销毁的时候，同时停止runloop，并销毁子线程
- (void)dealloc {
    NSLog(@"%s", __func__);
    [self stop];
}

@end
