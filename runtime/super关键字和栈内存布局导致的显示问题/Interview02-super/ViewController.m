//
//  ViewController.m
//  Interview02-super
//
//  Created by MJ Lee on 2018/5/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJPerson.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

/*
 1.print为什么能够调用成功？
 
 2.为什么self.name变成了ViewController等其他内容
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //调用[super viewDidLoad]，存在隐藏的struct，里面是self和[UIViewController class]两个成员，也是在栈上的
//    c++编译
//    struct abc = {
//        self,
//        [UIViewController class]
//    };
//    objc_msgSendSuper(abc, sel_registerName("viewDidLoad"));
    
    
    
    //窥探objc_msgSendSuper源码发现内部调用的是objc_msgSendSuper2(abc2, sel_registerName("viewDidLoad"));
    //    struct abc2 = {
    //        self,
    //        [ViewController class] -> superclass,从父类[UIViewController class]中搜索方法
    //    };
    //逻辑和c++变异后的objc_msgSendSuper其实是一样的。
    
    
//    NSObject *obj2 = [[NSObject alloc] init];
//
//    NSString *test = @"123";
    
    //viewDidLoad:栈内存分布从高到低：[ViewController class]、self 、 cls 、 obj。这3个栈地址是紧紧挨着的，
    //cls指向全局区的MJPerson类对象
    //obj指向cls
    //obj->cls->[MJPeron class]对象,有这个关系存在，obj通过cls可以找到类对象，说明可以找到print方法，编译没问题
    //pirint里面会使用name成员，name是isa内存偏移8个字节的地址，obj指向的前8个字节就是cls，因为栈内存是挨着的。接下来的内存就是self

    id cls = [MJPerson class];
    void *obj = &cls;
    [(__bridge id)obj print];
    
    NSLog(@"self = %p",&self);
    NSLog(@"self = %p",&self);
    NSLog(@"cls = %p",&cls);
    NSLog(@"obj = %p",&obj);//3个栈上的地址从大到小
    
    
    //p/x obj 打印obj的内存地址，是MJPerson实例0x000000016cf7f2d8
    //x 0x000000016cf7f2d8 ,打印从0x000000016cf7f2d8开始的内存情况
    //x/4g 0x000000016cf7f2d8 得到4个内存地址 ： MJPerson类对象、ViewController(也就是self)、【ViewController class】
    //所以[super viewDidLoad]内部调用的其实是objc_msgSendSuper2
    
    //person指向实例，实例里面有isa和name。isa指向MJPerson类对象
    //因为isa是实例的第一个成员，所以实例的地址就是isa的地址，因此，person -> isa -> [MJPeron class]
//    MJPerson *person = [[MJPerson alloc] init];
//    NSLog(@"%p %p",obj,object_getClass(person));
//    [person print];
    
//    long long *p = (long long *)obj;
//    NSLog(@"%p %p", *(p+2), [ViewController class]);
    
//    struct MJPerson_IMPL
//    {
//        Class isa;
//        NSString *_name;
//    };
    
}


@end
