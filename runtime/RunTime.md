# Runtime


### instance、class方法查找流程
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/26b23867d87942e09dfdcfd34ae0ee62~tplv-k3u1fbpfcp-watermark.image?)

### `class_copyIvarList` & `class_copyPropertyList`区别
`property` 正常使用会生成对应的实例变量，所以 `Ivar` 可以查到。

`class_copyIvarList` 获取类对象中的所有实例变量信息，从 `class_ro_t` 中获取：

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

`class_copyPropertyList` 获取类对象中的属性信息， `class_rw_t` 的 `properties`，先后输出了 category / extension/ baseClass 的属性，而且仅输出当前的类的属性信息，而不会向上去找 superClass 中定义的属性。

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
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;  // instance对象占用的内存空间

#ifdef __LP64__
    uint32_t reserved;
#endif
    const uint8_t * ivarLayout;
    const char * name;  // 类名
    method_list_t * baseMethodList;//方法列表
    protocol_list_t * baseProtocols;//协议列表
    const ivar_list_t * ivars;  // 成员变量列表
    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;//属性列表
};

struct class_rw_t { //可读可写，分类会合入这里
    uint32_t flags;
    uint32_t version;
    const class_ro_t *ro;//只读
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
### 消息发送机制
objc_msgSend的执行流程可以分为3大阶段
-   消息发送
-   动态方法解析
-   消息转发
##### 1 objc_msgSend执行流程01-消息发送
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/20a20657c95d48b1b3e609f2ee4f9b30~tplv-k3u1fbpfcp-watermark.image?)
##### 2 objc_msgSend执行流程02-动态方法解析
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/68bf298587ab449b9ba8f44858502c76~tplv-k3u1fbpfcp-watermark.image?)
 ```Objective-C
#import "MJPerson.h"
#import <objc/RunTime/RunTime.h>
@implementation MJPerson

void c_other(id self, SEL _cmd){
    NSLog(@"c_other - %@ - %@", self, NSStringFromSelector(_cmd));
}

+ (BOOL)resolveClassMethod:(SEL)sel{
    if (sel == @selector(test)) {
        // 第一个参数是object_getClass(self)
        class_addMethod(object_getClass(self), sel, (IMP)c_other, "v16@0:8");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

@end
 ```
 3 objc_msgSend的执行流程03-消息转发
 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1cc8e77ede444f5abbcc9f598463f979~tplv-k3u1fbpfcp-watermark.image?)

快速转发
 ```Objective-C
- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == @selector(test)) {
      //消息转发的第一个阶段：伪代码objc_msgSend([[MJCat alloc] init], aSelector)
        // objc_msgSend([[MJCat alloc] init], aSelector)
        return [[MJCat alloc] init]; 这里如果返回的是类对象，就调用类方法
    }
    return [super forwardingTargetForSelector:aSelector];
}
 ```
 
慢转发，没有实现快速转发的前提下
方法签名：返回值类型、参数类型
 ```Objective-C
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if (aSelector == @selector(test)) {
        return [NSMethodSignature signatureWithObjCTypes:"v16@0:8"];
    }
    return [super methodSignatureForSelector:aSelector];
} 
 ```
NSInvocation封装了一个方法调用，包括：方法调用者、方法名、方法参数
anInvocation.target 方法调用者
anInvocation.selector 方法名
[anInvocation getArgument:NULL atIndex:0] 方法参数

 ```Objective-C
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    anInvocation.target = [[MJCat alloc] init];
    [anInvocation invoke];
    //如果函数有返回值，可以这样获取结果
    int ret;
    [anInvocation getReturnValue:&ret];
}
```
消息转发的伪代码
```Objective-C
int __forwarding__(void *frameStackPointer, int isStret) {
    id receiver = *(id *)frameStackPointer;
    SEL sel = *(SEL *)(frameStackPointer + 8);
    const char *selName = sel_getName(sel);
    Class receiverClass = object_getClass(receiver);

    // 调用 forwardingTargetForSelector:
    if (class_respondsToSelector(receiverClass, @selector(forwardingTargetForSelector:))) {
        id forwardingTarget = [receiver forwardingTargetForSelector:sel];
        if (forwardingTarget && forwardingTarget != receiver) {
            if (isStret == 1) {
                int ret;
                objc_msgSend_stret(&ret,forwardingTarget, sel, ...);
                return ret;
            }
            return objc_msgSend(forwardingTarget, sel, ...);
        }
    }

    // 僵尸对象
    const char *className = class_getName(receiverClass);
    const char *zombiePrefix = "_NSZombie_";
    size_t prefixLen = strlen(zombiePrefix); // 0xa
    if (strncmp(className, zombiePrefix, prefixLen) == 0) {
        CFLog(kCFLogLevelError,
              @"*** -[%s %s]: message sent to deallocated instance %p",
              className + prefixLen,
              selName,
              receiver);
        <breakpoint-interrupt>
    }

    // 调用 methodSignatureForSelector 获取方法签名后再调用 forwardInvocation
    if (class_respondsToSelector(receiverClass, @selector(methodSignatureForSelector:))) {
        NSMethodSignature *methodSignature = [receiver methodSignatureForSelector:sel];
        if (methodSignature) {
            BOOL signatureIsStret = [methodSignature _frameDescriptor]->returnArgInfo.flags.isStruct;
            if (signatureIsStret != isStret) {
                CFLog(kCFLogLevelWarning ,
                      @"*** NSForwarding: warning: method signature and compiler disagree on struct-return-edness of '%s'.  Signature thinks it does%s return a struct, and compiler thinks it does%s.",
                      selName,
                      signatureIsStret ? "" : not,
                      isStret ? "" : not);
            }
            if (class_respondsToSelector(receiverClass, @selector(forwardInvocation:))) {
                NSInvocation *invocation = [NSInvocation _invocationWithMethodSignature:methodSignature frame:frameStackPointer];

                [receiver forwardInvocation:invocation];

                void *returnValue = NULL;
                [invocation getReturnValue:&value];
                return returnValue;
            } else {
                CFLog(kCFLogLevelWarning ,
                      @"*** NSForwarding: warning: object %p of class '%s' does not implement forwardInvocation: -- dropping message",
                      receiver,
                      className);
                return 0;
            }
        }
    }

    SEL *registeredSel = sel_getUid(selName);

    // selector 是否已经在 Runtime 注册过
    if (sel != registeredSel) {
        CFLog(kCFLogLevelWarning ,
              @"*** NSForwarding: warning: selector (%p) for message '%s' does not match selector known to Objective C runtime (%p)-- abort",
              sel,
              selName,
              registeredSel);
    } // doesNotRecognizeSelector
    else if (class_respondsToSelector(receiverClass,@selector(doesNotRecognizeSelector:))) {
        [receiver doesNotRecognizeSelector:sel];
    }
    else {
        CFLog(kCFLogLevelWarning ,
              @"*** NSForwarding: warning: object %p of class '%s' does not implement doesNotRecognizeSelector: -- abort",
              receiver,
              className);
    }

    // The point of no return.
    kill(getpid(), 9);
}
 ```

### @dynamic和synthesize
 ```Objective-C
#import "MJPerson.h"
#import <objc/RunTime/RunTime.h>
@implementation MJPerson

// 提醒编译器不要自动生成setter和getter的实现、不要自动生成成员变量
@dynamic age;
void setAge(id self, SEL _cmd, int age){
    NSLog(@"age is %d", age);
}

//优先找对象方法,找不到找C方法
//- (void)setAge:(int)age {
//    NSLog(@"age is %d-------", age);
//}

int age(id self, SEL _cmd){
    return 120;
}

//- (int)age {
//    return 100;
//}

//动态方法解析:没有实现OC的setter和getter,则去实现C的setter和getter.如果没实现oc的,默认并不会直接就去执行C语言的方法,还是需要动态方法解析的
+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(setAge:)) {
        class_addMethod(self, sel, (IMP)setAge, "v@:i");
        return YES;
    } else if (sel == @selector(age)) {
        class_addMethod(self, sel, (IMP)age, "i@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

//@synthesize 帮我们生成实例变量和getter、setter的实现，现在编译器已经做了这个，不需要写了
//@synthesize age = _age, height = _height;

//- (void)setAge:(int)age
//{
//    _age = age;
//}
//
//- (int)age
//{
//    return _age;
//}

@end
 ```

### super关键字
 ```Objective-C
#import "MJStudent.h"
#import <objc/RunTime/RunTime.h>
@implementation MJStudent
/*
 [super message]的底层实现
 1.消息接收者仍然是子类对象
 2.直接去父类开始查找方法的实现
 */
struct objc_super {
    __unsafe_unretained _Nonnull id receiver; // 消息接收者
    __unsafe_unretained _Nonnull Class super_class; // 消息接收者的父类
};

- (void)run{
    // super调用的receiver仍然是MJStudent对象
    [super run];如果MJPerson没有实现run，这里会递归崩溃
    
    //objc_super的第二个成员是super_class（消息接收者的父类），目的是从父类开始查找run方法，而不是从本类开始，如果从本类开始就是死循环了
//    struct objc_super arg = {self, [MJPerson class]};
//
//    objc_msgSendSuper(arg, @selector(run));
//
//
//    NSLog(@"MJStudet.......");
}

- (instancetype)init{
    if (self = [super init]) {
        NSLog(@"[self class] = %@", [self class]); // MJStudent
        NSLog(@"[self superclass] = %@", [self superclass]); // MJPerson
        NSLog(@"--------------------------------");
        // objc_msgSendSuper({self, [MJPerson class]}, @selector(class));
        NSLog(@"[super class] = %@", [super class]); // MJStudent
        NSLog(@"[super superclass] = %@", [super superclass]); // MJPerson
    }
    return self;
}

@end

//class的底层实现
@implementation NSObject
- (Class)class {
    return object_getClass(self);
}

- (Class)superclass {
    return class_getSuperclass(object_getClass(self));
}
@end
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

### runtime的使用
#### objc_msgSend
```
// 通过类名获取类
Class catClass = objc_getClass("Cat"); 
//注意Class实际上也是对象，所以同样能够接受消息，向Class发送alloc消息
Cat *cat = objc_msgSend(catClass, @selector(alloc)); 
//发送init消息给Cat实例cat
cat = objc_msgSend(cat, @selector(init)); 
//发送eat消息给cat，即调用eat方法
objc_msgSend(cat, @selector(eat));
//汇总消息传递过程
objc_msgSend(objc_msgSend(objc_msgSend(objc_getClass("Cat"), sel_registerName("alloc")), sel_registerName("init")), sel_registerName("eat"));
```
#### 关联对象:alertView,一般传值，使用的是alertView的tag属性。我们想把更多的参数传给alertView代理
```
- (void)shopCartCell:(BSShopCartCell *)shopCartCell didDeleteClickedAtRecId:(NSString *)recId{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确认要删除这个宝贝" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    objc_setAssociatedObject(alert, "suppliers_id", @"1", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(alert, "warehouse_id", @"2", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    alert.tag = [recId intValue];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *warehouse_id = objc_getAssociatedObject(alertView, "warehouse_id");
        NSString *suppliers_id = objc_getAssociatedObject(alertView, "suppliers_id");
        NSString *recId = [NSString stringWithFormat:@"%ld",(long)alertView.tag];
    }
}
```
#### 方法交换

```
#import "NSMutableDictionary+Extension.h"
#import <objc/runtime.h>
@implementation NSMutableDictionary (Extension)

+ (void)load{ 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ //确保不会被多次交换
    //NSDictionary是一个类蔟，找到子类去交换
        Class cls = NSClassFromString(@"__NSDictionaryM");
        //__NSDictionaryM NSMutableDictionary NSDictionary NSObject
        NSLog(@"%@ %@ %@ %@",cls , [cls superclass],[[cls superclass] superclass],[[[cls superclass] superclass] superclass]);

        Method method1 = class_getInstanceMethod(cls, @selector(setObject:forKeyedSubscript:));

        Method method2 = class_getInstanceMethod(cls, @selector(mj_setObject:forKeyedSubscript:));
        method_exchangeImplementations(method1, method2);
        Class cls2 = NSClassFromString(@"__NSDictionaryI");
        //__NSDictionaryI NSDictionary NSObject (null)
        NSLog(@"%@ %@ %@ %@",cls2 , [cls2 superclass],[[cls2 superclass] superclass],[[[cls2 superclass] superclass] superclass]);
        Method method3 = class_getInstanceMethod(cls2, @selector(objectForKeyedSubscript:));
        Method method4 = class_getInstanceMethod(cls2, @selector(mj_objectForKeyedSubscript:));
        method_exchangeImplementations(method3, method4);
    });
}

- (void)mj_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key{
    if (!key) return;
    [self mj_setObject:obj forKeyedSubscript:key];
}

- (id)mj_objectForKeyedSubscript:(id)key{
    if (!key) return nil;
    return [self mj_objectForKeyedSubscript:key];
}
@end
```
#### 动态添加方法
```
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    Person *p = [[Person alloc] init];
    // 默认person，没有实现eat方法，可以通过performSelector调用，但是会报错。
    // 动态添加方法就不会报错
    [p performSelector:@selector(eat)];
}
@end
@implementation Person
// void(*)()
// 默认方法都有两个隐式参数，
void eat(id self,SEL sel) {
    NSLog(@"%@ %@",self,NSStringFromSelector(sel));
}
// 当一个对象调用未实现的方法，会调用这个方法处理,并且会把对应的方法列表传过来.
// 刚好可以用来判断，未实现的方法是不是我们想要动态添加的方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(eat)) {
        // 动态添加eat方法
        // 第一个参数：给哪个类添加方法
        // 第二个参数：添加方法的方法编号
        // 第三个参数：添加方法的函数实现（函数地址）
        // 第四个参数：函数的类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
        class_addMethod(self, @selector(eat), eat, "v@:");
    }
    return [super resolveInstanceMethod:sel];
}
@end
```

#### 字典转模型
```
// Ivar:成员变量 以下划线开头
// Property:属性
+ (instancetype)modelWithDict:(NSDictionary *)dict{
    id objc = [[self alloc] init];
    // runtime:根据模型中属性,去字典中取出对应的value给模型属性赋值
    // 1.获取模型中所有成员变量 key
    // 获取哪个类的成员变量
    // count:成员变量个数
    unsigned int count = 0;
    // 获取成员变量数组
    Ivar *ivarList = class_copyIvarList(self, &count);
    // 遍历所有成员变量
    for (int i = 0; i < count; i++) {
        // 获取成员变量
        Ivar ivar = ivarList[i];
        // 获取成员变量名字
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 获取成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        // @"User" -> User
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@""" withString:@""];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        // 获取key
        NSString *key = [ivarName substringFromIndex:1];
        // 去字典中查找对应value
        // key:user  value:NSDictionary
        id value = dict[key];
        
        // 二级转换:判断下value是否是字典,如果是,字典转换层对应的模型
        // 并且是自定义对象才需要转换
        if ([value isKindOfClass:[NSDictionary class]] && ![ivarType hasPrefix:@"NS"]) {
            // 字典转换成模型 userDict => User模型
            // 转换成哪个模型

            // 获取类
            Class modelClass = NSClassFromString(ivarType);
            value = [modelClass modelWithDict:value];
        }
        
        // 给模型中属性赋值
        if (value) {
            [objc setValue:value forKey:key];
        }
    }
        
    return objc;
}
```

#### 崩溃防护（消息转发）

```
#import "MJPerson.h"
@implementation MJPerson
- (void)run{
    NSLog(@"run-123");
}

// MARK: - 防止出现方法找不到的崩溃
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    // 本来能调用的方法
    if ([self respondsToSelector:aSelector]) {
        return [super methodSignatureForSelector:aSelector];
    }
    // 找不到的方法
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

// 找不到的方法，都会来到这里
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"找不到%@方法", NSStringFromSelector(anInvocation.selector));
}
@end
```