//
//  YCTableViewItem.h
//  YCTableViewManager
//
//  Created by haima on 2019/3/25.
//

#import <Foundation/Foundation.h>

@protocol YCTableViewItemDelegate <NSObject>

@optional

/**
 cell添加圆角

 @param cell cell
 @param indexPath indexPath
 */
- (void)filletedCornersForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol YCCellShowProtocol <NSObject>

@required
/* 是否显示cell */
@property (nonatomic, assign) BOOL shouldShow;

@end

@interface YCTableViewItem : NSObject<YCCellShowProtocol>
/* 是否是组内的最后一项 */
@property (nonatomic, assign) BOOL isLastItemInSection;
/* 是否是组内的第一项 */
@property (nonatomic, assign) BOOL isFirstItemInSection;
@property (nonatomic, strong) NSIndexPath *indexPath;
/* YCTableViewItemDelegate */
@property (nonatomic, weak) id<YCTableViewItemDelegate> tableViewItemDelegate;

@property (nonatomic, copy) void(^selectItemHandler)(NSIndexPath *indexPath);
@property (nonatomic, copy) void(^removeItemHandler)(NSIndexPath *indexPath);

/* 上传给服务端值对应的key，使用YCEditViewHelper生成json时用到 */
@property (nonatomic, strong) NSString *requestKey;

/* cell对应的值，一般和textValue相等，但是对于picker类型的，则对应其选中的值，YCEditViewHelper中用到 */
@property (nonatomic, strong) id requestValue;
/* 首次设置requestValue时的值，用于校验是否有修改 */
@property (nonatomic, strong) id preValue;

/* 有时候cell选中的值不是要上传的格式，可以通过这个转换成服务端需要的格式，YCEditViewHelper中用到 */
@property (nonatomic, copy) id (^mapRequestBlock)(id requestValue);

/* cell最大宽度，和tableview宽度一致,自动获取 */
@property (nonatomic, assign) CGFloat maxWidth;

@property (nonatomic,assign) BOOL hasSpaceing;

+ (instancetype)item;


@end


