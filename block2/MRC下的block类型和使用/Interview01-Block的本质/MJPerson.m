//
//  MJPerson.m
//  Interview01-Block的本质
//
//  Created by MJ Lee on 2018/5/10.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson

int age_ = 10;

- (void)test
{
    void (^block)(void) = ^{
        NSLog(@"-------%d", [self name]);
    };
    block();
}

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        self.name = name;
    }
    return self;
}

@end
