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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    self.stopped = NO;
    self.thread = [[MJThread alloc] initWithBlock:^{
        NSLog(@"%@----begin----", [NSThread currentThread]);
        
        // 往RunLoop里面添加Source\Timer\Observer
        //线程保活
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        while (!weakSelf.isStoped) { //可以停止的runloop，runloop会一直调用，直到条件不满足，不写while循环，runloop就执行一次，无法保活
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        NSLog(@"%@----end----", [NSThread currentThread]);
        
        // NSRunLoop的run方法是无法停止的，它专门用于开启一个永不销毁的线程（NSRunLoop）
        //        [[NSRunLoop currentRunLoop] run];
        /*
         it runs the receiver in the NSDefaultRunLoopMode by repeatedly invoking runMode:beforeDate:.
         In other words, this method effectively begins an infinite loop that processes data from the run loop’s input sources and timers
         */
        
    }];
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

- (IBAction)stop {
    // 在子线程调用stop
    [self performSelector:@selector(stopThread) onThread:self.thread withObject:nil waitUntilDone:NO];
}

// 用于停止子线程的RunLoop
- (void)stopThread
{
    // 设置标记为NO
    self.stopped = YES;
    
    // 停止RunLoop，这个方法只是停止刚才运行的一次runloop
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    //这里崩溃的原因是waitUntilDone = no,不等待子线程执行，dealloc执行立马结束，self已经释放，子线程访问坏内存访问
    [self stop];
}

@end
