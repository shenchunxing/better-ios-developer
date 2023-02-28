//
//  main.m
//  Interview01-KVC
//
//  Created by MJ Lee on 2018/5/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"
#import "MJObserver.h"

void test()
{
    MJObserver *observer = [[MJObserver alloc] init];
    MJPerson *person = [[MJPerson alloc] init];
    
    // 添加KVO监听
    [person addObserver:observer forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    
    // 通过KVC修改age属性
    //setter查找顺序: - (void)setAge:(int)age   - (void)_setAge:(int)age  accessInstanceVariablesDirectly如果返回yes，使用4种成员变量的顺序返回
    [person setValue:@10 forKey:@"age"];
    // [person willChangeValueForKey:@"age"];
    // person->_age = 10;
    // [person didChangeValueForKey:@"age"];
    
    NSLog(@"%@", [person valueForKey:@"age"]);
    
    // 移除KVO监听
    [person removeObserver:observer forKeyPath:@"age"];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        //下面4种是直接通过成员变量访问的
        person->_age = 10;
        person->_isAge = 11;
        person->age = 12;
        person->isAge = 13;
        //属性访问：getter方法按照- (int)getAge  - (int)age  - (int)isAge  - (int)_age的顺序查找实现
        NSLog(@"%@", [person valueForKey:@"age"]);
        
        test();
    }
    return 0;
}



