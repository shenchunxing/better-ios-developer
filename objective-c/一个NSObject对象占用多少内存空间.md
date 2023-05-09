一个NSObject对象占用多少内存空间？

结论：受限于内存分配的机制，一个 NSObject对象都会分配 16Bit 的内存空间。但是实际上在64位下，只使用了 8bit，在32位下，只使用了 4bit。 首先NSObject对象的本质是一个NSObject_IMPL结构体。我们通过以下命令将 Objecttive-C 转化为 C\C++

// 如果需要连接其他框架，可以使用 -framework 参数，例如 -framework UIKit xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc main.m -o main.cpp 通过将main.m转化为main.cpp 文件可以看出它的结构包含一个isa指针：
```Objective-C
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <malloc/malloc.h>

struct NSObject_IMPL {
    Class isa;//8
};

struct Person_IMPL {
    struct NSObject_IMPL NSObject_IVARS; // 8
    int _age; // 4
}; // 16 内存对齐：结构体的大小必须是最大成员大小的倍数

struct Student_IMPL {
    struct Person_IMPL Person_IVARS; // 16
    int _no; // 4
}; // 16

// Person
@interface Person : NSObject
{
    @public
    int _age; //4
}
@property (nonatomic, assign) int height;
@end

@implementation Person

@end

@interface Student : Person
{
    int _no; //4
}
@end

@implementation Student

@end

@interface GoodStudent : Student
{
    int _library; //4
    NSString *_value;//8
    NSString *_name; //8
}
@end

@implementation GoodStudent

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Student *stu = [[Student alloc] init];
        NSLog(@"stu - %zd", class_getInstanceSize([Student class])); //24：class_getInstanceSize 内存对齐：最大成员的倍数
        NSLog(@"stu - %zd", malloc_size((__bridge const void *)stu));//32：malloc_size 内存对齐：16的倍数
        
        GoodStudent *good = [[GoodStudent alloc] init];
        NSLog(@"good - %zd", class_getInstanceSize([GoodStudent class]));//40
        NSLog(@"good - %zd", malloc_size((__bridge const void *)good));//48
//
        Person *person = [[Person alloc] init];
        [person setHeight:10];
        [person height];
        person->_age = 20;
        
        Person *person1 = [[Person alloc] init];
        person1->_age = 10;
        
        
        Person *person2 = [[Person alloc] init];
        person2->_age = 30;
        
        NSLog(@"person - %zd", class_getInstanceSize([Person class])); //16 isa = 8 ， age = 4, height = 4,没有height也会是16，因为必须是8的倍数
        NSLog(@"person - %zd", malloc_size((__bridge const void *)person));//16
    }
    return 0;
}