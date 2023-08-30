//
//  main.m
//  Interview04-block修饰符
//
//  Created by 沈春兴 on 2022/6/28.
//

#import <Foundation/Foundation.h>
#import "CXPerson.h"

void (^block)(void);
typedef void(^CXBlock) (void);

@interface TestObject : NSObject

@end

@implementation TestObject

- (void)dealloc {
    NSLog(@"对象已经被释放");
}

@end

void test__strong() {
   {
        TestObject *obj = [[TestObject alloc] init];
        NSLog(@"strong - before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
        block = ^(){ //全局的block变量，被栈上的代码块赋值，会执行copy操作，从栈指向了堆
            NSLog(@"obj对象地址:%@",obj);
        };
        NSLog(@"strong - after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //3   由于代码块创建的时候在栈上，内部对obj有强引用,而在赋值给全局变量block的时候,被拷贝到了堆上（对obj又引用了一次）,所以加了2次引用计数.
        //当前block
        NSLog(@"strong  - %@",[block class]);//从栈拷贝到了堆
        //obj无法被释放，因为block堆obj还是有强引用
   }
    block();
}

void test__weak() {
    {
        TestObject *obj = [[TestObject alloc] init];
        NSLog(@"weak - before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
        __weak NSObject *weak_obj = obj;
        block = ^(){ //block对weak_obj是有强引用， 但是weak_obj是一个弱指针不会增加引用计数。block被拷贝到了堆上
            NSLog(@"obj对象地址:%@",weak_obj);
        };
        NSLog(@"weak - after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1 ,weak不新增引用计数
        NSLog(@"weak - %@",[block class]);
    }
    block();
}

void test__weak_free() {
    TestObject *obj = [[TestObject alloc] init];
    __weak TestObject *weakObj = obj;
    NSLog(@"weak - strong - before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
    block = ^(){
        NSLog(@"obj对象地址:%@",weakObj); //这里obj还存活
        //weakObj因为是弱引用，存在的时间很短（可能就几行普通代码的时间长度）。经过了一个耗时操作，weakObj早已经被释放了
        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
            for (int i = 0; i < 10000; i++) {
                // 模拟一个耗时的任务
            }
            NSLog(@"耗时的任务 结束 obj对象地址:%@",weakObj); //这里obj已经被释放了
        });
    };
    NSLog(@"weak - strong - after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj));//1
    block();
}

void test_weak_strong() {
    TestObject *obj = [[TestObject alloc] init];
    __weak TestObject *weakObj = obj;
    NSLog(@"before block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj)); //1
    block = ^(){
        __strong TestObject *strongObj = weakObj; //确保weakObj不被释放掉
        NSLog(@"obj对象地址:%@",strongObj);
        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
            for (int i = 0; i < 10000; i++) {
                // 模拟一个耗时的任务
            }
            NSLog(@"耗时的任务 结束 obj对象地址:%@",strongObj); //这里的strongObj还是存在的。只有离开作用于，strongObj才会被释放
        });
    };
    NSLog(@"after block retainCount:%zd",CFGetRetainCount((__bridge CFTypeRef)obj));//1
    block();
}

void test1() {
    CXBlock block;
    {
        CXPerson *p = [[CXPerson alloc] init];
        p.name = @"shenchuxning";
        block = ^{
            NSLog(@"name = %@" , p.name); //CXPerson被block强引用着
        };
    }
    
    NSLog(@"---------------------"); //作用域结束CXBlock不会存在，强引用的CXPerson也被释放了
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        test__strong();
        NSLog(@"---------------------");
        test__weak();
        NSLog(@"---------------------");
        test__weak_free();
        NSLog(@"---------------------");
        test_weak_strong();
        NSLog(@"---------------------");
        test1();
    }
    return 0;
}


