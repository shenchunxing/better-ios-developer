这本书讲授了很多编写Objective-C语言时所应该遵循的规范。刚好笔者前段时间因为产品刚开发完，有了一点空档期，于是用了3个星期的时间仔细研读和总结了这本书。

在学习过程中也看过很多总结这本书的博客和文章，但是发现多数只是将每节的总结部分摘录了过来，因此讲得并不是很详细。于是笔者就想按照自己的方式对这本书进行总结，并以博客的形式展现出来：既能分享，同时又能对知识进行一下梳理和二次复习。

虽然本书的作者按照知识模块来将这本书分成七个章节，共52节，但是笔者在拜读的过程中发现本书介绍的知识点可以大致分为三类：概念类，规范类，和技巧类。笔者打算按照这三类来对这本书进行总结，形成三部曲：

*   概念类：讲解了一些概念性知识。
*   规范类：讲解了一些为了避免一些问题或者为后续开发提供便利所需要遵循的规范性知识。
*   技巧类：讲解了一些为了解决某些特定问题而需要用到的技巧性知识。

而且，笔者也按照自己的归类将这本书的结构用思维导图工具画了出来：

![三部曲分布图](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/1/5/160c563a0571dff6~tplv-t2oaga2asx-zoom-in-crop-mark:4536:0:0:0.awebp)

> 从图中可以看到，笔者并没有打乱原来作者的标题顺序。本篇总结即是三部曲之一：概念篇，后续会呈上规范篇和技巧篇。 备注：本总结所有的代码和图片都来自原书。其中，代码会适当加上笔者的注释，便于各位看官理解。

好了，不啰嗦了， 开始吧！

第1条：了解Objective-C的起源
====================

运行期组件
-----

对于消息结构的语言，运行时所执行的代码由运行环境来决定；在运行时才回去查找索要执行的方法。其实现原理是由运行期组件完成（runtime component），使用Objective-C的面向对象特性所需的全部数据结构以及函数都在运行期组件里面。

运行期组件本质上是一种与开发者所编写的代码相链接的动态库（dynamic library），其代码能把开发者所编写的所有程序粘合起来，所以只要更新运行期组件，就可以提升应用程序性能。

内存：对象分配到堆空间,指针分配到栈空间。 分配在队中的内存必须直接管理，而分配在栈上用于保存变量的内存则会在其栈帧弹出时自动清理。

不含\*的变量，可能会使用栈空间。结构体保存非对象类型。

第6条：理解“属性”这一概念
==============

> 属性用于封装对象中的数据。

1\. 存取方法
--------

在设置完属性后，编译器会自动写出一套存取方法，用于访问相应名称的变量：

    @interface EOCPerson : NSObject
    
    @property NSString *firstName;
    @property NSString *lastName;
    @end
    
    
    @interface EOCPerson : NSObject
    
    - (NSString*)firstName;
    - (void)setFirstName:(NSString*)firstName;
    - (NSString*)lastName;
    - (void)setLastName:(NSString*)lastName;
    
    @end
    复制代码

访问属性，可以使用点语法。编译器会把点语法转换为对存取方法的调用：

    aPerson.firstName = @"Bob"; // Same as:
    [aPerson setFirstName:@"Bob"];
    
    
    NSString *lastName = aPerson.lastName; // Same as:
    NSString *lastName = [aPerson lastName];
    复制代码

如果我们不希望编译器自动生成存取方法的话，需要设置@dynamic 字段：

    @interface EOCPerson : NSManagedObject
    
    @property NSString *firstName;
    @property NSString *lastName;
    
    @end
    
    
    @implementation EOCPerson
    @dynamic firstName, lastName;
    @end
    复制代码

2\. 属性关键字
---------

> 定义属性的时候，通常会赋予它一些特性，来满足一些对类保存数据所要遵循的需求。

### 原子性：

*   nonatomic：不使用同步锁
*   atomic：加同步锁，确保其原子性

### 读写

*   readwrite:同时存在存取方法
*   readonly:只有获取方法

### 内存管理

*   assign:纯量类型(scalar type)的简单赋值操作
*   strong:拥有关系保留新值，释放旧值，再设置新值
*   weak:非拥有关系(nonowning relationship)，属性所指的对象遭到摧毁时，属性也会清空
*   unsafe\_unretained ：类似assign，适用于对象类型，非拥有关系，属性所指的对象遭到摧毁时，属性不会清空。
*   copy：不保留新值，而是将其拷贝

### 注意：遵循属性定义

如果属性定义为copy，那么在非设置方法里设定属性的时候，也要遵循copy的语义

    - (id)initWithFirstName:(NSString*)firstName lastName:(NSString*)lastName
    {
             if ((self = [super init])) {
                _firstName = [firstName copy];
                _lastName = [lastName copy];
            }
           return self;
    }
    
    复制代码

第8条：理解“对象等同性”这一概念
=================

1\. 同等性判断
---------

> \==操作符比较的是指针值，也就是内存地址。

然而有的时候我们只是想比较指针所指向的内容，在这个时候，就需要通过`isEqual:`方法来比较。

而且，如果已知两个对象是字符串，最好通过`isEqualToString:`方法来比较。 对于数组和字典，也有`isEqualToArray:`方法和`isEqualToDictionary:`方法。

另外，如果比较的对象类型和当前对象类型相同，就可以采用自己编写的判定方法，否则调用父类的`isEqual:`方法：

    - (BOOL)isEqualToPerson:(EOCPerson*)otherPerson {
    
         //先比较对象类型，然后比较每个属性
         if (self == object) return YES;
         if (![_firstName isEqualToString:otherPerson.firstName])
             return NO;
         if (![_lastName isEqualToString:otherPerson.lastName])
             return NO;
         if (_age != otherPerson.age)
             return NO;
         return YES;
    }
    
    
    - (BOOL)isEqual:(id)object {
        //如果对象所属类型相同，就调用自己编写的判定方法，如果不同，调用父类的isEqual:方法
         if ([self class] == [object class]) {    
             return [self isEqualToPerson:(EOCPerson*)object];
        } else {    
             return [super isEqual:object];
        }
    }
    
    复制代码

2\. 深度等同性判定
-----------

比较两个数组是否相等的话可以使用深度同等性判断方法：

> 1.先比较数组的个数 2.再比较两个数组对应位置上的对象均相等。

第11条：理解objc\_msgSend的作用
=======================

在OC中，如果向某对象传递信息，那就会使用动态绑定机制来决定需要调用的方法。在底层，所有方法都是普通的C语言函数.

然而对象收到 消息后，究竟该调用哪个方法则完全于运行期决定，甚至可以在程序运行时改变，这些特性使得OC成为一门真正的动态语言。

在OC中，给对象发送消息的语法是：

    id returnValue = [someObject messageName:parameter];
    复制代码

> 这里，someObject叫做“接收者(receiver)”，messageName:叫做"选择子（selector）",选择子和参数合起来称为“消息”。编译器看到此消息后，将其转换为一条标准的C语言函数调用，所调用的函数乃是消息传递机制中的核心函数叫做objc\_msgSend，它的原型如下：

    void objc_msgSend(id self, SEL cmd, ...)
    复制代码

> 第一个参数代表接收者，第二个参数代表选择子，后续参数就是消息中的那些参数，数量是可变的，所以这个函数就是参数个数可变的函数。

因此，上述以OC形式展现出来的函数就会转化成如下函数:

    id returnValue = objc_msgSend(someObject,@selector(messageName:),parameter);
    复制代码

> 这个函数会在接收者所属的类中搜寻其“方法列表”，如果能找到与选择子名称相符的方法，就去实现代码，如果找不到就沿着继承体系继续向上查找。如果找到了就执行，如果最终还是找不到，就执行**消息转发**操作。

> **注意**：如果匹配成功的话，这种匹配的结果会缓存在“快速映射表”里面。每个类都有这样一块缓存。所以如果将来再次向该类发送形同的消息，执行速度就会更快了。

第12条：理解消息转发机制
=============

如果对象所属类和其所有的父类都无法解读收到的消息，就会启动消息转发机制（message forwarding）。

尤其我们在编写自己的类时，可在消息转发过程中设置挂钩，用以执行预定的逻辑，而不应该使应用程序崩溃。

消息转发分为两个阶段:

1.  征询接受者，看它能否动态添加方法，以处理这个未知的选择子，这个过程叫做动态方法解析（dynamic method resolution）。
    
2.  请接受者看看有没有其他对象能处理这条消息：
    
    2.1 如果有，则运行期系统会把消息转给那个对象。 2.2 如果没有，则启动完整的消息转发机制（full forwarding mechanism），运行期系统会把与消息有关的全部细节都封装到NSInvocation对象中，再给接受者最后一次机会，令其设法解决当前还未处理的这条消息。
    

![图片来自：《Effective Objective-C 》](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/1/5/160c563a08fd24bd~tplv-t2oaga2asx-zoom-in-crop-mark:4536:0:0:0.awebp)

类方法`+(BOOL)resolveInstanceMethod:(SEL)selector`:查看这个类是否能新增一个实例方法用以处理此选择子

实例方法`- (id)forwardTargetForSelector:(SEL)selector;`:询问是否能找到未知消息的备援接受者，如果能找到备援对象，就将其返回，如果不能，就返回nil。

实例方法`- (void)forwardInvocation:(NSInvocation*)invocation`:创建NSInvocation对象，将尚未处理的那条消息 有关的全部细节都封于其中，在触发NSInvocation对象时，“消息派发系统（message-dispatch system）”就会将消息派给目标对象。

下面来看一个关于动态方法解析的例子：

    #import <Foundation/Foundation.h>
    
    @interface EOCAutoDictionary : NSObject
    @property (nonatomic, strong) NSString *string;
    @property (nonatomic, strong) NSNumber *number;
    @property (nonatomic, strong) NSDate *date;
    @property (nonatomic, strong) id opaqueObject;
    
    @end
    
    
    
    #import "EOCAutoDictionary.h"
    #import <objc/runtime.h>
    
    
    @interface EOCAutoDictionary ()
    @property (nonatomic, strong) NSMutableDictionary *backingStore;
    @end
    
    
    
    @implementation EOCAutoDictionary
    
    @dynamic string, number, date, opaqueObject;
    
    
    
    - (id)init {
     if ((self = [super init])) {
        _backingStore = [NSMutableDictionary new];
    }
    
       return self;
    
    }
    
    
    
    + (BOOL)resolveInstanceMethod:(SEL)selector {
    
         NSString *selectorString = NSStringFromSelector(selector);
         if ([selectorString hasPrefix:@"set"]) {
             class_addMethod(self,selector,(IMP)autoDictionarySetter, "v@:@");
         } else {
             class_addMethod(self,selector,(IMP)autoDictionaryGetter, "@@:");
        }
         return YES;
    }
    
    复制代码

> 在本例中，EOCAutoDictionary类将属性设置为@dynamic，也就是说编译器无法自动为其属性生成set和get方法，因此我们需要动态给其添加set和get方法。

> 我们实现了`resolveInstanceMethod:`方法：首先将选择子转换为String，然后判断字符串是否含有set字段，如果有，则增加处理选择子的set方法；如果没有，则增加处理选择子的get方法。其中`class_addMethod`可以给类动态添加方法。

实现增加处理选择子的get方法：

    id autoDictionaryGetter(id self, SEL _cmd) {
    
         // Get the backing store from the object
         EOCAutoDictionary *typedSelf = (EOCAutoDictionary*)self;
         NSMutableDictionary *backingStore = typedSelf.backingStore;
    
         // The key is simply the selector name
         NSString *key = NSStringFromSelector(_cmd);
    
         // Return the value
         return [backingStore objectForKey:key];
    }
    
    复制代码

> 在这里，键的名字就等于方法名，所以在取出键对应的值之前，要将方法名转换为字符串。

实现增加处理选择子的set方法：

    
    void autoDictionarySetter(id self, SEL _cmd, id value) {
    
         // Get the backing store from the object
         EOCAutoDictionary *typedSelf = (EOCAutoDictionary*)self;
         NSMutableDictionary *backingStore = typedSelf.backingStore;
    
         /** The selector will be for example, "setOpaqueObject:".
         * We need to remove the "set", ":" and lowercase the first
         * letter of the remainder.
         */
         NSString *selectorString = NSStringFromSelector(_cmd);
         NSMutableString *key = [selectorString mutableCopy];
    
         // Remove the ':' at the end
        [key deleteCharactersInRange:NSMakeRange(key.length - 1, 1)];
    
         // Remove the 'set' prefix
        [key deleteCharactersInRange:NSMakeRange(0, 3)];
    
         // Lowercase the first character
         NSString *lowercaseFirstChar = [[key substringToIndex:1] lowercaseString];
        [key replaceCharactersInRange:NSMakeRange(0, 1) withString:lowercaseFirstChar];
    
         if (value) {
           [backingStore setObject:value forKey:key];
        } else {
            [backingStore removeObjectForKey:key];        
        }
    }
    
    复制代码

> 因为key的名字对应了属性名，也就是没有set，首字母小写，尾部没有：的字符串。然而，将set方法转换为字符串后，我们需要将set方法的这些“边角”都处理掉。最后得到了“纯净”的键后，再进行字典的赋值操作。

第14条：理解“类对象”的用意
===============

在运行期程序库的头文件里定义了描述OC对象所用的数据结构：

    typedef struct objc_class *Class;
    
        struct objc_class {
             Class isa;
             Class super_class;
             const char *name;
             long version;
             long info;
             long instance_size;
             struct objc_ivar_list *ivars;
             struct objc_method_list **methodLists;
             struct objc_cache *cache;
             struct objc_protocol_list *protocols;
    };
    
    
    
    复制代码

> 在这里，isa指针指向了对象所属的类：元类（metaclass），它是整个结构体的第一个变量。super\_class定义了本类的超类。

我们也可以向对象发送特定的方法来检视类的继承体系：自身属于哪一类；自身继承与哪一类。

我们使用`isMemberOfClass:`能够判断出对象是否为某个特定类的实例； 而`isKindOfClass:`方法能够判断出对象是否为某类或其派生类的实例。

这两种方法都是利用了isa指针获取对象所属的类，然后通过super\_class类在继承体系中查询。在OC语言中，必须使用这种查询类型信息的方法才能完全了解对象的真实类型。因为对象类型无法在编译期决定。

尤其注意在集合类里获取对象时，通常要查询类型信息因为这些对象不是强类型的（strongly typed），将它们从集合类中取出来的类型通常是id，也就是能响应任何消息（编译期）。

所以如果我们对这些对象的类型把握不好，那么就会有可能造成对象无法响应消息的情况。因此，在我们从集合里取出对象后，通常要进行类型判断：

    
    - (NSString*)commaSeparatedStringFromObjects:(NSArray*)array {
    
             NSMutableString *string = [NSMutableString new];
    
                 for (id object in array) {
                        if ([object isKindOfClass:[NSString class]]) {
                                [string appendFormat:@"%@,", object];
                        } else if ([object isKindOfClass:[NSNumber class]]) {
                                [string appendFormat:@"%d,", [object intValue]];
                        } else if ([object isKindOfClass:[NSData class]]) {
                               NSString *base64Encoded = /* base64 encoded data */;
                                [string appendFormat:@"%@,", base64Encoded];
                        } else {
                                // Type not supported
                        }
                  }
                 return string;
    }
    复制代码

第21条：理解Objective-C错误类型
======================

在OC中，我们可以用NSError描述错误。 使用NSError可以封装三种信息：

*   Error domain:错误范围，类型是字符串
*   Error code :错误码，类型是整数
*   User info：用户信息，类型是字典

1\. NSError的使用
--------------

用法：

1.通过委托协议来传递NSError，告诉代理错误类型。

    - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
    复制代码

2.作为方法的“输出参数”返回给调用者

    - (BOOL)doSomething:(NSError**)error
    复制代码

使用范例：

    
    NSError *error = nil;
    BOOL ret = [object doSomething:&error];
    
    if (error) {
        // There was an error
    }
    
    复制代码

2\. 自定义NSError
--------------

我们可以设置属于我们自己程序的错误范围和错误码

*   错误范围可以用全局常量字符串来定义。
*   错误码可以用枚举来定义。

    
    // EOCErrors.h
    extern NSString *const EOCErrorDomain;
    
    //定义错误码
    typedef NS_ENUM(NSUInteger, EOCError) {
    
        EOCErrorUnknown = –1,
        EOCErrorInternalInconsistency = 100,
        EOCErrorGeneralFault = 105,
        EOCErrorBadInput = 500,
    };
    
    
    
    // EOCErrors.m
    NSString *const EOCErrorDomain = @"EOCErrorDomain"; //定义错误范围
    
    复制代码

第22条：理解NSCopying协议
==================

如果我们想令自己的类支持拷贝操作，那就要实现NSCopying协议，该协议只有一个方法：

    - (id)copyWithZone:(NSZone*)zone
    复制代码

作者举了个：

    
    - (id)copyWithZone:(NSZone*)zone {
    
         EOCPerson *copy = [[[self class] allocWithZone:zone] initWithFirstName:_firstName  andLastName:_lastName];
        copy->_friends = [_friends mutableCopy];
         return copy;
    }
    
    复制代码

> 之所以是copy->\_friends，而不是copy.friends是因为friends并不是属性，而是一个内部使用的实例变量。

1\. 复制可变的版本：
------------

遵从协议

而且要执行：

    - (id)mutableCopyWithZone:(NSZone*)zone；
    复制代码

> 注意：拷贝可变型和不可变型发送的是`copy`和`mutableCopy`消息，而我们实现的却是`- (id)copyWithZone:(NSZone*)zone`和`- (id)mutableCopyWithZone:(NSZone*)zone` 方法。

> 而且，如果我们想获得某对象的不可变型，统一调用copy方法；获得某对象的可变型，统一调用mutableCopy方法。

例如数组的拷贝：

    -[NSMutableArray copy] => NSArray
    -[NSArray mutableCopy] => NSMutableArray
    复制代码

2\. 浅拷贝和深拷贝
-----------

Foundation框架中的集合类默认都执行浅拷贝：只拷贝容器对象本身，而不复制其中的数据。 而深拷贝的意思是连同对象本身和它的底层数据都要拷贝。

作者用一个图很形象地体现了浅拷贝和深拷贝的区别：

![图片来自：《Effective Objective-C》](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/1/5/160c563a074c86c6~tplv-t2oaga2asx-zoom-in-crop-mark:4536:0:0:0.awebp)

> 浅拷贝后的内容和原始内容指向同一个对象 深拷贝后的内容所指的对象是原始内容对应对象的拷贝

3\. 如何深拷贝？
----------

我们需要自己编写深拷贝的方法：遍历每个元素并复制，然后将复制后的所有元素重新组成一个新的集合。

    - (id)initWithSet:(NSArray*)array copyItems:(BOOL)copyItems;
    
    复制代码

> 在这里，我们自己提供了一个深拷贝的方法：该方法需要传入两个参数：需要拷贝的数组和是否拷贝元素（是否深拷贝）

    
    - (id)deepCopy {
           EOCPerson *copy = [[[self class] alloc] initWithFirstName:_firstName andLastName:_lastName];
            copy->_friends = [[NSMutableSet alloc] initWithSet:_friends copyItems:YES];
            return copy;
    }
    
    复制代码

第29条：理解引用计数
===========

尽管在iOS系统已经支持了自动引用计数，但仍然需要开发者了解其内存管理机制。

1\. 计数器的操作：
-----------

1.  retain：递增保留计数。
2.  release：递减保留计数
3.  autorelease ：待稍后清理“自动释放池时”，再递减保留计数。

> 注意：在对象初始化后，引用计数不一定是1，还有可能大于1。因为在初始化方法的实现中，或许还有其他的操作使得引用计数+1，例如其他的对象也保留了此对象。

有时，我们无法确定在某个操作后引用计数的确切值，而只能判断这个操作是递增还是递减了保留计数。

2\. 自动释放池：
----------

将对象放入自动释放池之后，不会马上使其引用计数-1，而是在当前线程的下一次事件循环时递减。

使用举例：如果我们想释放当前需要使用的方法返回值是，可以将其暂时放在自动释放池中：

    
    - (NSString*)stringValue {
         NSString *str = [[NSString alloc] initWithFormat:@"I am this: %@", self];
         return [str autorelease];
    }
    
    复制代码

3\. 保留循环（retain cycle）
----------------------

对象之间相互用强引用指向对方，会使得全部都无法得以释放。解决方案是讲其中一端的引用改为弱引用（weak reference），在引用的同时不递增引用计数。

第30条：以ARC简化引用计数
===============

* * *

使用ARC，可以省略对于引用计数的操作，让开发者专注于开发本身：

    if ([self shouldLogMessage]) {
         NSString *message = [[NSString alloc] initWithFormat:@"I am object, %p", self];
         NSLog(@"message = %@", message);
          [message release]; ///< Added by ARC
    }
    复制代码

> 显然这里我们不需要message对象了，那么ARC会自动为我们添加内存管理的语句。

因此，在ARC环境下调用内存管理语句是非法的：

*   retain
*   release
*   autorelease
*   dealloc

> 注意：ARC只负责管理OC对象的内存，CoreFoundation对象不归ARC管理

第37条：理解block这一概念
================

对于“块”的基础知识就不再赘述了，这里强调一下块的种类。

块(Block)分为三类：

*   栈块
*   堆块
*   全局块

1\. 栈block
----------

定义块的时候，其所占内存区域是分配在栈中的，而且只在定义它的那个范围内有效：

    void (^block)();
    
    if ( /* some condition */ ) {
        block = ^{
         NSLog(@"Block A");
        };
    
    } else {
        block = ^{
         NSLog(@"Block B");
        };
    }
    
    block();
    复制代码

上面定义的两个块只在if else语句范围内有效，一旦离开了最后一个右括号，如果编译器覆写了分配给块的内存，那么就会造成程序崩溃。

2\. 堆block
----------

为了解决这个问题，我们可以给对象发送copy消息，复制一份到堆里，并自带引用计数：

    void (^block)();
    
    if ( /* some condition */ ) {
        block = [^{
             NSLog(@"Block A");
       } copy];
    } else {
        block = [^{
             NSLog(@"Block B");
        } copy];
    }
    
    block();
    复制代码

3\. 全局block
-----------

全局块声明在全局内存里，而不需要在每次用到的时候于栈中创建。

    void (^block)() = ^{
         NSLog(@"This is a block");
    ﻿};
    
    复制代码

第47条：熟悉系统框架
===========

如果我们使用了系统提供的现成的框架，那么用户在升级系统后，就可以直接享受系统升级所带来的改进。

主要的系统框架：

*   Foundation:NSObject,NSArray,NSDictionary等
*   CFoundation框架：C语言API，Foundation框架中的许多功能，都可以在这里找到对应的C语言API
*   CFNetwork框架:C语言API，提供了C语言级别的网络通信能力
*   CoreAudio:C语言API，操作设备上的音频硬件
*   AVFoundation框架：提供的OC对象可以回放并录制音频和视频
*   CoreData框架：OC的API，将对象写入数据库
*   CoreText框架：C语言API，高效执行文字排版和渲染操作

用C语言来实现API的好处：可以绕过OC的运行期系统，从而提升执行速度。

最后的话
====

像本文开头所说，本文是三部曲系列的第一篇：概念篇，笔者主要将本书讲解概念的知识点抽取出来合并而成，内容相对后两篇简单一些。笔者会在一周的时间里陆续推出第2篇（规范篇），第3篇（技巧篇）~ 望各路大神和在大神路上的伙伴们多多交流。

本文已同步到个人博客：[传送门](https://link.juejin.cn?target=https%3A%2F%2Fknightsj.github.io%2F2016%2F09%2F05%2F%25E3%2580%258AEOC%25E3%2580%258B%25E8%25B6%2585%25E7%25BA%25A7%25E5%25B9%25B2%25E8%25B4%25A7%25E4%25B8%2589%25E9%2583%25A8%25E6%259B%25B2%25EF%25BC%2588%25E4%25B8%2580%25EF%25BC%2589%25EF%25BC%259A%25E6%25A6%2582%25E5%25BF%25B5%25E7%25AF%2587%2F "https://knightsj.github.io/2016/09/05/%E3%80%8AEOC%E3%80%8B%E8%B6%85%E7%BA%A7%E5%B9%B2%E8%B4%A7%E4%B8%89%E9%83%A8%E6%9B%B2%EF%BC%88%E4%B8%80%EF%BC%89%EF%BC%9A%E6%A6%82%E5%BF%B5%E7%AF%87/")

另外两篇传送门：

[《Effective Objective-C 》干货三部曲（二）：规范篇](https://juejin.cn/post/6844903548942024717 "https://juejin.cn/post/6844903548942024717")

[《Effective Objective-C 》干货三部曲（三）：技巧篇](https://juejin.cn/post/6844903549780885511 "https://juejin.cn/post/6844903549780885511")

**\---------------------------- 2018年7月17日更新 ----------------------------**

**注意注意！！！**

笔者在近期开通了个人公众号，主要分享编程，读书笔记，思考类的文章。

*   **编程类**文章：包括笔者以前发布的精选技术文章，以及后续发布的技术文章（以原创为主），并且逐渐脱离 iOS 的内容，将侧重点会转移到**提高编程能力**的方向上。
*   **读书笔记类**文章：分享**编程类**，**思考类**，**心理类**，**职场类**书籍的读书笔记。
*   **思考类**文章：分享笔者平时在**技术上**，**生活上**的思考。

> 因为公众号每天发布的消息数有限制，所以到目前为止还没有将所有过去的精选文章都发布在公众号上，后续会逐步发布的。

**而且因为各大博客平台的各种限制，后面还会在公众号上发布一些短小精干，以小见大的干货文章哦~**

扫下方的公众号二维码并点击关注，期待与您的共同成长~

![公众号：程序员维他命](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/7/17/164a40ee6f77891c~tplv-t2oaga2asx-zoom-in-crop-mark:4536:0:0:0.awebp)
