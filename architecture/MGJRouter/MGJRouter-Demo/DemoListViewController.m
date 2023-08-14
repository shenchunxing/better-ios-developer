//
//  DemoListViewController.m
//  MGJRequestManagerDemo
//
//  Created by limboy on 3/20/15.
//  Copyright (c) 2015 juangua. All rights reserved.
//

#import "DemoListViewController.h"

static NSMutableDictionary *titleWithHandlers;
static NSMutableArray *titles;

@interface DemoListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@end

@implementation DemoListViewController

/**
 URL 路由的优点

 极高的动态性，适合经常开展运营活动的app，例如电商
 方便地统一管理多平台的路由规则
 易于适配URL Scheme

 URl 路由的缺点

 传参方式有限，并且无法利用编译器进行参数类型检查，因此所有的参数都是通过字符串转换而来
 只适用于界面模块，不适用于通用模块
 参数的格式不明确，是个灵活的 dictionary，也需要有个地方可以查参数格式。
 不支持storyboard
 依赖于字符串硬编码，难以管理，蘑菇街做了个后台专门管理。
 无法保证所使用的的模块一定存在
 解耦能力有限，url 的”注册”、”实现”、”使用”必须用相同的字符规则，一旦任何一方做出修改都会导致其他方的代码失效，并且重构难度大
 */
+ (void)registerWithTitle:(NSString *)title handler:(UIViewController *(^)())handler
{
    if (!titleWithHandlers) {
        titleWithHandlers = [[NSMutableDictionary alloc] init];
        titles = [NSMutableArray array];
    }
    [titles addObject:title];
    titleWithHandlers[title] = handler;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"MGJRouterDemo";
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleWithHandlers.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *viewController = ((ViewControllerHandler)titleWithHandlers[titles[indexPath.row]])();
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
