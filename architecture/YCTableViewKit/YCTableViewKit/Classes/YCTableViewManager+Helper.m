//
//  YCTableViewManager+Helper.m
//  YCTableViewManager
//
//  Created by haima on 2019/3/25.
//

#import "YCTableViewManager+Helper.h"
#import "YCTableViewItem.h"

@implementation YCTableViewManager (Helper)

- (void)addManagerSections:(NSArray<YCTableViewSection *> *)sections {
    
    [sections enumerateObjectsUsingBlock:^(YCTableViewSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSection:obj];
    }];
}

- (void)registerItems:(NSArray<NSString *> *)items {
    
    NSString *realItem = nil;
    for (NSString *item in items) {
        if ([item hasSuffix:@"Item"]) {
            realItem = [item stringByReplacingOccurrencesOfString:@"Item" withString:@""];
        }
        NSString *cell = [realItem stringByAppendingString:@"Cell"];
        NSString *item = [realItem stringByAppendingString:@"Item"];
        
        NSAssert(NSClassFromString(cell) && NSClassFromString(item), @"can't find cell %@ or item %@", cell, item);
        
        [self registerCell:cell item:item];
    }
}

- (void)reloadDisplayedItem:(YCTableViewItem *)item {
    NSCParameterAssert(item.indexPath);
    
    UITableView *tableView = [self valueForKey:@"tableView"];
    [tableView reloadRowsAtIndexPaths:@[item.indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)reloadDisplayedItems:(NSArray<YCTableViewItem *>*)items {
    
    UITableView *tableView = [self valueForKey:@"tableView"];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    [items enumerateObjectsUsingBlock:^(YCTableViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject:obj.indexPath];
    }];
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)deleteDisplayedItem:(YCTableViewItem *)item {
    NSCParameterAssert(item.indexPath);
    
    UITableView *tableView = [self valueForKey:@"tableView"];
    [tableView deleteRowsAtIndexPaths:@[item.indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
