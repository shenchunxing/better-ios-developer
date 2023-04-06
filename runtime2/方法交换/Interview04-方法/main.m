//
//  main.m
//  Interview04-方法
//
//  Created by MJ Lee on 2018/5/29.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"
#import <objc/runtime.h>

void test();

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        
        Method runMethod = class_getInstanceMethod([MJPerson class], @selector(run));
        Method testMethod = class_getInstanceMethod([MJPerson class], @selector(test));
        method_exchangeImplementations(runMethod, testMethod);

        //方法交换
        [person run];
        
        //方法替换
        test();
    }
    return 0;
}

void myrun()
{
    NSLog(@"---myrun");
}

void test()
{
    MJPerson *person = [[MJPerson alloc] init];
    
    //方法替换
    class_replaceMethod([MJPerson class], @selector(play), (IMP)myrun, "v");
    
    //带回调的方法替换
    class_replaceMethod([MJPerson class], @selector(run), imp_implementationWithBlock(^{
        NSLog(@"123123");
    }), "v");
    
    
    [person play];
    [person run];
}
