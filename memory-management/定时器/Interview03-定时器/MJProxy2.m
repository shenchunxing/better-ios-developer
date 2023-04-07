//
//  MJProxy2.m
//  Interview03-定时器
//
//  Created by 沈春兴 on 2023/2/28.
//  Copyright © 2023 MJ Lee. All rights reserved.
//

#import "MJProxy2.h"

@interface MJProxy2 ()
@property (weak, nonatomic) id target;

@end

@implementation MJProxy2

+ (instancetype)proxyWithTarget:(id)target
{
    MJProxy2 *proxy = [MJProxy2 alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if (self.target) {
        
    } else {
        NSLog(@"报错");
    }
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (self.target) {
        [invocation invokeWithTarget:self.target];
    } else {
        NSLog(@"报错");
    }
}

@end
