//
//  MJPerson.m
//  Interview04-copy
//
//  Created by MJ Lee on 2018/6/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson

//- (void)setData:(NSArray *)data
//{
//    if (_data != data) {
//        [_data release];
//        _data = [data copy]; //如果修饰data的是copy，而传入的是可变数组，这里会强制变成不可变
//    }
//}

- (void)dealloc
{
    self.data = nil;
    
    [super dealloc];
}

@end
