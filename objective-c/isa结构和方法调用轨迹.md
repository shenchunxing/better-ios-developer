isa的结构
```Objective-C
struct mj_objc_class {
    Class isa;
    Class superclass;
};

//在ARM 32位的时候，isa的类型是Class类型的，直接存储着实例对象或者类对象的地址；在ARM64结构下，isa的类型变成了共用体(union)，使用了位域去存储更多信息
//共用体中可以定义多个成员，共用体的大小由最大的成员大小决定
//共用体的成员公用一个内存
//对某一个成员赋值，会覆盖其他成员的值
//存储效率更高
union isa_t
{
    Class cls;
    uintptr_t bits;   //存储下面结构体每一位的值
    struct {
        uintptr_t nonpointer        : 1;  // 0:普通指针，存储Class、Meta-Class；1:存储更多信息
        uintptr_t has_assoc         : 1;  // 有没有关联对象
        uintptr_t has_cxx_dtor      : 1;  // 有没有C++的析构函数（.cxx_destruct）
        uintptr_t shiftcls          : 33; // 存储Class、Meta-Class的内存地址
        uintptr_t magic             : 6;  // 调试时分辨对象是否初始化用
        uintptr_t weakly_referenced : 1;  // 有没有被弱引用过
        uintptr_t deallocating      : 1;  // 正在释放
        uintptr_t has_sidetable_rc  : 1;  //0:引用计数器在isa中；1:引用计数器存在SideTable
        uintptr_t extra_rc          : 19; // 引用计数器-1
    };
};

//Tagged Pointer的优化：
//Tagged Pointer专门用来存储小的对象，例如NSNumber, NSDate, NSString。
//Tagged Pointer指针的值不再是地址了，而是真正的值。所以，实际上它不再是一个对象了，它只是一个披着对象皮的普通变量而已。所以，它的内存并不存储在堆中，也不需要malloc和free。
//在内存读取上有着3倍的效率，创建时比以前快106倍。
//例如：1010，其中最高位1xxx表明这是一个tagged pointer，而剩下的3位010，表示了这是一个NSString类型。010转换为十进制即为2。也就是说，标志位是2的tagger
//pointer表示这是一个NSString对象。

//SEL，方法选择器，本质上是一个C字符串  IMP，函数指针，函数的执行入口  Method，类型，结构体，里面有SEL和IMP
/// Method
struct objc_method {
    SEL method_name;
    char *method_types;
    IMP method_imp;
 };

struct method_t {
    SEL name; //函数名
    const char *types; //编码（返回值类型、参数类型）
    IMP imp;//指向函数的指针（函数地址）
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // MJPerson类对象的地址：0x00000001000014c8
        // isa & ISA_MASK：0x00000001000014c8
        
        // MJPerson实例对象的isa：0x001d8001000014c9
        
        struct mj_objc_class *personClass = (__bridge struct mj_objc_class *)([MJPerson class]);
        
        struct mj_objc_class *studentClass = (__bridge struct mj_objc_class *)([MJStudent class]);
        
        NSLog(@"1111");
        
        MJPerson *person = [[MJPerson alloc] init];
        Class personClass1 = [MJPerson class];
        struct mj_objc_class *personClass2 = (__bridge struct mj_objc_class *)(personClass1);
        Class personMetaClass = object_getClass(personClass1);
        NSLog(@"%p %p %p", person, personClass1, personMetaClass);
        MJStudent *student = [[MJStudent alloc] init];
    }
    return 0;
}

方法调用轨迹：
![对象方法调用轨迹](objective-c/对象方法调用轨迹.png)


类结构：
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


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJStudent *stu = [[MJStudent alloc] init];
        stu->_weight = 10;
        
        mj_objc_class *studentClass = (__bridge mj_objc_class *)([MJStudent class]);
        mj_objc_class *personClass = (__bridge mj_objc_class *)([MJPerson class]);
        
        class_rw_t *studentClassData = studentClass->data();
        class_rw_t *personClassData = personClass->data();
        
        class_rw_t *studentMetaClassData = studentClass->metaClass()->data();
        class_rw_t *personMetaClassData = personClass->metaClass()->data();
    }
    return 0;
}


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
        NSLog(@"class3 == %p class3Name == %@ class3 is  MetaClass:%d",class3,class3,class_isMetaClass(class3));//1
        
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
