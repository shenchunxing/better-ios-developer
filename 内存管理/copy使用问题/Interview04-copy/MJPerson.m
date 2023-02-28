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


//NSArray用strong修饰导致数组类型会变
- (void)array_strong_Test {
    NSArray *array = @[ @1, @2, @3, @4 ];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];

    self.array2 = mutableArray;//赋值操作，strong修饰的话会强引用，copy修饰的话就是copy，不会被引用
    [mutableArray removeAllObjects];;
    NSLog(@"self.array2 = %@",self.array2);//array2变成了空的可变数组
    
    [mutableArray addObjectsFromArray:array];
    self.array2 = [mutableArray copy];//array2变成不可变数组，里面有[ @1, @2, @3, @4 ]
    [mutableArray removeAllObjects];;
    NSLog(@"self.array2 = %@",self.array2);//array2变成不可变数组，里面有[ @1, @2, @3, @4 ]
}

- (void)dealloc
{
    self.data = nil;
    
    [super dealloc];
}

@end
