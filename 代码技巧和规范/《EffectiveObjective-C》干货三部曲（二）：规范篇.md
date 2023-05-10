继上一篇[《Effective Objective-C 》干货三部曲（一）：概念篇](https://juejin.cn/post/6844903545636913159 "https://juejin.cn/post/6844903545636913159")之后，本篇即是三部曲的第二篇：规范篇。 没看过三部曲第一篇的小伙伴可能不知道我在说神马，在这里还是先啰嗦一下三部曲是咋回事：笔者将《Effective Objective-C 》这本书的52个知识点分为三大类进行了归类整理：

*   概念类：讲解了一些概念性知识。
*   规范类：讲解了一些为了避免一些问题或者为后续开发提供便利所需要遵循的规范性知识。
*   技巧类：讲解了一些为了解决某些特定问题而需要用到的技巧性知识。

然后用思维导图整理了一下：

![三部曲分布图](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/1/5/160c56b52054b413~tplv-t2oaga2asx-zoom-in-crop-mark:4536:0:0:0.image)

作为三部曲的第二篇，本篇总结抽取了《Effective Objective-C 》这本书中讲解规范性知识的部分：这些知识点都是为了避免在开发过程中出现问题或给开发提供便利的规范性知识点。掌握这些知识有助于形成科学地写OC代码的习惯，使得代码更加容易维护和扩展，学习这类知识是iOS初学者进阶的必经之路。

第2条： 在类的头文件中尽量少引用其他头文件
======================

有时，类A需要将类B的实例变量作为它公共API的属性。这个时候，我们不应该引入类B的头文件，而应该使用向前声明（forward declaring）使用class关键字，并且在A的实现文件引用B的头文件。

    // EOCPerson.h
    #import <Foundation/Foundation.h>
    
    @class EOCEmployer;
    
    @interface EOCPerson : NSObject
    
    @property (nonatomic, copy) NSString *firstName;
    @property (nonatomic, copy) NSString *lastName;
    @property (nonatomic, strong) EOCEmployer *employer;//将EOCEmployer作为属性
    
    @end
    
    // EOCPerson.m
    #import "EOCEmployer.h"
    
    复制代码

这样做有什么优点呢：

> *   不在A的头文件中引入B的头文件，就不会一并引入B的全部内容，这样就减少了编译时间。

*   可以避免循环引用：因为如果两个类在自己的头文件中都引入了对方的头文件，那么就会导致其中一个类无法被正确编译。

但是个别的时候，必须在头文件中引入其他类的头文件:

> 主要有两种情况：

1.  该类继承于某个类，则应该引入父类的头文件。
2.  该类遵从某个协议，则应该引入该协议的头文件。而且最好将协议单独放在一个头文件中。

第3条：多用字面量语法，少用与之等价的方法
=====================

1\. 声明时的字面量语法：
--------------

在声明NSNumber，NSArray，NSDictionary时，应该尽量使用简洁字面量语法。

    NSNumber *intNumber = @1;
    NSNumber *floatNumber = @2.5f;
    复制代码

    NSArray *animals =[NSArray arrayWithObjects:@"cat", @"dog",@"mouse", @"badger", nil];
    Dictionary *dict = @{@"animal":@"tiger",@"phone":@"iPhone 6"};
    复制代码

2\. 集合类取下标的字面量语法：
-----------------

NSArray，NSDictionary，NSMutableArray，NSMutableDictionary 的取下标操作也应该尽量使用字面量语法。

    NSString *cat = animals[0];
    NSString *iphone = dict[@"phone"];
    
    复制代码

> 使用字面量语法的优点：

1.  代码看起来更加简洁。
2.  如果存在nil值，则会立即抛出异常。如果在不用字面量语法定义数组的情况下，如果数组内部存在nil，则系统会将其设为数组最后一个元素并终止。所以当这个nil不是最后一个元素的话，就会出现难以排查的错误。

> **注意**: 字面量语法创建出来的字符串，数组，字典对象都是不可变的。

第4条：多用类型常量，少用#define预处理命令
=========================

在OC中，定义常量通常使用预处理命令，但是并不建议使用它，而是使用类型常量的方法。 首先比较一下这两种方法的区别：

*   预处理命令：简单的文本替换，不包括类型信息，并且可被任意修改。
*   类型常量：包括类型信息，并且可以设置其使用范围，而且不可被修改。

我们可以看出来，使用预处理虽然能达到替换文本的目的，但是本身还是有局限性的：不具备类型 + 可以被任意修改，总之给人一种不安全的感觉。

知道了它们的长短处，我们再来简单看一下它们的具体使用方法：

预处理命令：
------

`#define W_LABEL (W_SCREEN - 2*GAP)`

> 这里，(W\_SCREEN - 2\*GAP)替换了W\_LABEL，它不具备W\_LABEL的类型信息。而且要注意一下：如果替换式中存在运算符号，以笔者的经验最好用括号括起来，不然容易出现错误（有体会）。

类型常量：
-----

`static const NSTimeIntervalDuration = 0.3;`

> 这里: const 将其设置为常量，不可更改。 static意味着该变量仅仅在定义此变量的编译单元中可见。如果不声明static,编译器会为它创建一个外部符号（external symbol）。我们来看一下对外公开的常量的声明方法：

对外公开某个常量：
---------

如果我们需要发送通知，那么就需要在不同的地方拿到通知的“频道”字符串，那么显然这个字符串是不能被轻易更改，而且可以在不同的地方获取。这个时候就需要定义一个外界可见的字符串常量。

    //header file
    extern NSString *const NotificationString;
    
    //implementation file
    NSString *const  NotificationString = @"Finish Download";
    复制代码

> 这里NSString \*const NotificationString是指针常量。 extern关键字告诉编译器，在全局符号表中将会有一个名叫NotificationString的符号。

我们通常在头文件声明常量，在其实现文件里定义该常量。由实现文件生成目标文件时，编译器会在“数据段”为字符串分配存储空间。

最后注意一下公开和非公开的常量的命名规范：

> 公开的常量：常量的名字最好用与之相关的类名做前缀。 非公开的常量：局限于某个编译单元（tanslation unit，实现文件 implementation file）内，在签名加上字母k。

第5条：用枚举表示状态，选项，状态码
==================

我们经常需要给类定义几个状态，这些状态码可以用枚举来管理。下面是关于网络连接状态的状态码枚举：

    typedef NS_ENUM(NSUInteger, EOCConnectionState) {
      EOCConnectionStateDisconnected,
      EOCConnectionStateConnecting,
      EOCConnectionStateConnected,
    };
    复制代码

需要注意的一点是： 在枚举类型的switch语句中不要实现default分支。它的好处是，当我们给枚举增加成员时，编译器就会提示开发者：switch语句并未处理所有的枚举。对此，笔者有个教训，又一次在switch语句中将“默认分支”设置为枚举中的第一项，自以为这样写可以让程序更健壮，结果后来导致了严重的崩溃。

第7条： 在对象内部尽量直接访问实例变量
====================

关于实例变量的访问，可以直接访问，也可以通过属性的方式(点语法)来访问。书中作者建议在读取实例变量时采用直接访问的形式，而在设置实例变量的时候通过属性来做。

直接访问属性的特点：
----------

*   绕过set，get语义，速度快；

通过属性访问属性的特点：
------------

*   不会绕过属性定义的内存管理语义
*   有助于打断点排查错误
*   可以触发KVO

因此，有个关于折中的方案：

> 设置属性：通过属性 读取属性：直接访问

不过有两个特例：

1.  初始化方法和dealloc方法中，需要直接访问实例变量来进行设置属性操作。因为如果在这里没有绕过set方法，就有可能触发其他不必要的操作。
2.  惰性初始化（lazy initialization）的属性，必须通过属性来读取数据。因为惰性初始化是通过重写get方法来初始化实例变量的，如果不通过属性来读取该实例变量，那么这个实例变量就永远不会被初始化。

第15条：用前缀 避免命名空间冲突
=================

Apple宣称其保留使用所有"两字母前缀"的权利，所以我们选用的前缀应该是三个字母的。 而且，如果自己开发的程序使用到了第三方库，也应该加上前缀。

第18条：尽量使用不可变对象
==============

书中作者建议尽量把对外公布出来的属性设置为只读，在实现文件内部设为读写。具体做法是：

在头文件中，设置对象属性为`readonly`，在实现文件中设置为`readwrite`。这样一来，在外部就只能读取该数据，而不能修改它，使得这个类的实例所持有的数据更加安全。

而且，对于集合类的对象，更应该仔细考虑是否可以将其设为可变的。

如果在公开部分只能设置其为只读属性，那么就在非公开部分存储一个可变型。这样一来，当在外部获取这个属性时，获取的只是内部可变型的一个不可变版本,例如：

在公共API中：

    @interface EOCPerson : NSObject
    
    @property (nonatomic, copy, readonly) NSString *firstName;
    @property (nonatomic, copy, readonly) NSString *lastName;
    @property (nonatomic, strong, readonly) NSSet *friends //向外公开的不可变集合
    
    - (id)initWithFirstName:(NSString*)firstName lastName:(NSString*)lastName;
    - (void)addFriend:(EOCPerson*)person;
    - (void)removeFriend:(EOCPerson*)person;
    
    @end
    
    复制代码

> 在这里，我们将friends属性设置为不可变的set。然后，提供了来增加和删除这个set里的元素的公共接口。

在实现文件里：

    
    @interface EOCPerson ()
    
    @property (nonatomic, copy, readwrite) NSString *firstName;
    @property (nonatomic, copy, readwrite) NSString *lastName;
    
    @end
    
    @implementation EOCPerson {
         NSMutableSet *_internalFriends;  //实现文件里的可变集合
    }
    
    - (NSSet*)friends {
         return [_internalFriends copy]; //get方法返回的永远是可变set的不可变型
    }
    
    - (void)addFriend:(EOCPerson*)person {
        [_internalFriends addObject:person]; //在外部增加集合元素的操作
        //do something when add element
    }
    
    - (void)removeFriend:(EOCPerson*)person {
        [_internalFriends removeObject:person]; //在外部移除元素的操作
        //do something when remove element
    }
    
    - (id)initWithFirstName:(NSString*)firstName lastName:(NSString*)lastName {
    
         if ((self = [super init])) {
            _firstName = firstName;
            _lastName = lastName;
            _internalFriends = [NSMutableSet new];
        }
     return self;
    }
    
    复制代码

我们可以看到，在实现文件里，保存一个可变set来记录外部的增删操作。

这里最重要的代码是：

    - (NSSet*)friends {
     return [_internalFriends copy];
    }
    复制代码

> 这个是friends属性的获取方法：它将当前保存的可变set复制了一不可变的set并返回。因此，外部读取到的set都将是不可变的版本。

等一下，有个疑问：

> 在公共接口设置不可变set 和 将增删的代码放在公共接口中是否矛盾的？

答案：**并不矛盾!**

因为如果将friends属性设置为可变的，那么外部就可以随便更改set集合里的数据，这里的更改，仅仅是底层数据的更改，并不伴随其他任何操作。 然而有时，我们需要在更改set数据的同时**要执行隐秘在实现文件里的其他工作**，那么如果在外部随意更改这个属性的话，显然是达不到这种需求的。

因此，我们需要提供给外界**我们定制的**增删的方法，并不让外部”自行“增删。

第19条：使用清晰而协调的命名方式
=================

在给OC的方法取名字的时候要充分利用OC方法的命名优势，取一个**语义清晰**的方法名！什么叫语义清晰呢?就是说读起来像是一句话一样。

我们看一个例子：

先看名字取得不好的：

    //方法定义
    - (id)initWithSize:(float)width :(float)height;
    
    //方法调用
    EOCRectangle *aRectangle =[[EOCRectangle alloc] initWithSize:5.0f :10.0f];
    复制代码

> 这里定义了Rectangle的初始化方法。虽然直观上可以知道这个方法通过传入的两个参数来组成矩形的size，但是我们并不知道哪个是矩形的宽，哪个是矩形的高。 来看一下正确的🌰 ：

    //方法定义
    - (id)initWithWidth:(float)width height:(float)height;
    
    //方法调用
    EOCRectangle *aRectangle =[[EOCRectangle alloc] initWithWidth:5.0f height:10.0f];
    
    复制代码

> 这个方法名就很好的诠释了该方法的意图：这个类的初始化是需要宽度和高度的。而且，哪个参数是高度，哪个参数是宽度，看得人一清二楚。永远要记得：**代码是给人看的**。

笔者自己总结的方法命名规则：

> 每个冒号左边的方法部分最好与右边的参数名一致。

对于返回值是布尔值的方法，我们也要注意命名的规范：

*   获取”是否“的布尔值，应该增加“is”前缀：

    
    
    - isEqualToString:
    
    复制代码

获取“是否有”的布尔值，应该增加“has”前缀：

    
    - hasPrefix:
    
    复制代码

第20条：为私有方法名加前缀
==============

建议在实现文件里将非公开的方法都加上前缀，便于调试，而且这样一来也很容易区分哪些是公共方法，哪些是私有方法。因为往往公共方法是不便于任意修改的。

在这里，作者举了个例子：

    
    #import <Foundation/Foundation.h>
    
    @interface EOCObject : NSObject
    
    - (void)publicMethod;
    
    @end
    
    
    @implementation EOCObject
    
    - (void)publicMethod {
     /* ... */
    }
    
    - (void)p_privateMethod {
     /* ... */
    }
    
    @end
    
    复制代码

> **注意**： 不要用下划线来区分私有方法和公共方法，因为会和苹果公司的API重复。

第23条：通过委托与数据源协议进行对象间通信
======================

如果给委托对象发送消息，那么必须提前判断该委托对象是否实现了该消息：

    
    NSData *data = /* data obtained from network */;
    
    if ([_delegate respondsToSelector: @selector(networkFetcher:didReceiveData:)])
    {
            [_delegate networkFetcher:self didReceiveData:data];
    }
    
    复制代码

而且，最好再加上一个判断：判断委托对象是否存在

    
    NSData *data = /* data obtained from network */;
    
    if ( (_delegate) && ([_delegate respondsToSelector: @selector(networkFetcher:didReceiveData:)]))
    {
            [_delegate networkFetcher:self didReceiveData:data];
    }
    
    复制代码

对于代理模式，在iOS中分为两种：

*   普通的委托模式:信息从类流向委托者
*   信息源模式:信息从数据源流向类

![普通的委托 | 信息源](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/1/5/160c56b521fd5efb~tplv-t2oaga2asx-zoom-in-crop-mark:4536:0:0:0.image)

> 就好比tableview告诉它的代理（delegate）“我被点击了”；而它的数据源（data Source）告诉它“你有这些数据”。仔细回味一下，这两个信息的传递方向是相反的。

第24条：将类的实现代码分散到便于管理的数个分类中
=========================

通常一个类会有很多方法，而这些方法往往可以用某种特有的逻辑来分组。我们可以利用OC的分类机制，将类的这些方法按一定的逻辑划入几个分区中。

例子：

无分类的类：

    #import <Foundation/Foundation.h>
    
    @interface EOCPerson : NSObject
    
    @property (nonatomic, copy, readonly) NSString *firstName;
    @property (nonatomic, copy, readonly) NSString *lastName;
    @property (nonatomic, strong, readonly) NSArray *friends;
    
    - (id)initWithFirstName:(NSString*)firstName lastName:(NSString*)lastName;
    
    /* Friendship methods */
    - (void)addFriend:(EOCPerson*)person;
    - (void)removeFriend:(EOCPerson*)person;
    - (BOOL)isFriendsWith:(EOCPerson*)person;
    
    
    /* Work methods */
    - (void)performDaysWork;
    - (void)takeVacationFromWork;
    
    
    /* Play methods */
    - (void)goToTheCinema;
    - (void)goToSportsGame;
    
    
    @end
    
    复制代码

分类之后：

    #import <Foundation/Foundation.h>
    
    
    @interface EOCPerson : NSObject
    
    @property (nonatomic, copy, readonly) NSString *firstName;
    @property (nonatomic, copy, readonly) NSString *lastName;
    @property (nonatomic, strong, readonly) NSArray *friends;
    
    
    
    - (id)initWithFirstName:(NSString*)firstName
    
    lastName:(NSString*)lastName;
    
    @end
    
    
    
    @interface EOCPerson (Friendship)
    
    - (void)addFriend:(EOCPerson*)person;
    - (void)removeFriend:(EOCPerson*)person;
    - (BOOL)isFriendsWith:(EOCPerson*)person;
    
    @end
    
    
    
    @interface EOCPerson (Work)
    
    - (void)performDaysWork;
    - (void)takeVacationFromWork;
    
    @end
    
    
    
    @interface EOCPerson (Play)
    
    - (void)goToTheCinema;
    - (void)goToSportsGame;
    
    @end
    
    复制代码

其中，FriendShip分类的实现代码可以这么写：

    
    // EOCPerson+Friendship.h
    #import "EOCPerson.h"
    
    
    @interface EOCPerson (Friendship)
    
    - (void)addFriend:(EOCPerson*)person;
    - (void)removeFriend:(EOCPerson*)person;
    - (BOOL)isFriendsWith:(EOCPerson*)person;
    
    @end
    
    
    // EOCPerson+Friendship.m
    #import "EOCPerson+Friendship.h"
    
    
    @implementation EOCPerson (Friendship)
    
    - (void)addFriend:(EOCPerson*)person {
     /* ... */
    }
    
    - (void)removeFriend:(EOCPerson*)person {
     /* ... */
    }
    
    - (BOOL)isFriendsWith:(EOCPerson*)person {
     /* ... */
    }
    
    @end
    
    复制代码

> 注意：在新建分类文件时，一定要引入被分类的类文件。

通过分类机制，可以把类代码分成很多个易于管理的功能区，同时也便于调试。因为分类的方法名称会包含分类的名称，可以马上看到该方法属于哪个分类中。

利用这一点，我们可以创建名为Private的分类，将所有私有方法都放在该类里。这样一来，我们就可以根据private一词的出现位置来判断调用的合理性，这也是一种编写“自我描述式代码（self-documenting）”的办法。

第25条：总是为第三方类的分类名称加前缀
====================

分类机制虽然强大，但是如果分类里的方法与原来的方法名称一致，那么分类的方法就会覆盖掉原来的方法，而且总是以最后一次被覆盖为基准。

因此，我们应该以命名空间来区别各个分类的名称与其中定义的方法。在OC里的做法就是给这些方法加上某个共用的前缀。例如：

    @interface NSString (ABC_HTTP)
    
    // Encode a string with URL encoding
    - (NSString*)abc_urlEncodedString;
    
    // Decode a URL encoded string
    - (NSString*)abc_urlDecodedString;
    
    @end
    
    复制代码

因此，如果我们想给第三方库或者iOS框架里的类添加分类时，最好将分类名和方法名加上前缀。

第26条:勿在分类中声明属性
==============

除了实现文件里的class-continuation分类中可以声明属性外，其他分类无法向类中新增实例变量。

因此，类所封装的全部数据都应该定义在主接口中，这里是唯一能够定义实例变量的地方。

关于分类，需要强调一点：

> 分类机制，目标在于扩展类的功能，而不是封装数据。

第27条：使用class-continuation分类 隐藏实现细节
==================================

通常，我们需要减少在公共接口中向外暴露的部分(包括属性和方法)，而因此带给我们的局限性可以利用class-continuation分类的特性来补偿：

*   可以在class-continuation分类中增加实例变量。
*   可以在class-continuation分类中将公共接口的只读属性设置为读写。
*   可以在class-continuation分类中遵循协议，使其不为人知。

第31条：在dealloc方法中只释放引用并解除监听
==========================

永远不要自己调用dealloc方法，运行期系统会在适当的时候调用它。根据性能需求我们有时需要在dealloc方法中做一些操作。那么我们可以在dealloc方法里做什么呢？

*   释放对象所拥有的所有引用，不过ARC会自动添加这些释放代码，可以不必操心。
*   而且对象拥有的其他非OC对象也要释放（CoreFoundation对象就必须手动释放）
*   释放原来的观测行为：注销通知。如果没有及时注销，就会向其发送通知，使得程序崩溃。

举个简单的🌰 ：

    
    - (void)dealloc {
    
         CFRelease(coreFoundationObject);
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    }
    
    复制代码

> **尤其注意**：在dealloc方法中不应该调用其他的方法，因为如果这些方法是异步的，并且回调中还要使用当前对象，那么很有可能当前对象已经被释放了，会导致崩溃。

> 并且在dealloc方法中也不能调用属性的存取方法，因为很有可能在这些方法里还有其他操作。而且这个属性还有可能处于键值观察状态，该属性的观察者可能会在属性改变时保留或者使用这个即将回收的对象。

第36条：不要使用retainCount
====================

在非ARC得环境下使用retainCount可以返回当前对象的引用计数，但是在ARC环境下调用会报错，因为该方法已经被废弃了 。

它被废弃的原因是因为它所返回的引用计数只能反映对象某一时刻的引用计数，而无法“预知”对象将来引用计数的变化（比如对象当前处于自动释放池中，那么将来就会自动递减引用计数）。

第46条：不要使用dispatch\_get\_current\_queue
======================================

我们无法用某个队列来描述“当前队列”这一属性，因为派发队列是按照层级来组织的。

那么什么是队列的层级呢?

![队列的层及分布](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/1/5/160c56b52e7c28e4~tplv-t2oaga2asx-zoom-in-crop-mark:4536:0:0:0.image)

安排在某条队列中的快，会在其上层队列中执行，而层级地位最高的那个队列总是全局并发队列。

在这里，B，C中的块会在A里执行。但是D中的块，可能与A里的块并行，因为A和D的目标队列是并发队列。

正因为有了这种层级关系，所以检查当前队列是并发的还是非并发的就不会总是很准确。

第48条：多用块枚举，少用for循环
==================

当遍历集合元素时，建议使用块枚举，因为相对于传统的for循环，它更加高效，而且简洁,还能获取到用传统的for循环无法提供的值：

我们首先看一下传统的遍历：

传统的for遍历
--------

    NSArray *anArray = /* ... */;
    for (int i = 0; i < anArray.count; i++) {
       id object = anArray[i];
       // Do something with 'object'
    }
    
    
    
    // Dictionary
    NSDictionary *aDictionary = /* ... */;
    NSArray *keys = [aDictionary allKeys];
    for (int i = 0; i < keys.count; i++) {
       id key = keys[i];
       id value = aDictionary[key];
       // Do something with 'key' and 'value'
    }
    
    
    // Set
    NSSet *aSet = /* ... */;
    NSArray *objects = [aSet allObjects];
    for (int i = 0; i < objects.count; i++) {
       id object = objects[i];
       // Do something with 'object'
    
    }
    
    复制代码

我们可以看到，在遍历NSDictionary,和NSet时，我们又新创建了一个数组。虽然遍历的目的达成了，但是却加大了系统的开销。

利用快速遍历：
-------

    NSArray *anArray = /* ... */;
    for (id object in anArray) {
     // Do something with 'object'
    }
    
    // Dictionary
    NSDictionary *aDictionary = /* ... */;
    for (id key in aDictionary) {
     id value = aDictionary[key];
     // Do something with 'key' and 'value'
    
    }
    
    
    NSSet *aSet = /* ... */;
    for (id object in aSet) {
     // Do something with 'object'
    }
    
    复制代码

这种快速遍历的方法要比传统的遍历方法更加简洁易懂，但是缺点是无法方便获取元素的下标。

利用基于block的遍历：
-------------

    NSArray *anArray = /* ... */;
    [anArray enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop){
    
       // Do something with 'object'
       if (shouldStop) {
          *stop = YES; //使迭代停止
      }
    
    }];
    
    
    “// Dictionary
    NSDictionary *aDictionary = /* ... */;
    [aDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop){
         // Do something with 'key' and 'object'
         if (shouldStop) {
            *stop = YES;
        }
    }];
    
    
    // Set
    NSSet *aSet = /* ... */;
    [aSet enumerateObjectsUsingBlock:^(id object, BOOL *stop){
         // Do something with 'object'
         if (shouldStop) {
            *stop = YES;
        }
    复制代码

我们可以看到，在使用块进行快速枚举的时候，我们可以不创建临时数组。虽然语法上没有快速枚举简洁，但是我们可以获得数组元素对应的序号，字典元素对应的键值，而且，我们还可以随时令遍历终止。

利用快速枚举和块的枚举还有一个优点：能够修改块的方法签名

    for (NSString *key in aDictionary) {
             NSString *object = (NSString*)aDictionary[key];
            // Do something with 'key' and 'object'
    }
    复制代码

    
    NSDictionary *aDictionary = /* ... */;
    
        [aDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop){
    
                 // Do something with 'key' and 'obj'
    
    }];
    
    复制代码

如果我们可以知道集合里的元素类型，就可以修改签名。这样做的好处是：可以让编译期检查该元素是否可以实现我们想调用的方法，如果不能实现，就做另外的处理。这样一来，程序就能变得更加安全。

第50条：构建缓存时选用NSCache 而非NSDictionary
==================================

如果我们缓存使用得当，那么应用程序的响应速度就会提高。只有那种“重新计算起来很费事的数据，才值得放入缓存”，比如那些需要从网络获取或从磁盘读取的数据。

在构建缓存的时候很多人习惯用NSDictionary或者NSMutableDictionary，但是作者建议大家使用NSCache，它作为管理缓存的类，有很多特点要优于字典，因为它本来就是为了管理缓存而设计的。

NSCache优于NSDictionary的几点：
-------------------------

*   当系统资源将要耗尽时，NSCache具备自动删减缓冲的功能。并且还会先删减“最久未使用”的对象。
*   NSCache不拷贝键，而是保留键。因为并不是所有的键都遵从拷贝协议（字典的键是必须要支持拷贝协议的，有局限性）。
*   NSCache是线程安全的：不编写加锁代码的前提下，多个线程可以同时访问NSCache。

关于操控NSCache删减内容的时机
------------------

开发者可以通过两个尺度来调整这个时机：

*   缓存中的对象总数.
*   将对象加入缓存时，为其指定开销值。

对于开销值，只有在能很快计算出开销值的情况下，才应该考虑采用这个尺度，不然反而会加大系统的开销。

下面我们来看一下缓存的用法：缓存网络下载的数据

    // Network fetcher class
    typedef void(^EOCNetworkFetcherCompletionHandler)(NSData *data);
    
    @interface EOCNetworkFetcher : NSObject
    
    - (id)initWithURL:(NSURL*)url;
    - (void)startWithCompletionHandler:(EOCNetworkFetcherCompletionHandler)handler;
    
    @end
    
    // Class that uses the network fetcher and caches results
    @interface EOCClass : NSObject
    @end
    
    @implementation EOCClass {
         NSCache *_cache;
    }
    
    - (id)init {
    
         if ((self = [super init])) {
        _cache = [NSCache new];
    
         // Cache a maximum of 100 URLs
        _cache.countLimit = 100;
    
    
         /**
         * The size in bytes of data is used as the cost,
         * so this sets a cost limit of 5MB.
         */
        _cache.totalCostLimit = 5 * 1024 * 1024;
        }
     return self;
    }
    
    
    
    - (void)downloadDataForURL:(NSURL*)url { 
    
         NSData *cachedData = [_cache objectForKey:url];
    
         if (cachedData) {
    
             // Cache hit：存在缓存，读取
            [self useData:cachedData];
    
        } else {
    
             // Cache miss：没有缓存，下载
             EOCNetworkFetcher *fetcher = [[EOCNetworkFetcher alloc] initWithURL:url];      
    
            [fetcher startWithCompletionHandler:^(NSData *data){
             [_cache setObject:data forKey:url cost:data.length];    
            [self useData:data];
            }];
        }
    }
    @end
    
    复制代码

在这里，我们使用URL作为缓存的key，将总对象数目设置为100，将开销值设置为5MB。

NSPurgeableData
---------------

NSPurgeableData是NSMutableData的子类，把它和NSCache配合使用效果很好。

因为当系统资源紧张时，可以把保存NSPurgeableData的那块内存释放掉。

如果需要访问某个NSPurgeableData对象，可以调用`beginContentAccess`方发，告诉它现在还不应该丢弃自己所占据的内存。

在使用完之后，调用`endContentAccess`方法，告诉系统在必要时可以丢弃自己所占据的内存。

> 上面这两个方法类似于“引用计数”递增递减的操作，也就是说，只有当“引用计数”为0的时候，才可以在将来删去它所占的内存。

    
    - (void)downloadDataForURL:(NSURL*)url { 
    
          NSPurgeableData *cachedData = [_cache objectForKey:url];
    
          if (cachedData) {         
    
                // 如果存在缓存，需要调用beginContentAccess方法
                [cacheData beginContentAccess];
    
                 // Use the cached data
                [self useData:cachedData];
    
                 // 使用后，调用endContentAccess
                [cacheData endContentAccess];
    
    
            } else {
    
                     //没有缓存
                     EOCNetworkFetcher *fetcher = [[EOCNetworkFetcher alloc] initWithURL:url];    
    
                      [fetcher startWithCompletionHandler:^(NSData *data){                         NSPurgeableData *purgeableData = [NSPurgeableData dataWithData:data];
                             [_cache setObject:purgeableData forKey:url cost:purgeableData.length];
    
                              // Don't need to beginContentAccess as it begins            
                              // with access already marked
                               // Use the retrieved data
                                [self useData:data];
    
                                 // Mark that the data may be purged now
                                [purgeableData endContentAccess];
    
                }];
          }
    }
    复制代码

> 注意：

在我们可以直接拿到purgeableData的情况下需要执行`beginContentAccess`方法。然而，在创建purgeableData的情况下，是不需要执行beginContentAccess，因为在创建了purgeableData之后，其引用计数会自动+1；

第51条: 精简initialize 与 load的实现代码
==============================

load方法
------

    +(void)load;
    复制代码

每个类和分类在加入运行期系统时，都会调用`load`方法，而且仅仅调用一次，可能有些小伙伴习惯在这里调用一些方法，但是作者建议尽量不要在这个方法里调用其他方法，尤其是使用其他的类。原因是每个类载入程序库的时机是不同的，如果该类调用了还未载入程序库的类，就会很危险。

initialize方法
------------

    +(void)initialize;
    复制代码

这个方法与`load`方法类似，区别是这个方法会在程序**首次**调用这个类的时候调用（惰性调用），而且只调用一次（绝对不能主动使用代码调用）。

值得注意的一点是，如果子类没有实现它，它的超类却实现了，那么就会运行超类的代码：这个情况往往很容易让人忽视。

看一下🌰 ：

    #import <Foundation/Foundation.h>
    
    @interface EOCBaseClass : NSObject
    @end
    
    @implementation EOCBaseClass
    + (void)initialize {
     NSLog(@"%@ initialize", self);
    }
    @end
    
    @interface EOCSubClass : EOCBaseClass
    @end
    
    @implementation EOCSubClass
    @end
    复制代码

当使用EOCSubClass类时，控制台会输出两次打印方法：

    EOCBaseClass initialize
    EOCSubClass initialize
    复制代码

因为子类EOCSubClass并没有覆写`initialize`方法，那么自然会调用其父类EOCBaseClass的方法。 解决方案是通过检测类的类型的方法：

    + (void)initialize {
       if (self == [EOCBaseClass class]) {
           NSLog(@"%@ initialized", self);
        }
    }
    复制代码

这样一来，EOCBaseClass的子类EOCSubClass就无法再调用`initialize`方法了。 我们可以察觉到，如果在这个方法里执行过多的操作的话，会使得程序难以维护，也可能引起其他的bug。因此，在`initialize`方法里，最好只是设置内部的数据，不要调用其他的方法，因为将来可能会给这些方法添加其它的功能，那么会可能会引起难以排查的bug。

第52条: 别忘了NSTimer会保留其目标对象
========================

在使用NSTimer的时候，NSTimer会生成指向其使用者的引用，而其使用者如果也引用了NSTimer，那么就会生成保留环。

    #import <Foundation/Foundation.h>
    
    @interface EOCClass : NSObject
    - (void)startPolling;
    - (void)stopPolling;
    @end
    
    
    @implementation EOCClass {
         NSTimer *_pollTimer;
    }
    
    
    - (id)init {
         return [super init];
    }
    
    
    - (void)dealloc {
        [_pollTimer invalidate];
    }
    
    
    - (void)stopPolling {
    
        [_pollTimer invalidate];
        _pollTimer = nil;
    }
    
    
    - (void)startPolling {
       _pollTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                     target:self
                                                   selector:@selector(p_doPoll)
                                                   userInfo:nil
                                                    repeats:YES];
    }
    
    - (void)p_doPoll {
        // Poll the resource
    }
    
    @end
    
    复制代码

> 在这里，在EOCClass和\_pollTimer之间形成了保留环，如果不主动调用`stopPolling`方法就无法打破这个保留环。像这种通过主动调用方法来打破保留环的设计显然是不好的。

而且，如果通过回收该类的方法来打破此保留环也是行不通的，因为会将该类和NSTimer孤立出来，形成“孤岛”:

![孤立了类和它的NSTimer](https://p1-jj.byteimg.com/tos-cn-i-t2oaga2asx/gold-user-assets/2018/1/5/160c56b533af43bd~tplv-t2oaga2asx-zoom-in-crop-mark:4536:0:0:0.image)

这可能是一个极其危险的情况，因为NSTimer没有消失，它还有可能持续执行一些任务，不断消耗系统资源。而且，如果任务涉及到下载，那么可能会更糟。。

那么如何解决呢？ 通过“块”来解决！

通过给NSTimer增加一个分类就可以解决：

    #import <Foundation/Foundation.h>
    
    @interface NSTimer (EOCBlocksSupport)
    
    + (NSTimer*)eoc_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                             block:(void(^)())block
                                             repeats:(BOOL)repeats;
    @end
    
    
    
    @implementation NSTimer (EOCBlocksSupport)
    
    + (NSTimer*)eoc_scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                             block:(void(^)())block
                                            repeats:(BOOL)repeats
    {
                 return [self scheduledTimerWithTimeInterval:interval
                                                      target:self
                                                    selector:@selector(eoc_blockInvoke:)
                                                    userInfo:[block copy]
                                                     repeats:repeats];
    
    }
    
    
    + (void)eoc_blockInvoke:(NSTimer*)timer {
         void (^block)() = timer.userInfo;
             if (block) {
                 block();
            }
    }
    @end
    
    复制代码

我们在NSTimer类里添加了方法，我们来看一下如何使用它：

    - (void)startPolling {
    
             __weak EOCClass *weakSelf = self;    
             _pollTimer = [NSTimer eoc_scheduledTimerWithTimeInterval:5.0 block:^{
    
                   EOCClass *strongSelf = weakSelf;
                   [strongSelf p_doPoll];
              }
    
                                                              repeats:YES];
    }
    
    复制代码

在这里，创建了一个self的弱引用，然后让块捕获了这个self变量，让其在执行期间存活。

一旦外界指向EOC类的最后一个引用消失，该类就会被释放，被释放的同时，也会向NSTimer发送invalidate消息（因为在该类的dealloc方法中向NSTimer发送了invalidate消息）。

而且，即使在dealloc方法里没有发送invalidate消息，因为块里的weakSelf会变成nil，所以NSTimer同样会失效。

最后的话
====

总的来说这一部分还是比较容易理解的，更多的只是教我们一些编写OC程序的规范，并没有深入讲解技术细节。

而三部曲的最后一篇：技巧篇则着重讲解了一些在编写OC代码的过程中可以使用的一些技巧。广义上来讲，这些技巧也可以被称为“规范”，例如“提供全能初始化方法”这一节，但是这些知识点更像是一些“设计模式”目的更偏向于在于解决一些实际问题，因此将这些知识点归类为“技巧类”。

因为第三篇的内容稍微难一点，所以笔者打算再好好消化几天，将第三篇的初稿再三润饰之后呈献给大家~

本文已同步到个人博客：[传送门](https://link.juejin.cn?target=https%3A%2F%2Fknightsj.github.io%2F2016%2F09%2F09%2F%25E3%2580%258AEOC%25E3%2580%258B%25E8%25B6%2585%25E7%25BA%25A7%25E5%25B9%25B2%25E8%25B4%25A7%25E4%25B8%2589%25E9%2583%25A8%25E6%259B%25B2%25EF%25BC%2588%25E4%25BA%258C%25EF%25BC%2589%25EF%25BC%259A%25E8%25A7%2584%25E8%258C%2583%25E7%25AF%2587%2F "https://knightsj.github.io/2016/09/09/%E3%80%8AEOC%E3%80%8B%E8%B6%85%E7%BA%A7%E5%B9%B2%E8%B4%A7%E4%B8%89%E9%83%A8%E6%9B%B2%EF%BC%88%E4%BA%8C%EF%BC%89%EF%BC%9A%E8%A7%84%E8%8C%83%E7%AF%87/")

其他两篇的传送门：

[《Effective Objective-C 》干货三部曲（一）：概念篇](https://juejin.cn/post/6844903545636913159 "https://juejin.cn/post/6844903545636913159")

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