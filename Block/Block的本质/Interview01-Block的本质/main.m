//
//  main.m
//  Interview01-Block的本质
//
//  Created by MJ Lee on 2018/5/10.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

int age_ = 10;
static int height_ = 20;

void (^block)(void);

void test()
{
    int age = 10; // auto：自动变量，离开作用域就销毁，值传递
    static int height = 10; // 指针传递
    
    block = ^{
        // age的值捕获进来（capture）
        NSLog(@"age is %d, height is %d", age, height); //age is 10, height is 20
    };
    
    age = 20;
    height = 20;
}

void test2()
{
    block = ^{
        NSLog(@"age is %d, height is %d", age_, height_); //age is 20, height is 30  全局变量不需要捕获，谁都可以访问
    };
    
    age_ = 20;
    height_ = 30;
    block();
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        test();
        block();
        test2();
        
        void (^block1)(int, int) = ^(int a, int b){
            NSLog(@"Hello, World! - %d %d", a, b);
        };

        block1(10, 20);
        
        void (^block2)(void) = ^{
            NSLog(@"Hello, World!");
        };

        block2();// 调用block->FuncPtr
    }
    return 0;
}
