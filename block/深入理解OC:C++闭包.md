背景
--

苹果的 Objective-C 编译器允许用户在同一个源文件里自由地混合使用 C++和 Objective-C，混编后的语言叫 Objective-C++。相对于其它语言（例如 Swift、Kotlin、Dart 等）和 C++的文件隔离和架桥通信（例如 Kotlin 使用`JNI`，Dart 使用`FFI`），Objective-C 和 C++的同文件混编方式无疑是令人舒畅的。`OC/C++`混编虽然可以在一个文件中进行编写，但是有一些注意事项需要了解：Objective-C++没有为 OC 类增加 C++的功能，也没有为 C++增加 OC 的功能，例如：不能用 OC 语法调用 C++对象，也不能为 OC 对象增加构造函数和析构函数，也不能将`this`和`self`互相替换使用。类的体系结构是独立的，C++类不能继承 OC 类，OC 类也不能继承 C++类。

本文主要就之前令人困惑的 OC 的`Block`和 C++的`lambda`**混编问题**做一些探索。

> 实验环境：C++版本为 C++14，OC 只局限于 ARC。

基本了解
----

在深入探索之前，先通过对比的方式了解下二者：

### 语法

    ^(int x, NSString *y){} // ObjC, take int and NSString*
    [](int x, std::string y){} // C++, take int and std::string
    
    ^{ return 42; } // ObjC, returns int
    []{ return 42; } // C++, returns int
    
    ^int { if(something) return 42; else return 43; }
    []()->int { if(something) return 42; else return 43; }
    复制代码

### 原理

OC 的`Block`的底层可以参考《深入研究 Block 捕获外部变量和 \_\_block 实现原理》（[halfrost.com/ios\_block/](https://link.juejin.cn?target=https%3A%2F%2Fhalfrost.com%2Fios_block%2F "https://halfrost.com/ios_block/") ），这里不做深入探究，仅仅是要展开代码达到对比效果。

    - (void)viewDidLoad {
        [super viewDidLoad];
    
        int x = 3;
        void(^block)(int) = ^(int a) {
            NSLog(@"%d", x);
        };
        block(5);
    }
    复制代码

通过`clang -rewrite-objc`重写，可以得到以下结果：

    struct __ViewController__viewDidLoad_block_impl_0 {
      struct __block_impl impl;
      struct __ViewController__viewDidLoad_block_desc_0* Desc;
      int x;
      __ViewController__viewDidLoad_block_impl_0(void *fp, struct __ViewController__viewDidLoad_block_desc_0 *desc, int _x, int flags=0) : x(_x) {
        impl.isa = &_NSConcreteStackBlock;
        impl.Flags = flags;
        impl.FuncPtr = fp;
        Desc = desc;
      }
    };
    static void __ViewController__viewDidLoad_block_func_0(struct __ViewController__viewDidLoad_block_impl_0 *__cself, int a) {
       int x = __cself->x; // bound by copy
       NSLog((NSString *)&__NSConstantStringImpl__var_folders_st_jhg68rvj7sj064ft0rznckfh0000gn_T_ViewController_d02516_mii_0, x);
    }
    
    static struct __ViewController__viewDidLoad_block_desc_0 {
      size_t reserved;
      size_t Block_size;
    } __ViewController__viewDidLoad_block_desc_0_DATA = { 0, sizeof(struct __ViewController__viewDidLoad_block_impl_0)};
    
    static void _I_ViewController_viewDidLoad(ViewController * self, SEL _cmd) {
        ((void (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("ViewController"))}, sel_registerName("viewDidLoad"));
        int x = 3;
        void(*block)(int) = ((void (*)(int))&__ViewController__viewDidLoad_block_impl_0((void *)__ViewController__viewDidLoad_block_func_0, &__ViewController__viewDidLoad_block_desc_0_DATA, x));
        ((void (*)(__block_impl *, int))((__block_impl *)block)->FuncPtr)((__block_impl *)block, 5);
    }
    复制代码

而 C++ `lambda`采取了截然不同的的实现机制，会把`lambda`表达式转换为一个匿名 C++类。这里借助`cppinsights` 看下 C++ `lambda`的实现。

    #include <cstdio>
    
    struct A {
      int x;
      int y;
    };
    
    int main()
    {
        A a = {1, 2};
        int m = 3;
        auto add = [&a, m](int n)->int {
            return m + n + a.x + a.y;
        };
        m = 30;
        add(20);
    }
    复制代码

    #include <cstdio>
    
    struct A
    {
        int x;
        int y;
    };
    
    int main()
    {
        A a = {1, 2};
        int m = 3;
    
        class __lambda_12_15
        {
        public:
            inline int operator()(int n) const
            {
                return ((m + n) + a.x) + a.y;
            }
    
        private:
            A & a;
            int m;
    
        public:
            __lambda_12_15(A & _a, int & _m)
            : a{_a}
            , m{_m}
            {}
        };
    
        __lambda_12_15 add = __lambda_12_15{a, m};
        m = 30;
        add.operator()(20);
        return 0;
    }
    复制代码

可以看到：`lambda`表达式`add`被转换为类`__lambda_12_15`，且重载了操作符`()`，对`add`的调用也被转换为对`add.operator()`的调用。

### 捕获变量

OC `Block`只可能通过普通方式和`__block`方式捕获变量：

    int x = 42;
    void (^block)(void) = ^{ printf("%d\n", x); };
    block(); // prints 42
    复制代码

    __block int x = 42;
    void (^block)(void) = ^{ x = 43; };
    block(); // x is now 43
    复制代码

C++ `lambda`带来了更多的灵活性，可以通过以下这些方式捕获变量：

    [] Capture nothing
    [&] Capture any referenced variable by reference
    [=] Capture any referenced variable by making a copy
    [=, &foo] Capture any referenced variable by making a copy, but capture variable foo by reference
    [bar] Capture bar by making a copy; don't copy anything else
    [this] Capture the this pointer of the enclosing class
    复制代码

    int x = 42;
    int y = 99;
    int z = 1001;
    auto lambda = [=, &z] {
        // can't modify x or y here, but we can read them
        z++;
        printf("%d, %d, %d\n", x, y, z);
    };
    lambda(); // prints 42, 99, 1002
    // z is now 1002
    复制代码

### 内存管理

OC 的`Block`和 C++ `lambda`均起源于栈对象，然而二者的后续发展截然不同。OC 的`Block`本质是 OC 对象，他们是通过引用方式存储，从来不会通过值方式存储。为了延长生命周期，OC `Block`必须被拷贝到堆上。OC `Block`遵循 OC 的引用计数规则，`copy`和`release`必须平衡（`Block_copy`和`Block_release`同理）。首次拷贝会把`Block`从栈上移动到堆上，再次拷贝会增加其引用计数。当引用计数为 0 的时候，`Block`会被销毁，其捕获的对象会被`release`。

C++ `lambda`按值存储，而非按引用存储。所有捕获的变量都会作为匿名类对象的成员变量存储到匿名类对象中。当`lambda`表达式被拷贝的时候，这些变量也都会被拷贝，只需要触发适当的构造函数和析构函数即可。这里面有一个极其重要的点：通过引用捕获变量。这些变量是作为引用存储在匿名对象中的，他们并没有得到任何特殊待遇。这意味着这些变量的生命周期结束之后，`lambda`仍然有可能会去访问这些变量，从而造成未定义的行为或者崩溃，例如：

    
     - (void)viewDidLoad {
        [super viewDidLoad];
    
        int x = 3;
        lambda = [&x]() -> void {
            NSLog(@"x = %d", x);
        };
    }
    
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
        lambda();
    }
    
     // 从输出结果中可以看到x是一个随机值
    2022-02-12 23:15:01.375925+0800 BlockTest[63517:1006998] x = 32767
    复制代码

相对来说，`this`指向的存储在堆上，它的生命周期有一定的保证，但是即使如此，也无法绝对保证生命周期安全，有些情况下需要借助智能指针延长生命周期。

    auto strongThis = shared_from_this();
    doSomethingAsynchronously([strongThis, this]() {
        someMember_ = 42;
    });
    复制代码

闭包混合捕获问题
--------

前面讨论的内容都是相互独立的，OC 的`Block`并未涉及 C++对象，C++的`lambda`也没有牵扯 OC 对象，这大概是我们最希望看到的，但是混编过程中会发现这只是自己的一厢情愿。二者往往会相互把自己的魔杖伸向对方领域，从而会引发一些比较费解的问题。

### C++的`lambda`捕获`OC`对象

C++的`lambda`可以捕获 OC 变量吗？如果可以的话，会有循环引用的问题吗？如果有循环引用的问题，该怎么处理呢？

#### 值捕获 OC 对象

如代码所示，在`OCClass`类中有一个 C++字段`cppObj`，在`OCClass`的初始化方法中，对`cppObj`进行了初始化，并对其字段`callback`进行了赋值。可以看到，在`lambda`中对`self`进行了捕获，按照前面的规则，可以认为值捕获。

    class CppClass {
    public:
        CppClass() {
        }
    
        ~CppClass() {
        }
    public:
        std::function<void()> callback;
    };
    复制代码

    @implementation OCClass {
        std::shared_ptr<CppClass> cppObj;
    }
    
    - (void)dealloc {
        NSLog(@"%s", __FUNCTION__);
    }
    
    - (instancetype)init {
        if (self = [super init]) {
            cppObj = std::make_shared<CppClass>();
            cppObj->callback = [self]() -> void {
                [self executeTask];
            };
        }
        return self;
    }
    
    - (void)executeTask {
        NSLog(@"execute task");
    }
    复制代码

    OCClass *ocObj = [[OCClass alloc] init];
    复制代码

不幸的是，这样的捕获方式会发生循环引用：`OCClass`对象`ocObj`持有`cppObj`，`cppObj`通过`callback`持有了`ocObj`。

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6987ed4703b843f7a4fe9981f9984794~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

看下对应的汇编代码，可以发现捕获的时候，触发了`ARC`语义，自动对`self`进行了`retain`。

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/22fb537e44854598a0b427fe78dbbfa4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

这几行汇编代码对`self`增加引用计数。

    0x10cab31ea <+170>: movq   -0x8(%rbp), %rdi
    0x10cab31ee <+174>: movq   0x5e7b(%rip), %rax        ; (void *)0x00007fff2018fa80: objc_retain
    0x10cab31f5 <+181>: callq  *%rax
    复制代码

最后来看一下匿名类的参数，可以发现`self`是`OCClass *`类型，是一个指针类型。

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9e03a719a44d47099a366184f4606d3f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

那么可以简单地认为捕获伪代码如下，在`ARC`语义下会发生`retain`行为：

    __strong __typeof(self) capture_self = self;
    
    // 展开
    __strong OCClass * capture_self = self;
    复制代码

为了解决循环引用的问题，可以使用`__weak`。

    cppObj = std::make_shared<CppClass>();
    __weak __typeof(self) wself = self;
    cppObj->callback = [wself]() -> void {
        [wself executeTask];
    };
    复制代码

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc8158c07b3d438fba834a42b834b92b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

再次观察汇编代码，发现前面的`objc_retain`逻辑已经消失，代替的逻辑为`objc_copyWeak`。

#### 引用捕获 OC 对象

那么是否可以通过引用捕获来捕获`self`呢？

    cppObj = std::make_shared<CppClass>();
    cppObj->callback = [&self]() -> void {
        [self executeTask];
    };
    复制代码

可以看到汇编代码中同样没有`objc_retain`逻辑。

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e311730440e44adca75d54012e431e32~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

最后来看一下匿名类的参数，可以发现`self`是`OCClass *&`类型，是一个指针引用类型。

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/492482a229404a90b3c6b98af60dde8d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

可以看到引用捕获并不会对`self`进行`retain`，可以简单的认为捕获伪代码如下，在`ARC`语义下不会发生`retain`行为。

    __unsafe_unretained __typeof(self)& capture_self = self;
    
    // 展开
    __unsafe_unretained OCClass *&capture_self = self;
    复制代码

#### 被捕获的 OC 对象什么时候释放？

以这个代码片段为例：

    auto cppObj = std::make_shared<CppClass>();
    OCClass2 *oc2 = [[OCClass2 alloc] init];
    cppObj->callback = [oc2]() -> void {
        [oc2 class];
    };
    复制代码

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c7d61b7ada08495a9f45e8518f1ab849~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

可以看到，在`CppClass`的析构函数中对`std::function`进行了析构，而`std::function`则对其捕获的 OC 变量 oc2 进行了释放。

#### 结论

C++ `lambda`的本质是创建一个匿名结构体类型，用来存储捕获的变量。`ARC`会保证包含 OC 对象字段的 C++结构体类型遵循`ARC`语义：

1.  C++结构体的构造函数会将 OC 对象字段初始化为`nil`；
2.  当该 OC 对象字段被赋值的时候，会`release`掉之前的值，并`retain`新值（如果是`block`，会进行`copy`）；
3.  当 C++结构体的析构函数被调用的时候，会`release`掉 OC 对象字段。

C++ `lambda`会通过值或者引用的方式捕获 OC 对象。

1.  引用捕获 OC 对象相当于使用`__unsafe_unretained`，存在生命周期问题，本身比较危险，不太推荐；
2.  而值捕获的方式相当于使用`__strong`，可能会引起循环引用，必要的时候可以使用`__weak`。

### OC 的 Block 如何捕获 C++对象？

反过来看看 OC 的`Block`是怎么捕获 C++对象的。

代码中的`HMRequestMonitor`是一个 C++结构体，其中的`WaitForDone`和`SignalDone`方法主要是为了实现同步。

    struct HMRequestMonitor  {
    public:
        bool WaitForDone() { return is_done_.get(); }
        void SignalDone(bool success) { done_with_success_.set_value(success); }
        ResponseStruct& GetResponse() { return response_; }
    private:
        .....
    };
    复制代码

`upload`方法使用`HMRequestMonitor`对象，达到同步等待网络请求结果的目的（为了排版，代码有所调整）。

    hermas::ResponseStruct HMUploader::upload(
    const char* url,
    const char* request_data,
    int64_t len,
    const char* header_content_type,
    const char* header_content_encoding) {
        HMRequestModel *model = [[HMRequestModel alloc] init];
        ......
    
        auto monitor = std::make_shared<hermas::HMRequestMonitor>();
        std::weak_ptr<hermas::HMRequestMonitor> weakMonitor(monitor);
        DataResponseBlock block = ^(NSError *error, id data, NSURLResponse *response) {
            weakMonitor.lock()->SignalDone(true);
        };
        [m_session_manager requestWithModel:model callBackWithResponse:block];
        monitor->WaitForDone();
        return monitor->GetResponse();
    }
    复制代码

这里直接使用`std::weak_ptr`。

#### 不使用`__block`

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/38d547f5677c4429b27fd1d2ab8854f8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3573075d6c824bd6bf46d755e8e1d7db~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过实验可以得到以下结论：

1.  C++的对象会被 OC 的`Block`捕获，且通过值传递方式。通过断点可以发现调用的是`std::weak_ptr`的拷贝构造函数。

    template<class _Tp>
    inline
    weak_ptr<_Tp>::weak_ptr(weak_ptr const& __r) _NOEXCEPT
        : __ptr_(__r.__ptr_),
          __cntrl_(__r.__cntrl_)
    {
        if (__cntrl_)
            __cntrl_->__add_weak();
    }
    复制代码

2.  `monitor`的弱引用计数变化如下：

*   初始化`monitor`时， `weak_count = 1`;
*   初始化`weakMonitor`时，`weak_count = 2`，增加 1；
*   OC Block 捕获后，`weak_count = 4`，增加了 2。通过观察汇编代码，有 2 处：
    *   首次捕获的时候，对`weakMinotor`进行了复制，在汇编代码 142 行；
    *   `Block`从栈上拷贝到堆上的时候，再次对`weakMinotor`进行了复制，在汇编 144 行；

> 这里需要注意的是：C++的`weak_count`比较奇怪，它的值 = 弱引用个数 + 1，这么设计的原因比较复杂，具体可以参考：[stackoverflow.com/questions/5…](https://link.juejin.cn?target=https%3A%2F%2Fstackoverflow.com%2Fquestions%2F5671241%2Fhow-does-weak-ptr-work "https://stackoverflow.com/questions/5671241/how-does-weak-ptr-work")

如果此处不使用`std::weak_ptr`，而是直接捕获`std::shared_ptr`，被捕获后其强引用计数为 3，逻辑和上述的`std::weak_ptr`是一致的。（就本质上来说，`std::shared_ptr`和`std::weak_ptr`都是 C++类）

    std::shared_ptr<hermas::HMRequestMonitor> monitor = std::make_shared<hermas::HMRequestMonitor>();
    DataResponseBlock block = ^(NSError * _Nonnull error, id  _Nonnull data, NSURLResponse * _Nonnull response) {
        monitor->SignalDone(true);
    };
    复制代码

    (lldb) po monitor
    std::__1::shared_ptr<hermas::HMRequestMonitor>::element_type @ 0x00006000010dda58 strong=3 weak=1
    复制代码

#### 使用\_\_block

那么是否可以使用`__block`修改被捕获的 C++变量呢？通过实验发现是可行的。

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/274bcd7da46049739b1f62f116a94a45~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/57719850c82c4942b160993a69009149~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

可以得到以下结论：

1.  OC 的`Block`可以通过引用传递方式捕获 C++对象；
2.  `monitor`的`weak`引用计数如下：

*   初始化`monitor`时， `weak_count = 1`;
*   初始化`weakMonitor`时，`weak_count = 2`，增加 1；
*   OC `Block`捕获后，`weak_count = 2`，主要是由于移动构造函数被触发，只是所有权的转移，不会改变引用计数；

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/057407154ad64a4ba6688cfd21c744c0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

#### \_\_block 的疑问

了解 C++的同学可能会疑惑，这里既然是移动构造函数被触发，只是所有权发生了转移，意味着`monitor`作为右值被传递进来，已经变为`nullptr`被消亡，那么为什么示例中的`monitor`还可以继续访问？可以来验证一下：

1.  当首次执行完如下代码的时候

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f5f6f7f2ed724a1eaee6f7c7cb7b5130~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

会发现`monitor`变量的地址为：

    (lldb) po &monitor
    0x0000700001d959e8
    复制代码

2.  当执行`block`赋值的时候，会调用到`std::shared_ptr`的移动构造函数中：

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6fe68e8b73cb419bbf5f86ae31de3a5f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/163150f5f0414083b55e67ad63f2ee40~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   移动构造函数中的`this`地址为`0x0000600003b0c830`;
*   `__r`的地址也是`0x0000700001d959e8`，和`monitor`的地址一致。

3.  当执行完`block`的时候，再次打印`monitor`的地址，会发现`monitor`的地址已经发生了变化，和第二步中的`this`保持了一致，这说明`monitor`已经变为第二步中的`this`。

    (lldb) po &monitor
    0x0000600003b0c830
    复制代码

整个过程中，`monitor`前后地址发生了变化，分别是 2 个不同的`std::shared_ptr`对象。所以`monitor`还可以继续被访问。

#### 被捕获的 C++对象何时释放？

![图片](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/30657d019fea4ed0bf47a729e864ea13~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

同样在 OC 的`Block`释放的时候，会对其捕获的 C++对象进行释放。

#### 捕获 shared\_from\_this

C++的`this`是一个指针，本质就是一个整数，OC 的`Block`捕获`this`和捕获一个整数并没有本质上的区别，所以这里不再详细讨论。这里重点看下 C++的`shared_from_this`类，它是 this 的智能指针版本。

> 一个 C++类如果想访问`shared_from_this`，必须继承自类`enable_shared_from_this`，并把自己的类名作为模板参数传入。

    class CppClass : public std::enable_shared_from_this<CppClass> {
    public:
        CppClass(){}
        ~CppClass() {}
    
        void attachOCBlock();
    public:
        OCClass2 *ocObj2;
        void dosomething() {}
    };
    
    void CppClass::attachOCBlock() {
        ocObj2 = [[OCClass2 alloc] init];
        auto shared_this = shared_from_this();
        ocObj2.ocBlock = ^{
            shared_this->dosomething();
        };
    }
    复制代码

    @interface OCClass2 : NSObject
    @property void (^ocBlock)();
    @end
    复制代码

    auto cppObj = std::make_shared<CppClass>();
    cppObj->attachOCBlock();
    复制代码

根据前面的结论，在`CppClass`成员函数`attachOCBlock`中，`ocBlock`直接捕获`shared_from_this`同样会引发循环引用，同样采取`std::weak_ptr`来解决。

    void CppClass::attachOCBlock() {
        ocObj2 = [[OCClass2 alloc] init];
        std::weak_ptr<CppClass> weak_this = shared_from_this();
        ocObj2.ocBlock = ^{
            weak_this.lock()->dosomething();
        };
    }
    复制代码

#### 结论

OC 的`Block`可以捕获 C++对象。

1.  如果使用普通方式捕获栈上的 C++对象，会调用拷贝构造函数；
2.  如果使用`__block`方式捕获栈上的 C++对象，会调用移动构造函数，并且`__block`修饰的 C++对象在被捕获的时候，会进行重定向。

总结
--

本文一开始分别从语法、原理、变量捕获和内存管理 4 个维度，对 OC 的`Block`和 C++的`lambda`进行了简单的对比，然后花了较多的篇幅重点讨论 `OC/C++`的闭包混合捕获问题。之所以如此大费周章，是因为不想稀里糊涂地「猜想」和「试错」，只有深入了解背后机制，才能写出较好的 `OC/C++`混编代码，同时也希望能给有同样困惑的读者带来一些帮助。然而对于 `OC/C++`整个混编领域来说，这仅仅是冰山一角，疑难问题仍然重重，期待未来能带来更多的探索。

参考文档
----

1.  [isocpp.org/wiki/faq/ob…](https://link.juejin.cn?target=https%3A%2F%2Fisocpp.org%2Fwiki%2Ffaq%2Fobjective-c "https://isocpp.org/wiki/faq/objective-c")
2.  [www.philjordan.eu/article/mix…](https://link.juejin.cn?target=http%3A%2F%2Fwww.philjordan.eu%2Farticle%2Fmixing-objective-c-c%2B%2B-and-objective-c%2B%2B "http://www.philjordan.eu/article/mixing-objective-c-c++-and-objective-c++")
3.  [releases.llvm.org/12.0.0/tool…](https://link.juejin.cn?target=https%3A%2F%2Freleases.llvm.org%2F12.0.0%2Ftools%2Fclang%2Fdocs%2FAutomaticReferenceCounting.html "https://releases.llvm.org/12.0.0/tools/clang/docs/AutomaticReferenceCounting.html")
4.  [releases.llvm.org/12.0.0/tool…](https://link.juejin.cn?target=https%3A%2F%2Freleases.llvm.org%2F12.0.0%2Ftools%2Fclang%2Fdocs%2FBlockLanguageSpec.html%23c-extensions "https://releases.llvm.org/12.0.0/tools/clang/docs/BlockLanguageSpec.html#c-extensions")
5.  [mikeash.com/pyblog/frid…](https://link.juejin.cn?target=https%3A%2F%2Fmikeash.com%2Fpyblog%2Ffriday-qa-2011-06-03-objective-c-blocks-vs-c0x-lambdas-fight.html "https://mikeash.com/pyblog/friday-qa-2011-06-03-objective-c-blocks-vs-c0x-lambdas-fight.html")