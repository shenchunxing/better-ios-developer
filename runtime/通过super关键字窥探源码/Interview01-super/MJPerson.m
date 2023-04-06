//
//  MJPerson.m
//  Interview01-super
//
//  Created by MJ Lee on 2018/5/29.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"
#import <objc/runtime.h>

@implementation MJPerson

// LLVM
// OC -> 中间代码（.ll） -> 汇编、机器代码

void test(int param)
{
    
}

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
//{
//    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
//}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    //调试技巧：xcode -> Product -> Perform Action -> Assemble "MJPerson.m"，可以直接转成汇编，窥探内部实现看到bl    _objc_msgSendSuper2，说明super内部调用的是_objc_msgSendSuper2方法
    [super forwardInvocation:anInvocation];
    // 查看汇编，汇编的是真实的
    // objc_msgSendSuper2(struct, @selector(forwardInvocation:), anInvocation)
    
    // 转为cpp文件和汇编有差异，但是基本原理是一样的
//    objc_msgSendSuper({self, class_getSuperclass(objc_getClass("MJPerson"))},
//                      @selector(forwardInvocation:),
//                      anInvocation);
    
    int a = 10;
    int b = 20;
    int c = a + b;
    test(c);
}

@end
