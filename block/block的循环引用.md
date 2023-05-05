### Block的循环引用
#### ARC下的解决block循环引用
 1、 将该对象使用 `__weak` 修饰符修饰之后再在 Block 中使用。 `id weak weakSelf = self;`
    或者 `weak __typeof(&*self)weakSelf = self` 该方法可以设置宏
      `__weak` ：不会产生强引用，指向的对象销毁时，会自动让指针置为 ni1
      
 2、 使用 `unsafe_unretained` 关键字，用法与 `__weak` 一致。
 `unsafe_unretained` 不会产生强引用，不安全，指向的对象销毁时，指针存储的地址值不变。
![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/36e08256d31948d68cefda62413da584~tplv-k3u1fbpfcp-watermark.image?)

3、也可以使用 `__block` 来解决循环引用问题，用法为： `__block id weakSelf = self;`，但不推荐使用。因为必须要调用该 block 方案才能生效，因为需要及时的将 `__block` 变量置为 nii。

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f08f2b880b0f42b3a68df2140c3bc9cc~tplv-k3u1fbpfcp-watermark.image?)

####  MRC下解决block循环引用
MRC下可使用 `unsafe_unretained` 和 `__block` 进行解决，`__weak` 不能在 MRC 中使用。在 MRC 下 `__block` 的用法简单化了，可以照搬 `__weak` 的使用方法，两者用法一致。
用  `unsafe_unretained`  解决：
```Objective-C
unsafe_unretained id weakSelf = self;
self.block = ^{
    NSLog(@"%@", @[weakSelf]);
};
```

用 `__block`  解决：
```Objective-C
__block id weakSelf = self;
self.block = ^{
    NSLog(@"%@", @[weakself]);
};
```

其中最佳实践为 weak-strong dance 解法：
```Objective-C
__weak __typeof(self) weakSelf = self;
self.block = ^{
    __strong typeof(self) strongSelf = weakSelf;
    if (!strongSelf) {
         return;
    }
    NSLog(@"%@", @[strongSelf]);
};
self.block();
```

- weakSelf 是保证 block 内部(作用域内)不会产生循环引用
- strongSelf 是保证 block 内部(作用域内) self 不会被 block释放
- `if (!strongSelf) { return;}` 该代码作用：因为 weak 指针指向的对象，是可能被随时释放的。为了防止 self 在 block 外部被释放，比如其它线程内被释放。



讨论区 ：

- 如果对MRC下的循环引用解决方案感兴趣，可参见讨论  [《issue#50 -- 37 题 block 循环引用问题》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/50 ) 
- [《建议增加一个问题：__block和__weak的区别 #7》](https://github.com/ChenYilong/iOSInterviewQuestions/issues/7) 

在 [《iOS面试题集锦（附答案）》]( https://github.com/ChenYilong/iOSInterviewQuestions ) 中有这样一道题目： 
在block内如何修改block外部变量？（38题）答案如下：

### 在block内如何修改block外部变量？
默认情况下，在block中访问的外部变量是复制过去的，即：**写操作不对原变量生效**。但是你可以加上 `__block` 来让其写操作生效，示例代码如下:
 ```Objective-C
    __block int a = 0;
    void (^foo)(void) = ^{ 
        a = 1; 
    };
    foo(); 
    //这里，a的值被修改为1
 ```
面试官肯定会追问“为什么写操作就生效了？” 实际上需要有几个必要条件：
 - "将 auto 从栈 copy 到堆"
 - “将 auto 变量封装为结构体(对象)”


我会将本问题分下面几个部分，分别作答：
 - 该问题研究的是哪种 `block` 类型?
 - 在 `block` 内为什么不能修改 `block` 外部变量
 - 最优解及原理解析
 - 其他几种解法
 - 改外部变量必要条件之"将 auto 从栈 copy 到堆"
 - 改外部变量必要条件之“将 auto 变量封装为结构体(对象)”
 
### 在 `block` 内为什么不能修改 `block` 外部变量
为了保证 block 内部能够正常访问外部的变量，block 有一个变量捕获机制。
**Block不允许修改外部变量的值**。Apple这样设计，应该是考虑到了block的特殊性，block 本质上是一个对象，block 的花括号区域是对象内部的一个函数，变量进入 花括号，实际就是已经进入了另一个函数区域---改变了作用域。在几个作用域之间进行切换时，如果不加上这样的限制，变量的可维护性将大大降低。又比如我想在block内声明了一个与外部同名的变量，此时是允许呢还是不允许呢？只有加上了这样的限制，这样的情景才能实现。

所以 Apple 在编译器层面做了限制，如果在 block 内部试图修改 auto 变量（无修饰符），那么直接编译报错。
你可以把编译器的这种行为理解为：对 block 内部捕获到的 auto 变量设置为只读属性---不允许直接修改。

### 使用系统的某些block api（如UIView的block版本写动画时），是否也考虑引用循环问题？ 
 ```Objective-C
//判断如下几种情况,是否有循环引用? 是否有内存泄漏?

 //情况❶ UIViewAnimationsBlock
[UIView animateWithDuration:duration animations:^{ [self.superview layoutIfNeeded]; }]; 

 //情况❷ NSNotificationCenterBlock
[[NSNotificationCenter defaultCenter] addObserverForName:@"someNotification" 
                                                  object:nil 
                           queue:[NSOperationQueue mainQueue]
                                              usingBlock:^(NSNotification * notification) {
                                                    self.someProperty = xyz; }]; 

 //情况❸ NSNotificationCenterIVARBlock
  _observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"testKey"
                                                                object:nil
                                                                 queue:nil
                                                            usingBlock:^(NSNotification *note) {
      [self dismissModalViewControllerAnimated:YES];
  }];

 //情况❹ GCDBlock
    dispatch_group_async(self.operationGroup, self.serialQueue, ^{
        [self doSomething];
    });

//情况❺ NSOperationQueueBlock
[[NSOperationQueue mainQueue] addOperationWithBlock:^{ self.someProperty = xyz; }]; 

 ```


情况 | 循环引用 | 内存泄漏
:-------------:|:-------------:|:-------------:
情况 1 |不会循环应用 | 不会发生内存泄漏
情况 2 |不会循环引用 | 会发生内存泄漏
情况 3 |会循环引用   |会发生内存泄漏
情况 4 |不会循环引用 |不会发生内存泄漏
情况 5 |不会循环引用 |不会发生内存泄漏

情况一:
 ```Objective-C
 //思考：是否有内存泄漏?是否有循环引用?
[UIView animateWithDuration:duration animations:^{ [self.superview layoutIfNeeded]; }]; 
 ```
 其中 `block` 会立即执行，所以并不会持有 `block` 。 其中 `duration` 延迟时间并不能决定 `block` 执行的时机， `block` 始终是瞬间执行。
 这里涉及了 `CoreAnimation` （核心动画）相关的知识：
 
 首先分清下面几个结构概念：
 
  - UIView 层
  - Layer 层
  - data 数据层
  
  其中
  
  - UIView 层的`block` 仅仅是提供了类似快照 data 的变化。
  - 当真正执行  `Animation` 动画时才会将“原有状态”与“执行完 `block` 的状态”做一个差值，来去做动画。
 
这个问题关于循环引用的部分已经解答完毕，下面我们来扩展一下，探究一下系统 API 相关的内存泄漏问题。

情况二:
 ```Objective-C
 //思考：是否有内存泄漏?是否有循环引用?
[[NSNotificationCenter defaultCenter] addObserverForName:@"someNotification"  object:nil 
 queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * notification) {
        self.someProperty = xyz; }]; 
 ```
 
 情况三:
 
 ```Objective-C
 //思考：是否有内存泄漏?是否有循环引用?
  _observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"testKey" object:nil queue:nil usingBlock:^(NSNotification *note) {
      [self dismissModalViewControllerAnimated:YES];
  }];
 ```

情况四:

而下面的代码虽然有类似的结构但并不存在内存泄漏:
 ```Objective-C
  //思考：是否有内存泄漏?是否有循环引用?
    dispatch_group_async(self.operationGroup, self.serialQueue, ^{
        [self doSomething];
    });
 ```

情况二这里出现内存泄漏问题实际上是因为：

 - `[NSNoficationCenter defaultCenter]` 持有了 `block`
 - 这个 `block` 持有了 `self`; 
 - 而 `[NSNoficationCenter defaultCenter]` 是一个单例，因此这个单例持有了 `self`, 从而导致 `self` 不被释放。

这个结论可参考参考issue中讨论：[《第39题的一些疑问 #138》](https://github.com/ChenYilong/iOSInterviewQuestions/issues/138) 

以下来自[APPLE API文档 -- Instance Method
addObserverForName:object:queue:usingBlock:]( https://developer.apple.com/documentation/foundation/nsnotificationcenter/1411723-addobserverforname) ：

> The block is copied by the notification center and (the copy) held until the observer registration is removed.

但整个过程中并没有循环引用，因为 `self` 没有持有 `NotificationCenter` , 也没有持有 `block`。即使 `self` 持有这个`Observer`, 并没有任何证据或者文档标明 `Observer` 会持有这个`block`, 所以我之前的解释是不正确的。这里 Observer 应该是不持有 block 的，因为只需要 `NSNotificationCenter` 同时持有 `Observer` 和 `block` 即可实现 `API` 所提供的功能, 这里也不存在循环引用。

其中情况三:

存在循环引用

![https://github.com/ChenYilong](https://i.loli.net/2020/06/02/pDLde8Hgkt4X69u.gif)

根据上面的原理，思考一下情况五：

 ```Objective-C
  //思考：是否有内存泄漏?是否有循环引用?
[[NSOperationQueue mainQueue] addOperationWithBlock:^{ self.someProperty = xyz; }]; 
 ```
在 Gnustep 源码中可以证实
`[NSOperationQueue mainQueue]` 是单例，然后参考 `addOperationWithBlock` 源码可知：

虽然是单例，但它并不持有 `block`，不会造成循环引用，传递完成后就销毁了，不会造成无法释放的内存泄漏问题。

参考issue中讨论：[《第39题的一些疑问 #138》](https://github.com/ChenYilong/iOSInterviewQuestions/issues/138) 

-------------

针对情况四 `GCD` 的问题，实际上，self确实持有了queue; 而block也确实持有了self; 但是并没有证据或者文档表明这个queue一定会持有block; 而且即使queue持有了block, 在block执行完毕的时候，由于需要将任务从队列中移除，因此完全可以解除queue对block的持有关系，所以实际上这里也不存在循环引用。下面的测试代码可以验证这一点(其中`CYLUser`有一个属性name):

 ```Objective-C
        CYLUser *user = [[CYLUser alloc] init];
    dispatch_group_async(self.operationGroup, self.serialQueue, ^{
        NSLog(@"dispatch_async demoGCDRetainCycle");
        [self.testList addObject:@"demoGCDRetainCycle2"];
        user.name = @"测试";
        NSLog(@"Detecor 's name: %@", user.name);
    });
 ```
那么会看到先打印出 `dispatch_async demoGCDRetainCycle`, 然后打印出这个 `user` 的name, 然后执行 `CYLUser` 的 `-dealloc` 方法。也就是说在这个block执行完毕的时候，仅由这个block持有的 `user`就会被释放了, 从而验证这个 `block` 都被释放了，即使对应的 `queue` 还存在。   


什么时候这里会有循环引用呢？仍然是当 `self` 持有 `block` 的时候，例如这个 `block`是 `self` 的一个 `strong` 的属性，但这就和 `GCD` 的调用无关了，这个时候无论是否调用 `GCD` 的 `API` 都会有循环引用的。


检测代码中是否存在循环引用/内存泄漏问题，

- 可用 Xcode-instruments-Leak 工具查看
- 也可以使用可以使用 Xcode 的 Debug 工具--内存图查看，使用方法
- ![https://github.com/ChenYilong](https://i.loli.net/2020/06/02/pDLde8Hgkt4X69u.gif)
- 使用 Facebook 开源的一个检测工具  [***FBRetainCycleDetector***](https://github.com/facebook/FBRetainCycleDetector) 。