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
        MJPerson *p = [[MJPerson alloc] init];
        
        [p array_strong_Test];
        
        //传入的是可变的,用strong修饰,并不会崩溃
        p.data = [NSMutableArray array];
        [p.data addObject:@"jack"];
        [p.data addObject:@"rose"];
        
        //传入的是可变的,用copy修饰,自动变成了不可变,会崩溃
        p.array = [NSMutableArray array];
        [p.array addObject:@"jack"];
        [p.array addObject:@"rose"];
        
        [p release];
    }
    return 0;
}
