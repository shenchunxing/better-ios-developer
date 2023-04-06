//
//  main.m
//  Interview01-位运算
//
//  Created by MJ Lee on 2018/5/19.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MJPerson.h"
#import <objc/runtime.h>
#import "MJClassInfo.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"%s", @encode(SEL));
        
        MJPerson *person = [[MJPerson alloc] init];
//
        mj_objc_class *cls = (__bridge mj_objc_class *)[MJPerson class];
        class_rw_t *data = cls->data();
//        // v 16 @ 0 : 8
        [person test:10 height:20];
        
        
        //方法名相同，方法地址也是一样的
        SEL sel1 = sel_registerName("test");
        SEL sel2 = @selector(test);
        NSLog(@"%p %p %p", @selector(test), @selector(test), sel_registerName("test"));
        
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
