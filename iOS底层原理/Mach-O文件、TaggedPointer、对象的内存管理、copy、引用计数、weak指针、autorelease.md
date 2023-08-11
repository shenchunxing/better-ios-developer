
一、Mach-O文件
==========

1\. 了解Mach-O文件
--------------

`Mach-O` 其实是 `Mach Object` 文件格式的缩写，是 `mac` 以及 `iOS` 上可执行文件的格式， 类似于 `windows` 上的 `PE` 格式 ( Portable Executable ) , `linux` 上的 `elf` 格式 ( Executable and Linking Format ) .

它是一种用于`可执行文件`、`目标代码`、`动态库`的文件格式。作为 `a.out` 格式的替代，`Mach-O` 提供了更强的扩展性。

但是除了可执行文件外 , 其实还有一些文件也是使用的 `Mach-O` 的文件格式 .

> **属于 `Mach-O` 格式的常见文件**
> 
> *   `MH_OBJECT`
>     *   目标文件 .o
>     *   库文件
>         *   .a(静态库其实就是N个.o文件合在一起)
>         *   .dylib
>         *   .framework
> *   `MH_EXCUTE:`可执行文件
>     *   .app/xx
> *   `MH_DYLINKER:` 动态链接编辑器
>     *   /usr/lib/dyld( 动态链接器 )
> *   `MH_DYSM:` 存储着二进制文件符号信息的文件
> *   .dsym ( 符号表 )

Tips : 使用 `file` 命令可以查看文件类型

2\. iOS程序的文件格式
--------------

iOS程序的可执行文件,本质上就是`Mach-O文件`

3\. 了解`Mach-O文件`的文件结构
---------------------

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/14e5d711e45e444b90651bb450e70708~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

`Mach-O` 的组成结构如图所示包括了

*   `Header` 包含该二进制文件的一般信息
*   字节顺序、架构类型、加载指令的数量等。
*   使得可以快速确认一些信息，比如当前文件用于 `32` 位还是 `64` 位，对应的处理器是什么、文件类型是什么
*   `Load commands` 一张包含很多内容的表
*   内容包括区域的位置、符号表、动态符号表等。
*   `Data` 通常是对象文件中最大的部分
*   包含 `Segement` 的具体数据

我们来找一个 Mach-O 文件 使用 MachOView 或者 otool 命令去查看一下文件结构 .

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bce5321829a1460c8f3c323bd9a2efde~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d698b9519b074807b3c3889b4732ae65~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

那么这个 `Mach-O` 到底这些部分存放的是什么内容 , 加下来我们就来一一探索一下 .

### 3.1 Mach Header

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b776f3d6f0c4832aa42cd6e23132f64~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

`Header` 中存储的内容大致如上图所示 , 那么每一条到底对应着什么呢 ? , 我们打开源码看一下, `cmd + shift + o` , 搜索 `load.h` , 找 `mach_header_64` 结构体.

    struct mach_header_64 {
    uint32_t	magic;		/* 魔数,快速定位64位/32位 */
    cpu_type_t	cputype;	/* cpu 类型 比如 ARM */
    cpu_subtype_t	cpusubtype;	/* cpu 具体类型 比如arm64 , armv7 */
    uint32_t	filetype;	/* 文件类型 例如可执行文件 .. */
    uint32_t	ncmds;		/* load commands 加载命令条数 */
    uint32_t	sizeofcmds;	/* load commands 加载命令大小*/
    uint32_t	flags;		/* 标志位标识二进制文件支持的功能 , 主要是和系统加载、链接有关*/
    uint32_t	reserved;	/* reserved , 保留字段 */
    };
    复制代码

`mach_header_64` 相较于 `mach_header` , 也就是 `32` 位头文件 , 只是多了一个保留字段 . `mach_header` 是链接器加载时最先读取的内容 , 它决定了一些基础架构 , 系统类型 , 指令条数等信息.

### 3.2 Load Commands

`Load Commands` 详细保存着加载指令的内容 , 告诉链接器如何去加载这个 `Mach-O` 文件.

通过查看内存地址我们发现 , 在内存中 , `Load Commands` 是紧跟在 `Mach_header` 之后的 .

那么这些 `Load Commands` 对应了什么呢 ? 我们以 arm64 为例.

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e27522f335d847b2a7f8e5f72c70d356~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

其中 **\_TEXT** 段和 **\_DATA** 段 , 是我们经常需要研究的 , `MachOView` 下面也有详细列出.

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6604bff0b76448cbaffd275e87943c65~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 3.3 \_TEXT 段

我们来看看 `_TEXT` 段里都存放了什么 , 其实真正开始读取就是从 `_TEXT` 段开始读取的 .

名称

内容

`_text`

主程序代码

`_stubs` , `_stub_helper`

动态链接

`_objc_methodname`

方法名称

`_objc_classname`

类名称

`_objc_methtype`

方法类型 ( v@: )

`_cstring`

静态字符串常量

### 3.4 \_DATA 段

`_DATA` 在内存中是紧跟在 `_TEXT` 段之后的.

名称

内容

`_got` : Non-Lazy Symbol Pointers

非懒加载符号表

`_la_symbol_ptr` : Lazy Symbol Pointers

懒加载符号表

`_objc_classlist`

类列表

...

二、iOS程序的内存布局
============

1\. 一个运行中的iOS程序的内存
------------------

从前面的介绍,我们得知iOS程序本质上是一个可执行的`Mach-O`文件,`Mach-O`文件的内存布局,自上而下是:

*   `Mach Header`
*   `Load Commands`
*   `__TEXT段`
*   `__DATA段`

其实,前面介绍到的`Mach-O`文件布局,远不止此,因为 程序在 运行过程中 还会产生 `堆`、`栈`内存,所以应该是:

*   `Mach Header`
*   `Load Commands`
*   `__TEXT段`
*   `__DATA段`
*   `堆内存(heap区)`
*   `栈内存(stack区)`

> **多线程执行:** 我们前面 几篇文章 在 探索 多线程原理的时候,我们得知:

*   一个进程(一个iOS程序) 在运行过程中,至少会有一条主线程和管理线程工作的RunLoop
*   且,我们平时开发过程中常常用到多线程技术
*   也就是说,**程序在运行过程中常常是有 多条线程并行执行任务的情况**
*   线程管理工作常常涉及与系统内核的一些函数和对象
*   01- 开辟一条线程工作,就要抢占 CPU 资源（CPU的时间片技术）
*   02- RunLoop管理线程,保持线程常驻(主线程)、线程可能进入休眠状态,且也有被唤醒的时候
*   ...
*   各种线程工作都涉及系统内核
*   总之,一个运行的iOS程序它的内存还牵扯到 内核区的内存 占用(即使不讨论线程的问题、App启动的时候动态库加载过程中,会有创建动态库缓存,也是由系统内核来分配内存的) 那么,一个运行中的iOS程序(`Mach-O`可执行文件)的内存应该包含:
*   `Mach Header`
*   `Load Commands`
*   `__TEXT段`
*   `__DATA段`
*   `堆内存(heap区)`
*   `栈内存(stack区)`
*   `内核区` 我们可以用一张图来表示iOS程序的内存布局顺序: ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7c22061d2fd547ca875806fb33265c3d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2\. 验证不同类型对象内存布局的顺序
-------------------

**我们通过在语法层上创建不同的对象,进行打印内存地址来验证:**

    int a = 10;
    int b;
    
    int main(int argc, char * argv[]) {
    @autoreleasepool {
        static int c = 20;
    
        static int d;
    
        int e;
        int f = 20;
    
        NSString *str = @"123";
    
        NSObject *obj = [[NSObject alloc] init];
    
        NSLog(@"\n&a=%p\n&b=%p\n&c=%p\n&d=%p\n&e=%p\n&f=%p\nstr=%p\nobj=%p\n",
              &a, &b, &c, &d, &e, &f, str, obj);
    
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
    }
    
    // 输出结果
    &a=0x100c81e58
    &b=0x100c81f24
    &c=0x100c81e5c
    &d=0x100c81f20
    &e=0x7ffeeef80c2c
    &f=0x7ffeeef80c28
    str=0x100c81070
    obj=0x6000024900a0 
    复制代码

经过排序的内存地址大小如下

    字符串常量
    str=0x10dfa0068
    
    已初始化的全局变量、静态变量
    &a =0x10dfa0db8
    &c =0x10dfa0dbc
    
    未初始化的全局变量、静态变量
    &d =0x10dfa0e80
    &b =0x10dfa0e84
    
    堆
    obj=0x608000012210
    
    栈
    &f =0x7ffee1c60fe0
    &e =0x7ffee1c60fe4 
    复制代码

**注意：**  字符串常量严格来说应该是存储在`__TEXT段`，只是我们习惯把他归于数据段

二、OC对象的一些特殊类型的内存管理
==================

1\. `Tagged Pointer`技术
----------------------

iOS从`64bit`系统开始，iOS引入了`Tagged Pointer`技术，用于优化`NSNumber、NSDate、NSString`等支持字面量语法的小对象的数据存储

2.Tagged Pointer的使用
-------------------

*   在没有使用`Tagged Pointer`之前， `NSNumber`等对象需要`动态分配内存`、`维护引用计数`等，`NSNumber指针`存储的是堆中`NSNumber对象的地址值`
*   使用`Tagged Pointer`之后，`NSNumber指针`里面存储的数据变成了：`Tag + Data`，也就是将数据直接存储在了指针中
*   当指针不够存储数据时，才会使用动态分配内存的方式来存储数据
*   `objc_msgSend`能识别`Tagged Pointer`，比如`NSNumber`的`intValue方法`，直接从指针提取数据，节省了以前的调用开销

下面我们来举例说明，看示例代码

    NSNumber *number1 = @4;
    NSNumber *number2 = @5;
    NSNumber *number3 = @(0xFFFFFFFFFFFFFFF);
    
    NSLog(@"%p %p %p", number1, number2, number3);
    
    // 输出地址分别为：0x5a05f784d24b4325 0x5a05f784d24b4225 0x100515970
    
    复制代码

我们知道，如果要是动态分配内存，由于OC对象都有`isa指针`，所以最少分配`16个字节`，换算成十六进制后末位都是0；由此可以推断使用了`Tagged Pointer`的内存地址末位不为0

然后再看上面示例代码的打印，前两个个值的末位都不为0，所以使用了`Tagged Pointer`来做优化；最后一个内存地址末位为0，证明由于需要存储的数据太大了，才会采用动态分配内存的方式

3\. 源码分析
--------

我们可以从`objc4`的`objc-object.h`找到`isTaggedPointer`的实现，是通过和一个掩码`_OBJC_TAG_MASK`进行按位与运算来判断是否使用了`TaggedPointer`

    objc_object::isTaggedPointer() {
    return _objc_isTaggedPointer(this);
    }
    
    static inline bool 
    _objc_isTaggedPointer(const void * _Nullable ptr)
    {
    return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
    } 
    复制代码

`_OBJC_TAG_MASK`掩码的值

    #if __arm64__
    #   define OBJC_SPLIT_TAGGED_POINTERS 1
    #else
    #   define OBJC_SPLIT_TAGGED_POINTERS 0
    #endif
    
    #if (TARGET_OS_OSX || TARGET_OS_MACCATALYST) && __x86_64__
    // 64-bit Mac - tag bit is LSB
    #   define OBJC_MSB_TAGGED_POINTERS 0
    #else
    // Everything else - tag bit is MSB
    #   define OBJC_MSB_TAGGED_POINTERS 1
    #endif
    
    #if OBJC_SPLIT_TAGGED_POINTERS
    #   define _OBJC_TAG_MASK (1UL<<63) // 指针的最高有效位为1
    
    #elif OBJC_MSB_TAGGED_POINTERS
    #   define _OBJC_TAG_MASK (1UL<<63)
    
    #else
    #   define _OBJC_TAG_MASK 1UL // 指针的最低有效位为1
    
    #endif 
    复制代码

三、OC对象的内存管理
===========

在iOS中，使用`引用计数`来管理OC对象的内存

1\. 引用计数的原则
-----------

*   一个新创建的OC对象引用计数默认是`1`，当引用计数减为`0`，OC对象就会销毁，释放其占用的内存空间
*   调用`retain`会让OC对象的`引用计数+1`，调用`release`会让OC对象的`引用计数-1`
*   当调用`alloc、new、copy、mutableCopy方法`返回了一个对象，在不需要这个对象时，要调用`release或者autorelease`来释放它
*   想拥有某个对象，就让它的`引用计数+1`；不想再拥有某个对象，就让它的`引用计数-1`
*   可以通过以下私有函数来查看自动释放池的情况
*   `extern void` \_objc\_autoreleasePoolPrint(`void`);

2\. MRC环境下的内存管理
---------------

在`MRC环境下`的内存管理使用，见下面代码

    // Car
    @interface Car : NSObject
    
    @end
    
    @implementation Car
    
    @end
    
    // Dog
    @interface Dog : NSObject
    
    - (void)run;
    @end
    
    @implementation Dog
    
    - (void)run
    {
    NSLog(@"%s", __func__);
    }
    
    - (void)dealloc
    {
    [super dealloc];
    
    NSLog(@"%s", __func__);
    }
    @end
    
    // Person
    @interface Person : NSObject
    {
    Dog *_dog;
    Car *_car;
    int _age;
    }
    
    - (void)setAge:(int)age;
    - (int)age;
    
    - (void)setDog:(Dog *)dog;
    - (Dog *)dog;
    
    - (void)setCar:(Car *)car;
    - (Car *)car;
    
    @end
    
    @implementation Person
    
    - (void)setAge:(int)age
    {
    _age = age;
    }
    
    - (int)age
    {
    return _age;
    }
    
    - (void)setDog:(Dog *)dog
    {
    if (_dog != dog) {
        [_dog release];
        _dog = [dog retain];
    }
    }
    
    - (Dog *)dog
    {
    return _dog;
    }
    
    - (void)setCar:(Car *)car
    {
    if (_car != car) {
        [_car release];
        _car = [car retain];
    }
    }
    
    - (Car *)car
    {
    return _car;
    }
    
    - (void)dealloc
    {
    //    [_dog release];
    //    _dog = nil;
    self.dog = nil;
    self.car = nil;
    
    NSLog(@"%s", __func__);
    
    // 父类的dealloc放到最后
    [super dealloc];
    }
    
    @end
    
    
    int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        Dog *dog = [[Dog alloc] init]; // 1
        Person *person = [[Person alloc] init]; // 1
    
        [person setDog:dog]; // 2
    
        [person release]; // 0 // dog -1 = 1
        [dog release]; // 0
    }
    return 0;
    } 
    复制代码

加上`@property`后，编译器会自动生成`setter和getter`

    @property (nonatomic, assign) int age;
    @property (nonatomic, retain) Dog *dog;
    复制代码

类工厂方法创建的对象不需要进行`retain`操作，其内部已经对应做了处理

    NSMutableArray *data = [NSMutableArray array];
    复制代码

四、copy
======

1\. 深拷贝和浅拷贝
-----------

> **拷贝的目的：产生一个副本对象，跟源对象互不影响**

*   修改了源对象，不会影响副本对象
*   修改了副本对象，不会影响源对象

> **iOS提供了2个拷贝方法**

*   `copy`：不可变拷贝，产生不可变副本
*   `mutableCopy`：可变拷贝，产生可变副本

> **深拷贝和浅拷贝**

*   深拷贝：`内容拷贝`，产生新的对象
*   浅拷贝：`指针拷贝`，没有产生新的对象

看下面示例代码，内存地址分别是什么

    NSString *str1 = [NSString stringWithFormat:@"test"];
    NSString *str2 = [str1 copy]; // 返回的是NSString，浅拷贝
    NSMutableString *str3 = [str1 mutableCopy]; // 返回的是NSMutableString，深拷贝
    
    NSMutableString *str4 = [[NSMutableString alloc] initWithFormat:@"test"];
    NSString *str5 = [str4 copy]; // 返回的是NSString，深拷贝
    NSMutableString *str6 = [str4 mutableCopy]; // 返回的是NSMutableString，深拷贝
    
    NSLog(@"%p %p %p", str1, str2, str3);
    NSLog(@"%p %p %p", str4, str5, str6);
    
    // copy、mutablecopy相当于进行了一次retain，要对应进行一次release
    [str6 release];
    [str5 release];
    [str4 release];
    
    [str3 release];
    [str2 release];
    [str1 release]; 
    复制代码

通过打印发现`str1`和`str2`的内存地址是一样的，所以为浅拷贝，没有产生新的对象；而其他的都产生了新的对象，为深拷贝

常用的几个可变不可变的类型进行`copy`的操作如下图所示

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c629e7b005634d4ebb0d902e50d05929~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2\. copy修饰属性
------------

1.我们看下面代码，运行结果是怎样，为什么

    @interface Person : NSObject
    
    @property (strong, nonatomic) NSString * text;
    @end
    
    @implementation Person
    
    @end
    
    int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *person = [[Person alloc] init];
        NSMutableString * str1 = [NSMutableString stringWithString:@"dddddddddddd"];
        person.text = str1;
        [str1 appendString:@"33"];
    
        NSLog(@"%@ %@", str1, person.text);
    }
    return 0;
    }
    
    // 输出：dddddddddddd33 dddddddddddd33 
    复制代码

我们发现`str1`的值改变后，`person.text`也会被影响到，因为它们指向的是同一块内存空间

所以像`NSString、NSArray、NSDictionary`这几个类型作为属性，都是用`copy`来修饰的，这样意味着属性是不可改变的

    @property (copy, nonatomic) NSArray *data;
    @property (copy, nonatomic) NSString *text;
    @property (copy, nonatomic) NSDictionary *dict; 
    复制代码

2.我们再看下面代码，运行结果是怎样，为什么

    @interface Person : NSObject
    
    @property (copy, nonatomic) NSMutableArray *data;
    @end
    
    @implementation Person
    
    @end
    
    int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *p = [[Person alloc] init];
    
        p.data = [NSMutableArray array];
        [p.data addObject:@"jack"];
        [p.data addObject:@"rose"];
    }
    return 0;
    } 
    复制代码

结果会报错。

因为用`copy`修饰`NSMutableArray`，生成的`setter`会通过深拷贝变成`NSArray类型`的对象，然后`NSArray`在进行添加元素自然会报错

所以像`NSMutableString、NSMutableArray、NSMutableDictionary`这几个类型作为属性，都是用`strong`来修饰的，这样意味着属性是不可改变的

    @property (strong, nonatomic) NSMutableArray *data;
    @property (strong, nonatomic) NSMutableString *text;
    @property (strong, nonatomic) NSMutableDictionary *dict;
    复制代码

3.自定义copy
---------

我们的自定义类型也可以通过遵守`NSCopying协议`实现拷贝功能

使用代码如下

    @interface Person : NSObject <NSCopying>
    
    @property (assign, nonatomic) int age;
    @property (assign, nonatomic) double weight;
    @end
    
    @implementation Person
    
    - (id)copyWithZone:(NSZone *)zone
    {
    Person *person = [[Person allocWithZone:zone] init];
    person.age = self.age;
    person.weight = self.weight;
    return person;
    }
    
    int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *p1 = [[Person alloc] init];
        p1.age = 20;
        p1.weight = 50;
    
        Person *p2 = [p1 copy];
    //        p2.age = 30;
    
        NSLog(@"%@", p1);
        NSLog(@"%@", p2);   
    }
    return 0;
    } 
    复制代码

五、引用计数的存储
=========

我们之前学习的`isa指针里`有一个位域的值是用来存储引用计数器的

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b32a2820a7e949d2946f366da5fff095~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

当引用计数器过大就会存储在一个叫`SideTable`的类中

    struct SideTable {
    spinlock_t slock;
    RefcountMap refcnts;
    weak_table_t weak_table; // 弱引用表
    
    SideTable() {
        memset(&weak_table, 0, sizeof(weak_table));
    }
    
    ~SideTable() {
        _objc_fatal("Do not delete SideTable.");
    }
    
    void lock() { slock.lock(); }
    void unlock() { slock.unlock(); }
    void forceReset() { slock.forceReset(); }
    
    // Address-ordered lock discipline for a pair of side tables.
    
    template<HaveOld, HaveNew>
    static void lockTwo(SideTable *lock1, SideTable *lock2);
    template<HaveOld, HaveNew>
    static void unlockTwo(SideTable *lock1, SideTable *lock2);
    }; 
    复制代码

`RefcountMap refcnts`是一个散列表，用来存储着引用计数的

    typedef objc::DenseMap<DisguisedPtr<objc_object>,size_t,RefcountMapValuePurgeable> RefcountMap; 
    复制代码

1\. 通过源码分析
----------

### 1.1 retain的源码分析

我们在`objc-object.h`中可以对应看到引用计数存储的相关代码

我们通过`retain`来分析，其内部会去调用`rootRetain`

    inline id 
    objc_object::retain()
    {
    ASSERT(!isTaggedPointer());
    
    return rootRetain(false, RRVariant::FastOrMsgSend);
    }
    
    ALWAYS_INLINE id
    objc_object::rootRetain(bool tryRetain, objc_object::RRVariant variant)
    {
    if (slowpath(isTaggedPointer())) return (id)this;
    
    bool sideTableLocked = false;
    bool transcribeToSideTable = false;
    
    isa_t oldisa;
    isa_t newisa;
    
    oldisa = LoadExclusive(&isa.bits);
    
    if (variant == RRVariant::FastOrMsgSend) {
        // These checks are only meaningful for objc_retain()
        // They are here so that we avoid a re-load of the isa.
        if (slowpath(oldisa.getDecodedClass(false)->hasCustomRR())) {
            ClearExclusive(&isa.bits);
            if (oldisa.getDecodedClass(false)->canCallSwiftRR()) {
                return swiftRetain.load(memory_order_relaxed)((id)this);
            }
            return ((id(*)(objc_object *, SEL))objc_msgSend)(this, @selector(retain));
        }
    }
    
    if (slowpath(!oldisa.nonpointer)) {
        // a Class is a Class forever, so we can perform this check once
        // outside of the CAS loop
        if (oldisa.getDecodedClass(false)->isMetaClass()) {
            ClearExclusive(&isa.bits);
            return (id)this;
        }
    }
    
    do {
        transcribeToSideTable = false;
        newisa = oldisa;
    
        // 如果不是nonpointer，直接操作散列表+1
        if (slowpath(!newisa.nonpointer)) {
            ClearExclusive(&isa.bits);
            if (tryRetain) return sidetable_tryRetain() ? (id)this : nil;
            else return sidetable_retain(sideTableLocked);
        }
        // don't check newisa.fast_rr; we already called any RR overrides
        if (slowpath(newisa.isDeallocating())) {
            ClearExclusive(&isa.bits);
            if (sideTableLocked) {
                ASSERT(variant == RRVariant::Full);
                sidetable_unlock();
            }
            if (slowpath(tryRetain)) {
                return nil;
            } else {
                return (id)this;
            }
        }
        uintptr_t carry;
    
        // 执行引用计数加1操作
        newisa.bits = addc(newisa.bits, RC_ONE, 0, &carry);  // extra_rc++
    
        // 判断extra_rc是否满了，carry是标识符
        if (slowpath(carry)) {
            // newisa.extra_rc++ overflowed
            if (variant != RRVariant::Full) {
                ClearExclusive(&isa.bits);
                return rootRetain_overflow(tryRetain);
            }
            // Leave half of the retain counts inline and 
            // prepare to copy the other half to the side table.
            // 如果extra_rc满了，则拿出一半存储到side table散列表中
            if (!tryRetain && !sideTableLocked) sidetable_lock();
            sideTableLocked = true;
            transcribeToSideTable = true;
            newisa.extra_rc = RC_HALF;
            newisa.has_sidetable_rc = true;
        }
    } while (slowpath(!StoreExclusive(&isa.bits, &oldisa.bits, newisa.bits)));
    
    if (variant == RRVariant::Full) {
        if (slowpath(transcribeToSideTable)) {
            // Copy the other half of the retain counts to the side table.
            sidetable_addExtraRC_nolock(RC_HALF);
        }
    
        if (slowpath(!tryRetain && sideTableLocked)) sidetable_unlock();
    } else {
        ASSERT(!transcribeToSideTable);
        ASSERT(!sideTableLocked);
    }
    
    return (id)this;
    } 
    复制代码

`retain`的流程可以用下图来概述

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2db2bfdc775a4715877b8163cc6a784e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 1.2 release的源码分析

然后我们再看`release`，会对应调用`rootRelease`

    inline void
    objc_object::release()
    {
    ASSERT(!isTaggedPointer());
    
    rootRelease(true, RRVariant::FastOrMsgSend);
    }
    
    ALWAYS_INLINE bool
    objc_object::rootRelease(bool performDealloc, objc_object::RRVariant variant)
    {
    if (slowpath(isTaggedPointer())) return false;
    
    bool sideTableLocked = false;
    
    isa_t newisa, oldisa;
    
    oldisa = LoadExclusive(&isa.bits);
    
    if (variant == RRVariant::FastOrMsgSend) {
        // These checks are only meaningful for objc_release()
        // They are here so that we avoid a re-load of the isa.
        if (slowpath(oldisa.getDecodedClass(false)->hasCustomRR())) {
            ClearExclusive(&isa.bits);
            if (oldisa.getDecodedClass(false)->canCallSwiftRR()) {
                swiftRelease.load(memory_order_relaxed)((id)this);
                return true;
            }
            ((void(*)(objc_object *, SEL))objc_msgSend)(this, @selector(release));
            return true;
        }
    }
    
    // 判断nonpointer是不是共用体类型的指针
    if (slowpath(!oldisa.nonpointer)) {
        // a Class is a Class forever, so we can perform this check once
        // outside of the CAS loop
        if (oldisa.getDecodedClass(false)->isMetaClass()) {
            ClearExclusive(&isa.bits);
            return false;
        }
    }
    
    retry:
    do {
        newisa = oldisa;
    
        // 判断是否为nonpointer
        if (slowpath(!newisa.nonpointer)) {
            ClearExclusive(&isa.bits);
    
            // 不是则直接操作散列表-1
            return sidetable_release(sideTableLocked, performDealloc);
        }
        if (slowpath(newisa.isDeallocating())) {
            ClearExclusive(&isa.bits);
            if (sideTableLocked) {
                ASSERT(variant == RRVariant::Full);
                sidetable_unlock();
            }
            return false;
        }
    
        // don't check newisa.fast_rr; we already called any RR overrides
        uintptr_t carry;
        // 进行引用计数-1操作（extra_rc--）
        newisa.bits = subc(newisa.bits, RC_ONE, 0, &carry);  // extra_rc--
        if (slowpath(carry)) {
            // don't ClearExclusive()
            // 如果此时extra_rc的值为0了，则走到underflow
            goto underflow;
        }
    } while (slowpath(!StoreReleaseExclusive(&isa.bits, &oldisa.bits, newisa.bits)));
    
    // 此时extra_rc中值为0，散列表中也是空的，触发析构函数
    if (slowpath(newisa.isDeallocating()))
        goto deallocate;
    
    if (variant == RRVariant::Full) {
        if (slowpath(sideTableLocked)) sidetable_unlock();
    } else {
        ASSERT(!sideTableLocked);
    }
    return false;
    
    underflow:
    // newisa.extra_rc-- underflowed: borrow from side table or deallocate
    
    // abandon newisa to undo the decrement
    newisa = oldisa;
    
    // 判断散列表中是否存储了一半的引用计数
    if (slowpath(newisa.has_sidetable_rc)) {
        if (variant != RRVariant::Full) {
            ClearExclusive(&isa.bits);
            return rootRelease_underflow(performDealloc);
        }
    
        // Transfer retain count from side table to inline storage.
    
        if (!sideTableLocked) {
            ClearExclusive(&isa.bits);
            sidetable_lock();
            sideTableLocked = true;
            // Need to start over to avoid a race against 
            // the nonpointer -> raw pointer transition.
            oldisa = LoadExclusive(&isa.bits);
            goto retry;
        }
    
        // Try to remove some retain counts from the side table.
        // 从SideTable中移除存储的一半引用计数
        auto borrow = sidetable_subExtraRC_nolock(RC_HALF);
    
        bool emptySideTable = borrow.remaining == 0; // we'll clear the side table if no refcounts remain there
    
        if (borrow.borrowed > 0) {
            // Side table retain count decreased.
            // Try to add them to the inline count.
            bool didTransitionToDeallocating = false;
    
            // 进行-1操作，然后存储到extra_rc中
            newisa.extra_rc = borrow.borrowed - 1;  // redo the original decrement too
            newisa.has_sidetable_rc = !emptySideTable;
    
            bool stored = StoreReleaseExclusive(&isa.bits, &oldisa.bits, newisa.bits);
    
            if (!stored && oldisa.nonpointer) {
                // Inline update failed. 
                // Try it again right now. This prevents livelock on LL/SC 
                // architectures where the side table access itself may have 
                // dropped the reservation.
                uintptr_t overflow;
                newisa.bits =
                    addc(oldisa.bits, RC_ONE * (borrow.borrowed-1), 0, &overflow);
                newisa.has_sidetable_rc = !emptySideTable;
                if (!overflow) {
                    stored = StoreReleaseExclusive(&isa.bits, &oldisa.bits, newisa.bits);
                    if (stored) {
                        didTransitionToDeallocating = newisa.isDeallocating();
                    }
                }
            }
    
            if (!stored) {
                // Inline update failed.
                // Put the retains back in the side table.
                ClearExclusive(&isa.bits);
                sidetable_addExtraRC_nolock(borrow.borrowed);
                oldisa = LoadExclusive(&isa.bits);
                goto retry;
            }
    
            // Decrement successful after borrowing from side table.
            if (emptySideTable)
                sidetable_clearExtraRC_nolock();
    
            if (!didTransitionToDeallocating) {
                if (slowpath(sideTableLocked)) sidetable_unlock();
                return false;
            }
        }
        else {
            // Side table is empty after all. Fall-through to the dealloc path.
        }
    }
    
    // 进行析构，发送dealloc消息
    deallocate:
    // Really deallocate.
    
    ASSERT(newisa.isDeallocating());
    ASSERT(isa.isDeallocating());
    
    if (slowpath(sideTableLocked)) sidetable_unlock();
    
    __c11_atomic_thread_fence(__ATOMIC_ACQUIRE);
    
    if (performDealloc) {
        ((void(*)(objc_object *, SEL))objc_msgSend)(this, @selector(dealloc));
    }
    return true;
    } 
    复制代码

`release`的流程可以用下图来概述

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/23dc7e12564e4f049f5ba9f5efdd583e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 1.3 dealloc源码分析

`retain`和`release`的实现中，都涉及到`dealloc析构函数`，我们来分析下`dealloc`的底层实现

通过调用轨迹`dealloc -> _objc_rootDealloc -> rootDealloc`，最终会调用到`rootDealloc`

    inline void
    objc_object::rootDealloc()
    {
    if (isTaggedPointer()) return;  // fixme necessary?
    
    if (fastpath(isa.nonpointer                     && // 普通的isa
                 !isa.weakly_referenced             && // 弱指针引用
                 !isa.has_assoc                     && // 关联对象
    #if ISA_HAS_CXX_DTOR_BIT
                 !isa.has_cxx_dtor                  && // c++析构函数
    #else
                 !isa.getClass(false)->hasCxxDtor() &&
    #endif
                 !isa.has_sidetable_rc)) // 引用计数散列表
    {
        assert(!sidetable_present());
        free(this); // 直接释放
    } 
    else {
        object_dispose((id)this);
    }
    } 
    复制代码

进一步调用到`object_dispose`

我们可以看到如果没有上述判断中需要处理的条件，对象会释放的更快

    // object_dispose
    id 
    object_dispose(id obj)
    {
    if (!obj) return nil;
    
    // 销毁实例而不释放内存
    objc_destructInstance(obj);
    // 释放内存
    free(obj);
    
    return nil;
    }
    
    // objc_destructInstance
    void *objc_destructInstance(id obj) 
    {
    if (obj) {
        // Read all of the flags at once for performance.
        bool cxx = obj->hasCxxDtor();
        bool assoc = obj->hasAssociatedObjects();
    
        // This order is important.
        // 调用c++析构函数，清除成员变量
        if (cxx) object_cxxDestruct(obj);
        // 删除关联对象
        if (assoc) _object_remove_assocations(obj, /*deallocating*/true);
        // 将指向当前对象的弱指针置为nil
        obj->clearDeallocating();
    }
    
    return obj;
    }
    
    // clearDeallocating
    inline void 
    objc_object::clearDeallocating()
    {
    // 判断是否为nonpointer
    if (slowpath(!isa.nonpointer)) {
        // Slow path for raw pointer isa.
        // 如果不是，则直接释放散列表
        sidetable_clearDeallocating();
    }
    else if (slowpath(isa.weakly_referenced  ||  isa.has_sidetable_rc)) {
        // Slow path for non-pointer isa with weak refs and/or side table data.
        // 如果是，清空弱引用表 + 散列表
        clearDeallocating_slow();
    }
    
    assert(!sidetable_present());
    }
    
    // clearDeallocating_slow
    NEVER_INLINE void
    objc_object::clearDeallocating_slow()
    {
    ASSERT(isa.nonpointer  &&  (isa.weakly_referenced || isa.has_sidetable_rc));
    
    SideTable& table = SideTables()[this];
    table.lock();
    if (isa.weakly_referenced) {
        // 清空弱引用表
        weak_clear_no_lock(&table.weak_table, (id)this);
    }
    if (isa.has_sidetable_rc) {
        // 清空引用计数
        table.refcnts.erase(this);
    }
    table.unlock();
    }
    
    复制代码

dealloc的流程可以用下图概述

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9e5406fae1454dbd8da6f5e78b6651f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 1.4 retainCount 源码分析

下面我们再来分析`retainCount`的实现

    - (NSUInteger)retainCount {
    return _objc_rootRetainCount(self);
    }
    
    uintptr_t
    _objc_rootRetainCount(id obj)
    {
    ASSERT(obj);
    
    return obj->rootRetainCount();
    } 
    复制代码

内部会进一步调用`rootRetainCount`

    inline uintptr_t 
    objc_object::rootRetainCount()
    {
    // 如果是TaggedPointer就返回
    if (isTaggedPointer()) return (uintptr_t)this;
    
    sidetable_lock();
    
    // 拿到isa
    isa_t bits = __c11_atomic_load((_Atomic uintptr_t *)&isa.bits, __ATOMIC_RELAXED);
    if (bits.nonpointer) { // 查看是否为非指针类型
        uintptr_t rc = bits.extra_rc; // 拿到isa指针里的extra_rc返回
        if (bits.has_sidetable_rc) { // 判断has_sidetable_rc的值是否为1，如果为1就要去SideTable里面取
            rc += sidetable_getExtraRC_nolock();
        }
        sidetable_unlock();
        return rc;
    }
    
    sidetable_unlock();
    return sidetable_retainCount();
    }
    
    size_t 
    objc_object::sidetable_getExtraRC_nolock()
    {
    // 通过一个key取出SideTable里的散列表refcnts
    ASSERT(isa.nonpointer);
    SideTable& table = SideTables()[this];
    RefcountMap::iterator it = table.refcnts.find(this);
    if (it == table.refcnts.end()) return 0;
    else return it->second >> SIDE_TABLE_RC_SHIFT;
    }
    复制代码

六、weak指针
========

我们通常会使用`__weak`来对变量进行弱引用，被`__weak`修饰的变量一旦被释放，会自动置为`nil`

`__unsafe_unretained`的作用也是将变量变成弱指针，但是不同于`__weak`的原因是修饰的变量释放后并不会置为`nil`

1\. weak的实现原理
-------------

我们可以在`dealloc析构函数`的实现中找到关于弱引用的处理 根据调用轨迹:

*   `dealloc` ->
*   `_objc_rootDealloc` ->
*   `rootDealloc` ->
*   `object_dispose` ->
*   `objc_destructInstance` ->
*   `clearDeallocating` ->
*   `clearDeallocating_slow` 找到`clearDeallocating_slow`来分析:

    NEVER_INLINE void objc_object::clearDeallocating_slow()
    {
        ASSERT(isa.nonpointer  &&  (isa.weakly_referenced || isa.has_sidetable_rc));
    
        SideTable& table = SideTables()[this];
        table.lock();
        if (isa.weakly_referenced) {
            // 清空弱引用表
            weak_clear_no_lock(&table.weak_table, (id)this);
        }
        if (isa.has_sidetable_rc) {
            // 清空引用计数
            table.refcnts.erase(this);
        }
        table.unlock();
    }
    
    复制代码

如果有弱引用表，则进一步调用`weak_clear_no_lock`去清空弱引用表

    void weak_clear_no_lock(weak_table_t *weak_table, id referent_id) 
    {
        // 当前对象的地址值
        objc_object *referent = (objc_object *)referent_id;
    
        // 通过地址值找到弱引用表
        weak_entry_t *entry = weak_entry_for_referent(weak_table, referent);
        if (entry == nil) {
            /// XXX shouldn't happen, but does with mismatched CF/objc
            //printf("XXX no entry for clear deallocating %p\n", referent);
            return;
        }
    
        // zero out references
        weak_referrer_t *referrers;
        size_t count;
        
        if (entry->out_of_line()) {
            referrers = entry->referrers;
            count = TABLE_SIZE(entry);
        } 
        else {
            referrers = entry->inline_referrers;
            count = WEAK_INLINE_COUNT;
        }
        
        for (size_t i = 0; i < count; ++i) {
            objc_object **referrer = referrers[i];
            if (referrer) {
                if (*referrer == referent) {
                    *referrer = nil;
                }
                else if (*referrer) {
                    _objc_inform("__weak variable at %p holds %p instead of %p. "
                                 "This is probably incorrect use of "
                                 "objc_storeWeak() and objc_loadWeak(). "
                                 "Break on objc_weak_error to debug.\n", 
                                 referrer, (void*)*referrer, (void*)referent);
                    objc_weak_error();
                }
            }
        }
        
        // 移除弱引用表
        weak_entry_remove(weak_table, entry);
    }
    
    复制代码

其内部会调用`weak_entry_for_referent`根据对象的地址值作为`key`，和`mask进行按位与运算`在散列表中找到对应的弱引用表

    static weak_entry_t *
    weak_entry_for_referent(weak_table_t *weak_table, objc_object *referent)
    {
        ASSERT(referent);
    
        weak_entry_t *weak_entries = weak_table->weak_entries;
    
        if (!weak_entries) return nil;
    
        // 利用地址值(作为key) & mask = 索引
        size_t begin = hash_pointer(referent) & weak_table->mask;
        size_t index = begin;
        size_t hash_displacement = 0;
        while (weak_table->weak_entries[index].referent != referent) {
            index = (index+1) & weak_table->mask;
            if (index == begin) bad_weak_table(weak_table->weak_entries);
            hash_displacement++;
            if (hash_displacement > weak_table->max_hash_displacement) {
                return nil;
            }
        }
        
        return &weak_table->weak_entries[index];
    }
    
    复制代码

通过源码分析，我们可以得知`weak修饰`的属性都会存在一个`weak_table`类型的散列表中，然后以当前对象的地址值为`key`将所有的弱引用表进行存储；当该对象被释放时，也是同样的步骤从散列表`weak_table`中查找到弱引用表并移除

2\. 总结
------

*   全局共维护一张`SideTables表`
*   `SideTables`中包含多个`SideTable`，可以通过对象地址的哈希算法找到对应的`SideTable`
*   `SideTable`对应着多个对象，里面存储着`引用计数表`和`弱引用表`，需要再对该对象进行一次哈希才能找到其`引用计数表`和`弱引用表`

`SideTable`的关系如下图所示

![-w810](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8804a15c3e14e30944c1dee0eef46ab~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

七、autorelease
=============

我们在`MRC环境`下给一个对象加上`autorelease`，该对象会在被放到自动释放池中自动进行引用计数管理

    int main(int argc, const char * argv[]) {
        @autoreleasepool { 
            Person *p1 = [[[Person alloc] init] autorelease]; 
        } 
        return 0;
    } 
    复制代码

`autorelease`到底做了什么呢？

1\. @autoreleasepool的实现原理
-------------------------

下面我们就来分析`@autoreleasepool`的实现原理

我们先将这段代码转为`C++`代码来查看

    int main(int argc, const char * argv[]) {
        /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
            HPPerson *person = ((HPPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((MJPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((HPPerson *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("HPPerson"), sel_registerName("alloc")), sel_registerName("init")), sel_registerName("autorelease"));
        }
        return 0;
    } 
    复制代码

发现会生成一个`__AtAutoreleasePool`类型的结构体，其内部会生成构造函数和析构函数

    struct __AtAutoreleasePool {
      __AtAutoreleasePool() { // 构造函数，在生成结构体变量的时候调用
        atautoreleasepoolobj = objc_autoreleasePoolPush();
      }
      
      ~__AtAutoreleasePool() { // 析构函数，在结构体销毁的时候调用
        objc_autoreleasePoolPop(atautoreleasepoolobj);
      }
      
      void * atautoreleasepoolobj;
    };
    
    复制代码

`@autoreleasepool`的实现过程就是在代码块的开头和结尾分别调用`objc_autoreleasePoolPush`和`objc_autoreleasePoolPop`

然后我们在从`objc4源码`中`NSObject.mm`可以找到对应的实现

    void * objc_autoreleasePoolPush(void)
    {
        return AutoreleasePoolPage::push();
    }
    
    void objc_autoreleasePoolPop(void *ctxt)
    {
        AutoreleasePoolPage::pop(ctxt);
    }
    
    复制代码

我们发现两个函数都会调用到`AutoreleasePoolPage类型`，我们可以看到该类型的定义如下，本质是一个`AutoreleasePoolPageData`类型的结构体

    class AutoreleasePoolPage : private AutoreleasePoolPageData{
        friend struct thread_data_t;
    
    public:
        // 每页的大小
        static size_t const SIZE =
    #if PROTECT_AUTORELEASEPOOL
            PAGE_MAX_SIZE;  // must be multiple of vm page size
    #else
            PAGE_MIN_SIZE;  // size and alignment, power of 2
    #endif
        
    private:
        static pthread_key_t const key = AUTORELEASE_POOL_KEY;
        static uint8_t const SCRIBBLE = 0xA3;  // 0xA3A3A3A3 after releasing
        static size_t const COUNT = SIZE / sizeof(id);
        static size_t const MAX_FAULTS = 2;
        
        ....
    }
    
    // AutoreleasePoolPageData
    struct AutoreleasePoolPageData
    {
    #if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
        struct AutoreleasePoolEntry {
            uintptr_t ptr: 48;
            uintptr_t count: 16;
    
            static const uintptr_t maxCount = 65535; // 2^16 - 1
        };
        static_assert((AutoreleasePoolEntry){ .ptr = MACH_VM_MAX_ADDRESS }.ptr == MACH_VM_MAX_ADDRESS, "MACH_VM_MAX_ADDRESS doesn't fit into AutoreleasePoolEntry::ptr!");
    #endif
    
        magic_t const magic;
        __unsafe_unretained id *next;
        pthread_t const thread;
        AutoreleasePoolPage * const parent; // 指向上一个AutoreleasePoolPage的指针（链表中的第一个为nil）
        AutoreleasePoolPage *child; // 指向下一个存储AutoreleasePoolPage的指针（链表中的最后一个为nil）
        uint32_t const depth;
        uint32_t hiwat;
    
        AutoreleasePoolPageData(__unsafe_unretained id* _next, pthread_t _thread, AutoreleasePoolPage* _parent, uint32_t _depth, uint32_t _hiwat)
            : magic(), next(_next), thread(_thread),
              parent(_parent), child(nil),
              depth(_depth), hiwat(_hiwat)
        {
        }
    };
    
    复制代码

2\. objc\_autoreleasePoolPush的源码分析
----------------------------------

我们通过调用轨迹`objc_autoreleasePoolPush -> AutoreleasePoolPage::push`来分析内部具体做了什么

    // 入栈
    static inline void *push() 
    {
       id *dest;
       if (slowpath(DebugPoolAllocation)) {
           // Each autorelease pool starts on a new pool page.
           // 创建一个新的page对象，将POOL_BOUNDARY加进去
           dest = autoreleaseNewPage(POOL_BOUNDARY);
       } else {
           // 已有page对象，快速加入POOL_BOUNDARY
           dest = autoreleaseFast(POOL_BOUNDARY);
       }
       ASSERT(dest == EMPTY_POOL_PLACEHOLDER || *dest == POOL_BOUNDARY);
       return dest;
    }
    
    复制代码

**【第一步】** 如果没有新的page对象，那么会调用`autoreleaseNewPage`

    static __attribute__((noinline))
    id *autoreleaseNewPage(id obj)
    {
       // 获取当前操作页
       AutoreleasePoolPage *page = hotPage();
       
       // 将POOL_BOUNDARY加到page中（入栈）
       if (page) return autoreleaseFullPage(obj, page);
       else return autoreleaseNoPage(obj);
    }
    
    // 获取当前操作页
    static inline AutoreleasePoolPage *hotPage() 
    {
       // 获取当前页
       AutoreleasePoolPage *result = (AutoreleasePoolPage *)
           tls_get_direct(key);
       
       // 如果是一个空池，则返回nil，否则，返回当前线程的自动释放池
       if ((id *)result == EMPTY_POOL_PLACEHOLDER) return nil;
       if (result) result->fastcheck();
       return result;
    }
    
    复制代码

`autoreleaseNewPage`内部又会分别判断有page和没有page的操作

1.有page就调用`autoreleaseFullPage`将对象压入栈

    static __attribute__((noinline))
    id *autoreleaseFullPage(id obj, AutoreleasePoolPage *page)
    {
       // The hot page is full. 
       // Step to the next non-full page, adding a new page if necessary.
       // Then add the object to that page.
       ASSERT(page == hotPage());
       ASSERT(page->full()  ||  DebugPoolAllocation);
    
       // 循环遍历当前page是否满了
       do {
           // 如果子页面存在，则将页面替换为子页面
           if (page->child) page = page->child;
           // 如果子页面不存在，则新建页面
           else page = new AutoreleasePoolPage(page);
       } while (page->full());
    
       // 设置为当前操作page
       setHotPage(page);
       
       // 压入栈
       return page->add(obj);
    }
    
    // 设置当前操作页
    static inline void setHotPage(AutoreleasePoolPage *page) 
    {
       if (page) page->fastcheck();
       tls_set_direct(key, (void *)page);
    }
    
    static inline AutoreleasePoolPage *coldPage() 
    {
       AutoreleasePoolPage *result = hotPage();
       if (result) {
           while (result->parent) {
               result = result->parent;
               result->fastcheck();
           }
       }
       return result;
    }
    
    复制代码

在`add`里进行真正的压栈操作

    id *add(id obj)
    {
       ASSERT(!full());
       unprotect();
       id *ret; // 对象存储的位置
    
    #if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
       if (!DisableAutoreleaseCoalescing || !DisableAutoreleaseCoalescingLRU) {
           if (!DisableAutoreleaseCoalescingLRU) {
               if (!empty() && (obj != POOL_BOUNDARY)) {
                   AutoreleasePoolEntry *topEntry = (AutoreleasePoolEntry *)next - 1;
                   for (uintptr_t offset = 0; offset < 4; offset++) {
                       AutoreleasePoolEntry *offsetEntry = topEntry - offset;
                       if (offsetEntry <= (AutoreleasePoolEntry*)begin() || *(id *)offsetEntry == POOL_BOUNDARY) {
                           break;
                       }
                       if (offsetEntry->ptr == (uintptr_t)obj && offsetEntry->count < AutoreleasePoolEntry::maxCount) {
                           if (offset > 0) {
                               AutoreleasePoolEntry found = *offsetEntry;
                               memmove(offsetEntry, offsetEntry + 1, offset * sizeof(*offsetEntry));
                               *topEntry = found;
                           }
                           topEntry->count++;
                           ret = (id *)topEntry;  // need to reset ret
                           goto done;
                       }
                   }
               }
           } else {
               if (!empty() && (obj != POOL_BOUNDARY)) {
                   AutoreleasePoolEntry *prevEntry = (AutoreleasePoolEntry *)next - 1;
                   if (prevEntry->ptr == (uintptr_t)obj && prevEntry->count < AutoreleasePoolEntry::maxCount) {
                       prevEntry->count++;
                       ret = (id *)prevEntry;  // need to reset ret
                       goto done;
                   }
               }
           }
       }
    #endif
       // 传入对象存储的位置
       ret = next;  // faster than `return next-1` because of aliasing
       // 将obj压栈到next指针位置，然后next进行++，即下一个对象存储的位置
       *next++ = obj;
    #if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
       // Make sure obj fits in the bits available for it
       ASSERT(((AutoreleasePoolEntry *)ret)->ptr == (uintptr_t)obj);
    #endif
    done:
       protect();
       return ret;
    }
    
    复制代码

2.在`autoreleaseNewPage`内部判断没有page就会去调用`autoreleaseNoPage`创建新的page，然后在进行压栈操作

    static __attribute__((noinline))
    id *autoreleaseNoPage(id obj)
    {
       // "No page" could mean no pool has been pushed
       // or an empty placeholder pool has been pushed and has no contents yet
       ASSERT(!hotPage());
    
       bool pushExtraBoundary = false;
       
       // 判断是否为空占位符，如果是，则将入栈标识为true
       if (haveEmptyPoolPlaceholder()) {
           // We are pushing a second pool over the empty placeholder pool
           // or pushing the first object into the empty placeholder pool.
           // Before doing that, push a pool boundary on behalf of the pool 
           // that is currently represented by the empty placeholder.
           pushExtraBoundary = true;
       }
       
       // 如果不是POOL_BOUNDARY，并且没有pool，则报错
       else if (obj != POOL_BOUNDARY  &&  DebugMissingPools) {
           // We are pushing an object with no pool in place, 
           // and no-pool debugging was requested by environment.
           _objc_inform("MISSING POOLS: (%p) Object %p of class %s "
                        "autoreleased with no pool in place - "
                        "just leaking - break on "
                        "objc_autoreleaseNoPool() to debug", 
                        objc_thread_self(), (void*)obj, object_getClassName(obj));
           objc_autoreleaseNoPool(obj);
           return nil;
       }
       
       // 如果对象是POOL_BOUNDARY，且没有申请自动释放池内存，则设置一个空占位符存储在tls中，其目的是为了节省内存
       else if (obj == POOL_BOUNDARY  &&  !DebugPoolAllocation) {
           // We are pushing a pool with no pool in place,
           // and alloc-per-pool debugging was not requested.
           // Install and return the empty pool placeholder.
           return setEmptyPoolPlaceholder();
       }
    
       // We are pushing an object or a non-placeholder'd pool.
    
       // Install the first page.
       // 初始化第一页
       AutoreleasePoolPage *page = new AutoreleasePoolPage(nil);
       
       // 设置为当前页
       setHotPage(page);
       
       // Push a boundary on behalf of the previously-placeholder'd pool.
       // 如果标识为true，则压入栈
       if (pushExtraBoundary) {
           page->add(POOL_BOUNDARY);
       }
       
       // Push the requested object or pool.
       return page->add(obj);
    }
    
    复制代码

**【第二步】**  如果一开始就有page页面，那么直接进入到`autoreleaseFast`，再分别进行判断

    static inline id *autoreleaseFast(id obj)
    {
       AutoreleasePoolPage *page = hotPage();
       if (page && !page->full()) { // 已有page，并且没满
           return page->add(obj);
       } else if (page) {
           // 如果满了，则安排新的page
           return autoreleaseFullPage(obj, page);
       } else {
           // page不存在，新建
           return autoreleaseNoPage(obj);
       }
    }
    
    复制代码

3\. 小结
------

> **@autoreleasepool**

*   自动释放池`@autoreleasepool`的底层的主要数据结构
    *   底层会生成一个`__AtAutoreleasePool的对象`
    *   调用了autorelease的对象最终都是通过`AutoreleasePoolPage`对象 进行内存管理 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f5a0e59e63be44728f60027848558844~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   `__AtAutoreleasePool`内部又会分别生成两个函数:
    *   `objc_autoreleasePoolPush`和`objc_autoreleasePoolPop`
    *   两个函数分别在大括号作用域的开始和结尾进行`push（入栈）`和`pop（出栈）`操作
*   `__AtAutoreleasePool`的底层都是依靠`AutoreleasePoolPage对象`来进行操作的
*   `AutoreleasePoolPage`是一个可以进行双向链表查找的数据类型
    *   其内部的`child`会指向下一个`AutoreleasePoolPage对象`
    *   其内部的`parent`会指向上一个`AutoreleasePoolPage对象`

> **AutoreleasePoolPage对象**

*   每一个`AutoreleasePoolPage对象`都会有一定的存储空间，大概占用`4096个字节`
*   每一个`AutoreleasePoolPage对象`内部的成员变量会占`56个字节`，然后剩余的空间才用来存储`autorelease对象`
*   每一个`@autoreleasePool`的开始都会先将`POOL_BOUNDARY对象`压入栈，然后才开始存储`autorelease对象`，并且`push方法`会返回`POOL_BOUNDARY对象`的内存地址
*   当一个`AutoreleasePoolPage对象`存满后才会往下一个`AutoreleasePoolPage对象`里开始存储
*   `AutoreleasePoolPage对象`里面的`begin`和`end`分别对应着`autorelease对象`开始入栈的起始地址和结束地址
*   `AutoreleasePoolPage对象`里面的`next`指向下一个能存放`autorelease`对象地址的区域 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2ce26c822a214ec98862854f7a1b6f8d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

上面整个`push入栈`的过程分析可以用下图来概述

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7330e432d9f24f8a88ee1ac70ad2f6aa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

八、autorelease源码分析
=================

1\. autorelease的源码分析
--------------------

下面我们来看一下`autorelease`底层做了什么

    // objc_object::autorelease
    inline id 
    objc_object::autorelease()
    {
        ASSERT(!isTaggedPointer());
        if (fastpath(!ISA()->hasCustomRR())) {
            return rootAutorelease();
        }
    
        return ((id(*)(objc_object *, SEL))objc_msgSend)(this, @selector(autorelease));
    }
    
    // objc_object::rootAutorelease
    inline id 
    objc_object::rootAutorelease()
    {
        // 如果是TaggedPointer就返回
        if (isTaggedPointer()) return (id)this;
        if (prepareOptimizedReturn(ReturnAtPlus1)) return (id)this;
    
        return rootAutorelease2();
    }
    
    // objc_object::rootAutorelease2
    __attribute__((noinline,used))
    id 
    objc_object::rootAutorelease2()
    {
        ASSERT(!isTaggedPointer());
        return AutoreleasePoolPage::autorelease((id)this);
    }
    
    复制代码

发现最后还是会调用到`AutoreleasePoolPage`的`autorelease`

    static inline id autorelease(id obj)
    {
       ASSERT(!obj->isTaggedPointerOrNil());
       id *dest __unused = autoreleaseFast(obj);
    #if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
       ASSERT(!dest  ||  dest == EMPTY_POOL_PLACEHOLDER  ||  (id)((AutoreleasePoolEntry *)dest)->ptr == obj);
    #else
       ASSERT(!dest  ||  dest == EMPTY_POOL_PLACEHOLDER  ||  *dest == obj);
    #endif
       return obj;
    }
    
    复制代码

然后进入到快速压栈`autoreleaseFast`进行压栈操作，`autoreleasepool`只会将调用了`autorelease`的对象压入栈

`autorelease`和`objc_autoreleasePush`的整体分析如下图所示

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1bed9f612fef403980e8e1a5e13a6917~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2\. objc\_autoreleasePoolPop的源码分析
---------------------------------

【第一步】我们通过调用轨迹`objc_autoreleasePoolPop -> AutoreleasePoolPage::pop`来分析内部具体做了什么

    static inline void
    pop(void *token)
    {
       AutoreleasePoolPage *page;
       id *stop;
       
       // 判断是否为空占位符
       if (token == (void*)EMPTY_POOL_PLACEHOLDER) {
           // Popping the top-level placeholder pool.
           // 获取当前页
           page = hotPage();
           if (!page) {
               // Pool was never used. Clear the placeholder.
               // 如果当前页不存在，则清除空占位符
               return setHotPage(nil);
           }
           // Pool was used. Pop its contents normally.
           // Pool pages remain allocated for re-use as usual.
           // 如果当前页存在，则将当前页设置为coldPage,token设置为coldPage的开始位置
           page = coldPage();
           token = page->begin();
       } else {
           // 获取token所在的page
           page = pageForPointer(token);
       }
    
       stop = (id *)token;
       // 判断最后一个位置，是否是POOL_BOUNDARY
       if (*stop != POOL_BOUNDARY) {
           // 如果不是，即最后一个位置是一个对象
           if (stop == page->begin()  &&  !page->parent) {
               // Start of coldest page may correctly not be POOL_BOUNDARY:
               // 1. top-level pool is popped, leaving the cold page in place
               // 2. an object is autoreleased with no pool
               // 如果是第一个位置，且没有父节点，什么也不做
           } else {
               // Error. For bincompat purposes this is not 
               // fatal in executables built with old SDKs.
               // 如果是第一个位置，且有父节点，则出现了混乱
               return badPop(token);
           }
       }
    
       if (slowpath(PrintPoolHiwat || DebugPoolAllocation || DebugMissingPools)) {
           return popPageDebug(token, page, stop);
       }
    
       // 出栈
       return popPage<false>(token, page, stop);
    }
    
    复制代码

`begin`和`end`分别对应着`autorelease对象`的起始地址和结束地址

    // 开始存放autorelease对象的地址：开始地址 + 他本身占用的大小
    id * begin() {
       return (id *) ((uint8_t *)this+sizeof(*this));
    }
    
    // 结束地址：开始地址 + PAGE_MAX_SIZE
    id * end() {
       return (id *) ((uint8_t *)this+SIZE);
    }
    
    // coldPage
    static inline AutoreleasePoolPage *coldPage() 
    {
       AutoreleasePoolPage *result = hotPage();
       if (result) {
           while (result->parent) {
               result = result->parent;
               result->fastcheck();
           }
       }
       return result;
    }
    
    复制代码

【第二步】然后进入`popPage`进行出栈操作

    template<bool allowDebug>
    static void
    popPage(void *token, AutoreleasePoolPage *page, id *stop)
    {
       if (allowDebug && PrintPoolHiwat) printHiwat();
    
       // 出栈当前操作页面对象
       page->releaseUntil(stop);
    
       // memory: delete empty children
       // 删除空子项
       if (allowDebug && DebugPoolAllocation  &&  page->empty()) {
           // special case: delete everything during page-per-pool debugging
           // 获取当前页面的父节点
           AutoreleasePoolPage *parent = page->parent;
           //删除将当前页面
           page->kill();
           // 设置操作页面为父节点页面
           setHotPage(parent);
       } else if (allowDebug && DebugMissingPools  &&  page->empty()  &&  !page->parent) {
           // special case: delete everything for pop(top)
           // when debugging missing autorelease pools
           page->kill();
           setHotPage(nil);
       } else if (page->child) {
           // hysteresis: keep one empty child if page is more than half full
           // 如果页面已满一半以上，则保留一个空子级
           if (page->lessThanHalfFull()) {
               page->child->kill();
           }
           else if (page->child->child) {
               page->child->child->kill();
           }
       }
    }
    
    // kill
    void kill() 
    {
       // Not recursive: we don't want to blow out the stack 
       // if a thread accumulates a stupendous amount of garbage
       AutoreleasePoolPage *page = this;
       while (page->child) page = page->child;
    
       AutoreleasePoolPage *deathptr;
       do {
           deathptr = page;
           
           // 子节点 变成 父节点
           page = page->parent;
           if (page) {
               page->unprotect();
               
               //子节点置空
               page->child = nil;
               page->protect();
           }
           delete deathptr;
       } while (deathptr != this);
    }
    
    复制代码

内部会调用`releaseUntil`循环遍历进行`pop操作`

    void releaseUntil(id *stop) 
    {
       // Not recursive: we don't want to blow out the stack 
       // if a thread accumulates a stupendous amount of garbage
       
       // 循环遍历
       // 判断下一个对象是否等于stop，如果不等于，则进入while循环
       while (this->next != stop) {
           // Restart from hotPage() every time, in case -release 
           // autoreleased more objects
           AutoreleasePoolPage *page = hotPage();
    
           // fixme I think this `while` can be `if`, but I can't prove it
           // 如果当前页是空的
           while (page->empty()) {
               // 将page赋值为父节点页
               page = page->parent;
               // 并设置当前页为父节点页
               setHotPage(page);
           }
    
           page->unprotect();
    #if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
           AutoreleasePoolEntry* entry = (AutoreleasePoolEntry*) --page->next;
    
           // create an obj with the zeroed out top byte and release that
           id obj = (id)entry->ptr;
           int count = (int)entry->count;  // grab these before memset
    #else
           id obj = *--page->next;
    #endif
           memset((void*)page->next, SCRIBBLE, sizeof(*page->next));
           page->protect();
    
           if (obj != POOL_BOUNDARY) { // 只要不是POOL_BOUNDARY，就进行release
    #if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
               // release count+1 times since it is count of the additional
               // autoreleases beyond the first one
               for (int i = 0; i < count + 1; i++) {
                   objc_release(obj);
               }
    #else
               objc_release(obj);
    #endif
           }
       }
    
       // 设置当前页
       setHotPage(this);
    
    #if DEBUG
       // we expect any children to be completely empty
       for (AutoreleasePoolPage *page = child; page; page = page->child) {
           ASSERT(page->empty());
       }
    #endif
    }
    
    复制代码

3\. 总结
------

*   `pop`函数会将`POOL_BOUNDARY`的内存地址传进去
*   `autorelease对象`从`end的结束地址`开始进行发送`release消息`，一直找到`POOL_BOUNDARY`为止
*   一旦发现当前页已经空了，就会去上一个页面进行`pop`，并释放当前页面
*   整个入栈出栈的顺序是采用先进后出，和栈中顺序一样，但不代表着这里说的是真正的栈

上面整个`pop`出栈的过程分析可以用下图来概述

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/169db02de52f4bc497e904b61bd0585f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

九、通过打印分析执行过程
============

我们可以通过一个私有函数`_objc_autoreleasePoolPrint`来打印分析整个`autorelease`的过程

    // 声明内部私有函数，可以调用执行
    extern void _objc_autoreleasePoolPrint(void);
    
    int main(int argc, const char * argv[]) {
        @autoreleasepool { //  r1 = push()
            
            Person *p1 = [[[Person alloc] init] autorelease];
            Person *p2 = [[[Person alloc] init] autorelease];
            
            @autoreleasepool { // r2 = push()
               
                MJPerson *p3 = [[[Person alloc] init] autorelease];
                
                _objc_autoreleasePoolPrint();
                
            } // pop(r2)
            
            
        } // pop(r1)
        
        
        return 0;
    }
    
    复制代码

可以看到打印结果如下

    objc[25057]: ##############
    objc[25057]: AUTORELEASE POOLS for thread 0x1000e7e00
    objc[25057]: 5 releases pending.
    objc[25057]: [0x107009000]  ................  PAGE  (hot) (cold)
    objc[25057]: [0x107009038]  ################  POOL 0x107009038
    objc[25057]: [0x107009040]       0x10060f120  Person
    objc[25057]: [0x107009048]       0x100606800  Person
    objc[25057]: [0x107009050]  ################  POOL 0x107009050
    objc[25057]: [0x107009058]       0x100607de0  Person
    objc[25057]: ##############
    
    复制代码

十、面试题
=====

通过前面的探索,我们找几道面试题来检验一下对知识点的掌握程度

1.@dynamic和@synthesize两个关键字的含义
------------------------------

在旧版的编译器，加上`@synthesize`会生成`带下划线的成员变量和setter、getter的实现`，现在的编译器已经不用加上这个关键字也可以自动实现了

    // 成员变量为_age
    @synthesize age = _age;
    
    // 不赋值的话，成员变量就是age
    @synthesize age
    
    复制代码

加上`@dynamic`不会自动生成`setter和getter的实现和成员变量`

    @dynamic age;
    
    复制代码

所有的声明都是由`@property`来决定的

2.分别运行下面两段代码，思考能发生什么事，有什么区别
---------------------------

    @interface ViewController ()
    @property (strong, nonatomic) NSString *name;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 第一段
        for (int i = 0; i < 1000; i++) {
            dispatch_async(queue, ^{
                self.name = [NSString stringWithFormat:@"abcdefghijk"];
            });
        }
        
    
    // 第二段
        for (int i = 0; i < 1000; i++) {
            dispatch_async(queue, ^{
                self.name = [NSString stringWithFormat:@"abc"];
            });
        }
    }
    
    @end
    
    复制代码

【第一段代码】

由于给`self.name`赋值会调用`name的setter`，`setter`的实现是先释放掉旧的成员变量，然后赋值新的成员变量；又因为是多线程并发调用，所以`name`被多次释放造成坏内存访问

解决办法：在`dispatch_async`的回调中给`self.name`赋值加锁

【第二段代码】

程序不会崩溃。

我们先分别打印两个字符串，从打印类型和内存地址都可以发现第二个字符串是经过了`TaggedPointer`优化过的，所以不会调用`setter`，也就不会被多次释放造成崩溃了

    NSString *str1 = [NSString stringWithFormat:@"abcdefghijk"];
        NSString *str2 = [NSString stringWithFormat:@"abc"];
    
        NSLog(@"%@ %@", [str1 class], [str2 class]);
        NSLog(@"%p %p", str1, str2);
        
    // 输出：__NSCFString NSTaggedPointerString
    // 0x600000a8d6c0 0x818ff819168b363d
    
    复制代码

3.ARC都帮我们做了什么
-------------

`ARC`是`LLVM`和`Runtime`相互协作的产物；`LLVM`会在编译阶段帮我们生成内存管理相关的代码，`Runtime`又会在运行时进行内存管理的操作

4.局部变量具体是在什么时候进行释放的
-------------------

*   如果是不被修饰的局部变量，会在函数内作用域结束进行释放
*   如果是被`@autoreleasePool`修饰的，那么会交由自动释放池管理
*   如果是调用了`autorelease`，那么会被加到`RunLoop`中进行管理

看下面这段代码，对象在执行完`viewWillAppear`后才被释放

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        Person *person = [[[Person alloc] init] autorelease];
        
        NSLog(@"%s", __func__);
    }
    
    - (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
        
        NSLog(@"%s", __func__);
    }
    
    - (void)viewDidAppear:(BOOL)animated
    {
        [super viewDidAppear:animated];
        
        NSLog(@"%s", __func__);
    }
    
    复制代码

`Runloop`在进入循环时会先执行一次`objc_autoreleasePoolPush`，然后再进入睡眠之前会执行一次`objc_autoreleasePoolPop`和`objc_autoreleasePoolPush`，就这样一直循环；等到程序真正退出时再回执行一次`objc_autoreleasePoolPop`

由此也可以发现`viewDidLoad`和`viewWillAppear`是在同一次运行循环中