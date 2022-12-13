//
//  main.m
//  Interview01-block的copy
//
//  Created by MJ Lee on 2018/5/12.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MJBlock)(void);


//MJBlock myblock()
//{
//    return ^{
//        NSLog(@"---------");
//    };
//}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int age = 10;
        MJBlock block = ^{
            NSLog(@"---------%d", age);
        };
        
        NSLog(@"%@", [block class]);//__NSMallocBlock__
        
        
        
        
//        MJBlock block = myblock();
//        block();
//        NSLog(@"%@", [block class]);
    }
    return 0;
}
