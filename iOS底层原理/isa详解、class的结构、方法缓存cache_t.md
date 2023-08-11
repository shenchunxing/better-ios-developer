# isa详解、class的结构、方法缓存cache_t

一、Runtime简介
===========

1\. OC语言的本质回顾
-------------

我们 之前在 探索 [OC语言的本质](https://juejin.cn/post/7094409219361193997 "https://juejin.cn/post/7094409219361193997")时,了解到Apple官网对OC的介绍: ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e94a5620dd2423989298b734127909d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   Objective-C是程序员在为OS X和iOS编写软件时使用的主要编程语言(之一,现在已经还有Swift语言)
*   它`是C编程语言的超集`，提供`面向对象`的功能和`动态运行`时
*   Objective-C`继承了C语言的语法`、`基本类型`和`流控制语句`，并添加了用于`定义类和方法`的语法。(OC完全兼容标准C语言)
*   它还增加了`面向对象`管理和`对象字面量`的语言级别支持，同时提供**动态`类型和绑定`**，将许多责任推迟到`运行时`

2\. Runtime
-----------

官网中介绍OC语言时,提及的`动态运行`、**动态`类型和绑定`**、将许多责任推迟到`运行时`等许多运行时特性,就是讲通过Runtime这套底层API来实现的。

虽然,`Objective-C`是一门闭源的语言,但官方也对该语言有了适当的开源。我们通常可以通过该地址去查找苹果官方开源的一些源码:[opensource.apple.com/tarballs/](https://link.juejin.cn?target=https%3A%2F%2Fopensource.apple.com%2Ftarballs%2F "https://opensource.apple.com/tarballs/")

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6bc817df2da84fb88031dd78fe71f383~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 通过全局搜索 `objc`,可以找到`objc4`,然后下载最新的开源版本代码 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9a49551db70c437eaef9c7f0d34bdbef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们可以从官方开源的代码中也可以看到 官方开源的一些实现,其中就包含了runtime的一些实现 ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/117ff89facb04af8bbe0171c73025eb0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

综上,我们不难得出结论:

*   `Objective-C`是一门动态性比较强的编程语言，跟`C、C++`等语言有着很大的不同；
*   `Objective-C`的动态性是由`Runtime API`来支撑的
*   `Runtime API`提供的接口基本都是`C语言`的，源码由`C\C++\汇编语言`编写

二、isa详解
=======

前面，我们在探索 [OC中的几种对象和对象的isa指针](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012")的时候得出一些结论,我们简单回顾一下: Objective-C中的对象，简称OC对象，主要可以分为3种

*   `instance`对象（实例对象）
*   `class`对象（类对象）
*   `meta-class`对象（元类对象）

1\. `instance`对象
----------------

`instance对象`就是通过类`alloc`出来的对象，**每次调用alloc都会产生**`新的instance对象`

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cb8fd1721ce447eaba7497b405486dd2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   object1、object2是NSObject的instance对象（实例对象）
*   它们是不同的两个对象，分别占据着`两块不同的内存`  
    ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d805ef832c51464b8a99a8b821845113~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9aaae2abe8094f49a4334df28a1783a1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   instance对象在内存中存储的信息包括
    *   `isa指针`
    *   其他成员变量

2\. `class`对象
-------------

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/54b6a68bde4147c683a4dd3f270cb52e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   objectClass1 ~ objectClass5都是NSObject的`class对象`（类对象）
*   它们是同一个对象。每个类在 **`内存中有且只有一个`** class对象

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4e15dc0c21b3440b89d58ad508caf36f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   class对象在内存中存储的信息主要包括:
    *   `isa指针`
    *   `superclass指针`
    *   类的`属性`信息（@property）、类的`对象方法`信息（instance method）
    *   类的`协议`信息（protocol）、类的`成员变量`信息（ivar）
    *   ......

3\. `meta-class`对象
------------------

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/367bbfdd9fa44e499e8cc0a12694d050~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   objectMetaClass是NSObject的`meta-class对象`（元类对象）
*   每个类在内存中`有且只有一个meta-class对象`

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/642715824948456982650a87e34fb45f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   meta-class对象和class对象的内存结构是一样的，但是用途不一样，在内存中存储的信息主要包括
    *   `isa指针`
    *   `superclass指针`
    *   类的`类方法`信息（class method）
    *   ......

4\. `isa`指针
-----------

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f6e03149bb164352991ea9e17339dfd3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   **instance**的`isa`指向**class**
    
    *   当调用`对象方法`时，通过**instance**的`isa`找到`class`，最后找到对象方法的实现进行调用
*   **class**的`isa`指向**meta-class**
    
    *   当调用`类方法`时，通过**class**的`isa`找到`meta-class`，最后找到类方法的实现进行调用

> **class对象的superclass指针**

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/959a1f36752d415ca014854ee2acfbae~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   当Student的`instance`对象要调用Person的对象方法时，会先通过`isa`找到Student的`class`
*   然后通过`superclass`找到Person的`class`，最后找到对象方法的实现进行调用

> **meta-class对象的superclass指针**

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9b38352e4afb44ca9fa02785a8b90e91~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   当Student的`class`要调用Person的类方法时，会先通过`isa`找到Student的`meta-class`
*   然后通过`superclass`找到Person的`meta-class`，最后找到类方法的实现进行调用

5\. 对`isa`、`superclass`总结
-------------------------

> `isa`

*   `instance`的`isa`指向`class`
*   `class`的`isa`指向`meta-class`
*   `meta-class`的`isa`指向基类的`meta-class`
*   基类的`class`的`isa` 指向基类的`meta-class`
*   基类的`meta-class`的`isa`指向基类的`meta-class`本身

> `superclass`

*   `class`的`superclass`指向父类的`class`
    *   如果没有父类，superclass指针为nil
*   `meta-class`的`superclass`指向父类的`meta-class`
    *   基类的meta-class的superclass指向基类的class

> `方法调用`

*   instance调用对象方法的轨迹
    
    *   isa找到class，方法不存在，就通过superclass找父类
*   class调用类方法的轨迹
    
    *   isa找meta-class，方法不存在，就通过superclass找父类

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18aa8f023ccc40149b7e200c793d6a66~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

6\. 综上
------

结合前面的结论,我们不难得知,OC语言中的三类对象,是通过isa指针建立联系的,而OC的运行时特性所依赖的的RuntimeAPI正是在一定程度上基于isa指针建立的三类对象的联系,实现 动态运行时的。

因此,要想`学习Runtime`，首先要了解它`底层的一些常用数据结构`，比如`isa指针`

*   在arm64架构之前，`isa`就是一个`普通的指针`，存储着`Class`、`Meta-Class`对象的内存地址
*   从arm64架构开始，对isa进行了优化，变成了`一个共用体（union）结构`，还使用`位域来存储更多的信息`。需要通过ISA\_MASK进行一定的位运算才能进一步获取具体的信息

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9202a1cd44c746c1a5db37af5253e3d1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

7\. `isa`的本质
------------

在arm64架构之后 OC对象的`isa指针`并不是直接指向`类对象`或者`元类对象`，而是需要`&ISA_MASK`通过`位运算`才能获取到`类对象`或者`元类对象`的地址。  
今天来探寻一下为什么需要`&ISA_MASK`才能获取到`类对象`或者`元类对象`的地址，以及这样的好处。(苹果官方为什么做这个优化呢？我们来一步一步探索一下！)

首先在源码中找到`isa指针`，看一下`isa指针`的本质。

    // 截取objc_object内部分代码
    struct objc_object {
    private:
        isa_t isa;
    } 
    复制代码

`isa指针`其实是一个`isa_t`类型的共用体，来到`isa_t`内部查看其结构

    // 精简过的isa_t共用体
    union isa_t 
    {
        isa_t() { }
        isa_t(uintptr_t value) : bits(value) { }
    
        Class cls;
        uintptr_t bits;
    
    #if SUPPORT_PACKED_ISA
    # if __arm64__      
    #   define ISA_MASK        0x0000000ffffffff8ULL
    #   define ISA_MAGIC_MASK  0x000003f000000001ULL
    #   define ISA_MAGIC_VALUE 0x000001a000000001ULL
        struct {
            uintptr_t nonpointer        : 1;
            uintptr_t has_assoc         : 1;
            uintptr_t has_cxx_dtor      : 1;
            uintptr_t shiftcls          : 33; // MACH_VM_MAX_ADDRESS 0x1000000000
            uintptr_t magic             : 6;
            uintptr_t weakly_referenced : 1;
            uintptr_t deallocating      : 1;
            uintptr_t has_sidetable_rc  : 1;
            uintptr_t extra_rc          : 19;
        #       define RC_ONE   (1ULL<<45)
        #       define RC_HALF  (1ULL<<18)
        };
    
    # elif __x86_64__     
    #   define ISA_MASK        0x00007ffffffffff8ULL
    #   define ISA_MAGIC_MASK  0x001f800000000001ULL
    #   define ISA_MAGIC_VALUE 0x001d800000000001ULL
        struct {
            uintptr_t nonpointer        : 1;
            uintptr_t has_assoc         : 1;
            uintptr_t has_cxx_dtor      : 1;
            uintptr_t shiftcls          : 44; // MACH_VM_MAX_ADDRESS 0x7fffffe00000
            uintptr_t magic             : 6;
            uintptr_t weakly_referenced : 1;
            uintptr_t deallocating      : 1;
            uintptr_t has_sidetable_rc  : 1;
            uintptr_t extra_rc          : 8;
    #       define RC_ONE   (1ULL<<56)
    #       define RC_HALF  (1ULL<<7)
        };
    
    # else
    #   error unknown architecture for packed isa
    # endif
    #endif 
    复制代码

上述源码中`isa_t`是`union`类型，`union`表示共用体。

从源码中我们可以看到:

*   共用体中有一个结构体
*   结构体内部分别定义了一些变量
*   变量后面的值代表的是该变量占用多少个字节，也就是位域技术

> **了解共用体**

*   在进行某些算法的C语言编程的时候，需要使几种不同类型的变量的值存放到同一段内存单元中；
*   这种几个不同的变量共同占用一段内存的结构，在C语言中，被称作“共用体”类型结构，简称共用体

接下来使用共用体的方式来深入的了解apple为什么要使用共用体，以及使用共用体的好处。

### 7.1 探寻过程

#### 7.1.1 模仿底层对数据的存储

接下来使用代码来模仿底层的做法，创建一个person类并含有三个BOOL类型的成员变量。

    @interface Person : NSObject
    @property (nonatomic, assign, getter = isTall) BOOL tall;
    @property (nonatomic, assign, getter = isRich) BOOL rich;
    @property (nonatomic, assign, getter = isHansome) BOOL handsome;
    @end 
    复制代码

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            NSLog(@"%zd", class_getInstanceSize([Person class]));
        }
        return 0;
    }
    // 打印内容
    // Runtime - union探寻[52235:3160607] 16
    复制代码

上述代码中Person含有3个BOOL类型的属性，打印Person类对象占据内存空间为16

*   也就是`(isa指针 = 8) + (BOOL tall = 1) + (BOOL rich = 1) + (BOOL handsome = 1) = 13`
*   因为`内存对齐`原则所以Person类对象占据内存空间为16(关于这内存对齐相关的知识,我们在[这篇文章](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012")介绍过)

通过共用体技术,可以使几个不同的变量**存放到同一段内存**中去，可以很大程度上节省内存空间

> 尝试用一个字节存储三个BOOL类型的变量的值

*   那么我们知道BOOL值只有两种情况 0 或者 1，但是却占据了一个字节的内存空间
*   而一个内存空间中有8个二进制位，并且二进制只有 0 或者 1
    *   那么是否可以使用1个二进制位来表示一个BOOL值
    *   也就是说3个BOOL值最终只使用3个二进制位，也就是一个内存空间即可呢？
    *   如何实现这种方式？

首先如果使用这种方式 **`需要自己写setter、getter方法的声明与实现`**:

*   不可以写属性声明，因为一旦写属性，系统会自动帮我们添加成员变量(会开辟内存空间、也会实现setter、getter。我为了探索要规避系统的自动生成)

另外想要将三个BOOL值存放在一个字节中，我们可以添加一个`char`类型的成员变量

*   `char`类型占据一个字节内存空间，也就是8个二进制位
*   可以使用其中最后三个二进制位来存储3个BOOL值。

    @interface Person()
    {
        char _tallRichHandsome;
    } 
    复制代码

例如`_tallRichHansome的值为 0b 0000 0010` ，那么只使用8个二进制位中的最后3个，分别为其赋值0或者1来代表`tall、rich、handsome`的值。如下图所示:

![存储方式](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/07e4c2cb23464acbb71e606eab63513b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

那么现在面临的问题就是如何取出8个二进制位中的某一位的值，或者为某一位赋值呢？

##### a.) 取值

假如将三个BOOL变量的值 存在 一个字节里面,我们首先探讨一下如何从一个字节里面 取出 这三个变量的具体值。

可以使用1个二进制位来表示一个BOOL值,那么从低位开始,一个二进制位代表一个值。

*   假如char类型的成员变量中存储的二进制为`0b 0000 0010`
*   如果想将倒数第2位的值也就是rich的值取出来，则需要进行 进制位的 `位运算`
*   我们可以使用&进行`按位与`运算进而取出相应位置的值

> 了解【&：按位与】 **同真为真，其他都为假**

    // 示例
    // 取出倒数第三位 tall
      0000 0010
    & 0000 0100
    ------------
      0000 0000  // 取出倒数第三位的值为0，其他位都置为0
    
    // 取出倒数第二位 rich
      0000 0010
    & 0000 0010
    ------------
      0000 0010 // 取出倒数第二位的值为1，其他位都置为0
    复制代码

> 结论: **`按位与可以用来取出特定的二进制位的值`**

*   想取出哪一位就将那一位置为1，其他为都置为0
*   然后同原数据进行按位与计算，即可取出特定的位

> 用 `按位与` 运算来实现get方法

    #define TallMask 0b00000100 // 4
    #define RichMask 0b00000010 // 2
    #define HandsomeMask 0b00000001 // 1
    
    - (BOOL)tall
    {
        return !!(_tallRichHandsome & TallMask);
    }
    - (BOOL)rich
    {
        return !!(_tallRichHandsome & RichMask);
    }
    - (BOOL)handsome
    {
        return !!(_tallRichHandsome & HandsomeMask);
    } 
    复制代码

上述代码中使用两个`!!（非）`来将值改为bool类型。同样使用上面的例子

    // 取出倒数第二位 rich
      0000 0010  // _tallRichHandsome
    & 0000 0010 // RichMask
    ------------
      0000 0010 // 取出rich的值为1，其他位都置为0 
    复制代码

上述代码中`(_tallRichHandsome & TallMask)`的值为`0000 0010`也就是2，但是我们需要的是一个BOOL类型的值 0 或者 1

*   那么`!!2`就将 2 先转化为 0 ，之后又转化为 1
*   相反如果按位与取得的值为 0 时，`!!0`将 0 先转化为 1 之后又转化为 0
*   因此使用`!!`两个非操作将值转化为 0 或者 1 来表示相应的值。

#### 7.1.2 优化掩码,使其增加可读性

> **掩码: 一般用来 进行 `按位与（&）`运算的值称之为`掩码`**

*   上述代码中定义了三个宏，用来分别进行按位与运算而取出相应的值
*   三个宏的具体值都是掩码
*   为了能更清晰的表明掩码是为了取出哪一位的值，上述三个宏的定义可以使用`左移运算符:<<`来优化

> **左移运算符 `A<<n` ,表示在A数值的二进制数据中左移n位得到一个值** ![<<左移操作符示例](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/42377eb08edf47cbab62feb40418797b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

那么上述宏定义可以使用`<<（左移）`优化成如下代码

    #define TallMask (1<<2) // 0b00000100 4
    #define RichMask (1<<1) // 0b00000010 2
    #define HandsomeMask (1<<0) // 0b00000001 1 
    复制代码

##### b.) 设值

我们如果`想给某一个二进制位赋值` 0或者1，依然可以使用 `位运算`

**如果想设置某个值的某个二进制位的值为1,那么只要在该二进制位 **与1进行** `|（按位或`运算即可**

> 按位或 运算: **`| : 按位或，只要有一个1即为1，否则为0。`** 在当前谈论的案例中,也可以说:  
> **如果想设置BOOL值为YES的话，那么将原本的值与掩码（该位置二进制位的值是1）进行按位或的操作即可。  
> `例如我们想将tall置为1`**

    // 将倒数第三位 tall置为1
      0000 0010  // _tallRichHandsome
    | 0000 0100  // TallMask
    ------------
      0000 0110 // 将tall置为1，其他位值都不变 
    复制代码

> 按位与 运算: **`&: 按位与，同真为真，其他都为假`** 在当前谈论的案例中,也可以说:  
> **如果想设置BOOL值为NO的话，需要将掩码按位取反（~ : 按位取反符）（该位置二进制位的值即变成0），之后在与原本的值进行按位与操作即可。**

    // 将倒数第二位 rich置为0
      0000 0010  // _tallRichHandsome
    & 1111 1101  // RichMask按位取反
    ------------
      0000 0000 // 将rich置为0，其他位值都不变
    复制代码

此时set方法内部实现如下

    - (void)setTall:(BOOL)tall
    {
        if (tall) { // 如果需要将值置为1  // 按位或掩码
            _tallRichHandsome |= TallMask;
        }else{ // 如果需要将值置为0 // 按位与（按位取反的掩码）
            _tallRichHandsome &= ~TallMask; 
        }
    }
    - (void)setRich:(BOOL)rich
    {
        if (rich) {
            _tallRichHandsome |= RichMask;
        }else{
            _tallRichHandsome &= ~RichMask;
        }
    }
    - (void)setHandsome:(BOOL)handsome
    {
        if (handsome) {
            _tallRichHandsome |= HandsomeMask;
        }else{
            _tallRichHandsome &= ~HandsomeMask;
        }
    } 
    复制代码

写完set、get方法之后通过代码来查看一下是否可以设值、取值成功。

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            Person *person  = [[Person alloc] init];
            person.tall = YES;
            person.rich = NO;
            person.handsome = YES;
            NSLog(@"tall : %d, rich : %d, handsome : %d", person.tall,person.rich,person.handsome);
        }
        return 0;
    } 
    复制代码

打印内容

    Runtime - union探寻[58212:3857728] tall : 1, rich : 0, handsome : 1
    复制代码

可以看出上述代码可以正常赋值和取值。但是代码还是有一定的局限性:

*   当需要添加新属性的时候，需要重复上述工作，并且代码可读性比较差
*   接下来使用结构体的位域特性来优化上述代码

#### 7.1.3 用 位域 技术 实现 变量的 存取

将上述代码进行优化，使用结构体位域，可以使代码可读性更高。 **位域声明 `位域名 : 位域长度;`**

使用位域需要注意以下3点：

*   1. 如果一个字节所剩空间不够存放另一位域时，应从下一单元起存放该位域。
    *   也可以有意使某位域从下一单元开始
*   2.  位域的长度不能大于数据类型本身的长度
    
    *   比如int类型就不能超过32位二进位。
*   3. 位域可以无位域名，这时它只用来作填充或调整位置
    *   无名的位域是不能使用的

上述代码使用结构体位域优化之后。

    @interface Person()
    {
        struct {
            char handsome : 1; // 位域，代表占用一位空间
            char rich : 1;  // 按照顺序只占一位空间
            char tall : 1; 
        }_tallRichHandsome;
    } 
    复制代码

set、get方法中可以直接通过结构体赋值和取值

    - (void)setTall:(BOOL)tall
    {
        _tallRichHandsome.tall = tall;
    }
    - (void)setRich:(BOOL)rich
    {
        _tallRichHandsome.rich = rich;
    }
    - (void)setHandsome:(BOOL)handsome
    {
        _tallRichHandsome.handsome = handsome;
    }
    - (BOOL)tall
    {
        return _tallRichHandsome.tall;
    }
    - (BOOL)rich
    {
        return _tallRichHandsome.rich;
    }
    - (BOOL)handsome
    {
        return _tallRichHandsome.handsome;
    } 
    复制代码

通过代码验证一下是否可以赋值或取值正确

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            Person *person  = [[Person alloc] init];
            person.tall = YES;
            person.rich = NO;
            person.handsome = YES;
            NSLog(@"tall : %d, rich : %d, handsome : %d", person.tall,person.rich,person.handsome);
        }
        return 0;
    } 
    复制代码

首先在log处打个断点，查看\_tallRichHandsome内存储的值

![_tallRichHandsome内存储的值](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9a4492c9b9ff4deab74c00f7ed346db1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

因为`_tallRichHandsome`占据一个内存空间，也就是8个二进制位，我们将05十六进制转化为二进制查看

![05转化为二进制](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/878c48288cdc403494837cd4015c1d00~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中可以发现，倒数第三位也就是tall值为1，倒数第二位也就是rich值为0，倒数一位也就是handsome值为1，如此看来和上述代码中我们设置的值一样。可以成功赋值。

接着继续打印内容： `Runtime - union探寻[59366:4053478] tall : -1, rich : 0, handsome : -1`

此时可以发现问题，tall与handsome我们设值为YES，讲道理应该输出的值为1为何上面输出为-1呢？

并且上面通过打印`_tallRichHandsome`中存储的值，也确认`tall`和`handsome`的值都为1。我们再次打印`_tallRichHandsome`结构体内变量的值。

![person内部_tallRichHandsome结构体变量](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/12fd08fbfb0d49b299ba67fabace076f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中可以发现，handsome的值为0x01，通过计算器将其转化为二进制

![0x01二进制数](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3299975af959443f933c2f9cf1c6e95c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

可以看到值确实为1的，为什么打印出来值为-1呢？此时应该可以想到应该是get方法内部有问题。我们来到get方法内部通过打印断点查看获取到的值。

    - (BOOL)handsome
    {
        BOOL ret = _tallRichHandsome.handsome;
        return ret;
    } 
    复制代码

打印ret的值

![po ret的值](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/029d7d3af51a470cb97afe1185df666a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过打印ret的值发现其值为255，也就是`1111 1111`，此时也就能解释为什么打印出来值为 -1了，首先此时通过结构体获取到的`handsome`的值为`0b1`只占一个内存空间中的1位，但是BOOL值占据一个内存空间，也就是8位。当仅有1位的值扩展成8位的话，其余空位就会根据前面一位的值全部补位成1，因此此时ret的值就被映射成了`0b 11111 1111`。

**`11111111` 在一个字节时，有符号数则为-1，无符号数则为255。因此我们在打印时候打印出的值为-1**

为了验证当1位的值扩展成8位时，会全部补位，我们将tall、rich、handsome值设置为占据两位。

    @interface Person()
    {
        struct {
            char tall : 2;
            char rich : 2;
            char handsome : 2;
        }_tallRichHandsome;
    } 
    复制代码

此时在打印就发现值可以正常打印出来。 `Runtime - union探寻[60827:4259630] tall : 1, rich : 0, handsome : 1`

**这是因为，在get方法内部获取到的`_tallRichHandsome.handsome`为两位的也就是`0b 01`，此时在赋值给8位的BOOL类型的值时，前面的空值就会自动根据前面一位补全为0，因此返回的值为`0b 0000 0001`，因此打印出的值也就为1了。**

因此上述问题同样可以使用`!!`双感叹号来解决问题。`!!`的原理上面已经讲解过，这里不再赘述了。

使用结构体位域优化之后的代码

    @interface Person()
    {
        struct {
            char tall : 1;
            char rich : 1;
            char handsome : 1;
        }_tallRichHandsome;
    }
    @end
    
    @implementation Person
    
    - (void)setTall:(BOOL)tall
    {
        _tallRichHandsome.tall = tall;
    }
    - (void)setRich:(BOOL)rich
    {
        _tallRichHandsome.rich = rich;
    }
    - (void)setHandsome:(BOOL)handsome
    {
        _tallRichHandsome.handsome = handsome;
    }
    - (BOOL)tall
    {
        return !!_tallRichHandsome.tall;
    }
    - (BOOL)rich
    {
        return !!_tallRichHandsome.rich;
    }
    - (BOOL)handsome
    {
        return !!_tallRichHandsome.handsome;
    } 
    复制代码

上述代码中使用结构体的位域则不在需要使用掩码，使代码可读性增强了很多，但是效率相比直接使用位运算的方式来说差很多，如果想要高效率的进行数据的读取与存储同时又有较强的可读性就需要使用到共用体了。

#### 7.1.4 用 共用体 和 来存储 变量的值

为了使代码存储数据高效率的同时，有较强的可读性，可以使用共用体来增强代码可读性，同时使用位运算来提高数据存取的效率。

使用共用体优化的代码

    #define TallMask (1<<2) // 0b00000100 4
    #define RichMask (1<<1) // 0b00000010 2
    #define HandsomeMask (1<<0) // 0b00000001 1
    
    @interface Person()
    {
        union {
            char bits;
           // 结构体仅仅是为了增强代码可读性，无实质用处
            struct {
                char tall : 1;
                char rich : 1;
                char handsome : 1;
            };
        }_tallRichHandsome;
    }
    @end
    
    @implementation Person
    
    - (void)setTall:(BOOL)tall
    {
        if (tall) {
            _tallRichHandsome.bits |= TallMask;
        }else{
            _tallRichHandsome.bits &= ~TallMask;
        }
    }
    - (void)setRich:(BOOL)rich
    {
        if (rich) {
            _tallRichHandsome.bits |= RichMask;
        }else{
            _tallRichHandsome.bits &= ~RichMask;
        }
    }
    - (void)setHandsome:(BOOL)handsome
    {
        if (handsome) {
            _tallRichHandsome.bits |= HandsomeMask;
        }else{
            _tallRichHandsome.bits &= ~HandsomeMask;
        }
    }
    - (BOOL)tall
    {
        return !!(_tallRichHandsome.bits & TallMask);
    }
    - (BOOL)rich
    {
        return !!(_tallRichHandsome.bits & RichMask);
    }
    - (BOOL)handsome
    {
        return !!(_tallRichHandsome.bits & HandsomeMask);
    } 
    复制代码

上述代码中使用位运算这种比较高效的方式存取值，使用union共用体来对数据进行存储。增加读取效率的同时增强代码可读性。

其中`_tallRichHandsome`共用体只占用一个字节，因为结构体中tall、rich、handsome都只占一位二进制空间，所以结构体只占一个字节，而char类型的bits也只占一个字节，他们都在共用体中，因此共用一个字节的内存即可。

并且在`get、set`方法中并没有使用到结构体，结构体仅仅为了增加代码可读性，指明共用体中存储了哪些值，以及这些值各占多少位空间。同时存值取值还使用位运算来增加效率，存储使用共用体，存放的位置依然通过与掩码进行位运算来控制。

此时代码已经算是优化完成了，高效的同时可读性高，那么此时在回头看`isa_t`共用体的源码

### 7.2 isa\_t源码

此时我们在回头查看isa\_t源码

    // 精简过的isa_t共用体
    union isa_t 
    {
        isa_t() { }
        isa_t(uintptr_t value) : bits(value) { }
    
        Class cls;
        uintptr_t bits;
    
    # if __arm64__
    #   define ISA_MASK        0x0000000ffffffff8ULL
    #   define ISA_MAGIC_MASK  0x000003f000000001ULL
    #   define ISA_MAGIC_VALUE 0x000001a000000001ULL
        struct {
            uintptr_t nonpointer        : 1;
            uintptr_t has_assoc         : 1;
            uintptr_t has_cxx_dtor      : 1;
            uintptr_t shiftcls          : 33; // MACH_VM_MAX_ADDRESS 0x1000000000
            uintptr_t magic             : 6;
            uintptr_t weakly_referenced : 1;
            uintptr_t deallocating      : 1;
            uintptr_t has_sidetable_rc  : 1;
            uintptr_t extra_rc          : 19;
    #       define RC_ONE   (1ULL<<45)
    #       define RC_HALF  (1ULL<<18)
        };
    #endif
    }; 
    复制代码

经过前面 对`位运算`、`位域`以及`共用体`的介绍，现在再来看源码已经可以很清晰的理解其中的内容:

*   源码中通过共用体的形式存储了64位的值，这些值在结构体中被展示出来，通过对`bits`进行位运算而取出相应位置的值
*   `shiftcls`
    *   `shiftcls`中存储着`Class、Meta-Class`对象的内存地址信息
    *   我们之前在OC对象的本质中提到过，对象的isa指针需要同`ISA_MASK`经过一次&（按位与）运算才能得出真正的Class对象地址

![isa指针按位与得到Class对象地址](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8dc4e46eec54d14b21e20020c0cf284~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

那么此时我们重新来看`ISA_MASK`的值`0x0000000ffffffff8ULL`，我们将其转化为二进制数

![0x0000000ffffffff8ULL二进制](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95d57113989c47348d9a7fb688d92447~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   上图中可以看出`ISA_MASK`的值转化为二进制中有33位都为1，前面提到过按位与的作用是可以取出这33位中的值
*   那么此时很明显了,同`ISA_MASK`进行按位与运算即可以取出`Class`或`Meta-Class`的值。

同时可以看出`ISA_MASK`最后三位的值为0，那么任何数同`ISA_MASK`按位与运算之后，得到的最后三位必定都为0，因此任何类对象或元类对象的内存地址最后三位必定为0，转化为十六进制末位必定为8或者0。

### 7.3 `isa`中存储的信息及作用

将结构体取出来标记一下这些信息的作用。

    struct {
        // 0代表普通的指针，存储着Class，Meta-Class对象的内存地址。
        // 1代表优化后的使用位域存储更多的信息。
        uintptr_t nonpointer        : 1; 
    
       // 是否有设置过关联对象，如果没有，释放时会更快
        uintptr_t has_assoc         : 1;
    
        // 是否有C++析构函数，如果没有，释放时会更快
        uintptr_t has_cxx_dtor      : 1;
    
        // 存储着Class、Meta-Class对象的内存地址信息
        uintptr_t shiftcls          : 33; 
    
        // 用于在调试时分辨对象是否未完成初始化
        uintptr_t magic             : 6;
    
        // 是否有被弱引用指向过，如果没有，释放时会更快
        uintptr_t weakly_referenced : 1;
    
        // 对象是否正在释放
        uintptr_t deallocating      : 1;
    
    
        // 里面存储的值是引用计数器减1
        uintptr_t extra_rc          : 19;
        
        
        // 引用计数器是否过大无法存储在isa中
        // 如果为1，那么引用计数会存储在一个叫SideTable的类的属性中
        uintptr_t has_sidetable_rc  : 1;
    }; 
    复制代码

#### 7.3.1 验证 `isa`中存储的信息是否可靠

通过下面一段代码验证上述信息存储的位置及作用

    // 以下代码需要在真机中运行，因为真机中才是__arm64__ 位架构
    - (void)viewDidLoad {
        [super viewDidLoad];
        Person *person = [[Person alloc] init];
        NSLog(@"%p",[person class]);
        NSLog(@"%@",person);
    } 
    复制代码

首先打印`person`类对象的地址，之后通过断点打印一下`person`对象的`isa指针`地址。

首先来看一下打印的内容

![打印内容](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/af82757db480414388576bfa2dcc4f2c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

将类对象地址转化为二进制

![类对象地址](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/980195a54c3b423ea6319ab4e2c87cb8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

将person的isa指针地址转化为二进制

![person对象的isa指针地址](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0acd1ec87d414a11a09a8c1566246112~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**shiftcls : `shiftcls`中存储类对象地址，通过上面两张图对比可以发现存储类对象地址的33位二进制内容完全相同。**

**extra\_rc : `extra_rc`的19位中存储着的值为引用计数减一，因为此时person的引用计数为1，因此此时`extra_rc`的19位二进制中存储的是0。**

**magic : `magic`的6位用于在调试时分辨对象是否未完成初始化，上述代码中person已经完成初始化，那么此时这6位二进制中存储的值`011010`即为共用体中定义的宏`# define ISA_MAGIC_VALUE 0x000001a000000001ULL`的值。**

**nonpointer : 这里肯定是使用的优化后的isa，因此`nonpointer`的值肯定为1**

因为此时person对象没有关联对象并且没有弱指针引用过，可以看出`has_assoc`和`weakly_referenced`值都为0，接着我们为person对象添加弱引用和关联对象，来观察一下`has_assoc`和`weakly_referenced`的变化。

    - (void)viewDidLoad {
        [super viewDidLoad];
        Person *person = [[Person alloc] init];
        NSLog(@"%p",[person class]);
        // 为person添加弱引用
        __weak Person *weakPerson = person;
        // 为person添加关联对象
        objc_setAssociatedObject(person, @"name", @"xx_cc", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        NSLog(@"%@",person);
    } 
    复制代码

重新打印person的isa指针地址将其转化为二进制可以看到`has_assoc`和`weakly_referenced`的值都变成了1

![has_assoc和weakly_referenced的变化](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7180d01473c6475eb2de2dbc0d1ff0fd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**注意：只要设置过关联对象或者弱引用引用过对象`has_assoc`和`weakly_referenced`的值就会变成1，不论之后是否将关联对象置为nil或断开弱引用。**

如果没有设置过关联对象，对象释放时会更快，这是因为对象在销毁时会判断是否有关联对象进而对关联对象释放。来看一下对象销毁的源码

    void *objc_destructInstance(id obj) 
    {
        if (obj) {
            Class isa = obj->getIsa();
            // 是否有c++析构函数
            if (isa->hasCxxDtor()) {
                object_cxxDestruct(obj);
            }
            // 是否有关联对象，如果有则移除
            if (isa->instancesHaveAssociatedObjects()) {
                _object_remove_assocations(obj);
            }
            objc_clear_deallocating(obj);
        }
        return obj;
    } 
    复制代码

相信至此我们已经对`isa指针`有了新的认识:

*   `arm64`架构之后，`isa指针`不单单只存储了`Class`或`Meta-Class`的地址，而是使用共用体的方式存储了更多信息
*   其中`shiftcls`存储了`Class`或`Meta-Class`的地址，需要同`ISA_MASK`进行按位&运算才可以取出其内存地址值。

三、class的结构
==========

1\. 回顾一下Class的内部结构
------------------

我们在之前在探索OC的三类对象的时候,从简单探索过[Class的内部结构](https://juejin.cn/post/7096087582370431012#heading-16 "https://juejin.cn/post/7096087582370431012#heading-16"),且对Class结构的认识最后以一张图作总结: ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/787bc924ee1148d2bb330eff705a87d3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

我们在前面的篇幅中对`isa指针`有了新的认识之后,也需要基于此 对Class有 进一步的探索，重新认识Class内部结构:

首先回顾一下Class的内部结构相关的源码:

    struct objc_class : objc_object {
        // Class ISA;
        Class superclass;
        cache_t cache;             // formerly cache pointer and vtable
        class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
    
        class_rw_t *data() { 
            return bits.data();
        }
        void setData(class_rw_t *newData) {
            bits.setData(newData);
        }
    } 
    复制代码

    class_rw_t* data() {
        return (class_rw_t *)(bits & FAST_DATA_MASK);
    }  
    复制代码

### 1.1 class\_rw\_t

从源码中我们不难得知：

*   `bits & FAST_DATA_MASK`位运算之后，可以得到`class_rw_t`
*   而`class_rw_t`中存储着`方法`列表、`属性`列表以及`协议`列表等
*   来看一下`class_rw_t`部分代码:
    
        struct class_rw_t {
            // Be warned that Symbolication knows the layout of this structure.
            uint32_t flags;
            uint32_t version;
        
            const class_ro_t *ro;
        
            method_array_t methods; // 方法列表
            property_array_t properties; // 属性列表
            protocol_array_t protocols; // 协议列表
        
            Class firstSubclass;
            Class nextSiblingClass;
        
            char *demangledName;
        }; 
        复制代码
    
    *   从`class_rw_t`结构体内部的成员:`method_array_t`、`property_array_t`、`protocol_array_t`其实都是**二维数组**
    *   我们可以去看下`method_array_t`、`property_array_t`、`protocol_array_t`的内部结构:
        
            class method_array_t : 
                public list_array_tt<method_t, method_list_t> 
            {
                typedef list_array_tt<method_t, method_list_t> Super;
            
             public:
                method_list_t **beginCategoryMethodLists() {
                    return beginLists();
                }
            
                method_list_t **endCategoryMethodLists(Class cls);
            
                method_array_t duplicate() {
                    return Super::duplicate<method_array_t>();
                }
            };
            
            
            class property_array_t : 
                public list_array_tt<property_t, property_list_t> 
            {
                typedef list_array_tt<property_t, property_list_t> Super;
            
             public:
                property_array_t duplicate() {
                    return Super::duplicate<property_array_t>();
                }
            };
            
            
            class protocol_array_t : 
                public list_array_tt<protocol_ref_t, protocol_list_t> 
            {
                typedef list_array_tt<protocol_ref_t, protocol_list_t> Super;
            
             public:
                protocol_array_t duplicate() {
                    return Super::duplicate<protocol_array_t>();
                }
            };
            复制代码
        
    *   我们这里以`method_array_t`为例,分析一下其二维数组的构成:
        *   `method_array_t`本身就是一个数组，数组里面存放的是数组`method_list_t`
        *   `method_list_t`里面最终存放的是`method_t`
        *   `method_t`是一个方法对象

`class_rw_t`里面的`methods、properties、protocols`是二维数组，是可读可写的，其中包含了`类的初始内容`以及`分类的内容`。 (这里以methods为例,实际上`properties`和`protocols`都是类似的构成) ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0c484f0c4fc241e09a4f1d1e54103b0b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

### 1.2 class\_ro\_t

我们之前提到过`class_ro_t`中也有存储`方法`、`属性`、`协议`列表，另外还有`成员变量`列表。

接着来看一下`class_ro_t`部分代码

    struct class_ro_t {
        uint32_t flags;
        uint32_t instanceStart;
        uint32_t instanceSize;
    #ifdef __LP64__
        uint32_t reserved;
    #endif
    
        const uint8_t * ivarLayout;
        
        const char * name;//类名
        method_list_t * baseMethodList;//方法列表
        protocol_list_t * baseProtocols;//协议列表
        const ivar_list_t * ivars;//成员变量列表，是只读的
    
        const uint8_t * weakIvarLayout;
        property_list_t *baseProperties;//属性列表
    
        method_list_t *baseMethods() const {
            return baseMethodList;
        }
    }; 
    复制代码

从`class_rw_t`的源码中我们可以看到`class_ro_t *ro`成员,但是其是被const修饰的,也就是是只读,不可修改的。我们进一步去看一下`class_ro_t`的内部结构我们可以得知:

*   内部直接存储的直接就是`method_list_t、protocol_list_t 、property_list_t`类型的`一维数组`
*   数组里面分别存放的是`类的初始信息`
*   以`method_list_t`为例，`method_list_t`中直接存放的就是`method_t`，但是是只读的，不允许增删改查。

### 1.3 总结

以方法列表为例，`class_rw_t`中的`methods`是二维数组的结构，并且`可读可写`

*   因此可以`动态的添加方法`，并且更加便于分类方法的添加
*   因为我们在[Category的本质](https://juejin.cn/post/7096480684847415303#heading-2 "https://juejin.cn/post/7096480684847415303#heading-2")里面提到过，`attachList`函数内通过`memmove 和 memcpy`两个操作将`分类的方法列表`合并在`本类的方法列表中`(也即是`class_rw_t`的`methods`中)
*   那么此时就将分类的方法和本类的方法统一整合到一起了

其实一开始类的方法，属性，成员变量属性协议等等都是存放在`class_ro_t`中的

*   当程序运行的时候，需要将分类中的列表跟类初始的列表合并在一起的时，就会将`class_ro_t`中的列表和分类中的列表合并起来存放在`class_rw_t`中
*   也就是说`class_rw_t`中有部分列表是从`class_ro_t`里面拿出来的。并且最终和分类的方法合并
*   可以通过源码看到这一部分的实现:
    
        static Class realizeClass(Class cls)
        {
            runtimeLock.assertWriting();
        
            const class_ro_t *ro;
            class_rw_t *rw;
            Class supercls;
            Class metacls;
            bool isMeta;
        
            if (!cls) return nil;
            if (cls->isRealized()) return cls;
            assert(cls == remapClass(cls));
        
            // 最开始cls->data是指向ro的
            ro = (const class_ro_t *)cls->data();
        
            if (ro->flags & RO_FUTURE) { 
                // rw已经初始化并且分配内存空间
                rw = cls->data();  // cls->data指向rw
                ro = cls->data()->ro;  // cls->data()->ro指向ro
                cls->changeInfo(RW_REALIZED|RW_REALIZING, RW_FUTURE);
            } else { 
                // 如果rw并不存在，则为rw分配空间
                rw = (class_rw_t *)calloc(sizeof(class_rw_t), 1); // 分配空间
                rw->ro = ro;  // rw->ro重新指向ro
                rw->flags = RW_REALIZED|RW_REALIZING;
                // 将rw传入setData函数，等于cls->data()重新指向rw
                cls->setData(rw); 
            }
        } 
        复制代码
    

> **源码解读:** 那么从上述源码中可以发现:

*   类的初始信息本来其实是存储在`class_ro_t`中的
    *   并且`ro`本来是指向`cls->data()`的
    *   也就是说`bits.data()`得到的是`ro`
*   但是在运行过程中创建了`class_rw_t`，并将`cls->data`指向`rw`
    *   同时将初始信息`ro`赋值给`rw`中的`ro`
    *   最后在通过setData(rw)设置data
*   那么此时`bits.data()`得到的就是`rw`
*   之后再去检查是否有`分类`，同时将分类的`方法`、`属性`、`协议`列表整合存储在`class_rw_t`的`方法`，`属性`及`协议`列表中

通过上述对源码的分析，我们对`class_rw_t`内存储`方法`、`属性`、`协议`列表的过程有了更清晰的认识，那么接下来探寻`class_rw_t`中是如何存储方法的。

2\. class\_rw\_t中是如何存储方法的?
--------------------------

### 2.1 method\_t

我们知道 `method_array_t`中最终存储的是`method_t`

*   `method_t`是对方法、函数的封装，每一个方法对象就是一个`method_t`
*   通过源码看一下`method_t`的结构体:

    struct method_t {
        SEL name;  // 函数名
        const char *types;  // 编码（返回值类型，参数类型）
        IMP imp; // 指向函数的指针（函数地址）
    }; 
    复制代码

`method_t`结构体中可以看到三个成员，我们依次来看看这三个成员变量分别代表什么:

#### 2.1.1 SEL

`SEL`代表方法\\函数名，一般叫做选择器，底层结构跟`char *`类似

*   `SEL`可以通过`@selector()`和`sel_registerName()`获得
    
        SEL sel1 = @selector(test);
        SEL sel2 = sel_registerName("test");
        复制代码
    
*   也可以通过`sel_getName()`和`NSStringFromSelector()`将`SEL`转成字符串
    
        char *string = sel_getName(sel1);
        NSString *string2 = NSStringFromSelector(sel2);
        复制代码
    
*   不同类中相同名字的方法，所对应的方法选择器是相同的
    
    *   `SEL`仅仅代表方法的名字，并且不同类中相同的方法名的`SEL`是全局唯一的。
    
        NSLog(@"%p,%p", sel1,sel2);
        Runtime-test[23738:8888825] 0x1017718a3,0x1017718a3
        复制代码
    

`typedef struct objc_selector *SEL;`，可以把`SEL`看做是方法名字符串。

#### 2.1.2 types

`types`包含了函数返回值，参数编码的字符串

*   通过字符串拼接的方式将返回值和参数拼接成一个字符串
*   这个字符串可以用于 代表函数`返回值`及`参数`

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0b382be3d67f424cb1df07deb6e79eab~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

我们通过代码查看一下`types`是如何代表函数返回值及参数的:

*   首先通过在本地写几个与runtime底层实现class一样的结构体,用于模拟Class的内部实现
*   我们曾在[探寻Class的本质](https://juejin.cn/post/7096087582370431012#heading-18 "https://juejin.cn/post/7096087582370431012#heading-18")时,做过该操作：通过类型强制转化来探寻内部数据

    Person *person = [[Person alloc] init];
    xx_objc_class *cls = (__bridge xx_objc_class *)[Person class];
    class_rw_t *data = cls->data();
    复制代码

通过断点可以在data中找到types的值

![data中types的值](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f33186f19f05443bb9efd3c292d8e243~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   上图中可以看出`types`的值为`v16@0:8`
*   那么这个值代表什么呢？
*   apple为了能够清晰的使用字符串表示方法及其返回值，制定了一系列对应规则，通过下表可以看到一一对应关系 ![Objective-C type encodings](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/41320d7fb32b4942890c8151dfbe8a95~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

将types的值同表中的一一对照查看`types`的值`v16@0:8` 代表什么

    - (void) test;
    
     v    16      @     0     :     8
    void         id          SEL
    // 16表示参数的占用空间大小，id后面跟的0表示从0位开始存储，id占8位空间。
    // SEL后面的8表示从第8位开始存储，SEL同样占8位空间
    复制代码

我们知道任何方法都默认有两个参数的，`id`类型的`self`，和`SEL`类型的`_cmd`，而上述通过对`types`的分析同时也验证了这个说法。

为了能够看的更加清晰，我们为test添加返回值及参数之后重新查看types的值。

![types的值](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4d706c1e75784e2b86b156625b69ad62~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

同样通过上表找出一一对应的值，查看types的值代表的方法

    - (int)testWithAge:(int)age Height:(float)height
    {
        return 0;
    }
      i    24    @    0    :    8    i    16    f    20
    int         id        SEL       int        float
    // 参数的总占用空间为 8 + 8 + 4 + 4 = 24
    // id 从第0位开始占据8位空间
    // SEL 从第8位开始占据8位空间
    // int 从第16位开始占据4位空间
    // float 从第20位开始占据4位空间
    复制代码

iOS提供了`@encode`的指令，可以将具体的类型转化成字符串编码。

    NSLog(@"%s",@encode(int));
    NSLog(@"%s",@encode(float));
    NSLog(@"%s",@encode(id));
    NSLog(@"%s",@encode(SEL));
    
    // 打印内容
    Runtime-test[25275:9144176] i
    Runtime-test[25275:9144176] f
    Runtime-test[25275:9144176] @
    Runtime-test[25275:9144176] :
    复制代码

上述代码中可以看到，对应关系确实如上表所示。

#### 2.1.3 IMP

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4f7c807ac946452ca99602219cbc386b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) `IMP`代表函数的具体实现

*   存储的内容是函数地址
*   也就是说当找到`IMP`的时候就可以找到函数实现，进而对函数进行调用

在上述代码中打印`IMP`的值

    Printing description of data->methods->first.imp:
    (IMP) imp = 0x000000010c66a4a0 (Runtime-test`-[Person testWithAge:Height:] at Person.m:13)
    复制代码

之后在`test`方法内部打印断点，并来到其方法内部可以看出`IMP`中的存储的地址也就是方法实现的地址。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2df23d0ed51445e0b256c2591a6f92e5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

四、cache\_t方法缓存
==============

通过前面的探索我们知道了方法列表是如何存储在`Class类对象`中的

*   但是当多次继承的子类想要调用基类方法时，就需要通过`superclass`指针一层一层找到基类，在从基类方法列表中找到对应的方法进行调用
*   如果`多次调用`基类方法，那么`就需要多次遍历`每一层父类的方法列表，这对性能来说无疑是伤害巨大的

Apple通过`方法缓存技术`的形式解决了这一问题，接下来我们来探寻`Class类对象`是如何进行方法缓存的

回到类对象结构体`objc_class`。里面有一个成员变量`cache`

*   这个`cache`成员变量就是用于实现 `方法缓存技术` 的支撑
    
        struct objc_class : objc_object {
            // Class ISA;
            Class superclass;
            cache_t cache; // 方法缓存            // formerly cache pointer and vtable
            class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags
        
            class_rw_t *data() { 
                return bits.data();
            }
            void setData(class_rw_t *newData) {
                bits.setData(newData);
            }
        } 
        复制代码
    
*   **`Class`内部结构中有个方法缓存（`cache_t`），用`散列表`（`哈希表`）来缓存曾经调用过的方法，可以提高方法的查找速度**

回顾方法调用过程：

*   调用方法的时候，需要去方法列表里面进行遍历查找
    *   如果方法不在列表里面，就会通过`superclass`找到父类的类对象，在去父类类对象方法列表里面遍历查找。
*   如果方法需要调用很多次的话，那就相当于`每次调用都需要去遍历`多次方法列表

> `cache_t`技术

*   为了能够快速查找方法，`apple`设计了`cache_t`来进行方法缓存:
*   每当调用方法的时候，会先去`cache`中查找是否有缓存的方法:
    *   如果没有缓存，在去类对象方法列表中查找，以此类推直到找到方法之后，就会将方法直接存储在`cache`中
    *   下一次在调用这个方法的时候，就会在类对象的`cache`里面找到这个方法，直接调用了

1\. cache\_t 如何进行缓存
-------------------

那么`cache_t`是如何对方法进行缓存的呢？首先来看一下`cache_t`的内部结构。

    struct cache_t {
        struct bucket_t *_buckets; // 散列表 数组
        mask_t _mask; // 散列表的长度 -1
        mask_t _occupied; // 已经缓存的方法数量
    }; 
    复制代码

`bucket_t`是以数组的方式存储方法列表的，看一下`bucket_t`内部结构

    struct bucket_t {
    private:
        cache_key_t _key; // SEL作为Key
        IMP _imp; // 函数的内存地址
    }; 
    复制代码

从源码中可以看出:

*   `bucket_t`中存储着`SEL`和`_imp`
*   通过`key->value`的形式:
    *   以`SEL`为`key`
    *   `函数实现的内存地址 _imp`为`value`来存储方法

通过一张图来展示一下`cache_t`的结构

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e3c30ca46e44b968a42fb9dcb53973e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

> **方法散列表`bucket_t`**

*   上述`bucket_t`列表我们称之为散列表（哈希表）
*   **散列表（Hash table，也叫哈希表），是根据关键码值(Key value)而直接进行访问的数据结构**
*   也就是说，它通过把关键码值映射到表中一个位置来访问记录，以加快查找的速度。
*   这个映射函数叫做`散列函数`，存放记录的数组叫做`散列表`

那么apple如何在散列表中快速并且准确的找到对应的key以及函数实现呢？  
这就需要我们通过源码来看一下apple的散列函数是如何设计的:

2.散列函数及散列表原理
------------

首先来看一下方法缓存的源码（主要查看几个函数，关键代码都有注释,便不再展开介绍）

### 2.1 cache\_fill 及 cache\_fill\_nolock 函数

    void cache_fill(Class cls, SEL sel, IMP imp, id receiver)
    {
    #if !DEBUG_TASK_THREADS
        mutex_locker_t lock(cacheUpdateLock);
        cache_fill_nolock(cls, sel, imp, receiver);
    #else
        _collecting_in_critical();
        return;
    #endif
    }
    
    static void cache_fill_nolock(Class cls, SEL sel, IMP imp, id receiver)
    {
        cacheUpdateLock.assertLocked();
        // 如果没有initialize直接return
        if (!cls->isInitialized()) return;
        // 确保线程安全，没有其他线程添加缓存
        if (cache_getImp(cls, sel)) return;
        // 通过类对象获取到cache 
        cache_t *cache = getCache(cls);
        // 将SEL包装成Key
        cache_key_t key = getKey(sel);
       // 占用空间+1
        mask_t newOccupied = cache->occupied() + 1;
       // 获取缓存列表的缓存能力，能存储多少个键值对
        mask_t capacity = cache->capacity();
        if (cache->isConstantEmptyCache()) {
            // 如果为空的，则创建空间，这里创建的空间为4个。
            cache->reallocate(capacity, capacity ?: INIT_CACHE_SIZE);
        }
        else if (newOccupied <= capacity / 4 * 3) {
            // 如果所占用的空间占总数的3/4一下，则继续使用现在的空间
        }
        else {
           // 如果占用空间超过3/4则扩展空间
            cache->expand();
        }
        // 通过key查找合适的存储空间。
        bucket_t *bucket = cache->find(key, receiver);
        // 如果key==0则说明之前未存储过这个key，占用空间+1
        if (bucket->key() == 0) cache->incrementOccupied();
        // 存储key，imp 
        bucket->set(key, imp);
    } 
    复制代码

### 2.2 expand ()函数

当散列表的空间被占用超过3/4的时候，散列表会调用`expand ()`函数进行扩展，我们来看一下`expand ()`函数内散列表如何进行扩展的。

    void cache_t::expand()
    {
        cacheUpdateLock.assertLocked();
        // 获取旧的散列表的存储空间
        uint32_t oldCapacity = capacity();
        // 将旧的散列表存储空间扩容至两倍
        uint32_t newCapacity = oldCapacity ? oldCapacity*2 : INIT_CACHE_SIZE;
        // 为新的存储空间赋值
        if ((uint32_t)(mask_t)newCapacity != newCapacity) {
            newCapacity = oldCapacity;
        }
        // 调用reallocate函数，重新创建存储空间
        reallocate(oldCapacity, newCapacity);
    } 
    复制代码

### 2.3 reallocate 函数

通过上述源码看到`reallocate`函数负责分配散列表空间，来到`reallocate`函数内部。

    void cache_t::reallocate(mask_t oldCapacity, mask_t newCapacity)
    {
        // 旧的散列表能否被释放
        bool freeOld = canBeFreed();
        // 获取旧的散列表
        bucket_t *oldBuckets = buckets();
        // 通过新的空间需求量创建新的散列表
        bucket_t *newBuckets = allocateBuckets(newCapacity);
    
        assert(newCapacity > 0);
        assert((uintptr_t)(mask_t)(newCapacity-1) == newCapacity-1);
        // 设置Buckets和Mash，Mask的值为散列表长度-1
        setBucketsAndMask(newBuckets, newCapacity - 1);
        // 释放旧的散列表
        if (freeOld) {
            cache_collect_free(oldBuckets, oldCapacity);
            cache_collect(false);
        }
    } 
    复制代码

上述源码中首次传入`reallocate`函数的`newCapacity`为`INIT_CACHE_SIZE`，`INIT_CACHE_SIZE`是个枚举值，也就是4。因此散列表最初创建的空间就是4个。

    enum {
        INIT_CACHE_SIZE_LOG2 = 2,
        INIT_CACHE_SIZE      = (1 << INIT_CACHE_SIZE_LOG2)
    }; 
    复制代码

上述源码中可以发现散列表进行扩容时会将容量增至之前的2倍。

### 2.4 find 函数

最后来看一下散列表中如何快速的通过`key`找到相应的`bucket`呢？我们来到`find`函数内部

    bucket_t * cache_t::find(cache_key_t k, id receiver)
    {
        assert(k != 0);
        // 获取散列表
        bucket_t *b = buckets();
        // 获取mask
        mask_t m = mask();
        // 通过key找到key在散列表中存储的下标
        mask_t begin = cache_hash(k, m);
        // 将下标赋值给i
        mask_t i = begin;
        // 如果下标i中存储的bucket的key==0说明当前没有存储相应的key，将b[i]返回出去进行存储
        // 如果下标i中存储的bucket的key==k，说明当前空间内已经存储了相应key，将b[i]返回出去进行存储
        do {
            if (b[i].key() == 0  ||  b[i].key() == k) {
                // 如果满足条件则直接reutrn出去
                return &b[i];
            }
        // 如果走到这里说明上面不满足，那么会往前移动一个空间重新进行判定，知道可以成功return为止
        } while ((i = cache_next(i, m)) != begin);
    
        // hack
        Class cls = (Class)((uintptr_t)this - offsetof(objc_class, cache));
        cache_t::bad_cache(receiver, (SEL)k, cls);
    } 
    复制代码

函数`cache_hash (k, m)`用来通过`key`找到方法在散列表中存储的下标，来到`cache_hash (k, m)`函数内部

    static inline mask_t cache_hash(cache_key_t key, mask_t mask) 
    {
        return (mask_t)(key & mask);
    } 
    复制代码

可以发现`cache_hash (k, m)`函数内部仅仅是进行了`key & mask`的按位与运算，得到下标即存储在相应的位置上。按位与运算在上文中已详细讲解过，这里不在赘述。

### 2.5 \_mask

通过上面的分析我们知道`_mask`的值是散列表的长度减一，那么任何数通过与`_mask`进行按位与运算之后获得的值都会小于等于`_mask`，因此不会出现数组溢出的情况。

举个例子，假设散列表的长度为8，那么mask的值为7

      0101 1011  // 任意值
    & 0000 0111  // mask = 7
    ------------
      0000 0011 //获取的值始终等于或小于mask的值 
    复制代码

3.方法调用总结
--------

*   **首次方法查找与缓存:**
    *   **首次方法查找:** 当第一次使用方法时，`消息机制`通过`isa指针`找到`class/meta-class`
    *   **方法缓存:** 遍历方法列表找到方法之后(如果找不到就调用superclass去父类中找)，会对方法以`SEL为keyIMP为value`的方式缓存在`cache`的`_buckets`中
    *   **散列表下标:** 当第一次存储的时候，会创建具有4个空间的散列表，并将`_mask`的值置为散列表的长度减一，之后通过`SEL & mask`计算出方法存储的下标值，并将方法存储在散列表中
        *   举个例子，如果计算出下标值为3，那么就将方法直接存储在下标为3的空间中，前面的空间会留空
*   **散列表扩容:**
    *   当散列表中存储的方法占据散列表长度超过3/4的时候，散列表会进行扩容操作:
        *   将创建一个新的散列表并且空间扩容至原来空间的两倍
        *   并重置`_mask`的值
        *   最后释放旧的散列表
    *   此时再有方法要进行缓存的话，就需要重新通过`SEL & mask`计算出下标值之后在按照下标进行存储了
*   **散列表下标计算:**
    *   如果一个类中方法很多，其中很可能会出现多个方法的`SEL & mask`得到的值为同一个下标值
    *   如果计算出来的下标有值,那么会调用`cache_next`函数往下标值-1位去进行存储
    *   如果下标值-1位空间中有存储方法，并且key不与要存储的key相同，那么再到前面一位进行比较，直到找到一位空间没有存储方法或者`key`与要存储的`key`相同为止
    *   如果到下标0的话就会到下标为`_mask`的空间也就是最大空间处进行比较。
*   **非首次方法查找:**
    *   当要查找方法时，并不需要遍历散列表，同样通过`SEL & mask`计算出下标值，直接去下标值的空间取值即可
    *   同上，如果下标值中存储的key与要查找的key不相同，就去前面一位查找。
    *   这样虽然占用了少量空间，但是大大节省了时间，也就是说其实apple是使用空间换取时间的一种方法查找算法优化测策略。

通过一张图更清晰的看一下其中的流程:

![散列表内部存取逻辑](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/46ed531c86134115a6757c9ae873fe34~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4\. 验证上述流程
----------

通过一段代码演示一下 。同样使用仿照`objc_class结构体`自定义一个结构体，并进行强制转化来查看其内部数据，自定义结构体在之前的文章中使用过多次这里不在赘述。

我们创建`Person`类继承`NSObject`，`Student`类继承`Person`，`CollegeStudent`继承`Student`。三个类分别有`personTest，studentTest，colleaeStudentTest`方法

通过打印断点来看一下方法缓存的过程

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            
            CollegeStudent *collegeStudent = [[CollegeStudent alloc] init];
            xx_objc_class *collegeStudentClass = (__bridge xx_objc_class *)[CollegeStudent class];
            
            cache_t cache = collegeStudentClass->cache;
            bucket_t *buckets = cache._buckets;
            
            [collegeStudent personTest];
            [collegeStudent studentTest];
            
            NSLog(@"----------------------------");
            for (int i = 0; i <= cache._mask; i++) {
                bucket_t bucket = buckets[i];
                NSLog(@"%s %p", bucket._key, bucket._imp);
            }
            NSLog(@"----------------------------");
            
            [collegeStudent colleaeStudentTest];
    
            cache = collegeStudentClass->cache;
            buckets = cache._buckets;
            NSLog(@"----------------------------");
            for (int i = 0; i <= cache._mask; i++) {
                bucket_t bucket = buckets[i];
                NSLog(@"%s %p", bucket._key, bucket._imp);
            }
            NSLog(@"----------------------------");
            
            NSLog(@"%p",@selector(colleaeStudentTest));
            NSLog(@"----------------------------");
        }
        return 0;
    } 
    复制代码

我们分别在`collegeStudent`实例对象调用`personTest，studentTest，colleaeStudentTest`方法处打断点查看`cache`的变化。

**`personTest`方法调用之前:**

![personTest方法调用之前](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9cc78362f2234139b9470ef6cde934cc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从上图中可以发现:

*   `personTest`方法调用之前，`cache`中仅仅存储了`init方法`
*   上图中可以看出`init方法`恰好存储在下标为0的位置因此我们可以看到
*   `_mask`的值为`3`验证我们上述源码中提到的散列表第一次存储时会分配4个内存空间
*   `_occupied`的值为1证明此时`_buckets`中仅仅存储了一个方法。

当`collegeStudent`在调用`personTest`的时候:

*   首先发现`collegeStudent类对象`的`cache`中没有`personTest方法`，就会去`collegeStudent类对象`的方法列表中查找
*   方法列表中也没有，那么就通过`superclass指针`找到`Student类对象`
*   `Studeng类对象`中`cache`和方法列表同样没有，再通过`superclass指针`找到`Person类对象`
*   最终在`Person类对象`方法列表中找到之后进行调用，并缓存在`collegeStudent类对象`的`cache`中。

**执行`personTest`方法之后查看`cache`方法的变化:**

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9e6f33e109e843e58cbfae40788c87e3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中可以发现:

*   `_occupied`值为2，说明此时`personTest`方法已经被缓存在`collegeStudent类对象`的`cache`中

同理执行过`studentTest`方法之后，我们通过打印查看一下此时`cache`内存储的信息

![cache内存储的信息](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6720212d40154cb8bef8f0ca2a7348e2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中可以看到`cache`中确实存储了 `init 、personTest 、studentTest`三个方法。

那么执行过`colleaeStudentTest方法`之后此时`cache`中应该对`colleaeStudentTest方法`进行缓存。

前面源码提到过，当存储的方法数超过散列表长度的3/4时，系统会重新创建一个容量为原来两倍的新的散列表替代原来的散列表。  
过掉`colleaeStudentTest方法`，重新打印`cache`内存储的方法查看:

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3603950d95ee4b92bd66dc98ce2d576c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从图中可看出:

*   `_bucket`散列表扩容之后仅仅存储了`colleaeStudentTest方法`
*   并且上图中打印`SEL & _mask` 位运算得出下标的值确实是`_bucket`列表中`colleaeStudentTest方法`存储的位置

至此已经对Class的结构及方法缓存的过程有了新的认知:

*   **apple通过散列表的形式对方法进行缓存，以少量的空间节省了大量查找方法的时间**
    