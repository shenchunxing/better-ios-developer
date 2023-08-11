//
//  MJPerson.h
//  Interview01-Category的成员变量
//
//  Created by MJ Lee on 2018/5/9.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

//struct MJPerson_IMPL
//{
//    Class isa;
//    int _age;
//};

@interface MJPerson : NSObject
//{
//    int _age;
//}
//
//- (void)setAge:(int)age;
//- (int)age;

@property (assign, nonatomic) int age;

@end
