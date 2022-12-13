//
//  ViewController.m
//  Interview02-读写安全
//
//  Created by MJ Lee on 2018/6/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()
@property (strong, nonatomic) dispatch_queue_t queue;
@end

@implementation ViewController

//- (void)viewDidLoad {
//    [super viewDidLoad];
//
////    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
////    queue.maxConcurrentOperationCount = 5;
//
////    dispatch_semaphore_create(5);
//
//    self.queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);
//
//    for (int i = 0; i < 10; i++) {
//        dispatch_async(self.queue, ^{
//            [self read];
//        });
//
//        dispatch_async(self.queue, ^{
//            [self read];
//        });
//
//        dispatch_async(self.queue, ^{
//            [self read];
//        });
//
//        dispatch_barrier_async(self.queue, ^{
//            [self write];
//        });
//    }
//}
//
//
//- (void)read {
//    sleep(1);
//    NSLog(@"read");
//}
//
//- (void)write
//{
//    sleep(1);
//    NSLog(@"write");
//}

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_SERIAL);//串行队列无法并发读取
    self.queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);
//    self.queue = dispatch_get_global_queue(0, 0);

    for (int i = 0; i < 10; i++) { //栅栏函数实现多读单写，必须是手动创建的并发队列
        [self read];
        [self read];
        [self read];
        [self write];
    }
}

- (void)read {
    dispatch_async(self.queue, ^{ //读取也要加锁，因为可能在读的时候，刚好在写。不允许同时读和写
        NSLog(@"read");
    });
}

- (void)write
{
    //注意：dispatch_barrier_async传入的并发队列，必须是自己创建的并发队列，不能是全局的
    //如果传入的是全局并发队列或者串行队列，相当于dispatch_async
    dispatch_barrier_async(self.queue, ^{//写肯定需要加锁，同一时间保证只有1条线程在写
        NSLog(@"write");
    });
}

@end


//
//
//@end
