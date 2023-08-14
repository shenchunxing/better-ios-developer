//
//  YCGeneralPageAPI.h
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import "YCBasePageAPI.h"

NS_ASSUME_NONNULL_BEGIN
@class YCRequestModel;
@interface YCGeneralPageAPI : YCBasePageAPI
/**
 根据模块派生的YCRequestModel子类
 
 每个模块有属于自己的YCRequestModel子类
 */
@property (strong, nonatomic) YCRequestModel *requestModel;

/**
 除pageSize、pageIndex两个参数外的其它参数
 */
@property (strong, nonatomic) NSMutableDictionary *params;

/**
 默认每页数据条数, 即pageSize的值
 
 默认 20
 */
@property (assign, nonatomic) NSInteger defaultPageSize;

/**
 标识页数的请求key
 
 默认pageIndex

 */
@property (copy, nonatomic) NSString *pageNumberKey;

/* 条数key
    默认pageSize
 */
@property (nonatomic, copy) NSString *pageSizeKey;

/**
 当前响应中数据条数
 
 response: 当前响应（注：是最原始的响应）
 返回数据条数
 */
@property (copy, nonatomic) NSInteger (^currentPageSizeBlock)(id response);
@end

NS_ASSUME_NONNULL_END
