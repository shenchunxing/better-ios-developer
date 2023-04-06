//
//  MJPerson.m
//  Interview05-super
//
//  Created by MJ Lee on 2018/5/26.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson

- (void)run
{
    NSLog(@"run-123");
}
// MARK: - 防止出现方法找不到的崩溃
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // 本来能调用的方法
    if ([self respondsToSelector:aSelector]) {
        return [super methodSignatureForSelector:aSelector];
    }
    
    // 找不到的方法
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

// 找不到的方法，都会来到这里
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"找不到%@方法", NSStringFromSelector(anInvocation.selector));
}
@end

// NSProxy
