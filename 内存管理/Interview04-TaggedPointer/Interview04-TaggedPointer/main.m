//
//  main.m
//  Interview04-TaggedPointer
//
//  Created by MJ Lee on 2018/6/21.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

BOOL isTaggedPointer(id pointer)
{
    return (long)(__bridge void *)pointer & 1; //mac平台：指针的最低有效位是1 ios平台：指针最高有效位是1
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        NSNumber *number = [NSNumber numberWithInt:10];
//        NSNumber *number = @(10);
        
        NSNumber *number1 = @4;//直接存储在栈区指针当中
        NSNumber *number2 = @5;
        NSNumber *number3 = @(0xFFFFFFFFFFFFFFF);
        
        number1.intValue; //这种还是会执行objc_msgSend，内部做了优化，没有堆空间，没有对象。直接从直接里面读取
        
        NSLog(@"%d %d %d", isTaggedPointer(number1), isTaggedPointer(number2), isTaggedPointer(number3));
        NSLog(@"%p %p %p", number1, number2, number3);
    }
    return 0;
}
