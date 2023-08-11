# objc_msgSend的三个阶段(消息发送、动态解析方法、消息转发)、super的本质

一、objc\_msgSend消息发送
===================

过一段代码，将方法调用代码转为c++代码查看方法调用的本质是什么样的。  
`xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m`

    [person test];
    //  --------- c++底层代码
    ((void (*)(id, SEL))(void *)objc_msgSend)((id)person, sel_registerName("test"));
    复制代码

通过上述源码可以看出:

*   c++底层代码中方法调用其实都是转化为 `objc_msgSend`函数
*   OC的方法调用也叫`消息机制`，表示`给方法调用者发送消息`。
*   拿上述代码举例，上述代码中实际为: 给person实例对象发送一条test消息：
    *   消息接受者：person
    *   消息名称：test

> **方法调用的过程** 方法调用的过程 实际上分为三个阶段:
> 
> *   **消息发送阶段:** 负责从类及父类的缓存列表及方法列表查找方法;
> *   **动态解析阶段:** 如果消息发送阶段没有找到方法，则会进入动态解析阶段，负责动态的添加方法实现;
> *   **消息转发阶段:** 如果也没有实现动态解析方法，则会进行消息转发阶段，将消息转发给可以处理消息的接受者来处理;
> 
> *   如果消息转发也没有实现，就会报方法找不到的错误，无法识别消息，`unrecognzied selector sent to instance`

接下来我们通过阅读`runtime`源码,探寻一下OC的方法调用的三个阶段分别是如何实现的:

1\. 消息发送
--------

在`runtime`源码中搜索`_objc_msgSend`查看其内部实现，在`objc-msg-arm64.s`汇编文件可以知道`_objc_msgSend`函数的实现

        ENTRY _objc_msgSend
        UNWIND _objc_msgSend, NoFrame
        MESSENGER_START
    
        cmp	x0, #0			// nil check and tagged pointer check
        b.le	LNilOrTagged		//  (MSB tagged pointer looks negative)
        ldr	x13, [x0]		// x13 = isa
        and	x16, x13, #ISA_MASK	// x16 = class	
    LGetIsaDone:
        CacheLookup NORMAL		// calls imp or objc_msgSend_uncached
    复制代码

上述汇编源码中会首先判断消息接受者`reveiver`的值。

*   如果传入的消息接受者为nil则会执行`LNilOrTagged`
    *   `LNilOrTagged`内部会执行`LReturnZero`
    *   而`LReturnZero`内部则直接return0
*   如果传入的消息接受者不为nill则执行`CacheLookup`
    *   `CacheLookup`内部对方法缓存列表进行查找
    *   如果找到则执行`CacheHit`，进而调用方法
    *   否则执行`CheckMiss`
        *   `CheckMiss`内部调用`__objc_msgSend_uncached`
        *   `__objc_msgSend_uncached`内会执行`MethodTableLookup`
        *   `MethodTableLookup`也就是方法列表查找
        *   `MethodTableLookup`内部的核心代码`__class_lookupMethodAndLoadCache3`
        *   `__class_lookupMethodAndLoadCache3`也就是C语言函数`_class_lookupMethodAndLoadCache3`
*   **C函数`_class_lookupMethodAndLoadCache3`函数内部则是对方法查找的核心代码**

> **首先通过一张图看一下汇编语言中\_objc\_msgSend的运行流程**

![消息发送流程](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/93ee0268261643e9be9db767957d8c0b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

方法查找的核心函数就是`_class_lookupMethodAndLoadCache3`函数，接下来重点分析`_class_lookupMethodAndLoadCache3`函数内的源码。

### 1.1 `_class_lookupMethodAndLoadCache3` 函数

    IMP _class_lookupMethodAndLoadCache3(id obj, SEL sel, Class cls)
    {
        return lookUpImpOrForward(cls, sel, obj, 
                                  YES/*initialize*/, NO/*cache*/, YES/*resolver*/);
    } 
    复制代码

### 1.2 `lookUpImpOrForward` 函数

    IMP lookUpImpOrForward(Class cls, SEL sel, id inst, 
                           bool initialize, bool cache, bool resolver)
    {
        // initialize = YES , cache = NO , resolver = YES
        IMP imp = nil;
        bool triedResolver = NO;
        runtimeLock.assertUnlocked();
    
        // 缓存查找, 因为cache传入的为NO, 这里不会进行缓存查找, 因为在汇编语言中CacheLookup已经查找过
        if (cache) {
            imp = cache_getImp(cls, sel);
            if (imp) return imp;
        }
    
        runtimeLock.read();
        if (!cls->isRealized()) {
            runtimeLock.unlockRead();
            runtimeLock.write();
            realizeClass(cls);
            runtimeLock.unlockWrite();
            runtimeLock.read();
        }
        if (initialize  &&  !cls->isInitialized()) {
            runtimeLock.unlockRead();
            _class_initialize (_class_getNonMetaClass(cls, inst));
            runtimeLock.read();
        }
    
     retry:    
        runtimeLock.assertReading();
    
        // 防止动态添加方法，缓存会变化，再次查找缓存。
        imp = cache_getImp(cls, sel);
        // 如果查找到imp, 直接调用done, 返回方法地址
        if (imp) goto done;
    
        // 查找方法列表, 传入类对象和方法名
        {
            // 根据sel去类对象里面查找方法
            Method meth = getMethodNoSuper_nolock(cls, sel);
            if (meth) {
                // 如果方法存在，则缓存方法，
                // 内部调用的就是 cache_fill 上文中已经详细讲解过这个方法，这里不在赘述了。
                log_and_fill_cache(cls, meth->imp, sel, inst, cls);
                // 方法缓存之后, 取出imp, 调用done返回imp
                imp = meth->imp;
                goto done;
            }
        }
    
        // 如果类方法列表中没有找到, 则去父类的缓存中或方法列表中查找方法
        {
            unsigned attempts = unreasonableClassCount();
            // 如果父类缓存列表及方法列表均找不到方法，则去父类的父类去查找。
            for (Class curClass = cls->superclass;
                 curClass != nil;
                 curClass = curClass->superclass)
            {
                // Halt if there is a cycle in the superclass chain.
                if (--attempts == 0) {
                    _objc_fatal("Memory corruption in class list.");
                }
                
                // 查找父类的缓存
                imp = cache_getImp(curClass, sel);
                if (imp) {
                    if (imp != (IMP)_objc_msgForward_impcache) {
                        // 在父类中找到方法, 在本类中缓存方法, 注意这里传入的是cls, 将方法缓存在本类缓存列表中, 而非父类中
                        log_and_fill_cache(cls, imp, sel, inst, curClass);
                        // 执行done, 返回imp
                        goto done;
                    }
                    else {
                        // 跳出循环, 停止搜索
                        break;
                    }
                }
                
                // 查找父类的方法列表
                Method meth = getMethodNoSuper_nolock(curClass, sel);
                if (meth) {
                    // 同样拿到方法, 在本类进行缓存
                    log_and_fill_cache(cls, meth->imp, sel, inst, curClass);
                    imp = meth->imp;
                    // 执行done, 返回imp
                    goto done;
                }
            }
        }
        
        // ---------------- 消息发送阶段完成 ---------------------
    
        // ---------------- 进入动态解析阶段 ---------------------
        // 上述列表中都没有找到方法实现, 则尝试解析方法
        if (resolver  &&  !triedResolver) {
            runtimeLock.unlockRead();
            _class_resolveMethod(cls, sel, inst);
            runtimeLock.read();
            triedResolver = YES;
            goto retry;
        }
    
        // ---------------- 动态解析阶段完成 ---------------------
    
        // ---------------- 进入消息转发阶段 ---------------------
        imp = (IMP)_objc_msgForward_impcache;
        cache_fill(cls, sel, imp, inst);
    
     done:
        runtimeLock.unlockRead();
        // 返回方法地址
        return imp;
    } 
    复制代码

### 1.3 `getMethodNoSuper_nolock` 函数

方法列表中查找方法

    getMethodNoSuper_nolock(Class cls, SEL sel)
    {
        runtimeLock.assertLocked();
        assert(cls->isRealized());
        // cls->data() 得到的是 class_rw_t
        // class_rw_t->methods 得到的是methods二维数组
        for (auto mlists = cls->data()->methods.beginLists(), 
                  end = cls->data()->methods.endLists(); 
             mlists != end;
             ++mlists)
        {
             // mlists 为 method_list_t
            method_t *m = search_method_list(*mlists, sel);
            if (m) return m;
        }
        return nil;
    } 
    复制代码

上述源码中:

*   `getMethodNoSuper_nolock`函数中通过遍历方法列表拿到`method_list_t`
*   最终通过`search_method_list`函数查找方法

#### 1.3.1 `search_method_list`函数

    static method_t *search_method_list(const method_list_t *mlist, SEL sel)
    {
        int methodListIsFixedUp = mlist->isFixedUp();
        int methodListHasExpectedSize = mlist->entsize() == sizeof(method_t);
        // 如果方法列表是有序的，则使用二分法查找方法，节省时间
        if (__builtin_expect(methodListIsFixedUp && methodListHasExpectedSize, 1)) {
            return findMethodInSortedMethodList(sel, mlist);
        } else {
            // 否则则遍历列表查找
            for (auto& meth : *mlist) {
                if (meth.name == sel) return &meth;
            }
        }
        return nil;
    } 
    复制代码

#### 1.3.2 `findMethodInSortedMethodList`函数内二分查找实现原理

    static method_t *findMethodInSortedMethodList(SEL key, const method_list_t *list)
    {
        assert(list);
    
        const method_t * const first = &list->first;
        const method_t *base = first;
        const method_t *probe;
        uintptr_t keyValue = (uintptr_t)key;
        uint32_t count;
        // >>1 表示将变量n的各个二进制位顺序右移1位，最高位补二进制0。
        // count >>= 1 如果count为偶数则值变为(count / 2)。如果count为奇数则值变为(count-1) / 2 
        for (count = list->count; count != 0; count >>= 1) {
            // probe 指向数组中间的值
            probe = base + (count >> 1);
            // 取出中间method_t的name，也就是SEL
            uintptr_t probeValue = (uintptr_t)probe->name;
            if (keyValue == probeValue) {
                // 取出 probe
                while (probe > first && keyValue == (uintptr_t)probe[-1].name) {
                    probe--;
                }
               // 返回方法
                return (method_t *)probe;
            }
            // 如果keyValue > probeValue 则折半向后查询
            if (keyValue > probeValue) {
                base = probe + 1;
                count--;
            }
        }
        
        return nil;
    } 
    复制代码

至此为止，消息发送阶段已经完成。\\

2\. 总结
------

我们通过一张图来看一下`_class_lookupMethodAndLoadCache3`函数内部消息发送的整个流程:

![](https//https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c8bc282d238d4ba0bbd8903d4927e368~tplv-k3u1fbpfcp-zoom-1.image)

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/be24bd85b65e419fb5ff5b3e15b32b3d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

如果`消息发送`阶段没有找到方法，就会进入`动态解析方法`阶段

二、动态方法解析
========

1\. 了解方法的动态解析
-------------

当在本类`cache`包括`class_rw_t`中都找不到方法时会向上找父类的`cache`包括`class_rw_t`，若一直找不到方法，就会进入`动态方法解析`阶段.

我们来看一下动态解析阶段源码:

动态解析的方法

        if (resolver  &&  !triedResolver) {
            runtimeLock.unlockRead();
            _class_resolveMethod(cls, sel, inst);
            runtimeLock.read();
            // Don't cache the result; we don't hold the lock so it may have 
            // changed already. Re-do the search from scratch instead.
            triedResolver = YES;
            goto retry;
        } 
    复制代码

`_class_resolveMethod`函数内部，根据类对象或元类对象做不同的操作

    void _class_resolveMethod(Class cls, SEL sel, id inst)
    {
        if (! cls->isMetaClass()) {
            // try [cls resolveInstanceMethod:sel]
            _class_resolveInstanceMethod(cls, sel, inst);
        } 
        else {
            // try [nonMetaClass resolveClassMethod:sel]
            // and [cls resolveInstanceMethod:sel]
            _class_resolveClassMethod(cls, sel, inst);
            if (!lookUpImpOrNil(cls, sel, inst, 
                                NO/*initialize*/, YES/*cache*/, NO/*resolver*/)) 
            {
                _class_resolveInstanceMethod(cls, sel, inst);
            }
        }
    } 
    复制代码

从上述代码可以发现:

*   动态解析方法之后，会将`triedResolver = YES;`
*   那么下次就不会在进行动态解析阶段了，之后会重新执行`retry`，会重新对方法查找一遍
*   也就是说:
    *   无论我们是否实现动态解析方法
    *   无论动态解析方法是否成功，**`retry`之后都不会在进行动态的解析方法**了

2\. 如何动态解析方法
------------

*   动态解析`对象方法`时，会调用`+(BOOL)resolveInstanceMethod:(SEL)sel`方法;
*   动态解析`类方法`时，会调用`+(BOOL)resolveClassMethod:(SEL)sel`方法。

这里以实例对象为例通过代码来看一下动态解析的过程

    @implementation Person
    - (void) other {
        NSLog(@"%s", __func__);
    }
    
    + (BOOL)resolveInstanceMethod:(SEL)sel
    {
        // 动态的添加方法实现
        if (sel == @selector(test)) {
            // 获取其他方法 指向method_t的指针
            Method otherMethod = class_getInstanceMethod(self, @selector(other));
            
            // 动态添加test方法的实现
            class_addMethod(self, sel, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod));
            
            // 返回YES表示有动态添加方法
            return YES;
        }
        
        NSLog(@"%s", __func__);
        return [super resolveInstanceMethod:sel];
    }
    
    @end 
    复制代码

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            Person *person = [[Person alloc] init];
            [person test];
        }
        return 0;
    }
    // 打印结果
    // -[Person other] 
    复制代码

上述代码中可以看出，`person`在调用`test`方法时经过动态解析成功调用了`other`方法。

通过上面对消息发送的分析我们得知:

*   当本类和父类`cache`和`class_rw_t`中都找不到方法时，就会进行动态解析的方法
*   也就是说会自动调用类的`resolveInstanceMethod:`方法进行动态查找
*   因此我们可以在`resolveInstanceMethod:`方法内部使用`class_addMethod`动态的添加方法实现

这里需要注意`class_addMethod`用来向具有`给定方法名称`和`实现的类`添加新方法

*   `class_addMethod`将添加一个方法实现的覆盖，但是不会替换已有的实现
*   也就是说如果上述代码中已经实现了`-(void)test`方法，则不会再动态添加方法，这点在上述源码中也可以体现，因为一旦找到方法实现就直接return imp并调用方法了，不会再执行动态解析方法了。

### 2.1 动态添加方法

> class\_addMethod 函数

我们来看一下`class_addMethod`函数的参数分别代表什么。

        /** 
         第一个参数： cls:给哪个类添加方法
         第二个参数： SEL name:添加方法的名称
         第三个参数： IMP imp: 方法的实现，函数入口，函数名可与方法名不同（建议与方法名相同）
         第四个参数： types :方法类型，需要用特定符号，参考API
         */
    class_addMethod(__unsafe_unretained Class cls, SEL name, IMP imp, const char *types) 
    复制代码

上述参数上文中已经详细讲解过，这里不再赘述。

需要注意的是我们在上述代码中通过`class_getInstanceMethod`获取`Method`的方法

    // 获取其他方法 指向method_t的指针
    Method otherMethod = class_getInstanceMethod(self, @selector(other)); 
    复制代码

*   其实Method是`objc_method`类型结构体，可以理解为其内部结构同`method_t`结构体相同
*   前文中提到过`method_t`是代表方法的结构体，其内部包含`SEL、type、IMP`
*   我们通过自定义`method_t`结构体，将`objc_method`强转为`method_t`查看方法是否能够动态添加成功:
    
        struct method_t {
            SEL sel;
            char *types;
            IMP imp;
        };
        
        - (void) other {
            NSLog(@"%s", __func__);
        }
        
        + (BOOL)resolveInstanceMethod:(SEL)sel
        {
            // 动态的添加方法实现
            if (sel == @selector(test)) {
                // Method强转为method_t
                struct method_t *method = (struct method_t *)class_getInstanceMethod(self, @selector(other));
        
                NSLog(@"%s,%p,%s",method->sel,method->imp,method->types);
        
                // 动态添加test方法的实现
                class_addMethod(self, sel, method->imp, method->types);
        
                // 返回YES表示有动态添加方法
                return YES;
            }
        
            NSLog(@"%s", __func__);
            return [super resolveInstanceMethod:sel];
        } 
        复制代码
    

查看打印内容

    动态解析方法[3246:1433553] other,0x100000d00,v16@0:8
    动态解析方法[3246:1433553] -[Person other] 
    复制代码

可以看出确实可以打印出相关信息，那么我们就可以理解为:

*   `objc_method`内部结构同`method_t`结构体相同，可以代表类定义中的方法

另外上述代码中我们通过`method_getImplementation`函数和`method_getTypeEncoding`函数获取方法的`imp`和`type`。当然我们也可以通过自己写的方式来调用，这里以动态添加有参数的方法为例。

    +(BOOL)resolveInstanceMethod:(SEL)sel
    {
        if (sel == @selector(eat:)) {
            class_addMethod(self, sel, (IMP)cook, "v@:@");
            return YES;
        }
        return [super resolveInstanceMethod:sel];
    }
    void cook(id self ,SEL _cmd,id Num)
    {
        // 实现内容
        NSLog(@"%@的%@方法动态实现了,参数为%@",self,NSStringFromSelector(_cmd),Num);
    } 
    复制代码

上述代码中当调用`eat:`方法时，动态添加了`cook`函数作为其实现并添加id类型的参数。

### 2.2 动态解析类方法

当动态解析`类方法`的时候，就会调用`+(BOOL)resolveClassMethod:(SEL)sel`函数  
而我们知道类方法是存储在元类对象里面的，因此cls第一个对象需要`传入元类对象`以下代码为例:

    void other(id self, SEL _cmd)
    {
        NSLog(@"other - %@ - %@", self, NSStringFromSelector(_cmd));
    }
    
    + (BOOL)resolveClassMethod:(SEL)sel
    {
        if (sel == @selector(test)) {
            // 第一个参数是object_getClass(self)，传入元类对象。
            class_addMethod(object_getClass(self), sel, (IMP)other, "v16@0:8");
            return YES;
        }
        return [super resolveClassMethod:sel];
    } 
    复制代码

我们在上述源码的分析中提到过:

*   无论我们是否实现了`动态解析`的方法，系统内部都会执行`retry`对方法再次进行查找
*   那么如果我们实现了`动态解析方法`，此时就会顺利查找到方法，进而返回`imp`对方法进行调用
*   如果我们没有实现动态解析方法。就会进行消息转发。

3\. 总结
------

接下来看一下动态解析方法流程图示

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f0df18ef119e4addb707d85971d92026~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

七、消息转发
======

1\. 消息转发
--------

如果我们自己也没有对方法进行动态的解析，那么就会进行消息转发

    imp = (IMP)_objc_msgForward_impcache;
    cache_fill(cls, sel, imp, inst); 
    复制代码

自己没有能力处理这个消息的时候，就会进行消息转发阶段，会调用`_objc_msgForward_impcache`函数。

通过搜索可以在汇编中找到`__objc_msgForward_impcache`函数实现:

*   `__objc_msgForward_impcache`函数中调用`__objc_msgForward`进而找到`__objc_forward_handler`。

    objc_defaultForwardHandler(id self, SEL sel)
    {
        _objc_fatal("%c[%s %s]: unrecognized selector sent to instance %p "
                    "(no message forward handler is installed)", 
                    class_isMetaClass(object_getClass(self)) ? '+' : '-', 
                    object_getClassName(self), sel_getName(sel), self);
    }
    void *_objc_forward_handler = (void*)objc_defaultForwardHandler;
    复制代码

我们发现这仅仅是一个错误信息的输出。  
其实消息转发机制是不开源的，但是我们可以猜测其中可能拿返回的对象调用了`objc_msgSend`，重走了一遍`消息发送`，`动态解析`，`消息转发`的过程。最终找到方法进行调用。

我们通过代码来看一下

*   首先创建`Car`类继承自`NSObject`，并且`Car`有一个`- (void) driving`方法，
*   当`Person类实例对象`失去了驾车的能力，并且没有在开车过程中动态的学会驾车，那么此时就会将开车这条信息转发给`Car`
*   由`Car实例对象`来帮助`person对象`驾车

    #import "Car.h"
    @implementation Car
    - (void) driving
    {
        NSLog(@"car driving");
    }
    @end
    
    --------------
    
    #import "Person.h"
    #import <objc/runtime.h>
    #import "Car.h"
    @implementation Person
    - (id)forwardingTargetForSelector:(SEL)aSelector
    {
        // 返回能够处理消息的对象
        if (aSelector == @selector(driving)) {
            return [[Car alloc] init];
        }
        return [super forwardingTargetForSelector:aSelector];
    }
    @end
    
    --------------
    
    #import<Foundation/Foundation.h>
    #import "Person.h"
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
    
            Person *person = [[Person alloc] init];
            [person driving];
        }
        return 0;
    }
    
    // 打印内容
    // 消息转发[3452:1639178] car driving
    
    复制代码

**由上述代码可以看出:**

*   当本类没有实现方法，并且没有动态解析方法，就会调用`forwardingTargetForSelector`函数，进行消息转发
*   我们可以实现`forwardingTargetForSelector`函数，在其内部将消息**转发给可以实现**此方法的对象

如果`forwardingTargetForSelector`函数返回为`nil`或者没有实现的话

*   就会调用`methodSignatureForSelector`方法，用来返回一个方法签名(这是我们正确跳转方法的最后机会）
*   如果`methodSignatureForSelector`方法返回正确的方法签名就会调用`forwardInvocation`方法
*   `forwardInvocation`方法内提供一个`NSInvocation`类型的参数
    *   `NSInvocation`封装了一个方法的调用，包括方法的调用者，方法名，以及方法的参数
    *   在`forwardInvocation`函数内修改方法调用对象即可
*   如果`methodSignatureForSelector`返回的为nil，就会来到`doseNotRecognizeSelector:`方法内部
*   程序crash提示无法识别选择器`unrecognized selector sent to instance`

我们通过以下代码进行验证

    - (id)forwardingTargetForSelector:(SEL)aSelector
    {
        // 返回能够处理消息的对象
        if (aSelector == @selector(driving)) {
            // 返回nil则会调用methodSignatureForSelector方法
            return nil; 
            // return [[Car alloc] init];
        }
        return [super forwardingTargetForSelector:aSelector];
    }
    
    // 方法签名：返回值类型、参数类型
    - (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
    {
        if (aSelector == @selector(driving)) {
           // return [NSMethodSignature signatureWithObjCTypes: "v@:"];
           // return [NSMethodSignature signatureWithObjCTypes: "v16@0:8"];
           // 也可以通过调用Car的methodSignatureForSelector方法得到方法签名，这种方式需要car对象有aSelector方法
            return [[[Car alloc] init] methodSignatureForSelector: aSelector];
    
        }
        return [super methodSignatureForSelector:aSelector];
    }
    
    //NSInvocation 封装了一个方法调用，包括：方法调用者，方法，方法的参数
    //    anInvocation.target 方法调用者
    //    anInvocation.selector 方法名
    //    [anInvocation getArgument: NULL atIndex: 0]; 获得参数
    - (void)forwardInvocation:(NSInvocation *)anInvocation
    {
    //   anInvocation中封装了methodSignatureForSelector函数中返回的方法。
    //   此时anInvocation.target 还是person对象，我们需要修改target为可以执行方法的方法调用者。
    //   anInvocation.target = [[Car alloc] init];
    //   [anInvocation invoke];
        [anInvocation invokeWithTarget: [[Car alloc] init]];
    }
    
    // 打印内容
    // 消息转发[5781:2164454] car driving 
    复制代码

2.总结
----

上述代码中可以发现方法可以正常调用。接下来我们来看一下消息转发阶段的流程图

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/72879a99330e47f29b0402ae94ea3311~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 

3.NSInvocation
--------------

*   `methodSignatureForSelector`方法中返回的方法签名
*   在`forwardInvocation`中被包装成`NSInvocation`对象
*   `NSInvocation`提供了获取和修改`方法名`、`参数`、`返回值`等方法，也就是说，在`forwardInvocation`函数中我们可以对方法进行最后的修改。

同样上述代码，我们为driving方法添加返回值和参数，并在`forwardInvocation`方法中修改方法的返回值及参数。

    #import "Car.h"
    @implementation Car
    - (int) driving:(int)time
    {
        NSLog(@"car driving %d",time);
        return time * 2;
    }
    @end
    
    #import "Person.h"
    #import <objc/runtime.h>
    #import "Car.h"
    
    @implementation Person
    - (id)forwardingTargetForSelector:(SEL)aSelector
    {
        // 返回能够处理消息的对象
        if (aSelector == @selector(driving)) {
            return nil;
        }
        return [super forwardingTargetForSelector:aSelector];
    }
    
    // 方法签名：返回值类型、参数类型
    - (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
    {
        if (aSelector == @selector(driving:)) {
             // 添加一个int参数及int返回值type为 i@:i
             return [NSMethodSignature signatureWithObjCTypes: "i@:i"];
        }
        return [super methodSignatureForSelector:aSelector];
    }
    
    
    //NSInvocation 封装了一个方法调用，包括：方法调用者，方法，方法的参数
    - (void)forwardInvocation:(NSInvocation *)anInvocation
    {    
        int time;
        // 获取方法的参数，方法默认还有self和cmd两个参数，因此新添加的参数下标为2
        [anInvocation getArgument: &time atIndex: 2];
        NSLog(@"修改前参数的值 = %d",time);
        time = time + 10; // time = 110
        NSLog(@"修改前参数的值 = %d",time);
        // 设置方法的参数 此时将参数设置为110
        [anInvocation setArgument: &time atIndex:2];
        
        // 将tagert设置为Car实例对象
        [anInvocation invokeWithTarget: [[Car alloc] init]];
        
        // 获取方法的返回值
        int result;
        [anInvocation getReturnValue: &result];
        NSLog(@"获取方法的返回值 = %d",result); // result = 220,说明参数修改成功
        
        result = 99;
        // 设置方法的返回值 重新将返回值设置为99
        [anInvocation setReturnValue: &result];
        
        // 获取方法的返回值
        [anInvocation getReturnValue: &result];
        NSLog(@"修改方法的返回值为 = %d",result);    // result = 99
    }
    
    #import<Foundation/Foundation.h>
    #import "Person.h"
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            Person *person = [[Person alloc] init];
            // 传入100，并打印返回值
            NSLog(@"[person driving: 100] = %d",[person driving: 100]);
        }
        return 0;
    } 
    复制代码

    消息转发[6415:2290423] 修改前参数的值 = 100
    消息转发[6415:2290423] 修改前参数的值 = 110
    消息转发[6415:2290423] car driving 110
    消息转发[6415:2290423] 获取方法的返回值 = 220
    消息转发[6415:2290423] 修改方法的返回值为 = 99
    消息转发[6415:2290423] [person driving: 100] = 99
    复制代码

从上述打印结果可以看出:  
`forwardInvocation`方法中可以对方法的参数及返回值进行修改。

并且我们可以发现，在设置tagert为Car实例对象时，就已经对方法进行了调用，而在`forwardInvocation`方法结束之后才输出返回值。

通过上述验证我们可以知道只要来到`forwardInvocation`方法中，我们便对方法调用有了绝对的掌控权，可以选择是否调用方法，以及修改方法的参数返回值等等。

4\. 类方法的消息转发
------------

类方法消息转发同对象方法一样，同样需要经过消息发送，动态方法解析之后才会进行消息转发机制。

我们知道类方法是存储在元类对象中的，元类对象本来也是一种特殊的类对象。需要注意的是，类方法的消息接受者变为`元类对象`。

**当类对象进行消息转发时，对调用相应的+号的`forwardingTargetForSelector、methodSignatureForSelector、forwardInvocation`方法，需要注意的是+号方法仅仅没有提示，而不是系统不会对类方法进行消息转发。**

下面通过一段代码查看类方法的消息转发机制。

    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            [Person driving];
        }
        return 0;
    }
    
    #import "Car.h"
    @implementation Car
    + (void) driving;
    {
        NSLog(@"car driving");
    }
    @end
    
    #import "Person.h"
    #import <objc/runtime.h>
    #import "Car.h"
    
    @implementation Person
    
    + (id)forwardingTargetForSelector:(SEL)aSelector
    {
        // 返回能够处理消息的对象
        if (aSelector == @selector(driving)) {
            // 这里需要返回类对象
            return [Car class]; 
        }
        return [super forwardingTargetForSelector:aSelector];
    }
    // 如果forwardInvocation函数中返回nil 则执行下列代码
    // 方法签名：返回值类型、参数类型
    + (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
    {
        if (aSelector == @selector(driving)) {
            return [NSMethodSignature signatureWithObjCTypes: "v@:"];
        }
        return [super methodSignatureForSelector:aSelector];
    }
    
    + (void)forwardInvocation:(NSInvocation *)anInvocation
    {
        [anInvocation invokeWithTarget: [Car class]];
    }
    
    // 打印结果
    // 消息转发[6935:2415131] car driving 
    复制代码

上述代码中同样可以对类对象方法进行消息转发。需要注意的是类方法的接受者为类对象。其他同对象方法消息转发模式相同。

总结
--

OC中的方法调用其实都是转成了`objc_msgSend`函数的调用,给receiver（方法调用者）发送了一条消息（selector方法名）。  
方法调用过程中也就是`objc_msgSend`底层实现分为三个阶段：**消息发送、动态方法解析、消息转发**。  
本文主要对这三个阶段相互之间的关系以及流程进行的探索。上文中已经讲解的很详细，这里不再赘述。

八、super的本质
==========

首先来看一道面试题。 下列代码中`Person`继承自`NSObject`，`Student`继承自`Person`，写出下列代码输出内容。

    #import "Student.h"
    @implementation Student
    - (instancetype)init
    {
        if (self = [super init]) {
            NSLog(@"[self class] = %@", [self class]);
            NSLog(@"[self superclass] = %@", [self superclass]);
            NSLog(@"----------------");
            NSLog(@"[super class] = %@", [super class]);
            NSLog(@"[super superclass] = %@", [super superclass]);
    
        }
        return self;
    }
    @end 
    复制代码

直接来看一下打印内容

    Runtime-super[6601:1536402] [self class] = Student
    Runtime-super[6601:1536402] [self superclass] = Person
    Runtime-super[6601:1536402] ----------------
    Runtime-super[6601:1536402] [super class] = Student
    Runtime-super[6601:1536402] [super superclass] = Person 
    复制代码

上述代码中可以发现无论是`self`还是`super`调用`class`或`superclass`的结果都是相同的。

**为什么结果是相同的？  
`super`关键字在调用方法的时候底层调用流程是怎样的？**

我们通过一段代码来看一下`super`底层实现，为`Person`类提供`run`方法，`Student`类中重写`run`方法，方法内部调用`[super run];`，将`Student.m`转化为`c++`代码查看其底层实现。

    - (void) run
    {
        [super run];
        NSLog(@"Student...");
    } 
    复制代码

上述代码转化为c++代码

    static void _I_Student_run(Student * self, SEL _cmd) {
        
        ((void (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("Student"))}, sel_registerName("run"));
        
        
        NSLog((NSString *)&__NSConstantStringImpl__var_folders_jm_dztwxsdn7bvbz__xj2vlp8980000gn_T_Student_e677aa_mi_0);
    } 
    复制代码

通过上述源码可以发现:

*   `[super run];`转化为底层源码内部其实调用的是`objc_msgSendSuper`函数
*   `objc_msgSendSuper`函数内传递了两个参数。`__rw_objc_super`结构体和`sel_registerName("run")`方法名
*   `__rw_objc_super`结构体内传入的参数是`self`和`class_getSuperclass(objc_getClass("Student"))`也就是`Student`的父类`Person`

首先我们找到`objc_msgSendSuper`函数查看内部结构

    OBJC_EXPORT id _Nullable
    objc_msgSendSuper(struct objc_super * _Nonnull super, SEL _Nonnull op, ...)
        OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0); 
    复制代码

可以发现`objc_msgSendSuper`中传入的结构体是`objc_super`，我们来到`objc_super`内部查看其内部结构。 我们通过源码查找`objc_super`结构体查看其内部结构。

    // 精简后的objc_super结构体
    struct objc_super {
        __unsafe_unretained _Nonnull id receiver; // 消息接受者
        __unsafe_unretained _Nonnull Class super_class; // 消息接受者的父类
        /* super_class is the first class to search */ 
        // 父类是第一个开始查找的类
    }; 
    复制代码

*   从`objc_super`结构体中可以发现`receiver`消息接受者仍然为`self`
*   `superclass`仅仅是用来告知消息查找从哪一个类开始。从父类的类对象开始去查找。

我们通过一张图看一下其中的区别。

![self/super调用方法的区别](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/02c233761b5b49d4babe6f8b2267c0c4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从上图中我们知道 **`super`调用方法的消息接受者`receiver`仍然是`self`，只是从父类的类对象开始去查找方法。**

那么此时重新回到面试题，我们知道class的底层实现如下面代码所示

    + (Class)class {
        return self;
    }
    
    - (Class)class {
        return object_getClass(self);
    } 
    复制代码

**`class`内部实现是根据消息接受者返回其对应的类对象，最终会找到基类的方法列表中  
而`self`和`super`的区别仅仅是`self`从本类类对象开始查找方法  
`super`从父类类对象开始查找方法，因此最终得到的结果都是相同的**

另外我们在回到`run`方法内部，很明显可以发现，如果`super`不是从父类开始查找方法，从本类查找方法的话，就调用方法本身造成循环调用方法而crash。

同理`superclass`底层实现同`class`类似，其底层实现代码如下入所示

    + (Class)superclass {
        return self->superclass;
    }
    
    - (Class)superclass {
        return [self class]->superclass;
    } 
    复制代码

因此得到的结果也是相同的。

1\. objc\_msgSendSuper2函数
-------------------------

上述OC代码转化为c++代码并不能说明`super`底层调用函数就一定`objc_msgSendSuper`。

其实`super`底层真正调用的函数时`objc_msgSendSuper2函数`我们可以通过查看super调用方法转化为汇编代码来验证这一说法

    - (void)viewDidLoad {
        [super viewDidLoad];
    } 
    复制代码

通过断点查看其汇编调用栈

![objc_msgSendSuper2函数](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ca8a6fc9a21a4d59afaab88a61d00339~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上图中可以发现`super`底层其实调用的是`objc_msgSendSuper2`函数，我们来到源码中查找一下`objc_msgSendSuper2`函数的底层实现，我们可以在汇编文件中找到其相关底层实现。

    ENTRY _objc_msgSendSuper2
    UNWIND _objc_msgSendSuper2, NoFrame
    MESSENGER_START
    
    ldp	x0, x16, [x0]		// x0 = real receiver, x16 = class
    ldr	x16, [x16, #SUPERCLASS]	// x16 = class->superclass
    CacheLookup NORMAL
    
    END_ENTRY _objc_msgSendSuper2 
    复制代码

通过上面汇编代码我们可以发现，其实底层是在函数内部调用的`class->superclass`获取父类，并不是我们上面分析的直接传入的就是父类对象。

**其实`_objc_msgSendSuper2`内传入的结构体为`objc_super2`**

    struct objc_super2 {
        id receiver;
        Class current_class;
    }; 
    复制代码

我们可以发现`objc_super2`中除了消息接受者`receiver`，另一个成员变量`current_class`也就是当前类对象。

与我们上面分析的不同`_objc_msgSendSuper2`函数内其实传入的是当前类对象，然后在函数内部获取当前类对象的父类，并且从父类开始查找方法。

我们也可以通过代码验证上述结构体内成员变量究竟是当前类对象还是父类对象。下文中我们会通过另外一道面试题验证。

2.isKindOfClass 与 isMemberOfClass
---------------------------------

首先看一下`isKindOfClass isKindOfClass`对象方法底层实现

    - (BOOL)isMemberOfClass:(Class)cls {
       // 直接获取实例类对象并判断是否等于传入的类对象
        return [self class] == cls;
    }
    
    - (BOOL)isKindOfClass:(Class)cls {
       // 向上查询，如果找到父类对象等于传入的类对象则返回YES
       // 直到基类还不相等则返回NO
        for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
            if (tcls == cls) return YES;
        }
        return NO;
    } 
    复制代码

`isKindOfClass isKindOfClass`类方法底层实现

    // 判断元类对象是否等于传入的元类元类对象
    // 此时self是类对象 object_getClass((id)self)就是元类
    + (BOOL)isMemberOfClass:(Class)cls {
        return object_getClass((id)self) == cls;
    }
    
    // 向上查找，判断元类对象是否等于传入的元类对象
    // 如果找到基类还不相等则返回NO
    // 注意：这里会找到基类
    + (BOOL)isKindOfClass:(Class)cls {
        for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
            if (tcls == cls) return YES;
        }
        return NO;
    } 
    复制代码

通过上述源码分析我们可以知道。 **`isMemberOfClass` 判断左边是否刚好等于右边类型。** **`isKindOfClass` 判断左边或者左边类型的父类是否刚好等于右边类型。** **注意：类方法内部是获取其元类对象进行比较**

我们查看以下代码

    NSLog(@"%d",[Person isKindOfClass: [Person class]]);
    NSLog(@"%d",[Person isKindOfClass: object_getClass([Person class])]);
    NSLog(@"%d",[Person isKindOfClass: [NSObject class]]);
    
    // 输出内容
    Runtime-super[46993:5195901] 0
    Runtime-super[46993:5195901] 1
    Runtime-super[46993:5195901] 1 
    复制代码

分析上述输出内容： 第一个 0：上面提到过类方法是获取self的元类对象与传入的参数进行比较，但是第一行我们传入的是类对象，因此返回NO。

第二个 1：同上，此时我们传入Person元类对象，此时返回YES。验证上述说法

第三个 1：我们发现此时传入的是NSObject类对象并不是元类对象，但是返回的值却是YES。 原因是基元类的superclass指针是指向基类对象的。如下图13号线

![isa、superclass指向图](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fbb5b77fe0a34e40b9ec03bae1307bc3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

那么`Person元类`通过`superclass`指针一直找到基元类，还是不相等，此时再次通过`superclass`指针来到基类，那么此时发现相等就会返回YES了。

3\. 复习
------

通过一道面试题对之前学习的知识进行复习。 问：以下代码是否可以执行成功，如果可以，打印结果是什么。

    // Person.h
    #import <Foundation/Foundation.h>
    @interface Person : NSObject
    @property (nonatomic, strong) NSString *name;
    - (void)test;
    @end
    
    // Person.m
    #import "Person.h"
    @implementation Person
    - (void)test
    {
        NSLog(@"test print name is : %@", self.name);
    }
    @end
    
    // ViewController.m
    @implementation ViewController
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        id cls = [Person class];
        void *obj = &cls;
        [(__bridge id)obj test];
        
        Person *person = [[Person alloc] init];
        [person test];
    } 
    复制代码

这道面试题确实很无厘头的一道题，日常工作中没有人这样写代码，但是需要解答这道题需要很完备的底层知识，我们通过这道题来复习一下，首先看一下打印结果。

    Runtime面试题[15842:2579705] test print name is : <ViewController: 0x7f95514077a0>
    Runtime面试题[15842:2579705] test print name is : (null) 
    复制代码

通过上述打印结果我们可以看出，是可以正常运行并打印的，说明`obj`可以正常调用`test`方法，但是我们发现打印`self.name`的内容却是`<ViewController: 0x7f95514077a0>`。下面`person`实例调用`test`不做过多解释了，主要用来和上面方法调用做对比。

为什么会是这样的结果呢？首先通过一张图看一下两种调用方法的内存信息。

![两种调用方法的内存信息](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9863ed89a5ad4ac38261789a210f3ce2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上图我们可以发现两种方法调用方式很相近。那么obj为什么可以正常调用方法？

### 3.1 obj为什么可以正常调用方法

首先通过之前的学习我们知道，`person`调用方法时首先通过`isa`指针找到类对象进而查找方法并进行调用。

而`person`实例对象内实际上是取最前面8个字节空间也就是`isa`并通过计算得出类对象地址。

而通过上图我们可以发现，`obj`在调用`test`方法时，也会通过其内存地址找到`cls`，而`cls`中取出最前面8个字节空间其内部存储的刚好是`Person`类对象地址。因此`obj`是可以正常调用方法的。

### 3.2 为什么self.name打印内容为ViewController对象

问题出在`[super viewDidLoad];`这段代码中，通过上述对`super`本质的分析我们知道，`super`内部调用`objc_msgSendSuper2`函数。

我们知道`objc_msgSendSuper2`函数内部会传入两个参数，`objc_super2`结构体和`SEL`，并且`objc_super2`结构体内有两个成员变量消息接受者和其父类。

    struct objc_super2 {
        id receiver; // 消息接受者
        Class current_class; // 当前类
    };
    }; 
    复制代码

通过以上分析我们可以得知`[super viewDidLoad];`内部`objc_super2`结构体内存储如下所示

    struct objc_super = {
        self,
        [ViewController Class]
    }; 
    复制代码

**那么`objc_msgSendSuper2`函数调用之前，会先创建局部变量`objc_super2`结构体用于为`objc_msgSendSuper2`函数传递的参数。**

### 3.3 局部变量由高地址向低地址分配在栈空间

**我们知道局部变量是存储在栈空间内的，并且是由高地址向低地址有序存储。** 我们通过一段代码验证一下。

    long long a = 1;
    long long b = 2;
    long long c = 3;
    NSLog(@"%p %p %p", &a,&b,&c);
    // 打印内容
    0x7ffee9774958 0x7ffee9774950 0x7ffee9774948 
    复制代码

通过上述代码打印内容，我们可以验证**局部变量在栈空间内是由高地址向低地址连续存储的。**

那么我们回到面试题中，通过上述分析我们知道，此时代码中包含局部变量以此为`objc_super2 结构体`、`cls`、`obj`。通过一张图展示一下这些局部变量存储结构。

![局部变量存储结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/26bd4e3159b84b53ac1473ff1644f6ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

上面我们知道当`person`实例对象调用方法的时候，会取实例变量前8个字节空间也就是`isa`来找到类对象地址。那么当访问实例变量的时候，就跳过`isa`的8个字节空间往下面去找实例变量。

**那么当`obj`在调用`test`方法的时候同样找到`cls`中取出前8个字节，也就是`Person类对象`的内存地址，那么当访问实例变量`_name`的时候，会继续向高地址内存空间查找，此时就会找到`objc_super`结构体，从中取出8个字节空间也就是`self`，因此此时访问到的`self.name`就是`ViewController对象`。**

**当访问成员变量`_name`的时候，`test`函数中的`self`也就是方法调用者其实是`obj`，那么`self.name`就是通过`obj`去找`_name`，跳过cls的8个指针，在取8个指针此时自然获取到`ViewController对象`。**

**因此上述代码中`cls`就相当于`isa`，`isa`下面的8个字节空间就相当于`_name`成员变量。因此成员变量`_name`的访问到的值就是`cls`地址后向高地址位取8个字节地址空间存储的值。**

为了验证上述说法，我们做一个实验，在`cls`后高地址中添加一个`string`，那么此时`cls`下面的高地址位就是`string`。以下示例代码

    - (void)viewDidLoad {
        [super viewDidLoad];
        
        NSString *string = @"string";
        
        id cls = [Person class];
        void *obj = &cls;
        [(__bridge id)obj test];
        
        Person *person = [[Person alloc] init];
        [person test];
    } 
    复制代码

此时的局部变量内存结构如下图所示

![局部变量内存结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b3fd84ae4ad04b8a943c463f1559ee88~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

此时在访问`_name`成员变量的时候，越过`cls`内存往高地址找就会来到`string`，此时拿到的成员变量就是`string`了。 我们来看一下打印内容

    Runtime面试题[16887:2829028] test print name is : string
    Runtime面试题[16887:2829028] test print name is : (null) 
    复制代码

再通过一段代码使用int数据进行试验

    - (void)viewDidLoad {
        [super viewDidLoad];
    
        int a = 3;
        
        id cls = [Person class];
        void *obj = &cls;
        [(__bridge id)obj test];
        
        Person *person = [[Person alloc] init];
        [person test];
    }
    // 程序crash，坏地址访问 
    复制代码

我们发现程序因为坏地址访问而crash，此时局部变量内存结构如下图所示

![局部变量内存结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ee3367a309384cc2a5d114a92483267b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

当需要访问`_name`成员变量的时候，会在`cls`后高地址为查找8位的字节空间，而我们知道`int`占4位字节，那么此时8位的内存空间同时占据`int`数据及`objc_super`结构体内，因此就会造成坏地址访问而crash。

我们添加新的成员变量进行访问

    // Person.h
    #import <Foundation/Foundation.h>
    @interface Person : NSObject
    @property (nonatomic, strong) NSString *name;
    @property (nonatomic, strong) NSString *nickName;
    - (void)test;
    @end
    ------------
    // Person.m
    #import "Person.h"
    @implementation Person
    - (void)test
    {
        NSLog(@"test print name is : %@", self.nickName);
    }
    @end
    --------
    //  ViewController.m
    - (void)viewDidLoad {
        [super viewDidLoad];
    
        NSObject *obj1 = [[NSObject alloc] init];
        
        id cls = [Person class];
        void *obj = &cls;
        [(__bridge id)obj test];
        
        Person *person = [[Person alloc] init];
        [person test];
    } 
    复制代码

我们看一下打印内容

    // 打印内容
    // Runtime面试题[17272:2914887] test print name is : <ViewController: 0x7ffc6010af50>
    // Runtime面试题[17272:2914887] test print name is : (null) 
    复制代码

可以发现此时打印的仍然是`ViewController对象`，我们先来看一下其局部变量内存结构

![局部变量内存结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6f1d8b5af206421b9294d3941e156847~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

首先通过`obj`找到`cls`，`cls`找到类对象进行方法调用，此时在访问`nickName`时，`obj`查找成员变量，首先跳过8个字节的`cls`，之后跳过`name`所占的8个字节空间，最终再取8个字节空间取出其中的值作为成员变量的值，那么此时也就是`self`了。

总结：这道面试题虽然很无厘头，让人感觉无从下手但是考察的内容非常多。 **1\. super的底层本质为调用`objc_msgSendSuper2`函数，传入`objc_super2`结构体，结构体内部存储消息接受者和当前类，用来告知系统方法查找从父类开始。**

**2\. 局部变量分配在栈空间，并且从高地址向低地址连续分配。先创建的局部变量分配在高地址，后续创建的局部变量连续分配在较低地址。**

**3\. 方法调用的消息机制，通过isa指针找到类对象进行消息发送。**

**4\. 指针存储的是实例变量的首字节地址，上述例子中`person`指针存储的其实就是实例变量内部的`isa`指针的地址。**

**5\. 访问成员变量的本质，找到成员变量的地址，按照成员变量所占的字节数，取出地址中存储的成员变量的值。**

### 3.4验证objc\_msgSendSuper2内传入的结构体参数

我们使用以下代码来验证上文中遗留的问题

    - (void)viewDidLoad {
        [super viewDidLoad];
        id cls = [Person class];
        void *obj = &cls;
        [(__bridge id)obj test];
    } 
    复制代码

上述代码的局部变量内存结构我们之前已经分析过了，真正的内存结构应该如下图所示

![局部变量内存结构](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2f7332cd22704abdbe28b12ae1df0711~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上面对面试题的分析，我们现在想要验证`objc_msgSendSuper2`函数内传入的结构体参数，只需要拿到`cls`的地址，然后向后移8个地址就可以获取到`objc_super`结构体内的`self`，在向后移8个地址就是`current_class`的内存地址。通过打印`current_class`的内容，就可以知道传入`objc_msgSendSuper2`函数内部的是当前类对象还是父类对象了。

我们来证明他是`UIViewController` 还是`ViewController`即可

![结构体内传入当前类](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/410d728e9db24c3fbf6e1762959b683a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上图可以发现，最终打印的内容确实为当前类对象。 **因此`objc_msgSendSuper2`函数内部其实传入的是当前类对象，并且在函数内部获取其父类，告知系统从父类方法开始查找的。**