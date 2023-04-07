//
//  MJPerson.m
//  Interview01-KVC
//
//  Created by MJ Lee on 2018/5/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson
// MARK: - KVC底层原理
/**
 setValue:forKey:的实现

 查找setKey:方法和_setKey:方法，只要找到就直接传递参数，调用方法；
 如果没有找到setKey:和_setKey:方法，查看accessInstanceVariablesDirectly方法的返回值，如果返回NO（不允许直接访问成员变量），调用setValue:forUndefineKey:并抛出异常NSUnknownKeyException；
 如果accessInstanceVariablesDirectly方法返回YES（可以访问其成员变量），就按照顺序依次查找 _key、_isKey、key、isKey 这四个成员变量，如果查找到了就直接赋值；如果没有查到，调用setValue:forUndefineKey:并抛出异常NSUnknownKeyException。
 */

/**
 valueForKey:的实现

 按照getKey，key，isKey的顺序查找方法，只要找到就直接调用；
 如果没有找到，accessInstanceVariablesDirectly返回YES（可以访问其成员变量），按照顺序依次查找_key、_isKey、key、isKey 这四个成员变量，找到就取值；如果没有找到成员变量，调用valueforUndefineKey并抛出异常NSUnknownKeyException。
 accessInstanceVariablesDirectly返回NO（不允许直接访问成员变量），那么会调用valueforUndefineKey:方法，并抛出异常NSUnknownKeyException；
 */

//getter方法按照- (int)getAge  - (int)age  - (int)isAge  - (int)_age的顺序查找实现
//- (int)getAge
//{
//    return 11;
//}

//- (int)age
//{
//    return 12;
//}

//- (int)isAge
//{
//    return 13;
//}

- (int)_age
{
    return 14;
}

//- (void)setAge:(int)age
//{
//    NSLog(@"setAge: - %d", age);
//}

//- (void)_setAge:(int)age
//{
//    NSLog(@"_setAge: - %d", age);
//}

- (void)willChangeValueForKey:(NSString *)key
{
    [super willChangeValueForKey:key];
    NSLog(@"willChangeValueForKey - %@", key);
}

- (void)didChangeValueForKey:(NSString *)key
{
    NSLog(@"didChangeValueForKey - begin - %@", key);
    [super didChangeValueForKey:key];
    NSLog(@"didChangeValueForKey - end - %@", key);
}

 //是否接受成员变量作为直接返回对象，默认的返回值就是YES
+ (BOOL)accessInstanceVariablesDirectly
{
    return YES;
}

@end
