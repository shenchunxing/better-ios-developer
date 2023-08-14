//
//  YCRequestModel.h
//  YCNetworking
//
//  Created by haima on 2019/3/26.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

/**
 请求体
 */

typedef NS_ENUM (NSUInteger, YCHttpRequestType){
    YCHttpRequestTypeGet,                       //get请求
    YCHttpRequestTypePost,                      //POST请求
    YCHttpRequestTypePostUpload,                //文件上传请求
    YCHttpRequestTypeGETDownload,               //下载文件请求，不做返回值解析
    YCHttpRequestTypeSOAPPost,                 //soap post请求
    YCHttpRequestTypePut,
    YCHttpRequestTypeHead,
    YCHttpRequestTypeDelete
    
};

typedef NS_ENUM(NSUInteger, YCRequestSerializerType) {
    YCRequestSerializerTypeJson,            //json请求序列号
    YCRequestSerializerTypeHttp,            //http请求序列号
};
NS_ASSUME_NONNULL_BEGIN

@interface YCRequestModel : NSObject

/* 请求超时时间 默认20s */
@property (nonatomic, assign) float timeout;
/* 请求方法 */
@property (nonatomic, assign) YCHttpRequestType requestType;
/* 请求序列化类型 默认json */
@property (nonatomic, assign) YCRequestSerializerType serializerType;
/* 根地址 */
@property (nonatomic, nonnull, copy) NSString * serverRoot;
/* 端口名 */
@property (nonatomic, copy) NSString *portName;
/* api版本 */
@property (nonatomic, nullable, copy) NSString *apiVersion;
/* 服务名 */
@property (nonatomic, nonnull, copy) NSString * serviceName;
/* 服务路径 */
@property (nonatomic, nonnull, copy) NSString * actionPath;
/* 请求参数 */
@property (nonatomic, nullable, copy) NSDictionary *parameters;

/* body */
@property (nonatomic, nullable, copy) id bodyData;

/* 上传数据处理 */
@property (nonatomic, nullable, copy) void(^constructingBodyWithBlock)(id<AFMultipartFormData>  _Nonnull formData);
//根据服务路径生成requestmodel
+ (instancetype)modelWithActionPath:(const NSString *)actionPath;
@end

NS_ASSUME_NONNULL_END
