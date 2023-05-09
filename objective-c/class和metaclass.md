```Objective-C
@interface MJPerson : NSObject
{
    int _age;
    int _height;
    int _no;
}
@end

@implementation MJPerson
- (void)test {
    
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *object1 = [[NSObject alloc] init];
        NSObject *object2 = [[NSObject alloc] init];
        
        Class objectClass1 = [object1 class];
        Class objectClass2 = [object2 class];
        Class objectClass3 = object_getClass(object1);
        Class objectClass4 = object_getClass(object2);
        Class objectClass5 = [NSObject class];
        
        //元类
        Class objectMetaClass = object_getClass(objectClass5);
        
        NSLog(@"instance - %p %p\n",
              object1,
              object2);
        
        //相等，都是NSObject类对象
        NSLog(@"class - %p\n %p\n %p\n %p\n %p\n %d\n",
              objectClass1,
              objectClass2,
              objectClass3,
              objectClass4,
              objectClass5,
              class_isMetaClass(objectClass3)); //false
        
        //传入类对象，得到的肯定是元类
        NSLog(@"objectMetaClass - %hhd",class_isMetaClass(object_getClass([MJPerson class]))); //1
        NSLog(@"objectMetaClass - %hhd",class_isMetaClass(object_getClass([NSObject class]))); //1
        
        NSLog(@"%p",object_getClass(objectMetaClass)); //NSObject的元类的元类是其本身
        NSLog(@"%p",class_getSuperclass(objectMetaClass)); //NSObject的元类的父类是NSObject类对象
    }
    return 0;
}

//区别下
 1.Class objc_getClass(const char *aClassName)
 1> 传入字符串类名
 2> 返回对应的类对象
 
 2.Class object_getClass(id obj)
 1> 传入的obj可能是instance对象、class对象、meta-class对象
 2> 返回值
 a) 如果是instance对象，返回class对象
 b) 如果是class对象，返回meta-class对象
 c) 如果是meta-class对象，返回NSObject（基类）的meta-class对象
 
 3.- (Class)class、+ (Class)class
 1> 返回的就是类对象
 
 - (Class) {
     return self->isa;
 }
 
 + (Class) {
     return self;
 }

