//
//  YCTableViewSection.h
//  YCTableViewManager
//
//  Created by haima on 2019/3/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class YCBaseItem;
NS_ASSUME_NONNULL_BEGIN
@class YCTableViewItem;
@interface YCTableViewSection : NSObject

/* item */
@property (nonatomic, copy, readonly) NSArray<YCTableViewItem *> *items;

/* headerView */
@property (nonatomic, strong) UIView *headerView;
/* height for headerView */
@property (nonatomic, assign) CGFloat headerHeight;
/* height for footerView */
@property (nonatomic, assign) CGFloat footerHeight;
/* footerView */
@property (nonatomic, strong) UIView *footerView;
/* 是否需要圆角 */
@property (nonatomic, assign) BOOL needFillet;

@property (nonatomic,assign) NSInteger sectionIndex;

@property (nonatomic,assign) NSInteger tag;

+ (instancetype)section;

/**
 添加单个item

 @param item YCTableViewItem子类
 */
- (void)addItem:(YCTableViewItem *)item;

/**
 批量添加item

 @param items YCTableViewItem子类集合
 */
- (void)addItems:(NSArray<YCTableViewItem *> *)items;

/**
 指定位置插入item

 @param item YCTableViewItem子类
 @param index 指定位置
 */
- (void)insertItem:(YCTableViewItem *)item atIndex:(NSUInteger)index;

/**
 指定item前插入

 @param item YCTableViewItem子类
 @param baseItem 指定item
 */
- (void)insertItem:(YCTableViewItem *)item aboveItem:(YCTableViewItem *)baseItem;

/**
 指定item后插入

 @param item YCTableViewItem子类
 @param baseItem 指定item
 */
- (void)insertItem:(YCTableViewItem *)item belowItem:(YCTableViewItem *)baseItem;

/**
 批量插入item

 @param items YCTableViewItem子类集合
 @param indexes 位置集合
 */
- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes;

/**
 移除指定item

 @param item YCTableViewItem子类
 */
- (void)removeItem:(YCTableViewItem *)item;

/**
 移除指定位置item

 @param index index
 */
- (void)removeItemAtIndex:(NSUInteger)index;

/**
 移除最后一个item
 */
- (void)removeLastItem;

/**
 移除所有item
 */
- (void)removeAllItems;


- (YCBaseItem *)getItemWithKey:(NSString *)key;



@end

NS_ASSUME_NONNULL_END
