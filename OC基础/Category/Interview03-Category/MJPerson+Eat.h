//
//  MJPerson+Eat.h
//  Interview03-Category
//
//  Created by MJ Lee on 2018/5/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@interface MJPerson (Eat) <NSCopying, NSCoding>

- (void)eat;

@property (assign, nonatomic) int weight;
@property (assign, nonatomic) double height;

@end
