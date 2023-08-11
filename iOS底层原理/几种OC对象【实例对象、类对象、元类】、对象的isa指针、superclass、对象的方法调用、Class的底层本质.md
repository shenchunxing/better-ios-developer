# 几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质

一、概述
====

我们在上上篇探索OC的文章:[Objective-C语言的的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")中,曾提到过 OC 是一种 `面向对象` 高级编程语言。因此本文紧接着上一篇文章的探索底层原理的步伐,开展 OC `面向对象` 的语法,对 OC 的 **`几种` 对象 `类型`** 进行探究。  
**OC对象主要分为三种:**

*   `instance对象`（实例对象）
*   `class对象`（类对象）
*   `meta-class对象`（元类对象） 并且,我们要探索 类对象(`Class`) 的补充和扩展的语法:`Category`(分类)

二、instance对象
============

通过OC语言编写的程序中,`instance对象`就是通过类`alloc`出来的对象，每次调用`alloc`都会产生新的`instance对象`。  
在上篇文章[OC对象的本质](https://juejin.cn/post/7094503681684406302 "https://juejin.cn/post/7094503681684406302")中,通过讨论 NSObject对象的`底层实现`、`内存布局`、`通过继承关系了解 子类、孙子类的 内存布局`...就是探索 `instance对象` 的底层过程的开端。现在简单回顾一下之前探索的结论,并继续探索!  
在[OC对象的本质](https://juejin.cn/post/7094503681684406302 "https://juejin.cn/post/7094503681684406302")这篇文章中,我们得到的结论:

*   NSObject的底层实现:

    目前官方暴露的头文件中的格式:
    @interface NSObject <NSObject> { 
        Class isa   ; 
    }
    @end
    
    简写格式:
    
    @interface NSObject <NSObject> { 
        objc_class isa   ; 
    }
    @end
    
    结构体objc_class的实现:
    
    struct objc_class  { 
        private: 
        isa_t isa; 
        public:
        Class superclass;
    
        const char *name;
    
        uint32_t version;
    
        uint32_t info;
    
        uint32_t instance_size;
    
        struct old_ivar_list *ivars;
    
        struct old_method_list **methodLists;
    
        Cache cache;
    
        struct old_protocol_list *protocols;
    
        // CLS_EXT only
    
        const uint8_t *ivar_layout;
    
        struct old_class_ext *ext;
    
        ....    
    }
    
    复制代码

*   创建一个NSObject对象`至少需要8个字节`,在64位系统中,系统至少实际分配了 `16个字节`。
    *   `至少需要8个字节`的内存(用于存放`isa指针`)
        
    *   `实际分配了16个字节`的内存(因为系统开发者在设计的时候,规定了内存分配的规则)
        
    *   OC对象的`内存对齐参数为 16`
        
        *   若需要分配的内存不够16,则以给16个字节
        *   若对象需要分配的内存超过16,则以能容纳对象的数据结构为前提,以最接近其的16最小公倍数为最终分配大小进行分配
    *   一个OC对象在内存中的布局:
        
        *   系统会在堆中开辟一块内存空间存放该对象
        *   这块空间里还包含`成员变量`和`isa指针`
        *   然后栈里的 局部变量 `指向这块存储空间` 的地址 ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2616b001cff148c9ad26a878bfb8c979~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    *   系统 提供了`两个底层API`给 开发者 进行 对内存分配情况的了解
        
            创建一个实例对象，至少需要多少内存？
            #import <objc/runtime.h>
            class_getInstanceSize([NSObject class]);
            
            
            创建一个实例对象，实际上分配了多少内存？
            #import <malloc/malloc.h>
            malloc_size((__bridge const void *)obj);
            
            复制代码
        

所有的OC类的`基类 都是 NSObject`,而 `instance对象`本质上是通过 `[[Class alloc]init]`......出来的

*   `alloc`: 分配内存
*   `init`: 初始化

    int main(int argc, const char * argv[]) {
    
        @autoreleasepool { 
            // obj1、obj2是NSObject的instance对象（实例对象）
            NSObject *obj1 = [[NSObject alloc]init];
    
            NSObject *obj2 = [[NSObject alloc]init];
    
            // 通过打印可以看出，它们是不同的两个对象，分别占据着两块不同的内存
            NSLog(@"obj1:%p",obj1);
    
            NSLog(@"obj2:%p",obj2); 
    
        }
    
        return 0;
    
    }
     
    复制代码

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/105391dbe4f648cf940c3a2bfd7ab18d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

我们随手写四个类:(继承关系如下:)

*   `Car` : NSObject
    *   增加了一个成员: int \_year
*   `CarRun` : Car
    *   增加了一个方法:
        *   \-(void)run;
*   `BBA_BMW` :CarRun
    *   增加了一个成员: ;
        *   NSString\*\_nameplate;
*   `BBA_BMW_RunFaster` :BBA\_BMW
    *   增加了一个方法:
        *   \-(void)runFaster;

    @interface Car :NSObject{
    
    @public
    
        int _year;
    
    }
    
    @end 
    
    
    @implementation Car
    
    - (instancetype)init{
    
        self = [super init];
    
        if (self) {
    
            _year = 1;
    
        }
    
        return self;
    
    }
    
    @end
    
    @interface CarRun :Car
    
    -(void)run;
    
    @end
     
    
    
    @implementation CarRun
    
    -(void)run{
    
        NSLog(@"%s",__func__);
    
    }
    
    @end
    
        
    
    @interface BBA_BMW :CarRun{
    
    @public
    
        NSString*_nameplate;//汽车铭牌 8个字节
    
    }
    
    @end
     
    
    
    @implementation BBA_BMW
    
    @end
     
    
    
    @interface BBA_BMW_RunFaster :BBA_BMW
    
    -(void)runFaster;
    
    @end
     
    
    @implementation BBA_BMW_RunFaster
    
    - (void)runFaster{
    
    NSLog(@"%s",__func__);
    
    }
    
    @end
    
    //main函数：
    int main(int argc, const char * argv[]) {
    
        @autoreleasepool {
    
           // obj1、obj2是NSObject的instance对象（实例对象）
    
           NSObject *obj1 = [[NSObject alloc]init];   
           NSObject *obj2 = [[NSObject alloc]init]; 
    
    
           // 通过打印可以看出，它们是不同的两个对象，分别占据着两块不同的内存
    
           NSLog(@"obj1:%p",obj1);
    
           NSLog(@"obj2:%p",obj2);
    
            
    
            //1.创建一个 基类 NSObject 的实例 分配 内存
    
               
    
            NSLog(@"NSObject:getInstanceSize:%zd",class_getInstanceSize([NSObject class]));
    
            NSLog(@"obj-malloc_size:%zd",malloc_size((__bridge const void*)obj1));
    
            NSLog(@"=====================================================================");
    
            //2.创建一个 基类 NSObject 的子类 Car 的实例 分配 内存
    
            Car *car = [[Car alloc]init];
    
            NSLog(@"Car-getInstanceSize:%zd",class_getInstanceSize([Car class]));
    
            NSLog(@"Car-malloc_size:%zd",malloc_size((__bridge const void*)car));
    
            NSLog(@"=====================================================================");
    
            //3.创建一个 Car 的子类 CarRun 的实例 分配 内存
    
            CarRun *car_run = [[CarRun alloc]init];
    
            NSLog(@"CarRun-getInstanceSize:%zd",class_getInstanceSize([CarRun class]));
    
            NSLog(@"CarRun-malloc_size:%zd",malloc_size((__bridge const void*)car_run));
    
            NSLog(@"=====================================================================");
    
            //4.创建一个 CarRun 的子类 BBA_BMW 的实例 分配 内存
    
            BBA_BMW *bmw = [[BBA_BMW alloc]init];
    
            NSLog(@"BBA_BMW-getInstanceSize:%zd",class_getInstanceSize([BBA_BMW class]));
    
            NSLog(@"BBA_BMW-malloc_size:%zd",malloc_size((__bridge const void*)bmw));
    
            NSLog(@"=====================================================================");
    
            //5.创建一个 CarRun 的子类 BBA_BMW_RunFaster 的实例 分配 内存
    
            BBA_BMW_RunFaster *bmw_runfaster = [[BBA_BMW_RunFaster alloc]init];
    
            NSLog(@"BBA_BMW_RunFaster-getInstanceSize:%zd",class_getInstanceSize([BBA_BMW_RunFaster class]));
    
            NSLog(@"BBA_BMW_RunFaster-malloc_size:%zd",malloc_size((__bridge const void*)bmw_runfaster));
    
            
    
            
    
        }
    
        return 0;
    
    }
    复制代码

通过`打印结果`,`结合类的声明` 我们不得出结论:

*   `添加方法,不影响Instance对象的内存分配`: 初始化一个实例对象,至少所需要的内存
*   `添加成员对象,影响Instance对象的内存分配`:初始化一个实例对象,至少所需要的内存 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a76e414d05fd4929923ce099c6edf90f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   `Instance 对象`的实际所需内存与其自身的成员对象有关,也即是:instance对象在内存中存储的信息与其自身的成员对象有关,成员对象:
    *   isa指针(基类NSObject对象内部存在)
    *   其他成员变量的具体值

三、Class对象
=========

1.每个类 在内存中 有且只有一个 Class对象
-------------------------

我们在探索`NSObject对象`的时候，看到了底层代码:

        struct objc_class  { 
            private: 
            isa_t isa; 
            public:
            Class superclass;
    
            const char *name;
    
            uint32_t version;
    
            uint32_t info;
    
            uint32_t instance_size;
    
            struct old_ivar_list *ivars;
    
            struct old_method_list **methodLists;
    
            Cache cache;
    
            struct old_protocol_list *protocols;
    
            // CLS_EXT only
    
            const uint8_t *ivar_layout;
    
            struct old_class_ext *ext;
    
            ....    
        }
    复制代码

结合 `NSObject.h`文件:

    @interface NSObject <NSObject> {
    
    #pragma clang diagnostic push
    
    #pragma clang diagnostic ignored "-Wobjc-interface-ivars"
    
        Class isa  OBJC_ISA_AVAILABILITY;
    
    #pragma clang diagnostic pop
    ...
    }
    复制代码

从前面两段代码,我们不难得知`基类NSObject`中有一个 **`Class类型的对象`**:`isa指针`  
我们把前面创建了四个类,且有继承关系的代码,通过clang指令转换成c++:

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/33ed8781165c4cc194a69767c35e9a6c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ff9c414ac5184fcdaa35464ef5aa223e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/57f1042c9ba64a0a98993beac1c06fb4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

结合前面的继承关系,和转换成c++底层代码之后的具体情况(如上图),我们不难得出一个结论:

*   `每个类在内存中有且只有一个class对象`
    
    *   还可以通过打印内存地址证明:
    
                            Class objectClass1 = [object1 class];
                            Class objectClass2 = [object2 class];
                            Class objectClass3 = object_getClass(object1);
                            Class objectClass4 = object_getClass(object2);
                            Class objectClass5 = [NSObject class];
        
                            // 通过打印可以看出，上面几个方法返回的都是同一个类对象，内存地址都一样
                            NSLog(@"class - %p %p %p %p %p %d",
                                            objectClass1,
                                            objectClass2,
                                            objectClass3,
                                            objectClass4,
                                            objectClass5);
        
        复制代码
    
    ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/669792b604ab4c92bc356d0ac381a5e2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   我们可以通过NSObject的 `类方法`、`实例方法` 获得 `类对象`: ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/75c7636b4d6e4bb9a40ce465a1b2f039~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
    *   `+ (Class)class`
    *   `- (Class)class`
*   我们还可以通过 Runtime的API获得 `类对象`:
    *       Class _Nullable object_getClass(id _Nullable obj)
            复制代码
        
    *   该API效力等同于`+ (Class)class`、`- (Class)class` ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5c22d1da48334af2a8c96a5bfffb66a8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

**注意：**  class方法返回的一直是类对象，所以哪怕这样写还是会返回类对象

    Class objectMetaClass2 = [[[NSObject class] class] class];
    复制代码

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/88bcc191e4bc4d41950ca59453c44061~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

2.Class对象在内存中存储的信息
------------------

我们查看苹果官方开源的runtime代码我们得知(代码获取以及相关探索过程参考这篇文章:[OC的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")),Class底层代码如下:

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c312f3c7312643d3b098eca1114be93d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eeffba25555a44a8a4dae8cf334dd2f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0fe2721d27bf48c291bea4089d477042~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

        struct objc_class  { 
            private: 
            isa_t isa; 
            public:
            Class superclass;
    
            const char *name;
    
            uint32_t version;
    
            uint32_t info;
    
            uint32_t instance_size;
    
            struct old_ivar_list *ivars;
    
            struct old_method_list **methodLists;
    
            Cache cache;
    
            struct old_protocol_list *protocols;
    
            // CLS_EXT only
    
            const uint8_t *ivar_layout;
    
            //struct old_class_ext *ext;
            uint32_t size;
    
            const uint8_t *weak_ivar_layout;
    
            struct old_property_list **propertyLists;
            ....    
        }
    复制代码

查看源码之后,我们不难得出结论，**`class对象在内存中存储的信息`:**

*   1.  `isa指针`
*   2.  `superclass指针`
*   3.  类的属性信息（`@property`）、类的对象方法信息（`instance method`）
    
    *   我们通过`runtimeAPI`遍历一下methodLists内部的信息,得知:`struct old_method_list **methodLists`内部存储的都是 **类的对象方法信息（`instance method`）** ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aed53cb1ea9e4e2391c85d67aa10bf7e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   4.  类的协议信息（`protocol`）、类的成员变量信息（`ivar`）
*   .... ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f574dc18977d41339c6cd904337f4425~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3.总结
----

对instance对象和Class对象的总结:

*   **`isa指针:`** 每个类 在内存中 有且只有一个 Class对象，isa指针
*   **`class对象在内存中存储的信息`:**
    *   1.  `isa指针`
    *   2.  `superclass指针`
    *   3.  类的属性信息（`@property`）、类的对象方法信息（`instance method`）
    *   4.  类的协议信息（`protocol`）、类的成员变量信息（`ivar`）
    *   ....
*   **`成员变量的值 存储在实例对象中`:** 是存储在实例对象中的，因为只有当我们创建实例对象的时候才为成员变赋值
*   **`成员对象的类型、值、名称,存储在在class对象中`:** 但是 成员变量叫什么名字，是什么类型，只需要有一份就可以了。所以存储在class对象中

三、meta-class对象
==============

1.meta-class 相关的函数
------------------

我们在阅读苹果官方开源的objc代码时,我们发现有若干个与class相关的内部实现函数: ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a3fce3f0c60a4997a7ed9fb3c4cf9e80~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们前面已经探究了比较常见的`instance-对象`、`class对象`、`基类NSObject`、`superclass`....  
但我们在翻阅源码的时候发现了一个`meta-class`。  
现在我们去了解一下`meta-class` 我们全局搜索metaclass,找到一个返回Class对象的`objc_getMetaClass`函数的实现:

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a7a855e1266d4d1eaa520d272efbcf19~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们继续跳进去看一下`ISA()`函数的实现: ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/77fa7ba87f3d47b48840ceab9ad4c7ac~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们从这段代码可以看到isa对象调用了一个函数,而isa指针，本身就存在于 class内部:

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d1e17a86308347e1a2382d8dccc19056~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) isa内部定义为:

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/11f287f478c34e318f738c63e807a02b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 函数

    inline Class isa_t::getDecodedClass(bool authenticated)
    复制代码

的内部实现:

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd059480954a4bcaab1b05d61fa85fcc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

2.meta-class相关的探索结论
-------------------

综上,我们不难得出结论:

*   我们可以通过 当前class的isa指针 拿到 `metaClass`
*   若为当前Class是metaClass: 则 返回 其自身
*   metaClass 的 metaClass 就是其 自身： ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/65d47234873a42939b7a15a1245db242~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   我们结合Class的内部结构体实现,不难得出结论:
    *   metaClass 也是 class 类型(meta-class对象和class对象的内存结构是一样的)
    *   metaClass 是一种特殊 的 class 类型(与其它Class对象可能有不一样的用途)
*   meta-class 存储的方法列表为 `类的类方法信息（class method）` ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f1170d20bf4e4b32af5294108c26340c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3955b623c7fa4c19991eb9498c770e54~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   `meta-class`的 superclass为 `NSObject类型的 meta-class`
*   `meta-class`的 superclass的 superclass 为 基类 `NSObject`(非元类)
*   `meta-class`的 superclass的 superclass 的 superclass,也即是 基类 `NSObject`(非元类)的 superclass的 为 nil ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/53c983e0e38f4d639ecaebd4523a60fb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   基类 `NSObject`(非元类)的superclass 为 nil
*   补充,获取meta-class的函数 除了 函数`objc_getMetaClass`, 还有 `object_getClass`

3.meta-class简要总结
----------------

meta-class对象和class对象的内存结构是一样的，但是用途不一样，在内存中存储的信息主要包括:

*   isa指针
*   superclass指针
*   类的类方法信息（class method）
*   ....

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/30d0906735b44997b3c8b9a0bd8e83d0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

四、isa和superclass
================

1.`isa指针`
---------

通过前面篇幅的介绍,我们得知:每个类的`实例对象`、`类对象`、`元类对象`都有一个`isa指针`

    void test11(void){
    
        Class animalMetaCls =  getMetaClassFromClass([BBA_BMW_RunFaster class]);
    
        NSLog(@"superclass:%@",[BBA_BMW_RunFaster superclass]);
    
        NSLog(@"superclass-superclass:%@",[[BBA_BMW_RunFaster superclass] superclass]);
    
        NSLog(@"superclass-superclass-superclass:%@",[[[BBA_BMW_RunFaster superclass] superclass] superclass]);
    
        NSLog(@"superclass-superclass-superclass-superclass:%@",[[[[BBA_BMW_RunFaster superclass] superclass] superclass] superclass]);
    
        NSLog(@"superclass-superclass-superclass-superclass-superclass:%@",[[[[[BBA_BMW_RunFaster superclass] superclass] superclass] superclass] superclass]);
    
        NSLog(@"====================");
    
        NSLog(@"metaClass:%@",animalMetaCls);
    
        NSLog(@"metaClass-superclass:%@======metaClass-superclass_class_isMetaClass:%d",[animalMetaCls superclass],class_isMetaClass([animalMetaCls superclass]));
    
        NSLog(@"metaClass-superclass-superclass:%@======metaClass-superclass-superclass_class_isMetaClass:%d",[[animalMetaCls superclass]superclass],class_isMetaClass([[animalMetaCls superclass]superclass]));
    
        NSLog(@"====================");
    
        NSLog(@"metaClass-superclass-superclass-superclass:%@======metaClass-superclass-superclass-superclass_class_isMetaClass:%d",[[[animalMetaCls superclass]superclass]superclass],class_isMetaClass([[[animalMetaCls superclass]superclass]superclass]));
    
        NSLog(@"metaClass-superclass-superclass-superclass-superclass:%@======metaClass-superclass-superclasss-superclass-superclass_class_isMetaClass:%d",[[[[animalMetaCls superclass]superclass]superclass]superclass],class_isMetaClass([[[[animalMetaCls superclass]superclass]superclass]superclass]));
    
        NSLog(@"metaClass-superclass-superclass-superclass-superclass-superclass:%@======metaClass-superclass-superclass-superclasss-superclass-superclass_class_isMetaClass:%d",[[[[[animalMetaCls superclass]superclass]superclass]superclass] superclass],class_isMetaClass([[[[[animalMetaCls superclass]superclass]superclass]superclass] superclass]));
    
        
    
        NSLog(@"metaClass-superclass-superclass-superclass-superclass-superclass-superclass:%@======metaClass-superclass-superclass--superclass-superclasss-superclass-superclass_class_isMetaClass:%d",[[[[[[animalMetaCls superclass]superclass]superclass]superclass] superclass] superclass],class_isMetaClass([[[[[[animalMetaCls superclass]superclass]superclass]superclass] superclass] superclass]));
    
    }
     
    
    
    int main(int argc, const char * argv[]) {
    
        @autoreleasepool {
    
            test11();
    
        }
    
        return 0;
    
    }
    复制代码

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bbc09f87daf74660979771bcff2ed60e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   instance的isa指向class
    *   当调用对象方法时，通过instance的isa找到class，最后找到对象方法的实现进行调用
*   class的isa指向meta-class
    *   当调用类方法时，通过class的isa找到meta-class，最后找到类方法的实现进行调用
*   meta-class的isa指向基类的meta-class
*   基类的isa指向自己

2.`superclass指针`
----------------

通过前面篇幅的介绍,我们得知:每个类的类对象、元类对象都有一个`superclass指针`

*   class的superclass指针指向父类的class
    *   如果没有父类，superclass指针为nil
*   meta-class的superclass指向父类的meta-class
    *   基类的meta-class的superclass指向基类的class

3.`方法的调用|寻址`
------------

instance调用对象方法的轨迹

*   isa找到class，方法不存在，就通过superclass找父类 class调用类方法的轨迹
*   isa找meta-class，方法不存在，就通过superclass找父类 ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f6e03149bb164352991ea9e17339dfd3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18aa8f023ccc40149b7e200c793d6a66~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4.证明isa指针的指向如上结论？
-----------------

我们通过如下代码证明：

    NSObject *object = [[NSObject alloc] init];
    Class objectClass = [NSObject class];
    Class objectMetaClass = object_getClass([NSObject class]);
            
    NSLog(@"%p %p %p", object, objectClass, objectMetaClass);
     
    复制代码

打断点并通过控制台打印相应对象的isa指针

![打印object的isa指针和objectClass的地址](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aec125628b9c46cd84b407e34f5cd26f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们发现object->isa与objectClass的地址不同，这是因为从64bit开始，isa需要进行一次位运算，才能计算出真实地址。而位运算的值我们可以通过下载[objc源代码](https://link.juejin.cn?target=https%3A%2F%2Fopensource.apple.com%2Ftarballs%2Fobjc4%2F "https://link.juejin.cn?target=https%3A%2F%2Fopensource.apple.com%2Ftarballs%2Fobjc4%2F")找到。

![ISA_MASK](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a6bbbd900c19485486d0c68e7d3c2204~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们通过位运算进行验证。

![isa通过位运算计算出正确的地址](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5167fe06dd884672a50e748177157fde~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们发现，object-isa指针地址0x001dffff96537141经过同0x00007ffffffffff8位运算，得出objectClass的地址0x00007fff96537140

接着我们来验证class对象的isa指针是否同样需要位运算计算出meta-class对象的地址。 当我们以同样的方式打印objectClass->isa指针时，发现无法打印

![p/x objectClass->isa](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7018e5e21aae4ecab79c6b0d9385ea2c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

同时也发现左边objectClass对象中并没有isa指针。我们来到Class内部看一下

    typedef struct objc_class *Class;
    
    struct objc_class {
        Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
    
    #if !__OBJC2__
        Class _Nullable super_class                              OBJC2_UNAVAILABLE;
        const char * _Nonnull name                               OBJC2_UNAVAILABLE;
        long version                                             OBJC2_UNAVAILABLE;
        long info                                                OBJC2_UNAVAILABLE;
        long instance_size                                       OBJC2_UNAVAILABLE;
        struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
        struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
        struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
        struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
    #endif
    
    } OBJC2_UNAVAILABLE;
    /* Use `Class` instead of `struct objc_class *` */
    
    复制代码

相信了解过isa指针的同学对objc\_class结构体内的内容很熟悉了，今天这里不深入研究，我们只看第一个对象是一个isa指针，为了拿到isa指针的地址，我们自己创建一个同样的结构体并通过强制转化拿到isa指针。

    struct hp_objc_class{
        Class isa;
    };
    
    
    Class objectClass = [NSObject class];
    struct hp_objc_class *objectClass2 = (__bridge struct hp_objc_class *)(objectClass);
    
    复制代码

此时我们重新验证一下

![objectClass2->isa](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/05aad9a0d09d4555a0bc2495779b2aca~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

确实，objectClass2的isa指针经过位运算之后的地址是meta-class的地址。

五、进一步探索 Class对象的底层结构
====================

1.Class的本质
----------

我们知道不管是类对象还是元类对象，类型都是Class，class和mete-class的底层都是objc\_class结构体的指针，内存中就是结构体，本章来探寻Class的本质。

    Class objectClass = [NSObject class];        
    Class objectMetaClass = object_getClass([NSObject class]);
     
    复制代码

点击Class来到内部，我们可以发现

    typedef struct objc_class *Class;
    复制代码

Class对象其实是一个指向objc\_class结构体的指针。因此我们可以说类对象或元类对象在内存中其实就是objc\_class结构体。

我们来到objc\_class内部，可以看到这段在底层原理中经常出现的代码。

    struct objc_class {
        Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
    
    #if !__OBJC2__
        Class _Nullable super_class                              OBJC2_UNAVAILABLE;
        const char * _Nonnull name                               OBJC2_UNAVAILABLE;
        long version                                             OBJC2_UNAVAILABLE;
        long info                                                OBJC2_UNAVAILABLE;
        long instance_size                                       OBJC2_UNAVAILABLE;
        struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
        struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
        struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
        struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
    #endif
    
    } OBJC2_UNAVAILABLE;
    /* Use `Class` instead of `struct objc_class *` */
     
    复制代码

这部分代码相信在文章中很常见，但是`OBJC2_UNAVAILABLE;`说明这些代码已经不在使用了。那么目前objc\_class的结构是什么样的呢？我们通过objc源码中去查找objc\_class结构体的内容。

![部分objc_class代码内容](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/457e843f6429448cb60b51f3df11dff9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们发现这个结构体继承 objc\_object 并且结构体内有一些函数，因为这是c++结构体，在c上做了扩展，因此结构体中可以包含函数。我们来到objc\_object内，截取部分代码

![objc_object内部分代码](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e9052cc660184f9f8b462aec97a0ad61~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们发现objc\_object中有一个isa指针，那么objc\_class继承objc\_object，也就同样拥有一个isa指针

那么我们之前了解到的，类中存储的类的成员变量信息，实例方法，属性名等这些信息在哪里呢。我们来到class\_rw\_t中，截取部分代码，我们发现class\_rw\_t中存储着方法列表，属性列表，协议列表等内容。

![class_rw_t部分代码](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fa7926342899412eba07d41eca4c012e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

而class\_rw\_t是通过bits调用data方法得来的，我们来到data方法内部实现。我们可以看到，data函数内部仅仅对bits进行&FAST\_DATA\_MASK操作

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/85fc10aea8104cf691441eeccbc808cd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5ee4a7802ef0420fbb8bf1c639262e50~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

而成员变量信息则是存储在class\_ro\_t内部中的，我们来到class\_ro\_t内查看。

![class_ro_t内部代码](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b64d184af39a4016af1f8d8a7341c41a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

最后总结通过一张图进行总结

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cca4b5a9b1c44e5abf4f0d830fc114c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

2.证明上述通过阅读源码得出的结论正确与否。
----------------------

因为底层的部分API无法直接在项目中使用,且我们通过阅读了苹果官方开源的底层代码,所以我们可以模仿官方开源的底层实现,在自己的工程 自定义结构体模仿Class的底层实现。  
**如果我们自己写的结构和`objc_class`真实结构是一样的，那么当我们强制转化的时候，就会一一对应的赋值。那么我们就可以拿到结构体内部的信息**。

### 2.1 自定义结构体，模仿苹果官方class底层实现

下列代码是我们仿照objc\_class结构体，提取其中需要使用到的信息，自定义的一个结构体: （注意,要把.m文件改成.mm,因为这段代码的实现属于c++的语法）

    #import <Foundation/Foundation.h>
    
    #ifndef HPClassInfo_h
    #define HPClassInfo_h
    
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
    
    struct bucket_t {
        cache_key_t _key;
        IMP _imp;
    };
    
    struct cache_t {
        bucket_t *_buckets;
        mask_t _mask;
        mask_t _occupied;
    };
    
    struct entsize_list_tt {
        uint32_t entsizeAndFlags;
        uint32_t count;
    };
    
    struct method_t {
        SEL name;
        const char *types;
        IMP imp;
    };
    
    struct method_list_t : entsize_list_tt {
        method_t first;
    };
    
    struct ivar_t {
        int32_t *offset;
        const char *name;
        const char *type;
        uint32_t alignment_raw;
        uint32_t size;
    };
    
    struct ivar_list_t : entsize_list_tt {
        ivar_t first;
    };
    
    struct property_t {
        const char *name;
        const char *attributes;
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
    
    struct class_ro_t {
        uint32_t flags;
        uint32_t instanceStart;
        uint32_t instanceSize;  // instance对象占用的内存空间
    #ifdef __LP64__
        uint32_t reserved;
    #endif
        const uint8_t * ivarLayout;
        const char * name;  // 类名
        method_list_t * baseMethodList;
        protocol_list_t * baseProtocols;
        const ivar_list_t * ivars;  // 成员变量列表
        const uint8_t * weakIvarLayout;
        property_list_t *baseProperties;
    };
    
    struct class_rw_t {
        uint32_t flags;
        uint32_t version;
        const class_ro_t *ro;
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
        class_rw_t* data() { // 提供data()方法进行 & FAST_DATA_MASK 操作
            return (class_rw_t *)(bits & FAST_DATA_MASK);
        }
    };
    
    /* OC对象 */
    struct hp_objc_object {
        void *isa;
    };
    
    /* 类对象 */
    struct hp_objc_class : hp_objc_object {
        Class superclass;
        cache_t cache;
        class_data_bits_t bits;
    public:
        class_rw_t* data() {
            return bits.data();
        }
        
        hp_objc_class* metaClass() { // 提供metaClass函数，获取元类对象
    // 前面我们讲解过，isa指针需要经过一次 & ISA_MASK操作之后才得到真正的地址
            return (hp_objc_class *)((long long)isa & ISA_MASK);
        }
    };
    
    #endif /* HPClassInfo_h */
     
    复制代码

### 2.2 添加几个类,用于制造验证数据

接下来我们将自己定义的类强制转化为我们自定义的精简的class结构体类型。

    #import <Foundation/Foundation.h>
    #import <objc/runtime.h>
    #import "HPClassInfo.h"
    
    /* Person */
    @interface Person : NSObject <NSCopying>
    {
        @public
        int _age;
    }
    @property (nonatomic, assign) int height;
    - (void)personMethod;
    + (void)personClassMethod;
    @end
    
    @implementation Person
    - (void)personMethod {}
    + (void)personClassMethod {}
    @end
    
    /* Student */
    @interface Student : Person <NSCoding>
    {
        @public
        int _no;
    }
    
    @property (nonatomic, assign) int score;
    - (void)studentMethod;
    + (void)studentClassMethod;
    @end
    
    @implementation Student
    - (void)studentMethod {}
    + (void)studentClassMethod {}
    @end
    
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            NSObject *object = [[NSObject alloc] init];
            Person *person = [[Person alloc] init];
            Student *student = [[Student alloc] init];
            
            hp_objc_class *objectClass = (__bridge hp_objc_class *)[object class];
            hp_objc_class *personClass = (__bridge hp_objc_class *)[person class];
            hp_objc_class *studentClass = (__bridge hp_objc_class *)[student class];
            
            hp_objc_class *objectMetaClass = objectClass->metaClass();
            hp_objc_class *personMetaClass = personClass->metaClass();
            hp_objc_class *studentMetaClass = studentClass->metaClass();
            
            class_rw_t *objectClassData = objectClass->data();
            class_rw_t *personClassData = personClass->data();
            class_rw_t *studentClassData = studentClass->data();
            
            class_rw_t *objectMetaClassData = objectMetaClass->data();
            class_rw_t *personMetaClassData = personMetaClass->data();
            class_rw_t *studentMetaClassData = studentMetaClass->data();
    
            // 0x00007ffffffffff8
            NSLog(@"%p %p %p %p %p %p",  objectClassData, personClassData, studentClassData,
                  objectMetaClassData, personMetaClassData, studentMetaClassData);
    
        return 0;
    } 
    复制代码

### 2.3 打断点求证

通过打断点，我们可以看到class内部信息。

至此，我们再次拿出那张经典的图，挨个分析图中isa指针和superclass指针的指向

![isa、superclass指向图](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9046c56660104389843e6a2010ef8008~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 2.4 instance对象

首先我们来看instance对象，我们通过前面篇幅的介绍不难得知:

*   `instance对象`中存储着isa指针和其他成员变量，
*   `instance对象`的isa指针是指向其**类对象**地址的 我们首先分析上述代码中我们创建的:
*   `object`，`person`，`student` 三个 `instance对象`
*   与其相对应的类对象 `objectClass`，`personClass`，`studentClass`。

![instance对象分析](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e64a0a6919924da3868f3df4c29cf612~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从上图中我们可以发现:

*   1.  `instance对象`中确实存储了isa指针和其成员变量
*   2.  将 `instance对象的isa指针` 经过 `&运算` 之后计算出的地址确实是其 `相应类对象的内存地址`
*   3.  由此我们**证明isa，superclass指向图中的1，2，3号线**。

### 2.5 class对象

接着我们来看class对象，同样通过前面的篇幅介绍，我们明确知道:

*   `class对象` 中存储着:
    *   `isa指针`，
    *   `superclass指针`
    *   `类的属性信息`，`类的成员变量信息`，`类的对象方法`，和 `类的协议信息`
*   而通过上面对object源码的分析，我们知道 以上 信息存储在 `class对象的class_rw_t中` 我们通过强制转化来窥探其中的内容。如下图

![personClassData内结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6e7523cc369d411d9e2ca27a8a26877c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   上图中我们通过模拟对person类对象调用.data函数:
    *   1.  即对bits进行&FAST\_DATA\_MASK(0x00007ffffffffff8UL)运算
    *   2.  并转化为class\_rw\_t。即上图中的personClassData。
*   其中我们发现 `成员变量信息`，`对象方法`，`属性等信息` **只显示first第一个**
    *   如果想要拿到更多的需要通过代码将指针后移获取。
*   上图中的instaceSize = 16 也同 person对象中isa指针8个字节+\_age4个字节+\_height4个字节相对应起来。（这里不在展开对objectClassData及studentClassData进行分析，基本内容同personClassData相同。）

那么类对象中的isa指针和superclass指针的指向是否如那张经典的图示呢？我们来验证一下。

![类对象的isa指针和superclass指针指向](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6affee94bb3b47c0ab9af1a8c6deee2d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上图中的内存地址的分析，由此我们证明:

*   `isa，superclass指向图中，isa指针的4，5，6号线`
*   `以及superclass指针的10，11，12号线`

### 2.6 meta-class对象

最后我们来看 `meta-class元类对象`  
前面篇幅中提到 `meta-class中`存储着:

*   `isa指针`
*   `superclass指针`
*   `类的类方法信息`。
*   同时我们知道`meta-class元类对象`与`class类对象`，具有相同的结构，只不过存储的信息不同。
*   并且`元类对象的isa指针` 指向 `基类的元类对象`，
*   `基类的元类对象的isa指针`指向`自己`
*   `元类对象的superclass指针`指向`其父类的元类对象`
*   `基类的元类对象的superclass`指针`指向其类对象`。

与class对象相同，我们同样通过模拟对person元类对象调用.data函数，即对bits进行&FAST\_DATA\_MASK(0x00007ffffffffff8UL)运算，并转化为class\_rw\_t。

![personMetaClassData内结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0efb0750ea4b429b8d58ea1b269a94f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

首先我们可以看到结构同personClassData相同，并且成员变量及属性列表等信息为空，而methods中存储着类方法personClassMethod。

接着来验证isa及superclass指针的指向是否同上图序号标注一样。

![meta-class的isa指针指向](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3b403bcb2012473baf560db93cbc6f77~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中通过地址证明meta-class的isa指向基类的meta-class，基类的isa指针也指向自己。

![meta-class的superclass指针指向](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0f5c8095d98b45f5800401063e52e843~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中通过地址证明meta-class的superclass指向父类的meta-class，基类的meta-class的superclass指向基类的class类。
