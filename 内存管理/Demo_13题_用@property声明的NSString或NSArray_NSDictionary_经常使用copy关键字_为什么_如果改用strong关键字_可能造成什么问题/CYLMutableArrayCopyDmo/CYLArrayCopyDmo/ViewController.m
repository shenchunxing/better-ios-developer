//
//  ViewController.m
//  CYLMutableArrayCopyDmo
//
//  Created by 陈宜龙 on 15/9/25.
//  Copyright © 2015年 http://weibo.com/luohanchenyilong/ 微博@iOS程序犭袁. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic ,readwrite, strong) NSArray *array;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array = @[ @1, @2, @3, @4 ];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];

    self.array = mutableArray;//赋值操作，strong修饰的话会强引用，copy修饰的话就是copy，不会被引用
    [mutableArray removeAllObjects];;
    NSLog(@"%@",self.array);//不可变的数组也可变了
    
    [mutableArray addObjectsFromArray:array];
    self.array = [mutableArray copy];//生成不可变数组
    [mutableArray removeAllObjects];;
    NSLog(@"%@",self.array);//不可变

}

@end
