//
//  main.m
//  Interview01-__block
//
//  Created by MJ Lee on 2018/5/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"
#import <objc/runtime.h>

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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        MJPerson *person = [[MJPerson alloc] init];
        
        MJBlock block = [^{
            NSLog(@"%p", person);
        } copy];//注意：MRC下block变量并没有对block产生强引用，copy后才会强引用，所以引用计数只增加一次
        
        NSLog(@"%d -%@",[person retainCount],object_getClass(block)); //2
        [person release];
        
        block();
        
        [block release]; //block持有person,block结束person才能释放
    }
    return 0;
}
