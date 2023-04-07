//
//  MJDog.m
//  Interview01-内存管理
//
//  Created by MJ Lee on 2018/6/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJDog.h"

@implementation MJDog

- (void)run
{
    NSLog(@"%s", __func__);
}

- (void)dealloc
{
    [super dealloc];
    
    NSLog(@"%s", __func__);
}

@end
