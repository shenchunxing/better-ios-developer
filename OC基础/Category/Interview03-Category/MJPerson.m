//
//  MJPerson.m
//  Interview03-Category
//
//  Created by MJ Lee on 2018/5/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

// class extension (匿名分类\类扩展)
@interface MJPerson()
{
    int _abc;
}
@property (nonatomic, assign) int age;

- (void)abc;
@end

@implementation MJPerson

- (void)abc
{
    
}

- (void)run
{
    NSLog(@"MJPerson - run");
}

+ (void)run2
{
    
}

@end
