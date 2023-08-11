load 和 initialize
====================

我们刚才在本文第三节第4.2小节 阅读 `load_images`底层函数实现的时候,发现了`call_load_methods`函数,顺便 探究一下 `load 和 initialize`的底层实现

4.1 load方法
----------

我们前面在探索load\_image函数的时候已经有了得到了load方法调度顺序的结论: **第一步.准备`load`方法:`prepare_load_methods`**

> **将类的处理顺序存储到待调度的表中**
> 
> *   以先处理类，后处理分类
> *   先处理父类，后处理子类
> 
> **类的处理逻辑：**
> 
> *   把类对象`Class`和类对应的load方法的`IMP`整合成一个`loadable_class`类型的结构体对象存储在表`loadable_classes`中。
> *   按照编译先后顺序调用（先编译，先调用）
> *   调用子类的`load`之前会先调用父类的`load`
> 
> **分类的处理逻辑：**
> 
> *   把分类对象`Category`和对应的load方法`IMP`整合成一个`loadable_category`类型的结构体对象存储在表`loadable_categories`中。

**第二步.调用`load`方法:`call_load_methods`**

> 以先调用类`Class`的load，后处理分类`Category`
> 
> *   通过分类找到对应的类
> *   然后由类调用`load`方法的顺序进行处理
> *   这个调用处理的顺序是根据准备方法`prepare_load_methods`中准备好的两张表`loadable_classes`和`loadable_categories`的顺序而来的。
> *   按照编译先后顺序调用（先编译，先调用）
> *   调用完就从表中移除，全部调用完结束循环。

*   `load方法`会在`Runtime`加载类、分类时调用
*   每个类、分类的`load`，在程序运行过程中只调用一次

### 4.1.1 源码分析顺序如下:

1.  在`objc-runtime-new.mm`中`load_images`方法可以发现准备处理`load方法`和调用`load方法`的函数
2.  在`prepare_load_methods`中发现，调用`load方法`前的类的处理和分类的处理
3.  递归调用`schedule_class_load`方法来优先添加父类放到列表中，然后再添加当前类，所以执行调用时肯定先执行父类的`load方法`
4.  在`objc-loadmethod.mm`中`call_load_methods`方法可以发现，程序运行时会先调用类的`load方法`，然后调用分类的`load方法`，详细代码如下
5.  找到每个类的`load方法`的内存地址，然后直接调用
6.  找到每个分类的`load方法`的内存地址，然后直接调用

### 4.1.2 load方法系统调用和主动调用的区别

*   系统调用`load方法`调用是直接找到类和分类中的方法的内存地址直接调用
*   主动调用`load方法`是通过消息机制来发送消息的，会在对应的消息列表里按顺序遍历一层层查找，找到就调用

### 4.1.3 我们通过Demo验证一下

(BMW继承自Car类） ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fc17088eb7cd4a38a1512bddcdd9818d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 符合前面的结论:

> *   以先处理类，后处理分类
> *   先处理父类，后处理子类
> *   各个分类的调度顺序依赖 源码文件的编译顺序:`先编译 先调用`

### 4.1.4 总结

在objc4源码解读load过程：

*   objc-os.mm
*   *   \_objc\_init
*   进入runtime后,加载load,在苹果开源代码中的函数顺序为:
*   *   load\_images
*   *   prepare\_load\_methods
*   *   *   schedule\_class\_load
*   *   *   add\_class\_to\_loadable\_list
*   *   *   add\_category\_to\_loadable\_list
*   *   call\_load\_methods
*   *   *   call\_class\_loads
*   *   *   call\_category\_loads
*   *   *   `(*load_method)(cls, SEL_load)`

+load方法是根据方法地址直接调用，并不是经过objc\_msgSend函数调用

4.2 initialize方法
----------------

**我们给Car类添加`initialize方法`:** ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4820615260ad49bfb4052d9a9bf5a54a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5490b09c910c4804928023d253619413~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 如上图所示,我们不难得知:`initialize方法`会在类第一次接收到消息时调用

**我们给Car的分类Car+Test添加`initialize方法`:**

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/feaf07e3b5fe43d69e1dc46c70d84bb8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a85fa77b658243039015ce815f4ce781~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

**我们给Car的分类Car+Test2添加`initialize方法`:**

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/44a0d20ccbbc4a1a898851d5ae168584~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/27c82cdd5e0e40078526fde824b781c5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

**我们调换一下两个分类的编译顺序:** ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a545bf3de7a44d9cb9a63b8a4580479d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

如上图所示,我们不难得知:

*   当分类 实现了 `initialize方法`时,会在类第一次接收到消息时调用分类的`initialize方法`
*   当多个分类 实现了 `initialize方法`时,调用后编译的那个分类的`initialize方法`

### 4.2.1 源码分析

1.由于在调用到这个类的时候才会执行`initialize方法`，那么说明是在发消息过程中来执行的，我们在`objc-runtime-new.mm`中调用`class_getInstanceMethod`或者`class_getClassMethod`方法，详细代码如下

#### 4.2.1.1 class\_getInstanceMethod

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f9742a6b62ea4d60820b70205a2312cd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    /***********************************************************************
    * _class_getMethod
    * fixme
    * Locking: read-locks runtimeLock
    **********************************************************************/
    static Method _class_getMethod(Class cls, SEL sel)
    {
        rwlock_reader_t lock(runtimeLock);
        return getMethod_nolock(cls, sel);
    }
    
    
    /***********************************************************************
    * class_getInstanceMethod.  Return the instance method for the
    * specified class and selector.
    **********************************************************************/
    Method class_getInstanceMethod(Class cls, SEL sel)
    {
        if (!cls  ||  !sel) return nil;
    
        // This deliberately avoids +initialize because it historically did so.
    
        // This implementation is a bit weird because it's the only place that 
        // wants a Method instead of an IMP.
    
    #warning fixme build and search caches
            
        // Search method lists, try method resolver, etc.
        lookUpImpOrNil(cls, sel, nil, 
                       NO/*initialize*/, NO/*cache*/, YES/*resolver*/);
    
    #warning fixme build and search caches
    
        return _class_getMethod(cls, sel);
    }
    
    复制代码

#### 4.2.1.2 lookUpImpOrNil

我们进入`lookUpImpOrNil`函数

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/93380730e4d643ea92f017bee96c54c1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    /***********************************************************************
    * lookUpImpOrNil.
    * Like lookUpImpOrForward, but returns nil instead of _objc_msgForward_impcache
    **********************************************************************/
    IMP lookUpImpOrNil(Class cls, SEL sel, id inst, 
                       bool initialize, bool cache, bool resolver)
    {
        IMP imp = lookUpImpOrForward(cls, sel, inst, initialize, cache, resolver);
        if (imp == _objc_msgForward_impcache) return nil;
        else return imp;
    }
    复制代码

#### 4.2.1.3 lookUpImpOrForward

我们继续进入`lookUpImpOrForward`函数

    /***********************************************************************
    * lookUpImpOrForward.
    * The standard IMP lookup. 
    * initialize==NO tries to avoid +initialize (but sometimes fails)
    * cache==NO skips optimistic unlocked lookup (but uses cache elsewhere)
    * Most callers should use initialize==YES and cache==YES.
    * inst is an instance of cls or a subclass thereof, or nil if none is known. 
    *   If cls is an un-initialized metaclass then a non-nil inst is faster.
    * May return _objc_msgForward_impcache. IMPs destined for external use 
    *   must be converted to _objc_msgForward or _objc_msgForward_stret.
    *   If you don't want forwarding at all, use lookUpImpOrNil() instead.
    **********************************************************************/
    IMP lookUpImpOrForward(Class cls, SEL sel, id inst, 
                           bool initialize, bool cache, bool resolver)
    {
        IMP imp = nil;
        bool triedResolver = NO;
    
        runtimeLock.assertUnlocked();
    
        // Optimistic cache lookup
        if (cache) {
            imp = cache_getImp(cls, sel);
            if (imp) return imp;
        }
    
        // runtimeLock is held during isRealized and isInitialized checking
        // to prevent races against concurrent realization.
    
        // runtimeLock is held during method search to make
        // method-lookup + cache-fill atomic with respect to method addition.
        // Otherwise, a category could be added but ignored indefinitely because
        // the cache was re-filled with the old value after the cache flush on
        // behalf of the category.
    
        runtimeLock.read();
    
        if (!cls->isRealized()) {
            // Drop the read-lock and acquire the write-lock.
            // realizeClass() checks isRealized() again to prevent
            // a race while the lock is down.
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
            // If sel == initialize, _class_initialize will send +initialize and 
            // then the messenger will send +initialize again after this 
            // procedure finishes. Of course, if this is not being called 
            // from the messenger then it won't happen. 2778172
        }
    
        
     retry:    
        runtimeLock.assertReading();
    
        // Try this class's cache.
    
        imp = cache_getImp(cls, sel);
        if (imp) goto done;
    
        // Try this class's method lists.
        {
            Method meth = getMethodNoSuper_nolock(cls, sel);
            if (meth) {
                log_and_fill_cache(cls, meth->imp, sel, inst, cls);
                imp = meth->imp;
                goto done;
            }
        }
    
        // Try superclass caches and method lists.
        {
            unsigned attempts = unreasonableClassCount();
            for (Class curClass = cls->superclass;
                 curClass != nil;
                 curClass = curClass->superclass)
            {
                // Halt if there is a cycle in the superclass chain.
                if (--attempts == 0) {
                    _objc_fatal("Memory corruption in class list.");
                }
                
                // Superclass cache.
                imp = cache_getImp(curClass, sel);
                if (imp) {
                    if (imp != (IMP)_objc_msgForward_impcache) {
                        // Found the method in a superclass. Cache it in this class.
                        log_and_fill_cache(cls, imp, sel, inst, curClass);
                        goto done;
                    }
                    else {
                        // Found a forward:: entry in a superclass.
                        // Stop searching, but don't cache yet; call method 
                        // resolver for this class first.
                        break;
                    }
                }
                
                // Superclass method list.
                Method meth = getMethodNoSuper_nolock(curClass, sel);
                if (meth) {
                    log_and_fill_cache(cls, meth->imp, sel, inst, curClass);
                    imp = meth->imp;
                    goto done;
                }
            }
        }
    
        // No implementation found. Try method resolver once.
    
        if (resolver  &&  !triedResolver) {
            runtimeLock.unlockRead();
            _class_resolveMethod(cls, sel, inst);
            runtimeLock.read();
            // Don't cache the result; we don't hold the lock so it may have 
            // changed already. Re-do the search from scratch instead.
            triedResolver = YES;
            goto retry;
        }
    
        // No implementation found, and method resolver didn't help. 
        // Use forwarding.
    
        imp = (IMP)_objc_msgForward_impcache;
        cache_fill(cls, sel, imp, inst);
    
     done:
        runtimeLock.unlockRead();
    
        return imp;
    }
    
    复制代码

#### 4.2.1.4 \_class\_initialize

我们找到了`_class_initialize`

    
    /***********************************************************************
    * class_initialize.  Send the '+initialize' message on demand to any
    * uninitialized class. Force initialization of superclasses first.
    **********************************************************************/
    void _class_initialize(Class cls)
    {
        assert(!cls->isMetaClass());
    
        Class supercls;
        bool reallyInitialize = NO;
    
        // Make sure super is done initializing BEFORE beginning to initialize cls.
        // See note about deadlock above.
        supercls = cls->superclass;
        if (supercls  &&  !supercls->isInitialized()) {
            _class_initialize(supercls);
        }
        
        // Try to atomically set CLS_INITIALIZING.
        {
            monitor_locker_t lock(classInitLock);
            if (!cls->isInitialized() && !cls->isInitializing()) {
                cls->setInitializing();
                reallyInitialize = YES;
            }
        }
        
        if (reallyInitialize) {
            // We successfully set the CLS_INITIALIZING bit. Initialize the class.
            
            // Record that we're initializing this class so we can message it.
            _setThisThreadIsInitializingClass(cls);
    
            if (MultithreadedForkChild) {
                // LOL JK we don't really call +initialize methods after fork().
                performForkChildInitialize(cls, supercls);
                return;
            }
            
            // Send the +initialize message.
            // Note that +initialize is sent to the superclass (again) if 
            // this class doesn't implement +initialize. 2157218
            if (PrintInitializing) {
                _objc_inform("INITIALIZE: thread %p: calling +[%s initialize]",
                             pthread_self(), cls->nameForLogging());
            }
    
            // Exceptions: A +initialize call that throws an exception 
            // is deemed to be a complete and successful +initialize.
            //
            // Only __OBJC2__ adds these handlers. !__OBJC2__ has a
            // bootstrapping problem of this versus CF's call to
            // objc_exception_set_functions().
    #if __OBJC2__
            @try
    #endif
            {
                callInitialize(cls);
    
                if (PrintInitializing) {
                    _objc_inform("INITIALIZE: thread %p: finished +[%s initialize]",
                                 pthread_self(), cls->nameForLogging());
                }
            }
    #if __OBJC2__
            @catch (...) {
                if (PrintInitializing) {
                    _objc_inform("INITIALIZE: thread %p: +[%s initialize] "
                                 "threw an exception",
                                 pthread_self(), cls->nameForLogging());
                }
                @throw;
            }
            @finally
    #endif
            {
                // Done initializing.
                lockAndFinishInitializing(cls, supercls);
            }
            return;
        }
        
        else if (cls->isInitializing()) {
            // We couldn't set INITIALIZING because INITIALIZING was already set.
            // If this thread set it earlier, continue normally.
            // If some other thread set it, block until initialize is done.
            // It's ok if INITIALIZING changes to INITIALIZED while we're here, 
            //   because we safely check for INITIALIZED inside the lock 
            //   before blocking.
            if (_thisThreadIsInitializingClass(cls)) {
                return;
            } else if (!MultithreadedForkChild) {
                waitForInitializeToComplete(cls);
                return;
            } else {
                // We're on the child side of fork(), facing a class that
                // was initializing by some other thread when fork() was called.
                _setThisThreadIsInitializingClass(cls);
                performForkChildInitialize(cls, supercls);
            }
        }
        
        else if (cls->isInitialized()) {
            // Set CLS_INITIALIZING failed because someone else already 
            //   initialized the class. Continue normally.
            // NOTE this check must come AFTER the ISINITIALIZING case.
            // Otherwise: Another thread is initializing this class. ISINITIALIZED 
            //   is false. Skip this clause. Then the other thread finishes 
            //   initialization and sets INITIALIZING=no and INITIALIZED=yes. 
            //   Skip the ISINITIALIZING clause. Die horribly.
            return;
        }
        
        else {
            // We shouldn't be here. 
            _objc_fatal("thread-safe class init in objc runtime is buggy!");
        }
    }
    复制代码

#### 4.2.1.5 callInitialize

我们在`_class_initialize`中找到了`callInitialize`:

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cee55d891b05436b8e3e94ab6a8eee8b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    // 调用initialize的函数
    void callInitialize(Class cls)
    {
        // 通过runtime消息机制发送initialize消息
        ((void(*)(Class, SEL))objc_msgSend)(cls, SEL_initialize);
        asm("");
    }
    复制代码

可以在`callInitialize`里发现本质都是通过**Runtime的消息机制**进行的发送

### 4.2.3调用顺序

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5fd936ea14b94d809f4e79be4db9f082~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

*   先调用父类的`initialize`，再调用子类的`initialize`
*   (先初始化父类，再初始化子类，每个类只会初始化1次)
*   如果子类没有实现`initialize`，会调用父类的`initialize` ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5dedb478fe54d1b9a1ed607acdc5678~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

4.3 initialize和load的区别
----------------------

*   `initialize`是通过`objc_msgSend`进行调用的，而`load`是**找到函数地址直接调用的**
*   如果子类没有实现`initialize`，会调用父类的`initialize`
    *   所以父类的`initialize`可能会被调用多次，第一次是系统通过消息发送机制调用的父类`initialize`，后面多次的调用都是因为子类没有实现`initialize`，而通过`superclass`找到父类再次调用的
*   如果分类实现了`initialize`，就覆盖类本身的`initialize`调用