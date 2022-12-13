//
//  MJPerson.m
//  Interview01-__block
//
//  Created by MJ Lee on 2018/5/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson
- (void)dealloc
{
    [super dealloc];
    NSLog(@"%s", __func__);
}
@end
