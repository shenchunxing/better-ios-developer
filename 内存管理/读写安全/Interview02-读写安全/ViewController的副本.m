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
@property (assign, nonatomic) pthread_rwlock_t lock; //读写锁
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化锁:读写锁
    pthread_rwlock_init(&_lock, NULL);
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    for (int i = 0; i < 10; i++) {
        dispatch_async(queue, ^{
            [self read];
        });
        dispatch_async(queue, ^{
            [self write];
        });
    }
}


- (void)read {
    pthread_rwlock_rdlock(&_lock); //读加锁pthread_rwlock_rdlock
    
    sleep(1);
    NSLog(@"%s", __func__);
    
    pthread_rwlock_unlock(&_lock);
}

- (void)write
{
    pthread_rwlock_wrlock(&_lock); //写加锁pthread_rwlock_wrlock
    
    sleep(1);
    NSLog(@"%s", __func__);
    
    pthread_rwlock_unlock(&_lock);
}

- (void)dealloc
{
    pthread_rwlock_destroy(&_lock); //需要销毁
}


@end
