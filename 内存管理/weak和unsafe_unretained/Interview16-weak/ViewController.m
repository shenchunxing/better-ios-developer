//
//  ViewController.m
//  Interview16-weak
//
//  Created by MJ Lee on 2018/7/1.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ARC是LLVM编译器和Runtime系统相互协作的一个结果
    
    __strong MJPerson *person1;
    __weak MJPerson *person2;
    __unsafe_unretained MJPerson *person3;
    
    
    NSLog(@"111");
    
    {
        MJPerson *person = [[MJPerson alloc] init];
        
        person3 = person;//
        person2 = person;//__weak自动置为null
//        person1 = person;//离开作用域销毁，person不会被销毁，被强引用者
        int a;
        //&person,打印的是变量的地址
        //person 打印的变量指向的地址,也就是对象的地址
        NSLog(@"person对象 - %p ，person变量 - %p ，a变量 - %p",person , &person, &a);
        
        
        //__unsafe_unretained需要手动置为nil,否则坏内存访问崩溃
        person3 = nil;
    }
    
    NSLog(@"222 - %@", person2);
    NSLog(@"222 - %@", person3);
}


@end
