//
//  YCBatchAPIRequest.h
//  YCAPIKit
//
//  Created by haima on 2019/6/6.
//

#import <Foundation/Foundation.h>
#import "YCBaseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface YCBatchAPIRequest : NSObject<YCAPIProtocol>
{
    @package;
    BOOL _canceled;
}

/* 批量请求集合 */
@property (nonatomic, strong, readonly) NSMutableSet<YCBaseAPI *> *apisSet;

/**
 是否在加载
 
 只要有一个api在加载，就为yes
 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

/**
 HUD展示者
 
 展示批量api请求的HUD
 */
@property (nonatomic, strong) id<YCAPIHUDPresenter> presenter;

/**
 请求错误信息
 
 返回最后一个执行错误回调的api返回的错误
 */
@property (strong, nonatomic) NSError *error;

/**
 请求成功回调
 
 所有api请求成功，才会调用此回调
 */
@property (nonatomic, strong) void(^requestSuccessHandler)(YCBatchAPIRequest *request);

/**
 请求失败回调
 
 任意api请求失败，就会调用此回调
 */
@property (nonatomic, strong) void(^requestFailureHandler)(YCBatchAPIRequest *request, NSError *error);


/**
 一个api请求失败后，是否取消剩余api
 
 默认yes
 */
@property (assign, nonatomic) BOOL cancelUnfinishedRequestWhenAnyAPIFailed;

/**
 是否使能batch api的presenter
 
 默认no，一般会使用当前类的presenter，而把subapi的presenter给禁止掉
 */
@property (assign, nonatomic) BOOL enableAPIPresenters;


/**
 添加subapi,不支持分页api
 
 @param api 需要批量请求的api
 */
- (void)addAPIRequest:(YCBaseAPI *)api;


/**
 批量添加subapi，不支持分页api
 
 @param apis 需要批量请求的所有api
 */
- (void)addBatchAPIRequests:(id <NSFastEnumeration>)apis;

@end

NS_ASSUME_NONNULL_END
