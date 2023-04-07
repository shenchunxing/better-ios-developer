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

void value_pass(){
    int age = 10; // auto：自动变量，离开作用域就销毁，值传递
    block = ^{
        // age的值捕获进来（capture）
        NSLog(@"age is %d", age); //age is 10
    };
    age = 20;
}

void point_pass() {
    static int height = 10;
    block = ^{
        NSLog(@"height is %d", height); //height is 20
    };
    height = 20;
}

void global_pass()
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
        value_pass(); //值传递
        block();
        point_pass();//指针传递
        block();
        
        global_pass();//全局变量传递，不需要捕获
        
        NSLog(@"----------");
        
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
