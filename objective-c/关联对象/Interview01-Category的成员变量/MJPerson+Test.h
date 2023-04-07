//
//  MJPerson+Test.h
//  Interview01-Category的成员变量
//
//  Created by MJ Lee on 2018/5/9.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@interface MJPerson (Test) {
//    int value; //直接报错,1.因为category底层没有成员变量列表,2.而且如果可以添加则MJPerson类结构里面的class_ro_t里面的instaceSize会跟着变,内存结构都发生了变化,这是不合理的
}
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) int weight;

@end
