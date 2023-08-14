//
//  YCMBHUDPresenter.m
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/3/27.
//

#import "YCMBHUDPresenter.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "YCSentinel.h"
#import "YCCustomHUD.h"
#import "YCNetworkErrorView.h"

@interface YCMBHUDPresenter ()
@property (weak, nonatomic, readwrite) UIView *view;
@property (strong, nonatomic) YCSentinel *sentinel;
@property (weak, nonatomic) MBProgressHUD *hud;
@end

@implementation YCMBHUDPresenter

+ (instancetype)HUDWithView:(UIView *)view {
    YCMBHUDPresenter *presenter = [[self alloc] init];
    presenter.view = view;
    presenter.sentinel = [[YCSentinel alloc] init];
    presenter.isCustomer = YES;
    presenter.showNetworkErrorView = YES;
    return presenter;
}

+ (instancetype)HUDWithView:(UIView *)view loadingTips:(NSString *)tips{
    YCMBHUDPresenter *presenter = [[self alloc] init];
    presenter.view = view;
    presenter.sentinel = [[YCSentinel alloc] init];
    presenter.isCustomer = YES;
    presenter.showNetworkErrorView = YES;
    presenter.tips = tips;
    return presenter;
}

- (void)dealloc {
    if ([[NSThread currentThread] isMainThread]) {
        [_hud hideAnimated:NO];
    }
}

- (void)apiShowNoNetworkView:(id<YCAPIProtocol>)api {
    
    __weak typeof(api) weakAPI = api;
    [YCNetworkErrorView showNoNetworkViewInView:self.view block:^{
        __strong typeof(weakAPI) strongAPI = weakAPI;
        [strongAPI retry];
    }];
}

- (void)apiShowBeginHUD:(id <YCAPIProtocol>)api {
    if ([self.sentinel increase] == 1) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        if (self.isCustomer) {
            self.hud.mode = MBProgressHUDModeCustomView;
            YCCustomHUD *customView = [[YCCustomHUD alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
            self.hud.customView = customView;
            self.hud.bezelView.color = [UIColor clearColor];
            self.hud.margin = 0.f;
            self.hud.offset = CGPointMake(0, -100);
            if (self.tips) {
                customView.titleLbl.text = self.tips;
            }
        }
    }
}

- (void)apiHideBeginHUD:(id <YCAPIProtocol>)api {
    if ([self.sentinel decrease] <= 0) {
        [self.hud hideAnimated:YES];
    }
    NSAssert(self.sentinel.value >= 0, @"present count should be more than or equal 0");
}

- (void)api:(id <YCAPIProtocol>)api showSuccessHUD:(id)response {
    [self apiHideBeginHUD:api];
}

- (void)api:(id <YCAPIProtocol>)api showFailureHUD:(NSError *)error {
    [self apiHideBeginHUD:api];
    NSAssert(self.sentinel.value >= 0, @"present count should be more than or equal 0");
}
@end
