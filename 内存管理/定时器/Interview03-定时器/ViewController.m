//
//  ViewController.m
//  Interview03-定时器
//
//  Created by MJ Lee on 2018/6/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJProxy.h"
#import "MJProxy2.h"
@interface ViewController ()
@property (strong, nonatomic) CADisplayLink *link;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *timer1;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self linkMedthod];//CADisplayLink设置消息转发可以解除循环引用
//    [self timerMethod];//定时器内部还是强引用，无法解除
//    [self timerMethod2];//NSTimer设置消息转发可以解除循环引用
//    [self blockMethod];//block设置弱引用，解除3者之间的循环
    [self proxy2Medthod];//NSTimer设置NSProxy可以解除循环引用

}

- (void)linkMedthod {
    // 保证调用频率和屏幕的刷帧频率一致，60FPS,1秒钟调用60次
    //      对象
    //timer      MJProxy
    //MJProxy对self是弱引用，可以解除循环引用
    self.link = [CADisplayLink displayLinkWithTarget:[MJProxy proxyWithTarget:self] selector:@selector(linkTest)];
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void)timerMethod {
    //无法解决循环引用，target内部会赋值给里面的强引用属性，还是强引用
    __weak typeof(self) weakSelf = self;
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:1.0 target:weakSelf selector:@selector(timerTest) userInfo:nil repeats:YES];
}

- (void)timerMethod2 {
    //-[MJProxy timerTest]: unrecognized selector sent to instance 0x600003088030
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[MJProxy proxyWithTarget:weakSelf] selector:@selector(timerTest) userInfo:nil repeats:YES];
        
}

- (void)blockMethod {
    //一种可以解决的方案
    __weak typeof(self) weakSelf = self;
    // self对NSTimer对象有强引用
    // NSTimer对Block有强引用
    // Block对self有强引用
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf timerTest];
    }];
}

- (void)proxy2Medthod {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:[MJProxy2 proxyWithTarget:self] selector:@selector(timerTest) userInfo:nil repeats:YES];
}

- (void)timerTest
{
    NSLog(@"%s", __func__);
}

- (void)linkTest
{
    NSLog(@"%s", __func__);
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self.link invalidate];
    [self.timer invalidate];
}

@end
