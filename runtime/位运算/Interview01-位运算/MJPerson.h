//
//  MJPerson.h
//  Interview01-位运算
//
//  Created by MJ Lee on 2018/5/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPerson : NSObject

// "i24@0:8i16f20"
// 0id 8SEL 16int 20float  == 24
- (int)test:(int)age height:(float)height;
@end
