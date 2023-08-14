//
//  YCSentinel.h
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/3/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//==================================
//          多线程哨兵
//==================================
@interface YCSentinel : NSObject
/**
 当前计数值
 */
@property (atomic, readonly) int32_t value;

/**
 计数值+1
 
 @return 当前计数值
 */
- (int32_t)increase;

/**
 计数值-1
 
 @return 当前计数值
 */
- (int32_t)decrease;
@end

NS_ASSUME_NONNULL_END
