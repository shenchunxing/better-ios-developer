//
//  MJStudent.m
//  Interview05-super
//
//  Created by MJ Lee on 2018/5/26.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJStudent.h"
#import <objc/runtime.h>

@implementation MJStudent

/*
 [super message]的底层实现
 1.消息接收者仍然是子类对象
 2.直接去父类开始查找方法的实现
 */

struct objc_super {
    __unsafe_unretained _Nonnull id receiver; // 消息接收者
    __unsafe_unretained _Nonnull Class super_class; // 消息接收者的父类
};

- (void)run
{
    // super调用的receiver仍然是MJStudent对象
    [super run];
    
    //objc_super的第二个成员是super_class（消息接收者的父类），目的是从父类开始查找run方法，而不是从本类开始，如果从本类开始就是死循环了
//    struct objc_super arg = {self, [MJPerson class]};
//
//    objc_msgSendSuper(arg, @selector(run));
//
//
//    NSLog(@"MJStudet.......");
    
}

- (instancetype)init
{
    if (self = [super init]) {
        NSLog(@"[self class] = %@", [self class]); // MJStudent
        NSLog(@"[self superclass] = %@", [self superclass]); // MJPerson

        NSLog(@"--------------------------------");

        // objc_msgSendSuper({self, [MJPerson class]}, @selector(class));
        NSLog(@"[super class] = %@", [super class]); // MJStudent
        NSLog(@"[super superclass] = %@", [super superclass]); // MJPerson
    }
    return self;
}

@end

//class的底层实现
//@implementation NSObject
//
//- (Class)class
//{
//    return object_getClass(self);
//}
//
//superclass的底层实现
//- (Class)superclass
//{
//    return class_getSuperclass(object_getClass(self));
//}
//
//@end
