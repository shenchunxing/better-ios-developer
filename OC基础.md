
 1.  [objc中向一个nil对象发送消息将会发生什么？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#objc中向一个nil对象发送消息将会发生什么) 
 2.  [objc中向一个对象发送消息[obj foo]和objc_msgSend()函数之间有什么关系？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#objc中向一个对象发送消息obj-foo和objc_msgsend函数之间有什么关系) 
 3.  [什么时候会报unrecognized selector的异常？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#什么时候会报unrecognized-selector的异常) 
 4.  [一个objc对象如何进行内存布局？（考虑有父类的情况）](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#一个objc对象如何进行内存布局考虑有父类的情况) 
 5. [一个objc对象的isa的指针指向什么？有什么作用？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#一个objc对象的isa的指针指向什么有什么作用)
 6.  [下面的代码输出什么？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#下面的代码输出什么) 


 ```Objective-C
    @implementation Son : Father
    - (id)init
    {
        self = [super init];
        if (self) {
            NSLog(@"%@", NSStringFromClass([self class]));
            NSLog(@"%@", NSStringFromClass([super class]));
        }
        return self;
    }
    @end
 ```

 
 7.  [runtime如何通过selector找到对应的IMP地址？（分别考虑类方法和实例方法）](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#runtime如何通过selector找到对应的IMP地址) 
 8.  [使用runtime Associate方法关联的对象，需要在主对象dealloc的时候释放么？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#使用runtime的Associate方法关联的对象,需要在主对象dealloc的时候释放么) 
 9.  [objc中的类方法和实例方法有什么本质区别和联系？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#objc中的类方法和实例方法有什么本质区别和联系) 
 
 10. [`_objc_msgForward` 函数是做什么的，直接调用它将会发生什么？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#_objc_msgforward函数是做什么的直接调用它将会发生什么)
 11. [runtime如何实现weak变量的自动置nil？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#runtime如何实现weak变量的自动置nil)
 12.  [能否向编译后得到的类中增加实例变量？能否向运行时创建的类中添加实例变量？为什么？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#能否向编译后得到的类中增加实例变量能否向运行时创建的类中添加实例变量为什么) 
 
 13.  [addObserver:forKeyPath:options:context:各个参数的作用分别是什么，observer中需要实现哪个方法才能获得KVO回调？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#addobserverforkeypathoptionscontext各个参数的作用分别是什么observer中需要实现哪个方法才能获得kvo回调) 
 14.  [如何手动触发一个value的KVO](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#46-如何手动触发一个value的kvo) 
 15.  [若一个类有实例变量 NSString *_foo ，调用setValue:forKey:时，可以以foo还是 _foo 作为key？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#若一个类有实例变量-nsstring-_foo-调用setvalueforkey时可以以foo还是-_foo-作为key) 
 16.  [KVC的keyPath中的集合运算符如何使用？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#kvc的keypath中的集合运算符如何使用) 
 17.  [KVC和KVO的keyPath一定是属性么？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#kvc和kvo的keypath一定是属性么) 
 18.  [如何关闭默认的KVO的默认实现，并进入自定义的KVO实现？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#如何关闭默认的kvo的默认实现并进入自定义的kvo实现) 
 19.  [apple用什么方式实现对一个对象的KVO？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#apple用什么方式实现对一个对象的kvo) 
 20.  [IBOutlet连出来的视图属性为什么可以被设置成weak?](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#iboutlet连出来的视图属性为什么可以被设置成weak) 
 21.  [IB中User Defined Runtime Attributes如何使用？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#ib中user-defined-runtime-attributes如何使用) 
 22.  [如何调试BAD_ACCESS错误](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#如何调试bad_access错误) 
 23.  [lldb（gdb）常用的调试命令？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#lldbgdb常用的调试命令) 
 
  [一个 NSObject对象占用多少内存空间？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#一个NSObject对象占用多少内存空间)
  
  [类对象和元类对象？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#类对象和元类对象)
  
  [isa的结构？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#isa的结构)
  
  [class的结构？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#class的结构)
  
  [通知的原理？](https://github.com/shenchunxing/ios_interview_questions/blob/master/OC基础.md#通知的原理)

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
// http://weibo.com/luohanchenyilong/
// https://github.com/ChenYilong

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

### objc中向一个对象发送消息[obj foo]和`objc_msgSend()`函数之间有什么关系？
具体原因同上题：该方法编译之后就是`objc_msgSend()`函数调用.

我们用 clang 分析下，clang 提供一个命令，可以将Objective-C的源码改写成C++语言，借此可以研究下[obj foo]和`objc_msgSend()`函数之间有什么关系。

以下面的代码为例，由于 clang 后的代码达到了10万多行，为了便于区分，添加了一个叫 iOSinit 方法，

```Objective-C
//
//  main.m
//  http://weibo.com/luohanchenyilong/
//  https://github.com/ChenYilong
//  Copyright (c) 2015年 微博@iOS程序犭袁. All rights reserved.
//


#import "CYLTest.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        CYLTest *test = [[CYLTest alloc] init];
        [test performSelector:(@selector(iOSinit))];
        return 0;
    }
}
```

在终端中输入

```Objective-C
clang -rewrite-objc main.m
```
就可以生成一个`main.cpp`的文件，在最低端（10万4千行左右）

![https://github.com/ChenYilong](http://i.imgur.com/eAH5YWn.png)

我们可以看到大概是这样的：

 
```Objective-C
((void ()(id, SEL))(void )objc_msgSend)((id)obj, sel_registerName("foo"));
```

也就是说：

>  [obj foo];在objc编译时，会被转意为：`objc_msgSend(obj, @selector(foo));`。

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

每个 Objective-C 对象都有相同的结构，如下图所示：

 ![https://github.com/ChenYilong](http://i.imgur.com/7mJlUj1.png)

翻译过来就是

|  Objective-C 对象的结构图 | 
 ------------- |
 ISA指针 |
 根类的实例变量 |
 倒数第二层父类的实例变量 |
 ... |
 父类的实例变量 |
 类的实例变量 | 


 - 根对象就是NSObject，它的superclass指针指向nil

 - 类对象既然称为对象，那它也是一个实例。类对象中也有一个isa指针指向它的元类(meta class)，即类对象是元类的实例。元类内部存放的是类方法列表，根元类的isa指针指向自己，superclass指针指向NSObject类。
 -  类对象 是放在数据段(数据区)上的, 和全局变量放在一个地方. 这也就是为什么: 同一个类对象的不同实例对象,的isa指针是一样的.
 -  实例对象存放在堆中



如图:
![https://github.com/ChenYilong](http://i.imgur.com/w6tzFxz.png)

### 一个objc对象的isa的指针指向什么？有什么作用？
`isa` 顾名思义 `is a` 表示对象所属的类。

`isa` 指向他的类对象，从而可以找到对象上的方法。

同一个类的不同对象，他们的 isa 指针是一样的。

### 下面的代码输出什么？




 ```Objective-C
    @implementation Son : Father
    - (id)init
    {
        self = [super init];
        if (self) {
            NSLog(@"%@", NSStringFromClass([self class]));
            NSLog(@"%@", NSStringFromClass([super class]));
        }
        return self;
    }
    @end
 ```


**答案：**

都输出 Son

    NSStringFromClass([self class]) = Son
    NSStringFromClass([super class]) = Son
 


这个题目主要是考察关于 Objective-C 中对 self 和 super 的理解。
 
super关键字，有以下几点需要注意：
- receiver还是当前类对象，而不是父类对象；
- super这里的含义就是优先去父类的方法列表中去查实现，很多问题都是父类中其实也没有实现，还是去根类里 去找实现，这种情况下时，其实跟直接调用self的效果是一致的。

下面做详细介绍:

我们都知道：self 是类的隐藏参数，指向当前调用方法的这个类的实例。那 super 呢？

很多人会想当然的认为“ super 和 self 类似，应该是指向父类的指针吧！”。这是很普遍的一个误区。其实 super 是一个 Magic Keyword， 它本质是一个编译器标示符，和 self 是指向的同一个消息接受者！他们两个的不同点在于：super 会告诉编译器，调用 class 这个方法时，要去父类的方法，而不是本类里的。


上面的例子不管调用`[self class]`还是`[super class]`，接受消息的对象都是当前 `Son ＊xxx` 这个对象。

当使用 self 调用方法时，会从当前类的方法列表中开始找，如果没有，就从父类中再找；而当使用 super 时，则从父类的方法列表中开始找。然后调用父类的这个方法。


这也就是为什么说“不推荐在 init 方法中使用点语法”，如果想访问实例变量 iVar 应该使用下划线（ `_iVar` ），而非点语法（ `self.iVar` ）。

点语法（ `self.iVar` ）的坏处就是子类有可能覆写 setter 。假设 Person 有一个子类叫 ChenPerson，这个子类专门表示那些姓“陈”的人。该子类可能会覆写 lastName 属性所对应的设置方法：

 ```Objective-C
//
//  ChenPerson.m
//  
//
//  Created by https://github.com/ChenYilong on 15/8/30.
//  Copyright (c) 2015年 http://weibo.com/luohanchenyilong/ 微博@iOS程序犭袁. All rights reserved.
//

#import "ChenPerson.h"

@implementation ChenPerson

@synthesize lastName = _lastName;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"🔴类名与方法名：%s（在第%d行），描述：%@", __PRETTY_FUNCTION__, __LINE__, NSStringFromClass([self class]));
        NSLog(@"🔴类名与方法名：%s（在第%d行），描述：%@", __PRETTY_FUNCTION__, __LINE__, NSStringFromClass([super class]));
    }
    return self;
}

- (void)setLastName:(NSString*)lastName
{
    //设置方法一：如果setter采用是这种方式，就可能引起崩溃
//    if (![lastName isEqualToString:@"陈"])
//    {
//        [NSException raise:NSInvalidArgumentException format:@"姓不是陈"];
//    }
//    _lastName = lastName;
    
    //设置方法二：如果setter采用是这种方式，就可能引起崩溃
    _lastName = @"陈";
    NSLog(@"🔴类名与方法名：%s（在第%d行），描述：%@", __PRETTY_FUNCTION__, __LINE__, @"会调用这个方法,想一下为什么？");

}

@end
 ```

在基类 Person 的默认初始化方法中，可能会将姓氏设为空字符串。此时若使用点语法（ `self.lastName` ）也即 setter 设置方法，那么调用将会是子类的设置方法，如果在刚刚的 setter 代码中采用设置方法一，那么就会抛出异常，


为了方便采用打印的方式展示，究竟发生了什么，我们使用设置方法二。


如果基类的代码是这样的：


 ```Objective-C
//
//  Person.m
//  nil对象调用点语法
//
//  Created by https://github.com/ChenYilong on 15/8/29.
//  Copyright (c) 2015年 http://weibo.com/luohanchenyilong/ 微博@iOS程序犭袁. All rights reserved.
//  

#import "Person.h"

@implementation Person

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lastName = @"";
        //NSLog(@"🔴类名与方法名：%s（在第%d行），描述：%@", __PRETTY_FUNCTION__, __LINE__, NSStringFromClass([self class]));
        //NSLog(@"🔴类名与方法名：%s（在第%d行），描述：%@", __PRETTY_FUNCTION__, __LINE__, self.lastName);
    }
    return self;
}

- (void)setLastName:(NSString*)lastName
{
    NSLog(@"🔴类名与方法名：%s（在第%d行），描述：%@", __PRETTY_FUNCTION__, __LINE__, @"根本不会调用这个方法");
    _lastName = @"炎黄";
}

@end
 ```

那么打印结果将会是这样的：

 ```Objective-C
 🔴类名与方法名：-[ChenPerson setLastName:]（在第36行），描述：会调用这个方法,想一下为什么？
 🔴类名与方法名：-[ChenPerson init]（在第19行），描述：ChenPerson
 🔴类名与方法名：-[ChenPerson init]（在第20行），描述：ChenPerson
 ```

我在仓库里也给出了一个相应的 Demo（名字叫：Demo_21题_下面的代码输出什么）。有兴趣可以跑起来看一下，主要看下他是怎么打印的，思考下为什么这么打印。

如果对这个例子有疑问：可以参与讨论区讨论 [《21题“不推荐在 init 方法中使用点语法” #75》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/75 ) 

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

 - 在ARC下不需要。
 - <p><del> 在MRC中,对于使用retain或copy策略的需要 。</del></p>在MRC下也不需要

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





### objc中的类方法和实例方法有什么本质区别和联系?

类方法：

 1. 类方法是属于类对象的
 2. 类方法只能通过类对象调用
 2. 类方法中的self是类对象
 2. 类方法可以调用其他的类方法
 2. 类方法中不能访问成员变量
 2. 类方法中不能直接调用对象方法

实例方法：

 1. 实例方法是属于实例对象的
 2. 实例方法只能通过实例对象调用
 2. 实例方法中的self是实例对象
 2. 实例方法中可以访问成员变量
 2. 实例方法中直接调用实例方法
 2. 实例方法中也可以调用类方法(通过类名)

### `_objc_msgForward`函数是做什么的，直接调用它将会发生什么？

> `_objc_msgForward`是 IMP 类型，用于消息转发的：当向一个对象发送一条消息，但它并没有实现的时候，`_objc_msgForward`会尝试做消息转发。

我们可以这样创建一个`_objc_msgForward`对象：

    IMP msgForwardIMP = _objc_msgForward;



在[上篇](https://github.com/ChenYilong/iOSInterviewQuestions)中的《objc中向一个对象发送消息`[obj foo]`和`objc_msgSend()`函数之间有什么关系？》曾提到`objc_msgSend`在“消息传递”中的作用。在“消息传递”过程中，`objc_msgSend`的动作比较清晰：首先在 Class 中的缓存查找 IMP （没缓存则初始化缓存），如果没找到，则向父类的 Class 查找。如果一直查找到根类仍旧没有实现，则用`_objc_msgForward`函数指针代替 IMP 。最后，执行这个 IMP 。



Objective-C运行时是开源的，所以我们可以看到它的实现。打开[ ***Apple Open Source 里Mac代码里的obj包*** ](http://www.opensource.apple.com/tarballs/objc4/)下载一个最新版本，找到 `objc-runtime-new.mm`，进入之后搜索`_objc_msgForward`。

![https://github.com/ChenYilong](http://i.imgur.com/rGBfaoL.png)

里面有对`_objc_msgForward`的功能解释：

![https://github.com/ChenYilong](http://i.imgur.com/vcThcdA.png)


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
//  Created by https://github.com/ChenYilong
//  Copyright (c)  微博@iOS程序犭袁(http://weibo.com/luohanchenyilong/). All rights reserved.
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

以第二种为例，操作如下所示：

![https://github.com/ChenYilong](http://i.imgur.com/uEwTCC4.png)


之后，运行时发送的所有消息都会打印到`/tmp/msgSend-xxxx`文件里了。

终端中输入命令前往：

```Objective-C
open /private/tmp
```





![https://github.com/ChenYilong](http://i.imgur.com/Fh5hhCw.png)



可能看到有多条，找到最新生成的，双击打开



在模拟器上执行执行以下语句（这一套调试方案仅适用于模拟器，真机不可用，关于该调试方案的拓展链接：[ ***Can the messages sent to an object in Objective-C be monitored or printed out?*** ](http://stackoverflow.com/a/10750398/3395008)），向一个对象发送一条错误的消息：




```Objective-C
//
//  main.m
//  CYLObjcMsgForwardTest
//
//  Created by http://weibo.com/luohanchenyilong/.
//  Copyright (c) 2015年 微博@iOS程序犭袁. All rights reserved.
//

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

![https://github.com/ChenYilong](http://i.imgur.com/UjbmVvB.png)


你可以在`/tmp/msgSend-xxxx`（我这一次是`/tmp/msgSend-9805`）文件里，看到打印出来：



![https://github.com/ChenYilong](http://i.imgur.com/AAERz1T.png)


 
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

为了能更清晰地理解这些方法的作用，git仓库里也给出了一个Demo，名称叫“ `_objc_msgForward_demo` ”,可运行起来看看。


下面回答下第二个问题“直接`_objc_msgForward`调用它将会发生什么？”

直接调用`_objc_msgForward`是非常危险的事，如果用不好会直接导致程序Crash，但是如果用得好，能做很多非常酷的事。

就好像跑酷，干得好，叫“耍酷”，干不好就叫“作死”。

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


> runtime 对注册的类， 会进行布局，对于 weak 对象会放入一个 hash 表中。 用 weak 指向的对象内存地址作为 key，当此对象的引用计数为0的时候会 dealloc，假如 weak 指向的对象内存地址是a，那么就会以a为键， 在这个 weak 表中搜索，找到所有以a为键的 weak 对象，从而设置为 nil。

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
// http://weibo.com/luohanchenyilong/
// https://github.com/ChenYilong

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
// http://weibo.com/luohanchenyilong/
// https://github.com/ChenYilong

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

### addObserver:forKeyPath:options:context:各个参数的作用分别是什么，observer中需要实现哪个方法才能获得KVO回调？

```Objective-C
// 添加键值观察
/*
1 观察者，负责处理监听事件的对象
2 观察的属性
3 观察的选项
4 上下文
*/
[self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:@"Person Name"];
```
observer中需要实现一下方法：



```Objective-C
// 所有的 kvo 监听到事件，都会调用此方法
/*
 1. 观察的属性
 2. 观察的对象
 3. change 属性变化字典（新／旧）
 4. 上下文，与监听的时候传递的一致
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;
```

### 如何手动触发一个value的KVO

所谓的“手动触发”是区别于“自动触发”：

自动触发是指类似这种场景：在注册 KVO 之前设置一个初始值，注册之后，设置一个不一样的值，就可以触发了。

想知道如何手动触发，必须知道自动触发 KVO 的原理：

键值观察通知依赖于 NSObject 的两个方法:  `willChangeValueForKey:` 和 `didChangevlueForKey:` 。在一个被观察属性发生改变之前，  `willChangeValueForKey:` 一定会被调用，这就
会记录旧的值。而当改变发生后，  `observeValueForKey:ofObject:change:context:` 会被调用，继而 `didChangeValueForKey:` 也会被调用。如果可以手动实现这些调用，就可以实现“手动触发”了。

那么“手动触发”的使用场景是什么？一般我们只在希望能控制“回调的调用时机”时才会这么做。

具体做法如下：



如果这个  `value` 是  表示时间的 `self.now` ，那么代码如下：最后两行代码缺一不可。

相关代码已放在仓库里。

 ```Objective-C
//  .m文件
//  Created by https://github.com/ChenYilong
//  微博@iOS程序犭袁(http://weibo.com/luohanchenyilong/).
//  手动触发 value 的KVO，最后两行代码缺一不可。

//@property (nonatomic, strong) NSDate *now;
- (void)viewDidLoad {
    [super viewDidLoad];
    _now = [NSDate date];
    [self addObserver:self forKeyPath:@"now" options:NSKeyValueObservingOptionNew context:nil];
    NSLog(@"1");
    [self willChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
    NSLog(@"2");
    [self didChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
    NSLog(@"4");
}
 ```

但是平时我们一般不会这么干，我们都是等系统去“自动触发”。“自动触发”的实现原理：


 > 比如调用 `setNow:` 时，系统还会以某种方式在中间插入 `wilChangeValueForKey:` 、  `didChangeValueForKey:` 和 `observeValueForKeyPath:ofObject:change:context:` 的调用。


大家可能以为这是因为 `setNow:` 是合成方法，有时候我们也能看到有人这么写代码:

 ```Objective-C
- (void)setNow:(NSDate *)aDate {
    [self willChangeValueForKey:@"now"]; // 没有必要
    _now = aDate;
    [self didChangeValueForKey:@"now"];// 没有必要
}
 ```

这完全没有必要，不要这么做，这样的话，KVO代码会被调用两次。KVO在调用存取方法之前总是调用 `willChangeValueForKey:`  ，之后总是调用 `didChangeValueForkey:` 。怎么做到的呢?答案是通过 isa 混写（isa-swizzling）。下文《apple用什么方式实现对一个对象的KVO？》会有详述。


其中会触发两次，具体原因可以查看文档[Apple document : Key-Value Observing Programming Guide-Manual Change Notification]( https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOCompliance.html#//apple_ref/doc/uid/20002178-SW3 "") ，主要是 `+automaticallyNotifiesObserversForKey:` 类方法了。



参考链接： [Manual Change Notification---Apple 官方文档](https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOCompliance.html#//apple_ref/doc/uid/20002178-SW3) 

### 若一个类有实例变量 `NSString *_foo` ，调用setValue:forKey:时，可以以foo还是 `_foo` 作为key？
都可以。
### KVC的keyPath中的集合运算符如何使用？

 1. 必须用在集合对象上或普通对象的集合属性上
 2. 简单集合运算符有@avg， @count ， @max ， @min ，@sum，
 3. 格式 @"@sum.age"或 @"集合属性.@max.age"

### KVC和KVO的keyPath一定是属性么？

KVC 支持实例变量，KVO 只能手动支持[手动设定实例变量的KVO实现监听](https://yq.aliyun.com/articles/30483)

![图片](/图片/kvc1.png)
![图片](/图片/kvc2.png)


### 如何关闭默认的KVO的默认实现，并进入自定义的KVO实现？


请参考：

  1. [《如何自己动手实现 KVO》](http://tech.glowing.com/cn/implement-kvo/)
  2. [**KVO for manually implemented properties**]( http://stackoverflow.com/a/10042641/3395008 ) 

### apple用什么方式实现对一个对象的KVO？ 



[Apple 的文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html)对 KVO 实现的描述：

 > Automatic key-value observing is implemented using a technique called isa-swizzling... When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class ...

从[Apple 的文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html)可以看出：Apple 并不希望过多暴露 KVO 的实现细节。不过，要是借助 runtime 提供的方法去深入挖掘，所有被掩盖的细节都会原形毕露：

 > 当你观察一个对象时，一个新的类会被动态创建。这个类继承自该对象的原本的类，并重写了被观察属性的 setter 方法。重写的 setter 方法会负责在调用原 setter 方法之前和之后，通知所有观察对象：值的更改。最后通过 ` isa 混写（isa-swizzling）` 把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就神奇的变成了新创建的子类的实例。我画了一张示意图，如下所示：


<p align="center"><a href="https://mp.weixin.qq.com/s/A4e5h3xgIEh6PInf1Rjqsw"><img src="https://tva1.sinaimg.cn/large/007S8ZIlly1gfec69ggukj30qh0fvjta.jpg"></a></p>


 KVO 确实有点黑魔法：


 > Apple 使用了 ` isa 混写（isa-swizzling）`来实现 KVO 。


下面做下详细解释：

键值观察通知依赖于 NSObject 的两个方法:  `willChangeValueForKey:` 和 `didChangevlueForKey:` 。在一个被观察属性发生改变之前，  `willChangeValueForKey:` 一定会被调用，这就会记录旧的值。而当改变发生后， `observeValueForKey:ofObject:change:context:` 会被调用，继而  `didChangeValueForKey:` 也会被调用。可以手动实现这些调用，但很少有人这么做。一般我们只在希望能控制回调的调用时机时才会这么做。大部分情况下，改变通知会自动调用。

 比如调用 `setNow:` 时，系统还会以某种方式在中间插入 `wilChangeValueForKey:` 、  `didChangeValueForKey:`  和 `observeValueForKeyPath:ofObject:change:context:` 的调用。大家可能以为这是因为 `setNow:` 是合成方法，有时候我们也能看到有人这么写代码:

 ```Objective-C
- (void)setNow:(NSDate *)aDate {
    [self willChangeValueForKey:@"now"]; // 没有必要
    _now = aDate;
    [self didChangeValueForKey:@"now"];// 没有必要
}
 ```

这完全没有必要，不要这么做，这样的话，KVO代码会被调用两次。KVO在调用存取方法之前总是调用 `willChangeValueForKey:`  ，之后总是调用 `didChangeValueForkey:` 。怎么做到的呢?答案是通过 isa 混写（isa-swizzling）。第一次对一个对象调用 `addObserver:forKeyPath:options:context:` 时，框架会创建这个类的新的 KVO 子类，并将被观察对象转换为新子类的对象。在这个 KVO 特殊子类中， Cocoa 创建观察属性的 setter ，大致工作原理如下:

 ```Objective-C
- (void)setNow:(NSDate *)aDate {
    [self willChangeValueForKey:@"now"];
    [super setValue:aDate forKey:@"now"];
    [self didChangeValueForKey:@"now"];
}
 ```
这种继承和方法注入是在运行时而不是编译时实现的。这就是正确命名如此重要的原因。只有在使用KVC命名约定时，KVO才能做到这一点。

KVO 在实现中通过 ` isa 混写（isa-swizzling）` 把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就神奇的变成了新创建的子类的实例。这在[Apple 的文档](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueObserving/Articles/KVOImplementation.html)可以得到印证：

 > Automatic key-value observing is implemented using a technique called isa-swizzling... When an observer is registered for an attribute of an object the isa pointer of the observed object is modified, pointing to an intermediate class rather than at the true class ...


然而 KVO 在实现中使用了 ` isa 混写（ isa-swizzling）` ，这个的确不是很容易发现：Apple 还重写、覆盖了 `-class` 方法并返回原来的类。 企图欺骗我们：这个类没有变，就是原本那个类。。。

但是，假设“被监听的对象”的类对象是 `MYClass` ，有时候我们能看到对 `NSKVONotifying_MYClass` 的引用而不是对  `MYClass`  的引用。借此我们得以知道 Apple 使用了 ` isa 混写（isa-swizzling）`。具体探究过程可参考[ 这篇博文 ](https://www.mikeash.com/pyblog/friday-qa-2009-01-23.html)。


那么 `wilChangeValueForKey:` 、  `didChangeValueForKey:`  和 `observeValueForKeyPath:ofObject:change:context:` 这三个方法的执行顺序是怎样的呢？

 `wilChangeValueForKey:` 、  `didChangeValueForKey:` 很好理解，`observeValueForKeyPath:ofObject:change:context:` 的执行时机是什么时候呢？

 先看一个例子：

代码已放在仓库里。

 ```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver:self forKeyPath:@"now" options:NSKeyValueObservingOptionNew context:nil];
    NSLog(@"1");
    [self willChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
    NSLog(@"2");
    [self didChangeValueForKey:@"now"]; // “手动触发self.now的KVO”，必写。
    NSLog(@"4");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    NSLog(@"3");
}

 ```



如果单单从下面这个例子的打印上， 

顺序似乎是 `wilChangeValueForKey:` 、 `observeValueForKeyPath:ofObject:change:context:` 、 `didChangeValueForKey:` 。

其实不然，这里有一个 `observeValueForKeyPath:ofObject:change:context:`  , 和 `didChangeValueForKey:` 到底谁先调用的问题：如果 `observeValueForKeyPath:ofObject:change:context:` 是在 `didChangeValueForKey:` 内部触发的操作呢？ 那么顺序就是： `wilChangeValueForKey:` 、  `didChangeValueForKey:`  和 `observeValueForKeyPath:ofObject:change:context:` 

不信你把 `didChangeValueForKey:` 注视掉，看下 `observeValueForKeyPath:ofObject:change:context:` 会不会执行。

了解到这一点很重要，正如  [46. 如何手动触发一个value的KVO](https://github.com/ChenYilong/iOSInterviewQuestions/blob/master/01《招聘一个靠谱的iOS》面试题参考答案/《招聘一个靠谱的iOS》面试题参考答案（下）.md#46-如何手动触发一个value的kvo)  所说的：

“手动触发”的使用场景是什么？一般我们只在希望能控制“回调的调用时机”时才会这么做。

而“回调的调用时机”就是在你调用 `didChangeValueForKey:` 方法时。

自定义的KVO实现
```Objective-C
MJPerson
#import "MJPerson.h"

@implementation MJPerson

- (void)setAge:(int)age
{
    _age = age;
    
    NSLog(@"setAge:");
}

//- (int)age
//{
//    return _age;
//}

- (void)willChangeValueForKey:(NSString *)key
{
    [super willChangeValueForKey:key];
    
    NSLog(@"willChangeValueForKey");
}

- (void)didChangeValueForKey:(NSString *)key
{
    NSLog(@"didChangeValueForKey - begin");
    
    [super didChangeValueForKey:key];
    
    NSLog(@"didChangeValueForKey - end");
}

@end

继承自MJPerson的子类
#import "NSKVONotifying_MJPerson.h"

@implementation NSKVONotifying_MJPerson

- (void)setAge:(int)age
{
    _NSSetIntValueAndNotify();
}

// 伪代码
void _NSSetIntValueAndNotify()
{
    [self willChangeValueForKey:@"age"];
    [super setAge:age];
    [self didChangeValueForKey:@"age"];
}

- (void)didChangeValueForKey:(NSString *)key
{
    // 通知监听器，某某属性值发生了改变
    [oberser observeValueForKeyPath:key ofObject:self change:nil context:nil];
}

@end


#import "ViewController.h"
#import "MJPerson.h"
#import <objc/runtime.h>

@interface ViewController ()
@property (strong, nonatomic) MJPerson *person1;
@property (strong, nonatomic) MJPerson *person2;
@end

// 反编译工具 - Hopper

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.person1 = [[MJPerson alloc] init];
    self.person1.age = 1;
    
    self.person2 = [[MJPerson alloc] init];
    self.person2.age = 2;
    
    
    NSLog(@"person1添加KVO监听之前 - %@ %@",
          object_getClass(self.person1),
          object_getClass(self.person2));
    NSLog(@"person1添加KVO监听之前 - %p %p",
          [self.person1 methodForSelector:@selector(setAge:)],
          [self.person2 methodForSelector:@selector(setAge:)]);
    
    // 给person1对象添加KVO监听
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.person1 addObserver:self forKeyPath:@"age" options:options context:@"123"];
    
    NSLog(@"person1添加KVO监听之后 - %@ %@",
          object_getClass(self.person1),//类对象地址变了
          object_getClass(self.person2));
    NSLog(@"person1添加KVO监听之后 - %p %p",
          [self.person1 methodForSelector:@selector(setAge:)],//方法在类对象中，地址也变了
          [self.person2 methodForSelector:@selector(setAge:)]);

    NSLog(@"类对象 - %@ %@",
          object_getClass(self.person1),  // self.person1.isa //NSKVONotifying_MJPerson
          object_getClass(self.person2)); // self.person2.isa //MJPerson
    
    NSLog(@"类对象地址 - %p %p",
          object_getClass(self.person1),  // self.person1.isa //NSKVONotifying_MJPerson
          object_getClass(self.person2)); // self.person2.isa //MJPerson

    NSLog(@"元类对象 - %@ %@",
          object_getClass(object_getClass(self.person1)), // self.person1.isa.isa //NSKVONotifying_MJPerson
          object_getClass(object_getClass(self.person2))); // self.person2.isa.isa //MJPerson
    
    NSLog(@"元类对象地址 - %p %p",
          object_getClass(object_getClass(self.person1)), // self.person1.isa.isa //NSKVONotifying_MJPerson
          object_getClass(object_getClass(self.person2))); // self.person2.isa.isa //MJPerson
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // NSKVONotifying_MJPerson是使用Runtime动态创建的一个类，是MJPerson的子类
    // self.person1.isa == NSKVONotifying_MJPerson
    [self.person1 setAge:21];
    
    // self.person2.isa = MJPerson
//    [self.person2 setAge:22];
}

- (void)dealloc {
    [self.person1 removeObserver:self forKeyPath:@"age"];
}

// 当监听对象的属性值发生改变时，就会调用
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
}

@end
```
给KVO添加筛选条件
 重写automaticallyNotifiesObserversForKey，需要筛选的key返回NO。
 setter里添加判断后手动触发KVO
```Objective-C
 + (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
     if ([key isEqualToString:@"age"]) {
         return NO;
     }
     return [super automaticallyNotifiesObserversForKey:key];
 }
 ​
 - (void)setAge:(NSInteger)age {
     if (age >= 18) {
         [self willChangeValueForKey:@"age"];
         _age = age;
         [self didChangeValueForKey:@"age"];
     }else {
         _age = age;
     }
 }
```

### IBOutlet连出来的视图属性为什么可以被设置成weak?

参考链接：[ ***Should IBOutlets be strong or weak under ARC?*** ](http://stackoverflow.com/questions/7678469/should-iboutlets-be-strong-or-weak-under-arc)

文章告诉我们：

> 因为既然有外链那么视图在xib或者storyboard中肯定存在，视图已经对它有一个强引用了。


不过这个回答漏了个重要知识，使用storyboard（xib不行）创建的vc，会有一个叫`_topLevelObjectsToKeepAliveFromStoryboard` 的私有数组强引用所有 top level 的对象，所以这时即便 outlet 声明成weak也没关系

如果对本回答有疑问，欢迎参与讨论： 

- [《第52题 IBOutlet连出来的视图属性为什么可以被设置成weak? #51》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/51 ) 
- [《关于weak的一个问题 #39》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/39 ) 

### IB中User Defined Runtime Attributes如何使用？ 

它能够通过KVC的方式配置一些你在interface builder 中不能配置的属性。当你希望在IB中作尽可能多得事情，这个特性能够帮助你编写更加轻量级的viewcontroller

<p align="center"><a href="https://mp.weixin.qq.com/s/A4e5h3xgIEh6PInf1Rjqsw"><img src="https://tva1.sinaimg.cn/large/007S8ZIlly1gfecd2fpfuj307907q3yt.jpg"></a></p>


### 如何调试BAD_ACCESS错误


 1. 重写object的respondsToSelector方法，现实出现EXEC_BAD_ACCESS前访问的最后一个object
 2. 通过 Zombie 
![https://github.com/ChenYilong](http://i.stack.imgur.com/ZAdi0.png)

 3. 设置全局断点快速定位问题代码所在行
 4. Xcode 7 已经集成了BAD_ACCESS捕获功能：**Address Sanitizer**。
用法如下：在配置中勾选✅Enable Address Sanitizer

<p align="center"><a href="https://mp.weixin.qq.com/s/A4e5h3xgIEh6PInf1Rjqsw"><img src="http://ww4.sinaimg.cn/large/006y8mN6gy1g71n53zsvpj30qc09sdh7.jpg"></a></p>


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
        uintptr_t nonpointer        : 1;  // 0:普通指针，存储Class、Meta-Class；1:存储更多信息
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
    IMP imp;//指向函数的指针（函数地址）
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
![图片](/图片/isa-superclass.png)

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

struct class_ro_t { //只读
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

###  通知的原理
nsnotification发送在什么线程，默认响应就在什么线程，和注册位置无关。所以说NSNotification是线程安全的。

通知是同步的。子线程发送消息，就会变成异步.可以使用addObserverForName：object: queue: usingBlock:。

NSNotificationQueue是异步发送，也就是延迟发送。在同一个线程发送和响应

不移除通知，iOS9.0之后，不会crash，原因：通知中心对观察者的引用是weak

多次添加同一个通知，会导致发送一次这个通知的时候，响应多次通知回调。因为在添加的时候不会做去重操作   

NSNotificationQueue和runloop的关系
     NSNotificationQueue将通知添加到队列中时，其中postringStyle参数就是定义通知调用和runloop状态之间关系。

     该参数的三个可选参数：
     NSPostWhenIdle：runloop空闲的时候回调通知方法
     NSPostASAP：runloop在执行timer事件或sources事件完成的时候回调通知方法
     NSPostNow：runloop立即回调通知方法
     
     NSNotificationQueue只是把通知添加到通知队列，并不会主动发送
     NSNotificationQueue依赖runloop，如果线程runloop没开启就不生效。
     NSNotificationQueue发送通知需要runloop循环中会触发NotifyASAP和NotifyIdle从而调用NSNotificationCenter
     NSNotificationCenter 内部的发送方法其实是同步的，所以NSNotificationQueue的异步发送其实是延迟发送。

      
```Objective-C
 NSNotification ： 存储通知信息，包含NSNotificationName通知名、对象objetct、useInfo字典
 @interface NSNotification : NSObject
  @property (readonly, copy) NSNotificationName name;
 @property (nullable, readonly, retain) id object;
 @property (nullable, readonly, copy) NSDictionary *userInfo;
 ```
NSNotificationCenter ： 单例实现。并且通知中心维护了一个包含所有注册的观察者的集合
  
NSObserverModel:定义了一个观察者模型用于保存观察者，通知消息名，观察者收到通知后执行代码所在的操作队列和执行代码的回调
```Objective-C
 @interface NSObserverModel : NSObject
 @property (nonatomic, strong) id observer;  //观察者对象
 @property (nonatomic, assign) SEL selector;  //执行的方法
 @property (nonatomic, copy) NSString *notificationName; //通知名字
 @property (nonatomic, strong) id object;  //携带参数
 @property (nonatomic, strong) NSOperationQueue *operationQueue;//队列
 @property (nonatomic, copy) OperationBlock block;  //回调
 ```
向通知中心注册观察者，源码如下：
```Objective-C
 - (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSString*)aName object:(nullable id)anObject{
  //如果不存在，那么即创建
     if (![self.obsetvers objectForKey:aName]) {
         NSMutableArray *arrays = [[NSMutableArray alloc]init];
        // 创建数组模型
         NSObserverModel *observerModel = [[NSObserverModel alloc]init];
         observerModel.observer = observer;
         observerModel.selector = aSelector;
         observerModel.notificationName = aName;
         observerModel.object = anObject;
         [arrays addObject:observerModel];
       //填充进入数组
         [self.obsetvers setObject:arrays forKey:aName];
  
  
     }else{
  
         //如果存在，取出来，继续添加减去即可
         NSMutableArray *arrays = (NSMutableArray*)[self.obsetvers objectForKey:aName];
         // 创建数组模型
         NSObserverModel *observerModel = [[NSObserverModel alloc]init];
         observerModel.observer = observer;
         observerModel.selector = aSelector;
         observerModel.notificationName = aName;
         observerModel.object = anObject;
         [arrays addObject:observerModel];
   }
 }
 ```
发送通知
```Objective-C  
 - (void)postNotification:(YFLNotification *)notification
 {
     //name 取出来对应观察者数组，执行任务
     NSMutableArray *arrays = (NSMutableArray*)[self.obsetvers objectForKey:notification.name];
  
     [arrays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
  
         //取出数据模型
         NSObserverModel *observerModel = obj;
         id observer = observerModel.observer;
         SEL secector = observerModel.selector;
  
         if (!observerModel.operationQueue) {
 #pragma clang diagnostic push
 #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             [observer performSelector:secector withObject:notification];
 #pragma clang diagnostic pop
         }else{
  
             //创建任务
             NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
  
                 //这里用block回调出去
                 observerModel.block(notification);
  
             }];
  
             // 如果添加观察者 传入 队列，那么就任务放在队列中执行(子线程异步执行)
             NSOperationQueue *operationQueue = observerModel.operationQueue;
             [operationQueue addOperation:operation];
  
         }
  
     }];
  
 }
```
