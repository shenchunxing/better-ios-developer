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
    NSLog(@"%p %p %p",&self,&obj,&a);//在栈空间，地址和self紧挨着
    
    NSLog(@"%p", [ViewController class]); //类地址
    NSLog(@"%p", object_getClass([ViewController class]));//元类地址
    NSLog(@"%p", [MJPerson class]);//类地址
    NSLog(@"%p", object_getClass([MJPerson class]));//元类地址
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
