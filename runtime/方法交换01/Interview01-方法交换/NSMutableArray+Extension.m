//
//  NSMutableArray+Extension.m
//  Interview01-方法交换
//
//  Created by MJ Lee on 2018/5/31.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "NSMutableArray+Extension.h"
#import <objc/runtime.h>

@implementation NSMutableArray (Extension)

+ (void)load
{
    //为了确保只执行一次，最好加上这个。可能存在一些不规范，可能出现多次执行，比如主动调用[class load]。
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇：NSString、NSArray、NSDictionary，真实类型是其他类型
        Class cls = NSClassFromString(@"__NSArrayM");
        //__NSArrayM NSMutableArray NSArray NSObject
        NSLog(@"%@ %@ %@ %@",cls , [cls superclass],[[cls superclass] superclass],[[[cls superclass] superclass] superclass]);
        Method method1 = class_getInstanceMethod(cls, @selector(insertObject:atIndex:));
        Method method2 = class_getInstanceMethod(cls, @selector(mj_insertObject:atIndex:));
        method_exchangeImplementations(method1, method2);
    });
}

- (void)mj_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject == nil) return;
    
    [self mj_insertObject:anObject atIndex:index];
}

@end
