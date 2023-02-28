//
//  MJProxy.m
//  Interview03-定时器
//
//  Created by MJ Lee on 2018/6/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJProxy.h"

@implementation MJProxy

+ (instancetype)proxyWithTarget:(id)target
{
    MJProxy *proxy = [[MJProxy alloc] init];
    proxy.target = target;
    return proxy;
}

//转发给target去执行aSelector
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.target;
}

@end
