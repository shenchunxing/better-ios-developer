//
//  main.m
//  Interview02-cache
//
//  Created by MJ Lee on 2018/5/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        
        [person personTest]; //方法缓存：存放到散列表：key：@selector(personTest)        value:personTest的函数地址
        [person personTest2];//哈希表扩容，会清空缓存。
        [person personTest3];//
        
        NSLog(@"%p", @selector(personTest));
        
        [person personTest]; //下次调用，直接从散列表根据key获取，
        [person personTest2];
        [person personTest3];
    }
    return 0;
}
