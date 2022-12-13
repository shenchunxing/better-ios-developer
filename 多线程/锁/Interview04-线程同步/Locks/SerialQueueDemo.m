//
//  SerialQueue.m
//  Interview04-线程同步
//
//  Created by MJ Lee on 2018/6/12.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "SerialQueueDemo.h"

@interface SerialQueueDemo()
@property (strong, nonatomic) dispatch_queue_t ticketQueue;
@property (strong, nonatomic) dispatch_queue_t moneyQueue;
@end

@implementation SerialQueueDemo

- (instancetype)init
{
    if (self = [super init]) {
        self.ticketQueue = dispatch_queue_create("ticketQueue", DISPATCH_QUEUE_SERIAL); //串行队列
        self.moneyQueue = dispatch_queue_create("moneyQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)__drawMoney
{
    dispatch_sync(self.moneyQueue, ^{
        [super __drawMoney];
    });
}

- (void)__saveMoney
{
    dispatch_sync(self.moneyQueue, ^{
        [super __saveMoney];
    });
}

- (void)__saleTicket
{
    dispatch_sync(self.ticketQueue, ^{ //这里sync就行，在子线程执行没问题，如果asnyc可能再开一条线程
        [super __saleTicket];
    });
}

@end
