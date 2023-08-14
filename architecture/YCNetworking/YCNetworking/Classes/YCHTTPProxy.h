//
//  YCHTTPProxy.h
//  YCNetworking
//
//  Created by haima on 2019/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class YCRequestModel,YCResponseModel;
@protocol YCHTTPProxy <NSObject>

@optional
/**
 请求之前处理请求数据

 @param requestModel requestModel
 */
- (void)beforeRequestSendWithRequestObject:(YCRequestModel *)requestModel;

/**
 根据返回数据判断是否要继续处理

 @param responseModel 返回数据模型
 @param response 返回json
 @return 是否继续后面处理流程
 */
- (BOOL)shouldContinueResponse:(YCResponseModel *)responseModel withResponseObject:(id)response;

@end

NS_ASSUME_NONNULL_END
