//
//  YCGeneralAPI.h
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import "YCBaseAPI.h"

NS_ASSUME_NONNULL_BEGIN
@class YCRequestModel;
@interface YCGeneralAPI : YCBaseAPI
/**
 根据模块派生的YCRequestModel子类
 
 每个模块有属于自己的YCRequestModel子类
 */
@property (strong, nonatomic) YCRequestModel *requestModel;

/** 参数 */
@property (strong, nonatomic) NSMutableDictionary *params;



@end

NS_ASSUME_NONNULL_END
