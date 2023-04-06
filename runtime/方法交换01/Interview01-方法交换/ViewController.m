//
//  ViewController.m
//  Interview01-方法交换
//
//  Created by MJ Lee on 2018/5/31.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)click1 {
    NSLog(@"%s", __func__);
}

- (IBAction)click2 {
    NSLog(@"%s", __func__);
}

- (IBAction)click3 {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *obj = nil;
    
//    NSMutableArray *array = [NSMutableArray array];
//    [array addObject:@"jack"];
//    [array insertObject:obj atIndex:0];
    
    
//    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//    dict[@"name"] = @"jack";
//    dict[obj] = @"rose";
//    dict[@"age"] = obj;
//
//    NSLog(@"%@", dict);
    
    NSDictionary *dict = @{@"name" : [[NSObject alloc] init],
                           @"age" : @"jack"};
    NSString *value =  dict[nil];
    
    NSLog(@"%@", [dict class]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
