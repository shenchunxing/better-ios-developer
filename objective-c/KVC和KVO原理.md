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