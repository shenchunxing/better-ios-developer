//
//  NSObject+Json.h
//  Interview02-runtime应用
//
//  Created by MJ Lee on 2018/5/29.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Json)

+ (instancetype)mj_objectWithJson:(NSDictionary *)json;

@end
