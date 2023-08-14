//
//  YCResponseModel.h
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>

extern NSString *const kNetworkErrorDomain;

NS_ASSUME_NONNULL_BEGIN

/**
 回调YCResponseModel
 */

@interface YCResponseModel : NSObject

/* error */
@property (nonatomic, strong) NSError *error;
/* 响应数据，原始数据 */
@property (nonatomic, strong) id responseObject;
/* 响应数据，data数据 */
@property (nonatomic, strong) id dataObject;
/* 请求任务 */
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
/* 是否继续处理响应 默认YES*/
@property (nonatomic, assign) BOOL isContinueResponse;
- (BOOL)isSuccess;
@end

NS_ASSUME_NONNULL_END
