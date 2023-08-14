//
//  YCGeneralAPI.m
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import "YCGeneralAPI.h"
#import <YCNetworking/YCRequestModel.h>

@implementation YCGeneralAPI
#pragma mark - override
- (YCRequestModel *)apiRequestModel {
    return self.requestModel;
}

- (NSDictionary *)apiRequestParams {
    return self.params;
}

- (id)apiReformResponse:(id)response {
    if (self.dataReformer) {
        return [self.dataReformer api:self reformResponse:response];
    }
    return response;
}
#pragma mark - getter

- (NSMutableDictionary *)params {
    if (_params == nil) {
        _params = [NSMutableDictionary dictionary];
    }
    
    return _params;
}
@end
