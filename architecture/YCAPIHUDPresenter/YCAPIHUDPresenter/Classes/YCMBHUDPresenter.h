//
//  YCMBHUDPresenter.h
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/3/27.
//

#import <Foundation/Foundation.h>
#import <YCAPIKit/YCAPIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCMBHUDPresenter : NSObject<YCAPIHUDPresenter>

@property (nonatomic, weak, readonly) UIView *view;
// 是否是新的自定义hud
@property (nonatomic, assign) BOOL isCustomer;
/* 是否显示网络出错页面，默认YES */
@property (nonatomic, assign) BOOL showNetworkErrorView;

+ (instancetype)HUDWithView:(__weak UIView *)view;

@property (nonatomic,copy) NSString *tips;

+ (instancetype)HUDWithView:(UIView *)view loadingTips:(NSString *)tips;

@end

NS_ASSUME_NONNULL_END
