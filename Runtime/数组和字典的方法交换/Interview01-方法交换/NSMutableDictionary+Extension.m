//
//  NSMutableDictionary+Extension.m
//  Interview01-方法交换
//
//  Created by MJ Lee on 2018/5/31.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "NSMutableDictionary+Extension.h"
#import <objc/runtime.h>

@implementation NSMutableDictionary (Extension)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = NSClassFromString(@"__NSDictionaryM");
        //__NSDictionaryM NSMutableDictionary NSDictionary NSObject
        NSLog(@"%@ %@ %@ %@",cls , [cls superclass],[[cls superclass] superclass],[[[cls superclass] superclass] superclass]);
        Method method1 = class_getInstanceMethod(cls, @selector(setObject:forKeyedSubscript:));
        Method method2 = class_getInstanceMethod(cls, @selector(mj_setObject:forKeyedSubscript:));
        method_exchangeImplementations(method1, method2);
        
        Class cls2 = NSClassFromString(@"__NSDictionaryI");
        //__NSDictionaryI NSDictionary NSObject (null)
        NSLog(@"%@ %@ %@ %@",cls2 , [cls2 superclass],[[cls2 superclass] superclass],[[[cls2 superclass] superclass] superclass]);
        Method method3 = class_getInstanceMethod(cls2, @selector(objectForKeyedSubscript:));
        Method method4 = class_getInstanceMethod(cls2, @selector(mj_objectForKeyedSubscript:));
        method_exchangeImplementations(method3, method4);
    });
}

- (void)mj_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
    if (!key) return;
    
    [self mj_setObject:obj forKeyedSubscript:key];
}

- (id)mj_objectForKeyedSubscript:(id)key
{
    if (!key) return nil;
    
    return [self mj_objectForKeyedSubscript:key];
}

@end
