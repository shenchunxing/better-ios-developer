# KVC

前言
==

> 之前,我们在探索动画及渲染相关原理的时候,我们输出了几篇文章,解答了`iOS动画是如何渲染,特效是如何工作的疑惑`。我们深感系统设计者在创作这些系统框架的时候,是如此脑洞大开,也 **`深深意识到了解一门技术的底层原理对于从事该方面工作的重要性。`**
> 
> 因此我们决定 **`进一步探究iOS底层原理的任务`**。继上一篇文章我们探索了KVO底层实现之后，本文探索的底层原理围绕`“KVC的底层实现”`展开

一、KVC的基本使用
==========

1.KVC
-----

`KVC`的全称是**Key-Value Coding**，俗称“键值编码”，可以通过一个key来访问某个属性

2.KVC的使用
--------

*   属性赋值
    *   可以通过`setValue: forKeyPath:` 和`setValue: forKey:`来给属性赋值
*   属性取值
    *   可以通过`valueForKeyPath:`和`valueForKey:`来获取属性值。

`setValue: forKeyPath:`可以根据`keyPath`找到更深层次的属性来赋值，`setValue: forKey:`就只能找当前对象的属性，见下面示例代码

    // 示例代码
    @interface Cat : NSObject
    
    @property (assign, nonatomic) int weight;
    @end
    
    @interface Person : NSObject
    
    @property (assign, nonatomic) int age;
    @property (strong, nonatomic) Cat *cat;
    @end
    
    @implementation Cat
    
    @end
    
    @implementation Person
    
    @end
    
    Person *person = [[Person alloc] init];
    [person setValue:@10 forKey:@"age"];    
        
    person.cat = [[Cat alloc] init];
    [person setValue:@80 forKeyPath:@"cat.weight"];
            
    // NSLog(@"%d, %d", person.age, person.cat.weight);
    NSLog(@"%@", [person valueForKey:@"age"]);
            NSLog(@"%@", [person valueForKeyPath:@"cat.weight"]);
    // 输出：10，80
     
    复制代码

**注意：**

*   如果`person.cat`没有创建对象，那么`setValue: forKeyPath:`也不能给`cat.weight`属性赋值
*   如果用`setValue: forKey:`方法来给cat.weight属性赋值，那么会抛出异常`[<Person 0x100510ec0> setValue:forUndefinedKey:]`

二、 KVC的实现本质
===========

1\. setValue: forKey: 的实现本质
---------------------------

1.在`Person`里分别添加和注释`setAge:、_setAge:`两个方法，然后运行程序发现，内部会按顺序分别查找每个方法是否存在

    @interface Person : NSObject
    
    @end
    
    @implementation Person
    
    // 分别打开和注释下面两个方法
    
    //- (void)setAge:(int)age
    //{
    //    NSLog(@"setAge: - %d", age);
    //}
    
    - (void)_setAge:(int)age
    {
        NSLog(@"_setAge: - %d", age);
    }
    
    @end
     
    复制代码

2.注释掉上面两个方法后，重写`accessInstanceVariablesDirectly`方法并对应返回YES和NO，运行程序发现返回NO会抛出异常，说明不会再去查找是否有对应的属性。

`accessInstanceVariablesDirectly`默认的返回值就是**YES**

    // 默认的返回值就是YES
    + (BOOL)accessInstanceVariablesDirectly
    {
        //return YES;
        return NO;
    }
     
    复制代码

3.最后我们在给`Person对象`分别添加和注释`_age、_isAge、age、isAge`这几个成员变量，运行程序发现，内部会按顺序分别查找每个成员变量是否存在，如果都没找到也会抛出异常

    // 分别打开和注释下面的每个成员变量
    
    @interface Person : NSObject
    {
        @public
    //    int age;
    //    int isAge;
    //    int _isAge;
        int _age;
    }
    
    @end
     
    复制代码

**通过上面一系列操作可以汇总为：**

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6a001b613a0f4eb2b73b13512b54325c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2\. valueForKey: 的实现本质
----------------------

1.在`Person`里分别添加和注释`getAge、age、isAge、_age`几个方法，然后运行程序发现，内部会按顺序查找每个方法是否存在

    @interface Person : NSObject
    
    @end
    
    @implementation MJPerson
    
    // 分别打开和注释下面两个方法
    
    - (int)getAge
    {
        return 11;
    }
    
    //- (int)age
    //{
    //    return 12;
    //}
    
    //- (int)isAge
    //{
    //    return 13;
    //}
    
    //- (int)_age
    //{
    //    return 14;
    //}
    
    @end
     
    复制代码

2.同`setValue: forKey:`第二部操作一样，如果返回值为NO则抛出异常`[<Person 0x105820160> valueForUndefinedKey:]`

    libc++abi.dylib: terminating with uncaught exception of type NSException
    *** Terminating app due to uncaught exception 'NSUnknownKeyException', reason: '[<Person 0x105820160> valueForUndefinedKey:]: this class is not key value coding-compliant for the key age.'
     
    复制代码

3.同`setValue: forKey:`最后一步操作一样，只不过找到了对应的对应的成员变量直接取值，找不到也会抛出上面的异常

**通过上面一系列操作也可以汇总为：**

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c2113f1ba9714cc5a6870ff7b8fcfc02~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

三、KVC的应用场景
==========

**1.可以通过`KVC`获取到私有成员变量，以及修改私有成员变量的值**

`iOS13`之后苹果不允许通过`KVC`获取系统API的私有成员了，会crash

通过`KVC`访问自定义类型的私有成员还是可以的

**2.字典转模式**

四、与KVC、KVO相关的一些面试题
==================

1.如何手动触发KVO？
------------

手动调用`willChangeValueForKey:`和`didChangeValueForKey:`

2.直接修改成员变量会触发KVO么
-----------------

不会触发KVO

3.通过KVC修改属性会触发KVO么？
-------------------

会触发KVO

如示例代码所示，我们给`Person`添加一个`成员变量age`和一个`只读属性weight`，然后都是通过`KVC`的方式分别给它们赋值，发现都会触发`KV0`监听，并调用了`willChangeValueForKey`和`didChangeValueForKey方法`

    // Person.h
    @interface Person : NSObject
    {
        @public
        int age;
    }
    
    @property (assign, nonatomic, readonly) int weight;
    @end
    
    // Person.m
    @implementation Person
    
    - (void)willChangeValueForKey:(NSString *)key
    {
        [super willChangeValueForKey:key];
        
        NSLog(@"willChangeValueForKey");
    }
    
    - (void)didChangeValueForKey:(NSString *)key
    {
        NSLog(@"didChangeValueForKey - begin");
        
        [super didChangeValueForKey:key];
        
        NSLog(@"didChangeValueForKey - end");
    }
    @end
    
    // ViewController.m
    @interface ViewController ()
    
    @property (strong, nonatomic) Person *person;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.person = [[Person alloc] init];
                
        //添加KVO监听
        [self.person addObserver: self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        [self.person addObserver: self forKeyPath:@"weight" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        
        [self.person setValue:@10 forKey:@"age"];
        [self.person setValue:@20 forKey:@"weight"];
    }
    
    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
        NSLog(@"observeValueForKeyPath: %@",change);
    }
    
    - (void)dealloc {
        [self.person removeObserver:self forKeyPath:@"age"];
        [self.person removeObserver:self forKeyPath:@"weight"];
    }
    @end
    
    // 输出结果
    //willChangeValueForKey
    //didChangeValueForKey - begin
    //observeValueForKeyPath: {
    //    kind = 1;
    //    new = 10;
    //    old = 0;
    //}
    //didChangeValueForKey - end
    //
    //
    //willChangeValueForKey
    //didChangeValueForKey - begin
    //observeValueForKeyPath: {
    //    kind = 1;
    //    new = 20;
    //    old = 0;
    //}
    //didChangeValueForKey - end
     
    复制代码

4.怎么通过KVO监听数组的元素变化？
-------------------

我们可以通过数组的`KVC`方式添加元素，其底层会调用`KVO`触发监听器来监听数组元素变化

    @interface ViewController ()
    
    @property (nonatomic, strong) NSMutableArray *lines;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.lines = [NSMutableArray array];
        [self addObserver: self forKeyPath:@"lines" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
        [[self mutableArrayValueForKey:@"lines"] addObject:@"1"];
    }
    
    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
        NSLog(@"observeValueForKeyPath: %@",change);
    }
    
    - (void)dealloc {
        [self removeObserver:self forKeyPath:@"lines"];
    }
    @end
    
    // 打印：
    observeValueForKeyPath: {
        indexes = "<_NSCachedIndexSet: 0x6000030afe60>[number of indexes: 1 (in 1 ranges), indexes: (0)]";
        kind = 2;
        new =     (
            1
        );
    }
    复制代码

专题系列文章
======

### 1.前知识

*   **[01-探究iOS底层原理|综述](https://juejin.cn/post/7089043618803122183/ "https://juejin.cn/post/7089043618803122183/")**
*   **[02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】](https://juejin.cn/post/7093842449998561316/ "https://juejin.cn/post/7093842449998561316/")**
*   **[03-探究iOS底层原理|LLDB](https://juejin.cn/post/7095079758844674056 "https://juejin.cn/post/7095079758844674056")**
*   **[04-探究iOS底层原理|ARM64汇编](https://juejin.cn/post/7115302848270696485/ "https://juejin.cn/post/7115302848270696485/")**

### 2\. 基于OC语言探索iOS底层原理

*   **[05-探究iOS底层原理|OC的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")**
*   **[06-探究iOS底层原理|OC对象的本质](https://juejin.cn/post/7094503681684406302 "https://juejin.cn/post/7094503681684406302")**
*   **[07-探究iOS底层原理|几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012")**
*   **[08-探究iOS底层原理|Category底层结构、App启动时Class与Category装载过程、load 和 initialize 执行、关联对象](https://juejin.cn/post/7096480684847415303 "https://juejin.cn/post/7096480684847415303")**
*   **[09-探究iOS底层原理|KVO](https://juejin.cn/post/7115318628563550244/ "https://juejin.cn/post/7115318628563550244/")**
*   **[10-探究iOS底层原理|KVC](https://juejin.cn/post/7115320523805949960/ "https://juejin.cn/post/7115320523805949960/")**
*   **[11-探究iOS底层原理|探索Block的本质|【Block的数据类型(本质)与内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用】](https://juejin.cn/post/7115809219319693320/ "https://juejin.cn/post/7115809219319693320/")**
*   **[12-探究iOS底层原理|Runtime1【isa详解、class的结构、方法缓存cache\_t】](https://juejin.cn/post/7116103432095662111 "https://juejin.cn/post/7116103432095662111")**
*   **[13-探究iOS底层原理|Runtime2【消息处理(发送、转发)&&动态方法解析、super的本质】](https://juejin.cn/post/7116147057739431950 "https://juejin.cn/post/7116147057739431950")**
*   **[14-探究iOS底层原理|Runtime3【Runtime的相关应用】](https://juejin.cn/post/7116291178365976590/ "https://juejin.cn/post/7116291178365976590/")**
*   **[15-探究iOS底层原理|RunLoop【两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer】](https://juejin.cn/post/7116515606597206030/ "https://juejin.cn/post/7116515606597206030/")**
*   **[16-探究iOS底层原理|RunLoop的应用](https://juejin.cn/post/7116521653667889165/ "https://juejin.cn/post/7116521653667889165/")**
*   **[17-探究iOS底层原理|多线程技术的底层原理【GCD源码分析1:主队列、串行队列&&并行队列、全局并发队列】](https://juejin.cn/post/7116821775127674916/ "https://juejin.cn/post/7116821775127674916/")**
*   **[18-探究iOS底层原理|多线程技术【GCD源码分析1:dispatch\_get\_global\_queue与dispatch\_(a)sync、单例、线程死锁】](https://juejin.cn/post/7116878578091819045 "https://juejin.cn/post/7116878578091819045")**
*   **[19-探究iOS底层原理|多线程技术【GCD源码分析2:栅栏函数dispatch\_barrier\_(a)sync、信号量dispatch\_semaphore】](https://juejin.cn/post/7116897833126625316 "https://juejin.cn/post/7116897833126625316")**
*   **[20-探究iOS底层原理|多线程技术【GCD源码分析3:线程调度组dispatch\_group、事件源dispatch Source】](https://juejin.cn/post/7116898446358888485/ "https://juejin.cn/post/7116898446358888485/")**
*   **[21-探究iOS底层原理|多线程技术【线程锁：自旋锁、互斥锁、递归锁】](https://juejin.cn/post/7116898868737867789/ "https://juejin.cn/post/7116898868737867789/")**
*   **[22-探究iOS底层原理|多线程技术【原子锁atomic、gcd Timer、NSTimer、CADisplayLink】](https://juejin.cn/post/7116907029465137165 "https://juejin.cn/post/7116907029465137165")**
*   **[23-探究iOS底层原理|内存管理【Mach-O文件、Tagged Pointer、对象的内存管理、copy、引用计数、weak指针、autorelease](https://juejin.cn/post/7117274106940096520 "https://juejin.cn/post/7117274106940096520")**

### 3\. 基于Swift语言探索iOS底层原理

关于`函数`、`枚举`、`可选项`、`结构体`、`类`、`闭包`、`属性`、`方法`、`swift多态原理`、`String`、`Array`、`Dictionary`、`引用计数`、`MetaData`等Swift基本语法和相关的底层原理文章有如下几篇:

*   [Swift5核心语法1-基础语法](https://juejin.cn/post/7119020967430455327 "https://juejin.cn/post/7119020967430455327")
*   [Swift5核心语法2-面向对象语法1](https://juejin.cn/post/7119510159109390343 "https://juejin.cn/post/7119510159109390343")
*   [Swift5核心语法2-面向对象语法2](https://juejin.cn/post/7119513630550261774 "https://juejin.cn/post/7119513630550261774")
*   [Swift5常用核心语法3-其它常用语法](https://juejin.cn/post/7119714488181325860 "https://juejin.cn/post/7119714488181325860")
*   [Swift5应用实践常用技术点](https://juejin.cn/post/7119722433589805064 "https://juejin.cn/post/7119722433589805064")

其它底层原理专题
========

### 1.底层原理相关专题

*   [01-计算机原理|计算机图形渲染原理这篇文章](https://juejin.cn/post/7018755998823219213 "https://juejin.cn/post/7018755998823219213")
*   [02-计算机原理|移动终端屏幕成像与卡顿 ](https://juejin.cn/post/7019117942377807908 "https://juejin.cn/post/7019117942377807908")

### 2.iOS相关专题

*   [01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理](https://juejin.cn/post/7019193784806146079 "https://juejin.cn/post/7019193784806146079")
*   [02-iOS底层原理|iOS动画渲染原理](https://juejin.cn/post/7019200157119938590 "https://juejin.cn/post/7019200157119938590")
*   [03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理](https://juejin.cn/post/7019497906650497061/ "https://juejin.cn/post/7019497906650497061/")
*   [04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案](https://juejin.cn/post/7020613901033144351 "https://juejin.cn/post/7020613901033144351")

### 3.webApp相关专题

*   [01-Web和类RN大前端的渲染原理](https://juejin.cn/post/7021035020445810718/ "https://juejin.cn/post/7021035020445810718/")

### 4.跨平台开发方案相关专题

*   [01-Flutter页面渲染原理](https://juejin.cn/post/7021057396147486750/ "https://juejin.cn/post/7021057396147486750/")

### 5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较

*   [01-Native、WebApp、跨平台开发三种方案性能比较](https://juejin.cn/post/7021071990723182606/ "https://juejin.cn/post/7021071990723182606/")

### 6.Android、HarmonyOS页面渲染专题

*   [01-Android页面渲染原理](https://juejin.cn/post/7021840737431978020/ "https://juejin.cn/post/7021840737431978020/")
*   [02-HarmonyOS页面渲染原理](# "#") (`待输出`)

### 7.小程序页面渲染专题

*   [01-小程序框架渲染原理](https://juejin.cn/post/7021414123346853919 "https://juejin.cn/post/7021414123346853919")