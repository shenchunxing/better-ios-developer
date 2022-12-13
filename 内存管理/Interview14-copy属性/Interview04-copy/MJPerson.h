//
//  MJPerson.h
//  Interview04-copy
//
//  Created by MJ Lee on 2018/6/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPerson : NSObject
@property (copy, nonatomic) NSMutableArray *array;
@property (strong, nonatomic) NSArray *data;
@end
