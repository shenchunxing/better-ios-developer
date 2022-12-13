//
//  OSSpinLockDemo2.m
//  Interview04-线程同步
//
//  Created by MJ Lee on 2018/6/7.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "OSSpinLockDemo2.h"
#import <libkern/OSAtomic.h>

@implementation OSSpinLockDemo2

//两个地方都在用，设置成全局的
static OSSpinLock moneyLock_;
+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        moneyLock_ = 0; //初始化
    });
}

- (void)__drawMoney
{
    OSSpinLockLock(&moneyLock_);
    
    [super __drawMoney];
    
    OSSpinLockUnlock(&moneyLock_);
}

- (void)__saveMoney
{
    OSSpinLockLock(&moneyLock_);
    
    [super __saveMoney];
    
    OSSpinLockUnlock(&moneyLock_);
}

- (void)__saleTicket
{
    //可以用这个方法给static变量初始化一次
//    static NSString *str = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        str = [NSString stringWithFormat:@"123"];
//    });
    
    //因为只有在这个方法里面使用，弄成static
    //注意：static右边不能为函数，因为函数是在运行期间才调，static必须在编译器就确定的
    static OSSpinLock ticketLock = OS_SPINLOCK_INIT;
    
    OSSpinLockLock(&ticketLock);
    
    [super __saleTicket];
    
    OSSpinLockUnlock(&ticketLock);
}

@end
