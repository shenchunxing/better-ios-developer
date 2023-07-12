
### 什么是Block？
Block是封装了函数调用和函数调用环境的OC对象

### 为什么block不能修改外部变量的值？
我们在写Block的时候，看起来外部变量和Block是在一个作用域内，其实编译器在编译的过程中会把Block分解多个方法，这时候外部变量和Block其实是不在同一个作用域内，所以无法做到修改这个变量。
 通过__block的修饰，这时候Block在编译的过程中就会获取外部变量的指针，通过指针来修改变量。

### 函数指针和block的区别？

函数指针和 Block 是两种不同的概念，它们在语法和使用方式上有一些区别。
函数指针是指向函数的指针变量。它允许您将函数作为参数传递给其他函数或将函数赋值给指针变量，以便稍后调用该函数。函数指针的类型与所指向函数的返回类型和参数类型相匹配。

以下是一个函数指针的示例：
```
int add(int a, int b) {
    return a + b;
}

int (*funcPtr)(int, int); // 声明一个函数指针
funcPtr = add; // 将函数赋值给函数指针
int result = funcPtr(3, 5); // 通过函数指针调用函数

NSLog(@"Result: %d", result); // 输出：Result: 8
```
Block 是一种特殊的语法，它允许您创建匿名函数或闭包。它捕获了其定义范围内的变量，并可以在稍后的时间点执行其中的代码。Block 通常用于异步操作、回调函数、事件处理等场景。

以下是一个 Block 的示例：
```
int (^block)(int, int) = ^(int a, int b) {
    return a + b;
};

int result = block(3, 5); // 调用 Block

NSLog(@"Result: %d", result); // 输出：Result: 8
```
可以看到，Block 使用了 ^ 符号来定义一个匿名函数，可以像函数一样使用，但它的语法更紧凑。Block 也可以捕获外部变量，使其在 Block 内部可见。

关于函数指针和 Block 的区别：

语法：函数指针使用 (*funcPtr)(...) 的形式来声明和使用，而 Block 使用 ^ 符号来定义和使用。

上下文：函数指针是对函数的引用，而 Block 是一个封装了代码块和上下文的对象。
可见性：函数指针只能访问其所指向的函数，而 Block 可以捕获并访问其定义范围内的变量。
匿名性：函数指针需要定义一个具名函数或引用现有的函数，而 Block 可以在代码中直接定义匿名函数。
内存管理：函数指针不需要特殊的内存管理，而 Block 在捕获外部变量时会自动进行内存管理，当 Block 被复制到堆上时，会自动处理变量的引用计数。
总结来说，函数指针适用于简单的函数引用和调用，而 Block 更适用于需要捕获上下文和变量的情况，以及需要定义匿名函数的场景

### 什么时候栈上的Block会复制到堆上呢?
栈上的 Block 会在以下情况下复制到堆上：

Block 在定义时捕获了外部的对象（包括局部变量）：如果 Block 在定义时捕获了外部的对象（使用了这些对象的变量），并且该 Block 在定义后在作用域外被使用（例如，被赋值给其他变量、作为参数传递、存储在全局容器中等），那么该 Block 将被复制到堆上。这样做是为了确保在 Block 在堆上执行时，仍然能够访问到正确的捕获对象。

Block 被作为参数传递给带有复制语义的方法或函数：如果将 Block 作为参数传递给具有复制语义的方法或函数（例如 GCD 的 API 中的一些函数），那么该 Block 将被复制到堆上，以便能够在其他线程或作用域中正确地使用。

在上述情况下，编译器会将栈上的 Block 复制到堆上，并在堆上分配内存来存储 Block 对象及其相关的数据。复制后的 Block 在堆上进行内存管理，即使定义它的作用域结束，也能够继续使用。

需要注意的是，对于不捕获任何外部对象的 Block（也称为纯粹的 Block），它们通常在栈上分配，并在定义的作用域结束后被销毁。这是因为纯粹的 Block 不需要访问外部对象的内存。

### Block访问对象类型的auto变量时，在ARC和MRC下有什么区别?
 在ARC下，栈区创建的block会自动copy到堆区；而MRC下，就不会自动拷贝了，需要我们手动调用copy函数。

 我们再说说block的copy操作，当block从栈区copy到堆区的过程中，也会对block内部访问的外部变量进行处理，它会调用Block_object_assign函数对变量进行处理，根据外部变量是strong还会weak对block内部捕获的变量进行引用计数+1或-1，从而达到强引用或弱引用的作用。

### 在Masonry的block中，使用self，会造成循环引用吗？如果是在普通的block中呢？
 不会，因为这是个栈block，没有延迟使用，使用后立刻释放
 普通的block会，一般会使用强引用持有，就会触发copy操作 

 因此
 在ARC下，由于block被自动copy到了堆区，从而对外部的对象进行强引用，如果这个对象同样强引用这个block，就会形成循环引用。
 在MRC下，由于访问的外部变量是auto修饰的，所以这个block属于栈区的，如果不对block手动进行copy操作，在运行完block的定义代码段后，block就会被释放，而由于没有进行copy操作，所以这个变量也不会经过Block_object_assign处理，也就不会对变量强引用。
 简单说就是：
 
 ARC下会对这个对象强引用，MRC下不会。 
 ```
[self addSubview:self.button];
[self.button mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self).mas_offset(50);
    make.right.equalTo(self).mas_offset(-30);
    make.width.mas_offset(60);
    make.height.mas_offset(30);
}];
在这段代码中，self 并不直接持有 block。Block 是在 -mas_makeConstraints: 方法内部创建的，并且 block 内部访问了 self。

尽管 block 内部访问了 self，但是在这种情况下，self 并不会持有这个 block。Block 是在局部作用域内创建的，它的生命周期受限于该方法的执行过程。一旦方法执行完毕，block 将被释放，而不会被 self 持有。

```

### Block捕获机制

```
#import <Foundation/Foundation.h>
int age_ = 10;
static int height_ = 20;
void (^block)(void);

void value_pass(){
    int age = 10; // auto：自动变量，离开作用域就销毁，值传递
    block = ^{
        // age的值捕获进来（capture）
        NSLog(@"age is %d", age); //age is 10
    };
    age = 20;
}

void point_pass() {
    static int height = 10;
    block = ^{
        NSLog(@"height is %d", height); //指针传递：height is 20
    };
    height = 20;
}

void global_pass() {
    block = ^{
        NSLog(@"age is %d, height is %d", age_, height_); //age is 20, height is 30  全局变量不需要捕获，谁都可以访问
    };
    age_ = 20;
    height_ = 30;
    block();
}
  
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        value_pass(); //值传递
        block();
        point_pass();//指针传递
        block();
        global_pass();//全局变量传递，不需要捕获
        NSLog(@"----------");
        void (^block1)(int, int) = ^(int a, int b){
            NSLog(@"Hello, World! - %d %d", a, b);
        };
        block1(10, 20);
        void (^block2)(void) = ^{
            NSLog(@"Hello, World!");
        };
        block2();// 调用block->FuncPtr
    }
    return 0;
}
```
### Block的继承体系
```Objective-C
void test() {
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
### ARC下的Block使用和类型
```Objective-C
int age = 20;
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        int a = 10; 
        void (^block1)(void) = ^{ //没有访问auto变量，__NSGlobalBlock__，存放在全局区（数据段）
            NSLog(@"Hello");
        };
   
        int age = 10;
        //被block2变量强引用着，自动copy，block在堆上
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

### ARC下的Block自动copy

```
//强指针
void (^block)(void) = ^{
        NSLog(@"Hello");
    };
```
```
typedef void(^CSBlock)(void);
//返回blcok
void(^CSBlock)(void) myBlock() {
    int age = 10;
    return ^{
        NSLog(@"age = %d",age);
    };
}
```
```
// block作为Cocoa API中方法名含有usingBlock的方法参数时
NSArray *array = [NSArray array];
[array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
}];
```
```
// block作为GCD API的方法参数时
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{            
});
```

### MRC环境下的block和copy（以下代码在MRC运行环境下）
```Objective-C
#import <Foundation/Foundation.h>
#import "MJPerson.h"
void (^block)(void);
void (^block_no_copy)(void);

//block被copy
void block_copyedTest(){
    // NSStackBlock
    int age = 10;
    block = [^{ //MRC下block变量不会强引用该block对象,block对象离开test2作用域就销毁了
        NSLog(@"block---------%d", age); //不copy会访问混乱
    } copy];
    NSLog(@"block类型：%@",[block class]); //MRC下,必须copy,会变成Mallocblock
    [block release];
}

//block不被copy
void block_no_copyedTest() {
    // NSStackBlock
    int age = 30;
    block_no_copy = ^{ //MRC下block_no_copy变量不会强引用该block对象,block对象离开test2作用域就销毁了
        NSLog(@"block_no_copy---------%d", age); //不copy会访问混乱
    };
    NSLog(@"block_no_copy类型：%@",[block_no_copy class]); //MRC下,不copy，仍然是NSStackBlock
    [block_no_copy release];//这里block对象因为没有强引用，直接被释放了，导致后续使用会数据错乱
}

//block类型
void block_type(){
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
    NSLog(@"全局:%@ ,不copy在栈:%@ ,copy后在堆:%@", [block1 class],  [block2 class] ,[[block2 copy] class]);
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
        NSLog(@"------------------");
        
        block_type(); //block类型
        block_copyedTest();//mrc下copy了block
        block();
        NSLog(@"------------------");

        block_no_copyedTest();//mrc下不copy block
        block_no_copy();
    }
    return 0;
}
```
运行结果：

![截屏2023-03-16 08.38.49.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c2968ea4d414364b64051bcb7f95929~tplv-k3u1fbpfcp-watermark.image?)

### Block修饰符
```Objective-C
#import <Foundation/Foundation.h>
#import "MJPerson.h"
typedef void (^MJBlock) (void);
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        MJBlock block = [^{
            NSLog(@"%p", person);
        } copy];
        NSLog(@"%d",[person retainCount]); //block因为copy操作，从栈拷贝到了堆，block对person有强引用，person的引用计数为2
        [person release];
        block();
        [block release]; //block持有person,block结束person才能释放
    }
    return 0;
}
```
```
#import <Foundation/Foundation.h>
#import "MJPerson.h"
typedef void (^MJBlock)(void);
void __weakTest () {
    MJBlock block;
    {
        MJPerson *person = [[MJPerson alloc] init];
        person.age = 10;
        __weak MJPerson *weakPerson = person;
        block = ^{//block对person对象是弱引用，可以安全释放
            NSLog(@"---------%d", weakPerson.age);
        };
    }
    NSLog(@"block被销毁");
}

void __strongTest () {
    MJBlock block;
    {
        MJPerson *person = [[MJPerson alloc] init];
        person.age = 10;
        int age = 10;
        block = ^{ //block对person对象强引用，导致对象无法释放
            NSLog(@"---------%d", person.age);
        };
    }
    NSLog(@"block被销毁");
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __weakTest();
        NSLog(@"--------");
        __strongTest();
    }
    return 0;
}
```
运行结果：

![截屏2023-03-16 08.47.53.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cf05c5a13cca45f2b43ce30df1aa08c4~tplv-k3u1fbpfcp-watermark.image?)

### block的内存管理
```
#import <Foundation/Foundation.h>
#import "CXPerson.h"
void (^block)(void);
typedef void(^CXBlock) (void);

@interface TestObject : NSObject
@end
@implementation TestObject
- (void)dealloc {
    NSLog(@"对象已经被释放");
}
@end

void test__strong() {
    {
        TestObject *obj = [[TestObject alloc] init];
        NSLog(@"before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
        block = ^(){ //全局的block变量，被栈上的代码块赋值，会执行copy操作，从栈指向了堆
            NSLog(@"obj对象地址:%@",obj);
        };
        NSLog(@"after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //3   由于代码块创建的时候在栈上，内部对obj有强引用,引用计数+1，而在赋值给全局变量block的时候,被拷贝到了堆上（对obj又引用了一次）,引用计数+1.
        //当前block
        NSLog(@"堆 - %@",[block class]);//从栈拷贝到了堆
        //obj无法被释放，因为block对obj还是有强引用
    }
    block();
}

void test__weak() {
    {
        TestObject *obj = [[TestObject alloc] init];
        NSLog(@"before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
        __weak NSObject *weak_obj = obj;
        block = ^(){ //block对weak_obj是有强引用， 但是weak_obj是一个弱指针不会增加引用计数，即使赋值给block 内部对 weak_obj 进行了强引用，也不会增加引用计数
            NSLog(@"obj对象地址:%@",weak_obj);
        };
        NSLog(@"after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1 ,weak不新增引用计数
        NSLog(@"堆 - %@",[block class]);
    }
    block();
}

void test_free() {
    TestObject *obj = [[TestObject alloc] init];
    __weak TestObject *weakObj = obj;
    NSLog(@"before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
    block = ^(){
        NSLog(@"obj对象地址:%@",weakObj); //这里obj还存活
        //weakObj因为是弱引用，存在的时间很短（可能就几行普通代码的时间长度）。经过了一个耗时操作，weakObj早已经被释放了
dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
            for (int i = 0; i < 10000; i++) {
                // 模拟一个耗时的任务
            }
            NSLog(@"耗时的任务 结束 obj对象地址:%@",weakObj); //这里obj已经被释放了
        });
    };
    NSLog(@"after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj));//1
    block();
}

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

void test1() {
    CXBlock block;
    {
        CXPerson *p = [[CXPerson alloc] init];
        p.name = @"shenchuxning";
        block = ^{
            NSLog(@"name = %@" , p.name); //CXPerson被block强引用着
        };
    }
    NSLog(@"---------------------"); //作用域结束CXBlock不会存在，强引用的CXPerson也被释放了
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        test__strong();
        NSLog(@"---------------------");
        test__weak();
        NSLog(@"---------------------");
        test_free();
        NSLog(@"---------------------");
        test_use_strong();
        NSLog(@"---------------------");
        test1();
    }
    return 0;
}
```
运行结果：

![截屏2023-03-16 08.52.20.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0831e21b6027457e91f02a7fc80b8628~tplv-k3u1fbpfcp-watermark.image?)

#### block的强弱引用导致对象释放时机不同
其实就是判断强引用到底什么时候释放
```
#import "ViewController.h"
#import "MJPerson.h"
@interface ViewController ()
@end
@implementation ViewController

1秒后释放
- (void)test1 {
    MJPerson *p = [[MJPerson alloc] init];
    __weak MJPerson *weakP = p;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"1-------%@", p); //因为block对p这里有强引用，导致p打印完，才会释放
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"2-------%@", weakP);//weakP指针是弱引用，
        });
    });
    NSLog(@"p即将释放");
}


3秒后释放
- (void)test2 {
    MJPerson *p = [[MJPerson alloc] init];
    __weak MJPerson *weakP = p;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"1-------%@", weakP);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"2-------%@", p);//因为block对p这里有强引用，导致p打印完，才会释放
        });
    });
    NSLog(@"p即将释放");
}

- (void)test3 {
    MJPerson *p = [[MJPerson alloc] init];
    __weak MJPerson *weakP = p;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"1-------%@", p);
        __strong MJPerson *strongPerson = weakP;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"2-------%@", strongPerson);//因为strongPerson对weakP这里有强引用，导致打印完，才会释放
        });
    });
    NSLog(@"p即将释放");
}
@end
```

### Block本质

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6781d510d76f472596aed1bc6607b74a~tplv-k3u1fbpfcp-watermark.image?)
```
struct __main_block_desc_0 {
    size_t reserved;//保留字段，未使用
    size_t Block_size;//Block 对象的大小，即所占内存空间的大小
};
struct __block_impl {
    void *isa;//指向 Block 对象所属的类的指针。在底层，Block 是一个 Objective-C 对象，因此需要isa 指针来指向其类。
    int Flags; //标志位，用于描述 Block 对象的属性和状态。
    int Reserved; //保留字段，未使用
    void *FuncPtr;//函数指针，指向 Block 的实际执行代码
};
// block底层结构体
struct __main_block_impl_0 {
    struct __block_impl impl;//__block_impl 结构体，用于存储 Block 的底层实现
    struct __main_block_desc_0* Desc;//指向一个描述符结构体的指针，描述 Block 的详细信息
    int age; //捕获后，内部有一个age变量
};
// 1.block结构体
void test1() {
    int age = 10;
    //block引用了auto变量age
    void(^block)(int, int) = ^(int a, int b){
        NSLog(@"this is a block! -- %d", age);
        NSLog(@"a = %d, b = %d",a,b);
    };
    struct __main_block_impl_0 *blockStruct = (__bridge struct __main_block_impl_0 *)block;
    block(100,200);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        test1();
    }
    return 0;
}
```

## __block

### __block修饰基本数据类型
生成的数据结构如下：
```
struct __Block_byref_age_0 {
    void *__isa;//指向 __Block_byref_age_0 结构体所属类的指针。在底层，该结构体是一个 Objective-C 对象，因此需要 __isa 指针来指向其类。
    <!-- __forwarding 指针的主要作用是在多个 Block 对象之间共享该变量的管理信息。当多个 Block 对象捕获同一个被 __block 修饰的变量时，它们会共享同一个 __forwarding 指针，以保证它们对变量进行引用计数管理和内存回收时的一致性。具体而言，__forwarding 指针指向了一个共享结构体实例，该结构体存储了被 __block 修饰变量的引用计数信息。这样，当 Block 对象需要对该变量进行引用计数增加或减少时，可以通过 __forwarding 指针访问到共享的引用计数信息，以确保多个 Block 对象之间的引用计数一致。同时，__forwarding 指针还在内存回收时发挥作用。当所有捕获了同一个变量的 Block 对象都被释放时，通过 __forwarding 指针可以将被修饰的变量的内存正确地释放 -->
    struct __Block_byref_age_0 *__forwarding;
    int __flags;//标志位，用于描述 __Block_byref_age_0 结构体的属性和状态。
    int __size;//__Block_byref_age_0 结构体的大小，即所占内存空间的大小
    int age;//被 __block 修饰的字段。
};
struct __main_block_desc_0 {
    size_t reserved;//保留字段，未使用
    size_t Block_size;//Block 对象的大小，即所占内存空间的大小。
    <!-- Block被拷贝到堆，会生成copy和disponse。需要对其进行内存管理 -->
    void (*copy)(void); //指向复制函数的指针。用于在 Block 复制时执行相应的操作
    void (*dispose)(void);//向释放函数的指针。用于在 Block 释放时执行相应的操作。
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
    struct __Block_byref_age_0 *age;//被__block修饰的age字段，被block捕获后，block内部生成__Block_byref_age_0结构体
};
```
测试代码：
```
void __block1Test() {
    __block int age = 10;
    NSLog(@"age在栈上 - %p", &age); //age在栈上
    MJBlock block = ^{ //age被捕获，在__main_block_impl_0内部生成了__Block_byref_age_0结构体，该结构体内部存有age
        age = 20;
        NSLog(@"age is %d", age);
    };
    struct __main_block_impl_0 *blockImpl0 = (__bridge struct __main_block_impl_0 *)block;
    NSLog(@"block - %p , blockImpl0 - %p", block, blockImpl0);
    NSLog(@"blockImpl0->age - %p", blockImpl0->age); //age结构体地址
    NSLog(@"blockImpl0->age->age - %p", &(blockImpl0->age->age));//age结构体里面的age变量地址
    NSLog(@"blockImpl0->age->__forwarding - %p", blockImpl0->age->__forwarding);//__forwarding指向age结构体本身
    NSLog(@"age在堆上 - %p", &age); //age在堆上，打印的是age结构体里面的age变量地址
}

```

### __block 、__weak同时修饰基本数据类型，

__weak不起作用，C++生成的代码和__block int age = 10;的情况一致

```
void __block2Test() {
    //警告：'__weak' only applies to Objective-C object or block pointer types; type here is 'int'
    //__weak修饰的是对象，对基本数据类型没什么用
    __block __weak int age = 10;
    MJBlock block1 = ^{
        //警告：__strong' only applies to Objective-C object or block pointer types; type here is 'int'
        __strong int myage = age; //只是值传递，myage还是保留原来age的值
        age = 20;
        NSLog(@"age is %d", age);//20
        NSLog(@"myage is %d", myage);//10
    };
    MJBlock block2 = ^{
        age = 30;
        NSLog(@"age is %d", age);//30
    };
    block1();
    block2();
}

```
### __block修饰基本数据类型，同时block引用weak修饰的对象类型
```
void __block3Test () {
    int no = 20;
    __block int age = 10;
    NSObject *object = [[NSObject alloc] init];
    //weak修饰对象类型
    __weak NSObject *weakObject = object;
    MJBlock block = ^{
        age = 20;
        NSLog(@"%d", no);//20
        NSLog(@"%d", age);//20
        NSLog(@"%p", weakObject);//堆地址
    };
    struct __main_block_impl_0* blockImpl = (__bridge struct __main_block_impl_0*)block;
    block();
    
}

```
//这种情况的block内部结构
```
struct __main_block_impl_0 {
   struct __block_impl impl;
   struct __main_block_desc_0* Desc;
   int no;
   __Block_byref_age_0 *age; //这里永远是强引用
   NSObject *__weak weakObject; //因为weakObject本身就是对象，这里直接弱引用即可
};
```

### __block、__weak同时修饰对象类型
```
void __block4Test () {
    int no = 20;
    __block int age = 10;
    NSObject *object1 = [[NSObject alloc] init];
    __weak NSObject *weakObject1 = object1;

    NSObject *object2 = [[NSObject alloc] init];
    __block __weak NSObject *weakObject2 = object2;

//栈上的block被拷贝到堆，首先会生成void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*) 和 void (*dispose)(struct __main_block_impl_0*);两个函数(因为需要内存管理了)
    MJBlock block = ^{
        age = 20;
        NSLog(@"%d", no);//20
        
         //__block普通变量age的内存管理：block被拷贝到堆上，会调用block内部的copy函数，copy内部会调用_Block_object_assign函数，这里的_Block_object_assign函数最后一个参数是8，对__block变量形成强引用（这里必定是强引用，和修饰符无关）,生成__Block_byref_age_0的结构体，里面有age变量 = 20，
            NSLog(@"%d", age);//20
        
        //对象类型的auto变量weakObject的内存管理：会调用block内部的copy函数，copy内部会调用_Block_object_assign函数，这里的_Block_object_assign函数最后一个参数是3，会根据修饰符生成对应的强或者弱引用，这里是弱引用NSObject *__weak weakObject1;
        NSLog(@"%p", weakObject1);
        
        
        
            //__block修饰对象变量bweakObj的内存管理：block被拷贝到堆上，会调用block内部的copy函数，copy内部会调用_Block_object_assign函数，这里的_Block_object_assign函数最后一个参数是8，对__block变量形成强引用（这里必定是强引用，和修饰符无关）,生成__Block_byref_weakObject2_4的结构体，里面有weak修饰的weakObject2变量，
        NSLog(@"%p", weakObject2);
    };
    struct __main_block_impl_0* blockImpl = (__bridge struct __main_block_impl_0*)block;
    block();


 struct ____block4Test_block_impl_0 {
       struct __block_impl impl;
       struct ____block4Test_block_desc_0* Desc;
       int no; //基本数据类型
       NSObject *__weak weakObject1; // 弱引用
       __Block_byref_age_3 *age; // 强引用
      __Block_byref_weakObject2_4 *weakObject2; //  强引用
    };

    
    //weakObject2变量被捕获后，在block内部结构生成__Block_byref_weakObject2_4
    struct __Block_byref_weakObject2_4 {
      void *__isa;
      __Block_byref_weakObject2_4 *__forwarding;
      int __flags;
      int __size;
      <!-- 这两个函数只有在对象类型才会生成 -->
      void (*__Block_byref_id_object_copy)(void*, void*);
      void (*__Block_byref_id_object_dispose)(void*);
      <!-- 这里的强弱引用关系来自外部修饰符 -->
      NSObject *__weak weakObject2; 
   };

}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        __block1Test();//__block修饰基本数据类型
        NSLog(@"------------");
        __block2Test();//__block __weak同时修饰基本数据类型
        NSLog(@"------------");
        __block3Test();//block内部使用weak对象和__block对象
        NSLog(@"------------");
        __block4Test();//block内部使用weak对象和__block对象
        
        
        <!--  三种变量类型的释放情况。注意：因为都涉及到对象的释放，必定会有内存管理函数dispose -->
         //__block普通变量从堆中移除的时候，调用dispose函数，内部会调用_Block_object_dispose函数，_Block_object_dispose函数会自动释放__block变量。这里的_Block_object_dispose函数最后一个参数是8
        //auto对象变量从堆中移除的时候，调用dispose函数，内部会调用_Block_object_dispose函数，_Block_object_dispose函数会自动释放__block变量。这里的_Block_object_dispose函数最后一个参数是3
        //__block对象变量从堆中移除的时候，调用dispose函数，内部会调用_Block_object_dispose函数，_Block_object_dispose函数会自动释放__block变量。这里的_Block_object_dispose函数最后一个参数是8
    }
    return 0;
}
```
运行结果：
![截屏2023-03-16 09.28.05.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/133732df83954626b7cfd84ed56d43f7~tplv-k3u1fbpfcp-watermark.image?)

### __block的内存管理
-   1.当block在栈上时，并不会对__block变量产生强引用（block在栈上会随时销毁，必然不会强引用）
-   2.当block被copy到堆时（不管修饰的是基本数据类型还是对象类型，都会生成新的对象，需要内存管理）
    -   会调用block内部的copy函数
    -   copy函数内部会调用_Block_object_assign函数
    -   _Block_object_assign函数会对__block变量形成强引用（retain）

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ca80682378c1481fb7c252268b2cdf1c~tplv-k3u1fbpfcp-watermark.image?)
  
![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ba24d0f9e5c343e391ae2f4d9e1e7b40~tplv-k3u1fbpfcp-watermark.image?)
-   3.当block从堆中移除时
    -   会调用block内部的dispose函数
    -   dispose函数内部会调用_Block_object_dispose函数
    -   _Block_object_dispose函数会自动释放引用的__block变量（release）

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7f0cad65009f4b60a63ee0f1503abcaf~tplv-k3u1fbpfcp-watermark.image?)