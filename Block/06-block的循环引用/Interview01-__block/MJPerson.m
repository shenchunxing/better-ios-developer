//
//  MJPerson.m
//  Interview01-__block
//
//  Created by MJ Lee on 2018/5/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson
- (void)dealloc
{
//    [super dealloc];
    NSLog(@"%s", __func__);
}

- (void)test
{
//    __weak typeof(self) weakSelf = self;
//    self.block = ^{
//        NSLog(@"age is %d", weakSelf.age);
//    };
    
    
    __weak typeof(self) weakSelf = self;
    self.block = ^{
        __strong typeof(weakSelf) myself = weakSelf;
        
        NSLog(@"age is %d", myself->_age);
    };
    
//    __unsafe_unretained typeof(self) weakSelf = self;
//    self.block = ^{
//        NSLog(@"age is %d", weakSelf.age);
//    };
}
@end
