//
//  MJPerson.m
//  Interview03-动态方法解析
//
//  Created by MJ Lee on 2018/5/22.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"
#import <objc/runtime.h>

@implementation MJPerson


void c_other(id self, SEL _cmd)
{
    NSLog(@"c_other - %@ - %@", self, NSStringFromSelector(_cmd));
}
//类方法的动态方法解析
+ (BOOL)resolveClassMethod:(SEL)sel
{
    if (sel == @selector(test)) {
        // 第一个参数是object_getClass(self)
        class_addMethod(object_getClass(self), sel, (IMP)c_other, "v16@0:8");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

//实例的动态方法解析
//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//    if (sel == @selector(test)) {
//        // 动态添加test方法的实现
//        class_addMethod(self, sel, (IMP)c_other, "v16@0:8");
//
//        // 返回YES代表有动态添加方法
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}

- (void)other
{
    NSLog(@"%s", __func__);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(test)) {
        // 获取其他方法
        Method method = class_getInstanceMethod(self, @selector(other));

        // 动态添加test方法的实现
        class_addMethod(self, sel,
                        method_getImplementation(method),//方法实现
                        method_getTypeEncoding(method));//方法编码

        // 返回YES代表有动态添加方法
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

// typedef struct objc_method *Method;
// struct objc_method == struct method_t
//        struct method_t *otherMethod = (struct method_t *)class_getInstanceMethod(self, @selector(other));

//struct method_t {
//    SEL sel;
//    char *types;
//    IMP imp;
//};
//
////
//+ (BOOL)resolveInstanceMethod:(SEL)sel
//{
//    if (sel == @selector(test)) {
//        // 获取其他方法
//        struct method_t *method = (struct method_t *)class_getInstanceMethod(self, @selector(other));
//
//        // 动态添加test方法的实现
//        class_addMethod(self, sel, method->imp, method->types);
//
//        // 返回YES代表有动态添加方法
//        return YES;
//    }
//    return [super resolveInstanceMethod:sel];
//}

@end
