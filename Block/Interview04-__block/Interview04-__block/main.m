//
//  main.m
//  Interview04-__block
//
//  Created by MJ Lee on 2018/5/12.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MJBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block __weak int age = 10;
        
        MJBlock block1 = ^{
            __strong int myage = age;
            age = 20;
            NSLog(@"age is %d", age);
        };
        
        MJBlock block2 = ^{
            age = 30;
            NSLog(@"age is %d", age);
        };
        
        block1();
        block2();
        
    }
    return 0;
}
