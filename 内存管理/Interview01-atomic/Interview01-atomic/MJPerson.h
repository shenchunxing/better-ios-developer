//
//  MJPerson.h
//  Interview01-atomic
//
//  Created by MJ Lee on 2018/6/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJPerson : NSObject
@property (assign, nonatomic) int age;
@property (copy, atomic) NSString *name;
@property (strong, atomic) NSMutableArray *data;
@end

/*
 nonatomic和atomic
 atom：原子，不可再分割的单位
 atomic：原子性
 
 给属性加上atomic修饰，可以保证属性的setter和getter都是原子性操作，也就是保证setter和gette内部是线程同步的
 
 // 加锁
 int a = 10;
 int b = 20;
 int c = a + b;
 // 解锁
 
 */
