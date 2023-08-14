//
//  YCAlertHUDPresnter.m
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/3/27.
//

#import "YCAlertHUDPresnter.h"
#import <YCAPIKit/YCAPIKit.h>
#import "YCNetworkErrorView.h"
#import "UIView+Toast.h"

@implementation YCAlertHUDPresnter

- (void)api:(id <YCAPIProtocol>)api showFailureHUD:(NSError *)error {
    
    [super api:api showFailureHUD:error];
    
    if ([error.userInfo[@"code"] isEqualToString:@"EC00000404"] && self.showNetworkErrorView) {
        __weak typeof(api) weakAPI = api;
        [YCNetworkErrorView showNetworkErrorViewInView:self.view block:^{
            __strong typeof(weakAPI) strongAPI = weakAPI;
            [strongAPI retry];
        }];
    }else if ([error.userInfo[@"code"] isEqualToString:@"EC00000000"] && self.showNetworkErrorView) {
        __weak typeof(api) weakAPI = api;
        [YCNetworkErrorView showNoNetworkViewInView:self.view block:^{
            __strong typeof(weakAPI) strongAPI = weakAPI;
            [strongAPI retry];
        }];
    }
    else{
        [self.view makeToast:error.localizedDescription duration:1.5 position:CSToastPositionCenter];
    }
}

@end
