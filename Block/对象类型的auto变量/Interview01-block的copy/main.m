//
//  main.m
//  Interview01-block的copy
//
//  Created by MJ Lee on 2018/5/12.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJPerson.h"

/**
 block 和函数指针的区别


 相似点
 1.函数指针和Block都可以实现回调的操作，声明上也很相似，实现上都可以看成是一个代码片段。
 2.函数指针类型和Block类型都可以作为变量和函数参数的类型。（typedef定义别名之后，这个别名就是一个类型）


 不同点
1.函数指针只能指向预先定义好的函数代码块（可以是其他文件里面定义，通过函数参数动态传入的），函数地址是在编译链接时就已经确定好的。
2.Block本质是Objective-C对象，是NSObject的子类，可以接收消息。
3.函数里面只能访问全局变量，而Block代码块不光能访问全局变量，还拥有当前栈内存和堆内存变量的可读性（当然通过__block访问指示符修饰的局部变量还可以在block代码块里面进行修改）。
4.从内存的角度看，函数指针只不过是指向代码区的一段可执行代码，而block实际上是程序运行过程中在栈内存动态创建的对象，可以向其发送copy消息将block对象拷贝到堆内存，以延长其生命周期。 关于第2点可以作一个实验，在定义block之后打一个断点，Cmd+R运行后，可以在调试窗口看到，block确实是一个对象，拥有isa指针。 另外，采用block写法，gcc编译出来可执行文件体积更大，这应该还是跟block是对象有关。

 */
typedef void (^MJBlock)(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        MJBlock block;
//
//        {
//            MJPerson *person = [[MJPerson alloc] init];
//            person.age = 10;
//
//            __weak MJPerson *weakPerson = person;
//            block = ^{
//                NSLog(@"---------%d", weakPerson.age);
//            };
//        }
//
//        NSLog(@"------");
        
        MJBlock block;
        
        {
            MJPerson *person = [[MJPerson alloc] init];
            person.age = 10;
            
//            __weak MJPerson *weakPerson = person;
            int age = 10;
            block = ^{
                NSLog(@"---------%d", person.age);
            };
        }
        
        NSLog(@"------");
    }
    return 0;
}
