//
//  MJProxy2.h
//  Interview03-定时器
//
//  Created by 沈春兴 on 2023/2/28.
//  Copyright © 2023 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MJProxy2 : NSProxy

+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
