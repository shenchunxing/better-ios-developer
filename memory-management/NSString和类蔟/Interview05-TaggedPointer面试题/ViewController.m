//
//  ViewController.m
//  Interview05-TaggedPointer面试题
//
//  Created by MJ Lee on 2018/6/21.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

#define MDMLog(str) ({NSString *name = @#str; NSLog(@"%@-->%@ %p, %zd", name, [str class], str, CFGetRetainCount((__bridge CFTypeRef)str));})

@interface ViewController ()
@property (nonatomic, strong) NSString *strongString;
@property (nonatomic, weak) NSString *weakString;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self test1];
//    NSLog(@"---------------");
//    [self test2];
//    NSLog(@"---------------");
    [self test3];
}

- (void)test1 {
    //字面量
    NSString *str1 = @"123456789"; //__NSCFConstantString 引用计数：很大
    MDMLog(str1);
    //+ stringWithString:
    NSString *str2 = [NSString stringWithString:@"123456789"];//__NSCFConstantString 引用计数：很大
    MDMLog(str2);
    //+ stringWithFormat:
    NSString *str3 = [NSString stringWithFormat:@"123456789"]; // NSTaggedPointerString 引用计数：很大
    MDMLog(str3);
    //- initWithString:
    NSString *str4 = [[NSString alloc] initWithString:@"123456789"]; // __NSCFConstantString 引用计数：很大
    MDMLog(str4);
    //- initWithFormat:
    NSString *str5 = [[NSString alloc] initWithFormat:@"123456789"]; // NSTaggedPointerString  引用计数：很大
    MDMLog(str5);
    
    
    //__NSCFString 引用计数：1
    NSString *str6 = [[NSString alloc] initWithFormat:@"马"];
    MDMLog(str6); //1
    
// NSTaggedPointerString  引用计数：很大
    NSString *str7 = [[NSString alloc] initWithFormat:@"1234567"];
    MDMLog(str7);
    
    //NSTaggedPointerString  引用计数：很大
    NSString *str8 = [[NSString alloc] initWithFormat:@"abcdefgh"];
    MDMLog(str8);
    
    //NSTaggedPointerString  引用计数：很大
    NSString *str9 = [[NSString alloc] initWithFormat:@"acdefghijk"];
    MDMLog(str9);

    
    //__NSCFString 引用计数：1
    NSString *str10 = [[NSString alloc] initWithFormat:@"aaaaaaaaaaaa"];
    MDMLog(str10); //1
    
    //NSString类簇
    NSLog(@"__NSCFConstantString.superClass = %@",[NSClassFromString(@"__NSCFConstantString") superclass]);//__NSCFConstantString.superClass = __NSCFString
    NSLog(@"NSTaggedPointerString.superClass = %@",[NSClassFromString(@"NSTaggedPointerString") superclass]);//NSTaggedPointerString.superClass = NSString
    NSLog(@"__NSCFString.superClass = %@",[NSClassFromString(@"__NSCFString") superclass]);//__NSCFString.superClass = NSMutableString
    NSLog(@"NSString.superClass = %@" , [NSClassFromString(@"NSString") superclass]);//NSString.superClass = NSObject
    NSLog(@"NSString 的所有子类 = %@" , [self findSubClass:[NSString class]]);
   
    
    NSLog(@"-----------------");
    
    //NSArray
    NSLog(@"NSArray.superClass = %@",[NSArray superclass]); //NSObject
    NSLog(@"NSMutableArray.superClass = %@",[NSMutableArray superclass]);//NSArray
    NSLog(@"NSArray 的所有子类 = %@" , [self findSubClass:[NSArray class]]);
        
    NSLog(@"---------------------------------------------------------------");
    
    //NSNumber
    NSLog(@"NSNumber.superClass = %@",[NSNumber superclass]); //NSValue
    NSLog(@"NSNumber 的所有子类 = %@" , [self findSubClass:[NSNumber class]]);
}

- (void)test2 {
    NSString __strong *str =  [NSString stringWithFormat:@"%@",@"string1"];
    MDMLog( str);
    NSString __weak *weakStr = str;
    str = nil;
    MDMLog(weakStr);
    NSLog(@"%@", weakStr);
}

- (void)test3 {
    //字符串是对象类型，str和str1是同一个对象，引用计数为2
    NSString *str = [[NSString alloc] initWithFormat:@"牛"];//1
    MDMLog(str);
    NSString *str1 = [str copy];//2
    MDMLog(str);
    MDMLog(str1);
    
    
    //可变到不可变，创建了新对象，引用计数为1
    NSString *str2 = [[NSMutableString alloc] initWithString:@"牛"];//1
    MDMLog(str2);
    NSString *str3 = [str2 copy];//1
    MDMLog(str2);
    MDMLog(str3);
}

//获取指定类的子类
- (NSArray *)findSubClass:(Class)defaultClass {
    //注册类的总数
    int count = objc_getClassList(NULL,0);
    //创建一个数组，其中包含给定对象
    NSMutableArray * array = [NSMutableArray arrayWithObject:defaultClass];
    //获取所有已注册的类
    Class *classes = (Class *)malloc(sizeof(Class) * count);
    
    objc_getClassList(classes, count);
    
    //遍历
    for (int i = 0; i < count; i++) {
        
        if (defaultClass == class_getSuperclass(classes[i])) {
            
            [array addObject:classes[i]];
            
        }
        
    }
    
    free(classes);
    return array;
    
}

@end
