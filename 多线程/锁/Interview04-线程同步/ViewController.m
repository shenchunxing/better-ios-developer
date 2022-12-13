//
//  ViewController.m
//  Interview04-线程同步
//
//  Created by MJ Lee on 2018/6/7.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJBaseDemo.h"
#import "OSSpinLockDemo.h"
#import "OSSpinLockDemo2.h"
#import "OSUnfairLockDemo.h"
#import "MutexDemo.h"
#import "MutexDemo2.h"
#import "MutexDemo3.h"
#import "NSLockDemo.h"
#import "NSConditionDemo.h"
#import "NSConditionLockDemo.h"
#import "SerialQueueDemo.h"
#import "SemaphoreDemo.h"
#import "SynchronizedDemo.h"

#define SemaphoreBegin \
static dispatch_semaphore_t semaphore; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
    semaphore = dispatch_semaphore_create(1); \
}); \
dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

#define SemaphoreEnd \
dispatch_semaphore_signal(semaphore);

dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

@interface ViewController ()
@property (strong, nonatomic) MJBaseDemo *demo;

@property (strong, nonatomic) NSThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MJBaseDemo *demo = [[SynchronizedDemo alloc] init];
//    [demo ticketTest];
//    [demo moneyTest];
    [demo otherTest];
    
    
//    MJBaseDemo *demo2 = [[SynchronizedDemo alloc] init];
//    [demo2 ticketTest];
    
//    self.thread = [[NSThread alloc] initWithBlock:^{
//        NSLog(@"111111");
//
//        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
//        [[NSRunLoop currentRunLoop] run];
//    }];
//    [self.thread start];
    
    // 线程的任务一旦执行完毕，生命周期就结束，无法再使用
    // 保住线程的命为什么要用runloop，用强指针不就好了么？
    // 准确来讲，使用runloop是为了让线程保持激活状态
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        NSLog(@"1");
        
        [self performSelector:@selector(test) withObject:nil afterDelay:.0];
        
        NSLog(@"3");
    });
    
    // 主线程几乎所有的事情都是交给了runloop去做，比如UI界面的刷新、点击时间的处理、performSelector等等
}

- (void)test
{
    NSLog(@"2");
}

- (void)test1
{
    SemaphoreBegin;
    
    // .....
    
    SemaphoreEnd;
}

- (void)test2
{
    SemaphoreBegin;
    
    // .....
    
    SemaphoreEnd;
}

- (void)test3
{
    SemaphoreBegin;
    
    // .....
    
    SemaphoreEnd;
}

@end
