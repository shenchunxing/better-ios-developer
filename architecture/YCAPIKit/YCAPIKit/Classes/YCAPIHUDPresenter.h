//
//  TDFAPIHUDPresenter.h
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>
#import "YCAPIProtocol.h"
//================================================
//                HUD展示代理
//================================================


@class YCBaseAPI;
@protocol YCAPIHUDPresenter <NSObject>

@required
/**
 展示无网络视图
 */
- (void)apiShowNoNetworkView:(id<YCAPIProtocol>)api;
/**
 展示请求开始HUD
 */
- (void)apiShowBeginHUD:(id<YCAPIProtocol>)api;

/**
 隐藏请求开始HUD
 */
- (void)apiHideBeginHUD:(id<YCAPIProtocol>)api;

/**
 展示请求成功HUD
 
 @param response 响应数据
 */
- (void)api:(id<YCAPIProtocol>)api showSuccessHUD:(id)response;

/**
 展示请求失败HUD
 
 @param error 错误信息
 */
- (void)api:(id<YCAPIProtocol>)api showFailureHUD:(NSError *)error;

@end

