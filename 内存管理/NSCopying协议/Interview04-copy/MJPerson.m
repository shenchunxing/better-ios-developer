//
//  MJPerson.m
//  Interview04-copy
//
//  Created by MJ Lee on 2018/6/28.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson

- (id)copyWithZone:(NSZone *)zone
{
    MJPerson *person = [[MJPerson allocWithZone:zone] init];
    person.age = self.age;
//    person.weight = self.weight;
    return person;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"age = %d, weight = %f", self.age, self.weight];
}

@end
