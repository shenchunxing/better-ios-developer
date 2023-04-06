//
//  main.m
//  Interview03-Category
//
//  Created by MJ Lee on 2018/5/3.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson+Eat.h"
#import "MJPerson+Test.h"
#import "MJPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /**
         compile source按照编译顺序，后编译的会执行，并且分类的优先级比本类高
         */
        MJPerson *person = [[MJPerson alloc] init];
        [person run];
//        objc_msgSend(person, @selector(run));
        [person test];
        [person eat];
        
        
        //分类创建的属性，没有成员变量，无法保存住属性值
        person.weight = 2;
        person.height = 1;
        NSLog(@"%d %f",person.weight,person.height);
//        objc_msgSend(person, @selector(eat));
        
        // 通过runtime动态将分类的方法合并到类对象、元类对象zhong 
    }
    return 0;
}
