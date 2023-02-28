//
//  ViewController.m
//  Interview18-autorelease时机
//
//  Created by MJ Lee on 2018/7/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 这个Person什么时候调用release，是由RunLoop来控制的
    // 它可能是在某次RunLoop循环中，RunLoop休眠之前调用了release
//    MJPerson *person = [[[MJPerson alloc] init] autorelease];
    
    MJPerson *person = [[MJPerson alloc] init];
    
    NSLog(@"%s", __func__);
    
    //方法里面的局部对象如果是autorleasepool管理的对象，是在某次runloop结束释放，如果是arc管理的，则在方法结束就释放了。
}

- (void)viewWillAppear:(BOOL)animated //viewdidload和willappear处于同一个runloop循环  和viewDidAppear不是处于同一个循环
{
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __func__);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"%s", __func__);
}



/*
 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
 kCFRunLoopEntry = (1UL << 0),  1
 kCFRunLoopBeforeTimers = (1UL << 1), 2
 kCFRunLoopBeforeSources = (1UL << 2), 4
 kCFRunLoopBeforeWaiting = (1UL << 5), 32
 kCFRunLoopAfterWaiting = (1UL << 6), 64
 kCFRunLoopExit = (1UL << 7), 128
 kCFRunLoopAllActivities = 0x0FFFFFFFU
 };
 */

#pragma mark - runloop启动的时候会注册2个观察者：第一个观察者的回调_wrapRunLoopWithAutoreleasePoolHandler、第二个观察者的回调_wrapRunLoopWithAutoreleasePoolHandler

/*
 activities = 0x1 ：等于1，因此监听的是kCFRunLoopEntry  push操作
 
 <CFRunLoopObserver 0x60000013f220 [0x1031c8c80]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x103376df2), context = <CFArray 0x60000025aa00 [0x1031c8c80]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7fd0bf802048>\n)}}
 
 
 activities = 0xa0：等于160 = 128 + 32，监听的是kCFRunLoopBeforeWaiting | kCFRunLoopExit
 kCFRunLoopBeforeWaiting | kCFRunLoopExit
 kCFRunLoopBeforeWaiting：先 pop、再push
 kCFRunLoopExit： pop
 
 <CFRunLoopObserver 0x60000013f0e0 [0x1031c8c80]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x103376df2), context = <CFArray 0x60000025aa00 [0x1031c8c80]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7fd0bf802048>\n)}}
 */

@end
