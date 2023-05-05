# MRC下的内存管理

### release和autorelease修饰对象
```
#import "ViewController.h"
@interface ViewController ()
@property (retain, nonatomic) NSMutableArray *data;
@property (retain, nonatomic) UITabBarController *tabBarController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //自动释放池管理
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];

    self.data = [NSMutableArray array];
// 等价于self.data = [[[NSMutableArray alloc] init] autorelease];
//也等价于  self.data = [[NSMutableArray alloc] init];
//[self.data release];

//重新引用了，临时数组可以直接release
//    NSMutableArray *data = [[NSMutableArray alloc] init];
//    self.data = data;
//    [data release];
}

- (void)dealloc {
    self.data = nil;
    self.tabBarController = nil;
    [super dealloc];
}
@end
```

### MRC下的copy和mutablecopy
```
#import <Foundation/Foundation.h>
// 拷贝的目的：产生一个副本对象，跟源对象互不影响
// 修改了源对象，不会影响副本对象
// 修改了副本对象，不会影响源对象
/*
 iOS提供了2个拷贝方法
 1.copy，不可变拷贝，产生不可变副本
 2.mutableCopy，可变拷贝，产生可变副本

 深拷贝和浅拷贝
 1.深拷贝：内容拷贝，产生新的对象
 2.浅拷贝：指针拷贝，没有产生新的对象
 */

void test(){
    //        NSString *str1 = [NSString stringWithFormat:@"test"];引用计数1
    //        NSString *str2 = [str1 copy]; // 返回的是NSString，引用计数2
    //        NSMutableString *str3 = [str1 mutableCopy]; // 返回的是NSMutableString，引用计数1
    NSMutableString *str1 = [NSMutableString stringWithFormat:@"test"];引用计数1
    NSString *str2 = [str1 copy];//深拷贝，引用计数1
    NSMutableString *str3 = [str1 mutableCopy];//深拷贝，引用计数1
    NSLog(@"%@ %@ %@", str1, str2, str3);
    NSLog(@"%p %p %p", str1, str2, str3);
}

void test2(){
    NSString *str1 = [[NSString alloc] initWithFormat:@"test9889989898989889"];
    //对于不可变字符串，copy此时相当于retain，引用计数会+1
    NSString *str2 = [str1 copy]; // 浅拷贝，指针拷贝，没有产生新对象
    NSMutableString *str3 = [str1 mutableCopy]; // 深拷贝，内容拷贝，有产生新对象
    NSLog(@"%lu",(unsigned long)str1.retainCount);// 2
    NSLog(@"%lu",(unsigned long)str2.retainCount);// 2
    NSLog(@"%lu",(unsigned long)str3.retainCount);// 1
    NSLog(@"%@ %@ %@", str1, str2, str3);
    NSLog(@"%p %p %p", str1, str2, str3);
    [str3 release];
    [str2 release];
    [str1 release];
}

void test3() {
    NSMutableString *str1 = [[NSMutableString alloc] initWithFormat:@"test9889989898989889"];
    NSString *str2 = [str1 copy]; // 深拷贝
    NSMutableString *str3 = [str1 mutableCopy]; // 深拷贝
    NSLog(@"%lu %lu %lu",(unsigned long)str1.retainCount,(unsigned long)str2.retainCount,(unsigned long)str3.retainCount);//1 1 1
//        [str1 appendString:@"111"];
//        [str3 appendString:@"333"];
//        NSLog(@"%@ %@ %@", str1, str2, str3);
    [str1 release];
    [str2 release];
    [str3 release];
}

void test8(){
    NSMutableString *str1 = [[NSMutableString alloc] initWithFormat:@"test"]; // 1
    NSString *str2 = [str1 copy]; // 深拷贝
    NSMutableString *str3 = [str1 mutableCopy]; // 深拷贝
    [str1 release];
    [str2 release];
    [str3 release];
}

void test4(){
    NSArray *array1 = [[NSArray alloc] initWithObjects:@"a", @"b", nil];
    NSArray *array2 = [array1 copy]; // 浅拷贝
    NSMutableArray *array3 = [array1 mutableCopy]; // 深拷贝
    NSLog(@"%p %p %p", array1, array2, array3);
    [array1 release];
    [array2 release];
    [array3 release];
}

void test5(){
    NSMutableArray *array1 = [[NSMutableArray alloc] initWithObjects:@"a", @"b", nil];
    NSArray *array2 = [array1 copy]; // 深拷贝
    NSMutableArray *array3 = [array1 mutableCopy]; // 深拷贝
    NSLog(@"%p %p %p", array1, array2, array3);
    [array1 release];
    [array2 release];
    [array3 release];
}

void test6(){
    NSDictionary *dict1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"jack", @"name", nil];
    NSDictionary *dict2 = [dict1 copy]; // 浅拷贝
    NSMutableDictionary *dict3 = [dict1 mutableCopy]; // 深拷贝
    NSLog(@"%p %p %p", dict1, dict2, dict3);
    [dict1 release];
    [dict2 release];
    [dict3 release];
}

void test7(){
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"jack", @"name", nil];
    NSDictionary *dict2 = [dict1 copy]; // 深拷贝
    NSMutableDictionary *dict3 = [dict1 mutableCopy]; // 深拷贝
    NSLog(@"%p %p %p", dict1, dict2, dict3);
    [dict1 release];
    [dict2 release];
    [dict3 release];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        test();
//        test2();
//        test3();
//        test4();
//        test5();
//        test6();
//        test7();
    }
    return 0;
}
```

### MRC下的内存管理
#### 被持有对象MJDog
```
#import <Foundation/Foundation.h>
@interface MJDog : NSObject
- (void)run;
@end

#import "MJDog.h"
@implementation MJDog
- (void)run{
    NSLog(@"%s", __func__);
}
- (void)dealloc{
    [super dealloc];
    NSLog(@"%s", __func__);
}
@end
```
#### 持有者MJPerson

```
#import <Foundation/Foundation.h>
#import "MJDog.h"
@interface MJPerson : NSObject{
    MJDog *_dog;
    int _age;
}
- (void)setAge:(int)age;
- (int)age;
- (void)setDog:(MJDog *)dog;
- (MJDog *)dog;
@end

#import "MJPerson.h"
@implementation MJPerson
- (void)setAge:(int)age{
    _age = age;
}

- (int)age{
    return _age;
}

- (void)setDog:(MJDog *)dog {
    if (_dog != dog) { //不判断可能两只狗是一样的，狗直接被释放了
        [_dog release]; //将上一只狗先释放
        _dog = [dog retain];//再拥有当前这只狗
    }
    //这种写法也可以
//    [dog retain];
//    [_dog release];
//    _dog = dog;
}

- (MJDog *)dog{
    return _dog;
}

- (void)dealloc{
//    [_dog release];
//    _dog = nil;
    self.dog = nil; //等价//[_dog release]、dog = nil;。走的是setter方法
    NSLog(@"%s", __func__);
    // 父类的dealloc放到最后
    [super dealloc];
}

@end
```

#### 持有和释放的关系变化

```
#import <Foundation/Foundation.h>
#import "MJPerson.h"
#import "MJDog.h"

void test(){
    MJPerson *person1 = [[[MJPerson alloc] init] autorelease];
    MJPerson *person2 = [[[MJPerson alloc] init] autorelease];
}

void test2() { //多个人持有同一只狗
    MJDog *dog = [[MJDog alloc] init]; // 1
    MJPerson *person1 = [[MJPerson alloc] init];
    [person1 setDog:dog]; // 2
    MJPerson *person2 = [[MJPerson alloc] init];
    [person2 setDog:dog]; // 3
    [dog release]; // 2
    [person1 release]; // 1
    [[person2 dog] run];
    [person2 release]; // 0
}

void test3() { //一个人持有多只狗
    MJDog *dog1 = [[MJDog alloc] init]; // dog1 : 1
    MJDog *dog2 = [[MJDog alloc] init]; // dog2 : 1
    MJPerson *person = [[MJPerson alloc] init];
    [person setDog:dog1]; // dog1 : 2
    [person setDog:dog2]; // dog2 : 2, dog1 : 1
    [dog1 release]; // dog1 : 0
    [dog2 release]; // dog2 : 1
    [person release]; // dog2 : 0
}

void test4(){ //一个人多次持有同一只狗
    MJDog *dog = [[MJDog alloc] init]; // dog:1
    MJPerson *person = [[MJPerson alloc] init];
    [person setDog:dog]; // dog:2
    [dog release]; // dog:1

    [person setDog:dog]; //多次持有同一只狗
    [person setDog:dog];
    [person setDog:dog];
    [person setDog:dog];
    [person setDog:dog];
    [person release]; // dog:0
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        test();
//        test2();
//        test3();
        test4();
    }
    return 0;
}
```