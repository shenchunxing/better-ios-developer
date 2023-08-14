//
//  YCGeneralPageAPI.m
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import "YCGeneralPageAPI.h"
#import <YCNetworking/YCRequestModel.h>

@implementation YCGeneralPageAPI
#pragma mark - override
- (YCRequestModel *)apiRequestModel {
    return self.requestModel;
}

- (NSDictionary *)apiRequestParams {
    return self.params;
}

- (NSInteger)apiCurrentPageSizeForResponse:(id)response {
    NSAssert(self.currentPageSizeBlock, @"Block to parsing page size can't be nil.");
    
    return self.currentPageSizeBlock(response);
}

- (NSInteger)apiDefaultPageSize {
    if (self.defaultPageSize > 0) {
        return self.defaultPageSize;
    }
    
    return [super apiDefaultPageSize];
}

- (id)apiReformResponse:(id)response {
    
    if (self.dataReformer) {
        return [self.dataReformer api:self reformResponse:response];
    }
    return response;
}

- (NSString *)apiPageNumberKey {
    if (self.pageNumberKey) {
        return self.pageNumberKey;
    }
    return [super apiPageNumberKey];
}

- (NSString *)apiPageSizeKey {
    if (self.pageSizeKey) {
        return self.pageSizeKey;
    }
    return [super apiPageSizeKey];
}

#pragma mark - getter
- (NSMutableDictionary *)params {
    if (_params == nil) {
        _params = [NSMutableDictionary dictionary];
    }
    
    return _params;
}
@end
