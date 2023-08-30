//
//  main.m
//  Interview01-Block的本质
//
//  Created by MJ Lee on 2018/5/10.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 一切以运行时的结果为准：clang编译后的c++文件并不是最终的
 
 clang c++

 
 llvm x.0 中间文件
 */

int age = 20;
typedef void(^CSBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int a = 10;
        
        void (^block1)(void) = ^{ //没有访问auto变量，__NSGlobalBlock__，存放在全局区（数据段）
            NSLog(@"Hello");
        };
        
        int age = 10;
        //被block2变量强引用着，在arc下会被拷贝到堆上
        void (^block2)(void) = ^{ //访问了自动变量，__NSMallocBlock__，存放在堆
            NSLog(@"Hello - %d", age);
        };
        NSLog(@"%@ %@", [block1 class], [block2 class]); //__NSGlobalBlock__ 、__NSMallocBlock__
        
        NSLog(@"-------------0");
        
        
        //访问了auto变量，但是没有被强引用，__NSStackBlock__（存放在栈）
        NSLog(@"%@",[^{
            NSLog(@"%d", age);
        } class]); //__NSStackBlock__
        
        //没有被强引用，还是__NSStackBlock__，虽然捕获了auto变量，但是没有被指针强引用着，还是__NSStackBlock__
        __block int height = 10;
        NSLog(@"%@",[^{
            height = 20;
            NSLog(@"%d", height);
        } class]);//__NSStackBlock__
        
        NSLog(@"-------------1");
        
        
        //block的继承体系
        // __NSGlobalBlock__ : __NSGlobalBlock : NSBlock : NSObject
        void (^block3)(void) = ^{
            NSLog(@"Hello");
        };
        
        NSLog(@"%@", [block3 class]);//__NSGlobalBlock__
        NSLog(@"%@", [[block3 class] superclass]);//NSBlock
        NSLog(@"%@", [[[block3 class] superclass] superclass]);//NSObject
        NSLog(@"%@", [[[[block3 class] superclass] superclass] superclass]);//null
        NSLog(@"-------------2");
    }
    return 0;
}


/**
 会自动copy到堆的四种情况：
 */
void autoCopy() {
    //1.强指针
    void (^block)(void) = ^{
            NSLog(@"Hello");
        };

    //3.block作为Cocoa API中方法名含有usingBlock的方法参数时
    NSArray *array = [NSArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
    }];

    //4.block作为GCD API的方法参数时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
}

//2.返回blcok
CSBlock myBlock() {
    int age = 10;
    return ^{
        NSLog(@"age = %d",age);
    };
};
