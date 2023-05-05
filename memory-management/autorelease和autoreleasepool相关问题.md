# autorelease和autoreleasepool相关问题

### autoreleasepool结构
```
#import <Foundation/Foundation.h>
#import "MJPerson.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        atautoreleasepoolobj = objc_autoreleasePoolPush();
        for (int i = 0; i < 1000; i++) {
            MJPerson *person = [[[MJPerson alloc] init] autorelease];
        } // 8000个字节
//        objc_autoreleasePoolPop(atautoreleasepoolobj);
    }
    return 0;
}

实际生成的是__AtAutoreleasePool结构体
/*
 struct __AtAutoreleasePool {
    __AtAutoreleasePool() { // 构造函数，在创建结构体的时候调用
        atautoreleasepoolobj = objc_autoreleasePoolPush(); //将POOL_BOUNDARY入栈，并返回第一个可填充的地址atautoreleasepoolobj
    }
    ~__AtAutoreleasePool() { // 析构函数，在结构体销毁的时候调用
objc_autoreleasePoolPop(atautoreleasepoolobj); //告诉pop，当初的第一个填充的地址atautoreleasepoolobj。这样，释放的时候将autorelease对象，一个个逆序释放，直到遇到atautoreleasepoolobj。
    }
    void * atautoreleasepoolobj;
 };
 
 {
    __AtAutoreleasePool __autoreleasepool;
    MJPerson *person = ((MJPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((MJPerson *(*)(id, SEL))(void *)objc_msgSend)((id)((MJPerson *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("MJPerson"), sel_registerName("alloc")), sel_registerName("init")), sel_registerName("autorelease"));
 }
 
    atautoreleasepoolobj = objc_autoreleasePoolPush();
    MJPerson *person = [[[MJPerson alloc] init] autorelease];
objc_autoreleasePoolPop(atautoreleasepoolobj);
 */
```

### autorelease释放时机

```
#import "ViewController.h"
#import "MJPerson.h"
@interface ViewController ()
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 这个Person什么时候调用release，是由RunLoop来控制的
    // 它可能是在某次RunLoop循环中，RunLoop休眠之前调用了release
//    MJPerson *person = [[[MJPerson alloc] init] autorelease];

    //person在viewDidLoad结束后释放
    MJPerson *person = [[MJPerson alloc] init];
    NSLog(@"%s", __func__);

    //方法里面的局部对象如果是autorleasepool管理的对象，是在某次runloop结束释放，如果是arc管理的，则在方法结束就释放了。

    @autoreleasepool {
        MJPerson *person2 = [[MJPerson alloc] init];//person2是autoreleasepool大括号结束后释放
    }
    NSLog(@"111");

    //person3释放时机是viewWillAppear 和 viewDidAppear 之间
    __autoreleasing MJPerson *person3 = [[MJPerson alloc] init];
    NSLog(@"222");
}

//下面的对象 ，分别在什么地方被释放 ?
- (void)weakLifeCycleTest {
    id obj0 = @"iTeaTime(技术清谈)";//obj0 字符串属于常量区，不会释放
    __weak id obj1 = obj0;//obj1 指向的对象在常量区，不会释放
    //obj2 没有修复符，默认为 `__strong`，会在对象被使用结束时释放。如果下方没有使用该对象，根据编译器是否优化，可能在下一行直接销毁，最晚可以在方法结束时销毁。
    id obj2 = [NSObject new];
    //obj3 警告 “Assigning retained object to weak variable; object will be released after assignment” ，new 结束后，等号右侧对象立马被释放，左侧指针也立即销毁，下方打印也是 null
    __weak id obj3 = [NSObject new];
    {
        //obj4 出了最近的括号销毁
        id obj4 = [NSObject new];
    }
    //obj5 出了最近的一个 autoreleasePool 时被释放
    __autoreleasing id obj5 = [NSObject new];
    //obj6 类似于基本数据结构的修饰符号 assign ，不会对修饰对象的生命周期产生影响，随着self的释放，obj6也会随之释放。比如 self 被其它线程释放，那么obj6也会随之释放。
    __unsafe_unretained id obj6 = self;
    NSLog(@"obj0=%@, obj1=%@, obj2=%@, obj3=%@, obj5=%@, obj6=%@", obj0, obj1, obj2, obj3, obj5, obj6);
}

- (void)viewWillAppear:(BOOL)animated //viewdidload和willappear处于同一个runloop循环  和viewDidAppear不是处于同一个循环
{
    [super viewWillAppear:animated];
    NSLog(@"%s", __func__);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%s", __func__);
}

/*

 typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
 kCFRunLoopEntry = (1UL << 0),  1
 kCFRunLoopBeforeTimers = (1UL << 1), 2
 kCFRunLoopBeforeSources = (1UL << 2), 4
 kCFRunLoopBeforeWaiting = (1UL << 5), 32
 kCFRunLoopAfterWaiting = (1UL << 6), 64
 kCFRunLoopExit = (1UL << 7), 128
 kCFRunLoopAllActivities = 0x0FFFFFFFU
 };
 */

#pragma mark - runloop启动的时候会注册2个观察者：第一个观察者的回调_wrapRunLoopWithAutoreleasePoolHandler、第二个观察者的回调_wrapRunLoopWithAutoreleasePoolHandler
/*
 activities = 0x1 ：等于1，因此监听的是kCFRunLoopEntry  push操作
 <CFRunLoopObserver 0x60000013f220 [0x1031c8c80]>{valid = Yes, activities = 0x1, repeats = Yes, order = -2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x103376df2), context = <CFArray 0x60000025aa00 [0x1031c8c80]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7fd0bf802048>\n)}}

 activities = 0xa0：等于160 = 128 + 32，监听的是kCFRunLoopBeforeWaiting | kCFRunLoopExit
 kCFRunLoopBeforeWaiting | kCFRunLoopExit
 kCFRunLoopBeforeWaiting：先 pop、再push
 kCFRunLoopExit： pop

 <CFRunLoopObserver 0x60000013f0e0 [0x1031c8c80]>{valid = Yes, activities = 0xa0, repeats = Yes, order = 2147483647, callout = _wrapRunLoopWithAutoreleasePoolHandler (0x103376df2), context = <CFArray 0x60000025aa00 [0x1031c8c80]>{type = mutable-small, count = 1, values = (\n\t0 : <0x7fd0bf802048>\n)}}
 */
@end
```

### __autorelease使用场景

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