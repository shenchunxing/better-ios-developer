//
//  ViewController.m
//  Interview05-TaggedPointer面试题
//
//  Created by MJ Lee on 2018/6/21.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSLock *lock; //方案2:加锁/解锁
//@property (strong, atomic) NSString *name;//方案1:atomic可以确保setter线程安全，可以解决崩溃问题
@end

@implementation ViewController

//arc本质实际是mrc，内存管理只对对象有用，taggerpoint不受内存管理
//- (void)setName:(NSString *)name
//{
//    if (_name != name) {
//        [_name release];//崩溃的原因是多个线程进行多次release导致
//        _name = [name retain];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lock = [[NSLock alloc] init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            // 加锁
            [self.lock lock];
            self.name = [NSString stringWithFormat:@"abcdefghijk"]; //报错坏内存访问,因为[_name release]被多次执行
            // 解锁
            [self.lock unlock];
        });
    }
    
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//
    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            self.name = [NSString stringWithFormat:@"abc"]; //taggedpointer
        });
    }
    
    NSString *str1 = [NSString stringWithFormat:@"abcdefghijk"];//堆
    NSString *str2 = [NSString stringWithFormat:@"123"];//常量字符串
    
    NSLog(@"%@ %@", [str1 class], [str2 class]);
    NSLog(@"%p", str2);
}


@end
