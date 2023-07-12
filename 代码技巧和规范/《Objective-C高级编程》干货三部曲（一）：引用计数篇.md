《Objective-C高级编程：iOS与OS X多线程和内存管理》

这本书有三个章节，我针对每一章节进行总结并加上适当的扩展分享给大家。可以从下面这张图来看一下这三篇的整体结构：

![](//upload-images.jianshu.io/upload_images/859001-169518e948933744.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

《Objective-C高级编程》 干货三部曲

> 注意，这个结构并不和书中的结构一致，而是以书中的结构为参考，稍作了调整。

本篇是第一篇：引用计数，简单说两句：  
Objective-C通过 retainCount 的机制来决定对象是否需要释放。 每次runloop迭代结束后，都会检查对象的 retainCount，如果retainCount等于0，就说明该对象没有地方需要继续使用它，可以被释放掉了。无论是手动管理内存，还是ARC机制，都是通过对retainCount来进行内存管理的。

先看一下手动内存管理：

手动内存管理
======

我个人觉得，学习一项新的技术之前，需要先了解一下它的核心思想。理解了核心思想之后，对技术点的把握就会更快一些：

内存管理的思想
-------

*   思想一：自己生成的对象，自己持有。
*   思想二：非自己生成的对象，自己也能持有。
*   思想三：不再需要自己持有的对象时释放对象。
*   思想四：非自己持有的对象无法释放。

从上面的思想来看，我们对对象的操作可以分为三种：生成，持有，释放，再加上废弃，一共有四种。它们所对应的Objective-C的方法和引用计数的变化是：

对象操作

Objecctive-C方法

引用计数的变化

生成并持有对象

alloc/new/copy/mutableCopy等方法

+1

持有对象

retain方法

+1

释放对象

release方法

\-1

废弃对象

dealloc方法

无

用书中的图来直观感受一下这四种操作：

![](//upload-images.jianshu.io/upload_images/859001-5ced77c57afcfab8.png?imageMogr2/auto-orient/strip|imageView2/2/w/671/format/webp)

图片来自：《Objective-C高级编程：iOS与OS X多线程和内存管理》

下面开始逐一解释上面的四条思想：

### 思想一：自己生成的对象，自己持有

在生成对象时，使用以下面名称开头的方法生成对象以后，就会持有该对象：

*   alloc
*   new
*   copy
*   mutableCopy

举个🌰：

    id obj = [[NSObject alloc] init];//持有新生成的对象
    

这行代码过后，指向生成并持有\[\[NSObject alloc\] init\]的指针被赋给了obj，也就是说obj这个指针强引用\[\[NSObject alloc\] init\]这个对象。

同样适用于new方法：

    id obj = [NSObject new];//持有新生成的对象
    

注意：  
这种将持有对象的指针赋给指针变量的情况不只局限于上面这四种方法名称，还包括以他们开头的所有方法名称：

*   allocThisObject
*   newThatObject
*   copyThisObject
*   mutableCopyThatObject

举个🌰：

    id obj1 = [obj0 allocObject];//符合上述命名规则，生成并持有对象
    

它的内部实现：

    - (id)allocObject
    {
        id obj = [[NSObject alloc] init];//持有新生成的对象
        return obj;
    }
    

反过来，如果不符合上述的命名规则，那么就不会持有生成的对象，  
看一个不符合上述命名规则的返回对象的createObject方法的内部实现🌰：

    - (id)createObject
    {
        id obj = [[NSObject alloc] init];//持有新生成的对象
        [obj autorelease];//取得对象，但自己不持有
        return obj;
    }
    

> 经由这个方法返回以后，无法持有这个返回的对象。因为这里使用了autorelease。autorelease提供了这样一个功能：在对象超出其指定的生存范围时能够自动并正确地释放（详细会在后面介绍）。

![](//upload-images.jianshu.io/upload_images/859001-97b23d0108e4cadf.png?imageMogr2/auto-orient/strip|imageView2/2/w/756/format/webp)

图片来自：《Objective-C高级编程：iOS与OS X多线程和内存管理》

> 也就是说，生成一个调用方不持有的对象是可以通过autorelease来实现的（例如NSMutableArray的array类方法）。

> 我的个人理解是：通过autorelease方法，使对象的持有权转移给了自动释放池。所以实现了：调用方拿到了对象，但这个对象还不被调用方所持有。

由这个不符合命名规则的例子来引出思想二：

### 思想二：非自己生成的对象，自己也能持有

我们现在知道，仅仅通过上面那个不符合命名规则的返回对象实例的方法是无法持有对象的。但是我们可以通过某个操作来持有这个返回的对象：这个方法就是通过retain方法来让指针变量持有这个新生成的对象：

    id obj = [NSMutableArray array];//非自己生成并持有的对象
    [obj retain];//持有新生成的对象
    

> 注意，这里\[NSMutableArray array\]返回的非自己持有的对象正是通过上文介绍过的autorelease方法实现的。所以如果想持有这个对象，需要执行retain方法才可以。

### 思想三：不再需要自己持有的对象时释放对象

对象的持有者**有义务**在不再需要这个对象的时候**主动**将这个对象释放。注意，是**有义务**，而不是有权利，注意两个词的不同。

来看一下释放对象的例子：

    id obj = [[NSObject alloc] init];//持有新生成的对象
    [obj doSomething];//使用该对象做一些事情
    [obj release];//事情做完了，释放该对象
    

同样适用于非自己生成并持有的对象（参考思想二）：

    id obj = [NSMutableArray array];//非自己生成并持有的对象
    [obj retain];//持有新生成的对象
    [obj soSomething];//使用该对象做一些事情
    [obj release];//事情做完了，释放该对象
    

> **可能遇到的面试题**：调用对象的release方法会销毁对象吗？  
> 答案是不会：调用对象的release方法只是将对象的引用计数器-1，当对象的引用计数器为0的时候会调用了对象的dealloc 方法才能进行释放对象的内存。

### 思想四：无法释放非自己持有的对象

在释放对象的时候，我们只能释放已经持有的对象，非自己持有的对象是不能被自己释放的。这很符合常识：就好比你自己才能从你自己的银行卡里取钱，取别人的卡里的钱是不对的（除非他的钱归你管。。。只是随便举个例子）。

#### 两种不允许的情况：

#### 1\. 释放一个已经废弃了的对象

    id obj = [[NSObject alloc] init];//持有新生成的对象
    [obj doSomething];//使用该对象
    [obj release];//释放该对象，不再持有了
    [obj release];//释放已经废弃了的对象，崩溃
    

#### 2\. 释放自己不持有的对象

    id obj = [NSMutableArray array];//非自己生成并持有的对象
    [obj release];//释放了非自己持有的对象
    

思考：哪些情况会使对象失去拥有者呢？

1.  将指向某对象的指针变量指向另一个对象。
2.  将指向某对象的指针变量设置为nil。
3.  当程序释放对象的某个拥有者时。
4.  从collection类中删除对象时。

现在知道了引用计数式内存管理的四个思想，我们再来看一下四个操作引用计数的方法：

alloc/retain/release/dealloc的实现
-------------------------------

某种意义上，GNUstep 和 Foundation 框架的实现是相似的。所以这本书的作者通过GNUstep的源码来推测了苹果Cocoa框架的实现。

下面开始针对每一个方法，同时用GNUstep和苹果的实现方式（追踪程序的执行和作者的猜测）来对比一下各自的实现。

### GNUstep实现：

#### alloc方法

    //GNUstep/modules/core/base/Source/NSObject.m alloc:
    
    + (id) alloc
    {
        return [self allocWithZone: NSDefaultMallocZone()];
    }
     
    + (id) allocWithZone: (NSZone*)z
    {
        return NSAllocateObject(self, 0, z);
    }
    

这里NSAllocateObject方法分配了对象，看一下它的内部实现：

    //GNUstep/modules/core/base/Source/NSObject.m NSAllocateObject:
    
    struct obj_layout {
        NSUInteger retained;
    };
     
    NSAllocateObject(Class aClass, NSUInteger extraBytes, NSZone *zone)
    {
        int size = 计算容纳对象所需内存大小;
        id new = NSZoneMalloc(zone, 1, size);//返回新的实例
        memset (new, 0, size);
        new = (id)&((obj)new)[1];
    }
    

> 1.  NSAllocateObject函数通过NSZoneMalloc函数来分配存放对象所需要的内存空间。
> 2.  obj\_layout是用来保存引用计数，并将其写入对象内存头部。

对象的引用计数可以通过retainCount方法来取得：

    GNUstep/modules/core/base/Source/NSObject.m retainCount:
    
    - (NSUInteger) retainCount
    {
        return NSExtraRefCount(self) + 1;
    }
     
    inline NSUInteger
    NSExtraRefCount(id anObject)
    {
        return ((obj_layout)anObject)[-1].retained;
    }
    

我们可以看到，给NSExtraRefCount传入anObject以后，通过访问对象内存头部的.retained变量，来获取引用计数。

#### retain方法

    //GNUstep/modules/core/base/Source/NSObject.m retain:
    
    - (id)retain
    {
        NSIncrementExtraRefCount(self);
        return self;
    }
     
    inline void NSIncrementExtraRefCount(id anObject)
    {
        //retained变量超出最大值,抛出异常
        if (((obj)anObject)[-1].retained == UINT_MAX - 1){
            [NSException raise: NSInternalInconsistencyException
            format: @"NSIncrementExtraRefCount() asked to increment too far”];
        }
        
        ((obj_layout)anObject)[-1].retained++;//retained变量+1
    }
    

#### release方法

    //GNUstep/modules/core/base/Source/NSObject.m release
    
    - (void)release
    {
        //如果当前的引用计数 = 0，调用dealloc函数
        if (NSDecrementExtraRefCountWasZero(self))
        {
            [self dealloc];
        }
    }
     
    BOOL NSDecrementExtraRefCountWasZero(id anObject)
    {
        //如果当前的retained值 = 0.则返回yes
        if (((obj)anObject)[-1].retained == 0){
            return YES;
        }
        
        //如果大于0，则-1，并返回NO
        ((obj)anObject)[-1].retained--;
        return NO;
    }
    

#### dealloc方法

    //GNUstep/modules/core/base/Source/NSObject.m dealloc
    
    - (void) dealloc
    {
        NSDeallocateObject (self);
    }
     
    inline void NSDeallocateObject(id anObject)
    {
        obj_layout o = &((obj_layout)anObject)[-1];
        free(o);//释放
    }
    

总结一下上面的几个方法：

*   Objective-C对象中保存着引用计数这一整数值。
*   调用alloc或者retain方法后，引用计数+1。
*   调用release后，引用计数-1。
*   引用计数为0时，调用dealloc方法废弃对象。

下面看一下苹果的实现：

### 苹果的实现

#### alloc方法

通过在NSObject类的alloc类方法上设置断点，我们可以看到执行所调用的函数：

*   +alloc
*   +allocWithZone:
*   class\_createInstance//生成实例
*   calloc//分配内存块

retainCount:

*   \_\_CFdoExternRefOperation
*   CFBasicHashGetCountOfKey

#### retain方法

*   \_\_CFdoExternRefOperation
*   CFBasicHashAddValue

#### release方法

*   \_\_CFdoExternRefOperation
*   CFBasicHashRemoveValue

我们可以看到他们都调用了一个共同的 \_\_CFdoExternRefOperation 方法。

看一下它的实现：

    int __CFDoExternRefOperation(uintptr_t op, id obj) {
    
        CFBasicHashRef table = 取得对象的散列表(obj);
        int count;
     
        switch (op) {
        case OPERATION_retainCount:
            count = CFBasicHashGetCountOfKey(table, obj);
            return count;
            break;
    
        case OPERATION_retain:
            count = CFBasicHashAddValue(table, obj);
            return obj;
        
        case OPERATION_release:
            count = CFBasicHashRemoveValue(table, obj);
            return 0 == count;
        }
    }
    

可以看出，\_\_CFDoExternRefOperation通过switch语句 针对不同的操作来进行具体的方法调用，如果 op 是 OPERATION\_retain，就去掉用具体实现 retain 的方法，以此类推。

可以猜想上层的retainCount,retain,release方法的实现：

    - (NSUInteger)retainCount
    {
        return (NSUInteger)____CFDoExternRefOperation(OPERATION_retainCount,self);
    }
    
    - (id)retain
    {
        return (id)____CFDoExternRefOperation(OPERATION_retain,self);
    }
    
    //这里返回值应该是id，原书这里应该是错了
    - (id)release
    {
        return (id)____CFDoExternRefOperation(OPERATION_release,self);
    }
    

我们观察一下switch里面每个语句里的执行函数名称，似乎和散列表（Hash）有关，这说明苹果对引用计数的管理应该是通过散列表来执行的。

图片来自：《Objective-C高级编程：iOS与OS X多线程和内存管理》

在这张表里，key为内存块地址，而对应的值为引用计数。也就是说，它保存了这样的信息：一些被引用的内存块各自对应的引用计数。

那么使用散列表来管理内存有什么好处呢？

因为计数表保存内存块地址，我们就可以通过这张表来：

*   确认损坏内存块的位置。
*   在检测内存泄漏时，可以查看各对象的持有者是否存在。

autorelease
-----------

### autorelease 介绍

当对象超出其作用域时，对象实例的release方法就会被调用，autorelease的具体使用方法如下：

1.  生成并持有NSAutoreleasePool对象。
2.  调用已分配对象的autorelease方法。
3.  废弃NSAutoreleasePool对象。

图片来自：《Objective-C高级编程：iOS与OS X多线程和内存管理》

所有调用过autorelease方法的对象，在废弃NSAutoreleasePool对象时，都将调用release方法（引用计数-1）：

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    id obj = [[NSObject alloc] init];
    [obj autorelease];
    [pool drain];//相当于obj调用release方法
    

NSRunLoop在每次循环过程中，NSAutoreleasePool对象都会被生成或废弃。  
也就是说，如果有大量的autorelease变量，在NSAutoreleasePool对象废弃之前（一旦监听到RunLoop即将进入睡眠等待状态，就释放NSAutoreleasePool），都不会被销毁，容易导致内存激增的问题:

    for (int i = 0; i < imageArray.count; i++)
    {
        UIImage *image = imageArray[i];
        [image doSomething];
    }
    

图片来自：《Objective-C高级编程：iOS与OS X多线程和内存管理》

因此，我们有必要在适当的时候再嵌套一个自动释放池来管理临时生成的autorelease变量：

    for (int i = 0; i < imageArray.count; i++)
    {
        //临时pool
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        UIImage *image = imageArray[i];
        [image doSomething];
        [pool drain];
    }
    

图片来自：《Objective-C高级编程：iOS与OS X多线程和内存管理》

> 可能会出的面试题：什么时候会创建自动释放池？  
> 答：运行循环检测到事件并启动后，就会创建自动释放池，而且子线程的 runloop 默认是不工作的，无法主动创建，必须手动创建。  
> 举个🌰：  
> 自定义的 NSOperation 类中的 main 方法里就必须添加自动释放池。否则在出了作用域以后，自动释放对象会因为没有自动释放池去处理自己而造成内存泄露。

### autorelease实现

和上文一样，我们还是通过GNUstep和苹果的实现来分别看一下。

#### GNUstep 实现

    //GNUstep/modules/core/base/Source/NSObject.m autorelease
    
    - (id)autorelease
    {
        [NSAutoreleasePool addObject:self];
    }
    

如果调用NSObject类的autorelease方法，则该对象就会被追加到正在使用的NSAutoreleasePool对象中的数组里（作者假想了一个简化的源代码）：

    //GNUstep/modules/core/base/Source/NSAutoreleasePool.m addObject
    
    + (void)addObject:(id)anObj
    {
        NSAutoreleasePool *pool = 取得正在使用的NSAutoreleasePool对象
        if (pool != nil){
            [pool addObject:anObj];
        }else{
            NSLog(@"NSAutoreleasePool对象不存在");
        }
    }
    
    - (void)addObject:(id)anObj
    {
        [pool.array addObject:anObj];
    }
    

也就是说，autorelease实例方法的本质就是调用NSAutoreleasePool对象的addObject类方法，然后这个对象就被追加到正在使用的NSAutoreleasePool对象中的数组里。

再来看一下NSAutoreleasePool的drain方法：

    - (void)drain
    {
        [self dealloc];
    }
    
    - (void)dealloc
    {
        [self emptyPool];
        [array release];
    }
    
    - (void)emptyPool
    {
        for(id obj in array){
            [obj release];
        }
    }
    

我们可以看到，在emptyPool方法里，确实是对数组里每一个对象进行了release操作。

#### 苹果的实现

我们可以通过objc4/NSObject.mm来确认苹果中autorelease的实现：

    objc4/NSObject.mm AutoreleasePoolPage
     
    class AutoreleasePoolPage
    {
        static inline void *push()
        {
            //生成或者持有 NSAutoreleasePool 类对象
        }
    
        static inline void pop(void *token)
        {
            //废弃 NSAutoreleasePool 类对象
            releaseAll();
        }
        
        static inline id autorelease(id obj)
        {
            //相当于 NSAutoreleasePool 类的 addObject 类方法
            AutoreleasePoolPage *page = 取得正在使用的 AutoreleasePoolPage 实例;
           autoreleaesPoolPage->add(obj)
        }
    
        id *add(id obj)
        {   
            //将对象追加到内部数组中
        }
        
        void releaseAll()
        {
            //调用内部数组中对象的 release 方法
        }
    };
    
    //压栈
    void *objc_autoreleasePoolPush(void)
    {
        if (UseGC) return nil;
        return AutoreleasePoolPage::push();
    }
     
    //出栈
    void objc_autoreleasePoolPop(void *ctxt)
    {
        if (UseGC) return;
        AutoreleasePoolPage::pop(ctxt);
    }
    

来看一下外部的调用：

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // 等同于 objc_autoreleasePoolPush
     
    id obj = [[NSObject alloc] init];
    [obj autorelease];
    // 等同于 objc_autorelease(obj)
     
    [NSAutoreleasePool showPools];
    // 查看 NSAutoreleasePool 状况
     
    [pool drain];
    // 等同于 objc_autoreleasePoolPop(pool)
    

看函数名就可以知道，对autorelease分别执行push、pop操作。销毁对象时执行release操作。

> **可能出现的面试题：苹果是如何实现autoreleasepool的？**  
> autoreleasepool以栈的数据结构实现,主要通过下列三个函数完成.  
> • objc\_autoreleasepoolPush（压入）  
> • objc\_autoreleasepoolPop（弹出）  
> • objc\_autorelease（释放内部）

ARC内存管理
=======

内存管理的思想
-------

上面学习了非ARC机制下的手动管理内存思想，针对引用计数的操作和自动释放池的相关内容。现在学习一下在ARC机制下的相关知识。

ARC和非ARC机制下的内存管理思想是一致的：

*   自己生成的对象，自己持有。
*   非自己生成的对象，自己也能持有。
*   不再需要自己持有的对象时释放对象。
*   非自己持有的对象无法释放。

在ARC机制下，编译器就可以自动进行内存管理，减少了开发的工作量。但我们有时仍需要四种所有权修饰符来配合ARC来进行内存管理

四种所有权修饰符
--------

但是，在ARC机制下我们有的时候需要追加所有权声明(以下内容摘自官方文档)：

*   **\_\_strong**：is the default. An object remains “alive” as long as there is a strong pointer to it.
*   **\_\_weak**：specifies a reference that does not keep the referenced object alive. A weak reference is set to nil when there are no strong references to the object.
*   **\_\_unsafe\_unretained**：specifies a reference that does not keep the referenced object alive and is not set to nil when there are no strong references to the object. If the object it references is deallocated, the pointer is left dangling.
*   **\_\_autoreleasing**：is used to denote arguments that are passed by reference (id \*) and are autoreleased on return.

下面分别讲解一下这几个修饰符：

### \_\_strong修饰符

\_\_strong修饰符 是id类型和对象类型默认的所有权修饰符：

#### \_\_strong使用方法：

    id obj = [NSObject alloc] init];
    

等同于：

    id __strong obj = [NSObject alloc] init];
    

看一下内存管理的过程：

    {
        id __strong obj = [NSObject alloc] init];//obj持有对象
    }
    //obj超出其作用域，强引用失效
    

> \_\_strong修饰符表示对对象的强引用。持有强引用的变量在超出其作用域时被废弃。

在\_\_strong修饰符修饰的变量之间相互赋值的情况：

    id __strong obj0 = [[NSObject alloc] init];//obj0 持有对象A
    id __strong obj1 = [[NSObject alloc] init];//obj1 持有对象B
    id __strong obj2 = nil;//ojb2不持有任何对象
    obj0 = obj1;//obj0强引用对象B；而对象A不再被ojb0引用，被废弃
    obj2 = obj0;//obj2强引用对象B（现在obj0，ojb1，obj2都强引用对象B）
    obj1 = nil;//obj1不再强引用对象B
    obj0 = nil;//obj0不再强引用对象B
    obj2 = nil;//obj2不再强引用对象B，不再有任何强引用引用对象B，对象B被废弃
    

> 而且，\_\_strong可以使一个变量初始化为nil：id \_\_strong obj0;  
> 同样适用于：id \_\_weak obj1; id \_\_autoreleasing obj2;

做个总结：被\_\_strong修饰后，相当于强引用某个对象。对象一旦有一个强引用引用自己，引用计数就会+1，就不会被系统废弃。而这个对象如果不再被强引用的话，就会被系统废弃。

#### \_\_strong内部实现：

生成并持有对象：

    {
        id __strong obj = [NSObject alloc] init];//obj持有对象
    }
    

编译器的模拟代码：

    id obj = objc_mesgSend(NSObject, @selector(alloc));
    objc_msgSend(obj,@selector(init));
    objc_release(obj);//超出作用域，释放对象
    

再看一下使用命名规则以外的构造方法：

    {
        id __strong obj = [NSMutableArray array];
    }
    

编译器的模拟代码：

    id obj = objc_msgSend(NSMutableArray, @selector(array));
    objc_retainAutoreleasedReturnValue(obj);
    objc_release(obj);
    

> objc\_retainAutoreleasedReturnValue的作用：持有对象，将对象注册到autoreleasepool并返回。

同样也有objc\_autoreleaseReturnValue，来看一下它的使用：

    + (id)array
    {
       return [[NSMutableArray alloc] init];
    }
    

编译器的模拟代码：

    + (id)array
    {
       id obj = objc_msgSend(NSMutableArray, @selector(alloc));
       objc_msgSend(obj,, @selector(init));
       return objc_autoreleaseReturnValue(obj);
    }
    

> objc\_autoreleaseReturnValue:返回注册到autoreleasepool的对象。

### \_\_weak修饰符

#### \_\_weak使用方法：

\_\_weak修饰符大多解决的是循环引用的问题：如果两个对象都互相强引用对方，同时都失去了外部对自己的引用，那么就会形成“孤岛”，这个孤岛将永远无法被释放，举个🌰：

    @interface Test:NSObject
    {
        id __strong obj_;
    }
    
    - (void)setObject:(id __strong)obj;
    @end
    
    @implementation Test
    - (id)init
    {
        self = [super init];
        return self;
    }
    
    - (void)setObject:(id __strong)obj
    {
        obj_ = obj;
    }
    @end
    

    {
        id test0 = [[Test alloc] init];//test0强引用对象A
        id test1 = [[Test alloc] init];//test1强引用对象B
        [test0 setObject:test1];//test0强引用对象B
        [test1 setObject:test0];//test1强引用对象A
    }
    

因为生成对象（第一，第二行）和set方法（第三，第四行）都是强引用，所以会造成两个对象互相强引用对方的情况：

《Objective-C高级编程：iOS与OS X多线程和内存管理》

所以，我们需要打破其中一种强引用：

    @interface Test:NSObject
    {
        id __weak obj_;//由__strong变成了__weak
    }
    
    - (void)setObject:(id __strong)obj;
    @end
    

这样一来，二者就只是弱引用对方了：

《Objective-C高级编程：iOS与OS X多线程和内存管理》

#### \_\_weak内部实现

    {
        id __weak obj1 = obj;
    }
    

编译器的模拟代码：

    id obj1;
    objc_initWeak(&obj1,obj);//初始化附有__weak的变量
    id tmp = objc_loadWeakRetained(&obj1);//取出附有__weak修饰符变量所引用的对象并retain
    objc_autorelease(tmp);//将对象注册到autoreleasepool中
    objc_destroyWeak(&obj1);//释放附有__weak的变量
    

> 这确认了\_\_weak的一个功能：使用附有\_\_weak修饰符的变量，即是使用注册到autoreleasepool中的对象。

这里需要着重讲解一下objc\_initWeak方法和objc\_destroyWeak方法：

*   objc\_initWeak:初始化附有\_\_weak的变量，具体通过执行objc\_strongWeak(&obj1, obj)方法，将obj对象以&obj1作为key放入一个weak表（Hash）中。
*   objc\_destroyWeak：释放附有\_\_weak的变量。具体通过执行objc\_storeWeak(&obj1,0)方法，在weak表中查询&obj1这个键，将这个键从weak表中删除。

> 注意：因为同一个对象可以赋值给多个附有\_\_weak的变量中，所以对于同一个键值，可以注册多个变量的地址。

当一个对象不再被任何人持有，则需要释放它，过程为：

*   objc\_dealloc
*   dealloc
*   \_objc\_rootDealloc
*   objc\_dispose
*   objc\_destructInstance
*   objc\_clear\_deallocating
    *   从weak表中获取废弃对象的地址
    *   将包含在记录中的所有附有\_\_weak修饰符变量的地址赋值为nil
    *   从weak表中删除该记录
    *   从引用计数表中删除废弃对象的地址

### \_\_autoreleasing修饰符

#### \_\_autoreleasing使用方法

ARC下，可以用@autoreleasepool来替代NSAutoreleasePool类对象，用\_\_autoreleasing修饰符修饰变量来替代ARC无效时调用对象的autorelease方法（对象被注册到autoreleasepool）。

《Objective-C高级编程：iOS与OS X多线程和内存管理》

说到\_\_autoreleasing修饰符，就不得不提\_\_weak：

    id  __weak obj1 = obj0;
    NSLog(@"class = %@",[obj1 class]);
    

等同于：

    id __weak obj1 = obj0;
    id __autoreleasing tmp = obj1;
    NSLog(@"class = %@",[tmp class]);//实际访问的是注册到自动个释放池的对象
    

注意一下两段等效的代码里，NSLog语句里面访问的对象是不一样的，它说明：在访问\_\_weak修饰符的变量（obj1）时必须访问注册到autoreleasepool的对象（tmp）。为什么呢？

因为\_\_weak修饰符只持有对象的弱引用，也就是说在将来访问这个对象的时候，无法保证它是否还没有被废弃。因此，如果把这个对象注册到autoreleasepool中，那么在@autoreleasepool块结束之前都能确保该对象存在。

#### \_\_autoreleasing内部实现

将对象赋值给附有\_\_autoreleasing修饰符的变量等同于ARC无效时调用对象的autorelease方法。

    @autoreleasepool{
        id __autoreleasing obj = [[NSObject alloc] init];
    }
    

编译器的模拟代码：

    id pool = objc_autoreleasePoolPush();//pool入栈
    id obj = objc_msgSend(NSObject, @selector(alloc));
    objc_msgSend(obj, @selector(init));
    objc_autorelease(obj);
    objc_autoreleasePoolPop(pool);//pool出栈
    

> 在这里我们可以看到pool入栈，执行autorelease，出栈的三个方法。

ARC下的规则
-------

我们知道了在ARC机制下编译器会帮助我们管理内存，但是在编译期，我们还是要遵守一些规则，作者为我们列出了以下的规则：

1.  不能使用retain/release/retainCount/autorelease
2.  不能使用NSAllocateObject/NSDeallocateObject
3.  必须遵守内存管理的方法名规则
4.  不要显式调用dealloc
5.  使用@autorelease块代替NSAutoreleasePool
6.  不能使用区域（NSZone）
7.  对象型变量不能作为C语言结构体的成员
8.  显式转换id和void\*

### 1\. 不能使用retain/release/retainCount/autorelease

在ARC机制下使用retain/release/retainCount/autorelease方法，会导致编译器报错。

### 2\. 不能使用NSAllocateObject/NSDeallocateObject

在ARC机制下使用NSAllocateObject/NSDeallocateObject方法，会导致编译器报错。

### 3\. 必须遵守内存管理的方法名规则

对象的生成／持有的方法必须遵循以下命名规则：

*   alloc
*   new
*   copy
*   mutableCopy
*   init

前四种方法已经介绍完。而关于init方法的要求则更为严格：

*   必须是实例方法
*   必须返回对象
*   返回对象的类型必须是id类型或方法声明类的对象类型

### 4\. 不要显式调用dealloc

对象被废弃时，无论ARC是否有效，系统都会调用对象的dealloc方法。

我们只能在dealloc方法里写一些对象被废弃时需要进行的操作（例如移除已经注册的观察者对象）但是不能手动调用dealloc方法。

注意在ARC无效的时候，还需要调用\[super dealloc\]：

    - (void)dealloc
    {
        //该对象的处理
        [super dealloc];
    }
    

### 5\. 使用@autorelease块代替NSAutoreleasePool

ARC下须使用使用@autorelease块代替NSAutoreleasePool。

### 6\. 不能使用区域（NSZone）

NSZone已经在目前的运行时系统（**OBC2**被设定的环境）被忽略了。

### 7\. 对象型变量不能作为C语言结构体的成员

C语言的结构体如果存在Objective-C对象型变量，便会引起错误，因为C语言在规约上没有方法来管理结构体成员的生存周期 。

### 8\. 显式转换id和void\*

非ARC下，这两个类型是可以直接赋值的

    id obj = [NSObject alloc] init];
    void *p = obj;
    id o = p;
    

但是在ARC下就会引起编译错误。为了避免错误，我们需要通过\_\_bridege来转换。

    id obj = [[NSObject alloc] init];
    void *p = (__bridge void*)obj;//显式转换
    id o = (__bridge id)p;//显式转换
    

属性
--

来看一下属性的声明与所有权修饰符的关系

属性关键字

所有权 修饰符

assign

\_\_unsafe\_unretained

copy

\_\_strong

retain

\_\_strong

strong

\_\_strong

\_\_unsafe\_unretained

\_\_unsafe\_unretained

weak

\_\_weak

说一下\_\_unsafe\_unretained：  
\_\_unsafe\_unretained表示存取方法会直接为实例变量赋值。

这里的“unsafe”是相对于weak而言的。我们知道weak指向的对象被销毁时，指针会自动设置为nil。而\_\_unsafe\_unretained却不会，而是成为空指针。需要注意的是：当处理非对象属性的时候就不会出现空指针的问题。

这样第一章就介绍完了，第二篇会在下周一发布^^

#### 扩展文献：

1.  [Apple:Transitioning to ARC Release Notes](https://developer.apple.com/library/content/releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html)
2.  [蚊香酱:可能是史上最全面的内存管理文章](https://www.jianshu.com/p/6cf682f90fa2)
3.  [微笑和飞飞:可能碰到的iOS笔试面试题（6）--内存管理](https://www.jianshu.com/p/0ad9957e3716)
4.  [《iOS编程(第4版)》](https://www.amazon.cn/%E5%9B%BE%E4%B9%A6/dp/B00RWORA1O/ref=sr_1_1?ie=UTF8&qid=1491531635&sr=8-1&keywords=ios%E7%BC%96%E7%A8%8B)

* * *

本文已经同步到个人博客：[传送门](https://knightsj.github.io/2017/04/10/%E3%80%8AObjective-C%20%E9%AB%98%E7%BA%A7%E7%BC%96%E7%A8%8B%E3%80%8B%E5%B9%B2%E8%B4%A7%E4%B8%89%E9%83%A8%E6%9B%B2%EF%BC%88%E4%B8%80%EF%BC%89%EF%BC%9A%E5%BC%95%E7%94%A8%E8%AE%A1%E6%95%B0%E7%AF%87/)

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