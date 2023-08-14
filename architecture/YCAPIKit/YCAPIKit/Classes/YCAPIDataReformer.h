//
//  TDFAPIDataReformer.h
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>


//================================================
//                数据加工代理
//================================================

NS_ASSUME_NONNULL_BEGIN
@class YCBaseAPI;
@protocol YCAPIDataReformer <NSObject>

@required
- (id)api:(YCBaseAPI *)api reformResponse:(id)response;

@end

NS_ASSUME_NONNULL_END
