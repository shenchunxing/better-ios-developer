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
@property (assign, nonatomic) pthread_rwlock_t lock; //读写锁
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self dispatch_barrier_asyncTest];//异步栅栏调用，实现读写安全
//    [self pthread_rwlock_rdlockTest];//读写锁实现读写安全,同一把锁，实现单读单写
}

- (void)dispatch_barrier_asyncTest {
//        self.queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_SERIAL);//串行队列无法并发读取
        self.queue = dispatch_queue_create("rw_queue", DISPATCH_QUEUE_CONCURRENT);
//        self.queue = dispatch_get_global_queue(0, 0);//无法起到隔离作用，相当于dispatch_async

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
    dispatch_barrier_async(self.queue, ^{//写必须加锁，同一时间保证只有1条线程在写
        NSLog(@"write");
    });
}




- (void)pthread_rwlock_rdlockTest {
    // 初始化锁:读写锁
    pthread_rwlock_init(&_lock, NULL);
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            [self read2];
        });
        dispatch_async(queue, ^{
            [self write2];
        });
    }
}


- (void)read2 {
    pthread_rwlock_rdlock(&_lock); //读加锁pthread_rwlock_rdlock
    
    sleep(1);
    NSLog(@"%s", __func__);
    
    pthread_rwlock_unlock(&_lock);
}

- (void)write2
{
    pthread_rwlock_wrlock(&_lock); //写加锁pthread_rwlock_wrlock
    
    sleep(1);
    NSLog(@"%s", __func__);
    
    pthread_rwlock_unlock(&_lock);
}

- (void)dealloc
{
    pthread_rwlock_destroy(&_lock); //需要销毁锁头
}

@end


