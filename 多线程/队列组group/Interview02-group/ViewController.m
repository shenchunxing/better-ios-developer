//
//  ViewController.m
//  Interview02-group
//
//  Created by MJ Lee on 2018/6/7.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("my_queue", DISPATCH_QUEUE_CONCURRENT);
    
    // 添加异步任务
    // 任务1 2交替执行
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"任务1-%@-%d", [NSThread currentThread],i);
        }
    });
    
    dispatch_group_async(group, queue, ^{
        for (int i = 6; i < 10; i++) {
            NSLog(@"任务2-%@-%d", [NSThread currentThread],i);
        }
    });
    
    // 等前面的任务执行完毕后，会自动执行这个任务
    //回到主队列
//    dispatch_group_notify(group, queue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            for (int i = 0; i < 5; i++) {
//                NSLog(@"任务3-%@", [NSThread currentThread]);
//            }
//        });
//    });
    
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        for (int i = 0; i < 5; i++) {
//            NSLog(@"任务3-%@", [NSThread currentThread]);
//        }
//    });
    
    
    //任务3 4交替执行
    dispatch_group_notify(group, queue, ^{
        for (int i = 100; i < 105; i++) {
            NSLog(@"任务3-%@-%d", [NSThread currentThread],i);
        }
    });
    
    dispatch_group_notify(group, queue, ^{
        for (int i = 200; i < 205; i++) {
            NSLog(@"任务4-%@-%d", [NSThread currentThread],i);
        }
    });
    
    
}


@end
