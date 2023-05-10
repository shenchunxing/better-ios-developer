# KVO

前言
==

> 之前,我们在探索动画及渲染相关原理的时候,我们输出了几篇文章,解答了`iOS动画是如何渲染,特效是如何工作的疑惑`。我们深感系统设计者在创作这些系统框架的时候,是如此脑洞大开,也 **`深深意识到了解一门技术的底层原理对于从事该方面工作的重要性。`**
> 
> 因此我们决定 **`进一步探究iOS底层原理的任务`** ,本文探索的底层原理围绕“`KVO的底层实现`展开

一、KVO简介
=======

1\. KVO
-------

`KVO`的全称是**Key-Value Observing**，俗称“键值监听”，可以用于监听某个对象属性值的改变

2\. KVO的使用
----------

*   发起监听
    *   可以通过`addObserver: forKeyPath:`方法对属性发起监听
*   接收监听信息
    *   然后通过`observeValueForKeyPath: ofObject: change:`方法中对应进行监听，见下面示例代码:

    // 示例代码
    @interface Person : NSObject
    
    @property (assign, nonatomic) int age;
    @property (assign, nonatomic) int height;
    @end
    
    @implementation Person
    
    @end
    
    @interface ViewController ()
    
    @property (strong, nonatomic) Person *person1;
    @property (strong, nonatomic) Person *person2;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.person1 = [[Person alloc] init];
        self.person1.age = 1;
        
        self.person2 = [[Person alloc] init];
        self.person2.age = 2;
        
        // 打印添加监听之前person1和person2对应的isa指针指向的类型
        NSLog(@"person1添加KVO监听之前 - %@ %@",
              object_getClass(self.person1),
              object_getClass(self.person2)); 
        // 打印结果：Person Person
        
        // 打印添加监听之前person1和person2对应的setAge方法是否有改变
        NSLog(@"person1添加KVO监听之前 - %p %p",
              [self.person1 methodForSelector:@selector(setAge:)],
              [self.person2 methodForSelector:@selector(setAge:)]);
        // 0x10b60c4b0 0x10b60c4b0
              
        // 给person1对象添加KVO监听
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.person1 addObserver:self forKeyPath:@"age" options:options context:@"123"];
        
        // 打印添加监听之后person1和person2对应的isa指针指向的类型
        NSLog(@"person1添加KVO监听之后 - %@ %@",
              object_getClass(self.person1),
              object_getClass(self.person2)); 
    	// 打印结果：NSKVONotifying_Person Person
    	
    	 // 打印添加监听之后person1和person2对应的setAge方法是否有改变
        NSLog(@"person1添加KVO监听之前 - %p %p",
              [self.person1 methodForSelector:@selector(setAge:)],
              [self.person2 methodForSelector:@selector(setAge:)]);
        // 0x7fff207b62b7 0x10b60c4b0
    }
    
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {
        self.person1.age = 20;    
    }
    
    - (void)dealloc {
        [self.person1 removeObserver:self forKeyPath:@"age"];
    }
    
    // 当监听对象的属性值发生改变时，就会调用
    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
    {
        NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
    }
    
    @end 
    复制代码

**注意：**  监听的对象销毁之前要移除该监听`removeObserver: forKeyPath:`

二、KVO的实现本质
==========

1.通过上面示例代码发现，函数在调用`addObserver: forKeyPath:`方法之后，`person1`的实例对象的`isa指针`指向了一个新的类型`NSKVONotifying_Person`，而没有添加监听的`person2`的`isa指针`还是指向了`Person`这个类型

2.我们发现通过`object_getClass`打印`person1`的类对象和元类对象都是新派生出来的`NSKVONotifying_Person`这个类型

    NSLog(@"类对象 - %@ %@",
              object_getClass(self.person1), 
              object_getClass(self.person2)); 
    // NSKVONotifying_Person Person
    
    NSLog(@"元类对象 - %@ %@",
              object_getClass(object_getClass(self.person1)), 
              object_getClass(object_getClass(self.person2))); 
    // NSKVONotifying_Person Person
     
    复制代码

3.我们发现通过`object_getClass`打印`person1`的`superclass`是`Person`这个类型，说明新派生出来的`NSKVONotifying_Person`是`Person`的子类

    NSLog(@"父类 - %@ %@", 
    		object_getClass(self.person1).superclass,
            object_getClass(self.person2).superclass);
            // Person NSObject
    复制代码

4.通过打印我们发现，`person1`调用的`setAge`方法的内存地址发生了改变，通过`LLDB`打印该地址的详细信息发现`setAge`方法的实现实际是`Foundation框架`中的`_NSSetIntValueAndNotify`这个函数

    (lldb) p (IMP)0x7fff207b62b7
    (IMP) $2 = 0x00007fff207b62b7 (Foundation`_NSSetIntValueAndNotify)
    (lldb) p (IMP) 0x108801480
    (IMP) $3 = 0x0000000108801480 (Interview01`-[Person setAge:] at Person.m:13)
    复制代码

5.我们手动创建这个派生类型`NSKVONotifying_Person`，并且在Person里面重写`setAge:、willChangeValueForKey:、didChangeValueForKey:`这三个方法，运行程序并观察调用情况

    @interface NSKVONotifying_Person : Person
    
    @end
    
    @implementation NSKVONotifying_Person
    
    @end
    
    
    @interface Person : NSObject
    
    @property (assign, nonatomic) int age;
    @property (assign, nonatomic) int height;
    @end
    
    @implementation Person
    
    - (void)setAge:(int)age
    {
        _age = age;
        
        NSLog(@"setAge:");
    }
    
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
    复制代码

由此可见，当监听的属性发生改变，系统派生出的这个类`NSKVONotifying_Person`(在)会对应的先后调用

*   `willChangeValueForKey:`
*   `setAge:`
*   `didChangeValueForKey:` 这三个方法，并在`didChangeValueForKey:`里调用观察者的`observeValueForKeyPath: ofObject: change:`来通知值属性值的变化

    // 执行后打印
    2021-01-19 13:42:02.071987+0800 Interview01[37119:19609444] willChangeValueForKey
    2021-01-19 13:42:02.072192+0800 Interview01[37119:19609444] setAge:
    2021-01-19 13:42:02.072332+0800 Interview01[37119:19609444] didChangeValueForKey - begin
    2021-01-19 13:42:02.072662+0800 Interview01[37119:19609444] 监听到<Person: 0x6000036ac2c0>的age属性值改变了 - {
        kind = 1;
        new = 21;
        old = 1;
    } - 123
    2021-01-19 13:42:02.072817+0800 Interview01[37119:19609444] didChangeValueForKey - end
    复制代码

6.通过`class方法`打印`person1`的类发现还是`Person`这个类型，说明在派生出的这个类`NSKVONotifying_Person`内部重写了`class`方法，并返回的是`Person`这个类型。所以只能通过`object_getClass`才能获取到真实的类型

    NSLog(@"%@ %@",
              [self.person1 class], 
              [self.person2 class]); 
    // Person Person
    
    NSLog(@"%@ %@",
              object_getClass(self.person1), 
              object_getClass(self.person2)); 
    // NSKVONotifying_Person Person
    复制代码

7.通过`Runtime`的`class_copyMethodList`函数查看`NSKVONotifying_Person`内部还动态生成了`dealloc、_isKVOA`这两个函数

    - (void)printMethodNamesOfClass:(Class)cls
    {
        unsigned int count;
        // 获得方法数组
        Method *methodList = class_copyMethodList(cls, &count);
        
        // 存储方法名
        NSMutableString *methodNames = [NSMutableString string];
        
        // 遍历所有的方法
        for (int i = 0; i < count; i++) {
            // 获得方法
            Method method = methodList[i];
            // 获得方法名
            NSString *methodName = NSStringFromSelector(method_getName(method));
            // 拼接方法名
            [methodNames appendString:methodName];
            [methodNames appendString:@", "];
        }
        
        // 释放
        free(methodList);
        
        // 打印方法名
        NSLog(@"%@ %@", cls, methodNames);
    }
    
    [self printMethodNamesOfClass:object_getClass(self.person1)];
    [self printMethodNamesOfClass:object_getClass(self.person2)];
    
    // 打印结果
    2021-01-19 15:38:13.552990+0800 Interview01[41940:19730538] NSKVONotifying_MJPerson setAge:, class, dealloc, _isKVOA,
    2021-01-19 15:38:13.553166+0800 Interview01[41940:19730538] MJPerson setAge:, age,
    复制代码

三、总结
====

**通过上面一系列操作可以汇总为：**

*   利用`RuntimeAPI`动态生成一个子类，并且让`instance对象`的`isa`指向这个全新的子类
*   全新的子类会重写`class`这个函数，并返回父类类型
*   在全新的子类里面会重写被监听的`成员对象/属性`的`setter`方法,当修改`instance对象`的属性时，会调用`Foundation`的`_NSSetXXXValueAndNotify函数`
*   *   函数内部首先调用`willChangeValueForKey:`
*   *   紧接着函数内部 调用父类原来的`setter`
*   *   最后调用`didChangeValueForKey:`
*   *   *   内部会触发监听器（Oberser）的监听方法 `observeValueForKeyPath:ofObject:change:context:`

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0383f5ab05324e50a84dc3fe6a72f00c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

四、KVO的应用场景
==========

*   1.监听`ScrollView`的偏移量，改变导航栏背景色
*   2.给`TextView`增加`placeHolder`，通过`KVO`监听文本是否输入对应隐藏展示`placeHolder`
*   ...

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