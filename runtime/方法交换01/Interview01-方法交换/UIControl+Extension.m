//
//  UIControl+Extension.m
//  Interview01-方法交换
//
//  Created by MJ Lee on 2018/5/31.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "UIControl+Extension.h"
#import <objc/runtime.h>

@implementation UIControl (Extension)

+ (void)load
{
    // hook：钩子函数
    Method method1 = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method method2 = class_getInstanceMethod(self, @selector(mj_sendAction:to:forEvent:));
    method_exchangeImplementations(method1, method2);
}

//交换的是类对象方法列表里面的imp，交换之后会立即刷新清除缓存，因此不会导致缓存查找到后出现调用问题
- (void)mj_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    NSLog(@"%@-%@-%@", self, target, NSStringFromSelector(action));
    
    // 调用系统原来的实现，这个是保险的
    //这里不会出现死循环，这里走的是系统的实现
    [self mj_sendAction:action to:target forEvent:event];
    
    //这么做不保险，可能还做了其他操作
//    [target performSelector:action];
    
//    if ([self isKindOfClass:[UIButton class]]) {
//        // 拦截了所有按钮的事件
//
//    }
}

@end
