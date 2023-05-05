# TaggedPointer相关问题

### 是否是TaggedPointer
```
BOOL isTaggedPointer(id pointer){
    return (long)(__bridge void *)pointer & 1; //mac平台：指针的最低有效位是1 ios平台：指针最高有效位是1
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        NSNumber *number = [NSNumber numberWithInt:10];
//        NSNumber *number = @(10);
        NSNumber *number1 = @4;//直接存储在栈区指针当中
        NSNumber *number2 = @5;
        NSNumber *number3 = @(0xFFFFFFFFFFFFFFF);
        number1.intValue; //这种还是会执行objc_msgSend，内部做了优化，没有堆空间，没有对象。直接从直接里面读取

        NSLog(@"%d %d %d", isTaggedPointer(number1), isTaggedPointer(number2), isTaggedPointer(number3)); //1 1 0
        NSLog(@"%p %p %p", number1, number2, number3);//0x3a1fc585dbe0a4e3 0x3a1fc585dbe0a5e3 0x600000208460
    }
    return 0;
}
```
### TaggedPointer对象可以避免多次release导致的崩溃
```
#import "ViewController.h"
@interface ViewController ()
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSLock *lock; //方案2:加锁/解锁
//@property (strong, atomic) NSString *name;//方案1:atomic可以确保setter线程安全，可以解决崩溃问题
@end

@implementation ViewController
//arc本质实际是mrc，内存管理只对对象有用，taggerpoint不受内存管理
//- (void)setName:(NSString *)name
//{
//    if (_name != name) {
//        [_name release];//崩溃的原因是多个线程进行多次release导致
//        _name = [name retain];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lock = [[NSLock alloc] init];

    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            // 加锁后只允许一个线程进入，不会多次release
//            [self.lock lock];
            self.name = [NSString stringWithFormat:@"abcdefghijk"]; //报错坏内存访问,因为[_name release]被多次执行
            // 解锁
//            [self.lock unlock];
        });
    }

    for (int i = 0; i < 1000; i++) {
        dispatch_async(queue, ^{
            self.name = [NSString stringWithFormat:@"abc"]; //taggedpointer
        });
    }
}
@end
```

### NSString类蔟及其引用计数（NSNumber、NSArray同理）
#### 创建方式不同，生成的子类不同
```
- (void)test1 {
NSString *str1 = @"123456789"; //__NSCFConstantString 引用计数：很大
NSString *str2 = [NSString stringWithString:@"123456789"];//__NSCFConstantString 引用计数：很大
NSString *str3 = [NSString stringWithFormat:@"123456789"]; // NSTaggedPointerString 引用计数：很大
NSString *str4 = [[NSString alloc] initWithString:@"123456789"]; // __NSCFConstantString 引用计数：很大
NSString *str5 = [[NSString alloc] initWithFormat:@"123456789"]; // NSTaggedPointerString  引用计数：很大
NSString *str6 = [[NSString alloc] initWithFormat:@"马"];//__NSCFString 引用计数：1
NSString *str7 = [[NSString alloc] initWithFormat:@"1234567"];// NSTaggedPointerString  引用计数：很大
NSString *str8 = [[NSString alloc] initWithFormat:@"abcdefgh"];//NSTaggedPointerString  引用计数：很大
NSString *str9 = [[NSString alloc] initWithFormat:@"acdefghijk"];//NSTaggedPointerString  引用计数：很大
NSString *str10 = [[NSString alloc] initWithFormat:@"aaaaaaaaaaaa"];//__NSCFString 引用计数：1
}

- (void)test2 {
    NSString __strong *str =  [NSString stringWithFormat:@"%@",@"string1"]; // NSTaggedPointerString,引用计数很大
    NSString __weak *weakStr = str; 
    str = nil; // 虽然是__weak修饰，但不是在堆上的对象，weakStr并不会置为null
    NSLog(@"%@", weakStr); // NSTaggedPointerString,引用计数很大
}

- (void)test3 {
    //字符串是对象类型，str和str1是同一个对象，引用计数为2
    NSString *str = [[NSString alloc] initWithFormat:@"牛"];//1
    NSString *str1 = [str copy];//2
    //可变到不可变，创建了新对象，引用计数为1
    NSString *str2 = [[NSMutableString alloc] initWithString:@"牛"];//1,这里实际生成的是NSMutableString
    NSString *str3 = [str2 copy];//[NSMutableString copy]，生成新对象NSString，引用计数1
}

```













