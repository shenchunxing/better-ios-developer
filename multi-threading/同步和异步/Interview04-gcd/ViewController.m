//
//  ViewController.m
//  Interview04-gcd
//
//  Created by MJ Lee on 2018/6/5.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

// dispatch_sync和dispatch_async用来控制是否要开启新的线程

/**
 队列的类型，决定了任务的执行方式（并发、串行）
 1.并发队列
 2.串行队列
 3.主队列（也是一个串行队列）
 */

//1
- (void)interview01
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？会！
    NSLog(@"1");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        NSLog(@"2");
    });
    
    NSLog(@"3");
    
    // dispatch_sync立马在当前线程同步执行任务
}

//1 3 2
- (void)interview02
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？不会！
    NSLog(@"1");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"2");
    });
    
    NSLog(@"3");
    
    // dispatch_async不要求立马在当前线程同步执行任务
}

//1 5 2
- (void)interview03
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？会！
    NSLog(@"1");
    
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{ // 0
        NSLog(@"2");
        
        dispatch_sync(queue, ^{ // 1
            NSLog(@"3");
        });
    
        NSLog(@"4");
    });
    
    NSLog(@"5");
}

//1 5 2 3 4
- (void)interview04
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？不会！
    NSLog(@"1");
    
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue2 = dispatch_queue_create("myqueu2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue2 = dispatch_queue_create("myqueu2", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(queue, ^{ // 0
        NSLog(@"2");
        
        dispatch_sync(queue2, ^{ // 1
            NSLog(@"3");
        });
        
        NSLog(@"4");
    });
    
    NSLog(@"5");
}


//1 5 2 3 4
- (void)interview05
{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？不会！
    NSLog(@"1");
    
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{ // 0
        NSLog(@"2");
        
        dispatch_sync(queue, ^{ // 1
            NSLog(@"3");
        });
        
        NSLog(@"4");
    });
    
    NSLog(@"5");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self interview05];
    
    dispatch_queue_t queue1 = dispatch_get_global_queue(0, 0);//全局并发队列,只有一个
    dispatch_queue_t queue2 = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue3 = dispatch_queue_create("queu3", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue4 = dispatch_queue_create("queu4", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue5 = dispatch_queue_create("queu5", DISPATCH_QUEUE_CONCURRENT);
    
    NSLog(@"%p %p %p %p %p", queue1, queue2, queue3, queue4, queue5);
}



@end
