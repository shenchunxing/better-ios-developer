应用程序的崩溃总是最让人头疼的问题。日常开发阶段的崩溃，发现后还能够立即处理，但是上线后出现的崩溃，就需要紧急修复bug了并且还需要发版，也是非常严重的研发事故，那么如何降低程序的崩溃率呢？这里就用到了`APP运行时Crash自动捕获和处理`，使APP能够持续稳定正常的运行。

常见的Crash有哪些？
------------

*   Container Crash(集合类操作造成的崩溃，例如数组越界、插入nil)
*   NSString Crash(字符串类操作造成的崩溃)
*   找不到对象方法或者类方法
*   KVO和KVC Crash
*   NSNOtification Crash
*   NSTimer Crash
*   Bad Access Crash(野指针)
*   Threading Crash(非主线程刷UI)
*   NSNull Crash
*   iOS16上的Crash

防护原理
----

Objective-C 语言是一门动态语言，利用 Objective-C 语言的 Runtime 运行时机制，对需要 `Hook` 的类添加 `Category`（分类），在各个分类的 `+(void)load` 中通过 `Method Swizzling` 拦截容易造成崩溃的系统方法，将系统原有方法与添加的防护方法的 `selector（方法选择器）与 IMP（函数实现指针）`进行交换。然后在替换方法中添加防护操作，从而达到避免以及修复崩溃的目的。

### Method Swizzling 方法的封装

由于这几种常见 Crash 的防护都需要用到 Method Swizzling 技术。所以我们可以为 NSObject 新建一个分类，将 Method Swizzling 相关的方法封装起来。

    @interface NSObject (Safe)
    
    /** 交换两个类方法的实现
      @param originalSelector  原始方法的 SEL
      @param swizzledSelector  交换方法的 SEL
      @param targetClass  类
     */
    + (void)jhDefenderSwizzlingClassMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass;
    
    /** 交换两个对象方法的实现
     @param originalSelector  原始方法的 SEL
     @param swizzledSelector 交换方法的 SEL
     @param targetClass  类
     */
    + (void)jhDefenderSwizzlingInstanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass;
    
    @end
    复制代码

    @implementation NSObject (Safe)
    
    // 交换两个类方法的实现
    + (void)iaskDefenderSwizzlingClassMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass {
        swizzlingClassMethod(targetClass, originalSelector, swizzledSelector);
    }
    
    // 交换两个对象方法的实现
    + (void)iaskDefenderSwizzlingInstanceMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector withClass:(Class)targetClass {
        swizzlingInstanceMethod(targetClass, originalSelector, swizzledSelector);
    }
    
    // 交换两个类方法的实现 C 函数
    void swizzlingClassMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
        Method originalMethod = class_getClassMethod(class, originalSelector);
        Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
    
        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod);                    method_getTypeEncoding(swizzledMethod));
    
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
    
    // 交换两个对象方法的实现 C 函数
    void swizzlingInstanceMethod(Class class, SEL originalSelector, SEL swizzledSelector) {
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        BOOL didAddMethod = class_addMethod(class,
                                            originalSelector,
                                            method_getImplementation(swizzledMethod),
    method_getTypeEncoding(swizzledMethod));
    
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
    
    @end
    复制代码

下面就来讲解下如何实现代码来防崩溃。

常见的Crash及防护措施
-------------

### 1\. Container Crash

指的是容器类的crash，常见的有NSArray／NSMutableArray／NSDictionary／NSMutableDictionary／NSCache的crash。 一些常见的越界，插入nil，等错误操作均会导致此类crash发生。

`解决方案`：对于容易造成crash的方法，自定义方法进行交换，并在自定义的方法中加入一些条件限制和判断。

#### NSArray+Safe

首先创建NSArray的分类(NSArray+Safe)，实现代码如下：

    #import "NSObject+Swizzling.h"
    #import <objc/runtime.h>
    
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
    
            //替换 objectAtIndex
            NSString *tmpStr = @"objectAtIndex:";
            NSString *tmpFirstStr = @"safe_ZeroObjectAtIndex:";
            NSString *tmpThreeStr = @"safe_objectAtIndex:";
            NSString *tmpSecondStr = @"safe_singleObjectAtIndex:";
    
            // 替换 objectAtIndexedSubscript
            NSString *tmpSubscriptStr = @"objectAtIndexedSubscript:";
            NSString *tmpSecondSubscriptStr = @"safe_objectAtIndexedSubscript:";
    
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArray0")
                                         originalSelector:NSSelectorFromString(tmpStr)                                     swizzledSelector:NSSelectorFromString(tmpFirstStr)];
    
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSSingleObjectArrayI")
                                         originalSelector:NSSelectorFromString(tmpStr)                                     swizzledSelector:NSSelectorFromString(tmpSecondStr)];
                                         
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArrayI")
                                         originalSelector:NSSelectorFromString(tmpStr)                                     swizzledSelector:NSSelectorFromString(tmpThreeStr)];
          
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArrayI")               originalSelector:NSSelectorFromString(tmpSubscriptStr)                                     swizzledSelector:NSSelectorFromString(tmpSecondSubscriptStr)];
        });
    }
    
    #pragma mark --- implement method
    
    /**
     取出NSArray 第index个 值 对应 __NSArrayI
      @param index 索引 index
      @return 返回值
     */
    
    - (id)safe_objectAtIndex:(NSUInteger)index {
        if (index >= self.count){
            return nil;
        }
        return [self safe_objectAtIndex:index];
    }
    
    /**
     取出NSArray 第index个 值 对应 __NSSingleObjectArrayI
      @param index 索引 index
      @return 返回值
     */
    - (id)safe_singleObjectAtIndex:(NSUInteger)index {
        if (index >= self.count){
            return nil;
        }
        return [self safe_singleObjectAtIndex:index];
    }
    
    /**
     取出NSArray 第index个 值 对应 __NSArray0
      @param index 索引 index
      @return 返回值
     */
    - (id)safe_ZeroObjectAtIndex:(NSUInteger)index {
        if (index >= self.count){
            return nil;
        }
        return [self safe_ZeroObjectAtIndex:index];
    }
    
    /**
     取出NSArray 第index个 值 对应 __NSArrayI
      @param idx 索引 idx
      @return 返回值
     */
    - (id)safe_objectAtIndexedSubscript:(NSUInteger)idx {
        if (idx >= self.count){
            return nil;
        }
        return [self safe_objectAtIndexedSubscript:idx];
    }
    复制代码

#### NSMutableArray+Safe

    #import "NSObject+Swizzling.h"
    #import <objc/runtime.h>
    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
    
            //替换 objectAtIndex:
            NSString *tmpGetStr = @"objectAtIndex:";
            NSString *tmpSafeGetStr = @"safeMutable_objectAtIndex:";
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArrayM")
                                         originalSelector:NSSelectorFromString(tmpGetStr)                                    swizzledSelector:NSSelectorFromString(tmpSafeGetStr)];
    
            //替换 removeObjectsInRange:
            NSString *tmpRemoveStr = @"removeObjectsInRange:";
            NSString *tmpSafeRemoveStr = @"safeMutable_removeObjectsInRange:";
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArrayM")
                             originalSelector:NSSelectorFromString(tmpRemoveStr)                                     swizzledSelector:NSSelectorFromString(tmpSafeRemoveStr)];
    
            //替换 insertObject:atIndex:
            NSString *tmpInsertStr = @"insertObject:atIndex:";
            NSString *tmpSafeInsertStr = @"safeMutable_insertObject:atIndex:";
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArrayM")
                              originalSelector:NSSelectorFromString(tmpInsertStr)                                     swizzledSelector:NSSelectorFromString(tmpSafeInsertStr)];
    
            //替换 removeObject:inRange:
            NSString *tmpRemoveRangeStr = @"removeObject:inRange:";
            NSString *tmpSafeRemoveRangeStr = @"safeMutable_removeObject:inRange:";
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArrayM")
                               originalSelector:NSSelectorFromString(tmpRemoveRangeStr)                             swizzledSelector:NSSelectorFromString(tmpSafeRemoveRangeStr)];
    
            // 替换 objectAtIndexedSubscript
            NSString *tmpSubscriptStr = @"objectAtIndexedSubscript:";
            NSString *tmpSecondSubscriptStr = @"safeMutable_objectAtIndexedSubscript:";
            [NSObject exchangeInstanceMethodWithSelfClass:NSClassFromString(@"__NSArrayM")
                          originalSelector:NSSelectorFromString(tmpSubscriptStr)                                    swizzledSelector:NSSelectorFromString(tmpSecondSubscriptStr)];
        });
    }
    
    #pragma mark --- implement method
    
    /**
     取出NSArray 第index个 值
      @param index 索引 index
      @return 返回值
     */
    - (id)safeMutable_objectAtIndex:(NSUInteger)index {
    
        if (index >= self.count){
            return nil;
        }
        return [self safeMutable_objectAtIndex:index];
    }
    
    /**
     NSMutableArray 移除索引 index 对应的值
      @param range 移除范围
     */
    - (void)safeMutable_removeObjectsInRange:(NSRange)range {
        if ((range.location + range.length) > self.count) {
            return;
        }
    
        return [self safeMutable_removeObjectsInRange:range];
    }
    
    /**
     在range范围内，移除掉anObject
      @param anObject 移除的anObject
      @param range 范围
     */
    
    - (void)safeMutable_removeObject:(id)anObject inRange:(NSRange)range {
     
        if ((range.location + range.length) > self.count) {
            return;
        }
    
        if (!anObject){
            return;
        }
    
        return [self safeMutable_removeObject:anObject inRange:range];
    }
    
    /**
     NSMutableArray 插入 新值 到 索引index 指定位置
      @param anObject 新值
      @param index 索引 index
     */
    - (void)safeMutable_insertObject:(id)anObject atIndex:(NSUInteger)index {
        if (index > self.count) {
            return;
        }
    
        if (!anObject){
            return;
        }
    
        [self safeMutable_insertObject:anObject atIndex:index];
    }
    
    /**
     取出NSArray 第index个 值 对应 __NSArrayI
      @param idx 索引 idx
      @return 返回值
     */
    
    - (id)safeMutable_objectAtIndexedSubscript:(NSUInteger)idx {
        if (idx >= self.count){
            return nil;
        }
    
        return [self safeMutable_objectAtIndexedSubscript:idx];
    }
    复制代码

这里我只是写出了NSArray和NSMutableArray的代码实现，其实NSDictionary和NSString也是同样的方法实现，交换系统的方法，在方法中实现异常情况的处理。

#### iOS16上的Crash

在项目中为 `NSMutableDictionary` 增加了空安全的防护，交换了系统的 `setObject:forKeyedSubscript:` 方法。发现这个会导致在iOS16系统上面，设置 `self.navigationItem.rightBarButtonItem =` 时出现内存爆增，最终导致项目因为内存问题Crash。

    setObject:forKeyedSubscript:
    当Object为nil时，Dictionary会将`key`对应的`obj`移除；
    当key为空时，会抛出NSInvalidArgumentException异常；
    复制代码

### 2\. Unrecognized Selector

如果被调用的对象方法没有实现，那么程序在运行中调用该方法时，就会因为找不到对应的方法实现，从而导致 APP 崩溃。那么可以在再找不到方法崩溃之前，拦截方法调用。

`消息转发的流程`：

*   动态方法解析：对象/类 在接收到无法解读的消息后，首先会调用`+resolveInstanceMethod:`或者`+resolveClassMethod:`，表示该类是否会增加一个方法实现。如果没有增加实现，进入下一步；
    
*   备援接收者(receiver)：如果当前对象实现了 `forwardingTargetForSelector:`，Runtime 就会调用这个方法，允许我们将消息的接受者转发给其他对象。如果返回为nil，则进入下一步转发流程；
    
*   完整的消息转发：如果`methodSignatureForSelector:`返回为nil，则会报错找不到方法。如果该方法返回了一个函数签名，那么系统会创建一个`NSInvocation`对象，把未处理的那条消息有关的细节都封于其中，改变调用目标，使消息在新目标上得到调用；
    

![截屏2022-03-21 下午5.15.08.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3dfccf8b62ab49d184077cc97f35f50d~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

这里我们选择第二步`（消息接受者重定向）来进行拦截`。因为 -forwardingTargetForSelector 方法可以将消息转发给一个对象，开销较小，并且被重写的概率较低，适合重写。

**具体实现步骤如下：**

*   给 NSObject 添加一个分类，在分类中实现一个自定义的 -jh\_forwardingTargetForSelector: 方法；
    
*   利用 Method Swizzling 将 -forwardingTargetForSelector:  和 -jh\_forwardingTargetForSelector: 进行方法交换；
    
*   在自定义的方法中，先判断当前对象是否已经实现了消息接受者重定向和消息重定向。如果都没有实现，就动态创建一个目标类，给目标类动态添加一个方法；
    
*   把消息转发给动态生成类的实例对象，由目标类动态创建的方法实现，这样就不存在找不到方法了；
    

实现代码如下：

    + (void)load {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 拦截 `-forwardingTargetForSelector:` 方法，替换自定义实现
            [NSObject iaskDefenderSwizzlingInstanceMethod: @selector(forwardingTargetForSelector:)withMethod: @selector(jh_forwardingTargetForSelector:)withClass:[NSObject class]];
    
            [NSObject iaskDefenderSwizzlingClassMethod: @selector(forwardingTargetForSelector:)withMethod: @selector(jh_forwardingTargetForSelector:) withClass:[NSObject class]];
        });
    }
    
    // 实例方法
    - (id)jh_forwardingTargetForSelector:(SEL)aSelector {
    
        SEL forwarding_sel = @selector(forwardingTargetForSelector:);
        
        // 获取 NSObject 的消息转发方法
        Method root_forwarding_method = class_getInstanceMethod([NSObject class], forwarding_sel);
        
        // 获取 当前类 的消息转发方法
        Method current_forwarding_method = class_getInstanceMethod([self class], forwarding_sel);
    
        // 判断当前类本身是否实现第二步:消息接受者重定向
        BOOL realize = method_getImplementation(current_forwarding_method) != method_getImplementation(root_forwarding_method);
    
        // 如果没有实现第二步:消息接受者重定向
        if (!realize) {
            // 判断有没有实现第三步:消息重定向
            SEL methodSignature_sel = @selector(methodSignatureForSelector:);
            Method root_methodSignature_method = class_getInstanceMethod([NSObject class], methodSignature_sel);
    
            Method current_methodSignature_method = class_getInstanceMethod([self class], methodSignature_sel);
    
            realize = method_getImplementation(current_methodSignature_method) != method_getImplementation(root_methodSignature_method);
    
            // 如果没有实现第三步:消息重定向
            if (!realize) {
                // 创建一个新类
                NSString *errClassName = NSStringFromClass([self class]);
                NSString *errSel = NSStringFromSelector(aSelector);
                NSLog(@"出问题的类，出问题的对象方法 == %@ %@", errClassName, errSel);
    
                NSString *className = @"CrachClass";
                Class cls = NSClassFromString(className);
                
                // 如果类不存在 动态创建一个类
                if (!cls) {
                    Class superClsss = [NSObject class];
                    cls = objc_allocateClassPair(superClsss, className.UTF8String, 0);
                    // 注册类
                    objc_registerClassPair(cls);
                }
                // 如果类没有对应的方法，则动态添加一个
                if (!class_getInstanceMethod(NSClassFromString(className), aSelector)) {
                    class_addMethod(cls, aSelector, (IMP)Crash, "@@:@");
                }
    
                // 把消息转发到当前动态生成类的实例对象上
                return [[cls alloc] init];
            }
        }
    
        return [self jh_forwardingTargetForSelector:aSelector];
    }
    
    // 类方法
    + (id)jh_forwardingTargetForSelector:(SEL)aSelector {
    
        SEL forwarding_sel = @selector(forwardingTargetForSelector:);
    
        // 获取 NSObject 的消息转发方法
        Method root_forwarding_method = class_getClassMethod([NSObject class], forwarding_sel);
    
        // 获取 当前类 的消息转发方法
        Method current_forwarding_method = class_getClassMethod([self class], forwarding_sel);
    
        // 判断当前类本身是否实现第二步:消息接受者重定向
        BOOL realize = method_getImplementation(current_forwarding_method) != method_getImplementation(root_forwarding_method);
    
        // 如果没有实现第二步:消息接受者重定向
        if (!realize) {
            // 判断有没有实现第三步:消息重定向
            SEL methodSignature_sel = @selector(methodSignatureForSelector:);
    
            Method root_methodSignature_method = class_getClassMethod([NSObject class], methodSignature_sel);
            
            Method current_methodSignature_method = class_getClassMethod([self class], methodSignature_sel);
    
            realize = method_getImplementation(current_methodSignature_method) != method_getImplementation(root_methodSignature_method);
    
            // 如果没有实现第三步:消息重定向
            if (!realize) {
                // 创建一个新类
                NSString *errClassName = NSStringFromClass([self class]);
                NSString *errSel = NSStringFromSelector(aSelector);
                NSLog(@"出问题的类，出问题的类方法 == %@ %@", errClassName, errSel);
                NSString *className = @"CrachClass";
                Class cls = NSClassFromString(className);
    
                // 如果类不存在 动态创建一个类
                if (!cls) {
                    Class superClsss = [NSObject class];
                    cls = objc_allocateClassPair(superClsss, className.UTF8String, 0);
                    // 注册类
                    objc_registerClassPair(cls);
                }
                // 如果类没有对应的方法，则动态添加一个
                if (!class_getInstanceMethod(NSClassFromString(className), aSelector)) {
                    class_addMethod(cls, aSelector, (IMP)Crash, "@@:@");
                }
                // 把消息转发到当前动态生成类的实例对象上
                return [[cls alloc] init];
            }
        }
    
        return [self jh_forwardingTargetForSelector:aSelector];
    }
    
    // 动态添加的方法实现
    
    static int Crash(id slf, SEL selector) {
        return 0;
    }
    复制代码

### 3\. KVC Crash

#### 什么是KVC？

KVC表示键值编码，提供一种机制来间接访问对象的属性。

#### KVC常见的崩溃原因：

*   key 不是对象的属性，造成崩溃；
*   keyPath 不正确，造成崩溃；
*   key 为 nil，造成崩溃；
*   value 为 nil，为非对象设值，造成崩溃；

`KVC的Setter 搜索模式`

![截屏2022-03-21 下午5.45.20.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/54ef557e5bb04fef94bc28997fb3fc72~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

`KVC的Getter 搜索模式`

![截屏2022-03-21 下午5.45.43.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c295ab44b598429fbe1220e2e2bd5af5~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

从上面流程可以看出，`setValue:forKey:` 执行失败会调用 `setValue: forUndefinedKey:` 方法，并引发崩溃；`valueForKey:` 执行失败会调用 `valueForUndefinedKey:` 方法，并引发崩溃；

对应上面的崩溃给出了对应的解决方案：

*   重写`setValue: forUndefinedKey:`方法和`valueForUndefinedKey:` 方法；
*   key为nil导致的问题，只需要交换系统的`setValue:forKey:`方法；
*   value 为 nil导致的问题，需要重写系统的`setNilValueForKey:`方法

可参考[『Crash 防护系统』（三）KVC 防护](https://juejin.cn/post/6844903934662803464 "https://juejin.cn/post/6844903934662803464")

### 4\. KVO Crash

#### 什么是KVO？

KVO是键值对观察，是 iOS 观察者模式的一种实现。KVO 允许一个对象监听另一个对象特定属性的改变，并在改变时接收到事件。

#### KVO常见的崩溃原因：

*   KVO 添加次数和移除次数不匹配；
*   被观察者提前被释放，被观察者在 dealloc 时仍然注册着 KVO；
*   添加或者移除时 keypath == nil；
*   添加了观察者，但未实现 observeValueForKeyPath:ofObject:change:context: 方法

#### 解决方案：

*   创建一个KVOProxy对象，在对象中使用{keypath : [observer1, observer2 , ...](https://link.juejin.cn?target=NSHashTable "NSHashTable")} 结构的关系哈希表进行 observer、keyPath 之间的维护；
*   然后利用 KVOProxy 对象对添加、移除、观察方法进行分发处理；
*   在分类中自定义了 dealloc 的实现，移除了多余的观察者；

[可参考『Crash 防护系统』（二）KVO 防护](https://juejin.cn/post/6844903927469588488 "https://juejin.cn/post/6844903927469588488")

### 5\. NSNotification Crash

产生的原因： 当一个对象添加了notification之后，如果dealloc的时候，仍然持有notification，就会出现NSNotification类型的crash。NSNotification类型的crash多产生于程序员写代码时候犯疏忽，在NSNotificationCenter添加一个对象为observer之后，忘记了在对象dealloc的时候移除它。

iOS9之前会crash，iOS9之后苹果系统已优化。在iOS9之后，即使开发者没有移除observer，Notification crash也不会再产生了。

解决方案： 交换系统的dealloc方法，在对象真正dealloc之前调用下`[[NSNotificationCenter defaultCenter] removeObserver:self]`

### 6\. NSTimer Crash

产生的原因：由于定时器 timer `强引用 target` 的关系导致 target `不能被释放`，造成内存泄露。与此同时，如果 NSTimer 是无限重复的执行一个任务的话，也有可能导致 target 的 selector 一直被重复调用且处于无效状态，对 app 的 CPU ，内存等性能方面均是没有必要的浪费。

解决办法： 定义一个抽象类，NSTimer 实例强引用抽象类，而在抽象类中，弱引用 target ，这样 target 和 NSTimer 之间的关系也就是弱引用了，意味着 target 可以自由的释放，从而解决了循环引用的问题。

### 7\. Bad Access Crash

野指针就是指向一个已删除的对象或者受限内存区域的指针。比较常见的就是这个指针指向的内存，在别处被回收了，但是这个指针不知道，依然还指向这块内存。

解决野指针导致的crash往往是一件棘手的事情，因为产生crash 的场景不好复现，再一个crash之后console(控制台)的信息提供的帮助有限。XCode本身为了便于开放调试时发现野指针问题，提供了Zombie机制，能够在发生野指针时提示出现野指针的类，从而解决了开发阶段出现野指针的问题。然而针对于线上产生的野指针问题，依旧没有一个比较好的办法来定位问题。

#### 野指针crash 防护方案：

野指针问题的解决思路方向其实很容易确定，XCode提供了`Zombie`的机制来排查野指针的问题，那么我们这边可以实现一个类似于Zombie的机制，加上对zombie实例的全部方法拦截机制 和 消息转发机制，那么就可以做到在野指针访问时不Crash而只是crash时相关的信息。

同时还需要注意一点：因为zombie的机制需要在对象释放时保留其指针和相关内存占用，随着app的进行，越来越多的对象被创建和释放，这会导致内存占用越来越大，这样显然对于一个正常运行的app的性能有影响。所以需要一个合适的zombie对象释放机制，确定zombie机制对内存的影响是有限度的。

zombie机制的实现主要分为以下四个环节：

**第一步**：method swizzling替换NSObject的`allocWithZone`方法，在新的方法中判断该类型对象是否需要加入野指针防护，如果需要，则通过`objc_setAssociatedObject`为该对象设置`flag`标记，被标记的对象后续会进入zombie流程

![截屏2022-03-21 下午9.15.40.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0a09fcc48ad34a54b4ac2fd7b5811117~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

做flag标记是因为很多系统类，比如NSString，UIView等创建，释放非常频繁，而这些实例发生野指针概率非常低。基本都是我们自己写的类才会有野指针的相关问题，所以通过在创建时 设置一个标记用来过滤不必要做野指针防护的实例，提高方案的效率。

同时做判断是否要加入标记的条件里面，我们加入了黑名单机制，是因为一些特定的类是不适用于添加到zombie机制的，会发生崩溃（例如：NSBundle），而且所以和zombie机制相关的类也不能加入标记，否则会在释放过程中循环引用和调用，导致内存泄漏甚至栈溢出。

**第二步**：method swizzling替换NSObject的dealloc方法，对flag标记的对象实例调用`objc_destructInstance`，释放该实例引用的相关属性，然后将实例的isa修改为HTZombieObject。通过objc\_setAssociatedObject 保存将原始类名保存在该实例中。

![截屏2022-03-21 下午9.17.27.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cbaef59ac8a5483fa7de7950390587f5~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

调用objc\_destructInstance的原因：

这里参考了系统在Object-C Runtime 中NSZombies实现，dealloc最后会调到`objectdispose`函数，在这个函数里面 其实也做了三件事情，

*   调用objc\_destructInstance释放该实例引用的相关实例
*   释放该内存

官方文档对objc\_destructInstance的解释为：

    Destroys an instance of a class without freeing memory and removes any associated references this instance might have had.
    复制代码

说明objc\_destructInstance会释放与实例相关联的引用，但是并不释放该实例等内存。

**第三步**：在HTZombieObject 通过消息转发机制forwardingTargetForSelector处理所有拦截的方法，根据selector动态添加能够处理方法的响应者HTStubObject 实例，然后通过 objc\_getAssociatedObject 获取之前保存该实例对应的原始类名，统计错误数据。

![截屏2022-03-21 下午9.19.28.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ce9a4cc73208464fba026feb917acc72~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

HTZombieObject的处理和unrecognized selector crash的处理是一样，主要的目的就是拦截所有传给HTZombieObject的函数，用一个返回为空的函数来替换，从而达到程序不崩溃的目的。

**第四步**：当退到后台或者达到未释放实例的上限时，则在ht\_freeSomeMemory方法中调用原有dealloc方法释放所有被zombie化的实例

综上所述，可以用下图总结一下bad access类型crash的防护流程：

![截屏2022-03-21 下午9.20.40.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d902873d05ca474ea65ada1e68773421~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?)

由于做了延时释放若干实例，对系统总内存会产生一定影响，目前将内存的缓冲区开到2M左右，所以应该没有很大的影响，但还是可能潜在一些风险。

延时释放实例是根据相关功能代码会聚焦在某一个时间段调用的假设前提下，所以野指针的zombie保护机制只能在其实例对象仍然缓存在zombie的缓存机制时才有效，若在实例真正释放之后，再调用野指针还是会出现Crash。

### 8\. 非主线程刷UI(Crash)

#### 为什么只在主线程刷新UI？

UIKit并不是一个线程安全的类，UI操作设计到渲染访问各种View对象的属性，如果异步操作下会存在读写的问题，而为其加锁则会耗费大量的资源并拖慢运行速度。另一方面因为整个程序的起点UIApplication是在主线程进行初始化，所以的用户事件都是在主线程上进行传递，所以View只能在主线程上才能对事件进行响应。而在渲染方面由于图像的渲染需要以60帧的刷新率在屏幕上同时更新，在非主线程异步话的情况下，无法确定这个处理过程能够实现同步更新。

目前初步的处理方案是`swizzle UIView`类的以下三个方法：

\-(void)setNeedsLayout;

\-(void)setNeedsDisplay;

\-(void)setNeedsDisplayInRect:(CGRect)rect;

在这三个方法调用的时候判断一下当前的线程，如果不是主线程的话，直接利用 dispatch\_async(dispatch\_get\_main\_queue(), ^{ //调用原本方法 });但是真正实施了之后，发现这三个方法并不能完全覆盖UIView相关的所有刷UI到操作。目前我也就找到这样的方法来解决。

### 9\. NSNull Crash

在解析后端Json数据时，有时会存在莫名其妙的返回了NSNull(实现已经约定不能返回NUll)，导致了App闪退，真坑爹啊。我们知道是不能给NSNull类型发送消息的。

第一种方式：AFN自带的属性，可以从响应JSON中移除值为NULL的键

    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    responseSerializer.removesKeysWithNullValues = YES;
    复制代码

`NullSafe`分析实现：这里主要还是用到OC运行时机制，关键点还是在消息转发上。新建一个Null的分类NullSafe，重写动态转发的方法。首先查找方法签名，如果能获取不到，就对常用的Foundation框架类遍历验证，假如能响应这个方法，就生成新的方法签名，然后进行下一步的转发。最后一步对方法进行转发，设置target对象为nil，像nil发送消息是不会发生崩溃的。

    - (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
    {
        //look up method signature
        NSMethodSignature *signature = [super methodSignatureForSelector:selector];
        if (!signature)
        {
            for (Class someClass in @[
                [NSMutableArray class],
                [NSMutableDictionary class],
                [NSMutableString class],
                [NSNumber class],
                [NSDate class],
                [NSData class]
            ])
            {
                @try
                {
                    if ([someClass instancesRespondToSelector:selector])
                    {
                        signature = [someClass instanceMethodSignatureForSelector:selector];
                        break;
                    }
                }
                @catch (__unused NSException *unused) {}
            }
        }
    
        return signature;
    }
    
    - (void)forwardInvocation:(NSInvocation *)invocation
    {
        invocation.target = nil;
        [invocation invoke];
    }
    复制代码

总结：
---

在项目中，我们可以定义一个类管理这些Crash防护，需不需要开启。因为在我们开发的过程中还是想能及时发现问题，然后及时修复问题。

我们也要合理权衡开启的防护类型，仅默认开启线上反馈的常见类型，而不是开启所有类型，其他类型可以配置为动态开启，根据用户设备的闪退日志开启防护。其次各种Hook带来的未知性，Crash 本身是非正常情况下才产生的，如果一味地规避这种异常，可能会产生更多的异常情况，特别是业务逻辑上会出现不可控制的流程。所以我们平常也要注意代码质量，严格防止出现那些低级的错误，应该去避免出现错误，而不是去防护错误的出现。

参考文章：

[juejin.cn/post/684490…](https://juejin.cn/post/6844903927469588488 "https://juejin.cn/post/6844903927469588488")

[大白健康系统](https://link.juejin.cn?target=https%3A%2F%2Fmp.weixin.qq.com%2Fs%3F__biz%3DMzUxMzcxMzE5Ng%3D%3D%26mid%3D2247488311%26idx%3D1%26sn%3D0db090c8d4a5efafa47f00af4b3f174f%26source%3D41%23wechat_redirect "https://mp.weixin.qq.com/s?__biz=MzUxMzcxMzE5Ng==&mid=2247488311&idx=1&sn=0db090c8d4a5efafa47f00af4b3f174f&source=41#wechat_redirect")