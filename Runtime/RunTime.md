
[动态方法解析过程](https://github.com/shenchunxing/ios_interview_questions/blob/master/RunTime.md#动态方法解析过程) 

[消息转发](https://github.com/shenchunxing/ios_interview_questions/blob/master/RunTime.md#消息转发) 

[@dynamic和synthesize](https://github.com/shenchunxing/ios_interview_questions/blob/master/RunTime.md#@dynamic和synthesize) 

[super关键字](https://github.com/shenchunxing/ios_interview_questions/blob/master/RunTime.md#super关键字) 

[消息转发的伪代码](https://github.com/shenchunxing/ios_interview_questions/blob/master/RunTime.md#消息转发的伪代码) 

[isKindOfClass和isMemberOfClass](https://github.com/shenchunxing/ios_interview_questions/blob/master/RunTime.md#消isKindOfClass和isMemberOfClass) 



### 动态方法解析过程

 ```Objective-C
#import "MJPerson.h"
#import <objc/runtime.h>

@implementation MJPerson

void c_other(id self, SEL _cmd)
{
    NSLog(@"c_other - %@ - %@", self, NSStringFromSelector(_cmd));
}

+ (BOOL)resolveClassMethod:(SEL)sel
{
    if (sel == @selector(test)) {
        // 第一个参数是object_getClass(self)
        class_addMethod(object_getClass(self), sel, (IMP)c_other, "v16@0:8");
        return YES;
    }
    return [super resolveClassMethod:sel];
}

@end
 ```


### 消息转发

快速转发
 ```Objective-C
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (aSelector == @selector(test)) {
      //消息转发的第一个阶段：伪代码objc_msgSend([[MJCat alloc] init], aSelector)
        // objc_msgSend([[MJCat alloc] init], aSelector)
        return [[MJCat alloc] init]; 这里如果返回的是类对象，就调用类方法
    }
    return [super forwardingTargetForSelector:aSelector];
}
 ```
 
慢转发，没有实现快速转发的前提下
方法签名：返回值类型、参数类型
 ```Objective-C
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if (aSelector == @selector(test)) {
        return [NSMethodSignature signatureWithObjCTypes:"v16@0:8"];
    }
    return [super methodSignatureForSelector:aSelector];
} 
 ```
NSInvocation封装了一个方法调用，包括：方法调用者、方法名、方法参数
anInvocation.target 方法调用者
anInvocation.selector 方法名
[anInvocation getArgument:NULL atIndex:0] 方法参数

 ```Objective-C
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
//    anInvocation.target = [[MJCat alloc] init];
//    [anInvocation invoke];

    [anInvocation invokeWithTarget:[[MJCat alloc] init]];
    
    //如果函数有返回值，可以这样获取结果
    int ret;
    [anInvocation getReturnValue:&ret];
}
 ``

消息转发防止程序崩溃
 ```Objective-C
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // 本来能调用的方法，不做处理
    if ([self respondsToSelector:aSelector]) {
        return [super methodSignatureForSelector:aSelector];
    }
    
    // 找不到的方法
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

// 找不到的方法，都会来到这里
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    NSLog(@"找不到%@方法", NSStringFromSelector(anInvocation.selector));
}

还有个NSProxy是一个专门用于消息转发的类，后续补充

 ```


### @dynamic和synthesize
 ```Objective-C
#import "MJPerson.h"
#import <objc/runtime.h>

@implementation MJPerson

// 提醒编译器不要自动生成setter和getter的实现、不要自动生成成员变量
@dynamic age;

void setAge(id self, SEL _cmd, int age)
{
    NSLog(@"age is %d", age);
}

//优先找对象方法,找不到找C方法
//- (void)setAge:(int)age {
//    NSLog(@"age is %d-------", age);
//}

int age(id self, SEL _cmd)
{
    return 120;
}

//- (int)age {
//    return 100;
//}

//动态方法解析:没有实现OC的setter和getter,则去实现C的setter和getter.如果没实现oc的,默认并不会直接就去执行C语言的方法,还是需要动态方法解析的
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(setAge:)) {
        class_addMethod(self, sel, (IMP)setAge, "v@:i");
        return YES;
    } else if (sel == @selector(age)) {
        class_addMethod(self, sel, (IMP)age, "i@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

//@synthesize 帮我们生成实例变量和getter、setter的实现，现在编译器已经做了这个，不需要写了
//@synthesize age = _age, height = _height;

//- (void)setAge:(int)age
//{
//    _age = age;
//}
//
//- (int)age
//{
//    return _age;
//}

@end
 ```


### super关键字
 ```Objective-C
#import "MJStudent.h"
#import <objc/runtime.h>

@implementation MJStudent

/*
 [super message]的底层实现
 1.消息接收者仍然是子类对象
 2.直接去父类开始查找方法的实现
 */

struct objc_super {
    __unsafe_unretained _Nonnull id receiver; // 消息接收者
    __unsafe_unretained _Nonnull Class super_class; // 消息接收者的父类
};

- (void)run
{
    // super调用的receiver仍然是MJStudent对象
    [super run];如果MJPerson没有实现run，这里会递归崩溃
    
    //objc_super的第二个成员是super_class（消息接收者的父类），目的是从父类开始查找run方法，而不是从本类开始，如果从本类开始就是死循环了
//    struct objc_super arg = {self, [MJPerson class]};
//
//    objc_msgSendSuper(arg, @selector(run));
//
//
//    NSLog(@"MJStudet.......");
    
}

- (instancetype)init
{
    if (self = [super init]) {
        NSLog(@"[self class] = %@", [self class]); // MJStudent
        NSLog(@"[self superclass] = %@", [self superclass]); // MJPerson

        NSLog(@"--------------------------------");

        // objc_msgSendSuper({self, [MJPerson class]}, @selector(class));
        NSLog(@"[super class] = %@", [super class]); // MJStudent
        NSLog(@"[super superclass] = %@", [super superclass]); // MJPerson
    }
    return self;
}

@end

//class的底层实现
//@implementation NSObject
//
//- (Class)class
//{
//    return object_getClass(self);
//}
//
//superclass的底层实现
//- (Class)superclass
//{
//    return class_getSuperclass(object_getClass(self));
//}
//
//@end
 ```


### 消息转发的伪代码
// 伪代码
```Objective-C
int __forwarding__(void *frameStackPointer, int isStret) {
    id receiver = *(id *)frameStackPointer;
    SEL sel = *(SEL *)(frameStackPointer + 8);
    const char *selName = sel_getName(sel);
    Class receiverClass = object_getClass(receiver);

    // 调用 forwardingTargetForSelector:
    if (class_respondsToSelector(receiverClass, @selector(forwardingTargetForSelector:))) {
        id forwardingTarget = [receiver forwardingTargetForSelector:sel];
        if (forwardingTarget && forwardingTarget != receiver) {
            if (isStret == 1) {
                int ret;
                objc_msgSend_stret(&ret,forwardingTarget, sel, ...);
                return ret;
            }
            return objc_msgSend(forwardingTarget, sel, ...);
        }
    }

    // 僵尸对象
    const char *className = class_getName(receiverClass);
    const char *zombiePrefix = "_NSZombie_";
    size_t prefixLen = strlen(zombiePrefix); // 0xa
    if (strncmp(className, zombiePrefix, prefixLen) == 0) {
        CFLog(kCFLogLevelError,
              @"*** -[%s %s]: message sent to deallocated instance %p",
              className + prefixLen,
              selName,
              receiver);
        <breakpoint-interrupt>
    }

    // 调用 methodSignatureForSelector 获取方法签名后再调用 forwardInvocation
    if (class_respondsToSelector(receiverClass, @selector(methodSignatureForSelector:))) {
        NSMethodSignature *methodSignature = [receiver methodSignatureForSelector:sel];
        if (methodSignature) {
            BOOL signatureIsStret = [methodSignature _frameDescriptor]->returnArgInfo.flags.isStruct;
            if (signatureIsStret != isStret) {
                CFLog(kCFLogLevelWarning ,
                      @"*** NSForwarding: warning: method signature and compiler disagree on struct-return-edness of '%s'.  Signature thinks it does%s return a struct, and compiler thinks it does%s.",
                      selName,
                      signatureIsStret ? "" : not,
                      isStret ? "" : not);
            }
            if (class_respondsToSelector(receiverClass, @selector(forwardInvocation:))) {
                NSInvocation *invocation = [NSInvocation _invocationWithMethodSignature:methodSignature frame:frameStackPointer];

                [receiver forwardInvocation:invocation];

                void *returnValue = NULL;
                [invocation getReturnValue:&value];
                return returnValue;
            } else {
                CFLog(kCFLogLevelWarning ,
                      @"*** NSForwarding: warning: object %p of class '%s' does not implement forwardInvocation: -- dropping message",
                      receiver,
                      className);
                return 0;
            }
        }
    }

    SEL *registeredSel = sel_getUid(selName);

    // selector 是否已经在 Runtime 注册过
    if (sel != registeredSel) {
        CFLog(kCFLogLevelWarning ,
              @"*** NSForwarding: warning: selector (%p) for message '%s' does not match selector known to Objective C runtime (%p)-- abort",
              sel,
              selName,
              registeredSel);
    } // doesNotRecognizeSelector
    else if (class_respondsToSelector(receiverClass,@selector(doesNotRecognizeSelector:))) {
        [receiver doesNotRecognizeSelector:sel];
    }
    else {
        CFLog(kCFLogLevelWarning ,
              @"*** NSForwarding: warning: object %p of class '%s' does not implement doesNotRecognizeSelector: -- abort",
              receiver,
              className);
    }

    // The point of no return.
    kill(getpid(), 9);
}
 ```


### isKindOfClass和isMemberOfClass
见Demo
