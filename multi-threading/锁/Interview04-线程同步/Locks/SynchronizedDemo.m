//
//  SynchronizedDemo.m
//  Interview04-线程同步
//
//  Created by MJ Lee on 2018/6/12.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "SynchronizedDemo.h"

@implementation SynchronizedDemo

- (void)__drawMoney
{
    @synchronized([self class]) { //保证同一个对象就行[self class] 、 self
        [super __drawMoney];
    }
}

- (void)__saveMoney
{
    @synchronized([self class]) { // 查看汇编调用了runtime：objc_sync_enter
        //底层实现是将传入的对象作为可key，映射到哈希表上。每个key对应一个锁，里面是使用recursive_mutex这个递归锁，recursive_mutex里面封装的是 pthread_mutex_t这个锁
        [super __saveMoney];
    } // runtime：objc_sync_exit
}

- (void)__saleTicket
{
    static NSObject *lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = [[NSObject alloc] init];
    });
    
    @synchronized(lock) { //单例可以保证同一个对象
        [super __saleTicket];
    }
}

- (void)otherTest
{
    @synchronized([self class]) {
        NSLog(@"123");
        [self otherTest];
    }
}
@end
