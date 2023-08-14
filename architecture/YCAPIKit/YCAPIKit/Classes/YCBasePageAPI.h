//
//  YCBasePageAPI.h
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import "YCBaseAPI.h"

CF_EXPORT NSString *const kYCAPIPageNumberKeyPageSize;     /// pageSize
CF_EXPORT NSString *const kYCAPIPageNumberKeyPageIndex;   /// pageIndex
CF_EXPORT const NSInteger kYCAPIDefaultPageSize;

NS_ASSUME_NONNULL_BEGIN

@interface YCBasePageAPI : YCBaseAPI
//================================================
//                业务子类可重载方法
//================================================
/** required
 当前响应对应的数据条数
 
 子类必须覆盖这个方法，不调用super
 使用这个方法辅助判断是否有下一页
 
 @param response 当前响应（注：是最原始的响应）
 @return 数据条数
 */
- (NSInteger)apiCurrentPageSizeForResponse:(id)response;

/** optional
 默认每页数据条数，即page_size的值
 
 子类可以重载这个方法，返回默认每页数据条数，不调用super
 
 @return 数据条数
 */
- (NSInteger)apiDefaultPageSize;

/** optional
 页数的请求key，默认 kTDFAPIPageNumberKeyPageIndex
 
 @return 页数key
 */
- (NSString *)apiPageNumberKey;

/** optional
 页面请求条数key，默认kYCAPIPageNumberKeyPageSize

 @return 条数key
 */
- (NSString *)apiPageSizeKey;

//================================================
//                一般属性与方法
//================================================

/**
 当次加载的数据条数
 */
@property (assign, nonatomic, readonly) NSInteger currentPageSize;


/**
 是否有下一页
 */
@property (assign, nonatomic, readonly) BOOL hasNextPage;

/**
 当前页码
 */
@property (assign, nonatomic) NSInteger pageNumber;


/**
 加载第一页
 */
- (BOOL)start;

/**
 加载下一页
 */
- (BOOL)startForNextPage;

@end

NS_ASSUME_NONNULL_END
