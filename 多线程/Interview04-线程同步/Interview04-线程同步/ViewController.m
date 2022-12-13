//
//  ViewController.m
//  Interview04-线程同步
//
//  Created by MJ Lee on 2018/6/7.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import <libkern/OSAtomic.h>

@interface ViewController ()
@property (assign, nonatomic) int money;
@property (assign, nonatomic) int ticketsCount;
@property (assign, nonatomic) OSSpinLock lock;//自旋锁，已经不再安全
@property (assign, nonatomic) OSSpinLock lock1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化锁
    self.lock = OS_SPINLOCK_INIT;
    self.lock1 = OS_SPINLOCK_INIT;
    
    [self ticketTest];
    [self moneyTest];
}

/**
 存钱、取钱演示
 */
- (void)moneyTest
{
    self.money = 100;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++) {
            [self saveMoney];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 10; i++) {
            [self drawMoney];
        }
    });
}

/**
 存钱
 */
- (void)saveMoney
{
    // 加锁
    OSSpinLockLock(&_lock1);
    
    int oldMoney = self.money;
    sleep(.2);
    oldMoney += 50;
    self.money = oldMoney;
    
    NSLog(@"存50，还剩%d元 - %@", oldMoney, [NSThread currentThread]);
    
    // 解锁
    OSSpinLockUnlock(&_lock1);
}

/**
 取钱
 */
- (void)drawMoney
{
    // 加锁
    OSSpinLockLock(&_lock1);
    
    int oldMoney = self.money;
    sleep(.2);
    oldMoney -= 20;
    self.money = oldMoney;
    
    NSLog(@"取20，还剩%d元 - %@", oldMoney, [NSThread currentThread]);
    // 解锁
    OSSpinLockUnlock(&_lock1);
}

/*
 thread1：优先级比较高
 
 thread2：优先级比较低
 优先级反转：如果一开始thread2先拿到锁，导致thread1一直在忙等，而cpu一直在给thread1分配资源，导致thread2无法解锁。
 
 thread3
 
 线程的调度，10ms
 
 时间片轮转调度算法（进程、线程）
 线程优先级
 */

/**
 卖1张票
 */
- (void)saleTicket
{
//    if (OSSpinLockTry(&_lock)) {
//        int oldTicketsCount = self.ticketsCount;
//        sleep(.2);
//        oldTicketsCount--;
//        self.ticketsCount = oldTicketsCount;
//        NSLog(@"还剩%d张票 - %@", oldTicketsCount, [NSThread currentThread]);
//
//        OSSpinLockUnlock(&_lock);
//    }
    
    // 加锁
    OSSpinLockLock(&_lock);

    int oldTicketsCount = self.ticketsCount;
    sleep(.2);
    oldTicketsCount--;
    self.ticketsCount = oldTicketsCount;
    NSLog(@"还剩%d张票 - %@", oldTicketsCount, [NSThread currentThread]);
    
    // 解锁
    OSSpinLockUnlock(&_lock);
}

/**
 卖票演示
 */
- (void)ticketTest
{
    self.ticketsCount = 15;
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            [self saleTicket];
        }
    });
}

@end
