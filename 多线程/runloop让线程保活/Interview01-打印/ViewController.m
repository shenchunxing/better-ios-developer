//
//  ViewController.m
//  Interview01-打印
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
    
    [self test2];
}

//面试题1：
//1 3 2
- (void)test2
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_async(queue, ^{
        NSLog(@"1");
        // 这句代码的本质是往Runloop中添加定时器,子线程必须开启runloop，才会调用test方法
        //这里已经创建了runloop，且已经添加了timer，但是没有执行（开启）runloop
        [self performSelector:@selector(test) withObject:nil afterDelay:.0];
        NSLog(@"3");
        
        //        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        //执行runloop
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//        [[NSRunLoop currentRunLoop] run];
    });
}

- (void)test
{
    NSLog(@"2");
}

//面试题2：
//1 2
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"1");
        
        //如果这里不保活thread，thread就销毁了。
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }];
    [thread start];
    
    //thread退出的话，执行会崩溃
    [self performSelector:@selector(test) onThread:thread withObject:nil waitUntilDone:YES];
}


@end
