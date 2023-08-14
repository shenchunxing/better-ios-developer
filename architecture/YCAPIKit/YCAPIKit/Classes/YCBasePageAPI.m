//
//  YCBasePageAPI.m
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import "YCBasePageAPI.h"

NSString *const kYCAPIPageNumberKeyPageSize = @"pageSize";     /// pageSize
NSString *const kYCAPIPageNumberKeyPageIndex = @"curPage";   /// pageIndex
const NSInteger kYCAPIDefaultPageSize = 10;
@interface YCBasePageAPI ()
@property (assign, nonatomic) NSInteger currentPageSize;
@end

@implementation YCBasePageAPI

#pragma mark - override
- (NSInteger)apiCurrentPageSizeForResponse:(id)response {
    NSString *exceptionName =
    [NSString stringWithFormat:@"Fail to get page size for response %@.", response];
    NSString *exceptionReason =
    [NSString stringWithFormat:@"API should override %@", NSStringFromSelector(_cmd)];
    @throw [[NSException alloc] initWithName:exceptionName
                                      reason:exceptionReason
                                    userInfo:nil];
}

- (NSInteger)apiDefaultPageSize {
    return kYCAPIDefaultPageSize;
}

- (NSString *)apiPageNumberKey {
    return kYCAPIPageNumberKeyPageIndex;
}

- (NSString *)apiPageSizeKey {
    return kYCAPIPageNumberKeyPageSize;
}

#pragma mark - operate
- (BOOL)start {
    self.pageNumber = 1;
    self.currentPageSize = NSNotFound;
    return [super start];
}

- (BOOL)startForNextPage {
    self.pageNumber += 1;
    
    BOOL success = [super start];
    
    if (!success) {
        self.pageNumber -= 1;
    }
    
    return success;
}

#pragma mark - interceptor
- (BOOL)beforePerformSuccessWithResponse:(id)response {
    BOOL valid = [super beforePerformSuccessWithResponse:response];
    
    self.currentPageSize = [self apiCurrentPageSizeForResponse:response];
    
    return valid;
}

- (BOOL)beforePerformFailureWithResponse:(id)response {
    
    BOOL valid = [super beforePerformFailureWithResponse:response];
    if (self.pageNumber > 0) {
        self.pageNumber -= 1;
    }
    return valid;
}
#pragma mark - override
- (NSDictionary *)reformedParams {
    
    NSAssert([self apiPageNumberKey], @"Api page number key can't be nil");
    
    NSMutableDictionary *paramsM = [super reformedParams].mutableCopy;
    paramsM[[self apiPageSizeKey]] = @(self.apiDefaultPageSize).stringValue;
    paramsM[[self apiPageNumberKey]] = @(self.pageNumber).stringValue;
    return paramsM;
}

#pragma mark getter
- (BOOL)hasNextPage {
    return self.currentPageSize == NSNotFound ||
    self.currentPageSize >= self.apiDefaultPageSize;
}

- (void)setPageNumber:(NSInteger)pageNumber {
    NSAssert(pageNumber >= 0, @"Page number can't be negative number.");
    
    _pageNumber = pageNumber;
}
@end
