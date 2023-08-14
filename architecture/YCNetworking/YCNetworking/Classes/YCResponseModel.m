//
//  YCResponseModel.m
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import "YCResponseModel.h"

NSString *const kNetworkingErrorCode = @"code";
NSString *const kNetworkErrorDomain  = @"kNetworkErrorDomain";

@implementation YCResponseModel

- (BOOL)isSuccess {

    //TODO:网络响应结果判断逻辑需要完善
    if (self.responseObject) {
        
       //成功
        if([[self.responseObject objectForKey:@"message"] isEqualToString:@"ok"] ||
           [[self.responseObject objectForKey:@"resultCode"] integerValue] == 200 ||
           [[self.responseObject objectForKey:@"success"] integerValue] !=0){
            self.dataObject = [self.responseObject objectForKey:@"data"];
            //有些返回datas
            if ([self.responseObject objectForKey:@"datas"]) {
                self.dataObject = [self.responseObject objectForKey:@"datas"];
            }
            return YES;
            
        }else {
           
            //失败
            NSNumber *code = [self.responseObject objectForKey:@"success"];
            if ([code integerValue] == 0) {
                //MARK:接口输出消息不一致
                NSString *message = @"请求出错";
                for (NSString *key in @[@"msg",@"message"]) {
                    if (self.responseObject[key]) {
                        message = self.responseObject[key];
                        break;
                    }
                }
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                userInfo[NSLocalizedDescriptionKey] = message;
                userInfo[kNetworkingErrorCode] = self.responseObject[kNetworkingErrorCode];
                self.error = [NSError errorWithDomain:kNetworkErrorDomain code:[code integerValue] userInfo:userInfo];
                return NO;
            }
        }
    }
    
    if (!self.error) {
        //无网络，或网络出错
        self.error = [NSError errorWithDomain:kNetworkErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"网络出错",kNetworkingErrorCode:@"EC00000000"}];
    }
    
    return NO;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.isContinueResponse = YES;
    }
    return self;
}

@end
