//
//  ViewController.m
//  Interview03-runtime应用
//
//  Created by MJ Lee on 2018/5/29.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取textfield所有的成员
    unsigned int count;
    Ivar *ivars = class_copyIvarList([UITextField class], &count);
    for (int i = 0; i < count; i++) {
        // 取出i位置的成员变量
        Ivar ivar = ivars[i];
        NSLog(@"%s %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
    free(ivars);
//
    self.textField.placeholder = @"请输入用户名";

    
    
    //3种方式设置提示颜色
    [self.textField setValue:[UIColor redColor] forKeyPath:@"placeholderLabel.textColor"];
    
    UILabel *placeholderLabel = [self.textField valueForKeyPath:@"placeholderLabel"];
    placeholderLabel.textColor = [UIColor greenColor];
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = [UIColor yellowColor];
    self.textField.attributedPlaceholder = [[NSMutableAttributedString alloc] initWithString:@"请输入用户名" attributes:attrs];
}

@end
