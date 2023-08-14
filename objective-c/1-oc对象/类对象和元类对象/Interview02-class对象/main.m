//
//  main.m
//  Interview02-class对象
//
//  Created by MJ Lee on 2018/4/8.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface MJPerson : NSObject
{
    int _age;
    int _height;
    int _no;
}
@end

@implementation MJPerson

@end

//为什么存在元类的设计？从面向对象的设计理念来说，万物皆对象，类也是对象，描述类的元类，存在的目的就是自上而下的逻辑自洽，也方便message的传递。

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // instance对象，实例对象
        NSObject *object1 = [[NSObject alloc] init];
        NSObject *object2 = [[NSObject alloc] init];
        
        // class对象，类对象
        // class方法返回的一直是class对象，类对象
        Class objectClass1 = [object1 class];
        Class objectClass2 = [object2 class];
        Class objectClass3 = object_getClass(object1);
        Class objectClass4 = object_getClass(object2);
        Class objectClass5 = [NSObject class];
        
        NSLog(@"class - %p %p %p %p %p %d", //打印一样的地址，都是类对象
              objectClass1,
              objectClass2,
              objectClass3,
              objectClass4,
              objectClass5,
              class_isMetaClass(objectClass3)); //不是元类对象，返回false
    
        // meta-class对象，元类对象
        // 将类对象当做参数传入，获得元类对象
        Class objectMetaClass = object_getClass(objectClass5);
        //class返回的方法就是一直是类对象
        Class objectMetaClass2 = [[[NSObject class] class] class];
        NSLog(@"objectMetaClass是一个元类 - %p %d", objectMetaClass, class_isMetaClass(objectMetaClass)); //元类
        NSLog(@"objectMetaClass2不是元类 - %p %d", objectMetaClass2, class_isMetaClass(objectMetaClass2)); //不是元类
        
        
        NSLog(@"objectMetaClass的元类是：%p",object_getClass(objectMetaClass)); //NSObject的元类的元类是其本身
        NSLog(@"objectMetaClass的父类是：%p",class_getSuperclass(objectMetaClass)); //NSObject的元类的父类是NSObject类对象
    }
    return 0;
}


/*
 1.Class objc_getClass(const char *aClassName)
 1> 传入字符串类名
 2> 返回对应的类对象
 
 2.Class object_getClass(id obj)
 1> 传入的obj可能是instance对象、class对象、meta-class对象
 2> 返回值
 a) 如果是instance对象，返回class对象
 b) 如果是class对象，返回meta-class对象
 c) 如果是meta-class对象，返回NSObject（基类）的meta-class对象
 
 3.- (Class)class、+ (Class)class
 1> 返回的就是类对象
 
 - (Class) {
     return self->isa;
 }
 
 + (Class) {
     return self;
 }
 */
