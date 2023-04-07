//
//  main.m
//  Interview01-class
//
//  Created by MJ Lee on 2018/5/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"
#import <objc/runtime.h>

//@implementation NSObject
//
//- (BOOL)isMemberOfClass:(Class)cls {
//    return [self class] == cls;
//}
//
//- (BOOL)isKindOfClass:(Class)cls {
//    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
//        if (tcls == cls) return YES;
//    }
//    return NO;
//}
//
//
//+ (BOOL)isMemberOfClass:(Class)cls {
//    return object_getClass((id)self) == cls;
//}
//
//
//+ (BOOL)isKindOfClass:(Class)cls {
//    for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
//        if (tcls == cls) return YES;
//    }
//    return NO;
//}
//@end

//void test(id obj)
//{
//    if ([obj isMemberOfClass:[MJPerson class]]) {
//
//    }
//}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //isKindOfClass: 如果是instance类型，则类对象开始查找，没找到从instance的类对象的父类继续查找 ，       如果是class类型，则从元类开始查找，没找到从当前class的元类对象的父类继续查找。
        //isMemberOfClass：当前instance的类对象是否是传入的class ，当前class的元类对象是是否是传入的class。
        
        //NSObject的metaclass是NSObject: [object_getClass([NSObject class]) superclass] == [NSObject class] :
        //NSObject元类的superclass就是NSObject
        //比较的左侧是对象,右侧就应该是类
        //比较的左侧是类,右侧就是元类
        NSLog(@"%d", [[NSObject class] isKindOfClass:[NSObject class]]); //1
        //object_getClass([NSObject class]) != [NSObject class]
        NSLog(@"%d", [[NSObject class] isMemberOfClass:[NSObject class]]);//0
        NSLog(@"%d", [[MJPerson class] isKindOfClass:[MJPerson class]]);//0
        NSLog(@"%d", [[MJPerson class] isMemberOfClass:[MJPerson class]]);//0
        NSLog(@"-------------");
        
        // 这句代码的方法调用者不管是哪个类（只要是NSObject体系下的），都返回YES
        NSLog(@"%d", [NSObject isKindOfClass:[NSObject class]]); // 1
        NSLog(@"%d", [NSObject isMemberOfClass:[NSObject class]]); // 0
        NSLog(@"%d", [MJPerson isKindOfClass:[MJPerson class]]); // 0
        NSLog(@"%d", [MJPerson isMemberOfClass:[MJPerson class]]); // 0
        
        NSLog(@"-------------");
        id person = [[MJPerson alloc] init];
        NSLog(@"%d", [person isMemberOfClass:[MJPerson class]]); //1
        NSLog(@"%d", [person isMemberOfClass:[NSObject class]]);//0
        NSLog(@"%d", [person isKindOfClass:[MJPerson class]]);//1
        NSLog(@"%d", [person isKindOfClass:[NSObject class]]);//1
        NSLog(@"%d", [MJPerson isMemberOfClass:object_getClass([MJPerson class])]);//1
        NSLog(@"%d", [MJPerson isKindOfClass:object_getClass([NSObject class])]);//1
        NSLog(@"%d", [MJPerson isKindOfClass:[NSObject class]]);//1
    }
    return 0;
}
