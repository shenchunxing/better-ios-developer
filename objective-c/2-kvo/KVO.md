 KVO的使用
----------

*   发起监听
    *   可以通过`addObserver: forKeyPath:`方法对属性发起监听
*   接收监听信息
    *   然后通过`observeValueForKeyPath: ofObject: change:`方法中对应进行监听，见下面示例代码:
```
   @interface Person : NSObject
    
    @property (assign, nonatomic) int age;
    @property (assign, nonatomic) int height;
    @end
    
    @implementation Person
    
    @end
    
    @interface ViewController ()
    
    @property (strong, nonatomic) Person *person1;
    @property (strong, nonatomic) Person *person2;
    @end
    
    @implementation ViewController
    
    - (void)viewDidLoad {
        [super viewDidLoad];
        
        self.person1 = [[Person alloc] init];
        self.person1.age = 1;
        
        self.person2 = [[Person alloc] init];
        self.person2.age = 2;
        
        // 打印添加监听之前person1和person2对应的isa指针指向的类型
        NSLog(@"person1添加KVO监听之前 - %@ %@",
              object_getClass(self.person1),
              object_getClass(self.person2)); 
        // 打印结果：Person Person
        
        // 打印添加监听之前person1和person2对应的setAge方法是否有改变
        NSLog(@"person1添加KVO监听之前 - %p %p",
              [self.person1 methodForSelector:@selector(setAge:)],
              [self.person2 methodForSelector:@selector(setAge:)]);
        // 0x10b60c4b0 0x10b60c4b0
              
        // 给person1对象添加KVO监听
        /* 1 观察者，负责处理监听事件的对象 2 观察的属性 3 观察的选项 4 上下文 */
        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self.person1 addObserver:self forKeyPath:@"age" options:options context:@"123"];
        
        // 打印添加监听之后person1和person2对应的isa指针指向的类型
        NSLog(@"person1添加KVO监听之后 - %@ %@",
              object_getClass(self.person1),
              object_getClass(self.person2)); 
        // 打印结果：NSKVONotifying_Person Person
        
         // 打印添加监听之后person1和person2对应的setAge方法是否有改变
        NSLog(@"person1添加KVO监听之前 - %p %p",
              [self.person1 methodForSelector:@selector(setAge:)],
              [self.person2 methodForSelector:@selector(setAge:)]);
        // 0x7fff207b62b7 0x10b60c4b0
    }
    
    - (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
    {
        self.person1.age = 20;    
    }
    
    - (void)dealloc {
        [self.person1 removeObserver:self forKeyPath:@"age"];
    }
    
    // 当监听对象的属性值发生改变时，就会调用
    /*
 1. 观察的属性
 2. 观察的对象
 3. change 属性变化字典（新／旧）
 4. 上下文，与监听的时候传递的一致
 */
    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
    {
        NSLog(@"监听到%@的%@属性值改变了 - %@ - %@", object, keyPath, change, context);
    }
    
    @end
```

**注意：**  监听的对象销毁之前要移除该监听`removeObserver: forKeyPath:`

二、KVO的实现本质
==========

1.通过上面示例代码发现，函数在调用`addObserver: forKeyPath:`方法之后，`person1`的实例对象的`isa指针`指向了一个新的类型`NSKVONotifying_Person`，而没有添加监听的`person2`的`isa指针`还是指向了`Person`这个类型

2.我们发现通过`object_getClass`打印`person1`的类对象和元类对象都是新派生出来的`NSKVONotifying_Person`这个类型

    NSLog(@"类对象 - %@ %@",
              object_getClass(self.person1), 
              object_getClass(self.person2)); 
    // NSKVONotifying_Person Person
    
    NSLog(@"元类对象 - %@ %@",
              object_getClass(object_getClass(self.person1)), 
              object_getClass(object_getClass(self.person2))); 
    // NSKVONotifying_Person Person
     
    复制代码

3.我们发现通过`object_getClass`打印`person1`的`superclass`是`Person`这个类型，说明新派生出来的`NSKVONotifying_Person`是`Person`的子类

    NSLog(@"父类 - %@ %@", 
            object_getClass(self.person1).superclass,
            object_getClass(self.person2).superclass);
            // Person NSObject
    复制代码

4.通过打印我们发现，`person1`调用的`setAge`方法的内存地址发生了改变，通过`LLDB`打印该地址的详细信息发现`setAge`方法的实现实际是`Foundation框架`中的`_NSSetIntValueAndNotify`这个函数

    (lldb) p (IMP)0x7fff207b62b7
    (IMP) $2 = 0x00007fff207b62b7 (Foundation`_NSSetIntValueAndNotify)
    (lldb) p (IMP) 0x108801480
    (IMP) $3 = 0x0000000108801480 (Interview01`-[Person setAge:] at Person.m:13)
    复制代码

5.我们手动创建这个派生类型`NSKVONotifying_Person`，并且在Person里面重写`setAge:、willChangeValueForKey:、didChangeValueForKey:`这三个方法，运行程序并观察调用情况

    @interface NSKVONotifying_Person : Person
    
    @end
    
    @implementation NSKVONotifying_Person
    
    @end
    
    
    @interface Person : NSObject
    
    @property (assign, nonatomic) int age;
    @property (assign, nonatomic) int height;
    @end
    
    @implementation Person
    
    - (void)setAge:(int)age {
        _age = age;
        NSLog(@"setAge:");
    }
    
    - (void)willChangeValueForKey:(NSString *)key{
        [super willChangeValueForKey:key];
        NSLog(@"willChangeValueForKey");
    }
    
    - (void)didChangeValueForKey:(NSString *)key {
        NSLog(@"didChangeValueForKey - begin");
        [super didChangeValueForKey:key];    
        NSLog(@"didChangeValueForKey - end");
    }
    
    bool __isKVOA { 
      return true;
    } 
    
    //隐藏子类 
    Class class {
       return object_getClass(self).superclass;
    }
    
    - (void)dealloc {
    }
    
    @end

由此可见，当监听的属性发生改变，系统派生出的这个类`NSKVONotifying_Person`(在)会对应的先后调用

*   `willChangeValueForKey:`
*   `setAge:`
*   `didChangeValueForKey:` 这三个方法，并在`didChangeValueForKey:`里调用观察者的`observeValueForKeyPath: ofObject: change:`来通知值属性值的变化

    // 执行后打印
```
    2021-01-19 13:42:02.071987+0800 Interview01[37119:19609444] willChangeValueForKey
    2021-01-19 13:42:02.072192+0800 Interview01[37119:19609444] setAge:
    2021-01-19 13:42:02.072332+0800 Interview01[37119:19609444] didChangeValueForKey - begin
    2021-01-19 13:42:02.072662+0800 Interview01[37119:19609444] 监听到<Person: 0x6000036ac2c0>的age属性值改变了 - {
        kind = 1;
        new = 21;
        old = 1;
    } - 123
    2021-01-19 13:42:02.072817+0800 Interview01[37119:19609444] didChangeValueForKey - end
```

6.通过`class方法`打印`person1`的类发现还是`Person`这个类型，说明在派生出的这个类`NSKVONotifying_Person`内部重写了`class`方法，并返回的是`Person`这个类型。所以只能通过`object_getClass`才能获取到真实的类型

    NSLog(@"%@ %@",
              [self.person1 class], 
              [self.person2 class]); 
    // Person Person
    
    NSLog(@"%@ %@",
              object_getClass(self.person1), 
              object_getClass(self.person2)); 
    // NSKVONotifying_Person Person
    复制代码

7.通过`Runtime`的`class_copyMethodList`函数查看`NSKVONotifying_Person`内部还动态生成了`dealloc、_isKVOA`这两个函数

    - (void)printMethodNamesOfClass:(Class)cls
    {
        unsigned int count;
        // 获得方法数组
        Method *methodList = class_copyMethodList(cls, &count);
        
        // 存储方法名
        NSMutableString *methodNames = [NSMutableString string];
        
        // 遍历所有的方法
        for (int i = 0; i < count; i++) {
            // 获得方法
            Method method = methodList[i];
            // 获得方法名
            NSString *methodName = NSStringFromSelector(method_getName(method));
            // 拼接方法名
            [methodNames appendString:methodName];
            [methodNames appendString:@", "];
        }
        
        // 释放
        free(methodList);
        
        // 打印方法名
        NSLog(@"%@ %@", cls, methodNames);
    }
    
    [self printMethodNamesOfClass:object_getClass(self.person1)];
    [self printMethodNamesOfClass:object_getClass(self.person2)];
    
    // 打印结果
    2021-01-19 15:38:13.552990+0800 Interview01[41940:19730538] NSKVONotifying_MJPerson setAge:, class, dealloc, _isKVOA,
    2021-01-19 15:38:13.553166+0800 Interview01[41940:19730538] MJPerson setAge:, age,

三、总结
====

**通过上面一系列操作可以汇总为：**

*   利用`RuntimeAPI`动态生成一个子类，并且让`instance对象`的`isa`指向这个全新的子类
*   全新的子类会重写`class`这个函数，并返回父类类型
*   在全新的子类里面会重写被监听的`成员对象/属性`的`setter`方法,当修改`instance对象`的属性时，会调用`Foundation`的`_NSSetXXXValueAndNotify函数`
*   *   函数内部首先调用`willChangeValueForKey:`
*   *   紧接着函数内部 调用父类原来的`setter`
*   *   最后调用`didChangeValueForKey:`
*   *   *   内部会触发监听器（Oberser）的监听方法 `observeValueForKeyPath:ofObject:change:context:`

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0383f5ab05324e50a84dc3fe6a72f00c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

四、KVO的应用场景
==========

*   1.监听`ScrollView`的偏移量，改变导航栏背景色
*   2.给`TextView`增加`placeHolder`，通过`KVO`监听文本是否输入对应隐藏展示`placeHolder`
*   ...