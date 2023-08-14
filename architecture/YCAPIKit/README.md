# YCAPIKit


##`YCAPIManager`类
负责管理API，包括请求发送、请求取消、请求重试<br>
业务中不直接使用

##`YCBaseAPI`所有API基类
不能直接使用，一般使用YCGeneralAPI或者继承YCBaseAPI封装请求。

##`YCBasePageAPI`分页API的基类
不能直接使用，一般使用YCGeneralPageAPI或继承YCBasePageAPI封装请求。

##`YCGeneralAPI` 离散型普通API
离散型请求，适用于使用频率低，参数比较简单的接口请求。

##`YCGeneralPageAPI`离散分页API
使用方式和YCGeneralAPI类似，但是必须实现currentPageSizeBlock，否则会报错。
可根据需要自定义pageNumberKey（默认pageIndex）、pageSizeKey（默认pageSize）、defaultPageSize（默认10）

##`YCBatchAPIRequest`用于批量请求，不支持分页请求



## Example

```
/* 登录api */
@property (nonatomic, strong) YCGeneralAPI *loginAPI;
/* hud展示类 */
@property (nonatomic, strong) YCAlertHUDPresnter *presenter;
```

```
- (YCGeneralAPI *)loginAPI {
    
    if (_loginAPI == nil) {
        _loginAPI = [[YCGeneralAPI alloc] init];
        _loginAPI.requestModel = [YCLoginRequestModel modelWithActionPath:@"login"];
        _loginAPI.presenter = self.presenter;
        [_loginAPI setApiSuccessHandler:^(__kindof YCBaseAPI * _Nonnull api, id  _Nonnull response) {
            
        }];
        
    }
    return _loginAPI;
}

- (YCAlertHUDPresnter *)presenter {
    
    if (_presenter == nil) {
        _presenter = [YCAlertHUDPresnter HUDWithView:self.view];
        
    }
    return _presenter;
}
```

```
    self.loginAPI.params[@"username"] = @"admin@yunche.com";
    self.loginAPI.params[@"password"] = @"111111";
    self.loginAPI.params[@"isTerminal"] = @"true";
    self.loginAPI.params[@"machineId"] = @"13165ffa4e4f9353d4e";
    [self.loginAPI start];
```


## Requirements

## Installation

```ruby
pod 'YCAPIKit'
```

## Author

shenweihang, haima@2dfire.com

## License

YCAPIKit is available under the MIT license. See the LICENSE file for more info.
