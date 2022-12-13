//
//  main.m
//  Interview01-isa和superclass
//
//  Created by MJ Lee on 2018/4/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "NSObject+Test.h"

// MJPerson
@interface MJPerson : NSObject <NSCopying>
{
    @public
    int _age;
}
@property (nonatomic, assign) int no;
- (void)personInstanceMethod;
+ (void)personClassMethod;
@end

@implementation MJPerson

- (void)test
{
    
}

- (void)personInstanceMethod
{
    
}
+ (void)personClassMethod
{
    
}
- (id)copyWithZone:(NSZone *)zone
{
    return nil;
}
@end

// MJStudent
@interface MJStudent : MJPerson <NSCoding>
{
@public
    int _weight;
}
@property (nonatomic, assign) int height;
- (void)studentInstanceMethod;
+ (void)studentClassMethod;
@end

@implementation MJStudent
- (void)test
{
    
}
- (void)studentInstanceMethod
{
    
}
+ (void)studentClassMethod
{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

+ (void)abc {
    
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJStudent *student = [[MJStudent alloc] init];
        
        
        
        [student test];
        

        [student personInstanceMethod];
        
        [student init];
        
        [MJStudent studentClassMethod];
        
        [MJStudent personClassMethod];
        
        [MJStudent load];
        
        [MJStudent abc]; //找不到方法报错
        
        MJPerson *person = [[MJPerson alloc] init];
        person->_age = 10;
        [person personInstanceMethod];

        [MJPerson personClassMethod];

//        objc_msgSend([MJPerson class], @selector(personClassMethod));
//        objc_msgSend(person, @selector(personInstanceMethod));

        Class personClass = [MJPerson class];

        Class personMetaClass = object_getClass(personClass);
        
        NSLog(@"%p %p %p", person, personClass, personMetaClass);
        
        
        
        //等价：objc_getClass传入的是字符串，返回类对象
        //class传入instance和class都返回类对象
        //object_getClass根据instance和class不同，返回不同
        Class pClass = objc_getClass("MJStudent");//objc_getClass传入字符串返回类的对象
        Class pClass2 = object_getClass(student);//objc_getClass传入字符串返回类的对象
        Class pClass3 = [student class];
        Class pClass4 = [MJStudent class];
        NSLog(@"%p %p %p %p",pClass,pClass2,pClass3,pClass4);
        
        
        
        
        NSLog(@"[MJPerson class] - %p", [MJPerson class]);
        NSLog(@"[NSObject class] - %p", [NSObject class]);
        
        [MJPerson test];
//        objc_msgSend([MJPerson class], @selector(test))
        
        // isa -> superclass -> suerpclass -> superclass -> .... superclass == nil
        
        [NSObject test];
//        objc_msgSend([NSObject class], @selector(test))
    }
    return 0;
}
