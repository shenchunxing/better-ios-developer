//
//  YCTableViewItem.m
//  YCTableViewManager
//
//  Created by haima on 2019/3/25.
//

#import "YCTableViewItem.h"

@interface YCTableViewItem ()
/* 默认YES */
@property (nonatomic, assign) BOOL isFirstSetValue;
@end

@implementation YCTableViewItem
@synthesize shouldShow;

+ (instancetype)item {

    YCTableViewItem *item = [[self alloc] init];
    item.shouldShow = YES;
    return item;
}

- (instancetype)init {
    if (self = [super init]) {
        self.isFirstSetValue = YES;
    }
    return self;
}

- (void)setRequestValue:(id)requestValue {
    
    _requestValue = requestValue;
    if (self.isFirstSetValue) {
        self.preValue = requestValue;
        self.isFirstSetValue = NO;
    }
}

@end
