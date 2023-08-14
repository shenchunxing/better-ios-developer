//
//  YCRequestURLSerializer.h
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class YCRequestModel;
@interface YCRequestURLSerializer : NSObject

/**
 解析URL

 @param request 请求模型
 @return 完整URL
 */
+ (NSString *)URLForRequest:(YCRequestModel *)request;

@end

NS_ASSUME_NONNULL_END
