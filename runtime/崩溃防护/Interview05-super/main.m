//
//  main.m
//  Interview05-super
//
//  Created by MJ Lee on 2018/5/26.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

//void test(SEL selector)
//{
//    MJPerson *person = [[MJPerson alloc] init];
//    [person performSelector:selector];
//}

//void test(NSMutableArray *array)
//{
//    [array addObject:@"234"];
//}

// 降低unrecognized selector崩溃率

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        [person run];
        [person test];
        [person other];
    }
    return 0;
}
