# OC对象的本质


二、NSObject的底层实现
===============

1\. 通过 Clang 转 源码格式查看
---------------------

我们在上一篇文章:**[OC的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")** 中得出了**结论:**  
我们平时编写的Objective-C代码，底层实现其实都是**C、C++代码、asm汇编代码**，所以Objective-C的面向对象 **`都是基于C\C++的数据结构实现的`**

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/089da4442b274f538df799081fd511b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 因此,我们可以写一份最简单的命令行项目,通过Clang编译器把源码文件 转成 C++的格式,进行查看,其底层的实现。

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d28cf5c4b9494023833567e1f09963b6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) **命令行:** 格式: `clang -rewrite-objc OC源文件 -o 输出的CPP文件`

    clang -rewrite-objc main.m -o main.mm

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b1f5007bffbd4186a798280a8d0eb8f4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

我们打开代码可以看见:

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/59798fb33adc4e0e8f655eef5ba7a961~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) NSObject的底层是一个结构体类型,内部有一个Class类型的成员名叫isa:

    struct NSObject_IMPL {
         Class isa; 
    };

2.查看源码
------

我们在上一篇文章:**[OC的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")** 中了解到了,苹果官方已经对OC语言的底层实现有了一部分的开源！！  
因此,我们可以通过`阅读源码`的形式了解NSObject的底层实现:  
我们可以通过.h文件看到,NSObject内部确实只有一个Class类型的isa成员,其余皆是一些方法。 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/460ccc8b79bb4a9e9c65b5a6bc502554~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 若我们了解内存分配就知道,我们探索一个类的内部结构的内存布局情况,关注其成员对象即可,不需要关注其方法(方法存储在公共内存位置,提供给所有的实例对象使用、类对象使用)。  
因此,我们进一步去看看Class是什么东西即可：

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f1cbbbf034904d9aa0d58ba4b9ea017b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们查看源码得知,Class本质是一个 objc\_class 类型的结构体指针

    typedef struct objc_class *Class;

我们进一步去看一下 `objc_class`这个结构体： ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0d243aad39d44ffd8874e0ad931c2a89~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们发现`objc_class`结构体继承自`objc_object`结构体，且`objc_class`内部有若干成员如下(忽略其函数、方法):
```
 struct objc_class : objc_object {
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
    }
```


我们跳进去查看 `objc_object`发现,其本身也只有一个 `isa_t`类型的成员 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bf56868bee14e73a556fd2bb5ce2575~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    struct objc_object  { 
        private: 
        isa_t isa; 
        ....    
    }
    复制代码

最终 `isa_t`类型的成员是一个联合体 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4e7a3df1a4c54f53894f0b807dced9f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

3.总结
----

通过前面的介绍,我们可以将NSObject的定义简写为:

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

**OC对象的本质**

*   Objective-C的对象、类主要是基于**C\\C++的结构体**实现的
*   凡是继承自NSObject的对象，都会自带一个类型是`Class`的`isa`的成员变量
    *   将其转成C++，就可以看到NSObject本质上是一个叫做`NSObject_IMPL`的结构体
        
    *   其成员变量isa本质上也是一个指向`objc_class`结构体的指针(`objc_class`继承自`objc_object`结构体,内部有一个isa成员)
        

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/45467b9abf374f6fa34143bb92a46fbe~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4.其它|`将Objective-C代码转换为C\C++代码`
-------------------------------

通过下面的命令可以将OC代码转换为C++代码来查看

*   `clang -rewrite-objc OC源文件 -o 输出的CPP文件` 由于Clang会根据不同平台转换的C++代码有所差异，所以针对iOS平台用下面的命令来转换
*   如果需要链接其他框架，使用-framework参数。比如-framework UIKit

    // 意为：通过Xcode运行iPhone平台arm64架构，重写OC文件到C++文件
    xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc OC源文件 -o 输出的CPP文件
    复制代码

三、NSObject的内存布局
===============

在iOS中查看对象内存布局的几种方式:

*   1.  通过 lldb命令(若是同学们不熟悉lldb,可以参考我这篇文章入门:[LLDB【命令结构、查询命令、断点设置、流程控制、模块查询、内存读写、chisel插件】](https://juejin.cn/post/7095079758844674056 "https://juejin.cn/post/7095079758844674056")
*   2.  通过 `Debug -> Debug Workfllow -> View Memory` **（Control+Option+Shift + Command + M）**
*   3.  通过 底层函数API

1.通过 `lldb命令` 窥探NSObject内存布局
----------------------------

*   1、**添加断点**
*   2、**打印内存地址:** 通过 `po` 命令打印出 对象的内存地址
*   3、**打印内存布局:** 通过 `memory read + 内存地址值` 命令打印出 对象的内存布局情况: ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/add86d4b2ad04e6186643c8acbd6a71c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   我们从打印结果中可以得出结论:`一个NSObject对象,系统给其分配了16个字节`

2.通过 `View Memory` 窥探NSObject内存布局
---------------------------------

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b38ca297e735482f953fcb9b43f9841b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   从截图上我们可以看到,地址`101323a20`与`101323a4F`之间差48,刚好显示差了一行
*   而`101323a20`的整个存储空间为绿色框框出来的一部分，蓝色框为`101323a30`开始的部分了
*   从内存布局中我们看到,`NSObject中有十六个字节`,但是只用了八个字节来存储内容。与前面的方式是得到的结论是相符合的。

3.通过 `底层函数API` 窥探NSObject内存布局
-----------------------------

我们通过阅读苹果官方开源的源码,我们可以看到runtime中有一个函数:

    /**  
     * Returns the size of instances of a class. 
     *  
     * **@param** cls A class object.
    
     * 
    
     * **@return** The size in bytes of instances of the class \e *cls,* or \c 0 if \e *cls* is \c Nil.
    
     */
    
    OBJC_EXPORT size_t
    
    class_getInstanceSize(Class _Nullable cls) 
    
        OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);
     
    复制代码

我们通过调用可以看到结果:

    #import <objc/runtime.h>
    class_getInstanceSize([NSObject class]);
    复制代码

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0d9ef886e6694026be7985a0f0f1cb41~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 结果是8。  
为什么是8？？跟我们前面得到的结论不一致！！！我们继续往下探索！！  
我们知道,OC中`创建对象分配内存是通过 alloc方法`,我们直接去看官方开源的程序中`alloc`的实现即可(本质上最终alloc的实现就会调用`allocWithZone:`方法): ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a994307d4c2444e8a2ed10a1e1057a29~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) `OBJC_SWIFT_UNAVAILABLE`这段宏是限制Swift语言分配内存（因为目前存在OC+Swift混编的情况,这个不是本篇幅谈论的范畴,咱们只关注 `纯OC` 环境即可） ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9e04dc72f9874b4f84becca9348140b3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们从`NSObject.mm`文件可以看到其实现调用的函数:  
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/55e758af9db842cb9e95aabb561226b7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

从图上我们清晰看见,最终其调用的是objc里面的 `_objc_rootAllocWithZone`函数:

我们通过全局搜索找到函数的内部实现:

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/819a71654bb84069b66d1bc87c5291c5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2dceca3d7b144c6fa02cdb113541a64c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们可以看到语言逻辑,在其首次分配内存的时候,调用了函数: `class_createInstance` `class_createInstance`函数最终也是调用了 `class_createInstanceFromZone函数`

    obj = class_createInstance(cls, 0);
    复制代码

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2116db8f0287496ea5bd0d6171e9a6bb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5c8e796f3d2f4f34a796af5602bf11b0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 从函数的实现中我们也看到了,CF框架要求:`所有对象至少分配16个字节内存`。这涉及到内存对齐的概念。

*   系统底层是早已开辟了16个长度、32个长度、48个长度、64个长度、128个长度....(16的倍数)的内存块的
*   当分配内存给对象时,是按照对象需要内存,能容纳其所需且最接近其的16的最小公倍数来分配内存块的
*   结合前面探索,我们不难猜出这段代码得出的`8个字节,是用来存储 isa 指针`的,我们来验证一下: ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6cbccac14ef24a988b539edcb06202c0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 如图所示,我们无法直接访问isa私有成员变量(苹果设计不可以直接访问),但是我们窥探过其开源代码,知道其数据结构,我们可以自己在外部写一个类似的结构体对象进行调试打印！且通过验证得出结论,我们的猜想是正确的！  
    那么我们可以得出结论:`class_getInstanceSize`这个runtime函数是用来获取,创建一个对象的实例,至少得给其分配多少内存的！(也就是其本身的数据结构需要多少内存)

    
      #import <objc/runtime.h>
    
      class_getInstanceSize([NSObject class]);
    
    复制代码

**我们进一步去找一找源码,看看系统底层`对内存对齐方面的处理:`**

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8483642325cb49cdaefad796c5f4aa22~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 我们可以看到红框框中框出来的部分,为分配内存的代码!在objc这份源码中已经看不到了,我们要重新去苹果的[OpenSource](https://link.juejin.cn?target=https%3A%2F%2Fopensource.apple.com%2Ftarballs%2F "https://opensource.apple.com/tarballs/")去下载[libmalloc](https://link.juejin.cn?target=https%3A%2F%2Fopensource.apple.com%2Ftarballs%2Flibmalloc%2F "https://opensource.apple.com/tarballs/libmalloc/")这个开源文件进行探索: 我们查找到 `_malloc_zone_calloc`的实现: ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0a38edc3079f4f20bd6961b26ba9a78c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 从上图,我们不难得知,本质上还是调了`calloc`函数

*   其中`zone->calloc`传入的zone 就是 上一步中的 `default_zone`
*   这个关键代码的`目的`就是`申请一个指针，并将指针地址返回` `calloc`这个函数的实现,苹果官方没有开源 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/111856d5da854bf39429533c18840761~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 但是我们在系统暴露的`malloc.h`头文件中找到了一个函数: ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2ef12c960ce243d8beabd343c1005de2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    extern size_t malloc_size(const void *ptr);  /* Returns size of given ptr */
    复制代码

其解释是指,创建对象时,分配多少内存,并把分配的内存地址返回给指针`ptr`。我们试着用一下这个函数去获取一下实际分配的内存:

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8262f7042ac4e4fb06d0c4a7e19fd9e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 从打印结果我们可以看到 实际分配了`16个字节`,与前面的几种方式得到的结论一致！！

4.总结:
-----

我们对前面两个函数做一个总结:

    创建一个实例对象，至少需要多少内存？
    #import <objc/runtime.h>
    class_getInstanceSize([NSObject class]);
    
    
    创建一个实例对象，实际上分配了多少内存？
    #import <malloc/malloc.h>
    malloc_size((__bridge const void *)obj);
    
    复制代码

我们前面通过三种方式,得出结论,创建一个NSObject对象:

*   `至少需要8个字节`的内存(用于存放`isa指针`)
*   `实际分配了16个字节`的内存(因为系统开发者在设计的时候,规定了内存分配的规则)
*   OC对象的`内存对齐参数为 16`
    *   若需要分配的内存不够16,则以给16个字节
    *   若对象需要分配的内存超过16,则以能容纳对象的数据结构为前提,以最接近其的16最小公倍数为最终分配大小进行分配
*   一个OC对象在内存中的布局:
    *   系统会在堆中开辟一块内存空间存放该对象
    *   这块空间里还包含`成员变量`和`isa指针`
    *   然后栈里的 局部变量 `指向这块存储空间` 的地址

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6d565cdea4a3477ab84a0189edfb502f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

四、通过继承关系进一步了解NSObject
=====================

**随手写两个类:**

*   `Car`继承自`NSObject`
*   `BBA_BMW`继承自`Car`

    // 
    //  main.m 
    //  窥探iOS底层原理 
    // 
    //  Created by VanZhang on 2022/5/6. 
    //
     
    
    #import <Foundation/Foundation.h> 
    #import <objc/runtime.h> 
    #import <malloc/malloc.h>
    
    struct  { 
        Class isa; 
    }NSObject_ISA;
     
    
     
    
    @interface Car :NSObject{
    
    @public
    
        int _year;//多少年了 4个字节
    
        int _kilometres;//多少公里数  4个字节
    
    }//int 4+ int 4+  isa 8 = 24 ;需要24
    
    //内存对齐参数为16 ;总共分配了能容纳其需要的16的最小公倍数:32
    
    -(void)run;
    
    @end
     
    
    @implementation Car
    
    - (instancetype)init{
    
        self = [super init];
    
        if (self) {
    
            _year = 1;
    
            _kilometres = 2;
    
        }
    
        return self;
    
    }
    
    - (void)run{
    
        NSLog(@"%s",__func__);
    
    }
    
    @end
     
    
    @interface BBA_BMW :Car{
    
    @public
    
        NSString*_nameplate;//汽车铭牌 8个字节
    
    }//int 8+ double 8+  isa 8 + _nameplate 8= 32 ;需要32
    
    //内存对齐参数为16 ;总共分配了能容纳其需要的16的最小公倍数:32
    
    -(void)runFaster;
    
    @end
     
    
    
    @implementation BBA_BMW
    
    - (void)runFaster{
    
       NSLog(@"%s",__func__);
    
    }
    
    @end
     
    
    void testFunc(void){
    
        Car *c = [[Car alloc]init];
    
        c->_year = 18;
    
        c->_kilometres = 890123;
    
        NSLog(@"Car_class_getInstanceSize:%zd",class_getInstanceSize([c class]));
    
        NSLog(@"Car_size:%zd",malloc_size((__bridge const void *)(c)));
    
        BBA_BMW *bba = [[BBA_BMW alloc]init];
    
        bba->_nameplate = @"宝马七系";
    
        NSLog(@"BBA_BMW_class_getInstanceSize:%zd",class_getInstanceSize([bba class]));
    
        NSLog(@"BBA_BMW_size:%zd",malloc_size((__bridge const void *)(bba)));
    
        
    
    }
    
    int main(int argc, const char * argv[]) {
    
        @autoreleasepool {
    
            // insert code here...
    
            NSObject *obj = [[NSObject alloc]init];
    
            // NSLog(@"%@",obj);
    
            NSLog(@"class_getInstanceSize:%zd",class_getInstanceSize([obj class]));
    
           // NSLog(@"isa:%zd",sizeof(obj->isa));
    
            NSLog(@"isa:%zd",sizeof(NSObject_ISA));
    
            NSLog(@"malloc_size:%zd",malloc_size((__bridge const void *)(obj)));
    
            
    
            testFunc();
    
        }
    
        return 0;
    
    }
     
     
    复制代码

1.运行项目,通过系统函数打印一下:
------------------

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5721cfa30b95486693c0351b2c7172f5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fa790811114c4a8887cbe6218d5668c8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

2.打断点,通过ViewMemory查看一下内存
------------------------

**car:**

*   我们前面将`_year`设置为18,在16进制中,0x12=十进制的18
    
*   实际分配了32,真正用到了24 ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/215d91b4d0bf47a68fef56884c9f6e67~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) **bba:**
    
*   我们前面将`_year`默认设置为1,将 `_kilometres`改为int类型 默认设置为 2
    
*   内存分布情况如下: ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29d7ff970fc245eb82ea5c4168b72582~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)