# YCTableViewKit

TableView表单管理库

## Example

###创建`YCTableViewItem`的子类，如`YCMessageItem`<br>
```
@interface YCMessageItem : YCTableViewItem

/* title */
@property (nonatomic, copy) NSString *title;
/* content */
@property (nonatomic, copy) NSString *content;
/* height */
@property (nonatomic, assign) CGFloat height;


@end

```
###创建`UITableViewCell`子类，如`YCMessageCell`<br>
```
@interface YCMessageCell : UITableViewCell<YCTableViewCellProtocol>
/* title label */
@property (nonatomic, strong) UILabel *titleLabel;
/* content label */
@property (nonatomic, strong) UILabel *contentLabel;
@end
```

###`UITableViewCell`中必须实现一下协议方法：<br>
```
/* 只调用一次，一般书写布局代码 */
- (void)cellDidLoad;

/* cell高度 */
+ (CGFloat)heightForCellWithItem:(YCTableViewItem *)item;

/* 绑定cell的UI */
- (void)configCellWithItem:(YCTableViewItem *)item;

```

###`UIViewController`中使用方式：<br>

```
//需要导入头文件
#import <YCTableViewKit/YCTableViewKit.h>


/* TableView用于展示页面UI */
@property (nonatomic, strong) UITableView *tableView;

/* 用于管理组，刷新UI */
@property (nonatomic, strong) YCTableViewManager *manager;

/* 用于管理Items */
@property (nonatomic, strong) YCTableViewSection *section;

```

###`YCTableViewManager`初始化方法：<br>
```
- (YCTableViewManager *)manager {

    if (_manager == nil) {
        _manager = [[YCTableViewManager alloc] initWithTableView:self.tableView];
        //批量添加组，
        [_manager addManagerSections:@[self.section,self.section2]];
        //批量注册cell
        [_manager registerItems:@[S(YCMessageItem)]];
        //vc中需要使用UIScrollViewDelegate代理方法时，进行设置
        _manager.managerDelegate = self;
    }
    return _manager;
}
```

###`YCTableViewSection`初始化方法：<br>
```
- (YCTableViewSection *)section {

    if (_section == nil) {
        _section = [YCTableViewSection section];
    }
    return _section;
}
```

## Requirements

###`YCTableViewManager`功能说明：<br>
初始化方法<br>
```
- (instancetype)initWithTableView:(UITableView *)tableView;
```
其他功能api查看`YCTableViewManager.h`和`YCTableViewManager+Helper.h`

###`YCTableViewSection`功能说明：<br>
初始化方法<br>
```
+ (instancetype)section;
```
其他功能api查看`YCTableViewSection.h`

###`YCTableViewItem`功能说明：<br>
初始化方法<br>
```
+ (instancetype)item;
```
其他功能api查看`YCTableViewItem.h`

注意：所有Item的父类

## Installation


```ruby
pod 'YCTableViewKit'
```

## Author

shenweihang, haima@2dfire.com

## License

YCTableViewKit is available under the MIT license. See the LICENSE file for more info.
