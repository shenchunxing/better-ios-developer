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

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if (aSelector == @selector(test:)) {
        
        //3种写法等价
//        return [NSMethodSignature signatureWithObjCTypes:"v20@0:8i16"];
        return [NSMethodSignature signatureWithObjCTypes:"i@:i"];
//        return [[[MJCat alloc] init] methodSignatureForSelector:aSelector];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    // 参数顺序：receiver、selector、other arguments
//    int age;
//    [anInvocation getArgument:&age atIndex:2];
//    NSLog(@"%d", age + 10);
    
    
    // anInvocation.target == [[MJCat alloc] init]
    // anInvocation.selector == test:
    // anInvocation的参数：15
    // [[[MJCat alloc] init] test:15]
    
    [anInvocation invokeWithTarget:[[MJCat alloc] init]];
    
    int ret;
    [anInvocation getReturnValue:&ret];
    
    NSLog(@"%d", ret);
}

@end
