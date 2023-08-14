//
//  YCAPIInterceptor.h
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>

//================================================
//                切片入口代理
//================================================

NS_ASSUME_NONNULL_BEGIN
@class YCBaseAPI;
@protocol YCAPIInterceptor <NSObject>

@optional
- (BOOL)api:(YCBaseAPI *)api beforePerformSuccessWithResponse:(id)response;
- (void)api:(YCBaseAPI *)api afterPerformSuccessWithResponse:(id)response;
- (BOOL)api:(YCBaseAPI *)api beforePerformFailureWithResponse:(id)response;
- (void)api:(YCBaseAPI *)api afterPerformFailureWithResponse:(id)response;

@end

NS_ASSUME_NONNULL_END
