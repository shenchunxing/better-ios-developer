//
//  HomeViewController.m
//  YT_TargetAction
//
//  Created by yehao on 16/9/15.
//  Copyright © 2016年 yehot. All rights reserved.
//

#import "HomeViewController.h"

//  不使用 Router 或 target action 时的用法
#import "OneViewController.h"

//  使用 target action 跳转
#import "CTMediator+NewsActions.h"

@interface HomeViewController ()

@end

@implementation HomeViewController
/**
 Target-Action方案的优点:
 充分的利用Runtime的特性，无需注册这一步。Target-Action方案只有存在组件依赖Mediator这一层依赖关系。在Mediator中维护针对Mediator的Category，每个category对应一个Target，Categroy中的方法对应Action场景。Target-Action方案也统一了所有组件间调用入口。
 Target-Action方案也能有一定的安全保证，它对url中进行Native前缀进行验证。
 利用 分类 可以明确声明接口，进行编译检查.
 
 
 Target-Action方案的缺点:
 需要在mediator 和 target中重新添加每一个接口，模块化时代码较为繁琐
 在 category 中仍然引入了字符串硬编码，内部使用字典传参，一定程度上也存在和 URL 路由相同的问题
 无法保证使用的模块一定存在，target在修改后，使用者只能在运行时才能发现错误
 可能会创建过多的 target 类
 */
- (void)viewDidLoad {
    [super viewDidLoad];
}

//  使用 target action 跳转
- (IBAction)btnOne:(UIButton *)sender {
    
    // 这里 param dict 的 value 也可以 传 model
    UIViewController *viewController = [[CTMediator sharedInstance] yt_mediator_newsViewControllerWithParams:@{@"newsID":@"123456"}];
    [self.navigationController pushViewController:viewController animated:YES];
}

//  不使用 Router 或 target action 时的用法
- (IBAction)btnTwo:(UIButton *)sender {
    OneViewController *viewController = [[OneViewController alloc] init];
    viewController.name = @"普通用法";
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
