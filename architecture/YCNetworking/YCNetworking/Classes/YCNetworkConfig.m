//
//  YCNetworkConfig.m
//  YCNetworking
//
//  Created by haima on 2019/5/30.
//

#import "YCNetworkConfig.h"

NSString *kProjectAPIRoot = @"http://192.168.2.16";

@implementation YCNetworkConfig

+ (instancetype)shared {
    
    static YCNetworkConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YCNetworkConfig alloc] init];
    });
    return instance;
}

- (instancetype)init{
    
    self = [super init];
    if (self) {
        // 其他业务线可以选择创建分类文件放进主工程
        if (![self conformsToProtocol:@protocol(YCNetworkConfigInitialProtocol)]) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"You should implement a category of YCNetworkConfig class and then conform the <YCNetworkConfigInitialProtocol> protocol to init all ivars in -initDefaultsInformation method" userInfo:nil];
        }
        
        [(id <YCNetworkConfigInitialProtocol>)self initConfig];
    }
    return self;
}
@end
