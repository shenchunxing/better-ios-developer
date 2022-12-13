//
//  main.m
//  Interview01-Block的本质
//
//  Created by MJ Lee on 2018/5/10.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

void test()
{
    // __NSGlobalBlock__ : __NSGlobalBlock : NSBlock : NSObject
    void (^block)(void) = ^{
        NSLog(@"Hello");
    };
    
    NSLog(@"%@", [block class]);//__NSGlobalBlock__
    NSLog(@"%@", [[block class] superclass]);//NSBlock
    NSLog(@"%@", [[[block class] superclass] superclass]);//NSObject
    NSLog(@"%@", [[[[block class] superclass] superclass] superclass]);//null
}


/*
 一切以运行时的结果为准：clang编译后的c++文件并不是最终的
 
 clang c++

 
 llvm x.0 中间文件
 */

int age = 20;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int a = 10;
        
        void (^block1)(void) = ^{ //没有访问auto变量，__NSGlobalBlock__，存放在全局区（数据段）
            NSLog(@"Hello");
        };
        
        int age = 10;
        //被block2变量强引用着，block在堆上
        void (^block2)(void) = ^{ //访问了自动变量，__NSMallocBlock__，存放在堆
            NSLog(@"Hello - %d", age);
        };
    
        //__NSGlobalBlock__ __NSMallocBlock__
        NSLog(@"%@ %@", [block1 class], [block2 class]);
        
        
        
        
        //访问了auto变量，但是没有被强引用，__NSStackBlock__（存放在栈）
        NSLog(@"%@",[^{
            NSLog(@"%d", age);
        } class]);
        
        //没有被强引用，还是__NSStackBlock__
        __block int height = 10;
        NSLog(@"%@",[^{
            height = 20;
            NSLog(@"%d", height);
        } class]);
        
        NSLog(@"-------------");
        test();
    }
    return 0;
}


