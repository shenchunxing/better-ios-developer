# Category


我们前面在回顾 [Category](https://juejin.cn/post/7096359857221009444 "https://juejin.cn/post/7096359857221009444") 的基本使用的时候,我们得出了 `Category` 相关的结论:

*   通过Category可以给在没有继承关系的情况下 给 原类 增加功能(添加方法:`实例方法`、`Class方法`)
*   方法调用的优先级:
*   *   Category 的实现 > 原来的类 的实现
*   *   后编译的 Category 的实现 > 先编译的 Category 的实现
*   *   总结: `后编译的 Category > 先编译的 Category >原来的类`
*   通过Category可以给 原类 增加属性
*   *   编译器只会 默认给 该属性 添加 setter方法、getter方法的定义
*   *   通过Category 添加的属性的 setter方法、getter方法 需要 开发者实现
*   *   我们最终 通过 runtimeAPI 进行`关联对象`操作,对 setter 、getter 方法 完成了最简便、最可靠的实现
```
#import <objc/runtime.h> 
void  objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,id _Nullable value, objc_AssociationPolicy policy) ;

id _Nullable objc_getAssociatedObject(id _Nonnull object, const void * _Nonnull key); 
```
探究其底层原理的实现:
*   1.  Category如何给类添加 Instance对象方法、Class对象方法的？
*   2.  Category与原来的Class内部的方法的调用优先级如何实现的？
*   3.  为什么 通过Category可以给 原类 增加属性,但是只会添加 setter方法、getter方法的定义,而 setter方法、getter方法的实现需要 开发者自己完成？
*   4.  通过RuntimeAPI进行 `关联对象`操作,其底层原理是什么？

二、Category的本质
=============
    
    @interface Car : NSObject{
    @public
        int _year;
    }
    
    -(void)run;
    +(void)light;
    @end
    
    NS_ASSUME_NONNULL_END

    //  Car.m
    #import "Car.h"
    
    @implementation Car
    - (void)run{
        NSLog(@"%s",__func__);
    }
    + (void)light{
        NSLog(@"%s",__func__);
    }
    @end

**分类(`Car+Test`)的声明与实现:**

    #import "Car.h"
      
    @interface Car (Test)
    - (void)runFaster;
    + (void)lightLongTime;
    @end
     
    #import "Car+Test.h"
    @implementation Car (Test)
    - (void)run{
        NSLog(@"%s",__func__);
    }
    - (void)runFaster{
        NSLog(@"%s",__func__);
    }
    + (void)light{
        NSLog(@"%s",__func__);
    }
    + (void)lightLongTime{
        NSLog(@"%s",__func__);
    }
    
    @end

我们通过Clang指令对 两个.m文件进行转换,得到其底层实现的 `伪代码`(可参考的底层实现逻辑、因为OC是一个具备动态运行时特性的语言,部分细节还得到动态运行时才知道其真正的实现)

    clang -rewrite-objc 源码实现文件名.m

1.Category的底层实现
---------------
主类的核心信息是存放在结构体`_class_ro_t`中的

类的结构：
![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cca4b5a9b1c44e5abf4f0d830fc114c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

通过前面的分析我们发现:`分类源码中确实是将我们定义的对象方法，类方法，属性等都存放在catagory_t结构体中`  
接下来我们在回到runtime源码查看 `catagory_t` 存储的方法，属性，协议等是如何存储在类对象中的。  
我们在`objc-rumtime-new.mm`中找到的`category_t`的具体实现:

    struct category_t {
        const char *name;
        classref_t cls;
        struct method_list_t *instanceMethods;
        struct method_list_t *classMethods;
        struct protocol_list_t *protocols;
        struct property_list_t *instanceProperties;
        // Fields below this point are not always present on disk.
        struct property_list_t *_classProperties;
    
        method_list_t *methodsForMeta(bool isMeta) {
            if (isMeta) return classMethods;
            else return instanceMethods;
        }
    
        property_list_t *propertiesForMeta(bool isMeta, struct header_info *hi);
    };

与我们通过clang命令转出来的底层实现高度相似:

    struct _category_t {
        const char *name;//类名
        struct _class_t *cls;//主类指针
        const struct _method_list_t *instance_methods; // 对象方法
        const struct _method_list_t *class_methods;// 类方法
        const struct _protocol_list_t *protocols;// 协议
        const struct _prop_list_t *properties; // 属性
    };

2.Category的加载处理过程
-----------------
### 2.1 函数 `attachCategories`

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/46a16c2bcaf04a219071084bf0c453ed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 通过分析查找到`objc-rumtime-new.mm`文件里的`attachCategories`函数，将分类文件里的数据信息都附加到对应的类对象或者元类对象里,代码如下:

    // 附加上分类的核心操作
    // cls:类对象或者元类对象，cats_list：分类列表
    static void attachCategories(Class cls, const locstamped_category_t *cats_list, uint32_t cats_count,
                     int flags)
    {
        if (slowpath(PrintReplacedMethods)) {
            printReplacements(cls, cats_list, cats_count);
        }
        if (slowpath(PrintConnecting)) {
            _objc_inform("CLASS: attaching %d categories to%s class '%s'%s",
                         cats_count, (flags & ATTACH_EXISTING) ? " existing" : "",
                         cls->nameForLogging(), (flags & ATTACH_METACLASS) ? " (meta)" : "");
        }
    
        // 先分配固定内存空间来存放方法列表、属性列表和协议列表
        constexpr uint32_t ATTACH_BUFSIZ = 64;
        method_list_t   *mlists[ATTACH_BUFSIZ];
        property_list_t *proplists[ATTACH_BUFSIZ];
        protocol_list_t *protolists[ATTACH_BUFSIZ];
    
        uint32_t mcount = 0;
        uint32_t propcount = 0;
        uint32_t protocount = 0;
        bool fromBundle = NO;
        
        // 判断是否为元类
        bool isMeta = (flags & ATTACH_METACLASS);
        auto rwe = cls->data()->extAllocIfNeeded();
    
        for (uint32_t i = 0; i < cats_count; i++) {
            // 取出某个分类
            auto& entry = cats_list[i];
    
            // entry.cat就是category_t *cat
            // 根据isMeta属性取出每一个分类的类方法列表或者对象方法列表
            method_list_t *mlist = entry.cat->methodsForMeta(isMeta);
            
            // 如果有方法则添加mlist数组到mlists这个大的方法数组中
            // mlists是一个二维数组：[[method_t, method_t, ....], [method_t, method_t, ....]]
            if (mlist) {
                if (mcount == ATTACH_BUFSIZ) {
                    prepareMethodLists(cls, mlists, mcount, NO, fromBundle, __func__);
                    rwe->methods.attachLists(mlists, mcount);
                    mcount = 0;
                }
                // 将分类列表里先取出来的分类方法列表放到大数组mlists的最后面（ATTACH_BUFSIZ - ++mcount），所以最后编译的分类方法列表会放在整个方法列表大数组的最前面            
                mlists[ATTACH_BUFSIZ - ++mcount] = mlist;
                fromBundle |= entry.hi->isBundle();
            }
    
            // 同上面一样取出的是分类中的属性列表proplist加到大数组proplists中
            // proplists是一个二维数组：[[property_t, property_t, ....], [property_t, property_t, ....]]
            property_list_t *proplist =
                entry.cat->propertiesForMeta(isMeta, entry.hi);
            if (proplist) {
                if (propcount == ATTACH_BUFSIZ) {
                    rwe->properties.attachLists(proplists, propcount);
                    propcount = 0;
                }
                proplists[ATTACH_BUFSIZ - ++propcount] = proplist;
            }
    
            // 同上面一样取出的是分类中的协议列表protolist加到大数组protolists中
            // protolists是一个二维数组：[[protocol_ref_t, protocol_ref_t, ....], [protocol_ref_t, protocol_ref_t, ....]]
            protocol_list_t *protolist = entry.cat->protocolsForMeta(isMeta);
            if (protolist) {
                if (protocount == ATTACH_BUFSIZ) {
                    rwe->protocols.attachLists(protolists, protocount);
                    protocount = 0;
                }
                protolists[ATTACH_BUFSIZ - ++protocount] = protolist;
            }
        }
    
        if (mcount > 0) {
            prepareMethodLists(cls, mlists + ATTACH_BUFSIZ - mcount, mcount,
                               NO, fromBundle, __func__);
            
            // 将分类的所有对象方法或者类方法，都附加到类对象或者元类对象的方法列表中
            rwe->methods.attachLists(mlists + ATTACH_BUFSIZ - mcount, mcount);
            if (flags & ATTACH_EXISTING) {
                flushCaches(cls, __func__, [](Class c){
                    return !c->cache.isConstantOptimizedCache();
                });
            }
        }
    
        // 将分类的所有属性附加到类对象的属性列表中
        rwe->properties.attachLists(proplists + ATTACH_BUFSIZ - propcount, propcount); 
        // 将分类的所有协议附加到类对象的协议列表中
        rwe->protocols.attachLists(protolists + ATTACH_BUFSIZ - protocount, protocount);
    } 
    复制代码

### 2.2 上述的每步操作都会调用`attachLists`方法来进行元素分配，详细代码如下

    void attachLists(List* const * addedLists, uint32_t addedCount) {
       if (addedCount == 0) return;
    
       if (hasArray()) {
           // 获取原本的个数
           uint32_t oldCount = array()->count;
           // 最新的个数 = 原本的个数 + 新添加的个数
           uint32_t newCount = oldCount + addedCount;
           
           // 重新分配内存
           array_t *newArray = (array_t *)malloc(array_t::byteSize(newCount));
           // 将新数组的个数改为最新的个数
           newArray->count = newCount;
           // 将旧数组的个数改为最新的个数
           array()->count = newCount;
           
           // 递减遍历，将旧数组里的元素从后往前的依次放到新数组里
           for (int i = oldCount - 1; i >= 0; i--)
               newArray->lists[i + addedCount] = array()->lists[i];
           
           // 将新增加的元素从前往后的依次放到新数组里
           for (unsigned i = 0; i < addedCount; i++)
               newArray->lists[i] = addedLists[i];
           
           // 释放旧数组数据
           free(array());
           
           // 赋值新数组数据
           setArray(newArray);
           validate();
       }
       else if (!list  &&  addedCount == 1) {
           // 0 lists -> 1 list
           list = addedLists[0];
           validate();
       } 
       else { .... }
    } 
    复制代码

**上述源代码中有两个重要的数组** **array()->lists： 类对象原来的方法列表，属性列表，协议列表。** **addedLists：传入所有分类的方法列表，属性列表，协议列表。**

`attachLists函数`中最重要的两个方法:

*   `memmove内存移动`
*   `memcpy内存拷贝` 我们先来分别看一下这两个函数:
```
// memmove ：内存移动。
    /*  __dst : 移动内存的目的地
    *   __src : 被移动的内存首地址
    *   __len : 被移动的内存长度
    *   将__src的内存移动__len块内存到__dst中
    */
    void    *memmove(void *__dst, const void *__src, size_t __len);
    
    // memcpy ：内存拷贝。
    /*  __dst : 拷贝内存的拷贝目的地
    *   __src : 被拷贝的内存首地址
    *   __n : 被移动的内存长度
    *   将__src的内存拷贝__n块内存到__dst中
    */
    void    *memcpy(void *__dst, const void *__src, size_t __n);
```
下面我们图示经过memmove和memcpy方法过后的内存变化。

![未经过内存移动和拷贝时](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fd536998ff764aee8c7433b45a3ccd07~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

经过memmove方法之后，内存变化为

    // array()->lists 原来方法、属性、协议列表数组
    // addedCount 分类数组长度
    // oldCount * sizeof(array()->lists[0]) 原来数组占据的空间
    memmove(array()->lists + addedCount, array()->lists, 
                      oldCount * sizeof(array()->lists[0]));

![memmove方法之后内存变化](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/21aa3df305bc4a14bcc013c8c857c822~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

经过memmove方法之后，我们发现，虽然本类的方法，属性，协议列表会分别后移，但是本类的对应数组的指针依然指向原始位置。

memcpy方法之后，内存变化

    // array()->lists 原来方法、属性、协议列表数组
    // addedLists 分类方法、属性、协议列表数组
    // addedCount * sizeof(array()->lists[0]) 原来数组占据的空间
    memcpy(array()->lists, addedLists, 
                   addedCount * sizeof(array()->lists[0]));

![memmove方法之后，内存变化](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/32358179bed04d348512cbc79e633c0c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们发现:
*   原来指针并没有改变，至始至终指向开头的位置
*   并且经过memmove和memcpy方法之后，分类的方法，属性，协议列表被放在了类对象中原本存储的方法，属性，协议列表前面

那么为什么要将分类方法的列表追加到本来的对象方法前面呢?
*   这样做的目的是为了保证分类方法优先调用
*   我们知道当分类重写本类的方法时，会覆盖本类的方法。
*   其实经过上面的分析我们知道分类和主类有相同的方法的实现源码时,分类实现优先于主类的本质上并不是方法覆盖，而是在方法栈中的顺序不同，
*   *   分类的方法在占中的顺序较前,被优先调用
*   *   多个分类 有相同 方法的实现的时候,则按照源码编译的顺序（实则是分类被加入分类数组,在被遍历的时候的先后顺序决定了方法实现在方法栈中的顺序）

3.总结
----
*   编译时
    *   每一个`Category`都会生成一个`category_t`结构体对象，记录着所有的属性、方法和协议信息
    *   多个 `category_t` 会被放在 `category_list`中
*   运行时
    *   通过`Runtime`加载某个类的所有`Category`数据
    *   把所有`Category`的对象方法、类方法、属性、协议数据，分别合并到一个二维数组中，并且后面参与编译的`Category`数据，会在数组的前面
    *   将合并后的`Category`数据（方法、属性、协议），插入到类原来数据的前面
*   求证方法的调用顺序的原理
*   *   后编译的 Category > 先编译的 Category >原来的类(本质原因是 它们 在方法栈中的顺序不同,优先级不同)

三、App启动装载的过程
============

我们前面只是了解到了 Category 底层实现 和 Category 内部内容的如何装载 到 类、元类中的实现。对于 Class的装载过程,如何一步一步来到 Category的装载过程的了解有些欠缺！  
我们在了解[App启动优化](https://juejin.cn/post/7088342896658612238 "https://juejin.cn/post/7088342896658612238")的时候,曾谈及App冷启动的过程:

> APP的冷启动可以概括为3大阶段:
> 
> *   `dyld动态库加载`
> *   `Runtime初始化`
> *   `进入main函数`,开始整个应用的声明周期 ![-w897](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6747fbf8ebe14b4387ad738be27a774a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

1\. `dyld动态库加载`
---------------

`dyld（dynamic link editor）`，Apple的动态链接器，可以用来装载`Mach-O文件（可执行文件、动态库等）`

**启动APP时，`dyld`所做的事情如下：**
1.  启动APP时，`dyld`会先装载APP的可执行文件，同时会递归加载所有依赖的动态库
2.  当`dyld`把可执行文件、动态库都装载完毕后，会通知`Runtime`进行下一步的处理

2\. `Runtime初始化`
----------------

**启动APP时，`Runtime`所做的事情如下:**

*   `Runtime`会调用`map_images`进行可执行文件内容的解析和处理
*   在`load_images`中调用`call_load_methods`，调用所有`Class`和`Category`的`+load方法`
*   进行各种`objc`结构的初始化（注册Objc类 、初始化类对象等等）
*   调用`C++`静态初始化器和`__attribute__((constructor))`修饰的函数

到此为止，可执行文件和动态库中所有的符号`(Class，Protocol，Selector，IMP，…)`都已经按格式成功加载到内存中，被`Runtime`所管理

3\. 进入main函数
------------

**总结一下,整个启动过程可以概述为：**
1.  APP的启动由`dyld`主导，将可执行文件加载到内存，顺便加载所有依赖的动态库
2.  并由`Runtime`负责加载成`objc`定义的结构
3.  然后所有初始化工作结束后，`dyld`就会调用`main函数`
4.  接下来就是`UIApplicationMain函数`，`AppDelegate`的`application:didFinishLaunchingWithOptions:方法`

4.通过阅读源码关注`dyld动态库加载`、`Runtime初始化`
----------------------------------

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/172f6bf9b8b94b0e987171aa20da04ba~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    
    /***********************************************************************
    * _objc_init
    * Bootstrap initialization. Registers our image notifier with dyld.
    * Called by libSystem BEFORE library initialization time
    **********************************************************************/
    
    void _objc_init(void)
    {
        static bool initialized = false;
        if (initialized) return;
        initialized = true;
        
        // fixme defer initialization until an objc-using image is found?
        environ_init();
        tls_init();
        static_init();
        lock_init();
        exception_init();
    
        _dyld_objc_notify_register(&map_images, load_images, unmap_image);
    } 

我们在`_dyld_objc_notify_register(&map_images, load_images, unmap_image);`这段代码中发现了装载的过程:
*   `&map_images`:读取模块(images这里代表模块）
*   `load_images`:装载模块
*   `unmap_image`:结束读取模块

### 4.1 map\_images 读取模块过程
 ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f5036fccde57492fab406ef0900d9c0e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 4.1.1 `map_images_nolock`函数
    void 
    map_images_nolock(unsigned mhCount, const char * const mhPaths[],
                      const struct mach_header * const mhdrs[])
    {
        static bool firstTime = YES;
        header_info *hList[mhCount];
        uint32_t hCount;
        size_t selrefCount = 0;
    
        // Perform first-time initialization if necessary.
        // This function is called before ordinary library initializers. 
        // fixme defer initialization until an objc-using image is found?
        if (firstTime) {
            preopt_init();
        }
    
        if (PrintImages) {
            _objc_inform("IMAGES: processing %u newly-mapped images...\n", mhCount);
        }
    
    
        // Find all images with Objective-C metadata.
        hCount = 0;
    
        // Count classes. Size various table based on the total.
        int totalClasses = 0;
        int unoptimizedTotalClasses = 0;
        {
            uint32_t i = mhCount;
            while (i--) {
                const headerType *mhdr = (const headerType *)mhdrs[i];
    
                auto hi = addHeader(mhdr, mhPaths[i], totalClasses, unoptimizedTotalClasses);
                if (!hi) {
                    // no objc data in this entry
                    continue;
                }
                
                if (mhdr->filetype == MH_EXECUTE) {
                    // Size some data structures based on main executable's size
    #if __OBJC2__
                    size_t count;
                    _getObjc2SelectorRefs(hi, &count);
                    selrefCount += count;
                    _getObjc2MessageRefs(hi, &count);
                    selrefCount += count;
    #else
                    _getObjcSelectorRefs(hi, &selrefCount);
    #endif
                    
    #if SUPPORT_GC_COMPAT
                    // Halt if this is a GC app.
                    if (shouldRejectGCApp(hi)) {
                        _objc_fatal_with_reason
                            (OBJC_EXIT_REASON_GC_NOT_SUPPORTED, 
                             OS_REASON_FLAG_CONSISTENT_FAILURE, 
                             "Objective-C garbage collection " 
                             "is no longer supported.");
                    }
    #endif
                }
                
                hList[hCount++] = hi;
                
                if (PrintImages) {
                    _objc_inform("IMAGES: loading image for %s%s%s%s%s\n", 
                                 hi->fname(),
                                 mhdr->filetype == MH_BUNDLE ? " (bundle)" : "",
                                 hi->info()->isReplacement() ? " (replacement)" : "",
                                 hi->info()->hasCategoryClassProperties() ? " (has class properties)" : "",
                                 hi->info()->optimizedByDyld()?" (preoptimized)":"");
                }
            }
        }
    
        // Perform one-time runtime initialization that must be deferred until 
        // the executable itself is found. This needs to be done before 
        // further initialization.
        // (The executable may not be present in this infoList if the 
        // executable does not contain Objective-C code but Objective-C 
        // is dynamically loaded later.
        if (firstTime) {
            sel_init(selrefCount);
            arr_init();
    
    #if SUPPORT_GC_COMPAT
            // Reject any GC images linked to the main executable.
            // We already rejected the app itself above.
            // Images loaded after launch will be rejected by dyld.
    
            for (uint32_t i = 0; i < hCount; i++) {
                auto hi = hList[i];
                auto mh = hi->mhdr();
                if (mh->filetype != MH_EXECUTE  &&  shouldRejectGCImage(mh)) {
                    _objc_fatal_with_reason
                        (OBJC_EXIT_REASON_GC_NOT_SUPPORTED, 
                         OS_REASON_FLAG_CONSISTENT_FAILURE, 
                         "%s requires Objective-C garbage collection "
                         "which is no longer supported.", hi->fname());
                }
            }
    #endif
    
    #if TARGET_OS_OSX
            // Disable +initialize fork safety if the app is too old (< 10.13).
            // Disable +initialize fork safety if the app has a
            //   __DATA,__objc_fork_ok section.
    
            if (dyld_get_program_sdk_version() < DYLD_MACOSX_VERSION_10_13) {
                DisableInitializeForkSafety = true;
                if (PrintInitializing) {
                    _objc_inform("INITIALIZE: disabling +initialize fork "
                                 "safety enforcement because the app is "
                                 "too old (SDK version " SDK_FORMAT ")",
                                 FORMAT_SDK(dyld_get_program_sdk_version()));
                }
            }
    
            for (uint32_t i = 0; i < hCount; i++) {
                auto hi = hList[i];
                auto mh = hi->mhdr();
                if (mh->filetype != MH_EXECUTE) continue;
                unsigned long size;
                if (getsectiondata(hi->mhdr(), "__DATA", "__objc_fork_ok", &size)) {
                    DisableInitializeForkSafety = true;
                    if (PrintInitializing) {
                        _objc_inform("INITIALIZE: disabling +initialize fork "
                                     "safety enforcement because the app has "
                                     "a __DATA,__objc_fork_ok section");
                    }
                }
                break;  // assume only one MH_EXECUTE image
            }
    #endif
    
        }
    
        if (hCount > 0) {
            _read_images(hList, hCount, totalClasses, unoptimizedTotalClasses);
        }
    
        firstTime = NO;
    }

#### 4.1.2 `_read_images`函数

来到`map_images_nolock函数`中找到`_read_images函数`

        if (hCount > 0) {
            _read_images(hList, hCount, totalClasses, unoptimizedTotalClasses);
        }

**从`map_images_nolock函数` 到`_read_images函数` 的过程,即完成 动态库的装载准备,进入runtime的过程**  
在`_read_images函数中`我们找到分类相关代码: ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bea709e4112842bc80591b218d1ac2d7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    void _read_images(header_info **hList, uint32_t hCount, int totalClasses, int unoptimizedTotalClasses)
    {
        header_info *hi;
        uint32_t hIndex;
        size_t count;
        size_t i;
        Class *resolvedFutureClasses = nil;
        size_t resolvedFutureClassCount = 0;
        static bool doneOnce;
        TimeLogger ts(PrintImageTimes);
    
        runtimeLock.assertWriting();
    
    #define EACH_HEADER \
        hIndex = 0;         \
        hIndex < hCount && (hi = hList[hIndex]); \
        hIndex++
    
        if (!doneOnce) {
            doneOnce = YES;
    
    #if SUPPORT_NONPOINTER_ISA
            // Disable non-pointer isa under some conditions.
    
    # if SUPPORT_INDEXED_ISA
            // Disable nonpointer isa if any image contains old Swift code
            for (EACH_HEADER) {
                if (hi->info()->containsSwift()  &&
                    hi->info()->swiftVersion() < objc_image_info::SwiftVersion3)
                {
                    DisableNonpointerIsa = true;
                    if (PrintRawIsa) {
                        _objc_inform("RAW ISA: disabling non-pointer isa because "
                                     "the app or a framework contains Swift code "
                                     "older than Swift 3.0");
                    }
                    break;
                }
            }
    # endif
    
    # if TARGET_OS_OSX
            // Disable non-pointer isa if the app is too old
            // (linked before OS X 10.11)
            if (dyld_get_program_sdk_version() < DYLD_MACOSX_VERSION_10_11) {
                DisableNonpointerIsa = true;
                if (PrintRawIsa) {
                    _objc_inform("RAW ISA: disabling non-pointer isa because "
                                 "the app is too old (SDK version " SDK_FORMAT ")",
                                 FORMAT_SDK(dyld_get_program_sdk_version()));
                }
            }
    
            // Disable non-pointer isa if the app has a __DATA,__objc_rawisa section
            // New apps that load old extensions may need this.
            for (EACH_HEADER) {
                if (hi->mhdr()->filetype != MH_EXECUTE) continue;
                unsigned long size;
                if (getsectiondata(hi->mhdr(), "__DATA", "__objc_rawisa", &size)) {
                    DisableNonpointerIsa = true;
                    if (PrintRawIsa) {
                        _objc_inform("RAW ISA: disabling non-pointer isa because "
                                     "the app has a __DATA,__objc_rawisa section");
                    }
                }
                break;  // assume only one MH_EXECUTE image
            }
    # endif
    
    #endif
    
            if (DisableTaggedPointers) {
                disableTaggedPointers();
            }
            
            if (PrintConnecting) {
                _objc_inform("CLASS: found %d classes during launch", totalClasses);
            }
    
            // namedClasses
            // Preoptimized classes don't go in this table.
            // 4/3 is NXMapTable's load factor
            int namedClassesSize = 
                (isPreoptimized() ? unoptimizedTotalClasses : totalClasses) * 4 / 3;
            gdb_objc_realized_classes =
                NXCreateMapTable(NXStrValueMapPrototype, namedClassesSize);
    
            ts.log("IMAGE TIMES: first time tasks");
        }
    
    
        // Discover classes. Fix up unresolved future classes. Mark bundle classes.
    
        for (EACH_HEADER) {
            if (! mustReadClasses(hi)) {
                // Image is sufficiently optimized that we need not call readClass()
                continue;
            }
    
            bool headerIsBundle = hi->isBundle();
            bool headerIsPreoptimized = hi->isPreoptimized();
    
            classref_t *classlist = _getObjc2ClassList(hi, &count);
            for (i = 0; i < count; i++) {
                Class cls = (Class)classlist[i];
                Class newCls = readClass(cls, headerIsBundle, headerIsPreoptimized);
    
                if (newCls != cls  &&  newCls) {
                    // Class was moved but not deleted. Currently this occurs 
                    // only when the new class resolved a future class.
                    // Non-lazily realize the class below.
                    resolvedFutureClasses = (Class *)
                        realloc(resolvedFutureClasses, 
                                (resolvedFutureClassCount+1) * sizeof(Class));
                    resolvedFutureClasses[resolvedFutureClassCount++] = newCls;
                }
            }
        }
 
        ts.log("IMAGE TIMES: discover classes");
    
        // Fix up remapped classes
        // Class list and nonlazy class list remain unremapped.
        // Class refs and super refs are remapped for message dispatching.
        
        if (!noClassesRemapped()) {
            for (EACH_HEADER) {
                Class *classrefs = _getObjc2ClassRefs(hi, &count);
                for (i = 0; i < count; i++) {
                    remapClassRef(&classrefs[i]);
                }
                // fixme why doesn't test future1 catch the absence of this?
                classrefs = _getObjc2SuperRefs(hi, &count);
                for (i = 0; i < count; i++) {
                    remapClassRef(&classrefs[i]);
                }
            }
        }
    
        ts.log("IMAGE TIMES: remap classes");
    
        // Fix up @selector references
        static size_t UnfixedSelectors;
        sel_lock();
        for (EACH_HEADER) {
            if (hi->isPreoptimized()) continue;
    
            bool isBundle = hi->isBundle();
            SEL *sels = _getObjc2SelectorRefs(hi, &count);
            UnfixedSelectors += count;
            for (i = 0; i < count; i++) {
                const char *name = sel_cname(sels[i]);
                sels[i] = sel_registerNameNoLock(name, isBundle);
            }
        }
        sel_unlock();
    
        ts.log("IMAGE TIMES: fix up selector references");
    
    #if SUPPORT_FIXUP
        // Fix up old objc_msgSend_fixup call sites
        for (EACH_HEADER) {
            message_ref_t *refs = _getObjc2MessageRefs(hi, &count);
            if (count == 0) continue;
    
            if (PrintVtables) {
                _objc_inform("VTABLES: repairing %zu unsupported vtable dispatch "
                             "call sites in %s", count, hi->fname());
            }
            for (i = 0; i < count; i++) {
                fixupMessageRef(refs+i);
            }
        }
    
        ts.log("IMAGE TIMES: fix up objc_msgSend_fixup");
    #endif
    
        // Discover protocols. Fix up protocol refs.
        for (EACH_HEADER) {
            extern objc_class OBJC_CLASS_$_Protocol;
            Class cls = (Class)&OBJC_CLASS_$_Protocol;
            assert(cls);
            NXMapTable *protocol_map = protocols();
            bool isPreoptimized = hi->isPreoptimized();
            bool isBundle = hi->isBundle();
    
            protocol_t **protolist = _getObjc2ProtocolList(hi, &count);
            for (i = 0; i < count; i++) {
                readProtocol(protolist[i], cls, protocol_map, 
                             isPreoptimized, isBundle);
            }
        }
    
        ts.log("IMAGE TIMES: discover protocols");
    
        // Fix up @protocol references
        // Preoptimized images may have the right 
        // answer already but we don't know for sure.
        for (EACH_HEADER) {
            protocol_t **protolist = _getObjc2ProtocolRefs(hi, &count);
            for (i = 0; i < count; i++) {
                remapProtocolRef(&protolist[i]);
            }
        }
    
        ts.log("IMAGE TIMES: fix up @protocol references");
    
        // Realize non-lazy classes (for +load methods and static instances)
        for (EACH_HEADER) {
            classref_t *classlist = 
                _getObjc2NonlazyClassList(hi, &count);
            for (i = 0; i < count; i++) {
                Class cls = remapClass(classlist[i]);
                if (!cls) continue;
    
                // hack for class __ARCLite__, which didn't get this above
    #if TARGET_OS_SIMULATOR
                if (cls->cache._buckets == (void*)&_objc_empty_cache  &&  
                    (cls->cache._mask  ||  cls->cache._occupied)) 
                {
                    cls->cache._mask = 0;
                    cls->cache._occupied = 0;
                }
                if (cls->ISA()->cache._buckets == (void*)&_objc_empty_cache  &&  
                    (cls->ISA()->cache._mask  ||  cls->ISA()->cache._occupied)) 
                {
                    cls->ISA()->cache._mask = 0;
                    cls->ISA()->cache._occupied = 0;
                }
    #endif
    
                realizeClass(cls);
            }
        }
    
        ts.log("IMAGE TIMES: realize non-lazy classes");
    
        // Realize newly-resolved future classes, in case CF manipulates them
        if (resolvedFutureClasses) {
            for (i = 0; i < resolvedFutureClassCount; i++) {
                realizeClass(resolvedFutureClasses[i]);
                resolvedFutureClasses[i]->setInstancesRequireRawIsa(false/*inherited*/);
            }
            free(resolvedFutureClasses);
        }    
    
        ts.log("IMAGE TIMES: realize future classes");
    
        // Discover categories. 
        for (EACH_HEADER) {
            category_t **catlist = 
                _getObjc2CategoryList(hi, &count);
            bool hasClassProperties = hi->info()->hasCategoryClassProperties();
    
            for (i = 0; i < count; i++) {
                category_t *cat = catlist[i];
                Class cls = remapClass(cat->cls);
    
                if (!cls) {
                    // Category's target class is missing (probably weak-linked).
                    // Disavow any knowledge of this category.
                    catlist[i] = nil;
                    if (PrintConnecting) {
                        _objc_inform("CLASS: IGNORING category \?\?\?(%s) %p with "
                                     "missing weak-linked target class", 
                                     cat->name, cat);
                    }
                    continue;
                }
    
                // Process this category. 
                // First, register the category with its target class. 
                // Then, rebuild the class's method lists (etc) if 
                // the class is realized. 
                bool classExists = NO;
                if (cat->instanceMethods ||  cat->protocols  
                    ||  cat->instanceProperties) 
                {
                    addUnattachedCategoryForClass(cat, cls, hi);
                    if (cls->isRealized()) {
                        remethodizeClass(cls);
                        classExists = YES;
                    }
                    if (PrintConnecting) {
                        _objc_inform("CLASS: found category -%s(%s) %s", 
                                     cls->nameForLogging(), cat->name, 
                                     classExists ? "on existing class" : "");
                    }
                }
    
                if (cat->classMethods  ||  cat->protocols  
                    ||  (hasClassProperties && cat->_classProperties)) 
                {
                    addUnattachedCategoryForClass(cat, cls->ISA(), hi);
                    if (cls->ISA()->isRealized()) {
                        remethodizeClass(cls->ISA());
                    }
                    if (PrintConnecting) {
                        _objc_inform("CLASS: found category +%s(%s)", 
                                     cls->nameForLogging(), cat->name);
                    }
                }
            }
        }
   
        ts.log("IMAGE TIMES: discover categories");
    
        // Category discovery MUST BE LAST to avoid potential races 
        // when other threads call the new category code before 
        // this thread finishes its fixups.
    
        // +load handled by prepare_load_methods()
    
        if (DebugNonFragileIvars) {
            realizeAllClasses();
        }
    
    
        // Print preoptimization statistics
        if (PrintPreopt) {
            static unsigned int PreoptTotalMethodLists;
            static unsigned int PreoptOptimizedMethodLists;
            static unsigned int PreoptTotalClasses;
            static unsigned int PreoptOptimizedClasses;
    
            for (EACH_HEADER) {
                if (hi->isPreoptimized()) {
                    _objc_inform("PREOPTIMIZATION: honoring preoptimized selectors "
                                 "in %s", hi->fname());
                }
                else if (hi->info()->optimizedByDyld()) {
                    _objc_inform("PREOPTIMIZATION: IGNORING preoptimized selectors "
                                 "in %s", hi->fname());
                }
    
                classref_t *classlist = _getObjc2ClassList(hi, &count);
                for (i = 0; i < count; i++) {
                    Class cls = remapClass(classlist[i]);
                    if (!cls) continue;
    
                    PreoptTotalClasses++;
                    if (hi->isPreoptimized()) {
                        PreoptOptimizedClasses++;
                    }
                    
                    const method_list_t *mlist;
                    if ((mlist = ((class_ro_t *)cls->data())->baseMethods())) {
                        PreoptTotalMethodLists++;
                        if (mlist->isFixedUp()) {
                            PreoptOptimizedMethodLists++;
                        }
                    }
                    if ((mlist=((class_ro_t *)cls->ISA()->data())->baseMethods())) {
                        PreoptTotalMethodLists++;
                        if (mlist->isFixedUp()) {
                            PreoptOptimizedMethodLists++;
                        }
                    }
                }
            }
    
            _objc_inform("PREOPTIMIZATION: %zu selector references not "
                         "pre-optimized", UnfixedSelectors);
            _objc_inform("PREOPTIMIZATION: %u/%u (%.3g%%) method lists pre-sorted",
                         PreoptOptimizedMethodLists, PreoptTotalMethodLists, 
                         PreoptTotalMethodLists
                         ? 100.0*PreoptOptimizedMethodLists/PreoptTotalMethodLists 
                         : 0.0);
            _objc_inform("PREOPTIMIZATION: %u/%u (%.3g%%) classes pre-registered",
                         PreoptOptimizedClasses, PreoptTotalClasses, 
                         PreoptTotalClasses 
                         ? 100.0*PreoptOptimizedClasses/PreoptTotalClasses
                         : 0.0);
            _objc_inform("PREOPTIMIZATION: %zu protocol references not "
                         "pre-optimized", UnfixedProtocolReferences);
        }
    
    #undef EACH_HEADER
    }

从上述代码中我们可以知道这段代码是用来查找`有没有分类`的。

*   通过`_getObjc2CategoryList函数`获取到分类列表之后，进行遍历，获取其中的方法，协议，属性等。
*   可以看到最终都调用了`remethodizeClass(cls);`函数。我们来到remethodizeClass(cls);函数内部查看: ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2cbe3141328e4a0aabae6e3c2846d4f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 通过上述代码我们发现
*   `attachCategories函数`接收了类对象cls和分类数组cats。一个类可以有多个分类
*   之前我们说到分类信息存储`在category_t结构体`中，那么**多个分类则保存在category\_list**中。

紧接着 `attachCategories函数`的装载内容应该回到 本文第二章节 `Category的本质` 的 第二小节`Category的加载处理过程`中了解了

整体的过程如附图:

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e8c0b6f7e314fefa2c829d3713ec59c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 4.1.3 总结

*   App启动先加载动态库,为进入runtime准备,在苹果开源代码中的函数顺序为:
*   *   objc-os.mm:
*   *   *   \_objc\_init
*   *   *   map\_images
*   *   *   *   map\_images\_nolock
*   进入runtime后,装载类和分类,在苹果开源代码中的函数顺序为:
*   *   objc-runtime-new.mm
*   *   *   \_read\_images
*   *   *   remethodizeClass
*   *   *   attachCategories
*   *   *   attachLists
*   *   *   realloc、memmove、 memcpy

### 4.2 load\_images 装载模块过程

接下来我们分析`load_images`底层的逻辑流程，点击`load_images`进入

    void load_images(const char *path __unused, const struct mach_header *mh)
    {
        // Return without taking locks if there are no +load methods here.
        if (!hasLoadMethods((const headerType *)mh)) return;
    
        recursive_mutex_locker_t lock(loadMethodLock);
    
        // Discover load methods
        {
            mutex_locker_t lock2(runtimeLock);
            // 准备load方法
            prepare_load_methods((const headerType *)mh);
        }
    
        // Call +load methods (without runtimeLock - re-entrant)
        // 调用load方法
        call_load_methods();
    }

我们找到关键代码
*   1.  `prepare_load_methods` 准备load方法
*   2.  `call_load_methods` 调用load方法

#### 4.2.1 prepare\_load\_methods底层实现
![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a408d45953464524a8cde0e3197e89f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    void prepare_load_methods(const headerType *mhdr)
    {
        size_t count, i;
    
        runtimeLock.assertLocked();
        // 按编译顺序拿到所有的类的list
        //先递归调度 类和父类
        classref_t *classlist = 
            _getObjc2NonlazyClassList(mhdr, &count);
        // 按添加进数组的顺序遍历处理类的列表
        for (i = 0; i < count; i++) {
            schedule_class_load(remapClass(classlist[i]));
        }
        // 按编译顺序拿到所有的分类列表
        //再调度分类
        category_t **categorylist = _getObjc2NonlazyCategoryList(mhdr, &count);
        for (i = 0; i < count; i++) {
            category_t *cat = categorylist[i];
            Class cls = remapClass(cat->cls);
            if (!cls) continue;  // category for ignored weak-linked class
            realizeClass(cls);
            assert(cls->ISA()->isRealized());
            // 按顺序直接添加
            add_category_to_loadable_list(cat);
        }
    }

进入`schedule_class_load`

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/444709464da347c38dc2783a1e1baa89~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    /***********************************************************************
    * prepare_load_methods
    * Schedule +load for classes in this image, any un-+load-ed 
    * superclasses in other images, and any categories in this image.
    **********************************************************************/
    // Recursively schedule +load for cls and any un-+load-ed superclasses.
    // cls must already be connected.
    static void schedule_class_load(Class cls)
    {
        if (!cls) return;
        assert(cls->isRealized());  // _read_images should realize
    
        if (cls->data()->flags & RW_LOADED) return;
    
        // 递归调用，找到传进来的类的父类添加到列表中
        // Ensure superclass-first ordering
        schedule_class_load(cls->superclass);
    
        // 然后再调用当前传进来的类添加到列表中，所以父类肯定是在前面
        add_class_to_loadable_list(cls);
        cls->setInfo(RW_LOADED); 
    }

这里面添加的方法`add_class_to_loadable_list`的底层实现如下

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/79367e30fd9e47439a02e031fb6ca30a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    /***********************************************************************
    * add_class_to_loadable_list
    * Class cls has just become connected. Schedule it for +load if
    * it implements a +load method.
    **********************************************************************/
    void add_class_to_loadable_list(Class cls)
    {
        IMP method;
    
        loadMethodLock.assertLocked();
        //取到load方法
        method = cls->getLoadMethod();
        if (!method) return;  // Don't bother if cls has no +load method
        
        if (PrintLoading) {
            _objc_inform("LOAD: class '%s' scheduled for +load", 
                         cls->nameForLogging());
        }
        
        if (loadable_classes_used == loadable_classes_allocated) {
            loadable_classes_allocated = loadable_classes_allocated*2 + 16;
            loadable_classes = (struct loadable_class *)
                realloc(loadable_classes,
                                  loadable_classes_allocated *
                                  sizeof(struct loadable_class));
        }
        
        loadable_classes[loadable_classes_used].cls = cls;
        loadable_classes[loadable_classes_used].method = method;
        loadable_classes_used++;
    }

我们发现这个添加过程实际上就是

*   把`loadable_class`类型的结构体，存储到表待调度load的这张表`loadable_classes`中
*   而存储的结构体`loadable_class`类型包含类名`cls`以及该类的`load`方法`IMP`。
```
 struct loadable_class {
        Class cls;  // may be nil
        IMP method;
    };
```

`cls->getLoadMethod()`方法得到的就是该类的`Load`方法

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9bba0da95f8f4835a1a0bdfc6fd07a0e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    
    /***********************************************************************
    * objc_class::getLoadMethod
    * fixme
    * Called only from add_class_to_loadable_list.
    * Locking: runtimeLock must be read- or write-locked by the caller.
    **********************************************************************/
    IMP objc_class::getLoadMethod()
    {
        runtimeLock.assertLocked();
    
        const method_list_t *mlist;
    
        assert(isRealized());
        assert(ISA()->isRealized());
        assert(!isMetaClass());
        assert(ISA()->isMetaClass());
    
        mlist = ISA()->data()->ro->baseMethods();
        if (mlist) {
            for (const auto& meth : *mlist) {
                const char *name = sel_cname(meth.name);
                if (0 == strcmp(name, "load")) {
                    return meth.imp;
                }
            }
        }
    
        return nil;
    }

*   `schedule_class_load`底层实现原理是：获取父类，然后继续递归调用
*   `schedule_class_load`，然后把这些类按**父类的父类->父类->子类**这个顺序把类和类的load方法添加到`loadable_classes`表中。
*   这也是为什么类的`+(load)`方法执行顺序是**从父类到子类**的。

在调用`schedule_class_load`添加完成类之后，又继续处理分类

*   分类内部调用`_category_getLoadMethod`拿到分类中重写的`load`方法
*   然后也调用`add_category_to_loadable_list`把分类`cat`和分类的`load`方法添加到表`loadable_categories`中。

**所以总结`prepare_load_methods`准备load方法的逻辑就是：**

*   **`先处理类`:**
*   *   递归按照先父类再子类的顺序，把类和类的load方法整合成一个结构体对象`loadable_class`
*   *   然后把这个结构体对象存到表`loadable_classes`中。
*   **`处理完成类之后，再开始处理分类`:**
*   *   获取分类的load方法，把分类和分类的load方法整合成一个结构体对象`loadable_category`
*   *   然后存储到表`loadable_categories`中。

到这里，load方法准备工作完毕。

#### 4.2.2 `call_load_methods`底层实现

接下来进入重点，load方法的调用部分

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a1c20c2cf4ea4b8e83126b9b1620cb34~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    void call_load_methods(void)
    {
        static bool loading = NO;
        bool more_categories;
    
        loadMethodLock.assertLocked();
    
        // Re-entrant calls do nothing; the outermost call will finish the job.
        if (loading) return;
        loading = YES;
    
        void *pool = objc_autoreleasePoolPush();
    
        do {
            // 1. Repeatedly call class +loads until there aren't any more
            while (loadable_classes_used > 0) {
                call_class_loads();
            }
    
            // 2. Call category +loads ONCE
            more_categories = call_category_loads();
    
            // 3. Run more +loads if there are classes OR more untried categories
        } while (loadable_classes_used > 0  ||  more_categories);
    
        objc_autoreleasePoolPop(pool);
    
        loading = NO;
    }

**先观察这个函数实现部分:**

*   我们发现这个do—while循环被包含在`objc_autoreleasePoolPush()`和`objc_autoreleasePoolPop`中
*   苹果使用了autoreleasePool是为了节省内存开销

**然后我们继续来看循环体部分：**

    do {
            //1、while循环调用call_class_loads()方法
            while (loadable_classes_used > 0) {
                call_class_loads();
            }
    
            //2、调用call_category_loads()并返回一个bool布尔值并赋值给more_categories
            more_categories = call_category_loads();
    
        } while (loadable_classes_used > 0  ||  more_categories);

接下来我们继续分析`call_class_loads`和`call_category_loads`底层实现。

#### 4.2.3 `call_class_loads`底层实现

先来看看调用类的load函数`call_class_loads`：

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f6aeb89e4a44dda938ea019b00dbf44~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    static void call_class_loads(void)
    {
        int i;
        
        // Detach current loadable list.
        struct loadable_class *classes = loadable_classes;
        int used = loadable_classes_used;
        loadable_classes = nil;
        loadable_classes_allocated = 0;
        loadable_classes_used = 0;
        
        // Call all +loads for the detached list.
        for (i = 0; i < used; i++) {
            Class cls = classes[i].cls;
            load_method_t load_method = (load_method_t)classes[i].method;
            if (!cls) continue; 
    
            if (PrintLoading) {
                _objc_inform("LOAD: +[%s load]\n", cls->nameForLogging());
            }
            (*load_method)(cls, SEL_load);
        }
        
        // Destroy the detached list.
        if (classes) free(classes);
    }

**简化源码如下:**

    static void call_class_loads(void)
    {
        ......
        
        for (i = 0; i < loadable_classes_used; i++) {
        
            // 取出类里面的load方法
            // load_method_t：指向函数地址的指针
            // 这里的method对应的结构体为loadable_class
            Class cls = loadable_classes[i].cls;
            load_method_t load_method = (load_method_t) loadable_classes[i].method;
    
            ......
            
            // 直接调用load方法
            (*load_method)(cls, SEL_load);
        }
        ......
    }
    
    // 找到的method对应的结构体
    struct loadable_class {
        Class cls;  // may be nil
        IMP method; // 这个就是load方法
    };
    复制代码

这个过程其实就是从之前存储好的表`loadable_classes`中取出**Class**和对应**load**方法的`load_method_t`对象，直接调用。

#### 4.2.4 `call_category_loads`底层实现

然后看看调用分类的load函数`call_category_loads`

    static bool call_category_loads(void)
    {
        int i, shift;
        bool new_categories_added = NO;
        
        // Detach current loadable list.
        struct loadable_category *cats = loadable_categories;
        int used = loadable_categories_used;
        int allocated = loadable_categories_allocated;
        loadable_categories = nil;
        loadable_categories_allocated = 0;
        loadable_categories_used = 0;
    
        // Call all +loads for the detached list.
        for (i = 0; i < used; i++) {
            Category cat = cats[i].cat;
            load_method_t load_method = (load_method_t)cats[i].method;
            Class cls;
            if (!cat) continue;
    
            cls = _category_getClass(cat);
            if (cls  &&  cls->isLoadable()) {
                if (PrintLoading) {
                    _objc_inform("LOAD: +[%s(%s) load]\n", 
                                 cls->nameForLogging(), 
                                 _category_getName(cat));
                }
                (*load_method)(cls, SEL_load);
                cats[i].cat = nil;
            }
        }
    
        // Compact detached list (order-preserving)
        shift = 0;
        for (i = 0; i < used; i++) {
            if (cats[i].cat) {
                cats[i-shift] = cats[i];
            } else {
                shift++;
            }
        }
        used -= shift;
    
        // Copy any new +load candidates from the new list to the detached list.
        new_categories_added = (loadable_categories_used > 0);
        for (i = 0; i < loadable_categories_used; i++) {
            if (used == allocated) {
                allocated = allocated*2 + 16;
                cats = (struct loadable_category *)
                    realloc(cats, allocated *
                                      sizeof(struct loadable_category));
            }
            cats[used++] = loadable_categories[i];
        }
    
        // Destroy the new list.
        if (loadable_categories) free(loadable_categories);
    
        // Reattach the (now augmented) detached list. 
        // But if there's nothing left to load, destroy the list.
        if (used) {
            loadable_categories = cats;
            loadable_categories_used = used;
            loadable_categories_allocated = allocated;
        } else {
            if (cats) free(cats);
            loadable_categories = nil;
            loadable_categories_used = 0;
            loadable_categories_allocated = 0;
        }
    
        if (PrintLoading) {
            if (loadable_categories_used != 0) {
                _objc_inform("LOAD: %d categories still waiting for +load\n",
                             loadable_categories_used);
            }
        }
    
        return new_categories_added;
    }

**简化代码如下:**

    static bool call_category_loads(void)
    {
        int i, shift;
        bool new_categories_added = NO;
        
        // Detach current loadable list.
        struct loadable_category *cats = loadable_categories;
        int used = loadable_categories_used;
        int allocated = loadable_categories_allocated;
        loadable_categories = nil;
        loadable_categories_allocated = 0;
        loadable_categories_used = 0;
    
        // Call all +loads for the detached list.
        for (i = 0; i < used; i++) {
        
            // 取出每一个分类里的load方法
            // 这里的method对应的结构体为loadable_category
            Category cat = cats[i].cat;
            load_method_t load_method = (load_method_t)cats[i].method;
            Class cls;
            if (!cat) continue;
    
            cls = _category_getClass(cat);
            if (cls  &&  cls->isLoadable()) {
            
                ......
                
                // 直接调用load方法
                (*load_method)(cls, SEL_load);
                cats[i].cat = nil;
            }
        }
    
        ......
        
        return new_categories_added;
    }
    
    // 找到的method对应的结构体
    struct loadable_category {
        Category cat;  // may be nil
        IMP method; // 这个方法就是load方法
    }; 
    复制代码

这个过程和类的逻辑基本一致，也是就是从之前存储好的表`loadable_categories`中取出分类**Category**和对应**load**方法的`load_method_t`对象，然后通过`_category_getClass`获取到分类对应的类，然后用类直接调用load方法。

**到此为止，load\_images主要流程也已经分析完毕。load\_images主要做了下面这些步骤：**

**第一步.准备`load`方法:`prepare_load_methods`**

> **将类的处理顺序存储到待调度的表中**
> 
> *   以先处理类，后处理分类
> *   先处理父类，后处理子类
> 
> **类的处理逻辑：**
> 
> *   把类对象`Class`和类对应的load方法的`IMP`整合成一个`loadable_class`类型的结构体对象存储在表`loadable_classes`中。
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
> *   调用完就从表中移除，全部调用完结束循环。

下面是我对`load_images`方法实现逻辑的的流程图：

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a8d2fab8c90f4d17acaad2902798192c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

### 4.3 总结

App装载过程大概可以简化如图 ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b4ff895a730248388b67f86502edb38c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)


### 分类中添加实例变量和属性分别会发生什么，还是什么时候会发生问题？
     添加实例变量编译时直接报错，因为类的内存结构已经确定，无法在分类中添加实例变量了。
     添加属性没问题，但是在运行的时候使用这个属性程序crash。原因是没有实例变量也没有set/get方法
     
### 分类中为什么不能添加成员变量（runtime除外）？
      类对象在创建的时候已经定好了成员变量，但是分类是运行时加载的，无法添加。
      类对象里的 class_ro_t 类型的数据在运行期间不能改变，再添加方法和协议都是修改的 class_rw_t 的数据。
      分类添加方法、协议是把category中的方法，协议放在category_t结构体中，再拷贝到类对象里面。但是category_t里面没有成员变量列表。
      虽然category可以写上属性，其实是通过关联对象实现的，需要手动添加setter & getter。    
      
 ### 分类不能添加属性的实质原因
> 1.我们知道在一个类中用@property声明属性，编译器会自动帮我们生成`_成员变量`和`setter/getter`，但分类的指针结构体中，根本没有`成员变量列表`。所以在分类中用`@property`声明属性，既无法生成`_成员变量`也无法生成`setter/getter`的实现。  
> 2.因此结论是：我们可以用@property声明属性，编译和运行都会通过，只要不使用程序也不会崩溃。但如果调用了`_成员变量`和`setter/getter`方法，报错就在所难免了。

### 因为分类会覆盖本类的同名方法，想要调用本类方法怎么做？
 倒序遍历方法列表，找到相同的方法名就行，因为本类的在方法列表第一个
 
 ```Objective-C
void invokeOriginalMethod(id target , SEL selector) {
    uint count;
    Method *list = class_copyMethodList([target class], &count);
    for ( int i = count - 1 ; i >= 0; i--) {
        Method method = list[i];
        SEL name = method_getName(method);
        IMP imp = method_getImplementation(method);
        if (name == selector) {
            ((void (*)(id, SEL))imp)(target, name);
            break;
        }
    }
    free(list);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        invokeOriginalMethod(person, @selector(run));
    }
    return 0;
}
 ```

 ### 为什么在+(void)load或者+(void)initialize方法中总是要写dispatch_once函数？
 在多线程环境下，+load 和 +initialize 方法会自动调用，但它们的线程安全性有一些细微的差别：

+load 方法是在类加载到内存时自动调用的，通常在应用程序启动时。它是在主线程上同步执行的，因此不需要额外的线程保护机制。只要类被加载到内存中，+load 方法会被调用一次，并且在调用结束之前，不会有其他线程同时调用该方法。（给load方法加dispatch_once是为了防止主动调用load方法，虽然一般不会这么做）

+initialize 方法是在首次使用类时自动调用的，它是在多线程环境下按需异步执行的。虽然每个类只会被调用一次，但由于多线程的特性，多个线程可以同时访问并触发 +initialize 方法。因此，在 +initialize 方法中进行初始化时，需要考虑线程安全性。

### 有没有可能+(void)load方法也被调用多次？如何避免？
有一些特殊情况可能导致 +load 方法被多次调用：

子类和分类的 +load 方法：如果一个类的子类或分类也实现了 +load 方法，那么它们的 +load 方法也会被调用。这意味着在继承关系中，每个类的 +load 方法都会被调用一次，从父类到子类，按照继承关系的顺序。

动态加载的类：在运行时，通过 NSClassFromString 或其他动态加载类的方式，可以将类动态加载到内存中。如果一个类被多次动态加载，那么它的 +load 方法也会被多次调用。

类簇（Class Cluster）：类簇是一种抽象类，它有多个具体的私有子类来提供不同的实现。当使用类簇时，不同的具体子类可能会有各自的 +load 方法，因此在使用不同的子类时，对应的 +load 方法也会被调用。

总之，尽管 +load 方法在正常情况下只会被调用一次，但在特定的情况下，如继承关系、动态加载类和类簇中，可能会导致 +load 方法被多次调用。因此，在编写代码时，应当注意避免在 +load 方法中进行会产生副作用的操作，以保证代码的可靠性和稳定性。

#### +load方法
-   +load方法会在runtime加载类、分类时调用
-   每个类、分类的+load，在程序运行过程中只调用一次
-   `调用顺序`
    -   1.先调用类的+load
        -   按照编译先后顺序调用（先编译，先调用）
        -   调用子类的+load之前会先调用父类的+load

    -   2.再调用分类的+load
        -   按照编译先后顺序调用（先编译，先调用）

-   代码例子及图解佐证
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/426dfee073f0437499afdbc917aa72d1~tplv-k3u1fbpfcp-watermark.image?)

##### objc4源码解读过程：objc-os.mm
-   _objc_init
-   load_images
-   prepare_load_methods
    -   schedule_class_load
    -   add_class_to_loadable_list
    -   add_category_to_loadable_list
-   call_load_methods
    -   call_class_loads
    -   call_category_loads
    -   (*load_method)(cls, SEL_load)
-   `+load方法是根据方法地址直接调用，并不是经过objc_msgSend函数调用`

##### + initialize方法
-   `+initialize方法会在类第一次接收到消息时调用`
-   调用顺序
    -   先调用父类的+initialize，再调用子类的+initialize
    -   (先初始化父类，再初始化子类，每个类只会初始化1次)
##### objc4源码解读过程
-   `objc-msg-arm64.s`
    -   objc_msgSend
-   `objc-runtime-new.mm`
    -   class_getInstanceMethod
    -   lookUpImpOrNil
    -   lookUpImpOrForward
    -   _class_initialize
    -   callInitialize
    -   objc_msgSend(cls, SEL_initialize)

项目例子佐证 -

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b73f7793caf54581bf6a2f4eb8e431be~tplv-k3u1fbpfcp-watermark.image?)
-   `每个类都实现了+ initialize方法`

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/390ae24151834a5e959f665b22bb9c6b~tplv-k3u1fbpfcp-watermark.image?)
-   `先调用父类的+initialize，再调用子类的+initialize`
-   `(先初始化父类，再初始化子类，每个类只会初始化1次)`

> 解析  
> 1.[Student alloc]会调用+initialize方法，因为他有父类Person，所以先调用Person的+initialize方法，又因为分类在前面，所以调用了Person(Test2)的+initialize方法。但是他自己本身没有实现+initialize方法，所以会去父类查找，然后分类方法在前面，所以调用了Person(Test2)的+initialize方法。  

> 2.[Teacher alloc]会调用+initialize方法，因为他有父类Person，所以先调用Person的+initialize方法，但是前面已经初始化过了，所以跳过，调用自己的+initialize方法，但是因为他自己没有实现+initialize方法，所以调用父类的+initialize方法，又因为分类方法在前面，所以调用Person(Test) +initialize方法。 

> 3.[Person alloc]，因为前面已经初始化过了，所以不会再调+initialize方法，所以这里不打印。

##### +initialize和+load的区别
-   +initialize是通过objc_msgSend进行调用的，所以有以下特点
    -   如果子类没有实现+initialize，会调用父类的+initialize（所以父类的+initialize可能会被调用多次）
    -   如果分类实现了+initialize，就覆盖类本身的+initialize调用

### 关联对象
    使用关联对象，需要在主对象 dealloc 的时候手动释放么？
     不需要，主对象通过 dealloc -> object_dispose -> object_remove_assocations 进行关联对象的释放
     
```Objective-C     
#import "MJPerson+Test.h"
#import <objc/runtime.h>

@implementation MJPerson (Test)
/**
 void objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,
                         id _Nullable value, objc_AssociationPolicy policy)
 AssociationsManager = {static AssociationsHashMap map}
 AssociationsHashMap map = [{object : AssociationsMap = {key : Associations = {policy,value}}}]
 */
- (void)setName:(NSString *)name  //key确保唯一就行，_cmd、@selector(name)、static类型的字符串都可以作为key
{
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name
{
    // 隐式参数
    // _cmd == @selector(name)
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWeight:(int)weight
{
    objc_setAssociatedObject(self, @selector(weight), @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)weight
{
    // _cmd == @selector(weight)
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

@end
```
     
### 关联对象的实现和原理:
 关联对象不存储在关联对象本身内存中，而是存储在一个全局容器中，由runtime管理。这个容器是由 AssociationsManager 管理并在它维护的一个单例 Hash 表AssociationsHashMap ；
```
 第一层 AssociationsHashMap：类名object ：bucket（map）
 第二层 ObjectAssociationMap：key（name）：ObjcAssociation（value和policy）
```
 AssociationsManager 使用 AssociationsManagerLock 自旋锁保证了线程安全。

![image.png](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/5/14/1635a628a228e349~tplv-t2oaga2asx-jj-mark:3024:0:0:0:q75.awebp)

### 给关联对象设置key的时候有哪几种方式？
使用静态变量或全局变量作为关联的key：
```
static char associatedObjectKey; //这里没有给associatedObjectKey赋初值，并不是0或者nil，而是操作系统随机分配的内存，不会冲突。
objc_setAssociatedObject(object, &associatedObjectKey, associatedObject, OBJC_ASSOCIATION_RETAIN);
```

使用指向静态变量的指针作为关联的key：
```
static char associatedObjectKey;
static char *associatedObjectKeyPtr = &associatedObjectKey;
objc_setAssociatedObject(object, associatedObjectKeyPtr, associatedObject, OBJC_ASSOCIATION_RETAIN);
```
使用静态的dispatch_once_t变量作为关联的key：
```
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    objc_setAssociatedObject(object, &onceToken, associatedObject, OBJC_ASSOCIATION_RETAIN);
});
```

使用自定义的字符串作为关联的key：
```
static NSString * const associatedObjectKey = @"AssociatedObjectKey";
objc_setAssociatedObject(object, associatedObjectKey, associatedObject, OBJC_ASSOCIATION_RETAIN);
```
需要注意的是，关联的key应该具有全局唯一性，以避免不同的关联冲突。在使用字符串作为关联的key时，最好使用全局唯一的字符串，比如使用类名加上一个特定的后缀。


还可以使用@selector，因为可以确保唯一性，且全局存在不会销毁

关联对象的相关方法有:
```
objc_setAssociatedObject用于关联对象的设置,
objc_getAssociatedObject用于关联对象的获取,
objc_removeAssociatedObjects用于移除关联的对象等。
这些方法可以在<objc/runtime.h>头文件中找到。
```
### 如何销毁关联对象？销毁的时候key也会销毁吗？
在 Objective-C 中，可以使用 objc_setAssociatedObject 方法将关联对象与某个对象进行关联，并可以使用 objc_removeAssociatedObjects 方法来移除该对象的所有关联对象。

当调用 objc_removeAssociatedObjects 方法移除关联对象时，只会移除该对象的关联对象值，而不会销毁关联对象的 key。关联对象的 key 仍然存在，可以再次使用。
```
// 关联对象的 key
static char associatedObjectKey;
// 设置关联对象
objc_setAssociatedObject(object, &associatedObjectKey, associatedObject, OBJC_ASSOCIATION_RETAIN);
// 移除关联对象
objc_removeAssociatedObjects(object);
```
在上述示例中，关联对象的 key 是 associatedObjectKey，我们使用 objc_setAssociatedObject 将 associatedObject 关联到 object 上。然后，我们调用 objc_removeAssociatedObjects 移除 object 的所有关联对象。这将移除关联对象的值，但不会销毁关联对象的 key。

如果您希望完全移除关联对象，并且不再使用相同的 key 进行关联，您可以选择在不需要关联对象时，手动调用 objc_setAssociatedObject 方法，并将关联对象的值设置为 nil，或者使用 objc_setAssociatedObject 方法将 nil 关联到对象上，以覆盖旧的关联对象。
```
objc_setAssociatedObject(object, &associatedObjectKey, nil, OBJC_ASSOCIATION_RETAIN);
```
这样做会将关联对象的值设置为 nil，并且与该对象关联的 key 仍然存在，可以再次使用。
也就是说key还是一直存在，并不会随关联对象的销毁而销毁，除非退出程序。

