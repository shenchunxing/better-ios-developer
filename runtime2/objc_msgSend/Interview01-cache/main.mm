//
//  main.m
//  Interview01-cache
//
//  Created by MJ Lee on 2018/5/22.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJGoodStudent.h"
#import "MJClassInfo.h"
#import <objc/runtime.h>

//底层是汇编实现的：objc-msg-arm64文件
void objc_msgSend(id receiver, SEL selector)
{
    if (receiver == nil) return;
    
    // 查找缓存
    
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJGoodStudent *gs = [[MJGoodStudent alloc] init];
        [gs personTest];
        
        MJPerson *person = [[MJPerson alloc] init];
        [person personTest];
        // objc_msgSend(person, @selector(personTest));
        // 消息接收者（receiver）：person
        // 消息名称：personTest
        
        [MJPerson initialize];
        // objc_msgSend([MJPerson class], @selector(initialize));
        // 消息接收者（receiver）：[MJPerson class]
        // 消息名称：initialize
        
        // OC的方法调用：消息机制，给方法调用者发送消息
        
        // objc_msgSend如果找不到合适的方法进行调用，会报错unrecognized selector sent to instance
    }
    return 0;
}
