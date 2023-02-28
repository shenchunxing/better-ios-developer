//
//  main.m
//  Interview03-内存布局
//
//  Created by MJ Lee on 2018/6/21.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int a = 10; //已初始化数据
int b;//未初始化数据

int main(int argc, char * argv[]) {
    @autoreleasepool {
        static int c = 20; //已初始化静态变量
        
        static int d;//未初始化静态变量
        
        int e; //未初始化局部变量，在栈上
        int f = 20;//已初始化局部变量，在栈上

        NSString *str = @"123";//常量区
        
        NSObject *obj = [[NSObject alloc] init];//堆
        
        NSLog(@"全局区: a = %p , b = %p ,c = %p , d = %p,str = %p",&a,&b,&c,&d,str);
        NSLog(@"栈区: e = %p , f = %p , &obj = %p",&e,&f,&obj);
        NSLog(@"堆区: obj = %p",obj);
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

//地址从低到高
/*
 数据段：
     字符串常量
     str=0x10dfa0068
     
     已初始化的全局变量、静态变量
     &a =0x10dfa0db8
     &c =0x10dfa0dbc
     
     未初始化的全局变量、静态变量
     &d =0x10dfa0e80
     &b =0x10dfa0e84
 
 堆：
 obj=0x608000012210
 
 栈：
 &f =0x7ffee1c60fe0
 &e =0x7ffee1c60fe4
 */
