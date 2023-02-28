//
//  main.m
//  Interview01-消息转发
//
//  Created by MJ Lee on 2018/5/26.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        person.age = 20;
        person.height = 40;
        
        NSLog(@"age = %d - height = %f", person.age,person.height);
    }
    return 0;
}
