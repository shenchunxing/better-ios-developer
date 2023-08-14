//
//  YCRequestModel.m
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import "YCRequestModel.h"
#import "YCNetworkConfig.h"

@implementation YCRequestModel

+ (instancetype)modelWithActionPath:(const NSString *)actionPath {
    
    YCRequestModel *model = [[self alloc] init];
    model.actionPath = (NSString *)actionPath;
    return model;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.requestType = YCHttpRequestTypeGet;
        self.serverRoot = kProjectAPIRoot;
        self.portName = kYCPortName;
        self.apiVersion = @"v1";
        self.serializerType = YCRequestSerializerTypeJson;
    }
   return self;
}

- (NSString *)convertURLPart:(NSString *)urlPart {
    NSMutableString  *mutableString = [urlPart mutableCopy];
    
    if ([mutableString hasPrefix:@"/"]) {
        [mutableString deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    if ([mutableString hasSuffix:@"/"]) {
        [mutableString deleteCharactersInRange:NSMakeRange(mutableString.length - 1, 1)];
    }
    
    return [mutableString copy];
}

- (void)setServerRoot:(NSString *)serverRoot {
    _serverRoot = [self convertURLPart:serverRoot];
}

- (void)setPortName:(NSString *)portName {
    _portName = [self convertURLPart:portName];
}

- (void)setApiVersion:(NSString *)apiVersion {
    _apiVersion = [self convertURLPart:apiVersion];
}

- (void)setServiceName:(NSString *)serviceName {
    _serviceName = [self convertURLPart:serviceName];
}

- (void)setActionPath:(NSString *)actionPath {
    _actionPath = [self convertURLPart:actionPath];
}


@end
