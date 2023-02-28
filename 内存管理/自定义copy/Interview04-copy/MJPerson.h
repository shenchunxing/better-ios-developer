//
//  MJPerson.h
//  Interview04-copy
//
//  Created by MJ Lee on 2018/6/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPerson : NSObject <NSCopying>
@property (assign, nonatomic) int age;
@property (assign, nonatomic) double weight;
@end
