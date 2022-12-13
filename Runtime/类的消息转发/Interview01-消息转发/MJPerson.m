//
//  MJPerson.m
//  Interview01-消息转发
//
//  Created by MJ Lee on 2018/5/26.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"
#import <objc/runtime.h>
#import "MJCat.h"

@implementation MJPerson

+ (id)forwardingTargetForSelector:(SEL)aSelector
{
    // objc_msgSend([[MJCat alloc] init], @selector(test))
    // [[[MJCat alloc] init] test]
    if (aSelector == @selector(test)) return [[MJCat alloc] init];

    return [super forwardingTargetForSelector:aSelector];
}

//+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
//{
//    if (aSelector == @selector(test)) return [NSMethodSignature signatureWithObjCTypes:"v@:"];
//
//    return [super methodSignatureForSelector:aSelector];
//}
//
//+ (void)forwardInvocation:(NSInvocation *)anInvocation
//{
//    NSLog(@"1123");
//}

@end
