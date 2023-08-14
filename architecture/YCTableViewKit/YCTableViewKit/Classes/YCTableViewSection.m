//
//  YCTableViewSection.m
//  YCTableViewManager
//
//  Created by haima on 2019/3/25.
//

#import "YCTableViewSection.h"
#import "YCBaseItem.h"

@interface YCTableViewSection ()

/* 可变items数组 */
@property (nonatomic, strong) NSMutableArray *mutableItems;

@end

@implementation YCTableViewSection

#pragma mark - 初始化方法
+ (instancetype)section {
    
    YCTableViewSection *section = [[self alloc] init];
    return section;
}

#pragma mark - item
- (NSArray<YCTableViewItem *> *)items {
    return [self.mutableItems copy];
}

#pragma mark - item处理方法
- (void)addItem:(YCTableViewItem *)item {
    [self.mutableItems addObject:item];
}

- (void)addItems:(NSArray<YCTableViewItem *> *)items {
    [self.mutableItems addObjectsFromArray:items];
}

- (void)insertItem:(YCTableViewItem *)item atIndex:(NSUInteger)index {
    
    [self.mutableItems insertObject:item atIndex:index];
}

- (void)insertItem:(YCTableViewItem *)item aboveItem:(YCTableViewItem *)baseItem {
    
    NSAssert([self.mutableItems containsObject:baseItem], @"baseItem is't in this section");
    if ([self.mutableItems containsObject:baseItem]) {
        NSInteger index = [self.mutableItems indexOfObject:baseItem];
        [self.mutableItems insertObject:item atIndex:index];
    }
}

- (void)insertItem:(YCTableViewItem *)item belowItem:(YCTableViewItem *)baseItem {
    
    NSAssert([self.mutableItems containsObject:baseItem], @"baseItem is't in this section");
    if ([self.mutableItems containsObject:baseItem]) {
        NSInteger index = [self.mutableItems indexOfObject:baseItem];
        [self.mutableItems insertObject:item atIndex:index+1];
    }
}

- (void)insertItems:(NSArray<YCTableViewItem *> *)items atIndexes:(NSIndexSet *)indexes {
    
    [self.mutableItems insertObjects:items atIndexes:indexes];
}

- (void)removeItem:(YCTableViewItem *)item {
    [self.mutableItems removeObject:item];
}

- (void)removeItemAtIndex:(NSUInteger)index {
    [self.mutableItems removeObjectAtIndex:index];
}

- (void)removeLastItem {
    
    [self.mutableItems removeLastObject];
}

- (void)removeAllItems {
    [self.mutableItems removeAllObjects];
}

- (YCBaseItem *)getItemWithKey:(NSString *)key{
    for (YCTableViewItem *item in self.mutableItems) {
        if ([item isKindOfClass:[YCBaseItem class]]) {
            YCBaseItem *baseItem = (YCBaseItem *)item;
            if ([baseItem.key isEqualToString:key]) {
                return baseItem;
            }
        }
    }
    return nil;
}

#pragma mark - getter
- (NSMutableArray *)mutableItems {
    
    if (_mutableItems == nil) {
        _mutableItems = [[NSMutableArray alloc] init];
        
    }
    return _mutableItems;
}
@end
