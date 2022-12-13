//
//  ViewController.m
//  Interview04-线程同步
//
//  Created by MJ Lee on 2018/6/7.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJBaseDemo.h"
#import "OSSpinLockDemo.h"
#import "OSSpinLockDemo2.h"

@interface ViewController ()
@property (strong, nonatomic) MJBaseDemo *demo;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MJBaseDemo *demo = [[OSSpinLockDemo2 alloc] init];
    [demo ticketTest];
    [demo moneyTest];
    
    for (int i = 0; i < 10; i++) {
        [[[NSThread alloc] initWithTarget:self selector:@selector(test) object:nil] start];
    }
}

- (int)test
{
    int a = 10;
    int b = 20;
    
    NSLog(@"%p", self.demo);
    
    int c = a + b;
    return c;
}

@end
