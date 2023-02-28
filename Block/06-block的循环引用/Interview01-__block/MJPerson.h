//
//  MJPerson.h
//  Interview01-__block
//
//  Created by MJ Lee on 2018/5/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MJBlock) (void);

@interface MJPerson : NSObject
@property (copy, nonatomic) MJBlock block;
@property (assign, nonatomic) int age;

- (void)test;
@end
