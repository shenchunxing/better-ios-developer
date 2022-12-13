 [使用block时什么情况会发生引用循环，如何解决？](https://github.com/shenchunxing/ios_interview_questions/blob/master/Block.md#使用block时什么情况会发生引用循环如何解决)
 
 [在block内如何修改block外部变量？](https://github.com/shenchunxing/ios_interview_questions/blob/master/Block.md#在block内如何修改block外部变量) 
 
 [使用系统的某些block api（如UIView的block版本写动画时），是否也考虑引用循环问题？](https://github.com/shenchunxing/ios_interview_questions/blob/master/Block.md#使用系统的某些block-api如uiview的block版本写动画时是否也考虑引用循环问题) 
 
 [Block的修饰符](https://github.com/shenchunxing/ios_interview_questions/blob/master/Block.md#Block的修饰符) 
 
 [Block的类型](https://github.com/shenchunxing/ios_interview_questions/blob/master/Block.md#Block的类型) 
 
 [block的内存管理](https://github.com/shenchunxing/ios_interview_questions/blob/master/Block.md#block的内存管理) 


### 使用block时什么情况会发生引用循环，如何解决？
一个对象中强引用了 block，在 block 中又强引用了该对象，就会发生循环引用。

ARC 下的解决方法是：



 1、 将该对象使用 `__weak` 修饰符修饰之后再在 block 中使用。 `id weak weakSelf = self;`
    或者 `weak __typeof(&*self)weakSelf = self` 该方法可以设置宏
      `__weak` ：不会产生强引用，指向的对象销毁时，会自动让指针置为 ni1
      
 2、 使用 `unsafe_unretained` 关键字，用法与 `__weak` 一致。
 `unsafe_unretained` 不会产生强引用，不安全，指向的对象销毁时，指针存储的地址值不变。

几个方案的原理如下图所示：

![https://github.com/ChenYilong](https://tva1.sinaimg.cn/large/007S8ZIlly1gfj2600xzsj30pw0iadj5.jpg)

检测代码中是否存在循环引用问题，可参考下文中 39 题中提到的工具。

注意：

还有第三种方式：

3、也可以使用 `__block` 来解决循环引用问题，用法为： `__block id weakSelf = self;`，但不推荐使用。因为必须要调用该 block 方案才能生效，因为需要及时的将 `__block` 变量置为 nii。

![](https://tva1.sinaimg.cn/large/007S8ZIlly1gfj1sa1veaj30si1akgud.jpg)
 
```Objective-C
__block id weakSelf = self;
self.block = ^{
    NSLog(@"%@", @[weakSelf]);
    weakSelf = nil;
};
self.block();
```

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

![](https://tva1.sinaimg.cn/large/007S8ZIlly1gfl2fg3anyj31jy0m3dlu.jpg)

在 [《iOS面试题集锦（附答案）》]( https://github.com/ChenYilong/iOSInterviewQuestions ) 中有这样一道题目： 
在block内如何修改block外部变量？（38题）答案如下：

### 在block内如何修改block外部变量？


注：本题代码请在仓库中查看以 Demo38 开头的工程（公众号请点击原文查看 GitHub 仓库）
 
先描述下问题：

默认情况下，在block中访问的外部变量是复制过去的，即：**写操作不对原变量生效**。但是你可以加上 `__block` 来让其写操作生效，示例代码如下:


 ```Objective-C
    __block int a = 0;
    void (^foo)(void) = ^{ 
        a = 1; 
    };
    foo(); 
    //这里，a的值被修改为1
 ```


这是网上常见的描述。你同样可以在面试中这样回答，但你并没有答到“点子上”。真正的原因，并没有这么“神奇”，而且这种说法也有点牵强。面试官肯定会追问“为什么写操作就生效了？” 实际上需要有几个必要条件：

 - "将 auto 从栈 copy 到堆"
 - “将 auto 变量封装为结构体(对象)”


我会将本问题分下面几个部分，分别作答：

 - 该问题研究的是哪种 `block` 类型?
 - 在 `block` 内为什么不能修改 `block` 外部变量
 - 最优解及原理解析
 - 其他几种解法
 - 改外部变量必要条件之"将 auto 从栈 copy 到堆"
 - 改外部变量必要条件之“将 auto 变量封装为结构体(对象)”
 

 该问题研究的是哪种 block 类型?
-------------

今天我们讨论是 `__NSMallocBlock__` (或者叫 `_NSConcreteMallocBlock`，两者是叫法不同，指的是同一个东西)。


Block 类型| 环境
:-------------:|:-------------:
`__NSGlobalBlock__` | 没有访问 auto 变量
`__NSStackBlock__` | 访问了 auto 变量
`__NSMallocBlock__` | `__NSStackBlock__` 调用了 copy

每一种类型的 block 调用 copy 后的结果如下所示


Block 的类 | 副本源的配置存储域| 复制效果
:-------------:|:-------------:|:-------------:
`_NSConcreteGlobalBlock`| 程序的数据区域 | 什么也不做
`_NSConcreteStackBlock` | 栈|  从栈复制到堆
`_NSConcreteMallocBlock`| 堆 | 引用计数增加


在 ARC 环境下，编译器会根据情况自动将栈上的 block 复制到堆上，比如以下情况：

- block 作为函数返回值时
- 将 block 赋值给 __strong 指针时
- block 作为 Cocoa API 中方法名含有 using Block 的方法参数时
- Block 作为 GCD APIE 的方法参数时


![https://github.com/ChenYilong](https://tva1.sinaimg.cn/large/007S8ZIlly1gfiwolczn7j30sa0xaq8k.jpg)

更多细节可以查看：


![https://github.com/ChenYilong](https://tva1.sinaimg.cn/large/007S8ZIlly1gfkx49l2xxj30u012bqfs.jpg)


![https://github.com/ChenYilong](https://tva1.sinaimg.cn/large/007S8ZIlly1gfl31akk5hj30zg0lojz9.jpg)

 在 `block` 内为什么不能修改 `block` 外部变量
-------------



为了保证 block 内部能够正常访问外部的变量，block 有一个变量捕获机制。


![https://github.com/ChenYilong](https://tva1.sinaimg.cn/large/007S8ZIlly1gfks99t8fej30u017uqf8.jpg)




首先分析一下为什么不能修改：


**Block不允许修改外部变量的值**。Apple这样设计，应该是考虑到了block的特殊性，block 本质上是一个对象，block 的花括号区域是对象内部的一个函数，变量进入 花括号，实际就是已经进入了另一个函数区域---改变了作用域。在几个作用域之间进行切换时，如果不加上这样的限制，变量的可维护性将大大降低。又比如我想在block内声明了一个与外部同名的变量，此时是允许呢还是不允许呢？只有加上了这样的限制，这样的情景才能实现。


所以 Apple 在编译器层面做了限制，如果在 block 内部试图修改 auto 变量（无修饰符），那么直接编译报错。
你可以把编译器的这种行为理解为：对 block 内部捕获到的 auto 变量设置为只读属性---不允许直接修改。

从代码层面进行证明：

写一段 block 代码：

 ```Objective-C
//
//  main.m
//  Demo_38_block_edit_var
//
//  Created by chenyilong on 2020/6/3.
//  Copyright © 2020 ChenYilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
typedef void (^CYLBlock)(void);
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        int age = 10;
        CYLBlock block = ^{
            NSLog(@"age is %@", @(age));
        };
        block();
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

 ```

使用如下命令来查看对应的 C++ 代码：


 ```shell
 xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m
 ```

 代码如下所示：
 
![](https://tva1.sinaimg.cn/large/007S8ZIlly1gffg4w6nrmj30x10u04nr.jpg)



 ```Java

typedef void (*CYLBlock)(void);

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int age;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _age, int flags=0) : age(_age) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  int age = __cself->age; // bound by copy

            NSLog((NSString *)&__NSConstantStringImpl__var_folders_2w_wgnctp1932z76770l8lrrrbm0000gn_T_main_0d7ffa_mi_0, ((NSNumber *(*)(Class, SEL, int))(void *)objc_msgSend)(objc_getClass("NSNumber"), sel_registerName("numberWithInt:"), (int)(age)));
        }

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        appDelegateClassName = NSStringFromClass(((Class (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("AppDelegate"), sel_registerName("class")));
        int age = 10;
        CYLBlock block = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, age));
        ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
    }
    return UIApplicationMain(argc, argv, __null, appDelegateClassName);
}
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };

 ```


最优解及原理解析
-------------

说最优解前，先来说一下

其他几种解法
-------------

  - 加 static (放在静态存储区/全局初始化区 ) 缺点是会永久存储，内存开销大。
  - 将变量设置为全局变量，缺点也是内存开销大。

将变量设置为全局变量

![将变量设置为全局变量](https://tva1.sinaimg.cn/large/007S8ZIlly1gfkzpoivkij31470u04qp.jpg)

原理是 block 内外可直接访问全局变量

![](https://tva1.sinaimg.cn/large/007S8ZIlly1gfkzqxd6vkj31460u07wh.jpg)

加 static (放在静态存储区/全局初始化区)

原理是 block 内部对外部auto变量进行指针捕获

![加 static (放在静态存储区/全局初始化区)](https://tva1.sinaimg.cn/large/007S8ZIlly1gfkzqiy0myj314a0u0b29.jpg)

下面介绍下最优解 

 -  使用 `__block` 关键字

![https://github.com/ChenYilong](https://tva1.sinaimg.cn/large/007S8ZIlly1gfks7378ktj30sk1auqby.jpg)


改外部变量必要条件之"将 auto 从栈 copy 到堆"
-------------

之所以要放堆里，原因是栈中内存管理是由系统管理，出了作用域就会被回收， 堆中才是可以由我们程序员管理。

这里先说结论：

> 在 ARC 中无论是否添加 `__block` ，block 中的 auto 变量都会被从栈上 copy 到堆上。

下面证明下该结论：

先认识一下 `__block` 修饰符：

 - `__block` 可以用于解决 block 内部无法修改 auto 变量值的问题
 - `__block` 不能修饰全局变量、静态、变量（static)

编译器会将 `__block`  变量包装成一个对象


 ```Objective-C
//
//  main.m
//  Demo_38_block_edit_var
//
//  Created by chenyilong on 2020/6/3.
//  Copyright © 2020 ChenYilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
typedef void (^CYLBlock)(void);
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        __block int age = 10;//__block 可替换为 __block auto (auto 可省略)
        CYLBlock block = ^{
            age = 20;
            NSLog(@"age is %@", @(age));
        };
        block();
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

 ```

![https://github.com/ChenYilong](https://tva1.sinaimg.cn/large/007S8ZIlly1gffiapgoefj31420u0b29.jpg)





下面用代码证明下外部变量被 copy 到堆上：

我们可以打印下内存地址来进行验证：

 ```Objective-C
    __block int a = 0;
    NSLog(@"定义前：%p", &a);         //栈区
    void (^foo)(void) = ^{
        a = 1;
        NSLog(@"block内部：%p", &a);    //堆区
    };
    NSLog(@"定义后：%p", &a);         //堆区
    foo();
 ```

 ```Objective-C
2016-05-17 02:03:33.559 LeanCloudChatKit-iOS[1505:713679] 定义前：0x16fda86f8
2016-05-17 02:03:33.559 LeanCloudChatKit-iOS[1505:713679] 定义后：0x155b22fc8
2016-05-17 02:03:33.559 LeanCloudChatKit-iOS[1505:713679] block内部： 0x155b22fc8
 ```
 
 
“定义后”和“block内部”两者的内存地址是一样的，我们都知道 block 内部的变量会被 copy 到堆区，“block内部”打印的是堆地址，因而也就可以知道，“定义后”打印的也是堆的地址。
 
 
 那么如何证明“block内部”打印的是堆地址？
 
 把三个16进制的内存地址转成10进制就是：
 
 1. 定义后前：6171559672
 2. block内部：5732708296
 3. 定义后：5732708296
 
中间相差438851376个字节，也就是 418.5M 的空间，因为堆地址要小于栈地址，又因为 iOS 中主线程的栈区内存只有1M，Mac也只有8M，既然 iOS 中一条线程最大的栈空间是1M，显然a已经是在堆区了。

这也证实了：a 在定义前是栈区，但只要进入了 block 区域，就变成了堆区。

从代码角度讲：



 ```Objective-C
__block int a = 0; // 【a 会被编译成一个结构体，a struct 里会有一个 a 存储 0】
NSLog(@"定义前：%p", &a); //栈区
void (^foo)(void) = ^{
a = 1;
NSLog(@"block内部：%p", &a); //堆区
};
 ```


这里会执行 copy 操作，下面是编译后的 copy 方法，a struct 会被拷贝到堆里，自然里面的 a struct->a 也会拷贝到堆里

 ```Objective-C
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {_Block_object_assign((void*)&dst->a, (void*)src->a, 8/*BLOCK_FIELD_IS_BYREF*/);}
 ```


同理可证：

 > 在 ARC 中无论是否添加 `__block` ，block 中的 auto 变量都会被从栈上 copy 到堆上。
 
 
 证明代码如下：

 ```Objective-C
     __block int a = 0;
    int b = 1;
    NSLog(@"定义前外部：a：%p", &a);         //栈区
    NSLog(@"定义前外部：b：%p", &b);         //栈区
    void (^foo)(void) = ^{
        a = 1;
        NSLog(@"block内部：a：%p", &a);     //堆区
        NSLog(@"block内部：b：%p", &b);     //堆区
    };
    NSLog(@"定义后外部：a：%p", &a);         //堆区
    NSLog(@"定义后外部：b：%p", &b);         //栈区
    foo();
 ```

打印是：


 ```Objective-C
2020-06-08 12:59:43.633180+0800 Demo_38_block_edit_var[35375:7813379] 定义前外部：a：0x7ffee3d81078
2020-06-08 12:59:43.633328+0800 Demo_38_block_edit_var[35375:7813379] 定义前外部：b：0x7ffee3d8105c
2020-06-08 12:59:43.633535+0800 Demo_38_block_edit_var[35375:7813379] 定义后外部：a：0x600003683578
2020-06-08 12:59:43.633640+0800 Demo_38_block_edit_var[35375:7813379] 定义后外部：b：0x7ffee3d8105c
2020-06-08 12:59:43.633754+0800 Demo_38_block_edit_var[35375:7813379] block内部：a：0x600003683578
2020-06-08 12:59:43.633859+0800 Demo_38_block_edit_var[35375:7813379] block内部：b：0x6000038ff628

 ```

 `__block` 关键字修饰后，int类型也从4字节变成了32字节，这是 Foundation 框架 malloc 出来的。这也同样能证实上面的结论。（PS：居然比 NSObject alloc 出来的 16  字节要多一倍）。



改外部变量必要条件之“将 auto 变量封装为结构体(对象)”
-------------



正如上文提到的：

 > 我们都知道：**Block不允许修改外部变量的值**，这里所说的外部变量的值，指的是栈中 auto 变量。`__block` 作用是将 auto 变量封装为结构体(对象)，在结构体内部新建一个同名 auto 变量，block 内截获该结构体的指针，在 block 中使用自动变量时，使用指针指向的结构体中的自动变量。于是就可以达到修改外部变量的作用。
 
如果把编译器的“不允许修改外部”这种行为理解为：对 block 内部捕获到的 auto 变量设置为只读属性---不允许直接修改。

那么 `__block` 的作用就是创建了一个函数，允许你通过这个函数修改“对外只读”的属性。

属性对外只读，但是对外提供专门的修改值的方法，在开发中这种做法非常常见。

自动变量生成的结构体：


 ```Objective-C
struct __Block_byref_c_0 {
  void *__isa;
__Block_byref_c_0 *__forwarding;
 int __flags;
 int __size;
//自动变量
 int c;
};
 ```


block:

 ```Objective-C
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
//截获的结构体指针
  __Block_byref_c_0 *c; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_c_0 *_c, int flags=0) : c(_c->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
 ```

block中使用自动变量：


 ```Objective-C
static int __main_block_func_0(struct __main_block_impl_0 *__cself, int a) {
//指针
  __Block_byref_c_0 *c = __cself->c; // bound by ref
            (c->__forwarding->c) = 11;
            a = a + (c->__forwarding->c);
            return a;
}
 ```
 
 

理解到这是因为添加了修改只读属性的方法，而非所谓的“写操作生效”，这一点至关重要，要不然你如何解释下面这个现象：

以下代码编译可以通过，并且在 block 中成功将 a 的从 Tom 修改为 Jerry。
      
 ```Objective-C
    NSMutableString *a = [NSMutableString stringWithString:@"Tom"];
    void (^foo)(void) = ^{
        a.string = @"Jerry";
        //a = [NSMutableString stringWithString:@"William"]; //编译报错
    };
    foo();
 ```


 
 同理如下操作也是允许的： 
 
 
 ```Objective-C
//
//  main.m
//  Demo_38_block_edit_var
//
//  Created by chenyilong on 2020/6/3.
//  Copyright © 2020 ChenYilong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
typedef void (^CYLBlock)(void);
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        NSMutableArray *array = [[NSMutableArray array] init];
        CYLBlock block = ^{
            [array addobject: 0"123"];
            array = nil; //编译报错
        };
        block();
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}

 ```


以上都是在使用变量而非修改变量，所以不会编译报错。

![](https://tva1.sinaimg.cn/large/007S8ZIlly1gfl28fzqzhj31k40m2amd.jpg)


### 使用系统的某些block api（如UIView的block版本写动画时），是否也考虑引用循环问题？ 

注：39题对应Demo 请在仓库中查看以 Demo39 开头的工程。 

出题只举了一个例子，我们多举几个例子：


 ```Objective-C
//判断如下几种情况,是否有循环引用? 是否有内存泄漏?
//2020-06-01 16:34:43 @iTeaTime(技术清谈)@ChenYilong 

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

系统的某些block api中，比如 `UIView` 的 `block` 版本写动画时不需要考虑循环引用的问题，但也有一些系统 api 需要考虑内存泄漏的问题。

其中 `UIView` 的 `block` 版本写动画时不需要考虑虑循环引用的原因是：

比如典型的代码是这样：

 ```Objective-C
 //@iTeaTime(技术清谈)@ChenYilong 
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


-------------

情况二:




 ```Objective-C
 //@iTeaTime(技术清谈)@ChenYilong 
 //思考：是否有内存泄漏?是否有循环引用?
[[NSNotificationCenter defaultCenter] addObserverForName:@"someNotification" 
                                                  object:nil 
                           queue:[NSOperationQueue mainQueue]
                                              usingBlock:^(NSNotification * notification) {
                                                    self.someProperty = xyz; }]; 
 ```
 
 情况三:
 
 ```Objective-C
 //@iTeaTime(技术清谈)@ChenYilong 
 //思考：是否有内存泄漏?是否有循环引用?
  _observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"testKey"
                                                                object:nil
                                                                 queue:nil
                                                            usingBlock:^(NSNotification *note) {
      [self dismissModalViewControllerAnimated:YES];
  }];
 ```
 

情况四:

而下面的代码虽然有类似的结构但并不存在内存泄漏:


 ```Objective-C
 //@iTeaTime(技术清谈)@ChenYilong 
  //思考：是否有内存泄漏?是否有循环引用?
    dispatch_group_async(self.operationGroup, self.serialQueue, ^{
        [self doSomething];
    });
 ```


那么为什么情况二 `NSNotificationCenter` 的代码会有内存泄漏问题呢？


~~我之前的理解: self --> _observer --> block --> self 显然这也是一个循环引用。（对循环引用的成因解释有误，详见issue#73 https://github.com/ChenYilong/iOSInterviewQuestions/issues/73 ）~~


其实和循环引用没有关系；这里 `block` 强引用了 `self` , 但是 `self` 并没有强引用`block`; 所以没有循环引用。

情况二这里出现内存泄漏问题实际上是因为：

 - `[NSNoficationCenter defaultCenter]` 持有了 `block`
 - 这个 `block` 持有了 `self`; 
 - 而 `[NSNoficationCenter defaultCenter]` 是一个单例，因此这个单例持有了 `self`, 从而导致 `self` 不被释放。

![https://github.com/ChenYilong](https://tva1.sinaimg.cn/large/007S8ZIlgy1gfcrlp0gn0j30z40lwag6.jpg)

这个结论可参考参考issue中讨论：[《第39题的一些疑问 #138》](https://github.com/ChenYilong/iOSInterviewQuestions/issues/138) 



![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gfd5t6s8n8j31c00u0u0y.jpg)

以下来自[APPLE API文档 -- Instance Method
addObserverForName:object:queue:usingBlock:]( https://developer.apple.com/documentation/foundation/nsnotificationcenter/1411723-addobserverforname) ：

> The block is copied by the notification center and (the copy) held until the observer registration is removed.

但整个过程中并没有循环引用，因为 `self` 没有持有 `NotificationCenter` , 也没有持有 `block`。即使 `self` 持有这个`Observer`, 并没有任何证据或者文档标明 `Observer` 会持有这个`block`, 所以我之前的解释是不正确的。这里 Observer 应该是不持有 block 的，因为只需要 `NSNotificationCenter` 同时持有 `Observer` 和 `block` 即可实现 `API` 所提供的功能, 这里也不存在循环引用。



其中情况三:

存在循环引用

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gfd5sf6tbbj31c00u0npd.jpg)

![https://github.com/ChenYilong](https://i.loli.net/2020/06/02/pDLde8Hgkt4X69u.gif)

![](https://tva1.sinaimg.cn/large/007S8ZIlgy1gfd5v5laamj31hc0u0dvv.jpg)

根据上面的原理，思考一下情况五：

 ```Objective-C
  //@iTeaTime(技术清谈)@ChenYilong 
  //思考：是否有内存泄漏?是否有循环引用?
[[NSOperationQueue mainQueue] addOperationWithBlock:^{ self.someProperty = xyz; }]; 
 ```
 
 <p><del> 这个因为 `[NSOperationQueue mainQueue]` 并非单例，所以并没有内存泄漏。
 见下图:
 
https://tva1.sinaimg.cn/large/007S8ZIlgy1gfct4s2979j30y00lq0y0.jpg
 (此图有问题, 请忽略, 请参考下文的正确描述)
 
 </del></p>
 
在 Gnustep 源码中可以证实
`[NSOperationQueue mainQueue]` 是单例，然后参考 `addOperationWithBlock` 源码可知：

虽然是单例，但它并不持有 `block`，不会造成循环引用，传递完成后就销毁了，不会造成无法释放的内存泄漏问题。

参考issue中讨论：[《第39题的一些疑问 #138》](https://github.com/ChenYilong/iOSInterviewQuestions/issues/138) 

-------------

针对情况四 `GCD` 的问题，实际上，self确实持有了queue; 而block也确实持有了self; 但是并没有证据或者文档表明这个queue一定会持有block; 而且即使queue持有了block, 在block执行完毕的时候，由于需要将任务从队列中移除，因此完全可以解除queue对block的持有关系，所以实际上这里也不存在循环引用。下面的测试代码可以验证这一点(其中`CYLUser`有一个属性name):


 ```Objective-C
   //@iTeaTime(技术清谈)@ChenYilong 
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


### Block的修饰符
```Objective-C
void (^block)(void);//定义一个block

@interface TestObject : NSObject
@end

@implementation TestObject
- (void)dealloc {
    NSLog(@"对象已经被释放");
}
@end
```

强引用
```Objective-C
void test__strong() {
    {
        TestObject *obj = [[TestObject alloc] init];
        NSLog(@"before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
        block = ^(){ //全局的block变量，被栈上的代码块赋值，会执行copy操作，从栈指向了堆
            NSLog(@"obj对象地址:%@",obj);
        };
        NSLog(@"after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //3   由于代码块创建的时候在栈上，内部对obj有强引用,而在赋值给全局变量block的时候,被拷贝到了堆上（对obj又引用了一次）,所以加了2次引用计数.
        
        //当前block
        NSLog(@"堆 - %@",[block class]);//从栈拷贝到了堆
        
        //obj无法被释放，因为block堆obj还是有强引用
        
    }
    block();
}
```

弱引用
```Objective-C
void test__weak() {
    {
        TestObject *obj = [[TestObject alloc] init];
        NSLog(@"before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
        __weak NSObject *weak_obj = obj;
        block = ^(){ //block对weak_obj是有强引用， 但是weak_obj是一个弱指针不会增加引用计数
            NSLog(@"obj对象地址:%@",weak_obj);
        };
        NSLog(@"after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1 ,weak不新增引用计数
        NSLog(@"堆 - %@",[block class]);
        
    }
    block();
}
```

block内部使用强引用，防止block修饰的弱引用对象被提前释放
```Objective-C
void test_use_strong() {
    TestObject *obj = [[TestObject alloc] init];
    __weak TestObject *weakObj = obj;
    NSLog(@"before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
    block = ^(){
        __strong TestObject *strongObj = weakObj; //确保weakObj不被释放掉
        NSLog(@"obj对象地址:%@",strongObj);
        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
            for (int i = 0; i < 10000; i++) {
                // 模拟一个耗时的任务
            }
            NSLog(@"耗时的任务 结束 obj对象地址:%@",strongObj); //这里的strongObj还是存在的。只有离开作用于，strongObj才会被释放
        });
    };
    NSLog(@"after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj));//1
    block();
}
```

CXPerson被block强引用着
```Objective-C
@interface CXPerson : NSObject
@property (nonatomic, copy) NSString *name;
@end

@implementation CXPerson
- (void)dealloc {
    NSLog(@"CXPerson dealloc");
}
@end

typedef void(^CXBlock) (void);

void block_strong() {
    CXBlock block;
    
    {
        CXPerson *p = [[CXPerson alloc] init];
        p.name = @"shenchuxning";
        block = ^{
            NSLog(@"name = %@" , p.name); //CXPerson被block强引用着
        };
    }
} //作用域结束CXBlock不会存在，强引用的CXPerson也被释放了
```


### Block的类型
```Objective-C
void test()
{
    // __NSGlobalBlock__ : __NSGlobalBlock : NSBlock : NSObject
    void (^block)(void) = ^{
        NSLog(@"Hello");
    };
    
    NSLog(@"%@", [block class]);//__NSGlobalBlock__
    NSLog(@"%@", [[block class] superclass]);//NSBlock
    NSLog(@"%@", [[[block class] superclass] superclass]);//NSObject
    NSLog(@"%@", [[[[block class] superclass] superclass] superclass]);//null
}
```

```Objective-C
int age = 20;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int a = 10;
        
        void (^block1)(void) = ^{ //没有访问auto变量，__NSGlobalBlock__，存放在全局区（数据段）
            NSLog(@"Hello");
        };
        
        int age = 10;
        //被block2变量强引用着，block在堆上
        void (^block2)(void) = ^{ //访问了自动变量，__NSMallocBlock__，存放在堆
            NSLog(@"Hello - %d", age);
        };
    
        //__NSGlobalBlock__ __NSMallocBlock__
        NSLog(@"%@ %@", [block1 class], [block2 class]);
        
        //访问了auto变量，但是没有被强引用，__NSStackBlock__（存放在栈）
        NSLog(@"%@",[^{
            NSLog(@"%d", age);
        } class]);
        
        //没有被强引用，还是__NSStackBlock__
        __block int height = 10;
        NSLog(@"%@",[^{
            height = 20;
            NSLog(@"%d", height);
        } class]);
        
        NSLog(@"-------------");
    }
    return 0;
}
```


以下代码在MRC环境下
```Objective-C
#import <Foundation/Foundation.h>
#import "MJPerson.h"

void (^block)(void);
void test2()
{
    
    // NSStackBlock
    int age = 10;
    block = [^{ //MRC下block变量不会强引用该block对象,block离开test2作用域就销毁了
        NSLog(@"block---------%d", age); //不copy会访问混乱
    } copy];
    NSLog(@"block类型%@",[block class]); //MRC下,必须copy,会变成mallocblock
    [block release];
}

void test()
{
    // Global：没有访问auto变量
    void (^block1)(void) = ^{
        NSLog(@"block1---------");
    };
    
    // Stack：访问了auto变量
    int age = 10;
    void (^block2)(void) = ^{
        NSLog(@"block2---------%d", age);
    };
    NSLog(@"%p", [block2 copy]);//arc会自动copy,mrc需要手动，在堆上
    
    NSLog(@"全局:%@ 不copy在栈:%@ copy后在堆:%@", [block1 class],  [block2 class] ,[[block2 copy] class]);
}

int age = 10;

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int a = 10;
        
        NSLog(@"代码区：%p", __func__);
        NSLog(@"数据段：age %p", &age);
        NSLog(@"栈：a %p", &a);
        NSLog(@"堆：obj = %p", [[NSObject alloc] init]);
        NSLog(@"数据段：class %p", [MJPerson class]);
        
        test2();
        block();
        test();
    }
    return 0;
}
```

以下代码在MRC环境下
```Objective-C
#import <Foundation/Foundation.h>
#import "MJPerson.h"

typedef void (^MJBlock) (void);

struct __Block_byref_age_0 {
    void *__isa;
    struct __Block_byref_age_0 *__forwarding;
    int __flags;
    int __size;
    int age;
};

struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    void (*copy)(void);
    void (*dispose)(void);
};

struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    struct __Block_byref_age_0 *age;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        MJPerson *person = [[MJPerson alloc] init];
        
        MJBlock block = [^{
            NSLog(@"%p", person);
        } copy];
        
        NSLog(@"%d",[person retainCount]); //2,copy从栈拷贝到了堆，对person有强引用，如果不copy，引用计数还是1
        [person release];
        
        block();
        
        [block release]; //block持有person,block结束person才能释放
    }
    return 0;
}
```


### block的内存管理
```Objective-C
#import <Foundation/Foundation.h>

typedef void (^MJBlock) (void);

struct __Block_byref_age_0 {//__block修饰的普通类型生成的结构体
    void *__isa;
    struct __Block_byref_age_0 *__forwarding;
    int __flags;
    int __size;
    int age;
};

struct __Block_byref_bweakObj_1 {//__block修饰的对象类型生成的结构体
  void *__isa;
    struct __Block_byref_bweakObj_1 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*); //对象类型才会生成这两个函数copy和dispose
 void (*__Block_byref_id_object_dispose)(void*);
 NSObject *__weak bweakObj; //auto对象类型，受修饰符影响生成强弱引用，注意：这里只有ARC才会retain，MRC是不会retain的
};

struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    void (*copy)(void);
    void (*dispose)(void);
};

struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

struct __main_block_impl_0 {
    struct __block_impl impl;
    struct __main_block_desc_0* Desc;
    struct __Block_byref_age_0 *age;
    NSObject *__weak weakObject;//auto对象类型，受修饰符影响生成强弱引用
    struct __Block_byref_bweakObj_1 *bweakObj;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        int no = 20;
        
        __block int age = 10; //1.__block修饰的普通变量
        
        NSObject *object = [[NSObject alloc] init];
        __weak NSObject *weakObject = object; //2.auto对象变量
        
        __block __weak NSObject *bweakObj = object; //3.__block和__weak同时修饰的auto对象变量
        
        //注意：block在栈上时，不会对__block变量age和auto对象产生强引用
        
        MJBlock block = ^{
            //栈上的block被拷贝到堆，首先会生成void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*) 和 void (*dispose)(struct __main_block_impl_0*);两个函数
            
            //__block普通变量age的内存管理：block被拷贝到堆上，会调用block内部的copy函数，copy内部会调用_Block_object_assign函数，这里的_Block_object_assign函数最后一个参数是8，对__block变量形成强引用（这里必定是强引用，和修饰符无关）,生成__Block_byref_age_0的结构体，里面有age变量 = 10，
            
            //对象类型的auto变量weakObject的内存管理：会调用block内部的copy函数，copy内部会调用_Block_object_assign函数，这里的_Block_object_assign函数最后一个参数是3，会根据修饰符生成对应的强或者弱引用，这里是弱引用NSObject *__weak weakObject;
            
            //__block对象变量bweakObj的内存管理：block被拷贝到堆上，会调用block内部的copy函数，copy内部会调用_Block_object_assign函数，这里的_Block_object_assign函数最后一个参数是8，对__block变量形成强引用（这里必定是强引用，和修饰符无关）,生成__Block_byref_bweakObj_1的结构体，里面有weak修饰的bweakObj变量，
            
            age = 20;
            
            NSLog(@"%d", no);//20
            NSLog(@"%d", age);//20
            NSLog(@"%p", weakObject);//堆地址
            NSLog(@"%p", bweakObj);
        };
        
        struct __main_block_impl_0* blockImpl = (__bridge struct __main_block_impl_0*)block;
        block();
        
        
        //__block普通变量从堆中移除的时候，调用dispose函数，内部会调用_Block_object_dispose函数，_Block_object_dispose函数会自动释放__block变量。这里的_Block_object_dispose函数最后一个参数是8
        //auto对象变量从堆中移除的时候，调用dispose函数，内部会调用_Block_object_dispose函数，_Block_object_dispose函数会自动释放__block变量。这里的_Block_object_dispose函数最后一个参数是3
        //__block对象变量从堆中移除的时候，调用dispose函数，内部会调用_Block_object_dispose函数，_Block_object_dispose函数会自动释放__block变量。这里的_Block_object_dispose函数最后一个参数是8
    }
    return 0;
}

```
