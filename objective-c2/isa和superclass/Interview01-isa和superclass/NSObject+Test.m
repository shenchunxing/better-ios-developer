//
//  NSObject+Test.m
//  Interview02-isa和superclass
//
//  Created by MJ Lee on 2018/4/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "NSObject+Test.h"

@implementation NSObject (Test)

+ (void)test
{
    NSLog(@"+[NSObject test] - %p", self); //self表示当前调用对象
}

- (void)test
{
    NSLog(@"-[NSObject test] - %p", self);
}

@end
