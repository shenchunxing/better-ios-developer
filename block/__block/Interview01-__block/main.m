//
//  main.m
//  Interview01-__block
//
//  Created by MJ Lee on 2018/5/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MJBlock) (void);

/**
 __block修饰基本数据类型
 */
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


/**
 __block修饰对象类型
 */
struct __Block_byref_weakObject_0 {
  void *__isa;
 struct __Block_byref_weakObject_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 NSObject *__weak weakObject2;
};


struct __main_block_impl_1 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  struct __Block_byref_weakObject_0 *weakObject; // by ref
};


void __block1Test() {
    __block int age = 10;
    NSLog(@"age在栈上 - %p", &age); //age在栈上
    
    MJBlock block = ^{ //age被捕获，在__main_block_impl_0内部生成了__Block_byref_age_0结构体，该结构体内部存有age,注意此处打印的age已经在堆上了
        age = 20;
        NSLog(@"age is %d - %p", age,&age);
    };
    
    struct __main_block_impl_0 *blockImpl0 = (__bridge struct __main_block_impl_0 *)block;
    NSLog(@"block - %p , blockImpl0 - %p", block, blockImpl0);
    NSLog(@"blockImpl0->age - %p", blockImpl0->age); //age结构体地址
    NSLog(@"blockImpl0->age->age - %p", &(blockImpl0->age->age));//age结构体里面的age变量地址
    NSLog(@"blockImpl0->age->__forwarding - %p", blockImpl0->age->__forwarding);//__forwarding指向age结构体本身
    NSLog(@"blockImpl0->age->__forwarding->age - %d", blockImpl0->age->__forwarding->age);
    NSLog(@"age在堆上 - %p", &age); //age在堆上，打印的是age结构体里面的age变量地址
    
    block();
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

void __block4Test (void) {
    NSObject *object1 = [[NSObject alloc] init];
    __weak NSObject *weakObject1 = object1;
    
    NSObject *object2 = [[NSObject alloc] init];
    __block __weak NSObject *weakObject2 = object2;
    NSLog(@"weakObject1 = %p , weakObject2 = %p",weakObject1,weakObject2);
    
    MJBlock block = ^{
        NSLog(@"%p", weakObject1);//堆地址
        NSLog(@"%p", weakObject2);//堆地址
    };
    
    struct __main_block_impl_1 *blockImpl1 = (__bridge struct __main_block_impl_1*)block;
    //结构体地址和对象地址
    NSLog(@"%p - %p",blockImpl1->weakObject,blockImpl1->weakObject->weakObject2);
    block();
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        __block1Test();//__block修饰基本数据类型
        NSLog(@"------------");
        __block2Test();//__block __weak同时修饰基本数据类型
        NSLog(@"------------");
        __block3Test();//block内部使用weak对象和__block对象
        NSLog(@"------------");
        __block4Test();//block内部使用weak对象和__block对象
    }
    return 0;
}
