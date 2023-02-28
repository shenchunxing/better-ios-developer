//
//  main.m
//  Interview01-atomic
//
//  Created by MJ Lee on 2018/6/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *p = [[MJPerson alloc] init];
        
        
        for (int i = 0; i < 10; i++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                // 加锁
                p.data = [NSMutableArray array]; //data用atomic修饰，p.data = [NSMutableArray array] 是线程安全的
                // 解锁
            });
        }
        
        
        NSMutableArray *array = p.data; //getter是线程安全的
        //下面3句不是线程安全的。需要加锁
        // 加锁
        [array addObject:@"1"];
        [array addObject:@"2"];
        [array addObject:@"3"];
        // 解锁
    }
    return 0;
}
