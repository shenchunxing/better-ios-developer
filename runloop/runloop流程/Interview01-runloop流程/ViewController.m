//
//  ViewController.m
//  Interview01-runloop流程
//
//  Created by MJ Lee on 2018/6/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"123");
//    }];
    
    //gcd一般的api都和runloop无关，但是这种回到主线程的api和runloop有关
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 处理一些子线程的逻辑
        
        // 回到主线程去刷新UI界面
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"11111111111");
        });
    });
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 函数调用栈，查看是从cfrunlooprunspecific开始的，查看源码
    NSLog(@"111111");
}


@end
