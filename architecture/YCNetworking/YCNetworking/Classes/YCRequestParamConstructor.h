//
//  YCRequestParamConstructor.h
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YCRequestModel;
@interface YCRequestParamConstructor : NSObject

//根据YCRequestModel，获取参数
+ (NSMutableDictionary *)parametersForRequest:(YCRequestModel *)requestModel;

/**
 头部参数

 @param requestModel YCRequestModel
 @return 头部参数
 */
+ (NSMutableDictionary *)headersForRequest:(YCRequestModel *)requestModel;
@end

NS_ASSUME_NONNULL_END
