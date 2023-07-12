# Runtime

### 能否向编译后得到的类中增加实例变量？能否向运行时创建的类中添加实例变量？为什么？

不能向编译后得到的类中增加实例变量；
能向运行时创建的类中添加实例变量；
解释下：

因为编译后的类已经注册在 runtime 中，类结构体中的 objc_ivar_list 实例变量的链表 和 instance_size 实例变量的内存大小已经确定，同时runtime 会调用 class_setIvarLayout 或 class_setWeakIvarLayout 来处理 strong weak 引用。所以不能向存在的类中添加实例变量；

运行时创建的类是可以添加实例变量，调用 class_addIvar 函数。但是得在调用 objc_allocateClassPair 之后，objc_registerClassPair 之前，原因同上。

### instance、class方法查找流程
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/26b23867d87942e09dfdcfd34ae0ee62~tplv-k3u1fbpfcp-watermark.image?)

### `class_copyIvarList` & `class_copyPropertyList`区别
`property` 正常使用会生成对应的实例变量，所以 `Ivar` 可以查到。

`class_copyIvarList` 获取类对象中的所有实例变量信息，因为成员变量只存在于类和类扩展，这些都是类的基本信息。都存在class_ro_t中，所以从 `class_ro_t` 中获取：

```
Ivar *
class_copyIvarList(Class cls, unsigned int *outCount)
{
    const ivar_list_t *ivars;
    Ivar *result = nil;
    unsigned int count = 0;

    if (!cls) {
        if (outCount) *outCount = 0;
        return nil;
    }

    mutex_locker_t lock(runtimeLock);

    assert(cls->isRealized());
    
    if ((ivars = cls->data()->ro->ivars)  &&  ivars->count) {
        result = (Ivar *)malloc((ivars->count+1) * sizeof(Ivar));
        
        for (auto& ivar : *ivars) {
            if (!ivar.offset) continue;  // anonymous bitfield
            result[count++] = &ivar;
        }
        result[count] = nil;
    }
    
    if (outCount) *outCount = count;
    return result;
}
```

`class_copyPropertyList` 获取类对象中的属性信息， `class_rw_t` 的 `properties`，先后输出了 category / extension/ baseClass （因为还涉及到caregory的属性，所有要保存在class_rw_t中）的属性，而且仅输出当前的类的属性信息，而不会向上去找 superClass 中定义的属性。

```
objc_property_t *
class_copyPropertyList(Class cls, unsigned int *outCount)
{
    if (!cls) {
        if (outCount) *outCount = 0;
        return nil;
    }

    mutex_locker_t lock(runtimeLock);

    checkIsKnownClass(cls);
    assert(cls->isRealized());
    
    auto rw = cls->data();

    property_t **result = nil;
    unsigned int count = rw->properties.count();
    if (count > 0) {
        result = (property_t **)malloc((count + 1) * sizeof(property_t *));

        count = 0;
        for (auto& prop : rw->properties) {
            result[count++] = &prop;
        }
        result[count] = nil;
    }

    if (outCount) *outCount = count;
    return (objc_property_t *)result;
}
```


### 模拟Class的结构
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
#if __arm__  ||  __x86_64__  ||  __i386__
// objc_msgSend has few registers available.
// Cache scan increments and wraps at special end-marking bucket.
#define CACHE_END_MARKER 1
static inline mask_t cache_next(mask_t i, mask_t mask) {
    return (i+1) & mask;
}
#elif __arm64__
// objc_msgSend has lots of registers available.
// Cache scan decrements. No end marker needed.
#define CACHE_END_MARKER 0

static inline mask_t cache_next(mask_t i, mask_t mask) {
    return i ? i-1 : mask;
}
#else
#error unknown architecture
#endif

struct bucket_t {//桶
    cache_key_t _key;//方法key
    IMP _imp;//方法实现
};

struct cache_t { //方法缓存
    bucket_t *_buckets;//桶数组
    mask_t _mask;//掩码
    mask_t _occupied;//方法数量-1
    IMP imp(SEL selector)//根据Sel查找方法实现
    {
        mask_t begin = _mask & (long long)selector;
        mask_t i = begin;
        do {
            if (_buckets[i]._key == 0  ||  _buckets[i]._key == (long long)selector) {
                return _buckets[i]._imp;
            }
        } while ((i = cache_next(i, _mask)) != begin);
        return NULL;
    }
};

struct entsize_list_tt {
    uint32_t entsizeAndFlags;
    uint32_t count;
};

struct method_t { //方法
    SEL name;//方法名
    const char *types;//方法类型
    IMP imp;//方法实现
};

struct method_list_t : entsize_list_tt {
    method_t first;
};

struct ivar_t {//成员
    int32_t *offset;//偏移量
    const char *name;//名称
    const char *type;//类型
    uint32_t alignment_raw;//对齐
    uint32_t size;//大小
};

struct ivar_list_t : entsize_list_tt {
    ivar_t first;
};

struct property_t {
    const char *name;//属性名称
    const char *attributes;//属性信息
};

struct property_list_t : entsize_list_tt {
    property_t first;
};

struct chained_property_list {
    chained_property_list *next;
    uint32_t count;
    property_t list[0];
};

typedef uintptr_t protocol_ref_t;
struct protocol_list_t {
    uintptr_t count;
    protocol_ref_t list[0];
};

struct class_ro_t {//只读，包含了类的初始内容，（这也是分类不能添加属性的根本原因）`
    uint32_t flags;//用于存储类的标志，如是否是元类、是否为元类的根元类等信息
    uint32_t instanceStart;//实例对象开始地址的偏移量，用于计算实例对象的实际地址
    uint32_t instanceSize;  // instance对象占用的内存空间

#ifdef __LP64__
    uint32_t reserved;//在 64 位架构下的保留字段。
#endif
    const uint8_t * ivarLayout;//弱引用实例变量的布局信息
    const char * name;  // 类的名称，以 C 字符串的形式存储。
    method_list_t * baseMethodList;//指向类的基础方法列表（包括类和分类中的方法）的指针。
    protocol_list_t * baseProtocols;//指向类遵循的协议列表的指针
    const ivar_list_t * ivars;  // 指向类的实例变量列表的指针。
    const uint8_t * weakIvarLayout;//弱引用实例变量的布局信息
    property_list_t *baseProperties;//指向类的属性列表的指针
};

struct class_rw_t { //可读可写，分类会合入这里
    uint32_t flags;//用于存储类的标志，描述类的特性，比如是否是元类、是否是元类的根元类等信息
    uint32_t version;//用于标识类的版本号，当类的实现发生变化时，版本号会递增，用于类的加载和运行时判断。
    const class_ro_t *ro;//指向 class_ro_t 结构体的指针，用于引用类的只读信息，包括类名、实例变量、方法、协议等。
    method_list_t * methods;    // 指向方法列表（method_list_t）的指针，用于存储类的方法信息。
    property_list_t *properties;    // 属性列表
    const protocol_list_t * protocols;  // 协议列表
    Class firstSubclass;//指向第一个子类的 Class 对象的指针
    Class nextSiblingClass;//指向下一个兄弟类的 Class 对象的指针。
    char *demangledName;//存储类名的 C 字符串，如果类名被符号解析过，则存储解析后的类名
};

#define FAST_DATA_MASK          0x00007ffffffffff8UL
struct class_data_bits_t {
    uintptr_t bits;
public:
    class_rw_t* data() {
        return (class_rw_t *)(bits & FAST_DATA_MASK);
    }
};

struct mj_objc_object { //OC对象
    void *isa;
};

struct mj_objc_class : mj_objc_object { //OC类
    Class superclass;//父类
    cache_t cache;//方法缓存
    class_data_bits_t bits;//信息
public:
    class_rw_t* data() {
        return bits.data();
    }
    mj_objc_class* metaClass() {//元类
        return (mj_objc_class *)((long long)isa & ISA_MASK);
    }
};
#endif /* MJClassInfo_h */
```

### 方法缓存
Class内部结构中有个方法缓存（cache_t），用`散列表（哈希表）`来缓存曾经调用过的方法，可以提高方法的查找速度
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1cbcf3be26804962a76f6141ffa4001c~tplv-k3u1fbpfcp-watermark.image?)
#### 缓存查找

-   objc-cache.mm
-   bucket_t * cache_t::find(cache_key_t k, id receiver)

```
#import "ViewController.h"
#import <objc/runtime.h>
#import "MJPerson.h"
@interface ViewController ()
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //类对象或者元类对象地址，最后3位都是0，从isa底层的数据结构可以看出，isa & mask 得到class的33位地址值 + 后面的3位000组成了一个完整的class地址
    MJPerson *obj = [[MJPerson alloc] init];
    int a = 12;
    NSLog(@"self在栈上：%p ，obj指针在栈上：%p，obj对象在堆上：%p，a在栈上 = %p",&self,&obj,obj,&a);//在栈空间，地址和self紧挨着
    NSLog(@"全局区-ViewController类对象地址:%p", [ViewController class]); //类地址
    NSLog(@"全局区-ViewController元类地址：%p", object_getClass([ViewController class]));//元类地址
    NSLog(@"全局区-MJPerson类地址：%p", [MJPerson class]);//类地址
    NSLog(@"全局区-MJPerson元类地址：%p", object_getClass([MJPerson class]));//元类地址
}
@end
```
### isa指针
```
/** isa_t 结构体 */
union isa_t {
    Class cls;
    uintptr_t bits;
    struct {
        uintptr_t nonpointer        : 1;//0，代表普通的指针，存储着Class、Meta-Class对象的内存地址  
1，代表优化过，使用位域存储更多的信息
        uintptr_t has_assoc         : 1;//是否有设置过关联对象，如果没有，释放时会更快
        uintptr_t has_cxx_dtor      : 1;//是否有C++的析构函数（.cxx_destruct），如果没有，释放时会更快
        uintptr_t shiftcls          : 33;//存储着Class、Meta-Class对象的内存地址信息
        uintptr_t magic             : 6;//用于在调试时分辨对象是否未完成初始化
        uintptr_t weakly_referenced : 1;//是否有被弱引用指向过，如果没有，释放时会更快
        uintptr_t deallocating      : 1;//对象是否正在释放
        uintptr_t has_sidetable_rc  : 1;//当对象引用计数大于 10 时，则has_sidetable_rc 的值为 1，那么引用计数会存储在一个叫 SideTable 的类的属性中，这是一个散列表。
        uintptr_t extra_rc          : 19;//表示该对象的引用计数值，实际上是引用计数值减 1，例如，如果对象的引用计数为 10，那么 extra_rc 为 9。如果引用计数大于 10，则需要使用到上面的 has_sidetable_rc。
    };
};
```

### runtime如何通过selector 找到对应的 IMP 地址(分别考虑类方法和实例方法)
```
struct objc_class { //isa找到类，类里面有方法列表
    Class isa  OBJC_ISA_AVAILABILITY;
#if !__OBJC2__
    Class super_class                                 
    const char *name                                 
    long version                                     
    long info                                         
    long instance_size                               
    struct objc_ivar_list *ivars                     
    struct objc_method_list **methodLists//方法列表             
    struct objc_cache *cache                         
    struct objc_protocol_list *protocols             
#endif
} OBJC2_UNAVAILABLE;
```
```
struct objc_method {
    SEL method_name                                   
    char *method_types                              
    IMP method_imp 
}
```
//根据类,SEL,Method找到IMP
```
IMP class_getMethodImplementation(Class cls, SEL name);
IMP method_getImplementation(Method m)
```

 ### super关键字导致的打印问题
 
```
#import <Foundation/Foundation.h>
@interface MJPerson : NSObject
@property (copy, nonatomic) NSString *name;
- (void)print;
@end
@implementation MJPerson
- (void)print{
    NSLog(@"my name is %@", self->_name);
}
@end

- (void)viewDidLoad {
    [super viewDidLoad];
    id cls = [MJPerson class];
    void *obj = &cls;
    [(__bridge id)obj print];
  }
```
运行结果：

```
my name is <ViewController: 0x14d6067e0>
```
#### 为什么可以调用成功？

person通过isa找到类对象[MJPerson class]

obj通过cls找到类对象[MJPerson class]，因此可以调用成功
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2048827489284245ab09a51548797964~tplv-k3u1fbpfcp-watermark.image?)

#### 为什么self.name变成了ViewController等其他内容？

栈上的地址排布：
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ab3fa879c25e46ae97bdb952a67226c2~tplv-k3u1fbpfcp-watermark.image?)
打印self.name实际是通过isa偏移8个字节，找到_name成员。实例的内存是从低到高排布的。cls偏移8个字节找到的是self。因此打印了self。

变形：
```
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *str = @"test";
    id cls = [MJPerson class];
    void *obj = &cls;
    [(__bridge id)obj print];
  }
```
打印的是str，因为cls往上找8个字节，就是str对象。
 
 
### isKindOfClass和isMemberOfClass
```
#import <Foundation/Foundation.h>
#import "MJPerson.h"
#import <objc/runtime.h>
//@implementation NSObject
//
//- (BOOL)isMemberOfClass:(Class)cls {
//    return [self class] == cls;
//}
//

//- (BOOL)isKindOfClass:(Class)cls {
//    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
//        if (tcls == cls) return YES;
//    }
//    return NO;
//}
//
//

//+ (BOOL)isMemberOfClass:(Class)cls {
//    return object_getClass((id)self) == cls;
//}
//

//+ (BOOL)isKindOfClass:(Class)cls {
//    for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
//        if (tcls == cls) return YES;
//    }
//    return NO;
//}
//@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //isKindOfClass: 如果是instance类型，则类对象开始查找，没找到从instance的类对象的父类继续查找 ，       如果是class类型，则从元类开始查找，没找到从当前class的元类对象的父类继续查找。
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
```