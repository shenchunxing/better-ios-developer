//
//  ViewController.m
//  Interview03-线程保活
//
//  Created by MJ Lee on 2018/6/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJThread.h"

@interface ViewController ()
@property (strong, nonatomic) MJThread *thread;
@property (assign, nonatomic, getter=isStoped) BOOL stopped;
@end

@implementation ViewController

//完善逻辑，导航返回的时候，也能销毁runloop
- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    
    self.stopped = NO;
    self.thread = [[MJThread alloc] initWithBlock:^{
        NSLog(@"%@----begin----", [NSThread currentThread]);
        
        // 往RunLoop里面添加Source\Timer\Observer
        [[NSRunLoop currentRunLoop] addPort:[[NSPort alloc] init] forMode:NSDefaultRunLoopMode];
    
        //这里self可能为空，返回的时候释放了，所以要加判断self是否存在
        while (weakSelf && !weakSelf.isStoped) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        NSLog(@"%@----end----", [NSThread currentThread]);
    }];
    [self.thread start];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.thread) return; //线程被销毁，就不要在里面做事情
    [self performSelector:@selector(test) onThread:self.thread withObject:nil waitUntilDone:NO];
}

// 子线程需要执行的任务
- (void)test
{
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
}

- (IBAction)stop {
    if (!self.thread) return; //线程被销毁，就不要在里面做事情
    
    // 在子线程调用stop（waitUntilDone设置为YES，代表子线程的代码执行完毕后，这个方法才会往下走）
    [self performSelector:@selector(stopThread) onThread:self.thread withObject:nil waitUntilDone:YES];
}

// 用于停止子线程的RunLoop
- (void)stopThread
{
    // 设置标记为YES
    self.stopped = YES;
    
    // 停止RunLoop
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSLog(@"%s %@", __func__, [NSThread currentThread]);
    
    // 销毁线程
    self.thread = nil;
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    [self stop];
}

@end
