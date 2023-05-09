# KVC相关面试题
### setValue:forKey:的实现
 查找setKey:方法和_setKey:方法，只要找到就直接传递参数，调用方法；

 如果没有找到setKey:和_setKey:方法，查看accessInstanceVariablesDirectly方法的返回值，如果返回NO（不允许直接访问成员变量），调用setValue:forUndefineKey:并抛出异常NSUnknownKeyException；

 如果accessInstanceVariablesDirectly方法返回YES（可以访问其成员变量），就按照顺序依次查找 _key、_isKey、key、isKey 这四个成员变量，如果查找到了就直接赋值；如果没有查到，调用setValue:forUndefineKey:并抛出异常NSUnknownKeyException。
```
//- (void)setAge:(int)age
//{
//    NSLog(@"setAge: - %d", age);
//}

//- (void)_setAge:(int)age
//{
//    NSLog(@"_setAge: - %d", age);
//}
```
 
 ### valueForKey:的实现
 按照getKey，key，isKey的顺序查找方法，只要找到就直接调用；
 
 如果没有找到，accessInstanceVariablesDirectly返回YES（可以访问其成员变量），按照顺序依次查找_key、_isKey、key、isKey 这四个成员变量，找到就取值；如果没有找到成员变量，调用valueforUndefineKey并抛出异常NSUnknownKeyException。

 accessInstanceVariablesDirectly返回NO（不允许直接访问成员变量），那么会调用valueforUndefineKey:方法，并抛出异常NSUnknownKeyException；
 
Demo：
```
#import <Foundation/Foundation.h>
@interface MJPerson : NSObject{
    @public
    int age;
    int isAge;
    int _isAge;
    int _age;
}
@end

#import "MJPerson.h"
@implementation MJPerson
//getter方法按照：- (int)getAge 
- (int)age
- (int)isAge 
- (int)_age的顺序查找实现

//- (int)getAge
//{
//    return 11;
//}

//- (int)age
//{
//    return 12;
//}

//- (int)isAge
//{
//    return 13;
//}

- (int)_age {
    return 14;
}

 //是否接受成员变量作为直接返回对象，默认的返回值就是YES
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}
@end
```


```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        //下面4种是直接通过成员变量访问的
        person->_age = 10;
        person->_isAge = 11;
        person->age = 12;
        person->isAge = 13;
        //属性访问：getter方法按照- (int)getAge  - (int)age  - (int)isAge  - (int)_age的顺序查找实现
        NSLog(@"%@", [person valueForKey:@"age"]); //打印结果14
    }
    return 0;
}
```