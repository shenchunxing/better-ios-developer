//
//  ViewController.m
//  willDisplayCell绑定数据提高性能
//
//  Created by 沈春兴 on 2023/8/12.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.datas = @[@"Item1",@"Item2",@"Item3",@"Item4",@"Item5"];
    self.tableview.delegate =self;
    self.tableview.dataSource = self;
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

//cellForRowAtIndexPath只展示cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    return cell;
}

//数据绑定的操作放在willDisplayCell方法中。这样可以确保在即将显示cell之前，数据已经被正确绑定到cell上。
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = self.datas[indexPath.row];
}

@end
