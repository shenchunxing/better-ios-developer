//
//  ViewController.m
//  Interview04-Class地址
//
//  Created by MJ Lee on 2018/5/17.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "MJPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //类对象或者元类对象地址，最后3位都是0，从isa底层的数据结构可以看出，isa & mask 得到class的33位地址值 + 后面的3位000组成了一个完整的class地址
    
    MJPerson *obj = [[MJPerson alloc] init];
    int a = 12;
    NSLog(@"self在栈上：%p ，obj指针在栈上：%p，obj对象在堆上：%p，a在栈上 = %p",&self,&obj,obj,&a);//在栈空间，地址和self紧挨着
    
    NSLog(@"全局区-ViewController类对象地址:%p", [ViewController class]); //类地址
    NSLog(@"全局区-ViewController元类地址：%p", object_getClass([ViewController class]));//元类地址
    NSLog(@"全局区-MJPerson类地址：%p", [MJPerson class]);//类地址
    NSLog(@"全局区-MJPerson元类地址：%p", object_getClass([MJPerson class]));//元类地址
    
    
}

@end
