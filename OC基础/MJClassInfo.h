//
//  MJClassInfo.h
//  TestClass
//
//  Created by MJ Lee on 2018/3/8.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef MJClassInfo_h
#define MJClassInfo_h

# if __arm64__
#   define ISA_MASK        0x0000000ffffffff8ULL
# elif __x86_64__
#   define ISA_MASK        0x00007ffffffffff8ULL
# endif

#if __LP64__
typedef uint32_t mask_t;
#else
typedef uint16_t mask_t;
#endif
typedef uintptr_t cache_key_t;

struct bucket_t { //桶
    cache_key_t _key;//方法查找的key
    IMP _imp; //方法实现
};

struct cache_t { //方法缓存
    bucket_t *_buckets;//缓存的方法列表
    mask_t _mask; //掩码
    mask_t _occupied;//已经存入的方法缓存数量 - 1
};

struct entsize_list_tt { //列表
    uint32_t entsizeAndFlags;
    uint32_t count;
};

struct method_t { //方法
    SEL name;//选择器
    const char *types;//编码
    IMP imp;//函数实现地址
};

struct method_list_t : entsize_list_tt { //方法列表
    method_t first;
};

struct ivar_t { //成员变量
    int32_t *offset; //偏移量
    const char *name;//名称
    const char *type;//类型
    uint32_t alignment_raw;
    uint32_t size;//大小
};

struct ivar_list_t : entsize_list_tt { //成员变量列表
    ivar_t first;
};

struct property_t { //属性
    const char *name; //属性名
    const char *attributes; //属性特性
};

struct property_list_t : entsize_list_tt { //属性列表
    property_t first;
};

struct chained_property_list { //属性链表
    chained_property_list *next;
    uint32_t count;
    property_t list[0];
};

typedef uintptr_t protocol_ref_t;
struct protocol_list_t {
    uintptr_t count; //属性数量
    protocol_ref_t list[0];
};

struct class_ro_t { //只读
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;  // instance对象占用的内存空间
#ifdef __LP64__
    uint32_t reserved;
#endif
    const uint8_t * ivarLayout;
    const char * name;  // 类名
    method_list_t * baseMethodList; //基本的方法列表
    protocol_list_t * baseProtocols; //基础的协议列表
    const ivar_list_t * ivars;  // 成员变量列表
    const uint8_t * weakIvarLayout; //weak成员变量布局
    property_list_t *baseProperties;//基础属性列表
};

struct class_rw_t { //可读可写
    uint32_t flags;
    uint32_t version;
    const class_ro_t *ro; //只读
    method_list_t * methods;    // 方法列表
    property_list_t *properties;    // 属性列表
    const protocol_list_t * protocols;  // 协议列表
    Class firstSubclass;
    Class nextSiblingClass;
    char *demangledName;
};

#define FAST_DATA_MASK          0x00007ffffffffff8UL
struct class_data_bits_t {
    uintptr_t bits;
public:
    class_rw_t* data() { //可读可写的地址是通过位运算查找到的
        return (class_rw_t *)(bits & FAST_DATA_MASK);
    }
};

/* OC对象 */
struct mj_objc_object {
    void *isa;
};

/* 类对象 */
struct mj_objc_class : mj_objc_object {
    Class superclass; //父类
    cache_t cache; //缓存
    class_data_bits_t bits;//类信息
public:
    class_rw_t* data() { //可读可写
        return bits.data();
    }
    
    mj_objc_class* metaClass() { //元类
        return (mj_objc_class *)((long long)isa & ISA_MASK);
    }
};

#endif /* MJClassInfo_h */
