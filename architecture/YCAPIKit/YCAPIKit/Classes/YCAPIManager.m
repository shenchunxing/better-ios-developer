//
//  YCAPIManager.m
//  YCAPIKit
//
//  Created by haima on 2019/3/26.
//

#import "YCAPIManager.h"
#import <YCNetworking/YCHTTPClient.h>
#import <YCNetworking/YCRequestModel.h>
#import <YCNetworking/YCResponseModel.h>
#import "YCBaseAPI.h"
#import "YCBatchAPIRequest.h"

@interface YCAPIManager ()

/* 请求任务表 */
@property (strong, nonatomic) NSMutableDictionary <NSNumber *, NSURLSessionTask *> *requestTaskMap;
/* api集合 */
@property (strong, nonatomic) NSMutableSet <YCBaseAPI *> *requests;

@end

@implementation YCAPIManager

+ (instancetype)shareInstance {
    
    static YCAPIManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.requestTaskMap = [NSMutableDictionary dictionary];
        self.requests = [NSMutableSet set];
    }
    return self;
}

- (BOOL)sendRequest:(YCBaseAPI *)api {
    
    if (api.isLoading) {
        return NO;
    }
    [self sendRequest:api fromBatchRequest:nil withDispatchGroup:nil];
    return YES;
}

- (BOOL)sendBatchRequest:(YCBatchAPIRequest *)request {
    
    NSParameterAssert(request);
    NSAssert(request.apisSet.count > 0, @"Count of api should be more than 0");
    if (request.isLoading) {
        return NO;
    }
    [self safeAsyncOnMainThread:^{
        request.loading = YES;
        [request.presenter apiShowBeginHUD:request];
    }];
    
    dispatch_group_t batch_api_group = dispatch_group_create();
    for (YCBaseAPI *api in request.apisSet) {
        if (api.isLoading) {
            continue;
        }
        dispatch_group_enter(batch_api_group);
        [self sendRequest:api fromBatchRequest:request withDispatchGroup:batch_api_group];
    }
    dispatch_group_notify(batch_api_group, dispatch_get_main_queue(), ^{
        request.loading = NO;
        if (request->_canceled) {
            [request.presenter apiHideBeginHUD:request];
            return;
        }
        if (!request.error) {
            [request.presenter api:request showSuccessHUD:nil];
            if (request.requestSuccessHandler) {
                request.requestSuccessHandler(request);
            }
        }else{
            [request.presenter api:request showFailureHUD:request.error];
            if (request.requestFailureHandler) {
                request.requestFailureHandler(request, request.error);
            }
        }
    });
    return YES;
}

- (NSInteger)sendRequest:(YCBaseAPI *)api
        fromBatchRequest:(YCBatchAPIRequest *)batchRequest
       withDispatchGroup:(dispatch_group_t)dispatchGroup  {
 
    NSParameterAssert(api);
    
    
    if (api.isDeallocUntilCompletion) {
        @synchronized (self) {
            if (![self.requests containsObject:api]) {
                [self.requests addObject:api];
            }
        }
    }
    
    [self safeAsyncOnMainThread:^{
        if (!batchRequest || batchRequest.enableAPIPresenters) {
            [api.presenter apiShowBeginHUD:api];
        }
    }];
    YCRequestModel *requestModel = api.apiRequestModel;
    requestModel.parameters = [api reformedParams];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(api) weakApi = api;
    
    typeof(api.presenter) presenter = api.presenter;
    
    NSURLSessionTask *task = [[YCHTTPClient shareInstance] sendRequestWithRequestModel:requestModel progress:^(NSProgress * _Nullable progress) {
        
        __strong typeof(weakApi) strongApi = weakApi;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handleProgress:progress withAPI:strongApi];
    } callback:^(YCResponseModel * _Nullable responseModel) {
        __strong typeof(weakApi) strongApi = weakApi;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        // api was dealloced
        if (!strongApi) {
            if (!batchRequest || batchRequest.enableAPIPresenters) {
                [presenter apiHideBeginHUD:strongApi];
            }
        }
        
        [strongSelf handleResponse:responseModel withAPI:strongApi fromBatchRequest:batchRequest];
        if (dispatchGroup) {
            dispatch_group_leave(dispatchGroup);
        }
    }];
    [task resume];
    api->_requestId = task.taskIdentifier;
    @synchronized (self) {
        self.requestTaskMap[@(task.taskIdentifier)] = task;
    }
    [self safeAsyncOnMainThread:^{
        api.loading = YES;
    }];
    return task.taskIdentifier;
}


#pragma mark - progress handler
- (void)handleProgress:(NSProgress *)progress withAPI:(YCBaseAPI *)api {
    if (api.apiProgressBlock) {
        [self safeAsyncOnMainThread:^{
            api.apiProgressBlock(api, progress);
        }];
    }
}


#pragma mark - response handler
- (void)handleResponse:(YCResponseModel *)response
               withAPI:(YCBaseAPI *)api
      fromBatchRequest:(YCBatchAPIRequest *)batchRequest{
    
    // remove cached request from map
    @synchronized (self) {
        [self.requestTaskMap removeObjectForKey:@(response.sessionTask.taskIdentifier)];
        if ([self.requests containsObject:api]) {
            [self.requests removeObject:api];
        }
    }
    
    // continue response
    if (!response.isContinueResponse) {
        [self safeAsyncOnMainThread:^{
            if (!batchRequest || batchRequest.enableAPIPresenters) {
                [api.presenter apiHideBeginHUD:api];
            }
        }];
        return;
    }
    void (^requestCompletionBlock)(YCResponseModel *) = ^(YCResponseModel *response) {
        
        api.loading = NO;
        if ([response isSuccess]) {
            // api success
            [self handleSuccessWithResponse:response api:api fromBatchRequest:batchRequest];
        } else {
            
            // api canceled
            if (response.sessionTask.error.code == -999) {
                if (!batchRequest || batchRequest.enableAPIPresenters) {
                    [api.presenter apiHideBeginHUD:api];
                }
            }
            else {
                // api failure
                [self handleFailureWithResponse:response api:api fromBatchRequest:batchRequest];
            }
        }
    };
    
    [self safeAsyncOnMainThread:^{
        requestCompletionBlock(response);
    }];
}

#pragma mark - success handler
- (void)handleSuccessWithResponse:(YCResponseModel *)response
                              api:(YCBaseAPI *)api
                 fromBatchRequest:(YCBatchAPIRequest *)batchRequest{
    // for api hud
    if (!batchRequest || batchRequest.enableAPIPresenters) {
        [api.presenter api:api showSuccessHUD:response.responseObject];
    }
    
    // for api
    BOOL valid = [api beforePerformSuccessWithResponse:response.responseObject];
    if (!valid) return;
    
    if (api.apiSuccessHandler) {
        
        id reformedResponse = response.responseObject;
        
        if (api.dataReformer) {
            
            // get reformed response from reformer (delegete)
            reformedResponse = [api.dataReformer api:api reformResponse:reformedResponse];
        }else {
            reformedResponse = [api apiReformResponse:reformedResponse];
        }
        api.apiSuccessHandler(api, reformedResponse);
    }
    
    [api afterPerformSuccessWithResponse:response.responseObject];
}

#pragma mark - failure handler
- (void)handleFailureWithResponse:(YCResponseModel *)response
                              api:(YCBaseAPI *)api
                 fromBatchRequest:(YCBatchAPIRequest *)batchRequest{
    // for failure api hud
    if (!batchRequest || batchRequest.enableAPIPresenters) {
        [api.presenter api:api showFailureHUD:response.error];
    }
    
    // cancel unfinished api request from batch request
    if (batchRequest && batchRequest.cancelUnfinishedRequestWhenAnyAPIFailed) {
        for (YCBaseAPI *subapi in batchRequest.apisSet) {
            if (![subapi isEqual:api]) {
                [subapi cancel];
            }
        }
    }
    // get last error for batch request
    if (batchRequest) {
        batchRequest.error = response.error;
    }
    // for api
    BOOL valid = [api beforePerformFailureWithResponse:response.responseObject];
    if (!valid) return;
    
    if (api.apiFailureHandler) {
        api.apiFailureHandler(api, response.error);
    }

    
    [api afterPerformFailureWithResponse:response.responseObject];
}


#pragma mark - thread safe
- (void)safeAsyncOnMainThread:(void(^)(void))action {
    if ([[NSThread currentThread] isMainThread]) {
        action();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            action();
        });
    }
}

- (void)cancelRequestWithRequestId:(NSInteger)requestId {
    
    @synchronized (self) {
        NSNumber *key = @(requestId);
        NSURLSessionTask *task = self.requestTaskMap[key];
        [self.requestTaskMap removeObjectForKey:key];
        if (task) {
            [task cancel];
        }
    }
}

- (void)cancelAllRequest {
    
    @synchronized (self) {
        [self.requestTaskMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSURLSessionTask * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        [self.requestTaskMap removeAllObjects];
    }
}

@end
