//
//  ViewController.m
//  Interview01
//
//  Created by MJ Lee on 2018/4/23.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJPerson.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (strong, nonatomic) MJPerson *person1;
@property (strong, nonatomic) MJPerson *person2;
@end

// 反编译工具 - Hopper

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.person1 = [[MJPerson alloc] init];
    self.person1.age = 1;
    
    self.person2 = [[MJPerson alloc] init];
    self.person2.age = 2;
    
    
    NSLog(@"person1添加KVO监听之前 - %@ %@",
          object_getClass(self.person1),
          object_getClass(self.person2));
    NSLog(@"person1添加KVO监听之前 - %p %p",
          [self.person1 methodForSelector:@selector(setAge:)],
          [self.person2 methodForSelector:@selector(setAge:)]);
    
    // 给person1对象添加KVO监听
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.person1 addObserver:self forKeyPath:@"age" options:options context:@"123"];
    
    NSLog(@"person1添加KVO监听之后 - %@ %@",
          object_getClass(self.person1),//类对象地址变了
          object_getClass(self.person2));
    NSLog(@"person1添加KVO监听之后 - %p %p",
          [self.person1 methodForSelector:@selector(setAge:)],//方法在类对象中，地址也变了
          [self.person2 methodForSelector:@selector(setAge:)]);


    NSLog(@"类对象 - %@ - %@ - %@ - %@",
          object_getClass(self.person1),  // self.person1.isa //NSKVONotifying_MJPerson
          object_getClass(self.person2), // self.person2.isa //MJPerson
          //注意：class被重写了，两者一样。目的是隐藏NSKVONotifying_MJPerson这个子类
    [self.person1 class],[self.person2 class]);
    
    NSLog(@"类对象地址 - %p %p",
          object_getClass(self.person1),  // self.person1.isa //NSKVONotifying_MJPerson
          object_getClass(self.person2)); // self.person2.isa //MJPerson

    NSLog(@"元类对象 - %@ %@",
          object_getClass(object_getClass(self.person1)), // self.person1.isa.isa //NSKVONotifying_MJPerson
          object_getClass(object_getClass(self.person2))); // self.person2.isa.isa //MJPerson
    
    NSLog(@"元类对象地址 - %p %p",
          object_getClass(object_getClass(self.person1)), // self.person1.isa.isa //NSKVONotifying_MJPerson
          object_getClass(object_getClass(self.person2))); // self.person2.isa.isa //MJPerson
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // NSKVONotifying_MJPerson是使用Runtime动态创建的一个类，是MJPerson的子类
    // self.person1.isa == NSKVONotifying_MJPerson
    [self.person1 setAge:21];
    
    // self.person2.isa = MJPerson
//    [self.person2 setAge:22];
}

- (void)dealloc {
    [self.person1 removeObserver:self forKeyPath:@"age"];
}

// 当监听对象的属性值发生改变时，就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

@end
