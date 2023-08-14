//
//  YCAPIProtocol.h
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>


//================================================
//                API操作协议
//================================================

NS_ASSUME_NONNULL_BEGIN

@protocol YCAPIProtocol <NSObject>

@required
/**
 取消当前API的请求
 */
- (void)cancel;

/**
 开始请求当前API
 
 如果当前API正在加载，此方法会返回NO
 
 @return 是否成功
 */
- (BOOL)start;

/**
 重试请求
 */
- (void)retry;

@end

NS_ASSUME_NONNULL_END
