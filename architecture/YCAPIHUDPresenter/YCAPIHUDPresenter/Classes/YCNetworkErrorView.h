//
//  YCNetworkErrorView.h
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/4/20.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YCNetworkErrorViewType) {
    YCNetworkErrorViewTypeError,            //请求出错页面
    YCNetworkErrorViewTypeNoNetwork         //无网络页面
};

typedef void(^RetryHandler)(void);

@interface YCNetworkErrorView : UIView

//网路请求出错
+ (void)showNetworkErrorViewInView:(UIView *)view block:(RetryHandler)block;

//无网络
+ (void)showNoNetworkViewInView:(UIView *)view block:(RetryHandler)block;

@end

