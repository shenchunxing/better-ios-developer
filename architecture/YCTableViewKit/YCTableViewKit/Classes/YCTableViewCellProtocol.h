//
//  YCTableViewCellProtocol.h
//  YCTableViewManager
//
//  Created by haima on 2019/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YCTableViewItem;
@protocol YCTableViewCellProtocol <NSObject>

@required
/**
 cell创建的时候调用，只调用一次，一般做布局操作
 */
- (void)cellDidLoad;

/**
 绑定item

 @param item YCTableViewItem子类
 */
- (void)configCellWithItem:(YCTableViewItem *)item;

/**
 cell高度

 @param item YCTableViewItem子类
 @return cell高度
 */
+ (CGFloat)heightForCellWithItem:(YCTableViewItem *)item;

@optional
/**
 cell 即将展示时执行
 */
- (void)cellWillDisplay;

/**
 cell 已经展示时执行
 */
- (void)cellDidEndDisplay;

@end

NS_ASSUME_NONNULL_END
