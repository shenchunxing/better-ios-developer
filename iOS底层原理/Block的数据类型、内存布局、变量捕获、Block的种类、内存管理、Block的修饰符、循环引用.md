# 【Block的数据类型(本质)与内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用】

前言
==

> 之前,我们在探索动画及渲染相关原理的时候,我们输出了几篇文章,解答了`iOS动画是如何渲染,特效是如何工作的疑惑`。我们深感系统设计者在创作这些系统框架的时候,是如此脑洞大开,也 **`深深意识到了解一门技术的底层原理对于从事该方面工作的重要性。`**
> 
> 因此我们决定 **`进一步探究iOS底层原理的任务`**。在这篇文章中我们围绕`Block`展开,会逐个探索:`Block对象类型(本质)与内存布局`、`变量捕获`、`Block的种类`、`Block的修饰符`、`内存管理`、`循环引用`

一、Block的基本语法和使用介绍
=================

在探索Block的底层原理之前,我们需要先回顾一下Block在日常开发中的使用和相关的语法。可以通过我之前发表的这篇文章进行温故知新:[Block的基本语法和使用介绍](https://juejin.cn/post/7115572801490124837/ "https://juejin.cn/post/7115572801490124837/")

二、探索block的本质
============

1\. 一个简单的Block
--------------

首先写一个简单的block,将其转换成C++伪代码,查看一下其内部结构:

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            int age = 10;
            void(^block)(int ,int) = ^(int a, int b){
                NSLog(@"this is block,a = %d,b = %d",a,b);
                NSLog(@"this is block,age = %d",age);
            };
            block(3,5);
        }
        return 0;
    }
    
    复制代码

使用命令行将代码转化为c++查看其内部结构，与OC代码进行比较

    xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m
    复制代码

![c++与oc代码对比](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/744491e8db834ba1bb040a543c4eb9a9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中将c++中block的声明和定义分别与oc代码中相对应显示。  
将c++中block的声明和调用分别取出来查看其内部实现。

### 1.1 定义block变量

    // 定义block变量代码
    void(*block)(int ,int) = ((void (*)(int, int))&__main_block_impl_0(
    (void *)__main_block_func_0, 
    &__main_block_desc_0_DATA, age)
    );
    复制代码

*   **一个函数:**
    *   上述定义代码中，可以发现，block定义中调用了`__main_block_impl_0`函数
    *   并且将`__main_block_impl_0`函数的地址赋值给了`block`

那么我们来看一下`__main_block_impl_0`函数内部结构。

### 1.2 `__main_block_imp_0`结构体

![__main_block_imp_0结构体](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/725c9f42c2734f32947ba14c38061031~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   **构造函数:**
    *   `__main_block_imp_0`**结构体**内有一个同名构造函数\_\_main\_block\_imp\_0
    *   构造函数中对一些变量进行了赋值最终会返回一个结构体

那么也就是说最终将一个`__main_block_imp_0`结构体的**内存地址**赋值给了`block变量`

*   **构造函数的`参数`:**
    *   `__main_block_impl_0构造函数`中传入了四个参数:
        *   (void \*)\_\_main\_block\_func\_0
        *   &\_\_main\_block\_desc\_0\_DATA
        *   age
        *   flags
            *   其中flage有默认值，也就说flage参数在调用的时候可以省略不传。
            *   而最后的 age(\_age)则表示传入的\_age参数会自动赋值给age成员，相当于**age = \_age**

接下来着重看一下前面三个参数分别代表什么。

#### 1.2.1 第一个参数:`(void *)__main_block_func_0`

![__main_block_func_0](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b650ee1517f94b3ca33c14c2527f0e83~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**从代码中我们可以看到:**

*   在`__main_block_func_0`函数中首先取出`block`中`age`的值
*   紧接着可以看到两个熟悉的`NSLog`
*   我们不难发现这**两段代码恰恰是我们在block块中写下的代码**。
*   我们不难得出结论：
    *   `__main_block_func_0函数`中其实`存储着我们在block中写下的代码`
    *   而\_`_main_block_impl_0函数`中传入的是`(void *)__main_block_func_0`
        *   也就说将我们写在`block块中的代码`封装成`__main_block_func_0函数`
        *   并将`__main_block_func_0函数的地址`传入了`__main_block_impl_0的构造函数`中**保存在结构体内**

#### 1.2.2 第二个参数: `&__main_block_desc_0_DATA`

![&__main_block_desc_0_DATA](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8e313cba50844db29d4c1485dc63ad88~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从代码中我们可以看到:

*   `__main_block_desc_0`中存储着两个参数:`reserved`和`Block_size`
*   并且`reserved默认赋值为0`
*   而`Block_size`则存储着`__main_block_impl_0`的`占用空间大小`
*   最终将`__main_block_desc_0`结构体的地址传入`__main_block_impl_0的构造函数`中赋值给`Desc`

#### 1.2.3 第三个参数:`age`

**age是我们前面定义的局部变量**

我们可以先敲一段代码做一个简单的尝试

    int age = 10;
    void(^block)(int ,int) = ^(int a, int b){
         NSLog(@"this is block,a = %d,b = %d",a,b);
         NSLog(@"this is block,age = %d",age);
    };
    age = 20;
    block(3,5); 
    // log: this is block,a = 3,b = 5
    //      this is block,age = 10
    
    复制代码

**打印结果:**

*   通过打印结果,我们发现,在Block内部打印的`age`是在它被重新赋值之前,也就是`Block定义之前的旧值`**10**

**值传递:**

*   我们前面将OC代码 通过 命令行编译 成C++之后的代码中我们也可以看到,传如Block中的age是 **`值传递`** ![__main_block_imp_0结构体](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/725c9f42c2734f32947ba14c38061031~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   且,经过前面的简单尝试,我们也不难得出结论:这里Block捕获到的值,是在**Block定义代码中,第一次编译之后就确认了** **地址传递:**
*   而另外两个参数:`(void *)__main_block_func_0`、`&__main_block_desc_0_DATA`,都是地址传递
*   通过地址传递,在被调用时候,才有寻址操作

因此在**block定义之后**`对局部变量进行改变是无法被block捕获的`。

### 1.3 进一步查看`__main_block_impl_0结构体`

![__main_block_impl_0结构体](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/671450b32c214a1087b0dcddcdd9ec0d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

#### 1.3.1 第一个成员:`__block_impl结构体`

首先我们看一下`__main_block_impl_0结构体`的第一个成员变量`__block_impl结构体`：

![__block_impl结构体内部](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e278dc69f6304bdaa3711077c2686504~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**通过代码我们不难发现:**

*   **`isa指针`**:
    *   `__block_impl结构体`内部就有一个`isa指针`
    *   因此可以证明 **`block本质上就是一个oc对象`**
    *   而通过构造函数初始化的`__main_block_impl_0`结构体实例的内存地址赋值给`block变量`
        *   通过`block变量`的指针指向的地址(也就是)`__main_block_impl_0`实例的地址,可以拿到 结构体中的 第一个成员 `__block_impl`的地址
        *   进而去获取内部的 `isa指针`、`FuncPtr`等进行操作

#### 1.3.2 第二个成员:`__main_block_desc_0结构体`

我们在前面 **1.2.2** `&__main_block_desc_0_DATA` 中已经 探索过该结构体: ![&__main_block_desc_0_DATA](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8e313cba50844db29d4c1485dc63ad88~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   `__main_block_desc_0`中存储着两个参数:`reserved`和`Block_size`
*   并且`reserved默认赋值为0`
*   而`Block_size`则存储着`__main_block_impl_0`的`占用空间大小`
*   最终将`__main_block_desc_0`结构体的地址传入`__main_block_impl_0的构造函数`中赋值给`Desc`

### 1.4 总结

通过前面的探索,我们可以得出结论：

*   1.  **Block的本质:**
    
    *   `__block_impl`结构体中`isa指针`,我们前面探索[OC对象的本质](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012"),知道,每一个继承自NSObject的对象,都有`isa指针`
    *   **因此Block本质上是一个OC对象**
    *   我们通过简单打印调试,可以看到此时的Block的具体类型为`_NSConcreteStackBlock类型`
*   2.  **Block的执行函数:**
    
    *   `block代码块`中的代码被封装成`__main_block_func_0`函数
    *   `FuncPtr`则存储着`__main_block_func_0`函数的地址。
*   3.  **对象内存:**
    
    *   `Desc`指向`__main_block_desc_0`结构体对象，其中存储`__main_block_impl_0`结构体所占用的内存。

2.调用block执行内部代码
---------------

    // 执行block内部的代码
    ((void (*)(__block_impl *, int, int))((__block_impl *)block)->FuncPtr)
                                          ((__block_impl *)block,
                                                             3, 
                                                            5);
    
    复制代码

**结构体的指针:**

*   通过上述代码可以发现调用block是通过block找到FunPtr直接调用
*   通过前面的分析我们知道block指向的是`__main_block_impl_0`类型结构体
*   但是我们发现\_`_main_block_impl_0`结构体中并不能直接找到`FunPtr`(`FunPtr`是存储在`__block_impl`中的
*   **那么为什么block可以直接调用\_\_block\_impl中的FunPtr呢？**
    *   重新查看上述源代码可以发现:
        
        *   **类型强转:** `(__block_impl *)block`将block强制转化为`__block_impl类型`
        *   **结构体的第一个成员:** 又因为`__block_impl`是`__main_block_impl_0`结构体的第一个成员(**结构体本身的内存地址,就是指向其内部第一个成员的地址。这是C语言中指针的知识**)
        *   所以可以根据类型强转后拿到的内存地址,找到FunPtr成员并执行
    *   从前面的分析我们知道，`FunPtr`中存储着通过代码块封装的代码的函数地址，那么调用此函数，也就是会执行代码块中的代码。
        
    *   并且回头查看`__main_block_func_0`函数，可以发现第一个参数就是`__main_block_impl_0`类型的指针。也就是说将`block`传入`__main_block_func_0`函数中，便于重中取出block捕获的值。
        

3\. 如何验证block的本质确实是\_\_main\_block\_impl\_0结构体类型。
-------------------------------------------------

我们可以通过手写与之相似的结构体代码,并在OC代码中,对Block进行类型强转。  
进而通过调用类型强转之后的结构体对象,查看一下打印结果,看看是否能够跟以往OC代码中的Block一样调用代码块中,且给出一样的 打印结果

    struct __main_block_desc_0 { 
        size_t reserved;
        size_t Block_size;
    };
    struct __block_impl {
        void *isa;
        int Flags;
        int Reserved;
        void *FuncPtr;
    };
    // 模仿系统__main_block_impl_0结构体
    struct __main_block_impl_0 { 
        struct __block_impl impl;
        struct __main_block_desc_0* Desc;
        int age;
    };
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            int age = 10;
            void(^block)(int ,int) = ^(int a, int b){
                NSLog(@"this is block,a = %d,b = %d",a,b);
                NSLog(@"this is block,age = %d",age);
            };
    // 将底层的结构体强制转化为我们自己写的结构体，通过我们自定义的结构体探寻block底层结构体
            struct __main_block_impl_0 *blockStruct = (__bridge struct __main_block_impl_0 *)block;
            block(3,5);
        }
        return 0;
    }
    
    复制代码

通过代码证明：我们将block内部的结构体强制转化为自定义的结构体，转化成功说明底层结构体确实如我们之前分析结果的一样。

通过打断点可以看出我们自定义的结构体可以被赋值成功，以及里面的值。

![blockStruct](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/669ad8f685a74ecf834d52c3439ed18b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

接下来断点来到block代码块中，看一下堆栈信息中的函数调用地址。Debuf workflow -> always show Disassembly

![Debuf workflow -> always show Disassembly](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d35db41ae03f4e74990282688a210620~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上图可以看到地址确实和FuncPtr中的代码块地址一样。

4.总结
----

此时已经基本对block的底层结构有了基本的认识，上述代码可以通过一张图展示其中各个结构体之间的关系。

*   各个结构体之间的关系 ![图示block结构体内部之间的关系](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd807bd1d3e942309ac37ad2c781e997~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   block底层的数据结构
    *   block底层的数据结构也可以通过一张图来展示: ![block底层的数据结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f671fe4e03d24a0cbd1eaf1c7d027a2a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   对block有一个基本的认识:
    *   **block本质上也是一个oc对象**，ta内部也有一个isa指针
    *   block是封装了函数调用以及函数调用环境的OC对象(Block可能会读外部的值有捕获)

三、Block对变量的捕获
=============

我们在前面的篇幅中,得知Block对变量 可能存在 值捕获 的现象。那么我们顺着这个思路进一步探索 Block对变量 捕获的原理

为了保证block内部能够正常访问外部的变量，block有一个变量捕获机制。

1\. 局部变量
--------

### 1.1 auto变量

在OC中,局部变量的类型 本质上就是`auto变量`

我们在前面的篇幅中已经了解过block`对局部变量age的捕获`

**我们得出了结论:**

*   `auto自动变量`，离开作用域就销毁，通常局部变量前面自动添加auto关键字。
*   `自动变量的值`会被捕获到block内部，也就是说block内部会专门新增加一个参数来存储变量的值。
*   `值传递:` auto只存在于局部变量中，访问方式为值传递，通过前面篇幅的探索我们也可以确定对auto变量age的捕获 确实是值传递。

### 1.2 static变量

接下来分别添加aotu修饰的局部变量和static修饰的局部变量，重看源码来看一下他们之间的差别。

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            auto int a = 10;
            static int b = 11;
            void(^block)(void) = ^{
                NSLog(@"hello, a = %d, b = %d", a,b);
            };
            a = 1;
            b = 2;
            block();
        }
        return 0;
    }
    // log : block本质[57465:18555229] hello, a = 10, b = 2
    // block中a的值没有被改变而b的值随外部变化而变化。
    
    复制代码

重新生成c++代码看一下内部结构中两个参数的区别:

![局部变量c++代码](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dd8fd74d063f45d59d67c8bfb426316d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**从代码中我们不难看出看出:**

*   a,b两个变量都有捕获到block内部
*   但是`a传入的是值`，而`b传入的则是地址`

**为什么两种变量会有这种差异呢?**

*   因为自动变量可能会销毁，block在执行的时候有可能自动变量已经被销毁了，那么此时如果再去访问被销毁的地址肯定会发生坏内存访问，因此对于自动变量一定是值传递而不可能是指针传递了。
*   而静态变量不会被销毁，所以完全可以传递地址。而因为传递的是值得地址，所以在block调用之前修改地址中保存的值，block中的地址是不会变得。所以值会随之改变。

**结论:**

*   **`指针传递:`** static 修饰的变量为指针传递，同样会被block捕获。

2\. 全局变量
--------

我们同样以代码的方式看一下block是否捕获全局变量

    int a = 10;
    static int b = 11;
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            void(^block)(void) = ^{
                NSLog(@"hello, a = %d, b = %d", a,b);
            };
            a = 1;
            b = 2;
            block();
        }
        return 0;
    }
    // log hello, a = 1, b = 2
    
    复制代码

同样生成c++代码查看**全局变量**调用方式:

![全局变量c++代码](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cd01195885b24e81a2ef56c9d3256cd9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上述代码可以发现，`__main_block_imp_0`并没有添加任何变量，因此`block不需要捕获全局变量`，因为**全局变量无论在哪里都可以被访问**。

**局部变量因为跨函数访问所以需要捕获，全局变量在哪里都可以访问 ，所以不用捕获。**

3\. 总结
------

![block的变量捕获](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/793acbd09fd946f3b9064bb338c894a6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   **局部变量:** `都会被block捕获`
    *   自动变量是值捕获
    *   静态变量为地址捕获
*   **全局变量:** 全局变量则不会被block捕获

4.疑问：以下代码中block是否会捕获变量呢？
------------------------

    #import "Person.h"
    @implementation Person
    - (void)test
    {
        void(^block)(void) = ^{
            NSLog(@"%@",self);
        };
        block();
    }
    - (instancetype)initWithName:(NSString *)name
    {
        if (self = [super init]) {
            self.name = name;
        }
        return self;
    }
    + (void) test2
    {
        NSLog(@"类方法test2");
    }
    @end
    
    复制代码

同样转化为c++代码查看其内部结构

![c++代码](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4351ff23a3f2483a989740cefb561d86~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从代码中,我们不难发现:

*   self同样被block捕获
*   接着我们找到test方法可以发现，test方法默认传递了两个参数self和\_cmd
*   而类方法test2也同样默认传递了类对象self和方法选择器\_cmd ![对象方法和类方法对比](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/374ac06ba845439e8d45d6d4c6f8c92b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

不论对象方法还是类方法都会默认将self作为参数传递给方法内部，既然是作为参数传入，那么self肯定是局部变量。上面讲到局部变量肯定会被block捕获。

接着我们来看一下如果在block中使用成员变量或者调用实例的属性会有什么不同的结果。

    - (void)test
    {
        void(^block)(void) = ^{
            NSLog(@"%@",self.name);
            NSLog(@"%@",_name);
        };
        block();
    }
    
    复制代码

![c++代码](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1aa46f2bc5254061bd29944c83b705ad~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中可以发现，即使block中使用的是实例对象的属性，block中捕获的仍然是实例对象，并通过实例对象通过不同的方式去获取使用到的属性。

四、Block的种类
==========

1\. block的class
---------------

> **block对象是什么类型的?**

在前面探索 block对auto变量age的时候,我们通过调试得出了结论:block中的`isa指针`指向的是`_NSConcreteStackBlock`类对象地址。

> **那么block是否就是\_NSConcreteStackBlock类型的呢？**

我们通过代码用class方法或者isa指针查看具体类型。

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            // __NSGlobalBlock__ : __NSGlobalBlock : NSBlock : NSObject
            void (^block)(void) = ^{
                NSLog(@"Hello");
            };
            
            NSLog(@"%@", [block class]);
            NSLog(@"%@", [[block class] superclass]);
            NSLog(@"%@", [[[block class] superclass] superclass]);
            NSLog(@"%@", [[[[block class] superclass] superclass] superclass]);
        }
        return 0;
    }
    
    复制代码

打印内容

![block的类型](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e995b8190cfd4256b0cc9968b76a1cf2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从上述打印内容可以看出：

*   block**最终都是继承自NSBlock类型**，而**NSBlock继承于NSObjcet**
*   那么block其中的`isa`指针其实是来自NSObject中的。我们在这一步进一步验证了block的本质就是OC对象

2\. 探索Block的类型
--------------

### 2.1 block的三种类型

我们首先手写三个block：

*   不捕获变量的Block
*   捕获变量的Block
*   匿名Block 通过代码查看一下block在什么情况下其类型会各不相同:

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            // 1. 内部没有调用外部变量的block
            void (^block1)(void) = ^{
                NSLog(@"Hello");
            };
            // 2. 内部调用外部变量的block
            int a = 10;
            void (^block2)(void) = ^{
                NSLog(@"Hello - %d",a);
            };
           // 3. 直接调用的block的class
            NSLog(@"%@ %@ %@", [block1 class], [block2 class], [^{
                NSLog(@"%d",a);
            } class]);
        }
        return 0;
    }
    
    复制代码

**打印结果:**

![block的三种类型](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fa1ebf025c9c4c1b870b7f0f1a9117e7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 我们不难发现出现了**三种类型的Block:**

    __NSGlobalBlock__ （ _NSConcreteGlobalBlock ）
    __NSStackBlock__ （ _NSConcreteStackBlock ）
    __NSMallocBlock__ （ _NSConcreteMallocBlock ）
    复制代码

*   但我们将上述代码转化为c++代码查看源码时却发现block的类型与打印出来的类型不一样
    *   c++源码中三个block的isa指针全部`都指向_NSConcreteStackBlock类型`地址。
*   我们可以猜测runtime运行时过程中也许对类型进行了转变
    *   最终类型当然`以runtime运行时类型`也就是我们打印出的类型为准。

五、Block的内存管理
============

1\. 了解程序的内存分区
-------------

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29080a43720c46188df21501ca19cbd2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   1.  代码区 code
        *   程序被操作系统加载到内存时，所有可执行的代码被加载到代码区，也叫代码段
        *   程序运行这段时间该区域数据不可被修改只可以被执行。
*   2.  静态区
    
    *   程序被加载到内存时就已经分配好，程序退出时才从内存中消失
    *   存储静态变量和全局变量。代码执行期间一直占用内存！
*   3.  栈区
    
    *   一种先进后出的存储结构，所有的自动变量（auto修饰的相当于局部变量）,函数的参数，函数的返回值都是栈区变量
    *   不需要用户申请释放，编译器自动完成。
*   4.  堆区 heap
    
    *   一个比较大的内存容器（比栈大），需要我们手动的申请和释放内存。
    *   在C语言中,堆区内存的使用函数：头文件#include <stdlib.h>
        *   1：malloc 申请堆区内存。 void \* malloc(size\_t size);
            
            *   size为申请的内存的字节数。申请的空间随机不会初始化， 所以不知道内部值是多少。
        *   2：free 释放申请的内存。 free(void \*ptr);
            
            *   只能释放你申请的内存，不然就会出错。
        *   3: calloc 申请堆区内存。 void \*calloc(size\_t nmemb, size\_t size);
            
            *   nmemb:指定单位的数量，size;单位的数量。
            *   例子：malloc(10\*sizeof(int)); == calloc(10,sizeof(int)); 区别：malloc申请的内存不负责初始化，而calloc申请的内存已经初始化为0.
        *   4：realloc 可以扩大之前申请的内存 void \*realloc(void \*ptr, size\_t size);
            
            *   ptr 要扩充的区域地址，size 扩充之后的大小。
                
            *   例子：char \*a=(char _)malloc(10_sizeof(char));//10个字节
                
            *   realloc(a,100);//增加为100个字节，也不会初始化。
                

2 探索Block对其类型的具体定义
------------------

因为在ARC环境中,编译器会帮我们管理内存,为了便于探索观察,我们可以先关闭ARC回到MRC环境下

    // MRC环境！！！
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            // Global：没有访问auto变量：__NSGlobalBlock__
            void (^block1)(void) = ^{
                NSLog(@"block1---------");
            };   
            // Stack：访问了auto变量： __NSStackBlock__
            int a = 10;
            void (^block2)(void) = ^{
                NSLog(@"block2---------%d", a);
            };
            NSLog(@"%@ %@", [block1 class], [block2 class]);
            // __NSStackBlock__调用copy ： __NSMallocBlock__
            NSLog(@"%@", [[block2 copy] class]);
        }
        return 0;
    }
    
    复制代码

查看打印内容

![block类型](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/63022d41bb3f49c09a1803a49cf0b907~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过打印的结果我们不难得知:

*   **`__NSGlobalBlock__`:**
    *   没有访问auto变量的block是`__NSGlobalBlock__`类型的，存放在数据段中(代码区)
*   **`__NSStackBlock__`:**
    *   访问了auto变量的block是`__NSStackBlock__`类型的，存放在栈中
*   **`__NSMallocBlock__`:**
    *   `__NSStackBlock__`类型的block调用copy成为`__NSMallocBlock__`类型并被复制存放在堆中
*   ps:对于不同Block存在在那块内存区域,需要根据打印其对象地址 且打断点 结合 查看汇编 中呈现 的 不同 内存区域的 地址进行比对 做适量推测。此处的结论 参考 自 《Effective-ObjectiveC》一书

block是如何定义其类型，依据什么来为block定义不同的类型并分配在不同的空间呢？首先看下面一张图

![block是如何定义其类型](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/953534c363a74b97bf25f18779ea1f02~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3\. block在内存中的存储
----------------

通过下面一张图看一下不同block的存放区域 ![不同类型block的存放区域](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4d8e44fc13b44ec4ba3739f3f38703b5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中可以发现，根据block的类型不同，block存放在不同的区域中。 数据段中的`__NSGlobalBlock__`直到程序结束才会被回收，不过我们很少使用到`__NSGlobalBlock__`类型的block，因为这样使用block并没有什么意义。

`__NSStackBlock__`类型的block存放在栈中，我们知道栈中的内存由系统自动分配和释放，作用域执行完毕之后就会被立即释放，而在相同的作用域中定义block并且调用block似乎也多此一举。

`__NSMallocBlock__`是在平时编码过程中最常使用到的。存放在堆中需要我们自己进行内存管理。 上面提到过`__NSGlobalBlock__`类型的我们很少使用到，因为如果不需要访问外界的变量，直接通过函数实现就可以了，不需要使用block。

但是`__NSStackBlock__`访问了aotu变量，并且是存放在栈中的，上面提到过，栈中的代码在作用域结束之后内存就会被销毁，那么我们很有可能block内存销毁之后才去调用他，那样就会发生问题，通过下面代码可以证实这个问题。

    void (^block)(void);
    void test()
    {
        // __NSStackBlock__
        int a = 10;
        block = ^{
            NSLog(@"block---------%d", a);
        };
    }
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            test();
            block();
        }
        return 0;
    }
    
    复制代码

此时查看打印内容

![打印内容](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9220971a6a1e455ea112b7160335849c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**可以发现a的值变为了不可控的一个数字。为什么会发生这种情况呢？**

因为上述代码中创建的block是`__NSStackBlock__`类型的，因此block是存储在栈中的，那么当test函数执行完毕之后，栈内存中block所占用的内存已经被系统回收，因此原来的就有可能出现。查看其c++代码可以更清楚的理解。

![c++代码](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a409a23ab29746948cf9861aeb8d2a70~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

为了避免这种情况发生，可以`通过copy`将`__NSStackBlock__`类型的block转化为`__NSMallocBlock__`类型的block，将block存储在堆中，以下是修改后的代码。

    void (^block)(void);
    void test()
    {
        // __NSStackBlock__ 调用copy 转化为__NSMallocBlock__
        int age = 10;
        block = [^{
            NSLog(@"block---------%d", age);
        } copy];
        [block release];
    }
    
    复制代码

此时在打印就会发现数据正确

![打印内容](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3f2dd87fc49a4d4695cb9fbc326095c4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

那么其他类型的block调用copy会改变block类型吗？下面表格已经展示的很清晰了。

![不同类型调用copy效果](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/76973dff0d274c03b6d86106d058a9d6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

所以在平时开发过程中:

*   MRC环境下经常需要使用copy来保存block，将栈上的block拷贝到堆中，即使栈上的block被销毁，堆上的block也不会被销毁，需要我们自己调用release操作来销毁
*   而在ARC环境下系统会自动调用copy操作，使block不会被销毁

4.ARC帮我们做了什么
------------

在ARC环境下，编译器会根据情况自动将栈上的block进行一次copy操作，将block复制到堆上。

**什么情况下ARC会自动将block进行一次copy操作？** 以下代码都在RAC环境下执行。

### 1\. block作为函数返回值时

    typedef void (^Block)(void);
    Block myblock()
    {
        int a = 10;
        // 前面探索时提到过，block中访问了auto变量，此时block类型应为__NSStackBlock__
        Block block = ^{
            NSLog(@"---------%d", a);
        };
        return block;
    }
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            Block block = myblock();
            block();
           // 打印block类型为 __NSMallocBlock__
            NSLog(@"%@",[block class]);
        }
        return 0;
    }
    
    复制代码

**看一下打印的内容:**

![打印内容](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/81d91f8b9a4f4d40bd3da83af232f3d2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   在前面篇幅探索过程中得出一个结论:**在block中访问了auto变量时，block的类型为`__NSStackBlock__`**
*   上面打印结果却显示**blcok为`__NSMallocBlock__`类型的**，**并且可以正常打印出a的值**，说明block内存并没有被销毁
*   在前面篇幅探索过程中也得出一个结论: **`__NSStackBlock__类型的block`** 进行copy操作会转化为`__NSMallocBlock__`类型
*   那么说明ARC环境中，当block作为函数返回值时会自动帮助我们对block进行copy操作，并保存block的内存，并在适当的地方进行release操作。

### 2\. 将block赋值给\_\_strong指针时

block被强指针引用时，ARC环境下 编译器也会自动对block进行一次copy操作。

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            // block内没有访问auto变量
            Block block = ^{
                NSLog(@"block---------");
            };
            NSLog(@"%@",[block class]);
            int a = 10;
            // block内访问了auto变量，但没有赋值给__strong指针
            NSLog(@"%@",[^{
                NSLog(@"block1---------%d", a);
            } class]);
            // block赋值给__strong指针(通过一个类型来构造定义一个对象,默认是__strong指针)
            Block block2 = ^{
              NSLog(@"block2---------%d", a);
            };
            NSLog(@"%@",[block1 class]);
        }
        return 0;
    }
    
    复制代码

查看打印内容可以看出，当block被赋值给`__strong`指针时，在ARC会环境下自动进行一次copy操作。

![打印内容](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/afd81cec17b34994bf6f013f9a65b1b6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 3\. block作为Cocoa API中方法名含有usingBlock的方法参数时

例如：遍历数组的block方法，将block作为参数的时候。

    NSArray *array = @[];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
    }];
    
    复制代码

### 4\. block作为GCD API的方法参数时

例如：GDC的一次性函数或延迟执行的函数，执行完block操作之后系统才会对block进行release操作。

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
                
    });        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
    });
    
    复制代码

5.block声明写法
-----------

通过上面对MRC及ARC环境下block的不同类型的分析，总结出不同环境下block属性建议写法。

MRC下block属性的建议写法

**`@property (copy, nonatomic) void (^block)(void);`**

ARC下block属性的建议写法

**`@property (strong, nonatomic) void (^block)(void);`** **`@property (copy, nonatomic) void (^block)(void);`**

六、Block的修饰符
===========

1\. `__weak`修饰
--------------

*   如下代码

    // 定义block
    typedef void (^HPBlock)(void);
    
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            
            HPBlock block;
            
            {
                HPPerson *person = [[HPPerson alloc]init];
                person.age = 10;
    
                __weak HPPerson *weakPerson = person;
                
                block = ^{
                    NSLog(@"---------%d", weakPerson.age);
                };
                
                 NSLog(@"block.class = %@",[block class]);
            }
           
            NSLog(@"block销毁");
        }
        return 0;
    }
    
    复制代码

*   输出为

    iOS-block[3687:42147] block.class = __NSMallocBlock__
    iOS-block[3687:42147] -[HPPerson dealloc]
    iOS-block[3687:42147] block销毁
    复制代码

我们将代码转换成cpp伪代码查看下:

注意：

*   在使用clang转换OC为C++代码时，可能会遇到以下问题 `cannot create __weak reference in file using manual reference`
*   解决方案：支持ARC、指定运行时系统版本，比如 `xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-8.0.0 main.m`

生成之后，可以看到，如下代码，MRC情况下，生成的代码明显多了,这是因为ARC自动进行了copy操作

     //copy 函数
      void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*); 
      //dispose函数
      void (*dispose)(struct __main_block_impl_0*); 
    复制代码

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      //weak修饰
       HPPerson *__weak weakPerson;
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, HPPerson *__weak _weakPerson, int flags=0) : weakPerson(_weakPerson) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    
    
    static struct __main_block_desc_0 {
      size_t reserved;
      size_t Block_size;
      //copy 函数
      void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
      
      //dispose函数
      void (*dispose)(struct __main_block_impl_0*);
    } __main_block_desc_0_DATA = {
     0, 
     sizeof(struct __main_block_impl_0),
      __main_block_copy_0,
       __main_block_dispose_0
    };
    
    
    //copy函数内部会调用_Block_object_assign函数
    static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    
    //asssgin会对对象进行强引用或者弱引用
    _Block_object_assign((void*)&dst->person, 
    (void*)src->person, 
    3/*BLOCK_FIELD_IS_OBJECT*/);
    }
    
    //dispose函数内部会调用_Block_object_dispose函数
    static void __main_block_dispose_0(struct __main_block_impl_0*src) {
    _Block_object_dispose((void*)src->person, 
    3/*BLOCK_FIELD_IS_OBJECT*/);
    }
    
    
    复制代码

### 1.1 小结

无论是MRC还是ARC  
当block内部访问了对象类型的`auto`变量时:

*   如果block在栈上（即当block为`__NSStackBlock__`类型时候），将不会`auto变量`进行强引用
*   如果block被拷贝在堆上(即当block为`__NSMallocBlock__`类型时候）
    *   会调用block内部的copy函数
    *   copy函数内部会调用`_Block_object_assign`函数
    *   `_Block_object_assign`函数会根据`auto变量`的修饰符是`__strong`、`__weak`、`__unsafe_unretained`做出相应的操作,形成强引用(`retain`)或者弱引用。
*   如果block从堆上移除
    *   会调用block内部的dispose函数
    *   dispose函数内部会调用`_Block_object_dispose`函数
    *   `_Block_object_dispose`函数会自动释放引用的auto变量（release） 其实也很好理解，因为block本身就在栈上，自己都随时可能消失，怎么能保住别人的命呢？

函数

调用时机

copy函数

栈上的Block复制到堆上

dispose函数

堆上的block被废弃时

2.`__block`修饰符
--------------

先从一个简单的例子说起，请看下面的代码

    // 定义block
    typedef void (^HPBlock)(void);
    
    int age = 10;
    HPBlock block = ^{
        NSLog(@"age = %d", age);
    };
    block();
    
    复制代码

代码很简单，运行之后，输出

> age = 10

上面的例子在block中访问外部局部变量，那么问题来了，如果想在block内修改外部局部的值，怎么做呢？

### 2.1 修改局部变量的三种方法

#### 2.1.1 写成全局变量

我们把a定义为全局变量，那么在哪里都可以访问，

    // 定义block
    typedef void (^YZBlock)(void);
     int age = 10;
    
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            
            YZBlock block = ^{
                age = 20;
                NSLog(@"block内部修改之后age = %d", age);
            };
            
            block();
            NSLog(@"block调用完 age = %d", age);
        }
        return 0;
    }
    
    复制代码

这个很简单，输出结果为

    block内部修改之后age = 20
    block调用完 age = 20
    
    复制代码

对于输出就结果也没什么问题，因为全局变量，是所有地方都可访问的，在block内部可以直接操作age的内存地址的。调用完block之后，全局变量age指向的地址的值已经被更改为20，所以是上面的打印结果

#### 2.1.2 static修改局部变量

    // 定义block
    typedef void (^HPBlock)(void);
    
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
           static int age = 10;
            HPBlock block = ^{
                age = 20;
                NSLog(@"block内部修改之后age = %d", age);
            }; 
            block();
            NSLog(@"block调用完 age = %d", age);
        }
        return 0;
    } 
    复制代码

上面的代码输出结果为

    block内部修改之后age = 20
    block调用完 age = 20
    复制代码

终端执行这行指令`xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m`把`main.m`生成`main.cpp` 可以 看到如下代码

    struct __main_block_impl_0 {
        struct __block_impl impl;
        struct __main_block_desc_0* Desc;
        int *age;
        __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_age, int flags=0) : age(_age) {
            impl.isa = &_NSConcreteStackBlock;
            impl.Flags = flags;
            impl.FuncPtr = fp;
            Desc = desc;
        }
    };
    
    static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
        int *age = __cself->age; // bound by copy
        
        (*age) = 20;
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_x4_920c4yq936b63mvtj4wmb32m0000gn_T_main_5dbaa1_mi_0, (*age));
    }
    复制代码

可以看出，当局部变量用`static`修饰之后，这个block内部会有个成员是`int *age`，也就是说把age的地址捕获了。这样的话，当然在block内部可以修改局部变量age了。

*   以上两种方法，虽然可以达到在block内部修改局部变量的目的，但是，这样做，会导致内存无法释放。
    *   无论是全局变量，还是用static修饰，都无法及时销毁，会一直存在内存中。
    *   很多时候，我们只是需要临时用一下，当不用的时候，能销毁掉，那么第三种，也就是今天的主角 `__block`

### 2.2 `__block`来修饰

代码如下

    // 定义block
    typedef void (^HPBlock)(void); 
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            __block int age = 10;
            HPBlock block = ^{
                age = 20;
                NSLog(@"block内部修改之后age = %d",age);
            };
            
            block();
            NSLog(@"block调用完 age = %d",age);
        }
        return 0;
    } 
    复制代码

输出结果和上面两种一样

    block内部修改之后age = 20
    block调用完 age = 20
    复制代码

#### 2.2.1 `__block`分析

*   终端执行这行指令`xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m`把`main.m`生成`main.cpp`

首先能发现 多了`__Block_byref_age_0`结构体

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
        // 这里多了__Block_byref_age_0类型的结构体
      __Block_byref_age_0 *age; // by ref
        // fp是函数地址  desc是描述信息  __Block_byref_age_0 类型的结构体  *_age  flags标记
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_age_0 *_age, int flags=0) : age(_age->__forwarding) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp; //fp是函数地址
        Desc = desc;
      }
    };
    
    
    
    复制代码

再仔细看结构体`__Block_byref_age_0`，可以发现第一个成员变量是isa指针，第二个是指向自身的指针`__forwarding`

    
    // 结构体 __Block_byref_age_0
    struct __Block_byref_age_0 {
        void *__isa; //isa指针
        __Block_byref_age_0 *__forwarding; // 指向自身的指针
        int __flags;
        int __size;
        int age; //使用值
    };
    
    复制代码

查看main函数里面的代码

      // 这是原始的代码 __Block_byref_age_0
     __attribute__((__blocks__(byref))) __Block_byref_age_0 age = {
     (void*)0,(__Block_byref_age_0 *)&age, 0, sizeof(__Block_byref_age_0), 10};
            
                 
    // 这是原始的 block代码
    HPBlock block = ((void (*)())&__main_block_impl_0(
    (void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_age_0 *)&age, 570425344));
    
    
    复制代码

代码太长，简化一下，去掉一些强转的代码，结果如下

    
    // 这是原始的代码 __Block_byref_age_0
    __attribute__((__blocks__(byref))) __Block_byref_age_0 age = {(void*)0,(__Block_byref_age_0 *)&age, 0, sizeof(__Block_byref_age_0), 10};
            
    //这是简化之后的代码 __Block_byref_age_0
    __Block_byref_age_0 age = {
         0, //赋值给 __isa
         (__Block_byref_age_0 *)&age,//赋值给 __forwarding,也就是自身的指针
          0, // 赋值给__flags
          sizeof(__Block_byref_age_0),//赋值给 __size
          10 // age 使用值
        };
            
    // 这是原始的 block代码
    HPBlock block = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_age_0 *)&age, 570425344));
            
    // 这是简化之后的 block代码
    HPBlock block = (&__main_block_impl_0(
                 		__main_block_func_0,
               		&__main_block_desc_0_DATA,
    	           	 &age,
                	570425344));
            
     ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
            //简化为
    block->FuncPtr(block);
    
    
    复制代码

其中`__Block_byref_age_0`结构体中的第二个`(__Block_byref_age_0 *)&age`赋值给上面代码结构体`__Block_byref_age_0`中的第二个`__Block_byref_age_0 *__forwarding`,所以`__forwarding` 里面存放的是指向自身的指针

    //这是简化之后的代码 __Block_byref_age_0
    __Block_byref_age_0 age = {
         0, //赋值给 __isa
         (__Block_byref_age_0 *)&age,//赋值给 __forwarding,也就是自身的指针
          0, // 赋值给__flags
          sizeof(__Block_byref_age_0),//赋值给 __size
          10 // age 使用值
        };
    
    复制代码

结构体`__Block_byref_age_0`中代码如下，第二个`__forwarding`存放指向自身的指针,第五个`age`里面存放局部变量

    // 结构体 __Block_byref_age_0
    struct __Block_byref_age_0 {
        void *__isa; //isa指针
        __Block_byref_age_0 *__forwarding; // 指向自身的指针
        int __flags;
        int __size;
        int age; //使用值
    };
    
    复制代码

调用的时候，先通过`__forwarding`找到指针，然后去取出age值。

    (age->__forwarding->age)); 
    复制代码

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f17da6474554804ae403e4e3d8355e0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7bf1e780f89c4a97861eb28931aaf805~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

#### 2.2.2 \_\_block的内存管理

*   当block在栈上时，并不会对\_\_block变量产生强引用
*   当block被copy到堆时
    *   会调用block内部的copy函数
    *   copy函数内部会调用\_Block\_object\_assign函数
    *   \_Block\_object\_assign函数会根据所指向对象的修饰符（`__strong`、`__weak`、`__unsafe_unretained`）做出相应的操作，形成强引用（retain）或者弱引用（注意：这里仅限于ARC时会retain，MRC时不会retain）

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6d9a4585632d47c8ae452cbf6315cfa7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/957eb00a02cd4be696d8f544e5edc3a3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   当block从堆中移除时
    *   会调用block内部的dispose函数
    *   dispose函数内部会调用\_Block\_object\_dispose函数
    *   \_Block\_object\_dispose函数会自动释放引用的\_\_block变量（release）

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7fea421db28a4735995a44d1f573376e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 2.2.3 \_\_block的\_\_forwarding指针

结构体`__Block_byref_obj_0`

    //结构体__Block_byref_obj_0中有__forwarding
     struct __Block_byref_obj_0 {
      		void *__isa;
    		__Block_byref_obj_0 *__forwarding;
    		 int __flags;
     		int __size;
     		void (*__Block_byref_id_object_copy)(void*, void*);
     		void (*__Block_byref_id_object_dispose)(void*);
     		NSObject *__strong obj;
    };
    
    // 访问的时候
    age->__forwarding->age
    复制代码

为啥什么不直接用age,而是`age->__forwarding->age`呢？

这是因为:

*   如果`__block`变量在栈上，就可以直接访问
*   但是如果已经拷贝到了堆上，访问的时候，还去访问栈上的，就会出问题，所以，先根据`__forwarding`找到堆上的地址，然后再取值

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1416df53e32b4dccbd60cb9f11017e1c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

#### 2.2.4 小结

*   `__block`可以用于解决block内部无法修改auto变量值的问题
*   `__block`不能修饰全局变量、静态变量（static）
*   编译器会将`__block`变量包装成一个对象
*   调用的是，从`__Block_byref_age_0`的指针找到 `age`所在的内存，然后修改值

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6600f25525d84582bfb5b70458a82a39~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

七、使用Block时的循环引用问题
=================

继续探索一下block的循环引用问题。

看如下代码，有个Person类，里面两个属性，分别是block和age

    #import <Foundation/Foundation.h>
    
    typedef void (^HPBlock) (void);
    
    @interface HPPerson : NSObject
    @property (copy, nonatomic) HPBlock block;
    @property (assign, nonatomic) int age;
    @end
    
    
    #import "HPPerson.h"
    
    @implementation HPPerson
    - (void)dealloc
    {
        NSLog(@"%s", __func__);
    }
    @end
    复制代码

main.m中如下代码

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
        
            HPPerson *person = [[HPPerson alloc] init];
            person.age = 10;
            person.block = ^{
                 NSLog(@"person.age--- %d",person.age);
            };
            NSLog(@"--------");
    
        }
        return 0;
    }
    复制代码

输出只有

> iOS-block\[38362:358749\] --------

也就是说程序结束，**person都没有释放**，造成了内存泄漏。

1\. 循环引用原因
----------

下面这行代码，是有个person指针，HPPerson

    HPPerson *person = [[HPPerson alloc] init];
    复制代码

执行完

     person.block = ^{
                 NSLog(@"person.age--- %d",person.age);
     };
    复制代码

之后，block内部有个强指针指向person，下面代码生成cpp文件

> xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-8.0.0 main.m

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
        //强指针指向person
      HPPerson *__strong person;
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, HPPerson *__strong _person, int flags=0) : person(_person) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    复制代码

而block是person的属性

    @property (copy, nonatomic) HPBlock block;
    复制代码

当程序退出的时候，局部变量person销毁，但是由于HPPerson和block直接，互相强引用，谁都释放不了。

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd2fa7d41a0647c98904531944108829~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2.`__weak`解决循环引用
----------------

为了解决上面的问题，只需要用`__weak`来修饰，即可

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            HPPerson *person = [[HPPerson alloc] init];
            person.age = 10;
            
            __weak HPPerson *weakPerson = person;
            
            person.block = ^{
                NSLog(@"person.age--- %d",weakPerson.age);
            };
            NSLog(@"--------");
    
        }
        return 0;
    }
    复制代码

编译完成之后是

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
        // block内部对weakPerson是弱引用
      HPPerson *__weak weakPerson;
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, HPPerson *__weak _weakPerson, int flags=0) : weakPerson(_weakPerson) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    复制代码

当局部变量消失时候，对于HPPerson来说，只有一个弱指针指向它，那它就销毁，然后block也销毁。

3.`__unsafe_unretained`解决循环引用
-----------------------------

除了上面的`__weak`之后，也可以用`__unsafe_unretained`来解决循环引用

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            HPPerson *person = [[HPPerson alloc] init];
            person.age = 10;
            
            __unsafe_unretained HPPerson *weakPerson = person;
            
            person.block = ^{
                NSLog(@"person.age--- %d",weakPerson.age);
            };
            NSLog(@"--------");
    
        }
        return 0;
    }
    复制代码

对于的cpp文件为

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      HPPerson *__unsafe_unretained weakPerson;
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, HPPerson *__unsafe_unretained _weakPerson, int flags=0) : weakPerson(_weakPerson) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    复制代码

虽然`__unsafe_unretained`可以解决循环引用，但是最好不要用，因为:

*   `__weak`：不会产生强引用，指向的对象销毁时，会自动让指针置为nil
*   `__unsafe_unretained`：不会产生强引用，不安全，指向的对象销毁时，指针存储的地址值不变

4\. `__block`解决循环引用
-------------------

eg:

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
           __block HPPerson *person = [[HPPerson alloc] init];
            person.age = 10;
            person.block = ^{
                NSLog(@"person.age--- %d",person.age);
                //这一句不能少
                person = nil;
            };
            // 必须调用一次
            person.block();
            NSLog(@"--------");
        }
        return 0;
    }
    复制代码

上面的代码中，也是可以解决循环引用的。但是需要注意的是，`person.block();`必须调用一次，为了执行`person = nil;`.

对应的结果如下

*   下面的代码，block会对`__block`产生强引用

    __block HPPerson *person = [[HPPerson alloc] init];
    person.block = ^{
            NSLog(@"person.age--- %d",person.age);
            //这一句不能少
            person = nil;
    };
    复制代码

*   person对象本身就对block是强引用

    @property (copy, nonatomic) HPBlock block;
    复制代码

*   `__block`对person产生强引用

    struct __Block_byref_person_0 {
      void *__isa;
    __Block_byref_person_0 *__forwarding;
     int __flags;
     int __size;
     void (*__Block_byref_id_object_copy)(void*, void*);
     void (*__Block_byref_id_object_dispose)(void*);
        //`__block`对person产生强引用
     HPPerson *__strong person;
    };
    复制代码

所以他们的引用关系如图

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fa78bb5da06849f6974d91fec1862b16~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

当执行完`person = nil`时候,`__block`解除对person的引用,进而，全都解除释放了。 但是必须调用`person = nil`才可以，否则，不能解除循环引用

5.小结
----

通过前面的分析，我们知道，ARC下，上面三种方式对比，最好的是`__weak`

6.MRC下注意点
---------

如果再MRC下，因为不支持弱指针`__weak`，所以，只能是`__unsafe_unretained`或者`__block`来解决循环引用

八、一些相关的面试题
==========

做完前面的探索,我们可以通过一些面试题来检验对知识点的掌握程度

1.  block的原理是怎样的？本质是什么？
2.  \_\_block的作用是什么？有什么使用注意点？
3.  block的属性修饰词为什么是copy？使用block有哪些使用注意？
4.  block在修改NSMutableArray，需不需要添加\_\_block？

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