# # OC对象的本质

我们平时编写的Objective-C代码，底层实现其实都是**C、C++代码、asm汇编代码**，所以Objective-C的面向对象 **`都是基于C\C++的数据结构实现的

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/089da4442b274f538df799081fd511b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 

  转C++： xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc OC源文件 -o 输出的CPP文件

### NSObject的内存布局
```
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

struct NSObject_IMPL {
    Class isa;//8
};

struct Person_IMPL {
    struct NSObject_IMPL NSObject_IVARS; // 8
    int _age; // 4
}; // 16 内存对齐：结构体的大小必须是最大成员大小的倍数

struct Student_IMPL {
    struct Person_IMPL Person_IVARS; // 16
    int _no; // 4
}; // 16

// Person
@interface Person : NSObject
{
    @public
    int _age; //4
}
//@property (nonatomic, assign) int height;
@end

@implementation Person
@end

@interface Student : Person {
    int _no; //4
}
@end

@implementation Student

@end

@interface GoodStudent : Student
{
    int _library; //4
    NSString *_value;//8
    NSString *_name; //8
}
@end

@implementation GoodStudent

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *stu = [[Student alloc] init];
        
        NSLog(@"stu - %zd", class_getInstanceSize([Student class])); //16 class_getInstanceSize 内存对齐：最大成员的倍数
        NSLog(@"stu - %zd", malloc_size((__bridge const void *)stu));//16 malloc_size 内存对齐：16的倍数
        
        GoodStudent *good = [[GoodStudent alloc] init];
        NSLog(@"good - %zd", class_getInstanceSize([GoodStudent class]));//40
        NSLog(@"good - %zd", malloc_size((__bridge const void *)good));//48
//
        Person *person = [[Person alloc] init];
//        [person setHeight:10];
//        [person height];
        person->_age = 20;
        
        Person *person1 = [[Person alloc] init];
        person1->_age = 10;
        
        
        Person *person2 = [[Person alloc] init];
        person2->_age = 30;
        
        NSLog(@"person - %zd", class_getInstanceSize([Person class])); //16 isa = 8 ， age = 4, height = 4,没有height也会是16，因为必须是8的倍数
        NSLog(@"person - %zd", malloc_size((__bridge const void *)person));//16
    }
    return 0;
}
```

**OC对象主要分为三种:**

*   `instance对象`（实例对象）
*   `class对象`（类对象）
*   `meta-class对象`（元类对象） 并且,我们要探索 类对象(`Class`) 的补充和扩展的语法:`Category`(分类)

### 方法调用轨迹

instance调用对象方法的轨迹

*   isa找到class，方法不存在，就通过superclass找父类 class调用类方法的轨迹
*   isa找meta-class，方法不存在，就通过superclass找父类 ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f6e03149bb164352991ea9e17339dfd3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18aa8f023ccc40149b7e200c793d6a66~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
```
  NSObject *object = [[NSObject alloc] init];//对象地址（object->isa可以访问类地址，需要&上一个掩码）
    Class objectClass = [NSObject class];//类地址
    Class objectMetaClass = object_getClass([NSObject class]);//元类地址   
    NSLog(@"%p %p %p", object, objectClass, objectMetaClass);
```
   
类对象的简化结构：

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cca4b5a9b1c44e5abf4f0d830fc114c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

### 自定义类的结构体，模仿苹果官方class底层实现

下列代码是我们仿照objc\_class结构体，提取其中需要使用到的信息，自定义的一个结构体: （注意,要把.m文件改成.mm,因为这段代码的实现属于c++的语法）
```
#import <Foundation/Foundation.h>
#ifndef MJClassInfo_h
#define MJClassInfo_h

# if __arm64__
#   define ISA_MASK        0x0000000ffffffff8ULL
# elif __x86_64__
#   define ISA_MASK        0x00007ffffffffff8ULL
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
    uint32_t alignment_raw;//对齐
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

struct class_ro_t { //只读，在编译期就确定的结构
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;  // instance对象占用的内存空间（编译期间需要确定对象大小，因此运行时是无法添加成员变量的）
#ifdef __LP64__
    uint32_t reserved;
#endif
    const uint8_t * ivarLayout;//布局
    const char * name;  // 类名
    method_list_t * baseMethodList; //基本的方法列表
    protocol_list_t * baseProtocols; //基础的协议列表
    const ivar_list_t * ivars;  // 成员变量列表
    const uint8_t * weakIvarLayout; //weak成员变量布局
    property_list_t *baseProperties;//基础属性列表
};

struct class_rw_t { //可读可写（运行时会把class_ro_t合并进来）
    uint32_t flags;
    uint32_t version;//版本
    const class_ro_t *ro; //只读
    method_list_t * methods;    // 方法列表
    property_list_t *properties;    // 属性列表
    const protocol_list_t * protocols;  // 协议列表
    Class firstSubclass;
    Class nextSiblingClass;
    char *demangledName;
};

#define FAST_DATA_MASK          0x00007ffffffffff8UL
struct class_data_bits_t {
    uintptr_t bits;
public:
    class_rw_t* data() { //可读可写的地址是通过位运算查找到的
        return (class_rw_t *)(bits & FAST_DATA_MASK);
    }
};

/* OC对象 */
struct mj_objc_object {
    void *isa;//isa指针
};

/* 类对象 */
struct mj_objc_class : mj_objc_object { //继承了isa
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
```
