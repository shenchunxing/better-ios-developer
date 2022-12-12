
[动态方法解析过程](https://github.com/shenchunxing/ios_interview_questions/blob/master/RunTime.md#动态方法解析过程) 

[消息转发](https://github.com/shenchunxing/ios_interview_questions/blob/master/RunTime.md#消息转发) 



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
        return [[MJCat alloc] init];
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
}
 ```
