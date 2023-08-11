# Runtime的相关应用

前言
==

> 之前,我们在探索动画及渲染相关原理的时候,我们输出了几篇文章,解答了`iOS动画是如何渲染,特效是如何工作的疑惑`。我们深感系统设计者在创作这些系统框架的时候,是如此脑洞大开,也 **`深深意识到了解一门技术的底层原理对于从事该方面工作的重要性。`**
> 
> 因此我们决定 **`进一步探究iOS底层原理的任务`**。继前面两篇文章分别介绍了Runtime的：
> 
> *   [isa详解、class的结构、方法缓存cache\_t](https://juejin.cn/post/7116103432095662111 "https://juejin.cn/post/7116103432095662111")
> *   [objc\_msgSend的三个阶段(消息发送、动态解析方法、消息转发)、super的本质](https://juejin.cn/post/7116147057739431950/ "https://juejin.cn/post/7116147057739431950/") 之后,在本篇文章围绕Runtime在项目中的一些常见应用展开

一、 Runtime API
==============

首先我们写一段OC代码,然后基于此代码对一些Runtime API的使用展开介绍。

    // Person类继承自NSObject，包含run方法
    @interface Person : NSObject
    @property (nonatomic, strong) NSString *name;
    - (void)run;
    @end
    
    #import "Person.h"
    @implementation Person
    - (void)run
    {
        NSLog(@"%s",__func__);
    }
    @end
    
    // Car类继承自NSObejct，包含run方法
    #import "Car.h"
    @implementation Car
    - (void)run
    {
        NSLog(@"%s",__func__);
    }
    @end 
    复制代码

1\. 类相关API
----------

    1. 动态创建一个类（参数：父类，类名，额外的内存空间）
    Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)
    
    2. 注册一个类（要在类注册之前添加成员变量）
    void objc_registerClassPair(Class cls) 
    
    3. 销毁一个类
    void objc_disposeClassPair(Class cls)
    
    示例：
    void run(id self , SEL _cmd) {
        NSLog(@"%@ - %@", self,NSStringFromSelector(_cmd));
    }
    
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            // 创建类 superclass:继承自哪个类 name:类名 size_t:格外的大小，创建类是否需要扩充空间
            // 返回一个类对象
            Class newClass = objc_allocateClassPair([NSObject class], "Student", 0);
            
            // 添加成员变量 
            // cls:添加成员变量的类 name:成员变量的名字 size:占据多少字节 alignment:内存对齐，最好写1 types:类型，int类型就是@encode(int) 也就是i
            class_addIvar(newClass, "_age", 4, 1, @encode(int));
            class_addIvar(newClass, "_height", 4, 1, @encode(float));
            
            // 添加方法
            class_addMethod(newClass, @selector(run), (IMP)run, "v@:");
            
            // 注册类
            objc_registerClassPair(newClass);
            
            // 创建实例对象
            id student = [[newClass alloc] init];
        
            // 通过KVC访问
            [student setValue:@10 forKey:@"_age"];
            [student setValue:@180.5 forKey:@"_height"];
            
            // 获取成员变量
            NSLog(@"_age = %@ , _height = %@",[student valueForKey:@"_age"], [student valueForKey:@"_height"]);
            
            // 获取类的占用空间
            NSLog(@"类对象占用空间%zd", class_getInstanceSize(newClass));
            
            // 调用动态添加的方法
            [student run];
            
        }
        return 0;
    }
    
    // 打印内容
    // Runtime应用[25605:4723961] _age = 10 , _height = 180.5
    // Runtime应用[25605:4723961] 类对象占用空间16
    // Runtime应用[25605:4723961] <Student: 0x10072e420> - run
    
    注意
    类一旦注册完毕，就相当于类对象和元类对象里面的结构就已经创建好了。
    因此必须在注册类之前，添加成员变量。方法可以在注册之后再添加，因为方法是可以动态添加的。
    创建的类如果不需要使用了 ，需要释放类。
    复制代码

    4. 获取isa指向的Class，如果将类对象传入获取的就是元类对象，如果是实例对象则为类对象
    Class object_getClass(id obj)
    
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            Person *person = [[Person alloc] init];
            NSLog(@"%p,%p,%p",object_getClass(person), [Person class],
                  object_getClass([Person class]));
        }
        return 0;
    }
    // 打印内容
    Runtime应用[21115:3807804] 0x100001298,0x100001298,0x100001270
    复制代码

    5. 设置isa指向的Class，可以动态的修改类型。例如修改了person对象的类型，也就是说修改了person对象的isa指针的指向，中途让对象去调用其他类的同名方法。
    Class object_setClass(id obj, Class cls)
    
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            Person *person = [[Person alloc] init];
            [person run];
            
            object_setClass(person, [Car class]);
            [person run];
        }
        return 0;
    }
    // 打印内容
    Runtime应用[21147:3815155] -[Person run]
    Runtime应用[21147:3815155] -[Car run]
    最终其实调用了car的run方法 
    复制代码

    6. 用于判断一个OC对象是否为Class
    BOOL object_isClass(id obj)
    
    // 判断OC对象是实例对象还是类对象
    NSLog(@"%d",object_isClass(person)); // 0
    NSLog(@"%d",object_isClass([person class])); // 1
    NSLog(@"%d",object_isClass(object_getClass([person class]))); // 1 
    // 元类对象也是特殊的类对象 
    复制代码

    7. 判断一个Class是否为元类
    BOOL class_isMetaClass(Class cls)
    8. 获取类对象父类
    Class class_getSuperclass(Class cls) 
    复制代码

2\. 成员变量相关API
-------------

    1. 获取一个实例变量信息，描述信息变量的名字，占用多少字节等
    Ivar class_getInstanceVariable(Class cls, const char *name)
    
    2. 拷贝实例变量列表（最后需要调用free释放）
    Ivar *class_copyIvarList(Class cls, unsigned int *outCount)
    
    3. 设置和获取成员变量的值
    void object_setIvar(id obj, Ivar ivar, id value)
    id object_getIvar(id obj, Ivar ivar)
    
    4. 动态添加成员变量（已经注册的类是不能动态添加成员变量的）
    BOOL class_addIvar(Class cls, const char * name, size_t size, uint8_t alignment, const char * types)
    
    5. 获取成员变量的相关信息，传入成员变量信息，返回C语言字符串
    const char *ivar_getName(Ivar v)
    6. 获取成员变量的编码，types
    const char *ivar_getTypeEncoding(Ivar v)
    
    示例：
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            // 获取成员变量的信息
            Ivar nameIvar = class_getInstanceVariable([Person class], "_name");
            // 获取成员变量的名字和编码
            NSLog(@"%s, %s", ivar_getName(nameIvar), ivar_getTypeEncoding(nameIvar));
            
            Person *person = [[Person alloc] init];
            // 设置和获取成员变量的值
            object_setIvar(person, nameIvar, @"xx_cc");
            // 获取成员变量的值
            object_getIvar(person, nameIvar);
            NSLog(@"%@", object_getIvar(person, nameIvar));
            NSLog(@"%@", person.name);
            
            // 拷贝实例变量列表
            unsigned int count ;
            Ivar *ivars = class_copyIvarList([Person class], &count);
    
            for (int i = 0; i < count; i ++) {
                // 取出成员变量
                Ivar ivar = ivars[i];
                NSLog(@"%s, %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
            }
            
            free(ivars);
    
        }
        return 0;
    }
    
    // 打印内容
    // Runtime应用[25783:4778679] _name, @"NSString"
    // Runtime应用[25783:4778679] xx_cc
    // Runtime应用[25783:4778679] xx_cc
    // Runtime应用[25783:4778679] _name, @"NSString" 
    复制代码

3\. 属性相关AIP
-----------

    1. 获取一个属性
    objc_property_t class_getProperty(Class cls, const char *name)
    
    2. 拷贝属性列表（最后需要调用free释放）
    objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
    
    3. 动态添加属性
    BOOL class_addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
                      unsigned int attributeCount)
    
    4. 动态替换属性
    void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
                          unsigned int attributeCount)
    
    5. 获取属性的一些信息
    const char *property_getName(objc_property_t property)
    const char *property_getAttributes(objc_property_t property)
    
    复制代码

4.方法相关API
---------

    1. 获得一个实例方法、类方法
    Method class_getInstanceMethod(Class cls, SEL name)
    Method class_getClassMethod(Class cls, SEL name)
    
    2. 方法实现相关操作
    IMP class_getMethodImplementation(Class cls, SEL name) 
    IMP method_setImplementation(Method m, IMP imp)
    void method_exchangeImplementations(Method m1, Method m2) 
    
    3. 拷贝方法列表（最后需要调用free释放）
    Method *class_copyMethodList(Class cls, unsigned int *outCount)
    
    4. 动态添加方法
    BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)
    
    5. 动态替换方法
    IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
    
    6. 获取方法的相关信息（带有copy的需要调用free去释放）
    SEL method_getName(Method m)
    IMP method_getImplementation(Method m)
    const char *method_getTypeEncoding(Method m)
    unsigned int method_getNumberOfArguments(Method m)
    char *method_copyReturnType(Method m)
    char *method_copyArgumentType(Method m, unsigned int index)
    
    7. 选择器相关
    const char *sel_getName(SEL sel)
    SEL sel_registerName(const char *str)
    
    8. 用block作为方法实现
    IMP imp_implementationWithBlock(id block)
    id imp_getBlock(IMP anImp)
    BOOL imp_removeBlock(IMP anImp) 
    复制代码

二、Runtime在项目中的常见应用
==================

> 首先导入头文件`#import <objc/runtime.h>`

通过runtime的一系列方法，可以获取类的一些信息， 包括：属性列表，方法列表，成员变量列表，和遵循的协议列表。

1、获取列表
------

### 1.1 获取属性列表

有时候会有这样的需求，我们需要知道当前类中每个属性的名字。

        unsigned int count;
        // 获取列表
        objc_property_t *propertyList = class_copyPropertyList([self class], &count);
        for (unsigned int i=0; i<count; i++) {
            // 获取属性名
            const char *propertyName = property_getName(propertyList[i]);
            // 打印
            NSLog(@"property-->%@", [NSString stringWithUTF8String:propertyName]);
        }
    复制代码

### 1.2 获取方法列表

        Method *methodList = class_copyMethodList([self class], &count);
        for (unsigned int i; i<count; i++) {
            Method method = methodList[i];
            NSLog(@"method-->%@", NSStringFromSelector(method_getName(method)));
        }
    复制代码

### 1.3 获取成员变量列表

        Ivar *ivarList = class_copyIvarList([self class], &count);
        for (unsigned int i; i<count; i++) {
            Ivar myIvar = ivarList[i];
            const char *ivarName = ivar_getName(myIvar);
            NSLog(@"Ivar---->%@", [NSString stringWithUTF8String:ivarName]);
        }
    复制代码

### 1.4 获取协议列表

        __unsafe_unretained Protocol **protocolList = class_copyProtocolList([self class], &count);
        for (unsigned int i; i<count; i++) {
            Protocol *myProtocal = protocolList[i];
            const char *protocolName = protocol_getName(myProtocal);
            NSLog(@"protocol---->%@", [NSString stringWithUTF8String:protocolName]);
        }
    复制代码

2、动态添加
------

### 2.1 动态添加方法

核心方法：`class_addMethod ()` 首先从外部隐式调用一个`不存在`的方法：

    // 隐式调用方法
    [target performSelector:@selector(resolveAdd:) withObject:@"test"];
    复制代码

然后，在target对象内部重写拦截调用的方法，动态添加方法。

    // 重写了拦截调用的方法，并返回YES
    + (BOOL)resolveInstanceMethod:(SEL)sel{
        
        //给本类动态添加一个方法
        if ([NSStringFromSelector(sel) isEqualToString:@"resolveAdd:"]) {
            class_addMethod(self, sel, (IMP)runAddMethod, "v@:*");
        }
        return YES;
    }
    // 调用新增的方法
    void runAddMethod(id self, SEL _cmd, NSString *string){
        NSLog(@"add C IMP ", string);  //withObject 参数
    }
    
    复制代码

> 其中`class_addMethod`的四个参数分别是：

*   `Class`： cls 给哪个类添加方法，本例中是self
*   `SEL name`： 添加的方法，本例中是重写的拦截调用传进来的selector
*   `IMP imp`： 方法的实现，C方法的方法实现可以直接获得。如果是OC方法，可以用`+ (IMP)instanceMethodForSelector:(SEL)aSelector;`获得方法的实现。
*   `"v@:*"`：方法的签名，代表有一个参数的方法。

### 2.2 动态添加Ivar

*   优点：
    *   动态添加Ivar我们能够通过遍历Ivar得到我们所添加的属性。
*   缺点：
    *   不能在已存在的class中添加Ivar，所以说必须通过objc\_allocateClassPair动态创建一个class，才能调用class\_addIvar创建Ivar，最后通过objc\_registerClassPair注册class。

    //在目标target上添加属性(已经存在的类不支持，可跳进去看注释)，属性名propertyname，值value
    - (void)addIvarWithtarget:(id)target withPropertyName:(NSString *)propertyName withValue:(id)value {
        if (class_addIvar([target class], [propertyName UTF8String], sizeof(id), log2(sizeof(id)), "@"))
        {
            NSLog(@"创建属性Ivar成功");
        }
    }
    //获取目标target的指定属性值
    - (id)getIvarValueWithTarget:(id)target withPropertyName:(NSString *)propertyName
    {    Ivar ivar = class_getInstanceVariable([target class], [propertyName UTF8String]);
        if (ivar) {
            id value = object_getIvar(target, ivar);
            return value;
        } else
        {
            return nil;
        }
    }
    复制代码

### 2.3 动态添加property

主要用到class\_addProperty，class\_addMethod，class\_replaceProperty，class\_getInstanceVariable

    //在目标target上添加属性，属性名propertyname，值value
    + (void)addPropertyWithtarget:(id)target withPropertyName:(NSString *)propertyName withValue:(id)value {
        //先判断有没有这个属性，没有就添加，有就直接赋值
        Ivar ivar = class_getInstanceVariable([target class], [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
        if (ivar)
        {
            return;
        }
    
        /*
         objc_property_attribute_t type = { "T", "@/"NSString/"" };
         objc_property_attribute_t ownership = { "C", "" }; // C = copy
         objc_property_attribute_t backingivar  = { "V", "_privateName" };
         objc_property_attribute_t attrs[] = { type, ownership, backingivar };
         class_addProperty([SomeClass class], "name", attrs, 3);
         */
    
        //objc_property_attribute_t所代表的意思可以调用getPropertyNameList打印，大概就能猜出。
        objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@/%@/",NSStringFromClass([value class])] UTF8String] };
        objc_property_attribute_t ownership = { "&", "N" };
        objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
        objc_property_attribute_t attrs[] = { type, ownership, backingivar };
        if (class_addProperty([target class], [propertyName UTF8String], attrs, 3))
        {
            //添加get和set方法
            class_addMethod([target class], NSSelectorFromString(propertyName), (IMP)getter, "@@:");
            class_addMethod([target class], NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)setter, "v@:@");
            //赋值
            [target setValue:value forKey:propertyName];
            NSLog(@"%@", [target valueForKey:propertyName]);
            NSLog(@"创建属性Property成功");
        }
        else {
            class_replaceProperty([target class], [propertyName UTF8String], attrs, 3);
            //添加get和set方法
            class_addMethod([target class], NSSelectorFromString(propertyName), (IMP)getter, "@@:");
            class_addMethod([target class], NSSelectorFromString([NSString stringWithFormat:@"set%@:",[propertyName capitalizedString]]), (IMP)setter, "v@:@");
            //赋值
            [target setValue:value forKey:propertyName];
        }
    }
    
    id getter(id self1, SEL _cmd1)
    {
        NSString *key = NSStringFromSelector(_cmd1);
        Ivar ivar = class_getInstanceVariable([self1 class], "_dictCustomerProperty");
        //basicsViewController里面有个_dictCustomerProperty属性
        NSMutableDictionary *dictCustomerProperty = object_getIvar(self1, ivar);
        return [dictCustomerProperty objectForKey:key];
    }
    
    void setter(id self1, SEL _cmd1, id newValue)
    {
        //移除set
        NSString *key = [NSStringFromSelector(_cmd1) stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
        //首字母小写
        NSString *head = [key substringWithRange:NSMakeRange(0, 1)];
        head = [head lowercaseString];
        key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
        //移除后缀 ":"
        key = [key stringByReplacingCharactersInRange:NSMakeRange(key.length - 1, 1) withString:@""];
        Ivar ivar = class_getInstanceVariable([self1 class], "_dictCustomerProperty");
        //basicsViewController里面有个_dictCustomerProperty属性
        NSMutableDictionary *dictCustomerProperty = object_getIvar(self1, ivar);
        if (!dictCustomerProperty)
        {
            dictCustomerProperty = [NSMutableDictionary dictionary];
            object_setIvar(self1, ivar, dictCustomerProperty);
        }
        [dictCustomerProperty setObject:newValue forKey:key];
    }
    
    + (id)getPropertyValueWithTarget:(id)target withPropertyName:(NSString *)propertyName
    {
        //先判断有没有这个属性，没有就添加，有就直接赋值
        Ivar ivar = class_getInstanceVariable([target class], [[NSString stringWithFormat:@"_%@", propertyName] UTF8String]);
        if (ivar)
        {
            return object_getIvar(target, ivar);
        }
        ivar = class_getInstanceVariable([target class], "_dictCustomerProperty");
        //basicsViewController里面有个_dictCustomerProperty属性
        NSMutableDictionary *dict = object_getIvar(target, ivar);
        if (dict && [dict objectForKey:propertyName]) {
            return [dict objectForKey:propertyName];
        }
        else
        {
            return nil;
        }
    }
    复制代码

### 2.4 动态添加方法

    void dynamicMethodIMP(id self, SEL _cmd) {
        // implementation ....
    }
    
    @implementation MyClass
    + (BOOL)resolveInstanceMethod:(SEL)aSEL
    {
        if (aSEL == @selector(resolveThisMethodDynamically)) {
            class_addMethod([self class], aSEL, (IMP) dynamicMethodIMP, "v@:");
            return YES;
        }
        return [super resolveInstanceMethod:aSEL];
    }
    @end
    复制代码

### 2.5 分类添加属性

    @implementation NSObject (Property)
    - (NSString *)name
    {
        // 根据关联的key，获取关联的值。
        return objc_getAssociatedObject(self,_cmd);
    }
    - (void)setName:(NSString *)name
    {
        // 第一个参数：给哪个对象添加关联
        // 第二个参数：关联的key，通过这个key获取
        // 第三个参数：关联的value
        // 第四个参数:关联的策略
        objc_setAssociatedObject(self,  @selector(name), name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    @end
    复制代码

4、动态重写方法
--------

在没有一个类的实现源码的情况下，想改变其中一个方法的实现，除了`继承它重写`、和`借助Category重名方法`之外，还有更加灵活的方法 `Method Swizzle`。 在OC中调用一个方法，其实是向一个对象发送消息，查找消息的唯一依据是selector的名字。 利用OC的动态特性，可以实现在运行时偷换selector对应的方法实现。

> `Method Swizzle` 指的是，改变一个已存在的选择器对应的实现过程。OC中方法的调用能够在运行时，改变类的调度表中选择器到最终函数间的映射关系。

每个类都有一个方法列表，存放着selector的名字及其方法实现的映射关系。IMP有点类似函数指针，指向具体的方法实现。 利用 `method_exchangeImplementations` 来交换2个方法中的IMP。 利用 `class_replaceMethod` 来修改类。 利用 `method_setImplementation` 来直接设置某个方法的IMP。

归根结底，都是偷换了`selector`的IMP

5、方法交换
------

新建分类

    #import <objc/runtime.h> 
    + (void)load {
        // 方法交换应该被保证，在程序中只会执行一次
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            // 获得需要替换的系统方法
            SEL systemSel = @selector(didDisplay);
            // 自己实现的将要被交换的方法
            SEL swizzSel = @selector(myDidDisplay);
            
            //两个方法的Method
            Method systemMethod = class_getInstanceMethod([self class], systemSel);
            Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
            
            //首先动态添加方法，实现是被交换的方法，返回值表示添加成功还是失败
            BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
            if (isAdd) {
                //如果成功，说明类中不存在这个方法的实现
                //将被交换方法的实现替换到这个并不存在的实现
                class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
            } else {
                //否则，交换两个方法的实现
                method_exchangeImplementations(systemMethod, swizzMethod);
            }
            
        });
    }
    
    -(void)myDidDisplay{
      //......do
    }
    复制代码

6、归档解档
------

    // 设置不需要归解档的属性
    - (NSArray *)ignoredNames {
        return @[@"_aaa",@"_bbb",@"_ccc"];
    }
    // 解档方法
    - (instancetype)initWithCoder:(NSCoder *)aDecoder {
        if (self = [super initWithCoder:aDecoder]) {
            // 获取所有成员变量
            unsigned int outCount = 0;
            Ivar *ivars = class_copyIvarList([self class], &outCount);
    
            for (int i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                // 将每个成员变量名转换为NSString对象类型
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
    
                // 忽略不需要解档的属性
                if ([[self ignoredNames] containsObject:key]) {
                    continue;
                }
    
                // 根据变量名解档取值，无论是什么类型
                id value = [aDecoder decodeObjectForKey:key];
                // 取出的值再设置给属性
                [self setValue:value forKey:key];
                // 这两步就相当于以前的 self.age = [aDecoder decodeObjectForKey:@"_age"];
            }
            free(ivars);
        }
        return self;
    }
    // 归档调用方法
    - (void)encodeWithCoder:(NSCoder *)aCoder {
        // 获取所有成员变量
        unsigned int outCount = 0;
        Ivar *ivars = class_copyIvarList([self class], &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            // 将每个成员变量名转换为NSString对象类型
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
    
            // 忽略不需要归档的属性
            if ([[self ignoredNames] containsObject:key]) {
                continue;
            }
    
            // 通过成员变量名，取出成员变量的值
            id value = [self valueForKeyPath:key];
            // 再将值归档
            [aCoder encodeObject:value forKey:key];
            // 这两步就相当于 [aCoder encodeObject:@(self.age) forKey:@"_age"];
        }
        free(ivars);
    }
    复制代码

7、字典转模型
-------

在OC中，字典转模型一般我们用第三方库`MJExtension`，`YYModel`来运用。

基本原理就是:

*   利用`Runtime`可以获取模型中所有属性这一特性，来对要进行转换的字典进行遍历
*   利用`KVC`的方法去取值赋值
    *   `- (nullable id)valueForKeyPath:(NSString *)keyPath;`
    *   `- (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath;`
    *   去取出模型属性并作为字典中相对应的`key`，来取出其所对应的`value`，并把`value`赋值给模型属性。

下面来个简单的字典转模型的例子

    - (void)transformDict:(NSDictionary *)dict {
        Class class = self.class;
        // count:成员变量个数
        unsigned int count = 0;
        // 获取成员变量数组
        Ivar *ivars = class_copyIvarList(class, &count);
        // 遍历所有成员变量
        for (int i = 0; i < count; i++) {
            // 获取成员变量
            Ivar ivar = ivars[i];
            // 获取成员变量名字
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
            // 成员变量名转为属性名（去掉下划线 _ ）
            key = [key substringFromIndex:1];
            // 取出字典的值
            id value = dict[key];
            // 如果模型属性数量大于字典键值对数理，模型属性会被赋值为nil而报错
            if (value == nil) continue;
            // 利用KVC将字典中的值设置到模型上
            [self setValue:value forKeyPath:key];
        }
        //释放指针
        free(ivars);
    }
    复制代码

8、页面统计
------

添加一个`UIViewController`的分类:

*   通过`load`方法和`dispatch_once_t`来保证只加载一次
*   将`UIViewController`的`viewWillAppear`方法，交换为`swizz_viewWillAppear`方法

    + (void)load
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
        
            Class class = [self class];
            
            SEL originalSEL = @selector(viewWillAppear:);
            SEL swizzledSEL = @selector(swizz_viewWillAppear:);
            // 交换方法
            [JJRuntimeTool jj_MethodSwizzlingWithClass:class oriSEL:originalSEL swizzledSEL:swizzledSEL];
        });
    }
    复制代码

    - (void)swizz_viewWillAppear:(BOOL)animated
    {
        // 这里是调用交换方法的viewWillAppear，不是递归
        [self swizz_viewWillAppear:animated];
        NSLog(@"统计页面: %@", [self class]);
    }
    复制代码

9、防止按钮多次点击事件
------------

这里我们要配合分类`UIControl`，使用关联对象来添加属性。`delayInterval`来控制按钮点击几秒后才可以继续响应事件。

    @interface UIControl (Swizzling)
    
    // 是否忽略事件
    @property (nonatomic, assign) BOOL ignoreEvent;
    
    // 延迟多少秒可继续执行
    @property (**nonatomic, assign) NSTimeInterval delayInterval;
    
    @end
    复制代码

设置属性的`set`和`get`方法。

    - (void)setIgnoreEvent:(BOOL)ignoreEvent
    {
        objc_setAssociatedObject(self, @"associated_ignoreEvent", @(ignoreEvent), OBJC_ASSOCIATION_ASSIGN);
    }
    
    - (BOOL)ignoreEvent
    {
        return [objc_getAssociatedObject(self, @"associated_ignoreEvent") boolValue];
    }
    
    - (void)setDelayInterval:(NSTimeInterval)delayInterval
    {
        objc_setAssociatedObject(self, @"associated_delayInterval", @(delayInterval), OBJC_ASSOCIATION_ASSIGN);
    }
    
    - (NSTimeInterval)delayInterval
    {
        return [objc_getAssociatedObject(self, @"associated_delayInterval") doubleValue];
    }
    复制代码

这里的实现方法也是通过交换响应事件`sendAction:to:forEvent:`方法来实现延迟响应事件。

    + (void)load
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
    
            Class class = [self class];
            SEL originalSEL = @selector(sendAction:to:forEvent:);
            SEL swizzledSEL = @selector(swizzl_sendAction:to:forEvent:);
            
            [JJRuntimeTool jj_MethodSwizzlingWithClass:class oriSEL:originalSEL swizzledSEL:swizzledSEL];
    
        });
    }
    复制代码

    - (void)swizzl_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
    {
        // 如果忽略响应，就return
        if (self.ignoreEvent) return;
    
        if (self.delayInterval > 0) {
            //添加了延迟，ignoreEvent就设置为YES，让上面来拦截。
            self.ignoreEvent = YES;
            // 延迟delayInterval秒后，让ignoreEvent为NO,可以继续响应
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delayInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.ignoreEvent = NO;
            });
        }
        // 调用系统的sendAction方法
        [self swizzl_sendAction:action to:target forEvent:event];
    }
    复制代码

10、 稳定性治理
---------

### 10.1 防止数组越界崩溃

交换数组的`objectAtIndex`方法，检测是否越界，来防止崩溃。

    + (void)load {
    
        static dispatch_once_t onceToken;
    
        dispatch_once(&onceToken, ^{
    
            Class class = NSClassFromString(@"__NSArrayM");
    
            SEL originalSEL = @selector(objectAtIndex:);
    
            SEL swizzledSEL = @selector(swizz_objectAtIndex:);
    
            [JJRuntimeTool jj_MethodSwizzlingWithClass:class oriSEL:originalSEL swizzledSEL:swizzledSEL];
    
        });
    
    }
    
    - (id)swizz_objectAtIndex:(NSUInteger)index
    {
        if (index < self.count) {
            return [self swizz_objectAtIndex:index];
        }else {
            @try {
                return [self swizz_objectAtIndex:index];
            } @catch (NSException *exception) {
                NSLog(@"------- %s Crash Bacause Method %s --------- \n", class_getName(self.class), __func__ );
                NSLog(@"%@", [exception callStackSymbols]);
                return nil;
            } @finally {
            }
        }
    }
    复制代码

### 10.2 防止找不到方法实现崩溃

如果调用`objc_msgSend`后，找不到`IMP`实现方法，就会来到消息转发机制`resolveInstanceMethod`,这时候，我们可以动态添加一个方法，让`sel`指向我们的动态实现的`IMP`，来防止崩溃。

    void testFun(){
        NSLog(@"test Fun");
    }
    
    +(BOOL)resolveInstanceMethod:(SEL)sel{
        if ([super resolveInstanceMethod:sel]) {
            return YES;
        }else{
            class_addMethod(self, sel, (IMP)testFun, "v@:");
            return YES;
        }
    }
    复制代码

### 10.3 ...

11、切面开发
-------

### 11.1 Aspects

面向切面编程`Aspects`，不修改原来的函数，可以在函数的执行前后插入一些代码。这个是我在公司的老项目发现用的库，觉得有意思，也写下来。

核心是方法`aspect_hookSelector`。

    /**
    作用域：针对所有对象生效
    selector: 需要hook的方法
    options：是个枚举，主要定义了切面的时机（调用前、替换、调用后）
    block: 需要在selector前后插入执行的代码块
    error: 错误信息
    */
    + (id<AspectToken>)aspect_hookSelector:(SEL)selector
                               withOptions:(AspectOptions)options
                                usingBlock:(id)block
                                     error:(NSError **)error;
    /**
    作用域：针对当前对象生效
    */
    - (id<AspectToken>)aspect_hookSelector:(SEL)selector
                               withOptions:(AspectOptions)options
                                usingBlock:(id)block
                                     error:(NSError **)error;
    复制代码

### AspectOptions

`AspectOptions`是个枚举，用来定义切面的时机，即原有方法调用前、调用后、替换原有方法、只执行一次（调用完就删除切面逻辑）

    typedef NS_OPTIONS(NSUInteger, AspectOptions) {
        AspectPositionAfter   = 0,            /// 原有方法调用后
        AspectPositionInstead = 1,            /// 替换原有方法
        AspectPositionBefore  = 2,            /// 原有方法调用前执行
        
        AspectOptionAutomaticRemoval = 1 << 3 /// 执行完之后就恢复切面操作，即撤销hook
    };
    复制代码

### AspectsDemo

我们想在当前控制器调用`viewWillAppear`后，进行操作内容。

    - (void)viewDidLoad {
    
        [super viewDidLoad];
    
        [self aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^{
    
            NSLog(@"CCCCCC");
    
        } error:nil];
    
    }
    复制代码

    - (void)viewWillAppear:(BOOL)animated
    {
        NSLog(@"AAAAAA");
        [super viewWillAppear:animated];
        NSLog(@"BBBBBB");
    }
    复制代码

运行结果：

    022-01-14 15:32:49.962692+0800 AspectsDemo[68165:356953] AAAAAA
    
    2022-01-14 15:32:49.962785+0800 AspectsDemo[68165:356953] BBBBBB
    
    2022-01-14 15:32:49.962847+0800 AspectsDemo[68165:356953] CCCCCC
    复制代码

附上gitHub地址:[Aspects](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FLuckyVan37%2FAspects%3Forganization%3DLuckyVan37%26organization%3DLuckyVan37 "https://github.com/LuckyVan37/Aspects?organization=LuckyVan37&organization=LuckyVan37")

12、语言国际化
--------

### 12.1 对setText进行方法交换

国际化主要的工作就是在 `setText` 之前需要调用 `NSLocalizedString` 生成国际化后的字符串。

目前代码使我们纠结的地方是我们就直接使用 `setText` 了。我们希望在`setText`时插入一段国际化的代码。

我们希望在执行某个函数之前插入一段代码，Runtime的 `Method Swizzling` 可以实现这样的功能。

    @implementation UILabel(NewLabel)
    + (void)load {
        [UILabel configSwizzled];
    }
    + (void)configSwizzled {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [self class];
            SEL originalSelector = @selector(setText:);
            SEL swizzledSelector = @selector(setNewText:);
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            if (didAddMethod) {
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod,swizzledMethod);
            }
        });
    }
    - (void)setNewText:(NSString *)text {
        [self setNewText:NSLocalizedString(text, nil)];
    }
    @end
    复制代码

*   我们使用分类扩展 `UILabel` 。
*   然后重写 `load` 这个函数，在里面进行Swizzle的初始化。
*   在这里我们把 `setText` Swizzle `setNewText`.
*   在 `setNewText` 中我们我们调用 `NSLocalizedString` 进行国际化处理。

好了，这样我们解决了在代码中 `setText` 的国际化问题。

### 12.2 xib、storyboard语言国际化

这里我们发现，Xib StoryBoard 中设置属性的控件不会调用 `setText` 。

那这我们怎么解决呢？ 让他们调用一下 `setText` 吧。那我们需要怎么做？ Xib StoryBoard 的控件，必然会走 `initWithCoder` 这个初始化函数。我们在再次使用 Runtime 的黑魔法，让 `initWithCoder` 执行完后，我们在调用一下 `setText`。

直接看代码吧：

    + (void)configSwizzled {
    ...
    dispatch_once(&onceToken2, ^{
            Class class = [self class];
            SEL originalSelector = ;
            SEL swizzledSelector = ;
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
            if (didAddMethod) {
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod,swizzledMethod);
            }
        });
    }
    - (instancetype)initNewWithCoder:(NSCoder *)aDecoder {
        id result = [self initNewWithCoder:aDecoder];
        [self setText:self.text];
        return result;
    }
    复制代码

### 12.3 允许一些控件关闭语言国际化

我们可以添加一个变量来控制代码是否进行国际化。那就使用`关联对象(Associated Object)`吧。

    @interface UILabel (NewLabel)
    @property (nonatomic, assign)IBInspectable BOOL localizedEnlabe;
    @end
    @implementation UILabel(NewLabel)
    static char *localizedEnlabeChar = "LocalizedEnlabe";
    - (void)setLocalizedEnlabe:(BOOL)localizedEnlabe {
        objc_setAssociatedObject(self, &localizedEnlabeChar, [NSNumber numberWithBool:localizedEnlabe], OBJC_ASSOCIATION_ASSIGN);
    }
    - (BOOL)localizedEnlabe {
        NSNumber *value = objc_getAssociatedObject(self, &localizedEnlabeChar);
        if (value) {
            return [value boolValue];
        }
        return YES;
    }
    @end
    复制代码

*   这里我使用 `IBInspectable` 属性方便 Xib StoryBoard 设置属性.
    
*   需要国际化的控件还有 `UITextField` ， `UIButton` 等控件
    
*   虽然这种方法不见得能解决所有问题，但应该是可以解决 80% 的问题的。
    

十、面试题(转)
========

经过前面几篇文章的对Runtime的探索,我们可以用一些常见的Runtime面试题来检验一下学习成果.

1.objc在向一个对象发送消息时，发生了什么？
------------------------

> objc在向一个对象发送消息时，runtime会根据对象的isa指针找到该对象实际所属的类，然后在该类中的方法列表以及其父类方法列表中寻找方法运行，如果一直到根类还没找到，转向拦截调用，走消息转发机制，一旦找到 ，就去执行它的实现`IMP` 。

2.objc中向一个nil对象发送消息将会发生什么？
--------------------------

> 如果向一个nil对象发送消息，首先在寻找对象的isa指针时就是0地址返回了，所以不会出现任何错误。也不会崩溃。

详解： 如果一个方法返回值是一个对象，那么发送给nil的消息将返回0(nil)；

如果方法返回值为指针类型，其指针大小为小于或者等于sizeof(void\*) ，float，double，long double 或者long long的整型标量，发送给nil的消息将返回0；

如果方法返回值为结构体,发送给nil的消息将返回0。结构体中各个字段的值将都是0；

如果方法的返回值不是上述提到的几种情况，那么发送给nil的消息的返回值将是未定义的。

3.objc中向一个对象发送消息\[obj foo\]和`objc_msgSend()`函数之间有什么关系？
------------------------------------------------------

> 在objc编译时，\[obj foo\] 会被转意为：`objc_msgSend(obj, @selector(foo));`。

4.什么时候会报unrecognized selector的异常？
---------------------------------

> objc在向一个对象发送消息时，runtime库会根据对象的isa指针找到该对象实际所属的类，然后在该类中的方法列表以及其父类方法列表中寻找方法运行，如果，在最顶层的父类中依然找不到相应的方法时，会进入消息转发阶段，如果消息三次转发流程仍未实现，则程序在运行时会挂掉并抛出异常unrecognized selector sent to XXX 。

5.能否向编译后得到的类中增加实例变量？能否向运行时创建的类中添加实例变量？为什么？
------------------------------------------

> 不能向编译后得到的类中增加实例变量；
> 
> 能向运行时创建的类中添加实例变量；

> 1.因为编译后的类已经注册在 runtime 中,类结构体中的 objc\_ivar\_list 实例变量的链表和 instance\_size 实例变量的内存大小已经确定，同时runtime会调用 class\_setvarlayout 或 class\_setWeaklvarLayout 来处理strong weak 引用.所以不能向存在的类中添加实例变量。
> 
> 2.运行时创建的类是可以添加实例变量，调用class\_addIvar函数. 但是的在调用 objc\_allocateClassPair 之后，objc\_registerClassPair 之前,原因同上.

6.给类添加一个属性后，在类结构体里哪些元素会发生变化？
----------------------------

> instance\_size ：实例的内存大小；objc\_ivar\_list \*ivars:属性列表

7.一个objc对象的isa的指针指向什么？有什么作用？
----------------------------

> 指向他的类对象,从而可以找到对象上的方法

详解：下图很好的描述了对象，类，元类之间的关系:

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1d22c611b65e4c95a0f6e448e4ffc655~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

图中实线是 super\_class指针，虚线是isa指针。

1.  Root class (class)其实就是NSObject，NSObject是没有超类的，所以Root class(class)的superclass指向nil。
2.  每个Class都有一个isa指针指向唯一的Meta class
3.  Root class(meta)的superclass指向Root class(class)，也就是NSObject，形成一个回路。
4.  每个Meta class的isa指针都指向Root class (meta)。

8.\[self class\] 与 \[super class\]
----------------------------------

下面的代码输出什么？

    @implementation Son : Father
    - (id)init
    {
       self = [super init];
       if (self) {
           NSLog(@"%@", NSStringFromClass([self class]));
           NSLog(@"%@", NSStringFromClass([super class]));
       }
       return self;
    }
    @end
    复制代码

> NSStringFromClass(\[self class\]) = Son NSStringFromClass(\[super class\]) = Son

详解：这个题目主要是考察关于 Objective-C 中对 self 和 super 的理解。

self 是类的隐藏参数，指向当前调用方法的这个类的实例；

super 本质是一个编译器标示符，和 self 是指向的同一个消息接受者。不同点在于：super 会告诉编译器，当调用方法时，去调用父类的方法，而不是本类中的方法。

当使用 self 调用方法时，会从当前类的方法列表中开始找，如果没有，就从父类中再找；而当使用 super 时，则从父类的方法列表中开始找。然后调用父类的这个方法。

在调用`[super class]`的时候，runtime会去调用`objc_msgSendSuper`方法，而不是`objc_msgSend`；

    OBJC_EXPORT void objc_msgSendSuper(void /* struct objc_super *super, SEL op, ... */ )
    
    /// Specifies the superclass of an instance. 
    struct objc_super {
        /// Specifies an instance of a class.
        __unsafe_unretained id receiver;
    
        /// Specifies the particular superclass of the instance to message. 
    #if !defined(__cplusplus)  &&  !__OBJC2__
        /* For compatibility with old objc-runtime.h header */
        __unsafe_unretained Class class;
    #else
        __unsafe_unretained Class super_class;
    #endif
        /* super_class is the first class to search */
    };
    复制代码

在objc\_msgSendSuper方法中，第一个参数是一个objc\_super的结构体，这个结构体里面有两个变量，一个是接收消息的receiver，一个是当前类的父类super\_class。

objc\_msgSendSuper的工作原理应该是这样的: 从objc\_super结构体指向的superClass父类的方法列表开始查找selector，找到后以objc->receiver去调用父类的这个selector。注意，最后的调用者是objc->receiver，而不是super\_class！

那么objc\_msgSendSuper最后就转变成:

    // 注意这里是从父类开始msgSend，而不是从本类开始
    objc_msgSend(objc_super->receiver, @selector(class))
    
    /// Specifies an instance of a class.  这是类的一个实例
        __unsafe_unretained id receiver;   
    
    
    // 由于是实例调用，所以是减号方法
    - (Class)class {
        return object_getClass(self);
    }
    复制代码

由于找到了父类NSObject里面的class方法的IMP，又因为传入的入参objc\_super->receiver = self。self就是son，调用class，所以父类的方法class执行IMP之后，输出还是son，最后输出两个都一样，都是输出son。

9.runtime如何通过selector找到对应的IMP地址？
--------------------------------

> 每一个类对象中都一个方法列表,方法列表中记录着方法的名称,方法实现,以及参数类型,其实selector本质就是方法名称,通过这个方法名称就可以在方法列表中找到对应的方法实现.

10.\_objc\_msgForward函数是做什么的，直接调用它将会发生什么？
-----------------------------------------

> `_objc_msgForward`是 IMP 类型，用于消息转发的：当向一个对象发送一条消息，但它并没有实现的时候，`_objc_msgForward`会尝试做消息转发。

详解：`_objc_msgForward`在进行消息转发的过程中会涉及以下这几个方法：

1.  `resolveInstanceMethod:`方法 (或 `resolveClassMethod:`)。
2.  `forwardingTargetForSelector:`方法
3.  `methodSignatureForSelector:`方法
4.  `forwardInvocation:`方法
5.  `doesNotRecognizeSelector:` 方法

11\. runtime如何实现weak变量的自动置nil？知道SideTable吗？
-------------------------------------------

> runtime 对注册的类会进行布局，对于 weak 修饰的对象会放入一个 hash 表中。 用 weak 指向的对象内存地址作为 key，当此对象的引用计数为0的时候会 dealloc，假如 weak 指向的对象内存地址是a，那么就会以a为键， 在这个 weak 表中搜索，找到所有以a为键的 weak 对象，从而设置为 nil。

**更细一点的回答：**

> 1.初始化时：runtime会调用objc\_initWeak函数，初始化一个新的weak指针指向对象的地址。  
> 2.添加引用时：objc\_initWeak函数会调用objc\_storeWeak() 函数， objc\_storeWeak() 的作用是更新指针指向，创建对应的弱引用表。  
> 3.释放时,调用clearDeallocating函数。clearDeallocating函数首先根据对象地址获取所有weak指针地址的数组，然后遍历这个数组把其中的数据设为nil，最后把这个entry从weak表中删除，最后清理对象的记录。

> SideTable结构体是负责管理类的引用计数表和weak表，

详解：参考自《Objective-C高级编程》一书 **1.初始化时：runtime会调用objc\_initWeak函数，初始化一个新的weak指针指向对象的地址。**

    {
        NSObject *obj = [[NSObject alloc] init];
        id __weak obj1 = obj;
    }
    复制代码

当我们初始化一个weak变量时，runtime会调用 NSObject.mm 中的objc\_initWeak函数。

    // 编译器的模拟代码
     id obj1;
     objc_initWeak(&obj1, obj);
    /*obj引用计数变为0，变量作用域结束*/
     objc_destroyWeak(&obj1);
    复制代码

通过`objc_initWeak`函数初始化“附有weak修饰符的变量（obj1）”，在变量作用域结束时通过`objc_destoryWeak`函数释放该变量（obj1）。

**2.添加引用时：objc\_initWeak函数会调用objc\_storeWeak() 函数， objc\_storeWeak() 的作用是更新指针指向，创建对应的弱引用表。**

`objc_initWeak`函数将“附有weak修饰符的变量（obj1）”初始化为0（nil）后，会将“赋值对象”（obj）作为参数，调用`objc_storeWeak`函数。

    obj1 = 0；
    obj_storeWeak(&obj1, obj);
    复制代码

也就是说：

> weak 修饰的指针默认值是 nil （在Objective-C中向nil发送消息是安全的）

然后`obj_destroyWeak`函数将0（nil）作为参数，调用`objc_storeWeak`函数。

    objc_storeWeak(&obj1, 0);
    复制代码

前面的源代码与下列源代码相同。

    // 编译器的模拟代码
    id obj1;
    obj1 = 0;
    objc_storeWeak(&obj1, obj);
    /* ... obj的引用计数变为0，被置nil ... */
    objc_storeWeak(&obj1, 0);
    复制代码

`objc_storeWeak`函数把第二个参数的赋值对象（obj）的内存地址作为键值，将第一个参数\_\_weak修饰的属性变量（obj1）的内存地址注册到 weak 表中。如果第二个参数（obj）为0（nil），那么把变量（obj1）的地址从weak表中删除。

> 由于一个对象可同时赋值给多个附有\_\_weak修饰符的变量中，所以对于一个键值，可注册多个变量的地址。

可以把`objc_storeWeak(&a, b)`理解为：`objc_storeWeak(value, key)`，并且当key变nil，将value置nil。在b非nil时，a和b指向同一个内存地址，在b变nil时，a变nil。此时向a发送消息不会崩溃：在Objective-C中向nil发送消息是安全的。

**3.释放时,调用clearDeallocating函数。clearDeallocating函数首先根据对象地址获取所有weak指针地址的数组，然后遍历这个数组把其中的数据设为nil，最后把这个entry从weak表中删除，最后清理对象的记录。**

当weak引用指向的对象被释放时，又是如何去处理weak指针的呢？当释放对象时，其基本流程如下：

> 1.调用objc\_release  
> 2.因为对象的引用计数为0，所以执行dealloc  
> 3.在dealloc中，调用了\_objc\_rootDealloc函数  
> 4.在\_objc\_rootDealloc中，调用了object\_dispose函数  
> 5.调用objc\_destructInstance  
> 6.最后调用objc\_clear\_deallocating

对象被释放时调用的objc\_clear\_deallocating函数:

> 1.从weak表中获取废弃对象的地址为键值的记录  
> 2.将包含在记录中的所有附有 weak修饰符变量的地址，赋值为nil  
> 3.将weak表中该记录删除  
> 4.从引用计数表中删除废弃对象的地址为键值的记录

**总结:**

其实Weak表是一个hash（哈希）表，Key是weak所指对象的地址，Value是weak指针的地址（这个地址的值是所指对象指针的地址）数组。

12.isKindOfClass 与 isMemberOfClass
----------------------------------

下面代码输出什么？

    @interface Sark : NSObject
    @end
    @implementation Sark
    @end
    int main(int argc, const char * argv[]) {
        @autoreleasepool {
            BOOL res1 = [(id)[NSObject class] isKindOfClass:[NSObject class]];
            BOOL res2 = [(id)[NSObject class] isMemberOfClass:[NSObject class]];
            BOOL res3 = [(id)[Sark class] isKindOfClass:[Sark class]];
            BOOL res4 = [(id)[Sark class] isMemberOfClass:[Sark class]];
            NSLog(@"%d %d %d %d", res1, res2, res3, res4);
        }
        return 0;
    }
    复制代码

> 1000

详解：

在`isKindOfClass`中有一个循环，先判断`class`是否等于`meta class`，不等就继续循环判断是否等于`meta class`的`super class`，不等再继续取`super class`，如此循环下去。

`[NSObject class]`执行完之后调用`isKindOfClass`，第一次判断先判断`NSObject`和 `NSObject`的`meta class`是否相等，之前讲到`meta class`的时候放了一张很详细的图，从图上我们也可以看出，`NSObject`的`meta class`与本身不等。接着第二次循环判断`NSObject`与`meta class`的`superclass`是否相等。还是从那张图上面我们可以看到：`Root class(meta)` 的`superclass`就是 `Root class(class)`，也就是NSObject本身。所以第二次循环相等，于是第一行res1输出应该为YES。

同理，`[Sark class]`执行完之后调用`isKindOfClass`，第一次for循环，Sark的`Meta Class`与`[Sark class]`不等，第二次for循环，`Sark Meta Class`的`super class` 指向的是 `NSObject Meta Class`， 和`Sark Class`不相等。第三次for循环，`NSObject Meta Class`的`super class`指向的是`NSObject Class`，和 `Sark Class` 不相等。第四次循环，`NSObject Class` 的`super class` 指向 nil， 和 `Sark Class`不相等。第四次循环之后，退出循环，所以第三行的res3输出为NO。

`isMemberOfClass`的源码实现是拿到自己的isa指针和自己比较，是否相等。 第二行isa 指向 `NSObject` 的 `Meta Class`，所以和 `NSObject Class`不相等。第四行，isa指向Sark的`Meta Class`，和`Sark Class`也不等，所以第二行res2和第四行res4都输出NO。

13.使用runtime Associate方法关联的对象，需要在主对象dealloc的时候释放么？
--------------------------------------------------

> 无论在MRC下还是ARC下均不需要，被关联的对象在生命周期内要比对象本身释放的晚很多，它们会在被 NSObject -dealloc 调用的object\_dispose()方法中释放。

详解：

    1、调用 -release ：引用计数变为零
    对象正在被销毁，生命周期即将结束. 
    不能再有新的 __weak 弱引用，否则将指向 nil.
    调用 [self dealloc]
    
    2、 父类调用 -dealloc 
    继承关系中最直接继承的父类再调用 -dealloc 
    如果是 MRC 代码 则会手动释放实例变量们（iVars）
    继承关系中每一层的父类 都再调用 -dealloc
    
    >3、NSObject 调 -dealloc 
    只做一件事：调用 Objective-C runtime 中object_dispose() 方法
    
    >4. 调用 object_dispose()
    为 C++ 的实例变量们（iVars）调用 destructors
    为 ARC 状态下的 实例变量们（iVars） 调用 -release 
    解除所有使用 runtime Associate方法关联的对象 
    解除所有 __weak 引用 
    调用 free()
    复制代码

14\. 什么是method swizzling（俗称黑魔法)
-------------------------------

> 简单说就是进行方法交换

在Objective-C中调用一个方法，其实是向一个对象发送消息，查找消息的唯一依据是selector的名字。利用Objective-C的动态特性，可以实现在运行时偷换selector对应的方法实现，达到给方法挂钩的目的。

每个类都有一个方法列表，存放着方法的名字和方法实现的映射关系，selector的本质其实就是方法名，IMP有点类似函数指针，指向具体的Method实现，通过selector就可以找到对应的IMP。

换方法的几种实现方式

*   利用 method\_exchangeImplementations 交换两个方法的实现
*   利用 class\_replaceMethod 替换方法的实现
*   利用 method\_setImplementation 来直接设置某个方法的IMP

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c7e795cf14e449f2a3df36fbd05a9f61~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

15.Compile Error / Runtime Crash / NSLog…?
------------------------------------------

下面的代码会？`Compile Error` / `Runtime Crash` / `NSLog…`?

    @interface NSObject (Sark)
    + (void)foo;
    - (void)foo;
    @end
    
    @implementation NSObject (Sark)
    - (void)foo {
        NSLog(@"IMP: -[NSObject (Sark) foo]");
    }
    @end
    
    // 测试代码
    [NSObject foo];
    [[NSObject new] performSelector:@selector(foo)];
    复制代码

> IMP: -\[NSObject(Sark) foo\] ，全都正常输出，编译和运行都没有问题。

详解：

这道题和上一道题很相似，第二个调用肯定没有问题，第一个调用后会从元类中查找方法，然而方法并不在元类中，所以找元类的`superclass`。方法定义在是`NSObject`的`Category`，由于`NSObject`的对象模型比较特殊，元类的`superclass`是类对象，所以从类对象中找到了方法并调用。