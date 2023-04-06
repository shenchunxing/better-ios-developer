//
//  main.m
//  Interview01-super
//
//  Created by MJ Lee on 2018/5/29.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        [person run];
    }
    return 0;
}
