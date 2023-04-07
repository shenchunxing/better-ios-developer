//
//  ViewController.m
//  Interview01-位运算
//
//  Created by MJ Lee on 2018/5/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

//typedef enum {
//    MJOptionsOne = 1,   // 0b0001
//    MJOptionsTwo = 2,   // 0b0010
//    MJOptionsThree = 4, // 0b0100
//    MJOptionsFour = 8   // 0b1000
//} MJOptions;

typedef enum {
//    MJOptionsNone = 0,    // 0b0000
    MJOptionsOne = 1<<0,   // 0b0001
    MJOptionsTwo = 1<<1,   // 0b0010
    MJOptionsThree = 1<<2, // 0b0100
    MJOptionsFour = 1<<3   // 0b1000
} MJOptions;

@interface ViewController ()

@end

@implementation ViewController

- (void)test
{
    
}

/*
 0b0001
 0b0010
 0b1000
 ------
 0b1011
&0b0100
-------
 0b0000
 */
- (void)setOptions:(MJOptions)options //options是按位或的结果，options & MJOptionsOne可以判断是否包含MJOptionsOne
{
    if (options & MJOptionsOne) {
        NSLog(@"包含了MJOptionsOne");
    }
    
    if (options & MJOptionsTwo) {
        NSLog(@"包含了MJOptionsTwo");
    }
    
    if (options & MJOptionsThree) {
        NSLog(@"包含了MJOptionsThree");
    }
    
    if (options & MJOptionsFour) {
        NSLog(@"包含了MJOptionsFour");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self performSelector:@selector(test)];
//    
//    [person performSelector:@selector(test)];
    
//    [self setOptions: MJOptionsOne | MJOptionsFour];
//    [self setOptions: MJOptionsOne + MJOptionsTwo + MJOptionsFour];
//    
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
//
//    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
//
//    [self addObserver:self forKeyPath:@"age" options:options context:NULL];
}


@end
