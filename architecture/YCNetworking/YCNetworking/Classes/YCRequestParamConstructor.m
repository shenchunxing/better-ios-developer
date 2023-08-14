//
//  YCRequestParamConstructor.m
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import "YCRequestParamConstructor.h"
#import "YCRequestModel.h"
#import "YCNetworkConfig.h"
#import <YCDataCenter/YCDataCenter.h>

@implementation YCRequestParamConstructor

+ (NSMutableDictionary *)parametersForRequest:(YCRequestModel *)requestModel {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    //添加业务参数
    [params addEntriesFromDictionary:requestModel.parameters];
    
    return params;
}

+ (NSMutableDictionary *)headersForRequest:(YCRequestModel *)requestModel {
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    //添加共通参数
    headers[@"token"] = [[YCDataCenter sharedData] getObjectByKey:@"token"];
    headers[@"system"] = kYCSystem;
    return headers;
}


+ (NSString *)yc_operateId {
    //TODO:添加操作id
    return @"";
}

+ (NSString *)yc_operateName {
    //TODO:添加操作名
    return @"";
}

+ (NSString *)yc_roleName {
    return @"";
}

@end
