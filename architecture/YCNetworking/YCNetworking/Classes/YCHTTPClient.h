//
//  YCHTTPClient.h
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import <AFNetworking/AFNetworking.h>
#import "YCHTTPProxy.h"
NS_ASSUME_NONNULL_BEGIN

@class YCRequestModel,YCResponseModel;
@interface YCHTTPClient : AFHTTPSessionManager

/* 切片,强制持有方式，外部不能强持有 */
@property (nonatomic, strong) id<YCHTTPProxy> proxy;

+ (instancetype)shareInstance;


/**
 网络请求

 @param requestModel 请求requestModel
 @param progressBlock 进度
 @param callback 回调YCResponseModel
 @return task
 */
- (nonnull NSURLSessionTask*)sendRequestWithRequestModel:(nonnull YCRequestModel *)requestModel
                                                     progress:(nullable void (^)(NSProgress *_Nullable progress))progressBlock
                                                     callback:(nullable void (^)(YCResponseModel *_Nullable responseModel))callback;

//不要进度条
- (nonnull NSURLSessionTask*)sendRequestWithRequestModel:(nonnull YCRequestModel *)requestModel
                                                callback:(nullable void (^)(YCResponseModel *_Nullable responseModel))callback;

/**
 检测网络是否可用

 @param block block
 */
- (void)checkNetworkAvailable:(void(^)(BOOL isAvailable))block;
@end

NS_ASSUME_NONNULL_END
