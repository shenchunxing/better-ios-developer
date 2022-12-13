//
//  main.m
//  Interview01-Block的本质
//
//  Created by MJ Lee on 2018/5/10.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

int global_age_ = 10;
static int global_height_ = 10;

void (^block)(void);

void test()
{
    auto int a = 10;
    static int b = 10;
    block = ^{
        NSLog(@"age is %d, height is %d", a, b);//age is 10, height is 40
    };
    a = 30;
    b = 40;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        test();
        block();
        
        void (^block1)(void) = ^{
            NSLog(@"age is %d, height is %d", global_age_, global_height_); //age is 20, height is 20 全局变量不需要捕获，因为本身就可以访问
        };

        global_age_ = 20;
        global_height_ = 20;

        block1();
    }
    return 0;
}
