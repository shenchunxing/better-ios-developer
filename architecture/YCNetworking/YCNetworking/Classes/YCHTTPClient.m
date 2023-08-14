//
//  YCHTTPClient.m
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import "YCHTTPClient.h"
#import "YCRequestModel.h"
#import "YCResponseModel.h"
#import "YCRequestURLSerializer.h"
#import "YCNetworkConfig.h"
#import "YCRequestParamConstructor.h"

static YCHTTPClient *instance = nil;

static NSTimeInterval kYCNetworkingTimeout = 20.0;
static NSTimeInterval kYCNetworkingFileTimeout = 1800.0;

@interface YCHTTPClient ()
/* 是否有网络 */
@property (nonatomic, assign) BOOL whetherHaveNetwork;
@end

@implementation YCHTTPClient

+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        instance = [[YCHTTPClient alloc] initWithSessionConfiguration:defaultConfig];
                
        //请求序列化，默认使用AFHTTPRequestSerializer
        //配置
        instance.requestSerializer = [AFJSONRequestSerializer serializer];
        instance.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        
        //默认只支持json
        [instance.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        instance.requestSerializer.timeoutInterval = kYCNetworkingTimeout;
        
        //响应序列化
        instance.responseSerializer = [AFJSONResponseSerializer serializer];
        //处理网络请求的返回的数据Null问题
        ((AFJSONResponseSerializer *)instance.responseSerializer).removesKeysWithNullValues = YES;
        instance.whetherHaveNetwork = YES;
        //配置服务器地址
        kProjectAPIRoot = kYCProjectAPIRoot;
    });
    return instance;
}



- (nonnull NSURLSessionTask *)sendRequestWithRequestModel:(nonnull YCRequestModel *)requestModel
                                                     progress:(nullable void (^)(NSProgress *_Nullable progress))progressBlock
                                                     callback:(nullable void (^)(YCResponseModel *_Nullable responseModel))callback {
    
    
    NSParameterAssert(requestModel.serverRoot.length > 0);
    NSParameterAssert(requestModel.serviceName.length > 0);
    
    NSURLSessionTask *sessionTask = nil;
    if (!self.whetherHaveNetwork) {
        YCResponseModel *responseModel = [[YCResponseModel alloc] init];
        responseModel.sessionTask = sessionTask;
        callback(responseModel);
        return sessionTask;
    }
    
    if (self.proxy && [self.proxy respondsToSelector:@selector(beforeRequestSendWithRequestObject:)]) {
        !self.proxy?:[self.proxy beforeRequestSendWithRequestObject:requestModel];
    }
    
    //URL解析
    NSString *urlString = [YCRequestURLSerializer URLForRequest:requestModel];
    //参数解析
    NSMutableDictionary *mutableParameters = [YCRequestParamConstructor parametersForRequest:requestModel];
    NSDictionary *headers = [YCRequestParamConstructor headersForRequest:requestModel].copy;
    NSDictionary *parameters = [mutableParameters copy];
    
    
    //设置请求序列化，jsonh和http，默认json
    switch (requestModel.serializerType) {
        case YCRequestSerializerTypeJson:
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
            [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            break;
        case YCRequestSerializerTypeHttp:
            self.requestSerializer = [AFHTTPRequestSerializer serializer];
            self.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
            [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            break;
    }
    //请求超时时间设置
    if (requestModel.timeout > kYCNetworkingTimeout) {
        self.requestSerializer.timeoutInterval = requestModel.timeout;
    }
    //根据请求类型：get or post 设置超时时间
    if (requestModel.requestType == YCHttpRequestTypeGet || requestModel.requestType == YCHttpRequestTypePost) {
        self.requestSerializer.timeoutInterval = requestModel.timeout > kYCNetworkingTimeout ? requestModel.timeout : kYCNetworkingTimeout;
    }else {
        self.requestSerializer.timeoutInterval = kYCNetworkingFileTimeout;
    }
    
    //成功回调，返回YCResponseModel
    void (^successBlock)(NSURLSessionTask *, id) = ^(NSURLSessionTask *task, id response) {
        
        YCResponseModel *responseModel = [[YCResponseModel alloc] init];
        responseModel.responseObject = response;
        responseModel.sessionTask = task;
        
        if (self.proxy && [self.proxy respondsToSelector:@selector(shouldContinueResponse:withResponseObject:)]) {
            //判断是否需要中断处理
            responseModel.isContinueResponse = [self.proxy shouldContinueResponse:responseModel withResponseObject:response];
        }
        
        if(callback) {
            callback(responseModel);
        }
        //只要不是下载文件，就需要设置cookie
        if (requestModel.requestType != YCHttpRequestTypeGETDownload) {
            [self setCookieWithResponse:task.response];
        }
    };
    
    //失败回调，返回YCResponseModel
    void (^failureBlock)(NSURLSessionTask *, NSError *) = ^(NSURLSessionTask *task, NSError *error) {
        
        YCResponseModel *responseModel = [[YCResponseModel alloc] init];
        responseModel.sessionTask = task;
        
        if(callback) {
            callback(responseModel);
        }
        //只要不是下载文件，就需要设置cookie
        if (requestModel.requestType != YCHttpRequestTypeGETDownload) {
            [self setCookieWithResponse:task.response];
        }
    };
    
    
    //这里进行真正的请求
    switch (requestModel.requestType) {
            //get
            case YCHttpRequestTypeGet:
                
                sessionTask =  [self GET:urlString parameters:parameters headers:headers progress:progressBlock success:successBlock failure:failureBlock];
            break;
            //文件下载
            case YCHttpRequestTypeGETDownload: {
            
                NSURLRequest *request = [instance.requestSerializer requestWithMethod:@"GET" URLString:urlString parameters:parameters error:nil];
                sessionTask =[self downloadTaskWithRequest:request progress:progressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    
                    NSString *fullPath =  [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:response.suggestedFilename];
                    return [NSURL fileURLWithPath:fullPath];
                    //完成回调
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    
                    if (error) {
                        failureBlock(sessionTask, error);
                    }else{
                        successBlock(sessionTask, filePath);
                    }
                    
                }];
            }
            break;
            //post
            case YCHttpRequestTypePost: {
                
                if (requestModel.bodyData) {
                    sessionTask = [self POST:urlString parameters:requestModel.bodyData headers:headers progress:progressBlock success:successBlock failure:failureBlock];
                }else{
                    sessionTask = [self POST:urlString parameters:parameters headers:headers progress:progressBlock success:successBlock failure:failureBlock];

                }
            }
            
            break;
            //文件上传
            case YCHttpRequestTypePostUpload:
            
                sessionTask = [self POST:urlString parameters:parameters headers:headers constructingBodyWithBlock:requestModel.constructingBodyWithBlock progress:progressBlock success:successBlock failure:failureBlock];
            
            break;
            
            case YCHttpRequestTypeSOAPPost:
            //TODO:soap post
                
            break;
        case YCHttpRequestTypePut: {
            
            sessionTask = [self PUT:urlString parameters:parameters headers:headers success:successBlock failure:failureBlock];
        }
            break;
            case YCHttpRequestTypeHead: {
                sessionTask = [self HEAD:urlString parameters:parameters headers:headers success:^(NSURLSessionDataTask * _Nonnull task) {
                    successBlock(task,nil);
                } failure:failureBlock];
        }
            break;
        case YCHttpRequestTypeDelete: {
                sessionTask = [self DELETE:urlString parameters:parameters headers:headers success:successBlock failure:failureBlock];
        }
                break;
    }
    
    return sessionTask;
}

- (NSURLSessionTask *)sendRequestWithRequestModel:(YCRequestModel *)requestModel callback:(void (^)(YCResponseModel * _Nullable))callback
{
    return [self sendRequestWithRequestModel:requestModel progress:nil callback:callback];
}

//设置cookie
- (void)setCookieWithResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *cookieString = [[httpResponse allHeaderFields] valueForKey:@"Set-Cookie"];
    if(cookieString.length>0){
        NSString *sidStr1 = [[cookieString componentsSeparatedByString:@"sid="] lastObject];
        NSString *sid = [[sidStr1 componentsSeparatedByString:@";"] firstObject];
        if (![sid containsString:@"deleteMe"]) {
            [[NSUserDefaults standardUserDefaults] setObject:cookieString forKey:@"YCHttpCookie"];
            [[NSUserDefaults standardUserDefaults]  synchronize];
        }
        
    }
}


- (void)checkNetworkAvailable:(void(^)(BOOL isAvailable))block {
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            self.whetherHaveNetwork = NO;
        }else {
            self.whetherHaveNetwork = YES;
        }
        !block?:block(self.whetherHaveNetwork);
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
