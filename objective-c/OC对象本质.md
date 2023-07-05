# Objective-C
### objc中向一个nil对象发送消息将会发生什么？
在 Objective-C 中向 nil 发送消息是完全有效的——只是在运行时不会有任何作用:

1、 如果一个方法返回值是一个对象，那么发送给nil的消息将返回0(nil)。例如：  
 
```Objective-C
Person * motherInlaw = [[aPerson spouse] mother];
```
 如果 spouse 方法的返回值为 nil，那么发送给 nil 的消息 mother 也将返回 nil。

2、 如果方法返回值为指针类型，其指针大小为小于或者等于sizeof(void*)，float，double，long double 或者 long long 的整型标量，发送给 nil 的消息将返回0。

3、 如果方法返回值为结构体,发送给 nil 的消息将返回0。结构体中各个字段的值将都是0。

4、 如果方法的返回值不是上述提到的几种情况，那么发送给 nil 的消息的返回值将是未定义的。

具体原因如下：


> objc是动态语言，每个方法在运行时会被动态转为消息发送，即：objc_msgSend(receiver, selector)。


那么，为了方便理解这个内容，还是贴一个objc的源代码：


 
```Objective-C
// runtime.h（类在runtime中的定义）
struct objc_class {
  Class isa OBJC_ISA_AVAILABILITY; //isa指针指向Meta Class，因为Objc的类的本身也是一个Object，为了处理这个关系，runtime就创造了Meta Class，当给类发送[NSObject alloc]这样消息时，实际上是把这个消息发给了Class Object
  #if !__OBJC2__
  Class super_class OBJC2_UNAVAILABLE; // 父类
  const char *name OBJC2_UNAVAILABLE; // 类名
  long version OBJC2_UNAVAILABLE; // 类的版本信息，默认为0
  long info OBJC2_UNAVAILABLE; // 类信息，供运行期使用的一些位标识
  long instance_size OBJC2_UNAVAILABLE; // 该类的实例变量大小
  struct objc_ivar_list *ivars OBJC2_UNAVAILABLE; // 该类的成员变量链表
  struct objc_method_list **methodLists OBJC2_UNAVAILABLE; // 方法定义的链表
  struct objc_cache *cache OBJC2_UNAVAILABLE; // 方法缓存，对象接到一个消息会根据isa指针查找消息对象，这时会在method Lists中遍历，如果cache了，常用的方法调用时就能够提高调用的效率。
  struct objc_protocol_list *protocols OBJC2_UNAVAILABLE; // 协议链表
  #endif
  } OBJC2_UNAVAILABLE;
```

objc在向一个对象发送消息时，runtime库会根据对象的isa指针找到该对象实际所属的类，然后在该类中的方法列表以及其父类方法列表中寻找方法运行，然后在发送消息的时候，objc_msgSend方法不会返回值，所谓的返回内容都是具体调用时执行的。
那么，回到本题，如果向一个nil对象发送消息，首先在寻找对象的isa指针时就是0地址返回了，所以不会出现任何错误。

### 什么时候会报unrecognized selector的异常？
简单来说：


> 当调用该对象上某个方法,而该对象上没有实现这个方法的时候，
可以通过“消息转发”进行解决。



简单的流程如下，在上一题中也提到过：


> objc是动态语言，每个方法在运行时会被动态转为消息发送，即：objc_msgSend(receiver, selector)。


objc在向一个对象发送消息时，runtime库会根据对象的isa指针找到该对象实际所属的类，然后在该类中的方法列表以及其父类方法列表中寻找方法运行，如果，在最顶层的父类中依然找不到相应的方法时，程序在运行时会挂掉并抛出异常unrecognized selector sent to XXX 。但是在这之前，objc的运行时会给出三次拯救程序崩溃的机会：


 1. Method resolution

 objc运行时会调用`+resolveInstanceMethod:`或者 `+resolveClassMethod:`，让你有机会提供一个函数实现。如果你添加了函数，那运行时系统就会重新启动一次消息发送的过程，否则 ，运行时就会移到下一步，消息转发（Message Forwarding）。

 2. Fast forwarding

 如果目标对象实现了 `-forwardingTargetForSelector:`，Runtime 这时就会调用这个方法，给你把这个消息转发给其他对象的机会。
只要这个方法返回的不是nil和self，整个消息发送的过程就会被重启，当然发送的对象会变成你返回的那个对象。否则，就会继续Normal Fowarding。
这里叫Fast，只是为了区别下一步的转发机制。因为这一步不会创建任何新的对象，但下一步转发会创建一个NSInvocation对象，所以相对更快点。
 3. Normal forwarding

 这一步是Runtime最后一次给你挽救的机会。首先它会发送 `-methodSignatureForSelector:` 消息获得函数的参数和返回值类型。如果 `-methodSignatureForSelector:` 返回nil，Runtime则会发出 `-doesNotRecognizeSelector:` 消息，程序这时也就挂掉了。如果返回了一个函数签名，Runtime就会创建一个NSInvocation对象并发送 `-forwardInvocation:` 消息给目标对象。

为了能更清晰地理解这些方法的作用，git仓库里也给出了一个Demo，名称叫“ `_objc_msgForward_demo` ”,可运行起来看看。

### 一个objc对象如何进行内存布局？（考虑有父类的情况）

 - 所有父类的成员变量和自己的成员变量都会存放在该对象所对应的存储空间中.
 - 每一个对象内部都有一个isa指针,指向他的类对象,类对象中存放着本对象的
  1. 对象方法列表（对象能够接收的消息列表，保存在它所对应的类对象中）
  2. 成员变量的列表,
  2. 属性列表,

 它内部也有一个isa指针指向元对象(meta class),元对象内部存放的是类方法列表,类对象内部还有一个superclass的指针,指向他的父类对象。

 - 根对象就是NSObject，它的superclass指针指向nil

 - 类对象既然称为对象，那它也是一个实例。类对象中也有一个isa指针指向它的元类(meta class)，即类对象是元类的实例。元类内部存放的是类方法列表，根元类的isa指针指向自己，superclass指针指向NSObject类。
 -  类对象 是放在数据段(数据区)上的, 和全局变量放在一个地方. 这也就是为什么: 同一个类对象的不同实例对象,的isa指针是一样的.
 -  实例对象存放在堆中

### 一个objc对象的isa的指针指向什么？有什么作用？
`isa` 顾名思义 `isa` 表示对象所属的类。
`isa` 指向他的类对象，从而可以找到对象上的方法。同一个类的不同对象，他们的 isa 指针是一样的。

### 下面的代码输出什么？
 ```Objective-C
    @implementation Son : Father
    - (id)init
    {
        self = [super init];
        if (self) {
            NSLog(@"%@", NSStringFromClass([self class]));//Son
            NSLog(@"%@", NSStringFromClass([super class]));//Son
        }
        return self;
    }
    @end
 ```
super关键字，有以下几点需要注意：
- receiver还是当前类对象，而不是父类对象；
- super这里的含义就是优先去父类的方法列表中去查实现，很多问题都是父类中其实也没有实现，还是去根类里 去找实现，这种情况下时，其实跟直接调用self的效果是一致的。

下面做详细介绍:
我们都知道：self 是类的隐藏参数，指向当前调用方法的这个类的实例。那 super 呢？
很多人会想当然的认为“ super 和 self 类似，应该是指向父类的指针吧！”。这是很普遍的一个误区。其实 super 是一个 Magic Keyword， 它本质是一个编译器标示符，和 self 是指向的同一个消息接受者！他们两个的不同点在于：super 会告诉编译器，调用 class 这个方法时，要去父类的方法，而不是本类里的。

上面的例子不管调用`[self class]`还是`[super class]`，接受消息的对象都是当前 `Son ＊xxx` 这个对象。

当使用 self 调用方法时，会从当前类的方法列表中开始找，如果没有，就从父类中再找；而当使用 super 时，则从父类的方法列表中开始找。然后调用父类的这个方法。
接下来让我们利用 runtime 的相关知识来验证一下 super 关键字的本质，使用clang重写命令:


 ```Objective-C
    $ clang -rewrite-objc test.m
 ```

将这道题目中给出的代码被转化为:


 ```Objective-C
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_gm_0jk35cwn1d3326x0061qym280000gn_T_main_a5cecc_mi_0, NSStringFromClass(((Class (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("class"))));

    NSLog((NSString *)&__NSConstantStringImpl__var_folders_gm_0jk35cwn1d3326x0061qym280000gn_T_main_a5cecc_mi_1, NSStringFromClass(((Class (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){ (id)self, (id)class_getSuperclass(objc_getClass("Son")) }, sel_registerName("class"))));
 ```

从上面的代码中，我们可以发现在调用 [self class] 时，会转化成 `objc_msgSend`函数。看下函数定义：


 ```Objective-C
    id objc_msgSend(id self, SEL op, ...)
 ```
我们把 self 做为第一个参数传递进去。

而在调用 [super class]时，会转化成 `objc_msgSendSuper`函数。看下函数定义:


 ```Objective-C
    id objc_msgSendSuper(struct objc_super *super, SEL op, ...)
 ```

第一个参数是 `objc_super` 这样一个结构体，其定义如下:


 ```Objective-C
struct objc_super {
       __unsafe_unretained id receiver;
       __unsafe_unretained Class super_class;
};
 ```

结构体有两个成员，第一个成员是 receiver, 类似于上面的 `objc_msgSend`函数第一个参数self 。第二个成员是记录当前类的父类是什么。

所以，当调用 ［self class] 时，实际先调用的是 `objc_msgSend`函数，第一个参数是 Son当前的这个实例，然后在 Son 这个类里面去找 - (Class)class这个方法，没有，去父类 Father里找，也没有，最后在 NSObject类中发现这个方法。而 - (Class)class的实现就是返回self的类别，故上述输出结果为 Son。

objc Runtime开源代码对- (Class)class方法的实现:
 ```Objective-C
- (Class)class {
    return object_getClass(self);
}
 ```

而当调用 `[super class]`时，会转换成`objc_msgSendSuper函数`。第一步先构造 `objc_super` 结构体，结构体第一个成员就是 `self` 。
第二个成员是 `(id)class_getSuperclass(objc_getClass(“Son”))` , 实际该函数输出结果为 Father。

第二步是去 Father这个类里去找 `- (Class)class`，没有，然后去NSObject类去找，找到了。最后内部是使用 `objc_msgSend(objc_super->receiver, @selector(class))`去调用，

此时已经和`[self class]`调用相同了，故上述输出结果仍然返回 Son。

参考链接：[微博@Chun_iOS](http://weibo.com/junbbcom)的博文[刨根问底Objective－C Runtime（1）－ Self & Super](http://chun.tips/blog/2014/11/05/bao-gen-wen-di-objective%5Bnil%5Dc-runtime(1)%5Bnil%5D-self-and-super/)


### runtime如何通过selector找到对应的IMP地址?

每一个类对象中都一个方法列表，方法列表中记录着方法的名称、方法实现、以及参数类型，其实selector 本质就是方法名称，通过这个方法名称就可以在方法列表中找到对应的方法实现。

参考 NSObject 上面的方法：

 ```Objective-C
- (IMP)methodForSelector:(SEL)aSelector;
+ (IMP)instanceMethodForSelector:(SEL)aSelector;
 ```
 
 参考： [Apple Documentation-Objective-C Runtime-NSObject-methodForSelector:]( https://developer.apple.com/documentation/objectivec/nsobject/1418863-methodforselector?language=objc "Apple Documentation-Objective-C Runtime-NSObject-methodForSelector:") 
 
### 使用runtime的Associate方法关联的对象,需要在主对象dealloc的时候释放么?
> 无论在MRC下还是ARC下均不需要。


[ ***2011年版本的Apple API 官方文档 - Associative References***  ](https://web.archive.org/web/20120818164935/http://developer.apple.com/library/ios/#/web/20120820002100/http://developer.apple.com/library/ios/documentation/cocoa/conceptual/objectivec/Chapters/ocAssociativeReferences.html) 一节中有一个MRC环境下的例子：


 
```Objective-C
// 在MRC下，使用runtime Associate方法关联的对象，不需要在主对象dealloc的时候释放
// http://weibo.com/luohanchenyilong/ (微博@iOS程序犭袁)
// https://github.com/ChenYilong
// 摘自2011年版本的Apple API 官方文档 - Associative References 

static char overviewKey;
 
NSArray *array =
    [[NSArray alloc] initWithObjects:@"One", @"Two", @"Three", nil];
// For the purposes of illustration, use initWithFormat: to ensure
// the string can be deallocated
NSString *overview =
    [[NSString alloc] initWithFormat:@"%@", @"First three numbers"];
 
objc_setAssociatedObject (
    array,
    &overviewKey,
    overview,
    OBJC_ASSOCIATION_RETAIN
);
 
[overview release];
// (1) overview valid
[array release];
// (2) overview invalid
```
文档指出 

> At point 1, the string `overview` is still valid because the `OBJC_ASSOCIATION_RETAIN` policy specifies that the array retains the associated object. When the array is deallocated, however (at point 2), `overview` is released and so in this case also deallocated.

我们可以看到，在`[array release];`之后，overview就会被release释放掉了。

既然会被销毁，那么具体在什么时间点？


> 根据[ ***WWDC 2011, Session 322 (第36分22秒)*** ](https://developer.apple.com/videos/wwdc/2011/#322-video)中发布的内存销毁时间表，被关联的对象在生命周期内要比对象本身释放的晚很多。它们会在被 NSObject -dealloc 调用的 object_dispose() 方法中释放。

对象的内存销毁时间表，分四个步骤：

    // 对象的内存销毁时间表
    // http://weibo.com/luohanchenyilong/ (微博@iOS程序犭袁)
    // https://github.com/ChenYilong
    // 根据 WWDC 2011, Session 322 (36分22秒)中发布的内存销毁时间表 

     1. 调用 -release ：引用计数变为零
         * 对象正在被销毁，生命周期即将结束.
         * 不能再有新的 __weak 弱引用， 否则将指向 nil.
         * 调用 [self dealloc] 
     2. 子类 调用 -dealloc
         * 继承关系中最底层的子类 在调用 -dealloc
         * 如果是 MRC 代码 则会手动释放实例变量们（iVars）
         * 继承关系中每一层的父类 都在调用 -dealloc
     3. NSObject 调 -dealloc
         * 只做一件事：调用 Objective-C runtime 中的 object_dispose() 方法
     4. 调用 object_dispose()
         * 为 C++ 的实例变量们（iVars）调用 destructors 
         * 为 ARC 状态下的 实例变量们（iVars） 调用 -release 
         * 解除所有使用 runtime Associate方法关联的对象
         * 解除所有 __weak 引用
         * 调用 free()


对象的内存销毁时间表：[参考链接](http://stackoverflow.com/a/10843510/3395008)。

### `_objc_msgForward`函数是做什么的，直接调用它将会发生什么？

> `_objc_msgForward`是 IMP 类型，用于消息转发的：当向一个对象发送一条消息，但它并没有实现的时候，`_objc_msgForward`会尝试做消息转发。

我们可以这样创建一个`_objc_msgForward`对象：

    IMP msgForwardIMP = _objc_msgForward;

在[上篇](https://github.com/ChenYilong/iOSInterviewQuestions)中的《objc中向一个对象发送消息`[obj foo]`和`objc_msgSend()`函数之间有什么关系？》曾提到`objc_msgSend`在“消息传递”中的作用。在“消息传递”过程中，`objc_msgSend`的动作比较清晰：首先在 Class 中的缓存查找 IMP （没缓存则初始化缓存），如果没找到，则向父类的 Class 查找。如果一直查找到根类仍旧没有实现，则用`_objc_msgForward`函数指针代替 IMP 。最后，执行这个 IMP 。



Objective-C运行时是开源的，所以我们可以看到它的实现。打开[ ***Apple Open Source 里Mac代码里的obj包*** ](http://www.opensource.apple.com/tarballs/objc4/)下载一个最新版本，找到 `objc-runtime-new.mm`，进入之后搜索`_objc_msgForward`。
里面有对`_objc_msgForward`的功能解释：

```Objective-C
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
```

对 `objc-runtime-new.mm`文件里与`_objc_msgForward`有关的三个函数使用伪代码展示下：

```Objective-C
//  objc-runtime-new.mm 文件里与 _objc_msgForward 有关的三个函数使用伪代码展示
//  同时，这也是 obj_msgSend 的实现过程

id objc_msgSend(id self, SEL op, ...) {
    if (!self) return nil;
    IMP imp = class_getMethodImplementation(self->isa, SEL op);
    imp(self, op, ...); //调用这个函数，伪代码...
}
 
//查找IMP
IMP class_getMethodImplementation(Class cls, SEL sel) {
    if (!cls || !sel) return nil;
    IMP imp = lookUpImpOrNil(cls, sel);
    if (!imp) return _objc_msgForward; //_objc_msgForward 用于消息转发
    return imp;
}
 
IMP lookUpImpOrNil(Class cls, SEL sel) {
    if (!cls->initialize()) {
        _class_initialize(cls);
    }
 
    Class curClass = cls;
    IMP imp = nil;
    do { //先查缓存,缓存没有时重建,仍旧没有则向父类查询
        if (!curClass) break;
        if (!curClass->cache) fill_cache(cls, curClass);
        imp = cache_getImp(curClass, sel);
        if (imp) break;
    } while (curClass = curClass->superclass);
 
    return imp;
}
```
虽然Apple没有公开`_objc_msgForward`的实现源码，但是我们还是能得出结论：

> `_objc_msgForward`是一个函数指针（和 IMP 的类型一样），是用于消息转发的：当向一个对象发送一条消息，但它并没有实现的时候，`_objc_msgForward`会尝试做消息转发。


> 在[上篇](https://github.com/ChenYilong/iOSInterviewQuestions)中的《objc中向一个对象发送消息`[obj foo]`和`objc_msgSend()`函数之间有什么关系？》曾提到`objc_msgSend`在“消息传递”中的作用。在“消息传递”过程中，`objc_msgSend`的动作比较清晰：首先在 Class 中的缓存查找 IMP （没缓存则初始化缓存），如果没找到，则向父类的 Class 查找。如果一直查找到根类仍旧没有实现，则用`_objc_msgForward`函数指针代替 IMP 。最后，执行这个 IMP 。



为了展示消息转发的具体动作，这里尝试向一个对象发送一条错误的消息，并查看一下`_objc_msgForward`是如何进行转发的。

首先开启调试模式、打印出所有运行时发送的消息：
可以在代码里执行下面的方法：

```Objective-C
(void)instrumentObjcMessageSends(YES);
```
因为该函数处于 objc-internal.h 内，而该文件并不开放，所以调用的时候先声明，目的是告诉编译器程序目标文件包含该方法存在，让编译通过
```
OBJC_EXPORT void
instrumentObjcMessageSends(BOOL flag)
OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0);
```

或者断点暂停程序运行，并在 gdb 中输入下面的命令：

```Objective-C
call (void)instrumentObjcMessageSends(YES)
```

之后，运行时发送的所有消息都会打印到`/tmp/msgSend-xxxx`文件里了。

终端中输入命令前往：

```Objective-C
open /private/tmp
```

可能看到有多条，找到最新生成的，双击打开

在模拟器上执行执行以下语句（这一套调试方案仅适用于模拟器，真机不可用，关于该调试方案的拓展链接：[ ***Can the messages sent to an object in Objective-C be monitored or printed out?*** ](http://stackoverflow.com/a/10750398/3395008)），向一个对象发送一条错误的消息：

```Objective-C
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CYLTest.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        CYLTest *test = [[CYLTest alloc] init];
        [test performSelector:(@selector(iOS程序犭袁))];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

```

你可以在`/tmp/msgSend-xxxx`（我这一次是`/tmp/msgSend-9805`）文件里，看到打印出来：
```Objective-C
+ CYLTest NSObject initialize
+ CYLTest NSObject alloc
- CYLTest NSObject init
- CYLTest NSObject performSelector:
+ CYLTest NSObject resolveInstanceMethod:
+ CYLTest NSObject resolveInstanceMethod:
- CYLTest NSObject forwardingTargetForSelector:
- CYLTest NSObject forwardingTargetForSelector:
- CYLTest NSObject methodSignatureForSelector:
- CYLTest NSObject methodSignatureForSelector:
- CYLTest NSObject class
- CYLTest NSObject doesNotRecognizeSelector:
- CYLTest NSObject doesNotRecognizeSelector:
- CYLTest NSObject class
```



结合[《NSObject官方文档》](https://developer.apple.com/library/prerelease/watchos/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/#//apple_ref/doc/uid/20000050-SW11)，排除掉 NSObject 做的事，剩下的就是`_objc_msgForward`消息转发做的几件事：


 1. 调用`resolveInstanceMethod:`方法 (或 `resolveClassMethod:`)。允许用户在此时为该 Class 动态添加实现。如果有实现了，则调用并返回YES，那么重新开始`objc_msgSend`流程。这一次对象会响应这个选择器，一般是因为它已经调用过`class_addMethod`。如果仍没实现，继续下面的动作。

 2. 调用`forwardingTargetForSelector:`方法，尝试找到一个能响应该消息的对象。如果获取到，则直接把消息转发给它，返回非 nil 对象。否则返回 nil ，继续下面的动作。注意，这里不要返回 self ，否则会形成死循环。(讨论见： [《forwardingTargetForSelector返回self不会死循环吧。 #64》](https://github.com/ChenYilong/iOSInterviewQuestions/issues/64) 

 3. 调用`methodSignatureForSelector:`方法，尝试获得一个方法签名。如果获取不到，则直接调用`doesNotRecognizeSelector`抛出异常。如果能获取，则返回非nil：创建一个 NSInvocation 并传给`forwardInvocation:`。

 4. 调用`forwardInvocation:`方法，将第3步获取到的方法签名包装成 Invocation 传入，如何处理就在这里面了。(讨论见： [《_objc_msgForward问题 #106》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/106 ) 
 5. 调用`doesNotRecognizeSelector:` ，默认的实现是抛出异常。如果第3步没能获得一个方法签名，执行该步骤。

上面前4个方法均是模板方法，开发者可以重写(override)，由 runtime 来调用。最常见的实现消息转发：就是重写方法3和4，吞掉一个消息或者代理给其他对象都是没问题的

也就是说`_objc_msgForward`在进行消息转发的过程中会涉及以下这几个方法：
 1. `resolveInstanceMethod:`方法 (或 `resolveClassMethod:`)。
 2. `forwardingTargetForSelector:`方法
 3. `methodSignatureForSelector:`方法
 4. `forwardInvocation:`方法
 5. `doesNotRecognizeSelector:` 方法

下面回答下第二个问题“直接`_objc_msgForward`调用它将会发生什么？”

直接调用`_objc_msgForward`是非常危险的事，如果用不好会直接导致程序Crash，但是如果用得好，能做很多非常酷的事。

正如前文所说：
> `_objc_msgForward`是 IMP 类型，用于消息转发的：当向一个对象发送一条消息，但它并没有实现的时候，`_objc_msgForward`会尝试做消息转发。

如何调用`_objc_msgForward`？
`_objc_msgForward`隶属 C 语言，有三个参数 ：

|--| `_objc_msgForward`参数| 类型 |
-------------|-------------|-------------
 1 | 所属对象 | id类型
 2 |方法名 | SEL类型 
 3 |可变参数 |可变参数类型


首先了解下如何调用 IMP 类型的方法，IMP类型是如下格式：

为了直观，我们可以通过如下方式定义一个 IMP类型 ：

```Objective-C
typedef void (*voidIMP)(id, SEL, ...)
```
一旦调用`_objc_msgForward`，将跳过查找 IMP 的过程，直接触发“消息转发”，

如果调用了`_objc_msgForward`，即使这个对象确实已经实现了这个方法，你也会告诉`objc_msgSend`：


> “我没有在这个对象里找到这个方法的实现”



想象下`objc_msgSend`会怎么做？通常情况下，下面这张图就是你正常走`objc_msgSend`过程，和直接调用`_objc_msgForward`的前后差别：

![https://github.com/ChenYilong](http://ww1.sinaimg.cn/bmiddle/6628711bgw1eecx3jef23g206404tkbi.gif)

有哪些场景需要直接调用`_objc_msgForward`？最常见的场景是：你想获取某方法所对应的`NSInvocation`对象。举例说明：

[JSPatch （Github 链接）](https://github.com/bang590/JSPatch)就是直接调用`_objc_msgForward`来实现其核心功能的：

>  JSPatch 以小巧的体积做到了让JS调用/替换任意OC方法，让iOS APP具备热更新的能力。


作者的博文[《JSPatch实现原理详解》](http://blog.cnbang.net/tech/2808/)详细记录了实现原理，有兴趣可以看下。

同时 [ ***RAC(ReactiveCocoa)*** ](https://github.com/ReactiveCocoa/ReactiveCocoa) 源码中也用到了该方法。

### runtime如何实现weak变量的自动置nil？


> runtime 对注册的类， 会进行布局，对于 weak 对象会放入一个 hash 表中。 用 weak 指向的对象内存地址（堆地址）作为 key，weak指针地址（栈地址）作为value。当此对象的引用计数为0的时候会 dealloc，假如 weak 指向的对象内存地址是a，那么就会以a为键， 在这个 weak 表中搜索，找到所有以a为键的 weak 对象，从而设置为 nil。

在[上篇](https://github.com/ChenYilong/iOSInterviewQuestions)中的《runtime 如何实现 weak 属性》有论述。（注：在[上篇](https://github.com/ChenYilong/iOSInterviewQuestions)的《使用runtime Associate方法关联的对象，需要在主对象dealloc的时候释放么？》里给出的“对象的内存销毁时间表”也提到`__weak`引用的解除时间。）

我们可以设计一个函数（伪代码）来表示上述机制：

`objc_storeWeak(&a, b)`函数：

`objc_storeWeak`函数把第二个参数--赋值对象（b）的内存地址作为键值key，将第一个参数--weak修饰的属性变量（a）的内存地址（&a）作为value，注册到 weak 表中。如果第二个参数（b）为0（nil），那么把变量（a）的内存地址（&a）从weak表中删除，

你可以把`objc_storeWeak(&a, b)`理解为：`objc_storeWeak(value, key)`，并且当key变nil，将value置nil。

在b非nil时，a和b指向同一个内存地址，在b变nil时，a变nil。此时向a发送消息不会崩溃：在Objective-C中向nil发送消息是安全的。

而如果a是由assign修饰的，则：
在b非nil时，a和b指向同一个内存地址，在b变nil时，a还是指向该内存地址，变野指针。此时向a发送消息会产生崩溃。

参考讨论区 ： [《有一点说的很容易误导人 #6》](https://github.com/ChenYilong/iOSInterviewQuestions/issues/6) 

下面我们将基于`objc_storeWeak(&a, b)`函数，使用伪代码模拟“runtime如何实现weak属性”：
 
```Objective-C
// 使用伪代码模拟：runtime如何实现weak属性

 id obj1;
 objc_initWeak(&obj1, obj);
/*obj引用计数变为0，变量作用域结束*/
 objc_destroyWeak(&obj1);
```

下面对用到的两个方法`objc_initWeak`和`objc_destroyWeak`做下解释：

总体说来，作用是：
通过`objc_initWeak`函数初始化“附有weak修饰符的变量（obj1）”，在变量作用域结束时通过`objc_destoryWeak`函数释放该变量（obj1）。

下面分别介绍下方法的内部实现：

`objc_initWeak`函数的实现是这样的：在将“附有weak修饰符的变量（obj1）”初始化为0（nil）后，会将“赋值对象”（obj）作为参数，调用`objc_storeWeak`函数。



 
```Objective-C
obj1 = 0；
obj_storeWeak(&obj1, obj);
```

也就是说：

>  weak 修饰的指针默认值是 nil （在Objective-C中向nil发送消息是安全的）

然后`obj_destroyWeak`函数将0（nil）作为参数，调用`objc_storeWeak`函数。

`objc_storeWeak(&obj1, 0);`

前面的源代码与下列源代码相同。
```Objective-C
// 使用伪代码模拟：runtime如何实现weak属性

id obj1;
obj1 = 0;
objc_storeWeak(&obj1, obj);
/* ... obj的引用计数变为0，被置nil ... */
objc_storeWeak(&obj1, 0);
```


`objc_storeWeak`函数把第二个参数--赋值对象（obj）的内存地址作为键值，将第一个参数--weak修饰的属性变量（obj1）的内存地址注册到 weak 表中。如果第二个参数（obj）为0（nil），那么把变量（obj1）的地址从weak表中删除。





### 能否向编译后得到的类中增加实例变量？能否向运行时创建的类中添加实例变量？为什么？ 

 - 不能向编译后得到的类中增加实例变量；
 - 能向运行时创建的类中添加实例变量；

解释下：

 - 因为编译后的类已经注册在 runtime 中，类结构体中的 `objc_ivar_list` 实例变量的链表 和 `instance_size` 实例变量的内存大小已经确定，同时runtime 会调用 `class_setIvarLayout` 或 `class_setWeakIvarLayout` 来处理 strong weak 引用。所以不能向存在的类中添加实例变量；

 - 运行时创建的类是可以添加实例变量，调用 `class_addIvar` 函数。但是得在调用 `objc_allocateClassPair` 之后，`objc_registerClassPair` 之前，原因同上。



### IBOutlet连出来的视图属性为什么可以被设置成weak?

参考链接：[ ***Should IBOutlets be strong or weak under ARC?*** ](http://stackoverflow.com/questions/7678469/should-iboutlets-be-strong-or-weak-under-arc)

文章告诉我们：

> 因为既然有外链那么视图在xib或者storyboard中肯定存在，视图已经对它有一个强引用了。


不过这个回答漏了个重要知识，使用storyboard（xib不行）创建的vc，会有一个叫`_topLevelObjectsToKeepAliveFromStoryboard` 的私有数组强引用所有 top level 的对象，所以这时即便 outlet 声明成weak也没关系

如果对本回答有疑问，欢迎参与讨论： 

- [《第52题 IBOutlet连出来的视图属性为什么可以被设置成weak? #51》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/51 ) 
- [《关于weak的一个问题 #39》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/39 ) 

### 如何调试BAD_ACCESS错误


 1. 重写object的respondsToSelector方法，现实出现EXEC_BAD_ACCESS前访问的最后一个object
 2. 通过 Zombie 
![https://github.com/ChenYilong](http://i.stack.imgur.com/ZAdi0.png)

 3. 设置全局断点快速定位问题代码所在行
 4. Xcode 7 已经集成了BAD_ACCESS捕获功能：**Address Sanitizer**。
用法如下：在配置中勾选✅Enable Address Sanitizer

### lldb（gdb）常用的调试命令？

 - breakpoint 设置断点定位到某一个函数
 - n 断点指针下一步
 - po打印对象

更多 lldb（gdb） 调试命令可查看


 1. [ ***The LLDB Debugger*** ](http://lldb.llvm.org/lldb-gdb.html)；
 2. 苹果官方文档：[ ***iOS Debugging Magic*** ](https://developer.apple.com/library/ios/technotes/tn2239/_index.html)。


### 一个NSObject对象占用多少内存空间？

结论：受限于内存分配的机制，一个 NSObject对象都会分配 16Bit 的内存空间。但是实际上在64位下，只使用了 8bit，在32位下，只使用了 4bit。
首先NSObject对象的本质是一个NSObject_IMPL结构体。我们通过以下命令将 Objecttive-C 转化为 C\C++

// 如果需要连接其他框架，可以使用 -framework 参数，例如 -framework UIKit
xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main.cpp
通过将main.m转化为main.cpp 文件可以看出它的结构包含一个isa指针：
```Objective-C
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

struct NSObject_IMPL {
    Class isa;//8
};

struct Person_IMPL {
    struct NSObject_IMPL NSObject_IVARS; // 8
    int _age; // 4
}; // 16 内存对齐：结构体的大小必须是最大成员大小的倍数

struct Student_IMPL {
    struct Person_IMPL Person_IVARS; // 16
    int _no; // 4
}; // 16

// Person
@interface Person : NSObject
{
    @public
    int _age; //4
}
@property (nonatomic, assign) int height;
@end

@implementation Person

@end

@interface Student : Person
{
    int _no; //4
}
@end

@implementation Student

@end

@interface GoodStudent : Student
{
    int _library; //4
    NSString *_value;//8
    NSString *_name; //8
}
@end

@implementation GoodStudent

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *stu = [[Student alloc] init];
        NSLog(@"stu - %zd", class_getInstanceSize([Student class])); //24：class_getInstanceSize 内存对齐：最大成员的倍数
        NSLog(@"stu - %zd", malloc_size((__bridge const void *)stu));//32：malloc_size 内存对齐：16的倍数
        
        GoodStudent *good = [[GoodStudent alloc] init];
        NSLog(@"good - %zd", class_getInstanceSize([GoodStudent class]));//40
        NSLog(@"good - %zd", malloc_size((__bridge const void *)good));//48
//
        Person *person = [[Person alloc] init];
        [person setHeight:10];
        [person height];
        person->_age = 20;
        
        Person *person1 = [[Person alloc] init];
        person1->_age = 10;
        
        
        Person *person2 = [[Person alloc] init];
        person2->_age = 30;
        
        NSLog(@"person - %zd", class_getInstanceSize([Person class])); //16 isa = 8 ， age = 4, height = 4,没有height也会是16，因为必须是8的倍数
        NSLog(@"person - %zd", malloc_size((__bridge const void *)person));//16
    }
    return 0;
}
```

### 类对象和元类对象
```Objective-C
@interface MJPerson : NSObject
{
    int _age;
    int _height;
    int _no;
}
@end

@implementation MJPerson
- (void)test {
    
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *object1 = [[NSObject alloc] init];
        NSObject *object2 = [[NSObject alloc] init];
        
        Class objectClass1 = [object1 class];
        Class objectClass2 = [object2 class];
        Class objectClass3 = object_getClass(object1);
        Class objectClass4 = object_getClass(object2);
        Class objectClass5 = [NSObject class];
        
        //元类
        Class objectMetaClass = object_getClass(objectClass5);
        
        NSLog(@"instance - %p %p\n",
              object1,
              object2);
        
        //相等，都是NSObject类对象
        NSLog(@"class - %p\n %p\n %p\n %p\n %p\n %d\n",
              objectClass1,
              objectClass2,
              objectClass3,
              objectClass4,
              objectClass5,
              class_isMetaClass(objectClass3)); //false
        
        //传入类对象，得到的肯定是元类
        NSLog(@"objectMetaClass - %hhd",class_isMetaClass(object_getClass([MJPerson class]))); //1
        NSLog(@"objectMetaClass - %hhd",class_isMetaClass(object_getClass([NSObject class]))); //1
        
        NSLog(@"%p",object_getClass(objectMetaClass)); //NSObject的元类的元类是其本身
        NSLog(@"%p",class_getSuperclass(objectMetaClass)); //NSObject的元类的父类是NSObject类对象
    }
    return 0;
}

//区别下
 1.Class objc_getClass(const char *aClassName)
 1> 传入字符串类名
 2> 返回对应的类对象
 
 2.Class object_getClass(id obj)
 1> 传入的obj可能是instance对象、class对象、meta-class对象
 2> 返回值
 a) 如果是instance对象，返回class对象
 b) 如果是class对象，返回meta-class对象
 c) 如果是meta-class对象，返回NSObject（基类）的meta-class对象
 
 3.- (Class)class、+ (Class)class
 1> 返回的就是类对象
 
 - (Class) {
     return self->isa;
 }
 
 + (Class) {
     return self;
 }


```

### isa的结构
```Objective-C
struct mj_objc_class {
    Class isa;
    Class superclass;
};

//在ARM 32位的时候，isa的类型是Class类型的，直接存储着实例对象或者类对象的地址；在ARM64结构下，isa的类型变成了共用体(union)，使用了位域去存储更多信息
//共用体中可以定义多个成员，共用体的大小由最大的成员大小决定
//共用体的成员公用一个内存
//对某一个成员赋值，会覆盖其他成员的值
//存储效率更高
union isa_t
{
    Class cls;
    uintptr_t bits;   //存储下面结构体每一位的值
    struct {
        uintptr_t nonpointer        : 1;  // 0:普通指针，存储Class、Meta-Class；1:存储更多信息(TaggedPointer指针)
        uintptr_t has_assoc         : 1;  // 有没有关联对象
        uintptr_t has_cxx_dtor      : 1;  // 有没有C++的析构函数（.cxx_destruct）
        uintptr_t shiftcls          : 33; // 存储Class、Meta-Class的内存地址
        uintptr_t magic             : 6;  // 调试时分辨对象是否初始化用
        uintptr_t weakly_referenced : 1;  // 有没有被弱引用过
        uintptr_t deallocating      : 1;  // 正在释放
        uintptr_t has_sidetable_rc  : 1;  //0:引用计数器在isa中；1:引用计数器存在SideTable
        uintptr_t extra_rc          : 19; // 引用计数器-1
    };
};

//Tagged Pointer的优化：
//Tagged Pointer专门用来存储小的对象，例如NSNumber, NSDate, NSString。
//Tagged Pointer指针的值不再是地址了，而是真正的值。所以，实际上它不再是一个对象了，它只是一个披着对象皮的普通变量而已。所以，它的内存并不存储在堆中，也不需要malloc和free。
//在内存读取上有着3倍的效率，创建时比以前快106倍。
//例如：1010，其中最高位1xxx表明这是一个tagged pointer，而剩下的3位010，表示了这是一个NSString类型。010转换为十进制即为2。也就是说，标志位是2的tagger
//pointer表示这是一个NSString对象。

//SEL，方法选择器，本质上是一个C字符串  IMP，函数指针，函数的执行入口  Method，类型，结构体，里面有SEL和IMP
/// Method
struct objc_method {
    SEL method_name;
    char *method_types;
    IMP method_imp;
 };

struct method_t {
    SEL name; //函数名
    const char *types; //编码（返回值类型、参数类型）
    IMP imp;//指向函数的指针（函数地址），IMP本身地址是在栈/堆上，指向的地址就是函数实现，一般在代码区/数据段
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // MJPerson类对象的地址：0x00000001000014c8
        // isa & ISA_MASK：0x00000001000014c8
        
        // MJPerson实例对象的isa：0x001d8001000014c9
        
        struct mj_objc_class *personClass = (__bridge struct mj_objc_class *)([MJPerson class]);
        
        struct mj_objc_class *studentClass = (__bridge struct mj_objc_class *)([MJStudent class]);
        
        NSLog(@"1111");
        
        MJPerson *person = [[MJPerson alloc] init];
        Class personClass1 = [MJPerson class];
        struct mj_objc_class *personClass2 = (__bridge struct mj_objc_class *)(personClass1);
        Class personMetaClass = object_getClass(personClass1);
        NSLog(@"%p %p %p", person, personClass1, personMetaClass);
        MJStudent *student = [[MJStudent alloc] init];
    }
    return 0;
}
```


### class的结构

方法调用轨迹：

![1653926-120b85207083df9c.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ba8c0651157f4add9a3ccd5b080075a7~tplv-k3u1fbpfcp-watermark.image?)

```Objective-C
#ifndef MJClassInfo_h
#define MJClassInfo_h

# if __arm64__
#   define ISA_MASK        0x0000000ffffffff8ULL
# elif __x86_64__
#   define ISA_MASK        0x00007ffffffffff8ULL
# endif

#if __LP64__
typedef uint32_t mask_t;
#else
typedef uint16_t mask_t;
#endif
typedef uintptr_t cache_key_t;

struct bucket_t { //桶
    cache_key_t _key;//方法查找的key
    IMP _imp; //方法实现
};

struct cache_t { //方法缓存
    bucket_t *_buckets;//缓存的方法列表
    mask_t _mask; //掩码
    mask_t _occupied;//已经存入的方法缓存数量 - 1
};

struct entsize_list_tt { //列表
    uint32_t entsizeAndFlags;
    uint32_t count;
};

struct method_t { //方法
    SEL name;//选择器
    const char *types;//编码
    IMP imp;//函数实现地址
};

struct method_list_t : entsize_list_tt { //方法列表
    method_t first;
};

struct ivar_t { //成员变量
    int32_t *offset; //偏移量
    const char *name;//名称
    const char *type;//类型
    uint32_t alignment_raw;
    uint32_t size;//大小
};

struct ivar_list_t : entsize_list_tt { //成员变量列表
    ivar_t first;
};

struct property_t { //属性
    const char *name; //属性名
    const char *attributes; //属性特性
};

struct property_list_t : entsize_list_tt { //属性列表
    property_t first;
};

struct chained_property_list { //属性链表
    chained_property_list *next;
    uint32_t count;
    property_t list[0];
};

typedef uintptr_t protocol_ref_t;
struct protocol_list_t {
    uintptr_t count; //属性数量
    protocol_ref_t list[0];
};


struct class_ro_t { //只读。这部分信息在类加载时就被确定，并且在运行时不会发生改变。
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;  // instance对象占用的内存空间
#ifdef __LP64__
    uint32_t reserved;
#endif
    const uint8_t * ivarLayout;
    const char * name;  // 类名
    method_list_t * baseMethodList; //基本的方法列表
    protocol_list_t * baseProtocols; //基础的协议列表
    const ivar_list_t * ivars;  // 成员变量列表
    const uint8_t * weakIvarLayout; //weak成员变量布局
    property_list_t *baseProperties;//基础属性列表
};

struct class_rw_t { //可读可写
    uint32_t flags;
    uint32_t version;
    const class_ro_t *ro; //只读
    method_list_t * methods;    // 方法列表
    property_list_t *properties;    // 属性列表
    const protocol_list_t * protocols;  // 协议列表
    Class firstSubclass;
    Class nextSiblingClass;
    char *demangledName;
};

#define FAST_DATA_MASK          0x00007ffffffffff8UL
struct class_data_bits_t {
    uintptr_t bits;
public:
    class_rw_t* data() { //可读可写的地址是通过位运算查找到的
        return (class_rw_t *)(bits & FAST_DATA_MASK);
    }
};

/* OC对象 */
struct mj_objc_object {
    void *isa;
};

/* 类对象 */
struct mj_objc_class : mj_objc_object {
    Class superclass; //父类
    cache_t cache; //缓存
    class_data_bits_t bits;//类信息
public:
    class_rw_t* data() { //可读可写
        return bits.data();
    }
    
    mj_objc_class* metaClass() { //元类
        return (mj_objc_class *)((long long)isa & ISA_MASK);
    }
};


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJStudent *stu = [[MJStudent alloc] init];
        stu->_weight = 10;
        
        mj_objc_class *studentClass = (__bridge mj_objc_class *)([MJStudent class]);
        mj_objc_class *personClass = (__bridge mj_objc_class *)([MJPerson class]);
        
        class_rw_t *studentClassData = studentClass->data();
        class_rw_t *personClassData = personClass->data();
        
        class_rw_t *studentMetaClassData = studentClass->metaClass()->data();
        class_rw_t *personMetaClassData = personClass->metaClass()->data();
    }
    return 0;
}


#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Person.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //类对象
        NSObject *obj1 = [[NSObject alloc] init];
        NSObject *obj2 = [[NSObject alloc] init];
        Class c1 = [obj1 class];
        Class c2 = [obj2 class];
        Class c3 = [NSObject class];
        Class c4 = object_getClass(obj1);
        Class c5 = object_getClass(obj2);
        
        NSLog(@"obj1 = %p",obj1); //0x1012acb10
        NSLog(@"obj2 = %p",obj2);//0x1012ac880
        NSLog(@"c1 = %p",c1); //0x1fc49ffc8
        NSLog(@"c2 = %p",c2);//0x1fc49ffc8
        NSLog(@"c3 = %p",c3);//0x1fc49ffc8
        NSLog(@"c4 = %p",c4);//0x1fc49ffc8
        NSLog(@"c5 = %p",c5);//0x1fc49ffc8
        
        
        NSLog(@"--------------------------------------------");
        
        NSObject *obj3 = [[NSObject alloc] init];
        Class cls1 = object_getClass([NSObject class]); //元类地址0x1fc49ffa0
        Class cls2 = [[NSObject class] class]; //类地址0x1fc49ffc8
        Class cls3 = [[obj3 class] class];//类地址0x1fc49ffc8
        NSLog(@"cls1 = %p,cls2 = %p,cls3 = %p",cls1 ,cls2,cls3);
        
        
        NSLog(@"--------------------------------------------");
        
       
        Person *p           = [[Person alloc] init];
        Class  class1       = object_getClass(p); // 获取p ---> 类对象
        Class  class2       = [p class];  // 获取p ---> 类对象
        NSLog(@"class1 === %p class1Name == %@ class2 === %p class2Name == %@",class1,class1,class2,class2);
        
        /** 元类查找过程 */
        Class  class3       = objc_getMetaClass(object_getClassName(p)); // 获取p ---> 元类
        NSLog(@"class3 == %p class3Name == %@ class3 is  MetaClass:%d",class3,class3,class_isMetaClass(class3));//1
        
        Class  class4       = objc_getMetaClass(object_getClassName(class3)); // 获取class3 ---> 元类  此时的元类，class4就是根元类。
        NSLog(@"class4 == %p class4Name == %@",class4,class4); // class4 == 0x106defe78 class4Name == NSObject
        
        
        /** 元类查找结束，至此。我们都知道 根元类 的superClass指针是指向 根类对象 的；根类对象的isa指针有指向根元类对象；根元类对象的isa指针指向根元类自己；根类对象的superClass指针指向nil */
        Class  class5       = class_getSuperclass(class1);  // 获取 类对象的父类对象
        NSLog(@"class5 == %p class5Name == %@",class5,class5);  //class5 == 0x106defec8 class5Name == NSObject

        // 此时返现class5 已经是NSObject，我们再次获取class5的父类，验证class5是否是 根类对象
        Class  class6       = class_getSuperclass(class5);  // 获取 class5的父类对象
        NSLog(@"class6 == %p class6Name == %@",class6,class6); // class6 == 0x0 class6Name == (null) 至此根类对象验证完毕。
        
        
        /** 验证根类对象与根元类对象的关系 */
        Class  class7       = objc_getMetaClass(object_getClassName(class5)); // 获取根类对象 对应的  根元类 是否是class4 对应的指针地址
        NSLog(@"class7 == %p class7Name == %@",class7,class7);  // class7 == 0x106defe78 class7Name == NSObject
        
        Class  class8      =  class_getSuperclass(class4);  // 获取根元类class4  superClass 指针的指向 是否是根类对象class5 的指针地址
        NSLog(@"class8 == %p class8Name == %@",class8,class8);  // class8 == 0x106defec8 class8Name == NSObject； class8与class5指针地址相同
        
        Class  class9       = objc_getMetaClass(object_getClassName(class4)); // 获取根元类 isa 指针是否是指向自己
        NSLog(@"class9 == %p class9Name == %@",class9,class9);  //  class9 == 0x106defe78 class9Name == NSObject； class9 与 class4、class7指针地址相同
    }
    return 0;
}

```


### class结构中为什么要区分class_ro_t和class_rw_t开来？
在Objective-C的类结构中，分为class_ro_t（只读）和class_rw_t（可读写）这两个部分的目的是为了在运行时实现类的信息共享和写时复制。

class_ro_t是只读的部分，其中包含了类的静态信息，例如类的名称、父类、成员变量、属性、方法列表等。这部分信息在类加载时就被确定，并且在运行时不会发生改变。因此，将这部分信息定义为只读的可以确保类的静态信息不被修改。

class_rw_t是可读写的部分，其中包含了类的动态信息，例如方法缓存、协议列表等。这部分信息在类运行时可以进行修改和更新，例如添加新的方法、替换现有的方法实现等。通过将这部分信息定义为可读写的，可以在运行时动态地修改类的行为和功能。

此外，将类的信息分为只读和可读写两个部分还有助于实现类的写时复制（copy-on-write）机制。当一个类被复制（例如通过class_copyClassList函数或者使用objc_duplicateClass函数显式复制类时），只会复制class_ro_t部分的信息，而不会复制class_rw_t部分。这样，多个类对象可以共享相同的只读信息，而每个类对象都拥有自己的可读写信息，从而实现了内存的节省和高效的类复制操作。

总结起来，通过将类的信息分为只读和可读写两个部分，可以确保类的静态信息在运行时不被修改，同时允许类的动态信息在运行时进行修改。这种设计还有助于实现类的信息共享和写时复制机制，提供了更高效和灵活的类操作方式。

### 为什么在OC类中这两种写法都可以？使用C函数的场景有哪些？

```
- (NSString *)powerTipsImageName {
return @"devicemanager_adddevice_power_supply_n_gateway";
}

NSString * powerTipsImageName() {
return @"";
}

```
Objective-C的编译器在处理Objective-C类的实现时，会同时处理Objective-C方法和C函数的定义。因此，在Objective-C类的实现中，既可以定义Objective-C方法，也可以定义C函数，两者是并存的。 
使用C语言场景：
1.独立性和复用性：如果某个功能或操作不依赖于任何特定的类或对象，且可以在多个地方被复用，那么将其实现为C函数是更合适的选择。C函数可以在不同的上下文中被调用，而不需要与特定的类或对象绑定。

2.性能考虑：C语言是一种较为底层的语言，直接操作内存和执行指针操作，因此在对性能要求较高的场景下，使用C函数可以获得更好的执行效率。相比之下，Objective-C方法涉及到Objective-C运行时的消息传递和动态派发等机制，可能会引入一定的性能开销


### 为什么__bridge可以桥接OC对象和C的结构体。内部做了什么？
__bridge关键字本身并不会进行任何数据的拷贝或转换，而是提供了一个安全的类型转换标记，用于告诉编译器如何对待对象和结构体之间的转换时，不需要进行额外的内存管理或数据拷贝操作。这意味着桥接的操作非常轻量，不会对对象的引用计数或结构体的数据进行修改。并假定开发人员已经正确处理了类型的兼容性和生命周期管理。


