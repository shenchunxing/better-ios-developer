//
//  MJPerson.m
//  Interview02-runtime应用
//
//  Created by MJ Lee on 2018/5/29.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson
- (void)run
{
    NSLog(@"%s", __func__);
}

- (void)test
{
    NSLog(@"%s", __func__);
}

- (void)play
{
    NSLog(@"%s", __func__);
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        
    }
    return self;
}
@end
