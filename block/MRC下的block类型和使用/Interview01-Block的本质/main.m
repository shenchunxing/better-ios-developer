//
//  main.m
//  Interview01-Block的本质
//
//  Created by MJ Lee on 2018/5/10.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

/*
 一切以运行时的结果为准
 
 clang c++

 
 llvm x.0 中间文件
 */
void (^block)(void);
void (^block_no_copy)(void);
//block被copy
void block_copyedTest()
{
    
    // NSStackBlock
    int age = 10;
    block = [^{ //MRC下block变量不会强引用该block对象,block离开test2作用域就销毁了
        NSLog(@"block---------%d", age); //不copy会访问混乱
    } copy];
    NSLog(@"block类型：%@",[block class]); //MRC下,必须copy,会变成mallocblock
    [block release];
}

//block不被copy
void block_no_copyedTest()
{
    
    // NSStackBlock
    int age = 30;
    block_no_copy = ^{ //MRC下block_no_copy变量不会强引用该block对象,block_no_copy离开test2作用域就销毁了
        NSLog(@"block_no_copy---------%d", age); //不copy会访问混乱
    };
    NSLog(@"block_no_copy类型：%@",[block_no_copy class]); //MRC下,不copy，仍然是NSStackBlock
    [block_no_copy release];//这里block_no_copy因为没有强引用，直接被释放了，导致后续使用会数据错乱
}

//block类型
void block_type()
{
    // Global：没有访问auto变量
    void (^block1)(void) = ^{
        NSLog(@"block1---------");
    };
    
    // Stack：访问了auto变量
    int age = 10;
    void (^block2)(void) = ^{
        NSLog(@"block2---------%d", age);
    };
    NSLog(@"%p", [block2 copy]);//arc会自动copy,mrc需要手动，在堆上
    
    NSLog(@"全局:%@ ,不copy在栈:%@ ,copy后在堆:%@", [block1 class],  [block2 class] ,[[block2 copy] class]);
}

int age = 10;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int a = 10;
        
        NSLog(@"代码区：%p", __func__);
        NSLog(@"数据段：age %p", &age);
        NSLog(@"栈：a %p", &a);
        NSLog(@"堆：obj = %p", [[NSObject alloc] init]);
        NSLog(@"数据段：class %p", [MJPerson class]);
        NSLog(@"------------------");
        
        
        block_type(); //block类型
        
        block_copyedTest();//mrc下copy了block
        block();
        
        NSLog(@"------------------");
        
        block_no_copyedTest();//mrc下不copy block
        block_no_copy();
    }
    return 0;
}
