//
//  YCBaseAPI.m
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import "YCBaseAPI.h"
#import "YCAPIManager.h"
#import <YCNetworking/YCRequestModel.h>

@interface YCBaseAPI ()
{
    struct {
        unsigned int hasBeforePerformSuccessInterceptor: 1;
        unsigned int hasAfterPerformSuccessInterceptor: 1;
        unsigned int hasBeforePerformFailureInterceptor: 1;
        unsigned int hasAfterPerformFailureInterceptor: 1;
    } _state;
}
/* 请求id */
@property (nonatomic, assign) NSInteger requestId;
/* 重试请求参数 */
@property (nonatomic, copy) NSDictionary *retryParams;
/* 重试请求标识 */
@property (nonatomic, assign, getter=isRetry) BOOL retry;
@end

@implementation YCBaseAPI
@synthesize apiProgressBlock = _apiProgressBlock;
@synthesize apiSuccessHandler = _apiSuccessHandler;
@synthesize apiFailureHandler = _apiFailureHandler;


- (instancetype)init {
    if (self = [super init]) {
        self.deallocUntilCompletion = NO;
        self.loading = NO;
        self.retry = NO;
    }
    
    return self;
}

- (void)dealloc {
    [self cancel];
}


#pragma mark - override
- (YCRequestModel *)apiRequestModel {
    NSString *exceptionName = [NSString stringWithFormat:@"Fail to send %@.", self];
    NSString *exceptionReason = [NSString stringWithFormat:@"API should override %@", NSStringFromSelector(_cmd)];
    @throw [[NSException alloc] initWithName:exceptionName
                                      reason:exceptionReason
                                    userInfo:nil];
    return nil;
}

- (NSDictionary *)apiRequestParams {
    return @{};
}

- (id)apiReformResponse:(id)response {
    return response;
}

- (NSDictionary *)reformedParams {
    
    if (self.isRetry) {
        return self.retryParams;
    }
    NSMutableDictionary *paramsM = self.apiRequestParams.mutableCopy;
    if (!paramsM) {
        paramsM = [NSMutableDictionary dictionary];
    }
    [paramsM addEntriesFromDictionary:self.apiRequestModel.parameters];
    return paramsM;
}

#pragma mark - Interceptor 切片
- (BOOL)beforePerformSuccessWithResponse:(id)response {
    
    BOOL valid = YES;
    if (_state.hasBeforePerformSuccessInterceptor) {
        valid = [self.interceptor api:self beforePerformSuccessWithResponse:response];
    }
    
    [self prepareForRetryEnviroment];
    
    return valid;
}

- (void)afterPerformSuccessWithResponse:(id)response {
    
    if (_state.hasAfterPerformSuccessInterceptor) {
        [self.interceptor api:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailureWithResponse:(id)response {
    
    BOOL valid = YES;
    if (_state.hasBeforePerformFailureInterceptor) {
        valid = [self.interceptor api:self beforePerformFailureWithResponse:response];
    }
    
    [self prepareForRetryEnviroment];
    
    return valid;
}

- (void)afterPerformFailureWithResponse:(id)response {
 
    if (_state.hasAfterPerformFailureInterceptor) {
        [self.interceptor api:self afterPerformFailureWithResponse:response];
    }
}

#pragma mark - private method
- (void)prepareForRetryEnviroment {
    self.retry = NO;
    self.retryParams = self.apiRequestModel.parameters;
    self.apiRequestModel.parameters = nil;
}


#pragma mark - api operate
- (BOOL)start {
    return [[YCAPIManager shareInstance] sendRequest:self];
}

- (void)retry {
    self.retry = YES;
    [[YCAPIManager shareInstance] sendRequest:self];
}

- (void)cancel {
    [[YCAPIManager shareInstance] cancelRequestWithRequestId:self.requestId];
}


#pragma mark - interceptor
- (void)setInterceptor:(id<YCAPIInterceptor>)interceptor {
    _interceptor = interceptor;
    _state.hasBeforePerformSuccessInterceptor = [interceptor respondsToSelector:@selector(api:beforePerformSuccessWithResponse:)];
    _state.hasBeforePerformFailureInterceptor = [interceptor respondsToSelector:@selector(api:beforePerformFailureWithResponse:)];
    _state.hasAfterPerformSuccessInterceptor = [interceptor respondsToSelector:@selector(api:afterPerformSuccessWithResponse:)];
    _state.hasAfterPerformFailureInterceptor = [interceptor respondsToSelector:@selector(api:afterPerformFailureWithResponse:)];
}
@end
