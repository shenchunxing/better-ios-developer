//
//  YCValidatableProtocol.h
//  Pods
//
//  Created by haima on 2019/4/19.
//

#ifndef YCValidatableProtocol_h
#define YCValidatableProtocol_h



/**
 校验block
 
 @param value 校验对象
 @return 成功 YES  失败NO
 */
typedef BOOL (^YCFormatValidBlock)(id value);

@protocol YCValidatableProtocol <NSObject>
@required

//验证是否为空
- (BOOL)valid;

- (NSString *)validatedTitle;
@end


/**
 格式验证
 */
@protocol YCFormatValidatableProtocol <YCValidatableProtocol>
@required

/** 校验对象 */
- (id)validatedObject;

/** 校验block */
- (void)setFormatValidBlock:(YCFormatValidBlock)formatValidBlock;
- (YCFormatValidBlock)formatValidBlock;

//@property (copy, nonatomic) TDFFormatValidBlock formatValidBlock;
@optional
/**
 校验信息（优先级比validatedTitle高）
 校验出错时显示
 */
- (NSString *)validatedMessage;
- (void)setValidatedMessage:(NSString *)validatedMessage;
@end

#endif /* YCValidatableProtocol_h */
