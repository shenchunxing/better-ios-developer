//
//  main.m
//  Interview01-__block
//
//  Created by MJ Lee on 2018/5/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MJBlock) (void);

struct __Block_byref_age_0 {
    void *__isa;
    struct __Block_byref_age_0 *__forwarding;
    int __flags;
    int __size;
    int age;
};

struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    void (*copy)(void);
    void (*dispose)(void);
};

struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    struct __Block_byref_age_0 *age;
};

void __block1Test() {
    __block int age = 10;
    NSLog(@"age在栈上 - %p", &age); //age在栈上
    
    MJBlock block = ^{ //age被捕获，在__main_block_impl_0内部生成了__Block_byref_age_0结构体，该结构体内部存有age
        age = 20;
        NSLog(@"age is %d", age);
    };
    
    struct __main_block_impl_0 *blockImpl0 = (__bridge struct __main_block_impl_0 *)block;
    NSLog(@"age在堆上 - %p", &age); //age在堆上
}

void __block2Test() {
    //'__weak' only applies to Objective-C object or block pointer types; type here is 'int'
    //__weak修饰基本数据类型没什么用
    __block __weak int age = 10;
    
    MJBlock block1 = ^{
        //__strong' only applies to Objective-C object or block pointer types; type here is 'int'
        __strong int myage = age; //只是值传递
        age = 20;
        NSLog(@"age is %d", age);
        NSLog(@"myage is %d", myage);
    };
    
    MJBlock block2 = ^{
        age = 30;
        NSLog(@"age is %d", age);
    };
    
    block1();
    block2();
}

void __block3Test () {
    int no = 20;
    
    __block int age = 10;
    
    NSObject *object = [[NSObject alloc] init];
    __weak NSObject *weakObject = object;
    
    MJBlock block = ^{
        age = 20;
        
        NSLog(@"%d", no);//20
        NSLog(@"%d", age);//20
        NSLog(@"%p", weakObject);//堆地址
    };
    
    struct __main_block_impl_0* blockImpl = (__bridge struct __main_block_impl_0*)block;
    block();
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block1Test();//__block修饰基本数据类型
        NSLog(@"------------");
        __block2Test();//__block __weak同时修饰基本数据类型
        NSLog(@"------------");
        __block3Test();//block内部使用weak对象和__block对象
    }
    return 0;
}
