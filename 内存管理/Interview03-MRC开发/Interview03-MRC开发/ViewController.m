//
//  ViewController.m
//  Interview03-MRC开发
//
//  Created by MJ Lee on 2018/6/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (retain, nonatomic) NSMutableArray *data;
@property (retain, nonatomic) UITabBarController *tabBarController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    
    self.data = [NSMutableArray array];
    
//    self.data = [[[NSMutableArray alloc] init] autorelease];
    
//    self.data = [[NSMutableArray alloc] init];
//    [self.data release];
    
//    NSMutableArray *data = [[NSMutableArray alloc] init];
//    self.data = data;
//    [data release];
}


- (void)dealloc {
    self.data = nil;
    self.tabBarController = nil;
    
    [super dealloc];
}


@end
