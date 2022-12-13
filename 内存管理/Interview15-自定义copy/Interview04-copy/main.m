//
//  main.m
//  Interview04-copy
//
//  Created by MJ Lee on 2018/6/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *p1 = [[MJPerson alloc] init];
        p1.age = 20;
        p1.weight = 50;
        
        //arm64架构，引用计数已经存储在isa指针里面了。如果不够存储，就存储到sidetable这个数据结构里面，里面是一个哈希表

        MJPerson *p2 = [p1 copy];
//        p2.age = 30;

        //自己实现了copy，生成2个对象
        NSLog(@"%@ - %p", p1,&p1);
        NSLog(@"%@ - %p", p2,&p2);

        [p2 release];
        [p1 release];
        
        //        NSString *str;
        //        [str copy];
        //        [str mutableCopy];
        
        //        NSArray, NSMutableArray;
        //        NSDictionary, NSMutableDictionary;
        //        NSString, NSMutableString;
        //        NSData, NSMutableData;
        //        NSSet, NSMutableSet;
    }
    return 0;
}
