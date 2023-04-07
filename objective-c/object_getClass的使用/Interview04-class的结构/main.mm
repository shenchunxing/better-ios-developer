//
//  main.m
//  Interview04-class的结构
//
//  Created by MJ Lee on 2018/4/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//
// objective-c++
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Person.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //类对象
        NSObject *obj1 = [[NSObject alloc] init];
        NSObject *obj2 = [[NSObject alloc] init];
        Class c1 = [obj1 class];
        Class c2 = [obj2 class];
        Class c3 = [NSObject class];
        Class c4 = object_getClass(obj1);
        Class c5 = object_getClass(obj2);
        
        NSLog(@"obj1 = %p",obj1); //0x1012acb10
        NSLog(@"obj2 = %p",obj2);//0x1012ac880
        NSLog(@"c1 = %p",c1); //0x1fc49ffc8
        NSLog(@"c2 = %p",c2);//0x1fc49ffc8
        NSLog(@"c3 = %p",c3);//0x1fc49ffc8
        NSLog(@"c4 = %p",c4);//0x1fc49ffc8
        NSLog(@"c5 = %p",c5);//0x1fc49ffc8
        
        
        NSLog(@"--------------------------------------------");
        
        NSObject *obj3 = [[NSObject alloc] init];
        Class cls1 = object_getClass([NSObject class]); //元类地址0x1fc49ffa0
        Class cls2 = [[NSObject class] class]; //类地址0x1fc49ffc8
        Class cls3 = [[obj3 class] class];//类地址0x1fc49ffc8
        NSLog(@"cls1 = %p,cls2 = %p,cls3 = %p",cls1 ,cls2,cls3);
        
        
        NSLog(@"--------------------------------------------");
        
       
        Person *p           = [[Person alloc] init];
        Class  class1       = object_getClass(p); // 获取p ---> 类对象
        Class  class2       = [p class];  // 获取p ---> 类对象
        NSLog(@"class1 === %p class1Name == %@ class2 === %p class2Name == %@",class1,class1,class2,class2);
        
        /** 元类查找过程 */
        Class  class3       = objc_getMetaClass(object_getClassName(p)); // 获取p ---> 元类
        NSLog(@"class3 == %p class3Name == %@",class3,class3);
        
        Class  class4       = objc_getMetaClass(object_getClassName(class3)); // 获取class3 ---> 元类  此时的元类，class4就是根元类。
        NSLog(@"class4 == %p class4Name == %@",class4,class4); // class4 == 0x106defe78 class4Name == NSObject
        
        
        /** 元类查找结束，至此。我们都知道 根元类 的superClass指针是指向 根类对象 的；根类对象的isa指针有指向根元类对象；根元类对象的isa指针指向根元类自己；根类对象的superClass指针指向nil */
        Class  class5       = class_getSuperclass(class1);  // 获取 类对象的父类对象
        NSLog(@"class5 == %p class5Name == %@",class5,class5);  //class5 == 0x106defec8 class5Name == NSObject

        // 此时返现class5 已经是NSObject，我们再次获取class5的父类，验证class5是否是 根类对象
        Class  class6       = class_getSuperclass(class5);  // 获取 class5的父类对象
        NSLog(@"class6 == %p class6Name == %@",class6,class6); // class6 == 0x0 class6Name == (null) 至此根类对象验证完毕。
        
        
        /** 验证根类对象与根元类对象的关系 */
        Class  class7       = objc_getMetaClass(object_getClassName(class5)); // 获取根类对象 对应的  根元类 是否是class4 对应的指针地址
        NSLog(@"class7 == %p class7Name == %@",class7,class7);  // class7 == 0x106defe78 class7Name == NSObject
        
        Class  class8      =  class_getSuperclass(class4);  // 获取根元类class4  superClass 指针的指向 是否是根类对象class5 的指针地址
        NSLog(@"class8 == %p class8Name == %@",class8,class8);  // class8 == 0x106defec8 class8Name == NSObject； class8与class5指针地址相同
        
        Class  class9       = objc_getMetaClass(object_getClassName(class4)); // 获取根元类 isa 指针是否是指向自己
        NSLog(@"class9 == %p class9Name == %@",class9,class9);  //  class9 == 0x106defe78 class9Name == NSObject； class9 与 class4、class7指针地址相同
    }
    return 0;
}
