//
//  YCAPIManager.h
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class YCBaseAPI,YCBatchAPIRequest;
@interface YCAPIManager : NSObject

+ (instancetype)shareInstance;

/**
 发送API请求
 
 @param api 需要发送的API
 @return 是否成功
 */
- (BOOL)sendRequest:(YCBaseAPI *)api;

/**
 批量发送API请求
 
 @param request 批量请求
 @return 是否成功
 */
- (BOOL)sendBatchRequest:(YCBatchAPIRequest *)request;

/**
 取消API请求
 
 @param requestId 请求唯一标识
 */
- (void)cancelRequestWithRequestId:(NSInteger)requestId;

/**
 取消所有API请求
 */
- (void)cancelAllRequest;


@end

NS_ASSUME_NONNULL_END
