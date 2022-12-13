//
//  main.m
//  Interview01-load
//
//  Created by MJ Lee on 2018/5/5.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"
#import "MJStudent.h"
#import <objc/runtime.h>

void printMethodNamesOfClass(Class cls)
{
    unsigned int count;
    // 获得方法数组
    Method *methodList = class_copyMethodList(cls, &count);
    
    // 存储方法名
    NSMutableString *methodNames = [NSMutableString string];
    
    // 遍历所有的方法
    for (int i = 0; i < count; i++) {
        // 获得方法
        Method method = methodList[i];
        // 获得方法名
        NSString *methodName = NSStringFromSelector(method_getName(method));
        // 拼接方法名
        [methodNames appendString:methodName];
        [methodNames appendString:@", "];
    }
    
    // 释放
    free(methodList);
    
    // 打印方法名
    NSLog(@"%@ %@", cls, methodNames);
}


/**
 +load方法相关源码阅读顺序：

 _objc_init
 load_images
 prepare_load_methods
 schedule_class_load
 add_class_to_loadable_list
 add_category_to_loadable_list
 calls
 call_class_loads
 call_category_loads
 (*load_method)(cls, SEL_load)
 */
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSLog(@"---------------");
        /**
         优先顺序：
         先加载类的load
         再加载分类的load
         有继承关系的，先加载父类load、再加载子类的load，无继承关系的，按照编译顺序
         分类的加载顺序是完全按照编译顺序，也就是谁在前面，谁先加载。和其绑定类的继承关系无关
         即使有类的源文件，但是编译列表中没有，那么这个类就不会被编译，也就不会执行其load方法
         */
        /**
         MJDog +load
         MJPerson +load //MJStudent有继承关系的，先加载父类load、再加载子类的load
         MJStudent +load
         MJCat +load
         MJStudent (Test1) +load
         MJPerson (Test1) +load
         MJPerson (Test2) +load
         MJStudent (Test2) +load
         */
        [MJStudent load]; //这里是直接走消息机制，因此会走分类的MJStudent (Test2) +load
//        objc_msgSend();
        // isa
        // superclass
        // superclass
        
//        objc_msgSend([MJStudent class], @selector(load));
        
        // isa
        // superclass
        
//        objc_msgSend([MJPerson class], @selector(test));
        
//        printMethodNamesOfClass(object_getClass([MJPerson class]));
    }
    return 0;
}
