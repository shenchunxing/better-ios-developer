* * *

简书博客已经暂停更新，想看更多技术博客请到：

*   掘金 ：[J\_Knight\_](https://juejin.im/user/57f8ffda2e958a005581e3c0/posts)
*   个人博客: [J\_Knight\_](https://knightsj.github.io/)
*   个人公众号：程序员维他命

* * *

![](//upload-images.jianshu.io/upload_images/859001-7ceabf4418ec5228.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

《Objective-C高级编程：iOS与OS X多线程和内存管理》

这一章讲解了Block相关的知识。因为作者将Objective-C的代码转成了C++的代码，所以第一次看的时候非常吃力，我自己也不记得看了多少遍了。

这篇总结不仅仅只有这本书中的内容，还有一点在其他博客里看过的Block的相关知识，并加上了自己的理解，而且文章结构也和原书不太一致，是经过我的整理重新排列出来的。

先看一下本文结构（Blocks部分）：

![](//upload-images.jianshu.io/upload_images/859001-169518e948933744.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

《Objective-C高级编程》 干货三部曲

需要先知道的
======

Objective-C 转 C++的方法
--------------------

因为需要看Block操作的C++源码，所以需要知道转换的方法，自己转过来看一看：

1.  在OC源文件block.m写好代码。
2.  打开终端，cd到block.m所在文件夹。
3.  输入`clang -rewrite-objc block.m`，就会在当前文件夹内自动生成对应的block.cpp文件。

关于几种变量的特点
---------

c语言的函数中可能使用的变量：

*   函数的参数
*   自动变量（局部变量）
*   静态变量（静态局部变量）
*   静态全局变量
*   全局变量

而且，由于存储区域特殊，这其中有三种变量是可以在任何时候以任何状态调用的：

*   静态变量
*   静态全局变量
*   全局变量

而其他两种，则是有各自相应的作用域，超过作用域后，会被销毁。

好了，知道了这两点，理解下面的内容就容易一些了。

Block的实质
========

先说结论：Block实质是Objective-C对闭包的对象实现，简单说来，Block就是对象。

下面分别从表层到底层来分析一下：

表层分析Block的实质：它是一个类型
-------------------

Block是一种类型，一旦使用了Block就相当于生成了可赋值给Block类型变量的值。举个例子：

    int (^blk)(int) = ^(int count){
            return count + 1;
    };
    

*   等号左侧的代码表示了这个Block的类型：它接受一个int参数，返回一个int值。
*   等号右侧的代码是这个Block的值：它是等号左侧定义的block类型的一种实现。

如果我们在项目中经常使用某种相同类型的block，我们可以用`typedef`来抽象出这种类型的Block：

    typedef int(^AddOneBlock)(int count);
    
    AddOneBlock block = ^(int count){
            return count + 1;//具体实现代码
    };
    

这样一来，block的赋值和传递就变得相对方便一些了, 因为block的类型已经抽象了出来。

深层分析Block的实质：它是Objective-C对象
----------------------------

Block其实就是Objective-C对象，因为它的结构体中含有isa指针。

下面将Objective-C的代码转化为C++的代码来看一下block的实现。

**OC代码:**

    int main()
    {
        void (^blk)(void) = ^{
            printf("Block\n");
        };
        return 0;
    }
    

**C++代码:**

    struct __block_impl {
      void *isa;
      int Flags;
      int Reserved;
      void *FuncPtr;
    };
    
    //block结构体
    struct __main_block_impl_0 {
        
      struct __block_impl impl;
        
      struct __main_block_desc_0* Desc;
      
      //Block构造函数
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
        impl.isa = &_NSConcreteStackBlock;//isa指针
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
        
    };
    
    //将来被调用的block内部的代码：block值被转换为C的函数代码
    static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    
            printf("Block\n");
    }
    
    static struct __main_block_desc_0 {
        
      size_t reserved;
      size_t Block_size;
        
    } __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
    
    //main 函数
    int main()
    {
        void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));
        return 0;
    }
    

首先我们看一下从原来的block值（OC代码块）转化而来的C++代码：

    static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    
        printf("Block\n");
    }
    

> 这里，\*\_\_cself 是指向Block的值的指针，也就相当于是Block的值它自己（相当于C++里的this，OC里的self）。

> 而且很容易看出来，\_\_cself 是指向\_\_main\_block\_impl\_0结构体实现的指针。  
> 结合上句话，也就是说Block结构体就是\_\_main\_block\_impl\_0结构体。Block的值就是通过\_\_main\_block\_impl\_0构造出来的。

下面来看一下这个结构体的声明：

    struct __main_block_impl_0 {
        
      struct __block_impl impl;
        
      struct __main_block_desc_0* Desc;
      
      //构造函数
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    

可以看出，\_\_main\_block\_impl\_0结构体有三个部分：

第一个是成员变量impl，它是实际的函数指针，它指向\_\_main\_block\_func\_0。来看一下它的结构体的声明：

    struct __block_impl {
      void *isa;
      int Flags;
      int Reserved;  //今后版本升级所需的区域
      void *FuncPtr; //函数指针
    };
    

第二个是成员变量是指向\_\_main\_block\_desc\_0结构体的Desc指针，是用于描述当前这个block的附加信息的，包括结构体的大小等等信息

    static struct __main_block_desc_0 {
        
      size_t reserved;  //今后升级版本所需区域
      size_t Block_size;//block的大小
        
    } __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
    

第三个部分是\_\_main\_block\_impl\_0结构体的构造函数，\_\_main\_block\_impl\_0 就是该 block 的实现

    __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    

在这个结构体的构造函数里，isa指针保持这所属类的结构体的实例的指针。\_\_main\_block\_imlp\_0结构体就相当于Objective-C类对象的结构体，这里的\_NSConcreteStackBlock相当于Block的结构体实例,**也就是说block其实就是Objective-C对于闭包的对象实现**。

Block截获自动变量和对象
==============

Block截获自动变量（局部变量）
-----------------

使用Block的时候，不仅可以使用其内部的参数，还可以使用Block外部的局部变量。而一旦在Block内部使用了其外部变量，这些变量就会被Block保存。

有趣的是，即使在Block外部修改这些变量，存在于Block内部的这些变量也不会被修改。来看一下代码：

    int a = 10;
    int b = 20;
        
    PrintTwoIntBlock block = ^(){
        printf("%d, %d\n",a,b);
    };
        
    block();//10 20
        
    a += 10;
    b += 30;
        
    printf("%d, %d\n",a,b);//20 50
        
    block();//10 20
    

> 我们可以看到，在外部修改a，b的值以后，再次调用block时，里面的打印仍然和之前是一样的。给人的感觉是，外部到局部变量和被Block内部截获的变量并不是同一份。

那如果在内部修改a，b的值会怎么样呢？

    int a = 10;
    int b = 20;
        
    PrintTwoIntBlock block = ^(){
        //编译不通过
        a = 30;
        b = 10;
    };
        
    block();
    

如果不进行额外操作，局部变量一旦被Block保存，在Block内部就不能被修改了。

但是需要注意的是，这里的修改是指整个变量的赋值操作，变更该对象的操作是允许的，比如在不加上\_\_block修饰符的情况下，给在block内部的可变数组添加对象的操作是可以的。

    NSMutableArray *array = [[NSMutableArray alloc] init];
        
    NSLog(@"%@",array); //@[]
        
    PrintTwoIntBlock block = ^(){
        [array addObject:@1];
    };
        
    block();
        
    NSLog(@"%@",array);//@[1]
    

OK，现在我们知道了三点：

1.  Block可以截获局部变量。
2.  修改Block外部的局部变量，Block内部被截获的局部变量不受影响。
3.  修改Block内部到局部变量，编译不通过。

为了解释2，3点，我们通过C++的代码来看一下Block在截获变量的时候都发生了什么：  
**C代码：**

    int main()
    {
        int dmy = 256;
        int val = 10;
        
        const char *fmt = "var = %d\n";
        
        void (^blk)(void) = ^{
            printf(fmt,val);
        };
        
        val = 2;
        fmt = "These values were changed. var = %d\n";
        
        blk();
        
        return 0;
    }
    

**C++代码：**

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      
      const char *fmt;  //被添加
      int val;          //被添加
      
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, const char *_fmt, int _val, int flags=0) : fmt(_fmt), val(_val) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
      const char *fmt = __cself->fmt; // bound by copy
      int val = __cself->val; // bound by copy
    
            printf(fmt,val);
        }
    
    static struct __main_block_desc_0 {
      size_t reserved;
      size_t Block_size;
    } __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
    
    int main()
    {
        int dmy = 256;
        int val = 10;
    
        const char *fmt = "var = %d\n";
    
        void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, fmt, val));
    
        val = 2;
        fmt = "These values were changed. var = %d\n";
    
        ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    
        return 0;
    }
    

单独抽取\_\_main\_block\_impl\_0来看一下：

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      const char *fmt; //截获的自动变量
      int val;         //截获的自动变量
      
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, const char *_fmt, int _val, int flags=0) : fmt(_fmt), val(_val) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    

1.  我们可以看到，在block内部语法表达式中使用的自动变量（fmt，val）被作为成员变量追加到了\_\_main\_block\_impl\_0结构体中（注意：block没有使用的自动变量不会被追加，如dmy变量）。
2.  在初始化block结构体实例时（请看\_\_main\_block\_impl\_0的构造函数），还需要截获的自动变量fmt和val来初始化\_\_main\_block\_impl\_0结构体实例，因为增加了被截获的自动变量，block的体积会变大。

再来看一下函数体的代码：

    static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    
      const char *fmt = __cself->fmt; // bound by copy
      int val = __cself->val; // bound by copy
      printf(fmt,val);
    }
    

> 从这里看就更明显了：fmt,var都是从\_\_cself里面获取的，更说明了二者是属于block的。而且从注释来看（注释是由clang自动生成的），这两个变量是值传递，而不是指针传递，也就是说Block仅仅截获自动变量的值，所以这就解释了**即使改变了外部的自动变量的值，也不会影响Block内部的值**。

那为什么在默认情况下改变Block内部到变量会导致编译不通过呢？  
我的思考是：既然我们无法在Block中改变外部变量的值，所以也就没有必要在Block内部改变变量的值了，因为Block内部和外部的变量实际上是两种不同的存在：前者是Block内部结构体的一个成员变量，后者是在栈区里的临时变量。

现在我们知道：被截获的自动变量的值是无法直接修改的，但是有两个方法可以解决这个问题：

1.  改变存储于特殊存储区域的变量。
2.  通过\_\_block修饰符来改变。

1\. 改变存储于特殊存储区域的变量
------------------

*   全局变量，可以直接访问。
*   静态全局变量，可以直接访问。
*   静态变量，直接指针引用。

我们还是用OC和C++代码的对比看一下具体的实现:

**OC代码：**

    int global_val = 1;//全局变量
    static int static_global_val = 2;//全局静态变量
    
    int main()
    {
        static int static_val = 3;//静态变量
        
        void (^blk)(void) = ^{
            global_val *=1;
            static_global_val *=2;
            static_val *=3;
        };
        return 0;
    }
    

**C++代码：**

    int global_val = 1;
    static int static_global_val = 2;
    
    
    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      int *static_val;
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_val, int flags=0) : static_val(_static_val) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    
    
    static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    
      int *static_val = __cself->static_val; // bound by copy
    
      global_val *=1;
      static_global_val *=2;
      (*static_val) *=3;
    }
    
    static struct __main_block_desc_0 {
      size_t reserved;
      size_t Block_size;
    } __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
    
    int main()
    {
        static int static_val = 3;
    
        void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &static_val));
        return 0;
    }
    

我们可以看到，

*   全局变量和全局静态变量没有被截获到block里面，它们的访问是不经过block的(与\_\_cself无关)：

    static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    
      int *static_val = __cself->static_val; // bound by copy
    
      global_val *=1;
      static_global_val *=2;
      (*static_val) *=3;
    }
    

*   访问静态变量（static\_val）时，将静态变量的指针传递给\_\_main\_block\_impl\_0结构体的构造函数并保存：

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      int *static_val;//是指针，不是值
      
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int *_static_val, int flags=0) : static_val(_static_val) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    

那么有什么方法可以在Block内部给变量赋值呢？-- 通过\_\_block关键字。在讲解\_\_block关键字之前，讲解一下Block截获对象：

Block截获对象
---------

我们看一下在block里截获了array对象的代码，array超过了其作用域存在：

    blk_t blk;
    {
        id array = [NSMutableArray new];
        blk = [^(id object){
            [array addObject:object];
            NSLog(@"array count = %ld",[array count]);
                
        } copy];
    }
        
    blk([NSObject new]);
    blk([NSObject new]);
    blk([NSObject new]);
    

输出：

    block_demo[28963:1629127] array count = 1
    block_demo[28963:1629127] array count = 2
    block_demo[28963:1629127] array count = 3
    

看一下C++代码：

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      id array;//截获的对象
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, id _array, int flags=0) : array(_array) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    

值得注意的是，在OC中，C结构体里不能含有被\_\_strong修饰的变量，因为编译器不知道应该何时初始化和废弃C结构体。但是OC的运行时库能够准确把握Block从栈复制到堆，以及堆上的block被废弃的时机，在实现上是通过\_\_main\_block\_copy\_0函数和\_\_main\_block\_dispose\_0函数进行的:

    static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
        _Block_object_assign((void*)&dst->array, (void*)src->array, 3/*BLOCK_FIELD_IS_OBJECT*/);
    }
    
    static void __main_block_dispose_0(struct __main_block_impl_0*src) {
        _Block_object_dispose((void*)src->array, 3/*BLOCK_FIELD_IS_OBJECT*/);
    }
    

> 其中，\_Block\_object\_assign相当于retain操作，将对象赋值在对象类型的结构体成员变量中。  
> \_Block\_object\_dispose相当于release操作。

这两个函数调用的时机是在什么时候呢？

函数

被调用时机

\_\_main\_block\_copy\_0

从栈复制到堆时

\_\_main\_block\_dispose\_0

堆上的Block被废弃时

**什么时候栈上的Block会被复制到堆呢？**

*   调用block的copy函数时
*   Block作为函数返回值返回时
*   将Block赋值给附有\_\_strong修饰符id类型的类或者Block类型成员变量时
*   方法中含有usingBlock的Cocoa框架方法或者GCD的API中传递Block时

**什么时候Block被废弃呢？**

堆上的Block被释放后，谁都不再持有Block时调用dispose函数。

\_\_weak关键字：

    {
            id array = [NSMutableArray new];
            id __weak array2 = array;
            blk = ^(id object){
                [array2 addObject:object];
                NSLog(@"array count = %ld",[array2 count]);
            };
        }
        
        blk([NSObject new]);
        blk([NSObject new]);
        blk([NSObject new]);
    

输出：

     block_demo[32084:1704240] array count = 0
     block_demo[32084:1704240] array count = 0
     block_demo[32084:1704240] array count = 0
    

因为array在变量作用域结束时被释放，nil被赋值给了array2中。

\_\_block的实现原理
==============

\_\_block修饰局部变量
---------------

先通过OC代码来看一下给局部变量添加\_\_block关键字后的效果：

    __block int a = 10;
    int b = 20;
        
    PrintTwoIntBlock block = ^(){
        a -= 10;
        printf("%d, %d\n",a,b);
    };
        
    block();//0 20
        
    a += 20;
    b += 30;
        
    printf("%d, %d\n",a,b);//20 50
        
    block();/10 20
    

我们可以看到，\_\_block变量在block内部就可以被修改了。

> 加上\_\_block之后的变量称之为\_\_block变量，

先简单说一下\_\_block的作用：  
\_\_block说明符用于指定将变量值设置到哪个存储区域中，也就是说，当自动变量加上\_\_block说明符之后，会改变这个自动变量的存储区域。

接下来我们还是用clang工具看一下C++的代码：

OC代码

    int main()
    {
        __block int val = 10;
        
        void (^blk)(void) = ^{
            val = 1;
        };
        return 0;
    }
    

C++代码

    struct __Block_byref_val_0 {
      void *__isa;
    __Block_byref_val_0 *__forwarding;
     int __flags;
     int __size;
     int val;
    };
    
    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      __Block_byref_val_0 *val; // by ref
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_val_0 *_val, int flags=0) : val(_val->__forwarding) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
      __Block_byref_val_0 *val = __cself->val; // bound by ref
    
            (val->__forwarding->val) = 1;
        }
    static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->val, (void*)src->val, 8/*BLOCK_FIELD_IS_BYREF*/);}
    
    static void __main_block_dispose_0(struct __main_block_impl_0*src) {_Block_object_dispose((void*)src->val, 8/*BLOCK_FIELD_IS_BYREF*/);}
    
    static struct __main_block_desc_0 {
      size_t reserved;
      size_t Block_size;
      void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
      void (*dispose)(struct __main_block_impl_0*);
    } __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};
    int main()
    {
        __attribute__((__blocks__(byref))) __Block_byref_val_0 val = {(void*)0,(__Block_byref_val_0 *)&val, 0, sizeof(__Block_byref_val_0), 10};
    
        void (*blk)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_val_0 *)&val, 570425344));
        return 0;
    }
    
    

在\_\_main\_block\_impl\_0里面发生了什么呢？

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      __Block_byref_val_0 *val; // by ref
      
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_val_0 *_val, int flags=0) : val(_val->__forwarding) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    
    >__main_block_impl_0里面增加了一个成员变量，它是一个结构体指针，指向了 __Block_byref_val_0结构体的一个实例。那么这个结构体是什么呢？
    
    这个结构体是变量val在被__block修饰后生成的！！
    该结构体声明如下：
    ```objc
    struct __Block_byref_val_0 {
      void *__isa;
    __Block_byref_val_0 *__forwarding;
     int __flags;
     int __size;
     int val;
    };
    

我们可以看到，这个结构体最后的成员变量就相当于原来自动变量。  
这里有两个成员变量需要特别注意：

1.  val：保存了最初的val变量，也就是说原来单纯的int类型的val变量被\_\_block修饰后生成了一个结构体。这个结构体其中一个成员变量持有原来的val变量。
2.  \_\_forwarding：通过\_\_forwarding，可以实现无论\_\_block变量配置在栈上还是堆上都能正确地访问\_\_block变量，也就是说\_\_forwarding是指向自身的。

用一张图来直观看一下：

图片来自：《Objective-C高级编程：iOS与OS X多线程和内存管理》

  

怎么实现的？

1.  最初，\_\_block变量在栈上时，它的成员变量\_\_forwarding指向栈上的\_\_block变量结构体实例。
2.  在\_\_block被复制到堆上时，会将\_\_forwarding的值替换为堆上的目标\_\_block变量用结构体实例的地址。而在堆上的目标\_\_block变量自己的\_\_forwarding的值就指向它自己。

我们可以看到，这里面增加了指向\_\_Block\_byref\_val\_0结构体实例的指针。这里//by ref这个由clang生成的注释，说明它是通过指针来引用\_\_Block\_byref\_val\_0结构体实例val的。

因此\_\_Block\_byref\_val\_0结构体并不在\_\_main\_block\_impl\_0结构体中，目的是为了使得多个Block中使用\_\_block变量。

举个例子：

    int main()
    {
        __block int val = 10;
        
        void (^blk0)(void) = ^{
            val = 12;
        };
        
        void (^blk1)(void) = ^{
            val = 13;
        };
        return 0;
    }
    

    int main()
    {
        __attribute__((__blocks__(byref))) __Block_byref_val_0 val = {(void*)0,(__Block_byref_val_0 *)&val, 0, sizeof(__Block_byref_val_0), 10};
    
        void (*blk0)(void) = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_val_0 *)&val, 570425344));
    
        void (*blk1)(void) = ((void (*)())&__main_block_impl_1((void *)__main_block_func_1, &__main_block_desc_1_DATA, (__Block_byref_val_0 *)&val, 570425344));
        return 0;
    }
    

我们可以看到，在main函数里，两个block都引用了\_\_Block\_byref\_val\_0结构体的实例val。

那么\_\_block修饰对象的时候是怎么样的呢？

\_\_block修饰对象
-------------

\_\_block可以指定任何类型的自动变量。下面来指定id类型的对象:

看一下\_\_block变量的结构体：

    struct __Block_byref_obj_0 {
      void *__isa;
    __Block_byref_obj_0 *__forwarding;
     int __flags;
     int __size;
     void (*__Block_byref_id_object_copy)(void*, void*);
     void (*__Block_byref_id_object_dispose)(void*);
     id obj;
    };
    

被\_\_strong修饰的id类型或对象类型自动变量的copy和dispose方法：

    static void __Block_byref_id_object_copy_131(void *dst, void *src) {
     _Block_object_assign((char*)dst + 40, *(void * *) ((char*)src + 40), 131);
    }
    
    
    static void __Block_byref_id_object_dispose_131(void *src) {
     _Block_object_dispose(*(void * *) ((char*)src + 40), 131);
    }
    

同样，当Block持有被\_\_strong修饰的id类型或对象类型自动变量时：

*   如果\_\_block对象变量从栈复制到堆时，使用\_Block\_object\_assign函数，
*   当堆上的\_\_block对象变量被废弃时，使用\_Block\_object\_dispose函数。

    struct __main_block_impl_0 {
      struct __block_impl impl;
      struct __main_block_desc_0* Desc;
      __Block_byref_obj_0 *obj; // by ref
      __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_obj_0 *_obj, int flags=0) : obj(_obj->__forwarding) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    

可以看到，obj被添加到了\_\_main\_block\_impl\_0结构体中，它是\_\_Block\_byref\_obj\_0类型。

三种Block
=======

细心的同学会发现，在上面Block的构造函数\_\_main\_block\_impl\_0中的isa指针指向的是&\_NSConcreteStackBlock，它表示当前的Block位于栈区中。实际上，一共有三种类型的Block：

Block的类

存储域

拷贝效果

\_NSConcreteStackBlock

栈

从栈拷贝到堆

\_NSConcreteGlobalBlock

程序的数据区域

什么也不做

\_NSConcreteMallocBlock

堆

引用计数增加

全局Block：\_NSConcreteGlobalBlock
-------------------------------

因为全局Block的结构体实例设置在程序的数据存储区，所以可以在程序的任意位置通过指针来访问，它的产生条件：

*   记述全局变量的地方有block语法时。
*   block不截获的自动变量时。

以上两个条件只要满足一个就可以产生全局Block，下面分别用C++来展示一下第一种条件下的全局Block：

c代码：

    void (^blk)(void) = ^{printf("Global Block\n");};
    
    int main()
    {
        blk();
    }
    
    

C++代码：

    struct __blk_block_impl_0 {
      struct __block_impl impl;
      struct __blk_block_desc_0* Desc;
      __blk_block_impl_0(void *fp, struct __blk_block_desc_0 *desc, int flags=0) {
        impl.isa = &_NSConcreteGlobalBlock;//全局
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    static void __blk_block_func_0(struct __blk_block_impl_0 *__cself) {
    printf("Global Block\n");}
    
    static struct __blk_block_desc_0 {
      size_t reserved;
      size_t Block_size;
    } __blk_block_desc_0_DATA = { 0, sizeof(struct __blk_block_impl_0)};
    
    static __blk_block_impl_0 __global_blk_block_impl_0((void *)__blk_block_func_0, &__blk_block_desc_0_DATA);
    void (*blk)(void) = ((void (*)())&__global_blk_block_impl_0);
    
    int main()
    {
        ((void (*)(__block_impl *))((__block_impl *)blk)->FuncPtr)((__block_impl *)blk);
    }
    

> 我们可以看到Block结构体构造函数里面isa指针被赋予的是&\_NSConcreteGlobalBlock，说明它是一个全局Block。

栈Block：\_NSConcreteStackBlock
-----------------------------

在生成Block以后，如果这个Block不是全局Block，那么它就是为\_NSConcreteStackBlock对象，但是如果其所属的变量作用域名结束，该block就被废弃。在栈上的\_\_block变量也是如此。

但是，如果Block变量和\_\_block变量复制到了堆上以后，则不再会受到变量作用域结束的影响了，因为它变成了堆Block：

堆Block：\_NSConcreteMallocBlock
------------------------------

> 将栈block复制到堆以后，block结构体的isa成员变量变成了\_NSConcreteMallocBlock。

其他两个类型的Block在被复制后会发生什么呢？

Block类型

存储位置

copy操作的影响

\_NSConcreteGlobalBlock

程序的数据区域

什么也不做

\_NSConcreteStackBlock

栈

从栈拷贝到堆

\_NSConcreteMallocBlock

堆

引用计数增加

而大多数情况下，编译器会进行判断，自动将block从栈上复制到堆：

*   block作为函数值返回的时候
*   部分情况下向方法或函数中传递block的时候
    *   Cocoa框架的方法而且方法名中含有usingBlock等时。
    *   Grand Central Dispatch 的API。

除了这两种情况，基本都需要我们手动复制block。

那么\_\_block变量在Block执行copy操作后会发生什么呢？

1.  任何一个block被复制到堆上时，\_\_block变量也会一并从栈复制到堆上，并被该Block持有。
2.  如果接着有其他Block被复制到堆上的话，被复制的Block会持有\_\_block变量，并增加\_\_block的引用计数，反过来如果Block被废弃，它所持有的\_\_block也就被释放（不再有block引用它）。

Block循环引用
=========

如果在Block内部使用\_\_strong修饰符的对象类型的自动变量，那么当Block从栈复制到堆的时候，该对象就会被Block所持有。

所以如果这个对象还同时持有Block的话，就容易发生循环引用。

    typedef void(^blk_t)(void);
    
    @interface Person : NSObject
    {
        blk_t blk_;
    }
    
    @implementation Person
    
    - (instancetype)init
    {
        self = [super init];
        blk_ = ^{
            NSLog(@"self = %@",self);
        };
        return self;
    }
    
    @end
    

Block blk\_t持有self，而self也同时持有作为成员变量的blk\_t

\_\_weak修饰符
-----------

    - (instancetype)init
    {
        self = [super init];
        id __weak weakSelf = self;
        blk_ = ^{
            NSLog(@"self = %@",weakSelf);
        };
        return self;
    }
    

    typedef void(^blk_t)(void);
    
    @interface Person : NSObject
    {
        blk_t blk_;
        id obj_;
    }
    
    @implementation Person
    - (instancetype)init
    {
        self = [super init];
        blk_ = ^{
            NSLog(@"obj_ = %@",obj_);//循环引用警告
        };
        return self;
    }
    

Block语法内的obj\_截获了self,因为ojb\_是self的成员变量，因此，block如果想持有obj\_，就必须引用先引用self，所以同样会造成循环引用。就好比你如果想去某个商场里的咖啡厅，就需要先知道商场在哪里一样。

如果某个属性用的是weak关键字呢？

    @interface Person()
    @property (nonatomic, weak) NSArray *array;
    @end
    
    @implementation Person
    
    - (instancetype)init
    {
        self = [super init];
        blk_ = ^{
            NSLog(@"array = %@",_array);//循环引用警告
        };
        return self;
    }
    

还是会有循环引用的警告提示，因为循环引用的是self和block之间的事情，这个被Block持有的成员变量是strong还是weak都没有关系,而且即使是基本类型（assign）也是一样。

    @interface Person()
    @property (nonatomic, assign) NSInteger index;
    @end
    
    @implementation Person
    
    - (instancetype)init
    {
        self = [super init];
        blk_ = ^{
            NSLog(@"index = %ld",_index);//循环引用警告
        };
        return self;
    }
    

\_\_block修饰符
------------

    - (instancetype)init
    {
        self = [super init];
        __block id temp = self;//temp持有self
        
        //self持有blk_
        blk_ = ^{
            NSLog(@"self = %@",temp);//blk_持有temp
            temp = nil;
        };
        return self;
    }
    
    - (void)execBlc
    {
        blk_();
    }
    

所以如果不执行blk\_（将temp设为nil），则无法打破这个循环。

一旦执行了blk\_，就只有

*   self持有blk\_
*   blk\_持有temp

使用\_\_block 避免循环比较有什么特点呢？

*   通过\_\_block可以控制对象的持有时间。
*   为了避免循环引用必须执行block，否则循环引用一直存在。

所以我们应该根据实际情况，根据当前Block的用途来决定到底用\_\_block，还是\_\_weak或\_\_unsafe\_unretained。

这样第二章就讲解完了，总觉得还是差点什么，以后会持续更新和完善。  
本系列最后一篇会在下周一发布^^

扩展文献：
=====

1.  [深入研究Block捕获外部变量和\_\_block实现原理](https://www.jianshu.com/p/ee9756f3d5f6)
2.  [让我们来深入浅出block吧](https://www.jianshu.com/p/e03292674e60)
3.  [谈Objective-C block的实现](http://blog.devtang.com/2013/07/28/a-look-inside-blocks/)

* * *

本文已经同步到个人博客：[传送门](https://knightsj.github.io/2017/04/17/%E3%80%8AObjective-C%20%E9%AB%98%E7%BA%A7%E7%BC%96%E7%A8%8B%E3%80%8B%E5%B9%B2%E8%B4%A7%E4%B8%89%E9%83%A8%E6%9B%B2%EF%BC%88%E4%BA%8C%EF%BC%89%EF%BC%9ABlocks%E7%AF%87/)

本文已在版权印备案，如需转载请访问版权印。48422928

[获取授权](http://101702070004705.bqy.pub)

#### \-------------------------------- 2018年7月17日更新 --------------------------------

**注意注意！！！**

笔者在近期开通了个人公众号，主要分享编程，读书笔记，思考类的文章。

*   **编程类**文章：包括笔者以前发布的精选技术文章，以及后续发布的技术文章（以原创为主），并且逐渐脱离 iOS 的内容，将侧重点会转移到**提高编程能力**的方向上。
*   **读书笔记类**文章：分享**编程类**，**思考类**，**心理类**，**职场类**书籍的读书笔记。
*   **思考类**文章：分享笔者平时在**技术上**，**生活上**的思考。

> 因为公众号每天发布的消息数有限制，所以到目前为止还没有将所有过去的精选文章都发布在公众号上，后续会逐步发布的。

**而且因为各大博客平台的各种限制，后面还会在公众号上发布一些短小精干，以小见大的干货文章哦~**

扫下方的公众号二维码并点击关注，期待与您的共同成长~

公众号：程序员维他命