//
//  ViewController.m
//  Interview03-测试
//
//  Created by MJ Lee on 2018/5/12.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import "MJPerson.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self test1];//先strong后weak,1秒后就释放
//    [self test2];//先weak后strong，3秒后释放
    [self test3];//先strong后weak,但是因为weak指针又被strong强引用，3秒后释放
}

- (void)test1 {
    MJPerson *p = [[MJPerson alloc] init];
    __weak MJPerson *weakP = p;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"1-------%@", p); //因为block对p这里有强引用，导致p打印完，才会释放
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"2-------%@", weakP);//weakP指针是弱引用，
        });
    });
    NSLog(@"p即将释放");
}

- (void)test2 {
    MJPerson *p = [[MJPerson alloc] init];
    __weak MJPerson *weakP = p;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"1-------%@", weakP);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"2-------%@", p);//因为block对p这里有强引用，导致p打印完，才会释放
        });
    });
    NSLog(@"p即将释放");
}

- (void)test3 {
    MJPerson *p = [[MJPerson alloc] init];
    __weak MJPerson *weakP = p;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"1-------%@", p);
        __strong MJPerson *strongPerson = weakP;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"2-------%@", strongPerson);//因为strongPerson对weakP这里有强引用，导致打印完，才会释放
        });
    });
    NSLog(@"p即将释放");
}


@end
