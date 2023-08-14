//
//  YCRequestURLSerializer.m
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import "YCRequestURLSerializer.h"
#import "YCRequestModel.h"
#import "YCHTTPClient.h"

@implementation YCRequestURLSerializer

+ (NSString *)URLForRequest:(YCRequestModel *)request {
    
    NSString *urlString = request.serverRoot;
    
    if (request.portName.length > 0) {
        urlString = [urlString stringByAppendingFormat:@"/%@", request.portName];
    }
    
    if (request.apiVersion.length > 0) {
       urlString = [urlString stringByAppendingFormat:@"/%@", request.apiVersion];
    }
    
    if (request.serviceName.length > 0) {
        urlString = [urlString stringByAppendingFormat:@"/%@", request.serviceName];
    }
    
    if (request.actionPath.length > 0) {
        urlString = [urlString stringByAppendingFormat:@"/%@", request.actionPath];
    }

    NSURL *url = [NSURL URLWithString:urlString];
    
    return url.absoluteString;
}

@end
