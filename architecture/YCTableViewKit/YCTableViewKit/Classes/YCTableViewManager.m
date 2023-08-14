//
//  YCTableViewManager.m
//  YCTableViewManager
//
//  Created by haima on 2019/3/25.
//

#import "YCTableViewManager.h"
#import "YCTableViewItem.h"
#import "YCTableViewSection.h"
#import "YCTableViewCellProtocol.h"
#import <YCCategoryModule/YCCategoryModule.h>

@interface YCTableViewManager ()<UITableViewDelegate, UITableViewDataSource,YCTableViewItemDelegate>

/* 弱引用tableview */
@property (nonatomic, weak) UITableView *tableView;

/* 用于管理组 */
@property (nonatomic, strong) NSMutableArray *mutableSections;
/* 注册的cell集合 item-cell */
@property (nonatomic, strong) NSMutableDictionary *registerCells;

@end
@implementation YCTableViewManager
- (instancetype)initWithTableView:(UITableView *)tableView {
    
    if (self = [super init]) {
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        tableView.showsVerticalScrollIndicator = NO;
        self.tableView = tableView;
    }
    return self;
}

#pragma mark - public method
- (void)registerCell:(NSString *)cellName item:(NSString *)itemName {
    
    self.registerCells[itemName] = cellName;
}

- (void)addSection:(YCTableViewSection *)section {
    [self.mutableSections addObject:section];
}

- (void)insertSection:(YCTableViewSection *)section
         aboveSection:(YCTableViewSection *)baseSection {
    
    NSAssert([self.mutableSections containsObject:baseSection], @"baseSection is't in this manager!");
    NSUInteger index = [self.mutableSections indexOfObject:baseSection];
    [self insertSection:section atIndex:index];
}

- (void)insertSection:(YCTableViewSection *)section
         belowSection:(YCTableViewSection *)baseSection {
    
    NSAssert([self.mutableSections containsObject:baseSection], @"baseSection is't in this manager!");
    NSUInteger index = [self.mutableSections indexOfObject:baseSection];
    [self insertSection:section atIndex:index+1];
}

- (void)insertSection:(YCTableViewSection *)section atIndex:(NSUInteger)index {
    [self.mutableSections insertObject:section atIndex:index];
}

- (void)removeSectionAtIndex:(NSUInteger)index {
    [self.mutableSections removeObjectAtIndex:index];
}

- (void)removeSectionWithIteamArry:(NSMutableArray*)arry {
    [self.mutableSections removeObjectsInArray:arry];
}

- (void)removeLastSection {
    [self.mutableSections removeLastObject];
}

- (void)removeAllSections {
    [self.mutableSections removeAllObjects];
}

- (void)removeSection:(YCTableViewSection *)section {
    [self.mutableSections removeObject:section];
}

- (void)reloadData {
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)reloadCellAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - YCTableViewItemDelegate
- (void)filletedCornersForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    YCTableViewSection *section = self.mutableSections[indexPath.section];
    if (!section.needFillet) {
        return;
    }
    Class cellClass = [self classForCellAtIndexPath:indexPath];
    CGFloat cellHeight = 0;
    if ([cellClass conformsToProtocol:@protocol(YCTableViewCellProtocol)]) {
        cellHeight = [cellClass heightForCellWithItem:[self itemAtIndexPath:indexPath]];
    }
    
    if (section.items.count==1){
        [cell addRoundedCorners:UIRectCornerAllCorners withRadii:CGSizeMake(4, 4) viewRect:CGRectMake(0, 0, self.tableView.bounds.size.width, cellHeight)];
    }
    else if (indexPath.row==0) {
        [cell addRoundedCorners:UIRectCornerTopLeft|UIRectCornerTopRight withRadii:CGSizeMake(4, 4) viewRect:CGRectMake(0, 0, self.tableView.bounds.size.width, cellHeight)];
    }
    else if (indexPath.row==section.items.count-1){
        [cell addRoundedCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight withRadii:CGSizeMake(4, 4) viewRect:CGRectMake(0, 0, self.tableView.bounds.size.width, cellHeight)];
    }else{
        [cell addRoundedCorners:UIRectCornerAllCorners withRadii:CGSizeMake(0, 0) viewRect:CGRectMake(0, 0, self.tableView.bounds.size.width, cellHeight)];
    }
}

#pragma mark -- UITableViewDataSource --

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.mutableSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.mutableSections.count > section){
        YCTableViewSection *tableSection = self.mutableSections[section];
        NSInteger numOfRows = tableSection.items.count;
        return numOfRows;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class cellClass = [self classForCellAtIndexPath:indexPath];
    NSString *cellIdentifier = [NSString stringWithUTF8String:object_getClassName(cellClass)];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        if ([cell respondsToSelector:@selector(cellDidLoad)]) {
            [cell performSelector:@selector(cellDidLoad)];
        }
    }
    
    if ([cell respondsToSelector:@selector(configCellWithItem:)]) {
        [cell performSelector:@selector(configCellWithItem:) withObject:[self itemAtIndexPath:indexPath]];
    }
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.mutableSections.count > indexPath.section){
        YCTableViewSection *section = self.mutableSections[indexPath.section];
        section.sectionIndex = indexPath.section;
        if (section.needFillet) {
            YCTableViewItem *item = [self itemAtIndexPath:indexPath];
            item.tableViewItemDelegate = self;
            [self filletedCornersForCell:cell atIndexPath:indexPath];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(cellWillDisplay)]) {
        [cell performSelector:@selector(cellWillDisplay)];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(cellDidEndDisplay)]) {
        [cell performSelector:@selector(cellDidEndDisplay)];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight = 0;
    Class cellClass = [self classForCellAtIndexPath:indexPath];
    
    if ([cellClass conformsToProtocol:@protocol(YCTableViewCellProtocol)]) {
        cellHeight = [cellClass heightForCellWithItem:[self itemAtIndexPath:indexPath]];
    }
    
    return cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.mutableSections.count > section) {
        YCTableViewSection *tableSection = self.mutableSections[section];
        UIView *headerView = tableSection.headerView;
        return headerView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (self.mutableSections.count > section){
        YCTableViewSection *tableSection = self.mutableSections[section];
        UIView *footerView = tableSection.footerView;
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.mutableSections.count > section) {
        
        YCTableViewSection *tableSection = self.mutableSections[section];
        if (tableSection.headerHeight) {
            return tableSection.headerHeight;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (self.mutableSections.count > section) {
        YCTableViewSection *tableSection = self.mutableSections[section];
        if (tableSection.footerHeight) {
            return tableSection.footerHeight;
        }
    }
    return 0;
}

#pragma mark -- UITableViewDelegate --
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    YCTableViewItem *item = [self itemAtIndexPath:indexPath];
    if (item.selectItemHandler) {
        item.selectItemHandler(indexPath);
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.canEdit;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.canEdit && editingStyle == UITableViewCellEditingStyleDelete) {
        YCTableViewItem *item = [self itemAtIndexPath:indexPath];
        if (item.removeItemHandler) {
            item.removeItemHandler(indexPath);
        }
    }
}

//返回索引数组
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    if ([self.managerDelegate respondsToSelector:@selector(sectionIndexTitlesForTableView:)])
    return [self.managerDelegate sectionIndexTitlesForTableView:self.tableView];
    
    return nil;
}

//响应点击索引时的委托方法
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    if ([self.managerDelegate respondsToSelector:@selector(tableView:sectionForSectionIndexTitle:atIndex:)])
    return [self.managerDelegate tableView:self.tableView sectionForSectionIndexTitle:title atIndex:index];
    
    return 0;
}

#pragma mark -- UIScrollViewDelegate --

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewDidScroll:)])
        [self.managerDelegate scrollViewDidScroll:self.tableView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewDidZoom:)])
        [self.managerDelegate scrollViewDidZoom:self.tableView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
        [self.managerDelegate scrollViewWillBeginDragging:self.tableView];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewWillEndDragging:withVelocity:targetContentOffset:)])
        [self.managerDelegate scrollViewWillEndDragging:self.tableView withVelocity:velocity targetContentOffset:targetContentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [self.managerDelegate scrollViewDidEndDragging:self.tableView willDecelerate:decelerate];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
        [self.managerDelegate scrollViewWillBeginDecelerating:self.tableView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [self.managerDelegate scrollViewDidEndDecelerating:self.tableView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)])
        [self.managerDelegate scrollViewDidEndScrollingAnimation:self.tableView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)])
        return [self.managerDelegate viewForZoomingInScrollView:self.tableView];
    
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)])
        [self.managerDelegate scrollViewWillBeginZooming:self.tableView withView:view];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)])
        [self.managerDelegate scrollViewDidEndZooming:self.tableView withView:view atScale:scale];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)])
        return [self.managerDelegate scrollViewShouldScrollToTop:self.tableView];
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    // Forward to UIScrollView delegate
    //
    if ([self.managerDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.managerDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)])
        [self.managerDelegate scrollViewDidScrollToTop:self.tableView];
}


#pragma mark - private method

- (Class)classForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    YCTableViewItem *item = [self itemAtIndexPath:indexPath];
    
    NSString *cellString = self.registerCells[NSStringFromClass(item.class)];
    
    Class cellClass = NSClassFromString(cellString);
    
    NSAssert(cellClass, @"can't find reusable cell for item %@ at indexPath %@", item, indexPath);
    
    return cellClass;
}

- (YCTableViewItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.mutableSections.count > indexPath.section) {
        YCTableViewSection *section = self.mutableSections[indexPath.section];
        if ([section.items count] > indexPath.row) {
            YCTableViewItem *item = section.items[indexPath.row];
            item.indexPath = indexPath;
            item.maxWidth = self.tableView.bounds.size.width;
            item.isLastItemInSection = (section.items.count-1 == indexPath.row);
            item.isFirstItemInSection = (0 == indexPath.row);
            return item;
        }
    }
    return nil;
}

#pragma mark - getter
- (NSArray<YCTableViewSection *> *)sections {
    return self.mutableSections;
}

- (NSMutableArray *)mutableSections {
    
    if (_mutableSections == nil) {
        _mutableSections = [[NSMutableArray alloc] init];
        
    }
    return _mutableSections;
}

- (NSMutableDictionary *)registerCells {
    
    if (_registerCells == nil) {
        _registerCells = [[NSMutableDictionary alloc] init];
        
    }
    return _registerCells;
}
@end
