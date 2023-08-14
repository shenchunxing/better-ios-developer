//
//  YCNetworkConfig.h
//  YCNetworking
//
//  Created by haima on 2019/5/30.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * _Nonnull kProjectAPIRoot;

#define YC_NC_FOR_KEY(key) \
({ \
id value = [YCNetworkConfig shared].key; \
NSAssert(value, @"%@ can not be nil, you should setup it in YCNetworkConfig init category.", @#key); \
value; \
})

#define YC_NC_SET_API(value)\
[YCNetworkConfig shared].projectAPIRoot = value;

#define kYCProjectAPIRoot YC_NC_FOR_KEY(projectAPIRoot)
#define kYCSystem YC_NC_FOR_KEY(system)
#define kYCPortName YC_NC_FOR_KEY(portName)

NS_ASSUME_NONNULL_BEGIN
@protocol YCNetworkConfigInitialProtocol <NSObject>
@required
- (void)initConfig;
@end

@interface YCNetworkConfig : NSObject

/* api root地址 */
@property (nonatomic, copy) NSString *projectAPIRoot;

/* 系统 */
@property (nonatomic, copy) NSString *system;

/* 端口 */
@property (nonatomic, copy) NSString *portName;

+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
