# Category底层结构、App启动时Class与Category装载过程、load 和 initialize 执行、关联对象

前言
==

> 之前,我们在探索动画及渲染相关原理的时候,我们输出了几篇文章,解答了`iOS动画是如何渲染,特效是如何工作的疑惑`。我们深感系统设计者在创作这些系统框架的时候,是如此脑洞大开,也 **`深深意识到了解一门技术的底层原理对于从事该方面工作的重要性。`**
> 
> 因此我们决定 **`进一步探究iOS底层原理的任务`** ,本文探索的底层原理围绕“`Category底层结构`、`App启动时Class与Category装载过程`、`load 和 initialize 执行`、`关联对象`”展开

一、概述
====

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
    
        #import <objc/runtime.h> 
        void  objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,id _Nullable value, objc_AssociationPolicy policy) ;

        id _Nullable objc_getAssociatedObject(id _Nonnull object, const void * _Nonnull key); 
    

本文将以KnowWhat的事实基础为前提,达到KnowHow。围绕前面得到的这些结论,探究其底层原理的实现:

*   1.  Category如何给类添加 Instance对象方法、Class对象方法的？
*   2.  Category与原来的Class内部的方法的调用优先级如何实现的？
*   3.  为什么 通过Category可以给 原类 增加属性,但是只会添加 setter方法、getter方法的定义,而 setter方法、getter方法的实现需要 开发者自己完成？
*   4.  通过RuntimeAPI进行 `关联对象`操作,其底层原理是什么？

二、Category的本质
=============

我们首先还是先添加一个类(Car),并未其添加Category(Car+Test.h):

*   分类中添加了 方法:
*   *   instance对象方法:`- (void)runFaster;`
*   *   Class 对象方法:`+ (void)lightLongTime;`
*   分类中实现了 原来类中定义的方法:
*   *   `- (void)run`
*   *   `+ (void)light` **Car类的声明与实现:**

    //
    //  Car.h
    //  分类、扩展
    //
    //  Created by VanZhang on 2022/5/11.
    //
    #import <Foundation/Foundation.h>
    
    NS_ASSUME_NONNULL_BEGIN
    
    @interface Car : NSObject{
    @public
        int _year;
    }
    
    -(void)run;
    +(void)light;
    @end
    
    NS_ASSUME_NONNULL_END
    
    
    //
    //  Car.m
    //  分类、扩展
    //
    //  Created by VanZhang on 2022/5/11.
    //
    
    #import "Car.h"
    
    @implementation Car
    - (void)run{
        NSLog(@"%s",__func__);
    }
    + (void)light{
        NSLog(@"%s",__func__);
    }
    @end
    
    复制代码

**分类(`Car+Test`)的声明与实现:**

    //
    //  Car+Test.h
    //  分类、扩展
    //
    //  Created by VanZhang on 2022/5/11.
    //
    
    
    #import "Car.h"
      
    @interface Car (Test)
    - (void)runFaster;
    + (void)lightLongTime;
    @end
     
    
    //
    //  Car+Test.m
    //  分类、扩展
    //
    //  Created by VanZhang on 2022/5/11.
    //
    
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
    复制代码

我们通过Clang指令对 两个.m文件进行转换,得到其底层实现的 `伪代码`(可参考的底层实现逻辑、因为OC是一个具备动态运行时特性的语言,部分细节还得到动态运行时才知道其真正的实现)

    clang -rewrite-objc 源码实现文件名.m
    复制代码

**Car类的底层实现:** ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/057dbac41cc94e1daf22293988b9b890~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0bd83e8e62f048939dbd0575be7dcb64~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 关于 如 Car类 等 基类NSObject的子类 的底层实现 我们之前已经探索过了相关的话题,感兴趣,可以结合这几篇文章进行了解:

> *   **[OC的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")**
> *   **[OC对象的本质【底层实现、内存布局、继承关系】](https://juejin.cn/post/7094503681684406302 "https://juejin.cn/post/7094503681684406302")**
> *   **[几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012")**

1.Category的底层实现
---------------

**分类(Category)的底层实现(当前示例分类为`Car+Test`):**

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c69e3d4ff25d449982264c59e1d1bce0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/81a6014e76524a71b4af742b3243904c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

仔细查看代码:

    static struct /*_method_list_t*/ {
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[2];
    } _OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        2,
        {{(struct objc_selector *)"run", "v16@0:8", (void *)_I_Car_Test_run},
        {(struct objc_selector *)"runFaster", "v16@0:8", (void *)_I_Car_Test_runFaster}}
    };
    
    static struct /*_method_list_t*/ {
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[2];
    } _OBJC_$_CATEGORY_CLASS_METHODS_Car_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        2,
        {{(struct objc_selector *)"light", "v16@0:8", (void *)_C_Car_Test_light},
        {(struct objc_selector *)"lightLongTime", "v16@0:8", (void *)_C_Car_Test_lightLongTime}}
    }; 
    
     // 变量名对应着分类文件名 
    static struct _category_t _OBJC_$_CATEGORY_Car_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = 
    {
        "Car",
        0, // &OBJC_CLASS_$_Car,
        (const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Test,  // instance对象方法
        (const struct _method_list_t *)&_OBJC_$_CATEGORY_CLASS_METHODS_Car_$_Test, //Class方法
        0,
        0,
    };
    复制代码

从底层代码中我们发现结构体:

*   `_category_t _OBJC_$_CATEGORY_Car_$_Test`
*   `_OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Test`
*   `_OBJC_$_CATEGORY_CLASS_METHODS_Car_$_Test`
*   根据结构体的名称 以及具体实现,我们可以 清晰得知:
*   *   `_category_t _OBJC_$_CATEGORY_Car_$_Test` 对应 分类文件是`Person+Test`，并且里面记录着所有的分类信息:
*   *   `_OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Test` 对应 `struct _category_t`中的 `const struct _method_list_t *instance_methods;` //Instance对象方法
*   *   `_OBJC_$_CATEGORY_CLASS_METHODS_Car_$_Test 对应` `struct _category_t` 中的 `const struct _method_list_t *class_methods;` // 类方法

    struct _category_t {
        const char *name;
        struct _class_t *cls;
        const struct _method_list_t *instance_methods; // Instance对象方法
        const struct _method_list_t *class_methods;// 类方法
        const struct _protocol_list_t *protocols;// 协议
        const struct _prop_list_t *properties; // 属性
    };
    复制代码

上下几张图一一对应，并且我们看到:

*   定义了`_class_t`类型的`OBJC_CLASS_$_Car`结构体
*   最后将`_OBJC_$_CATEGORY_Car_$_Test`的`cls`指针指向`OBJC_CLASS_$_Car`结构体地址
*   我们这里可以看出，`cls`指针指向的 应该是 分类的 主类 类对象 的地址。 ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/601acdc344f24f6f8f9ee7445f7b6a22~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/99323593f0e14aff979aa5d7c01b0262~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) 并且,在了解[Class的底层本质](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012")的时候,我们得知,主类的核心信息是存放在结构体`_class_ro_t`中的![](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cca4b5a9b1c44e5abf4f0d830fc114c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

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
    复制代码

与我们通过clang命令转出来的底层实现高度相似:

    struct _category_t {
        const char *name;//类名
        struct _class_t *cls;//主类指针
        const struct _method_list_t *instance_methods; // 对象方法
        const struct _method_list_t *class_methods;// 类方法
        const struct _protocol_list_t *protocols;// 协议
        const struct _prop_list_t *properties; // 属性
    };
    复制代码

2.Category的加载处理过程
-----------------

前面我们通过模糊搜索,在`objc-rumtime-new.mm`找到`category_t`的实现,紧接着我们继续在`objc-rumtime-new.mm`文件尝试查找与 category 相关的 底层实现,我们找到了相关的几个函数: ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f9184f69b3ab427ea6ee94af88c01b99~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/039f536827f14b248296580b9e4b8269~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/67cf8a38b3964f10851edf7def99a87d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    
    
    /***********************************************************************
    * unattachedCategories
    * Returns the class => categories map of unattached categories.
    * Locking: runtimeLock must be held by the caller.
    **********************************************************************/
    static NXMapTable *unattachedCategories(void)
    {
        runtimeLock.assertWriting();
    
        static NXMapTable *category_map = nil;
    
        if (category_map) return category_map;
    
        // fixme initial map size
        category_map = NXCreateMapTable(NXPtrValueMapPrototype, 16);
    
        return category_map;
    }
    
    
    /***********************************************************************
    * addUnattachedCategoryForClass
    * Records an unattached category.
    * Locking: runtimeLock must be held by the caller.
    **********************************************************************/
    static void addUnattachedCategoryForClass(category_t *cat, Class cls, 
                                              header_info *catHeader)
    {
        runtimeLock.assertWriting();
    
        // DO NOT use cat->cls! cls may be cat->cls->isa instead
        NXMapTable *cats = unattachedCategories();
        category_list *list;
    
        list = (category_list *)NXMapGet(cats, cls);
        if (!list) {
            list = (category_list *)
                calloc(sizeof(*list) + sizeof(list->list[0]), 1);
        } else {
            list = (category_list *)
                realloc(list, sizeof(*list) + sizeof(list->list[0]) * (list->count + 1));
        }
        list->list[list->count++] = (locstamped_category_t){cat, catHeader};
        NXMapInsert(cats, cls, list);
    }
    
    
    /***********************************************************************
    * removeUnattachedCategoryForClass
    * Removes an unattached category.
    * Locking: runtimeLock must be held by the caller.
    **********************************************************************/
    static void removeUnattachedCategoryForClass(category_t *cat, Class cls)
    {
        runtimeLock.assertWriting();
    
        // DO NOT use cat->cls! cls may be cat->cls->isa instead
        NXMapTable *cats = unattachedCategories();
        category_list *list;
    
        list = (category_list *)NXMapGet(cats, cls);
        if (!list) return;
    
        uint32_t i;
        for (i = 0; i < list->count; i++) {
            if (list->list[i].cat == cat) {
                // shift entries to preserve list order
                memmove(&list->list[i], &list->list[i+1], 
                        (list->count-i-1) * sizeof(list->list[i]));
                list->count--;
                return;
            }
        }
    }
    
    
    /***********************************************************************
    * unattachedCategoriesForClass
    * Returns the list of unattached categories for a class, and 
    * deletes them from the list. 
    * The result must be freed by the caller. 
    * Locking: runtimeLock must be held by the caller.
    **********************************************************************/
    static category_list *
    unattachedCategoriesForClass(Class cls, bool realizing)
    {
        runtimeLock.assertWriting();
        return (category_list *)NXMapRemove(unattachedCategories(), cls);
    }
    
    
    /***********************************************************************
    * removeAllUnattachedCategoriesForClass
    * Deletes all unattached categories (loaded or not) for a class.
    * Locking: runtimeLock must be held by the caller.
    **********************************************************************/
    static void removeAllUnattachedCategoriesForClass(Class cls)
    {
        runtimeLock.assertWriting();
    
        void *list = NXMapRemove(unattachedCategories(), cls);
        if (list) free(list);
    }
    
    // Attach method lists and properties and protocols from categories to a class.
    // Assumes the categories in cats are all loaded and sorted by load order, 
    // oldest categories first.
    static void 
    attachCategories(Class cls, category_list *cats, bool flush_caches)
    {
        if (!cats) return;
        if (PrintReplacedMethods) printReplacements(cls, cats);
    
        bool isMeta = cls->isMetaClass();
    
        // fixme rearrange to remove these intermediate allocations
        method_list_t **mlists = (method_list_t **)
            malloc(cats->count * sizeof(*mlists));
        property_list_t **proplists = (property_list_t **)
            malloc(cats->count * sizeof(*proplists));
        protocol_list_t **protolists = (protocol_list_t **)
            malloc(cats->count * sizeof(*protolists));
    
        // Count backwards through cats to get newest categories first
        int mcount = 0;
        int propcount = 0;
        int protocount = 0;
        int i = cats->count;
        bool fromBundle = NO;
        while (i--) {
            auto& entry = cats->list[i];
    
            method_list_t *mlist = entry.cat->methodsForMeta(isMeta);
            if (mlist) {
                mlists[mcount++] = mlist;
                fromBundle |= entry.hi->isBundle();
            }
    
            property_list_t *proplist = 
                entry.cat->propertiesForMeta(isMeta, entry.hi);
            if (proplist) {
                proplists[propcount++] = proplist;
            }
    
            protocol_list_t *protolist = entry.cat->protocols;
            if (protolist) {
                protolists[protocount++] = protolist;
            }
        }
    
        auto rw = cls->data();
    
        prepareMethodLists(cls, mlists, mcount, NO, fromBundle);
        rw->methods.attachLists(mlists, mcount);
        free(mlists);
        if (flush_caches  &&  mcount > 0) flushCaches(cls);
    
        rw->properties.attachLists(proplists, propcount);
        free(proplists);
    
        rw->protocols.attachLists(protolists, protocount);
        free(protolists);
    }
    
    复制代码

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

    // memmove ：内存移动。
    /*  __dst : 移动内存的目的地
    *   __src : 被移动的内存首地址
    *   __len : 被移动的内存长度
    *   将__src的内存移动__len块内存到__dst中
    */
    void	*memmove(void *__dst, const void *__src, size_t __len);
    
    // memcpy ：内存拷贝。
    /*  __dst : 拷贝内存的拷贝目的地
    *   __src : 被拷贝的内存首地址
    *   __n : 被移动的内存长度
    *   将__src的内存拷贝__n块内存到__dst中
    */
    void	*memcpy(void *__dst, const void *__src, size_t __n);
     
    复制代码

下面我们图示经过memmove和memcpy方法过后的内存变化。

![未经过内存移动和拷贝时](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fd536998ff764aee8c7433b45a3ccd07~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

经过memmove方法之后，内存变化为

    // array()->lists 原来方法、属性、协议列表数组
    // addedCount 分类数组长度
    // oldCount * sizeof(array()->lists[0]) 原来数组占据的空间
    memmove(array()->lists + addedCount, array()->lists, 
                      oldCount * sizeof(array()->lists[0]));
     
    复制代码

![memmove方法之后内存变化](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/21aa3df305bc4a14bcc013c8c857c822~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

经过memmove方法之后，我们发现，虽然本类的方法，属性，协议列表会分别后移，但是本类的对应数组的指针依然指向原始位置。

memcpy方法之后，内存变化

    // array()->lists 原来方法、属性、协议列表数组
    // addedLists 分类方法、属性、协议列表数组
    // addedCount * sizeof(array()->lists[0]) 原来数组占据的空间
    memcpy(array()->lists, addedLists, 
                   addedCount * sizeof(array()->lists[0]));
     
    复制代码

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
    复制代码

我们在`_dyld_objc_notify_register(&map_images, load_images, unmap_image);`这段代码中发现了装载的过程: -`&map_images`:读取模块(images这里代表模块）

*   `load_images`:装载模块
*   `unmap_image`:结束读取模块

### 4.1 map\_images 读取模块过程

**a.我们进入到 `map_images`函数:** ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f5036fccde57492fab406ef0900d9c0e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 4.1.1 `map_images_nolock`函数

**b.我们继续进入`map_images_nolock`函数:**

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
    复制代码

#### 4.1.2 `_read_images`函数

来到`map_images_nolock函数`中找到`_read_images函数`

        if (hCount > 0) {
            _read_images(hList, hCount, totalClasses, unoptimizedTotalClasses);
        }
    复制代码

**从`map_images_nolock函数` 到`_read_images函数` 的过程,即完成 动态库的装载准备,进入runtime的过程**  
在`_read_images函数中`我们找到分类相关代码: ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bea709e4112842bc80591b218d1ac2d7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    /***********************************************************************
    * _read_images
    * Perform initial processing of the headers in the linked 
    * list beginning with headerList. 
    *
    * Called by: map_images_nolock
    *
    * Locking: runtimeLock acquired by map_images
    **********************************************************************/
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
    复制代码

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
    复制代码

我们找到关键代码

*   1.  `prepare_load_methods` 准备load方法
*   2.  `call_load_methods` 调用load方法

#### 4.2.1 prepare\_load\_methods底层实现

贴上`prepare_load_methods`源码 ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a408d45953464524a8cde0e3197e89f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

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
    复制代码

进入`schedule_class_load`，这个函数底层如下

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
    复制代码

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
     
    复制代码

我们发现这个添加过程实际上就是

*   把`loadable_class`类型的结构体，存储到表待调度load的这张表`loadable_classes`中
*   而存储的结构体`loadable_class`类型包含类名`cls`以及该类的`load`方法`IMP`。

    struct loadable_class {
        Class cls;  // may be nil
        IMP method;
    };
    复制代码

`cls->getLoadMethod()`方法得到的就是该类的`Load`方法

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9bba0da95f8f4835a1a0bdfc6fd07a0e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    
    /***********************************************************************
    * objc_class::getLoadMethod
    * fixme
    * Called only from add_class_to_loadable_list.
    * Locking: runtimeLock must be read- or write-locked by the caller.
    **********************************************************************/
    IMP 
    objc_class::getLoadMethod()
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
    复制代码

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

    
    /***********************************************************************
    * call_load_methods
    * Call all pending class and category +load methods.
    * Class +load methods are called superclass-first. 
    * Category +load methods are not called until after the parent class's +load.
    * 
    * This method must be RE-ENTRANT, because a +load could trigger 
    * more image mapping. In addition, the superclass-first ordering 
    * must be preserved in the face of re-entrant calls. Therefore, 
    * only the OUTERMOST call of this function will do anything, and 
    * that call will handle all loadable classes, even those generated 
    * while it was running.
    *
    * The sequence below preserves +load ordering in the face of 
    * image loading during a +load, and make sure that no 
    * +load method is forgotten because it was added during 
    * a +load call.
    * Sequence:
    * 1. Repeatedly call class +loads until there aren't any more
    * 2. Call category +loads ONCE.
    * 3. Run more +loads if:
    *    (a) there are more classes to load, OR
    *    (b) there are some potential category +loads that have 
    *        still never been attempted.
    * Category +loads are only run once to ensure "parent class first" 
    * ordering, even if a category +load triggers a new loadable class 
    * and a new loadable category attached to that class. 
    *
    * Locking: loadMethodLock must be held by the caller 
    *   All other locks must not be held.
    **********************************************************************/
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
    复制代码

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
    复制代码

接下来我们继续分析`call_class_loads`和`call_category_loads`底层实现。

#### 4.2.3 `call_class_loads`底层实现

先来看看调用类的load函数`call_class_loads`：

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f6aeb89e4a44dda938ea019b00dbf44~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    
    /***********************************************************************
    * call_class_loads
    * Call all pending class +load methods.
    * If new classes become loadable, +load is NOT called for them.
    *
    * Called only by call_load_methods().
    **********************************************************************/
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
    复制代码

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

    /***********************************************************************
    * call_category_loads
    * Call some pending category +load methods.
    * The parent class of the +load-implementing categories has all of 
    *   its categories attached, in case some are lazily waiting for +initalize.
    * Don't call +load unless the parent class is connected.
    * If new categories become loadable, +load is NOT called, and they 
    *   are added to the end of the loadable list, and we return TRUE.
    * Return FALSE if no new categories became loadable.
    *
    * Called only by call_load_methods().
    **********************************************************************/
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
    复制代码

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

四、 load 和 initialize
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

五、关联对象
======

我们在[关联对象](https://juejin.cn/post/7096359857221009444#heading-0 "https://juejin.cn/post/7096359857221009444#heading-0") 文章中,曾简单回顾 通过 runtimeAPI 进行 关联对象,实现 分类添加属性时候 的setter、getter方法的实现.  
**Demo如下:**  
我们先编写Car分类,给其添加属性

    //
    //  Car+Category1.h
    //  关联对象、Protocol
    //
    //  Created by VanZhang on 2022/5/11.
    //
    
    
    #import "Car.h"
    
    NS_ASSUME_NONNULL_BEGIN
    
    @interface Car (Category1)
    
    - (void)runFaster;
    + (void)lightLongTime;
    //Desc:
    @property (strong, nonatomic) NSString *nameplate;//车子的铭牌
    @property (assign, nonatomic) int km;//车子的公里数
    @end
    
    NS_ASSUME_NONNULL_END
    
    
    //
    //  Car+Category1.m
    //  关联对象、Protocol
    //
    //  Created by VanZhang on 2022/5/11.
    //
    
    #import "Car+Category1.h"
    #import <objc/runtime.h>
    @implementation Car (Category1)
    - (void)runFaster{
        NSLog(@"%s",__func__);
    }
    + (void)lightLongTime{
        NSLog(@"%s",__func__);
    }
    @end
    
    复制代码

5.1 关联对象API
-----------

导入

*   #import <objc/runtime.h>
*   *   objc\_setAssociatedObject
*   *   objc\_getAssociatedObject

5.2 通过Clang指令转换源码为底层格式
----------------------

**关键代码:**

    struct _prop_t {
        const char *name;
        const char *attributes;
    };
    
    struct _protocol_t;
    
    struct _objc_method {
        struct objc_selector * _cmd;
        const char *method_type;
        void  *_imp;
    };
    
    struct _protocol_t {
        void * isa;  // NULL
        const char *protocol_name;
        const struct _protocol_list_t * protocol_list; // super protocols
        const struct method_list_t *instance_methods;
        const struct method_list_t *class_methods;
        const struct method_list_t *optionalInstanceMethods;
        const struct method_list_t *optionalClassMethods;
        const struct _prop_list_t * properties;
        const unsigned int size;  // sizeof(struct _protocol_t)
        const unsigned int flags;  // = 0
        const char ** extendedMethodTypes;
    };
    
    struct _ivar_t {
        unsigned long int *offset;  // pointer to ivar offset location
        const char *name;
        const char *type;
        unsigned int alignment;
        unsigned int  size;
    };
    
    struct _class_ro_t {
        unsigned int flags;
        unsigned int instanceStart;
        unsigned int instanceSize;
        unsigned int reserved;
        const unsigned char *ivarLayout;
        const char *name;
        const struct _method_list_t *baseMethods;
        const struct _objc_protocol_list *baseProtocols;
        const struct _ivar_list_t *ivars;
        const unsigned char *weakIvarLayout;
        const struct _prop_list_t *properties;
    };
    
    struct _class_t {
        struct _class_t *isa;
        struct _class_t *superclass;
        void *cache;
        void *vtable;
        struct _class_ro_t *ro;
    };
    
    struct _category_t {
        const char *name;
        struct _class_t *cls;
        const struct _method_list_t *instance_methods;
        const struct _method_list_t *class_methods;
        const struct _protocol_list_t *protocols;
        const struct _prop_list_t *properties;
    };
    extern "C" __declspec(dllimport) struct objc_cache _objc_empty_cache;
    #pragma warning(disable:4273)
    
    static struct /*_method_list_t*/ {
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[1];
    } _OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Category1 __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        1,
        {{(struct objc_selector *)"runFaster", "v16@0:8", (void *)_I_Car_Category1_runFaster}}
    };
    
    static struct /*_method_list_t*/ {
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[1];
    } _OBJC_$_CATEGORY_CLASS_METHODS_Car_$_Category1 __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        1,
        {{(struct objc_selector *)"lightLongTime", "v16@0:8", (void *)_C_Car_Category1_lightLongTime}}
    };
    
    static struct /*_prop_list_t*/ {
        unsigned int entsize;  // sizeof(struct _prop_t)
        unsigned int count_of_properties;
        struct _prop_t prop_list[2];
    } _OBJC_$_PROP_LIST_Car_$_Category1 __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_prop_t),
        2,
        {{"nameplate","T@\"NSString\",&,N"},
        {"km","Ti,N"}}
    };
    
    extern "C" __declspec(dllimport) struct _class_t OBJC_CLASS_$_Car;
    
    static struct _category_t _OBJC_$_CATEGORY_Car_$_Category1 __attribute__ ((used, section ("__DATA,__objc_const"))) = 
    {
        "Car",
        0, // &OBJC_CLASS_$_Car,
        (const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Category1,
        (const struct _method_list_t *)&_OBJC_$_CATEGORY_CLASS_METHODS_Car_$_Category1,
        0,
        (const struct _prop_list_t *)&_OBJC_$_PROP_LIST_Car_$_Category1,
    };
    static void OBJC_CATEGORY_SETUP_$_Car_$_Category1(void ) {
        _OBJC_$_CATEGORY_Car_$_Category1.cls = &OBJC_CLASS_$_Car;
    }
    #pragma section(".objc_inithooks$B", long, read, write)
    __declspec(allocate(".objc_inithooks$B")) static void *OBJC_CATEGORY_SETUP[] = {
        (void *)&OBJC_CATEGORY_SETUP_$_Car_$_Category1,
    };
    static struct _category_t *L_OBJC_LABEL_CATEGORY_$ [1] __attribute__((used, section ("__DATA, __objc_catlist,regular,no_dead_strip")))= {
        &_OBJC_$_CATEGORY_Car_$_Category1,
    };
    static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
    复制代码

我们可以在 `_OBJC_$_PROP_LIST_Car_$_Category1`中发现,两个新的属性:`nameplate`、`km`  
从我们前面几篇文章对Class底层结构的实现我们可以轻易得知:

*   属性的信息存在 `_prop_list_t`结构体中
*   类的属性信息 存在 `_class_ro_t`结构体中
    
        struct _class_ro_t {
            unsigned int flags;
            unsigned int instanceStart;
            unsigned int instanceSize;
            unsigned int reserved;
            const unsigned char *ivarLayout;
            const char *name;
            const struct _method_list_t *baseMethods;
            const struct _objc_protocol_list *baseProtocols;
            const struct _ivar_list_t *ivars;
            const unsigned char *weakIvarLayout;
            const struct _prop_list_t *properties;
        };
        
        复制代码
    
*   我们在前面的转成底层代码之后的实现中并没有找到 属性的 `setter`、`getter` 方法(这也就是为什么,我们通过分类定义属性后,直接通过调用其Setter、getter方法 会发生闪退的根本原因(底层不支持默认给其进行属性实现))
*   *   因为类在定义的时候,其内存布局就已经确认了(Class结构体的内存布局)
*   *   若是 系统设计者 允许 在 分类添加属性的时候,允许其改Class的内存布局,那是相当危险的事情(破解程序,干掉一些关键成员属性就会造成某些服务的权限被破解)
*   *   通过 关联对象 的方式,存储起来的 通过分类创建的 属性值 ，不是存储在 类本身的 实例对象内存中

**我们 通过关联对象的方式 完成 其 setter、getter方法的实现:**

    //
    //  Car+Category1.m
    //  关联对象、Protocol
    //
    //  Created by VanZhang on 2022/5/11.
    //
    
    #import "Car+Category1.h"
    #import <objc/runtime.h>
    @implementation Car (Category1)
    - (void)runFaster{
        NSLog(@"%s",__func__);
    }
    + (void)lightLongTime{
        NSLog(@"%s",__func__);
    }
    - (void)setNameplate:(NSString *)nameplate{
        /*
         * object：关联的对象
         * value：关联的值
         * objc_AssociationPolicy：关联策略
         */
        objc_setAssociatedObject(self, @selector(nameplate), nameplate, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    - (NSString *)nameplate{
        
        // 隐式参数
        // _cmd == @selector(name)
        return objc_getAssociatedObject(self, _cmd);
    }
    - (void)setKm:(int)km{
        /*
         * object：关联的对象
         * value：关联的值
         * objc_AssociationPolicy：关联策略
         */
        objc_setAssociatedObject(self, @selector(km), @(km), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    - (int)km{
        return [objc_getAssociatedObject(self, _cmd) intValue];
    }
    @end
    
    复制代码

**转换成底层实现代码:**

    ...
    struct _prop_t {
        const char *name;
        const char *attributes;
    };
    
    struct _protocol_t;
    
    struct _objc_method {
        struct objc_selector * _cmd;
        const char *method_type;
        void  *_imp;
    };
    
    struct _protocol_t {
        void * isa;  // NULL
        const char *protocol_name;
        const struct _protocol_list_t * protocol_list; // super protocols
        const struct method_list_t *instance_methods;
        const struct method_list_t *class_methods;
        const struct method_list_t *optionalInstanceMethods;
        const struct method_list_t *optionalClassMethods;
        const struct _prop_list_t * properties;
        const unsigned int size;  // sizeof(struct _protocol_t)
        const unsigned int flags;  // = 0
        const char ** extendedMethodTypes;
    };
    
    struct _ivar_t {
        unsigned long int *offset;  // pointer to ivar offset location
        const char *name;
        const char *type;
        unsigned int alignment;
        unsigned int  size;
    };
    
    struct _class_ro_t {
        unsigned int flags;
        unsigned int instanceStart;
        unsigned int instanceSize;
        unsigned int reserved;
        const unsigned char *ivarLayout;
        const char *name;
        const struct _method_list_t *baseMethods;
        const struct _objc_protocol_list *baseProtocols;
        const struct _ivar_list_t *ivars;
        const unsigned char *weakIvarLayout;
        const struct _prop_list_t *properties;
    };
    
    struct _class_t {
        struct _class_t *isa;
        struct _class_t *superclass;
        void *cache;
        void *vtable;
        struct _class_ro_t *ro;
    };
    
    struct _category_t {
        const char *name;
        struct _class_t *cls;
        const struct _method_list_t *instance_methods;
        const struct _method_list_t *class_methods;
        const struct _protocol_list_t *protocols;
        const struct _prop_list_t *properties;
    };
    extern "C" __declspec(dllimport) struct objc_cache _objc_empty_cache;
    #pragma warning(disable:4273)
    
    static struct /*_method_list_t*/ {
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[5];
    } _OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Category1 __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        5,
        {{(struct objc_selector *)"runFaster", "v16@0:8", (void *)_I_Car_Category1_runFaster},
        {(struct objc_selector *)"setNameplate:", "v24@0:8@16", (void *)_I_Car_Category1_setNameplate_},
        {(struct objc_selector *)"nameplate", "@16@0:8", (void *)_I_Car_Category1_nameplate},
        {(struct objc_selector *)"setKm:", "v20@0:8i16", (void *)_I_Car_Category1_setKm_},
        {(struct objc_selector *)"km", "i16@0:8", (void *)_I_Car_Category1_km}}
    };
    
    static struct /*_method_list_t*/ {
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[1];
    } _OBJC_$_CATEGORY_CLASS_METHODS_Car_$_Category1 __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        1,
        {{(struct objc_selector *)"lightLongTime", "v16@0:8", (void *)_C_Car_Category1_lightLongTime}}
    };
    
    static struct /*_prop_list_t*/ {
        unsigned int entsize;  // sizeof(struct _prop_t)
        unsigned int count_of_properties;
        struct _prop_t prop_list[2];
    } _OBJC_$_PROP_LIST_Car_$_Category1 __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_prop_t),
        2,
        {{"nameplate","T@\"NSString\",&,N"},
        {"km","Ti,N"}}
    };
    
    extern "C" __declspec(dllimport) struct _class_t OBJC_CLASS_$_Car;
    
    static struct _category_t _OBJC_$_CATEGORY_Car_$_Category1 __attribute__ ((used, section ("__DATA,__objc_const"))) = 
    {
        "Car",
        0, // &OBJC_CLASS_$_Car,
        (const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Category1,
        (const struct _method_list_t *)&_OBJC_$_CATEGORY_CLASS_METHODS_Car_$_Category1,
        0,
        (const struct _prop_list_t *)&_OBJC_$_PROP_LIST_Car_$_Category1,
    };
    static void OBJC_CATEGORY_SETUP_$_Car_$_Category1(void ) {
        _OBJC_$_CATEGORY_Car_$_Category1.cls = &OBJC_CLASS_$_Car;
    }
    #pragma section(".objc_inithooks$B", long, read, write)
    __declspec(allocate(".objc_inithooks$B")) static void *OBJC_CATEGORY_SETUP[] = {
        (void *)&OBJC_CATEGORY_SETUP_$_Car_$_Category1,
    };
    static struct _category_t *L_OBJC_LABEL_CATEGORY_$ [1] __attribute__((used, section ("__DATA, __objc_catlist,regular,no_dead_strip")))= {
        &_OBJC_$_CATEGORY_Car_$_Category1,
    };
    static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
    ...
    复制代码

我们可以在结构体`_OBJC_$_CATEGORY_INSTANCE_METHODS_Car_$_Category1`发现,添加属性的setter、getter方法、此时在外部调用 setter、getter方法就不会闪退了！！

5.3 实现源码分析
----------

1.在`objc-references.mm`中我们可以看到`objc_setAssociatedObject`的实现代码如下

    void _object_set_associative_reference(id object, const void *key, id value, uintptr_t policy) {
        if (!object && !value) return;
    
        if (object->getIsa()->forbidsAssociatedObjects())
            _objc_fatal("objc_setAssociatedObject called on instance (%p) of class %s which does not allow associated objects", object, object_getClassName(object));
        
        // 通过传进来的object生成一个key
        DisguisedPtr<objc_object> disguised{(objc_object *)object};
        ObjcAssociation association{policy, value};
    
        // retain the new value (if any) outside the lock.
        association.acquireValue();
    
        bool isFirstAssociation = false;
        {
            AssociationsManager manager;
            // 取出AssociationsManager里的AssociationsHashMap这个属性
            AssociationsHashMap &associations(manager.get());
    
            // 如果value有值
            if (value) {
                // 根据传进来的object key的值disguised取出ObjectAssociationMap
                auto refs_result = associations.try_emplace(disguised, ObjectAssociationMap{});
                if (refs_result.second) {
                    /* it's the first association we make */
                    isFirstAssociation = true;
                }
    
                // 根据refs_result的key存放进association
                // association就是ObjcAssociation
                // 总之就是对应的每一个key一层层的赋值
                auto &refs = refs_result.first->second;
                auto result = refs.try_emplace(key, std::move(association));
                if (!result.second) {
                    association.swap(result.first->second);
                }
            } else { // 如果value为空
                auto refs_it = associations.find(disguised);
                if (refs_it != associations.end()) {
                    auto &refs = refs_it->second;
                    auto it = refs.find(key);
                    if (it != refs.end()) {
                        association.swap(it->second);
                        refs.erase(it);
                        if (refs.size() == 0) {
                            // 也会找到associations进行擦除
                            associations.erase(refs_it);
    
                        }
                    }
                }
            }
        }
    
    	....
    }
    
    复制代码

2.关联对象的取值函数`objc_getAssociatedObject`的实现代码如下

    void _object_get_associative_reference(id object, const void *key) {
        ObjcAssociation association{};
    
        {
            AssociationsManager manager;
            
            // associations是manager里面所有的AssociationsHashMap的list
            AssociationsHashMap &associations(manager.get());
            // 根据object在list里找到对应的那个AssociationsHashMap类型的i
            AssociationsHashMap::iterator i = associations.find((objc_object *)object);
            if (i != associations.end()) {
                
                // 再取出所有的ObjectAssociationMap的list
                ObjectAssociationMap &refs = i->second;
                // 根据key在list里找到对应的ObjectAssociationMap类型的j
                ObjectAssociationMap::iterator j = refs.find(key);
                if (j != refs.end()) {
                    // 取出ObjectAssociation类型的值association
                    association = j->second;
                    // 取出association里的value和策略
                    association.retainReturnedValue();
                }
            }
        }
    
        return association.autoreleaseReturnedValue();
    }
    
    复制代码

3.关联对象的几个类的实现关系可以用下图表示

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/00389be4c4034ca0afcfc5fcaaebd54a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

5.4 总结：
-------

*   关联对象并不是存储在被关联对象本身内存中
*   关联对象存储在全局的统一的一个`AssociationsManager`中
*   设置关联对象为`nil`，就相当于是移除关联对象
*   当`object`对象被释放，关联对象的值也会对应的从内存中移除（内存管理自动做了处理） 其它: 关联对象提供了以下API

    // 添加关联对象
     void objc_setAssociatedObject(id object, const void * key, id value, objc_AssociationPolicy policy)
    // 获得关联对象
    
    id objc_getAssociatedObject(id object, const void * key)
    //移除所有的关联对象
    void objc_removeAssociatedObjects(id object)
    复制代码

key的常见用法

    static void *MyKey = &MyKey;
    objc_setAssociatedObject(obj, MyKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    objc_getAssociatedObject(obj, MyKey)
    
    static char MyKey;
    objc_setAssociatedObject(obj, &MyKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    objc_getAssociatedObject(obj, &MyKey)
    
    //使用属性名作为key
    objc_setAssociatedObject(obj, @"property", value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_getAssociatedObject(obj, @"property");
    
    //使用get方法的@selecor作为key
    objc_setAssociatedObject(obj, @selector(getter), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    objc_getAssociatedObject(obj, @selector(getter))
    复制代码

objc\_AssociationPolicy

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d38379d734434efe9d41f403c926a158~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3c3b56d48dcf489e91cd6b76013cb145~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

总结
==

本文整个篇幅 介绍了 OC面向对象语法中的 `Category底层结构`、`Category中添加属性的策略关联对象的底层实现`、`类与分类中load 和 initialize 执行顺序和相关原理`、`App启动时Class与Category装载过程` 且验证了阅读源码的理解推断。本文只对课题相关的底层代码进行阅读或验证,并没有铺展开来介绍。本文就此收尾,其它底层原理相关的要点,待下回分晓

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