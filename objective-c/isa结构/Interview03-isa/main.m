//
//  main.m
//  Interview03-isa
//
//  Created by MJ Lee on 2018/4/15.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// MJPerson
@interface MJPerson : NSObject <NSCopying>
{
@public
    int _age;
}
@property (nonatomic, assign) int no;
- (void)personInstanceMethod;
+ (void)personClassMethod;
@end

@implementation MJPerson

- (void)test
{
    
}

- (void)personInstanceMethod
{
    
}
+ (void)personClassMethod
{
    
}
- (id)copyWithZone:(NSZone *)zone
{
    return nil;
}
@end

// MJStudent
@interface MJStudent : MJPerson <NSCoding>
{
@public
    int _weight;
}
@property (nonatomic, assign) int height;
- (void)studentInstanceMethod;
+ (void)studentClassMethod;
@end

@implementation MJStudent
- (void)test
{
    
}
- (void)studentInstanceMethod
{
    
}
+ (void)studentClassMethod
{
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}
@end

struct mj_objc_class {
    Class isa;
    Class superclass;
};

//在ARM 32位的时候，isa的类型是Class类型的，直接存储着实例对象或者类对象的地址；在ARM64结构下，isa的类型变成了共用体(union)，使用了位域去存储更多信息
//共用体中可以定义多个成员，共用体的大小由最大的成员大小决定
//共用体的成员公用一个内存
//对某一个成员赋值，会覆盖其他成员的值
//存储效率更高
union isa_t
{
    Class cls;
    uintptr_t bits;   //存储下面结构体每一位的值
    struct {
        uintptr_t nonpointer        : 1;  // 0:普通指针，存储Class、Meta-Class；1:存储更多信息
        uintptr_t has_assoc         : 1;  // 有没有关联对象
        uintptr_t has_cxx_dtor      : 1;  // 有没有C++的析构函数（.cxx_destruct）
        uintptr_t shiftcls          : 33; // 存储Class、Meta-Class的内存地址
        uintptr_t magic             : 6;  // 调试时分辨对象是否初始化用
        uintptr_t weakly_referenced : 1;  // 有没有被弱引用过
        uintptr_t deallocating      : 1;  // 正在释放
        uintptr_t has_sidetable_rc  : 1;  // 0:引用计数器在isa中；1:引用计数器存在SideTable
        uintptr_t extra_rc          : 19; // 引用计数器-1
    };
};

//Tagged Pointer的优化：
//Tagged Pointer专门用来存储小的对象，例如NSNumber, NSDate, NSString。
//Tagged Pointer指针的值不再是地址了，而是真正的值。所以，实际上它不再是一个对象了，它只是一个披着对象皮的普通变量而已。所以，它的内存并不存储在堆中，也不需要malloc和free。
//在内存读取上有着3倍的效率，创建时比以前快106倍。
//例如：1010，其中最高位1xxx表明这是一个tagged pointer，而剩下的3位010，表示了这是一个NSString类型。010转换为十进制即为2。也就是说，标志位是2的tagger
//pointer表示这是一个NSString对象。

//SEL，方法选择器，本质上是一个C字符串  IMP，函数指针，函数的执行入口  Method，类型，结构体，里面有SEL和IMP
/// Method
struct objc_method {
    SEL method_name;
    char *method_types;
    IMP method_imp;
 };

struct method_t {
    SEL name; //函数名
    const char *types; //编码（返回值类型、参数类型）
    IMP imp;//指向函数的指针（函数地址）
};


//runtime 有哪些应用？方法替换（method - Swizzling）有什么缺点？如何安全的进行方法替换？
//答：1、逆向。2、分类属性附加。3、预防崩溃等。4、方法的交换swizzling。5、快速定义归档和解档属性。
//缺点：
//1、找不到真正的方法归属
//例如数组越界，你以为替换的是NSArray的方法，事实上是_NSArrayI的方法
//2、多次进行方法交换，会将方法替换为原来的实现
//解决：利用单利进行限制，只进行一次方法交换
//3、交换的旧方法，子类未实现，父类实现
//出现的问题：父类在调用旧方法时，会崩溃
//解决方法：先进行方法添加，如果添加成功则进行替换<repleace>，反之，则进行交换<exchange>
//4、进行交换的方法，子类、父类均未实现
//出现的问题：出现死循环 解决方法：如果旧方法为nil，则替换后将swizzeldSEL复制一个不做任何操作的空实现。
//5、类方法–类方法存在元类中。
//答：找错替换的目标了


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // MJPerson类对象的地址：0x00000001000014c8
        // isa & ISA_MASK：0x00000001000014c8
        
        // MJPerson实例对象的isa：0x001d8001000014c9
        
        struct mj_objc_class *personClass = (__bridge struct mj_objc_class *)([MJPerson class]);
        
        struct mj_objc_class *studentClass = (__bridge struct mj_objc_class *)([MJStudent class]);
        
        NSLog(@"1111");
        
        MJPerson *person = [[MJPerson alloc] init];
        Class personClass1 = [MJPerson class];
        struct mj_objc_class *personClass2 = (__bridge struct mj_objc_class *)(personClass1);
        Class personMetaClass = object_getClass(personClass1);
        NSLog(@"%p %p %p", person, personClass1, personMetaClass);
        MJStudent *student = [[MJStudent alloc] init];
    }
    return 0;
}
