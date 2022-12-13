//
//  MJPerson.m
//  Interview01-消息转发
//
//  Created by MJ Lee on 2018/5/26.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"
#import <objc/runtime.h>

@implementation MJPerson

// 提醒编译器不要自动生成setter和getter的实现、不要自动生成成员变量
@dynamic age;

void setAge(id self, SEL _cmd, int age)
{
    NSLog(@"age is %d", age);
}

//优先找对象方法,找不到找C方法
//- (void)setAge:(int)age {
//    NSLog(@"age is %d-------", age);
//}

int age(id self, SEL _cmd)
{
    return 120;
}

//- (int)age {
//    return 100;
//}

//动态方法解析:没有实现OC的setter和getter,则去实现C的setter和getter.如果没实现oc的,默认并不会直接就去执行C语言的方法,还是需要动态方法解析的
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(setAge:)) {
        class_addMethod(self, sel, (IMP)setAge, "v@:i");
        return YES;
    } else if (sel == @selector(age)) {
        class_addMethod(self, sel, (IMP)age, "i@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

//@synthesize 帮我们生成实例变量和getter、setter的实现，现在编译器已经做了这个，不需要写了
//@synthesize age = _age, height = _height;

//- (void)setAge:(int)age
//{
//    _age = age;
//}
//
//- (int)age
//{
//    return _age;
//}

@end
