//
//  YCBatchAPIRequest.m
//  YCAPIKit
//
//  Created by haima on 2019/6/6.
//

#import "YCBatchAPIRequest.h"
#import "YCBasePageAPI.h"
#import "YCAPIManager.h"

@interface YCBatchAPIRequest ()
@property (strong, nonatomic) NSMutableSet <YCBaseAPI *> *apisSet;
@end
@implementation YCBatchAPIRequest

- (instancetype)init {
    
    if (self = [super init]) {
        
        self.cancelUnfinishedRequestWhenAnyAPIFailed = YES;
        self.enableAPIPresenters = NO;
    }
    return self;
}


- (void)addAPIRequest:(YCBaseAPI *)api {
    
    NSCParameterAssert(api);
    NSAssert([api isKindOfClass:[YCBaseAPI class]], @"Api is not a valid type.");
    NSAssert(![api isKindOfClass:[YCBasePageAPI class]], @"Batch api request unsupport page api type.");
    @synchronized (self) {
        [self.apisSet addObject:api];
    }
}

- (void)addBatchAPIRequests:(id <NSFastEnumeration>)apis {
    
    NSCParameterAssert(apis);
    @synchronized (self) {
        for (YCBaseAPI *api in apis) {
            NSAssert([api isKindOfClass:[YCBaseAPI class]], @"Api is not a valid type.");
            NSAssert(![api isKindOfClass:[YCBasePageAPI class]], @"Batch api request unsupport page api type.");
            [self.apisSet addObject:api];
        }
    }
}

- (void)retry {
    NSAssert(self.apisSet.count > 0, @"Count of api should be more than 0");
    
    for (YCBaseAPI *subapi in self.apisSet) {
        subapi->_retry = YES;
    }
    
    _canceled = NO;
    [[YCAPIManager shareInstance] sendBatchRequest:self];
}

- (BOOL)start {
    NSAssert(self.apisSet.count > 0, @"Count of api should be more than 0");
    
    if (self.isLoading) return NO;
    
    _canceled = NO;
    [[YCAPIManager shareInstance] sendBatchRequest:self];
    
    return YES;
}

- (void)cancel {
    NSAssert(self.apisSet.count > 0, @"Count of api should be more than 0");
    
    _canceled = YES;
    @synchronized (self) {
        for (YCBaseAPI *subapi in self.apisSet) {
            [subapi cancel];
        }
    }
}



- (NSMutableSet<YCBaseAPI *> *)apisSet {
    
    if (_apisSet == nil) {
        _apisSet = [[NSMutableSet alloc] init];
        
    }
    return _apisSet;
}
@end
