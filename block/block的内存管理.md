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
        NSLog(@"after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //3   由于代码块创建的时候在栈上，内部对obj有强引用,而在赋值给全局变量block的时候,被拷贝到了堆上（对obj又引用了一次）,所以加了2次引用计数.
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
        block = ^(){ //block对weak_obj是有强引用， 但是weak_obj是一个弱指针不会增加引用计数
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
```
#import "ViewController.h"
#import "MJPerson.h"
@interface ViewController ()
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self test1];//先strong后weak,1秒后就释放
//    [self test2];//先weak后strong，3秒后释放
    [self test3];//先strong后weak,但是因为weak指针又被strong强引用，3秒后释放
}

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
    size_t reserved;//保留字段，暂时无用
    size_t Block_size;//block大小
};
struct __block_impl {
    void *isa;//isa指针，Block是一个OC对象
    int Flags;
    int Reserved;
    void *FuncPtr;//函数指针
};
// block底层结构体
struct __main_block_impl_0 {
    struct __block_impl impl;//实现
    struct __main_block_desc_0* Desc;//描述
    int age; //内部有一个age变量
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
    void *__isa;
    struct __Block_byref_age_0 *__forwarding;
    int __flags;
    int __size;
    int age;
};
struct __main_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    void (*copy)(void); //blockv被拷贝到堆，会生成这两个函数（因为需要内存管理）
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
### __block 、__weak同时修饰基本数据类型

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
    
    //这种情况的block内部结构
    struct __main_block_impl_0 {
       struct __block_impl impl;
       struct __main_block_desc_0* Desc;
       __Block_byref_age_0 *age; //这里永远是强引用
       NSObject *__weak weakObject; //弱引用
    };
}

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
    
    //这种情况的block内部结构
    struct __Block_byref_weakObject2_4 {
      void *__isa;
      __Block_byref_weakObject2_4 *__forwarding;
      int __flags;
      int __size;
      void (*__Block_byref_id_object_copy)(void*, void*);//对象类型才会生成这2个函数
      void (*__Block_byref_id_object_dispose)(void*);
      NSObject *__weak weakObject2; //这里是弱引用
   };

    struct ____block4Test_block_impl_0 {
       struct __block_impl impl;
       struct ____block4Test_block_desc_0* Desc;
       int no;
       NSObject *__weak weakObject1;
       __Block_byref_age_3 *age; // 强引用
      __Block_byref_weakObject2_4 *weakObject2; //  强引用
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
-   1.当block在栈上时，并不会对__block变量产生强引用
-   2.当block被copy到堆时
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