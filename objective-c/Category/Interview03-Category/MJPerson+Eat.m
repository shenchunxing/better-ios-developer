//
//  MJPerson+Eat.m
//  Interview03-Category
//
//  Created by MJ Lee on 2018/5/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson+Eat.h"

@implementation MJPerson (Eat)
@dynamic weight,height;

- (void)run
{
    NSLog(@"MJPerson (Eat) - run");
}

- (void)eat
{
    NSLog(@"eat");
}

- (void)eat1
{
    NSLog(@"eat1");
}

+ (void)eat2
{
    
}

+ (void)eat3
{
    
}

- (int)weight {
    return 10;
}

- (double)height {
    return 20.0;
}

- (void)setHeight:(double)height {
    
}

- (void)setWeight:(int)weight {
    
}

@end
