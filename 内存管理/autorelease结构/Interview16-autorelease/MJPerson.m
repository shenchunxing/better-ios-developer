//
//  MJPerson.m
//  Interview16-autorelease
//
//  Created by MJ Lee on 2018/7/2.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson
- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    [super dealloc];
}
@end
