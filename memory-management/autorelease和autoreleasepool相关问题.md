### 自动释放池
-   自动释放池的主要底层数据结构是：`__AtAutoreleasePool`、`AutoreleasePoolPage`
-   `__AtAutoreleasePool`结构体
```
 struct __AtAutoreleasePool {
    __AtAutoreleasePool() { // 构造函数，在创建结构体的时候调用
        atautoreleasepoolobj = objc_autoreleasePoolPush();
    }
 
    ~__AtAutoreleasePool() { // 析构函数，在结构体销毁的时候调用
        objc_autoreleasePoolPop(atautoreleasepoolobj);
    }
 
    void * atautoreleasepoolobj;
 };
```
代码
```
@autoreleasepool {
    Person *p4 = [[[MJPerson alloc] init] autorelease];
}
```
内部转换成
```
atautoreleasepoolobj = objc_autoreleasePoolPush();
Person *person = [[[Person alloc] init] autorelease];
objc_autoreleasePoolPop(atautoreleasepoolobj);
```
-   `AutoreleasePoolPage`

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e314192429034e0db3b15c5d01054ce9~tplv-k3u1fbpfcp-watermark.image?)
-   `magic` 用来校验 AutoreleasePoolPage 的结构是否完整
-   `next`指向最新添加的 autoreleased 对象的下一个位置，初始化时指向 begin()
-   `thread` 指向当前线程
-   `parent`指向父结点，第一个结点的 parent 值为 nil
-   `child` 指向子结点，最后一个结点的 child 值为 nil
-   `depth` 代表深度，从 0 开始，往后递增 1
-   `hiwat` 代表 high water mark

#### AutoreleasePoolPage的结构

-   每个`AutoreleasePoolPage`对象占用`4096`字节内存，除了用来存放它内部的成员变量，剩下的空间用来存放`autorelease`对象的地址
-   所有的`AutoreleasePoolPage`对象通过`双向链表`的形式连接在一起

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/306bd4121dfc496391b577259494ad51~tplv-k3u1fbpfcp-watermark.image?)
  ```
atautoreleasepoolobj = objc_autoreleasePoolPush();
Person *person = [[[Person alloc] init] autorelease];
objc_autoreleasePoolPop(atautoreleasepoolobj);
```
上图的执行步骤说明

-   调用`push`方法会将一个`POOL_BOUNDARY`入栈，并且返回其存放的内存地址，即返回给`atautoreleasepoolobj`。
-   调用`pop`方法时传入一个`POOL_BOUNDARY`的内存地址，会从最后一个入栈的对象开始发送`release`消息，直到遇到这个`POOL_BOUNDARY`
-   `id *next`指向了下一个能存放`autorelease`对象地址的区域

代码例子如下
```
使用系统的私有方法，该方法不对外开放，但是真实存在
extern void _objc_autoreleasePoolPrint(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool { //  r1 = push()
        
        Person *p1 = [[[Person alloc] init] autorelease];
        Person *p2 = [[[Person alloc] init] autorelease];
        
        @autoreleasepool { // r2 = push()
            for (int i = 0; i < 5; i++) {
                Person *p3 = [[[Person alloc] init] autorelease];
            }
            
            @autoreleasepool { // r3 = push()
                Person *p4 = [[[Person alloc] init] autorelease];
                _objc_autoreleasePoolPrint();
            } // pop(r3)
        } // pop(r2)
    } // pop(r1)
    return 0;
}
```

执行结果

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b658c13d47954bb793e2d1875785fbee~tplv-k3u1fbpfcp-watermark.image?)
-   因为只打印了一个`PAGE`，所以说明他们是在同一个`AutoreleasePoolPage`，只是每次一个新的`autoreleasepool`，都会插入一个`POOL_BOUNDARY`。

-   每次释放对象时，都是从后往前释放，直到遇到`POOL_BOUNDARY`为止。

代码例子二
```
int main(int argc, const char * argv[]) {
    @autoreleasepool { //  r1 = push()
        @autoreleasepool {
            MJPerson *p1 = [[[MJPerson alloc] init] autorelease];
            _objc_autoreleasePoolPrint();
        }
        return 0;
    }
}
```

执行结果

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/afbd6e3a5eda44c9873db610dd077823~tplv-k3u1fbpfcp-watermark.image?)

```
int main(int argc, const char * argv[]) {
    @autoreleasepool { //  r1 = push()
        
        MJPerson *p1 = [[[MJPerson alloc] init] autorelease];
        MJPerson *p2 = [[[MJPerson alloc] init] autorelease];
        
        @autoreleasepool { // r2 = push()
            for (int i = 0; i < 600; i++) {
                MJPerson *p3 = [[[MJPerson alloc] init] autorelease];
            }

            @autoreleasepool { // r3 = push()
                MJPerson *p4 = [[[MJPerson alloc] init] autorelease];
                _objc_autoreleasePoolPrint();
            } // pop(r3)

        } // pop(r2)
        
    } // pop(r1)
    return 0;
}
```

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/53e4dee683134fabb71dfb54b2524adf~tplv-k3u1fbpfcp-watermark.image?)

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7589dfc4b55345968b36668ff885fd02~tplv-k3u1fbpfcp-watermark.image?)

### Runloop和Autorelease

iOS在主线程的Runloop中注册了2个Observer
-   第1个Observer监听了`kCFRunLoopEntry`事件，会调用`objc_autoreleasePoolPush()`
-   第2个Observer

<1> 监听了`kCFRunLoopBeforeWaiting`事件，会先调用`objc_autoreleasePoolPop()`、再调用`objc_autoreleasePoolPush()`  
<2> 监听了`kCFRunLoopBeforeExit`事件，会调用`objc_autoreleasePoolPop()`

### autorelease对象在什么时机会被调用release
```
- (void)viewDidLoad {
    [super viewDidLoad];
    // 这个Person什么时候调用release，是由RunLoop来控制的
    // 它可能是在某次RunLoop循环中，RunLoop休眠之前调用了release
    MJPerson *person = [[[MJPerson alloc] init] autorelease];
    NSLog(@"%s", __func__);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"%s", __func__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%s", __func__);
}
```
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cf449717c93c4f8598474568d58430aa~tplv-k3u1fbpfcp-watermark.image?)
-   得出结论，`autorelease`并不是根据对象的`作用域`来决定释放时机。
-   实际上，`autorelease`释放对象的依据是`Runloop`，简单说，`runloop`就是`iOS`中的消息循环机制，当一个`runloop`结束时系统才会一次性清理掉被`autorelease`处理过的对象，其实本质上说是在`本次runloop迭代结束时`清理掉被本次迭代期间被放到`autorelease pool`中的对象的。至于何时runloop结束并没有固定的duration。
-   本次runloop迭代休眠之前调用了`objc_autoreleasePoolPop()`方法，然后调用`release`，从而释放`Person`对象。

 ### 方法里有局部对象， 出了方法后会立即释放吗
 ```
- (void)viewDidLoad {
    [super viewDidLoad];
    Person *person = [[Person alloc] init];
    NSLog(@"%s", __func__);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"%s", __func__);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"%s", __func__);
}
```

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8157287aa2c34e51b3e49cba86b10caf~tplv-k3u1fbpfcp-watermark.image?)
通过打印结果可知，当`person`对象出了其作用域后就销毁，即系统会在它出作用域的时候，自动调用其`release`方法。

既然由`runloop`来决定对象释放时机而不是作用域，那么，在一个`{}`内使用循环大量创建对象就有可能带来内存上的问题，大量对象会被创建而没有及时释放，这时候就需要靠我们人工的干预`autorelease`的释放了。

上文有提到`autorelease pool`，一旦一个对象被`autorelease`，则该对象会被放到iOS的一个池：`autorelease pool`，其实这个`pool`本质上是一个`stack`，扔到pool中的对象等价于`入栈`。我们把需要及时释放掉的代码块放入我们生成的`autorelease pool`中，结束后清空这个自定义的`pool`，主动地让`pool`清空掉，从而达到及时释放内存的目的。优化代码如下

```
@autoreleasePool{
    //domeSomeThing;
}
```
### 什么时候用@autoreleasepool
  根据 [Apple的文档](https://link.jianshu.com/?t=https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmAutoreleasePools.html) ，使用场景如下：

-   写基于命令行的的程序时，就是没有UI框架，如`AppKit`等`Cocoa`框架时。
-   写循环，循环里面包含了大量临时创建的对象。（本文的例子）
-   创建了新的线程。（非`Cocoa`程序创建线程时才需要）
-   长时间在后台运行的任务。

> 1.  `autorelease 机制`基于 `UI framework`。因此写非UI framework的程序时，需要自己管理对象生存周期。
> 1.  `autorelease` 触发时机发生在下一次`runloop`的时候。因此如何在一个大的循环里不断创建`autorelease对象`，那么这些对象在下一次runloop回来之前将没有机会被释放，可能会耗尽内存。这种情况下，可以在`循环内部`显式使用`@autoreleasepool {}`将`autorelease`对象释放。
> 1.  自己创建的线程。`Cocoa`的应用都会维护自己`autoreleasepool`。因此，代码里`spawn`的线程，需要显式添加`autoreleasepool`。注意：如果是使用`POSIX API` 创建线程，而不是`NSThread`，那么不能使用`Cocoa`，因为`Cocoa`只能在`多线程（multithreading）`状态下工作。但可以使用NSThread创建一个马上销毁的线程，使得Cocoa进入multithreading状态。
### 什么对象会加入Autoreleasepool中

-   使用`alloc`、`new`、`copy`、`mutableCopy`的方法进行初始化时，会自己持有对象，在适当的位置release。
-   使用`+array、+dictionary`等类方法会自动将返回值的`对象`注册到`Autoreleasepool`。
-   `__weak`修饰的对象，为了保证在引用时不被废弃，会注册到`Autoreleasepool`中。
-   `id的指针`或`对象的指针`，在没有显示指定时会被注册到`Autoleasepool`中。

### autoreleasepool使用注意点

![image.jpeg](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c73b37838119471db6903817b52b9d36~tplv-k3u1fbpfcp-watermark.image?)
槽点：创建的`item`会被加到数组中，本身就不会释放，为什么要加`autoreleasepool`呢，无意义

![image.jpeg](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7987b219a4784fe7bdfd30ddd333e0ec~tplv-k3u1fbpfcp-watermark.image?)
实际测试下来也并没有发生内存堆积导致的峰值升高,去掉autreleasepool也不会导致内存升高，因为是alloc init方式=创建，并不属于autreleasepool管理。只有被`autorelease`的对象才会被加入到自动释放池中受`autoreleasepool`的管理

![image.jpeg](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/67899e04bdbc4e908ed0865ef20597ba~tplv-k3u1fbpfcp-watermark.image?)
手动`autoreleasepool`+`__autoreleasing`或者非持有对象的方式创建对象才是`autoreleasepool`管理。

### __autoreleasing什么时候使用？

```
#import "ViewController.h"
@interface DRNode : NSObject
@property (nonatomic, strong) DRNode *next;
@end

@implementation DRNode
- (void)dealloc {
    //头结点析构后会释放自身持有的属性,导致next指向的node析构...不停的析构导致stack overflow引发的EXC_BAD_ACCESS
//让_next = nil;可以缓解，栈溢出的问题，但是数据规模增大还是会栈溢出
    NSLog(@"_next = %@",_next);
    //最终解决方案是将next加入到自动释放池中，由自动释放池管理其释放，就不是造成因链式析构导致的stack overflow问题了
    __autoreleasing DRNode *next __attribute__((unused)) = _next;
    _next = nil;
}
@end

@interface ViewController ()
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DRNode *head = [[DRNode alloc] init];
    DRNode *cur = head;
    for (int i = 0 ; i < 500000; i++) {
        DRNode *node = [[DRNode alloc] init];
        cur.next = node;
        cur = node;
    }
}
@end
```