//
//  YCTableViewManager+Helper.h
//  YCTableViewManager
//
//  Created by haima on 2019/3/25.
//

#import <YCTableViewKit/YCTableViewManager.h>


#define S(item) NSStringFromClass([item class])
@interface YCTableViewManager (Helper)

/**
 批量添加组

 @param sections YCTableViewSection子类集合
 */
- (void)addManagerSections:(NSArray<YCTableViewSection *> *)sections;

/**
 批量注册cell，example：YCTextFieldItem--YCTextFieldCell,xxxItem--xxxCell
 */
- (void)registerItems:(NSArray<NSString *> *)items;

/**
 刷新item响应到界面
 
 @param item 刷新的item
 */
- (void)reloadDisplayedItem:(YCTableViewItem *)item;

/**
 刷新多个item响应到界面
 
 @param items 需要刷新的items
 */
- (void)reloadDisplayedItems:(NSArray <YCTableViewItem *> *)items;

/**
 删除item响应到界面
 
 @param item 删除的item
 */
- (void)deleteDisplayedItem:(YCTableViewItem *)item;

@end

