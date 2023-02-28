//
//  main.m
//  Interview03-block
//
//  Created by MJ Lee on 2018/5/9.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

// MARK: - block 的内部实现?
/**
 block是个对象，block的底层结构题也有isa，这个isa会指向block的类型
 block的底层结构体是 __main_block_impl_0，存储了下列数据

 方法实现的指针impl
 block的相关信息Desc
 如果有捕获外部变量，结构体内还会存储捕获的变量。


 使用block时就会根据impl找到方法所在，传入存储的变量调用。
 */

//MARK:Block内部结构
/**
 struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
 };
 
 
 struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
 };
 
 */

//MARK:什么是Block？
/**
 1.Block是封装了函数调用和函数调用环境的OC对象
**/

//MARK:block的类型
/**
 局部变量auto可以被block内部捕获，属于值传递
 局部变量static可以被内部捕获，是指针传递
 全局变量不需要被内部捕获，可以直接访问

 Block类型：globalblock：没有访问自动变量   stackblock：访问了自动变量。 mallocblock：stackblock调用了copy，到堆上了。

 [globalblock copy] : 什么都不做
 [stackblock copy] : 将栈上的blcok，拷贝到堆上
 [mallocblock copy] : 引用计数+1
**/

//MARK:block的内存管理
 /**
 对象类型的auto变量：
         如果block在栈上，不会产生强引用
         如果block被拷贝到堆上，内部会调用_Block_objc_assign函数，对auto修饰符产 生强或者弱引用。如果block从堆上移除，则会调用_Block_objc_dispose函数，会自动释放release。

 __block可以解决无法修改auto变量值的问题。__block不能修饰全局、静态变量
 编译器会将__block包装成一个对象。包装后的对象架构：
 栈上的__forwording指针在被copy后，会指向堆上的结构体对象。堆上的__forwording指向本身。
**/
 
//MARK:Block需要的注意点：
/** 1). 在block内部使用外部指针且会造成循环引用情况下，需要用__week修饰外部指针：
     __weak typeof(self) weakSelf = self;
 2). 在block内部如果调用了延时函数还使用弱指针会取不到该指针，因为已经被销毁了，需要在block内部再将弱指针重新强引用一下。
     __strong typeof(self) strongSelf = weakSelf;
 3). 如果需要在block内部改变外部栈区变量的话，需要在用__block修饰外部变量。
 **/

 //MARK:为什么block不能修改外部变量的值？
 /**我们在写Block的时候，看起来外部变量和Block是在一个作用域内，其实编译器在编译的过程中会把Block分解多个方法，这时候外部变量和Block其实是不在同一个作用域内，所以无法做到修改这个变量。
 通过__block的修饰，这时候Block在编译的过程中就会获取外部变量的指针，通过指针来修改变量。
  **/

//MARK:Block中可以修改全局变量，全局静态变量，局部静态变量、自动变量吗？
/**
 全局变量和静态全局变量的值改变，以及它们被Block捕获进去，因为是全局的，作用域很广
 静态变量和自动变量，被Block从外面捕获进来，成为__main_block_impl_0这个结构体的成员变量
 自动变量是以值传递方式传递到Block的构造函数里面去的。Block只捕获Block中会用到的变量。由于只捕获了自动变量的值，并非内存地址，所以Block内部不能改变自动变量的值。
 Block捕获的外部变量可以改变值的是静态变量，静态全局变量，全局变量
 */

 //MARK:函数指针和block的区别？
 /**函数指针是对一个函数地址的引用，内部只能访问全局变量。这个函数在编译的时候就已经确定了。而block是一个函数对象，是在程序运行过程中产生的。
 函数指针是Block的一部分。为什么这样说，如果你用Block，就有一个变量的使用，循环引用等等部分。
 */

//MARK:block在修改NSMutableArray，需不需要添加__block？
/**
 本身 block 内部就捕获了 NSMutableArray 指针，除非你要修改指针指向的对象，而这里明显只是修改内存数据，这个可以类比 NSMutableString。
 */

//MARK:block可以用strong修饰吗？
/**
 在MRC环境中，是不可以的，strong修饰符会对修饰的变量进行retain操作，这样并不会将栈中的block拷贝到堆内存中，而执行的block是在堆内存中，所以用strong修饰的block会导致在执行的时候因为错误的内存地址，导致闪退。

 在ARC环境中，是可以的，strong 和 copy 的操作都是将栈上block 拷贝到堆上。
 */

//MARK:什么时候栈上的Block会复制到堆上呢？
/**
 1.调用Block的copy实例方法
 2.Block作为函数返回值返回时
 3.将Block赋值给附有__strong修饰符id类型的类或Block类型成员变量时
 4.在方法名中含有usingBlock的Cocoa框架方法或Grand Central Dispatch的API中传递Block时
 注意：多次对同一个Block进行copy操作，只是会增加引用计数
 */

//MARK:Block访问对象类型的auto变量时，在ARC和MRC下有什么区别?
/**
 在ARC下，栈区创建的block会自动copy到堆区；而MRC下，就不会自动拷贝了，需要我们手动调用copy函数。

 我们再说说block的copy操作，当block从栈区copy到堆区的过程中，也会对block内部访问的外部变量进行处理，它会调用Block_object_assign函数对变量进行处理，根据外部变量是strong还会weak对block内部捕获的变量进行引用计数+1或-1，从而达到强引用或弱引用的作用。

 因此
 在ARC下，由于block被自动copy到了堆区，从而对外部的对象进行强引用，如果这个对象同样强引用这个block，就会形成循环引用。
 在MRC下，由于访问的外部变量是auto修饰的，所以这个block属于栈区的，如果不对block手动进行copy操作，在运行完block的定义代码段后，block就会被释放，而由于没有进行copy操作，所以这个变量也不会经过Block_object_assign处理，也就不会对变量强引用。
 简单说就是：
 
 ARC下会对这个对象强引用，MRC下不会。
 */


//MARK:解决循环引用时为什么要用__strong、__weak修饰？
/**
 __weak 就是为了避免 retainCycle
 而block 内部 __strong 则是在作用域 retain 持有当前对象做一些操作，结束后会释放掉它。（也就是避免提早被释放，哪些情况会被提早释放？）
 */

// MARK: - block 捕获外部局部变量实际上发生了什么？__block又做了什么？
/**
 block捕获外部变量的时候，会记录下外部变量的瞬时值，存储在block_impl_0结构体里
 __block 所起到的作用就是只要观察到该变量被 block 所持有，就将“外部变量”在栈中的内存地址放到了堆中。进而在block内部也可以修改外部变量的值。
 总之，block内部可以修改堆中的内容， 不可以直接修改栈中的内容
 */

// MARK: - 在Masonry的block中，使用self，会造成循环引用吗？如果是在普通的block中呢？
/**
 不会，因为这是个栈block，没有延迟使用，使用后立刻释放
 普通的block会，一般会使用强引用持有，就会触发copy操作
 */

struct __main_block_desc_0 {
    size_t reserved; //保留，暂时不会用
    size_t Block_size;//大小
};

//实现体
struct __block_impl {
    void *isa;//isa指针
    int Flags;
    int Reserved;
    void *FuncPtr;//函数地址，block执行的时候会调用
};

struct __main_block_impl_0 {
    struct __block_impl impl;//block实现
    struct __main_block_desc_0* Desc;//描述
    int age;
};

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        //第一一个block
        ^{
            NSLog(@"this is a block!");
        }();
        
        int age = 20;
        
        void (^block)(int, int) =  ^(int a , int b){
            NSLog(@"this is a block! -- %d", age);
    
        };
        
        
        
        struct __main_block_impl_0 *blockStruct = (__bridge struct __main_block_impl_0 *)block;
        
        
        
        block(10, 10);
    }
    return 0;
}


