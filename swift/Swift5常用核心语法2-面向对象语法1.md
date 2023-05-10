# Swift5常用核心语法2-面向对象语法1

一、概述
====

最近刚好有空,趁这段时间,复习一下`Swift5`核心语法,进行知识储备,以供日后温习 和 进一步探索`Swift`语言的底层原理做铺垫。

本文继上一篇文章[Swift5核心语法1-基础语法](https://juejin.cn/post/7119020967430455327 "https://juejin.cn/post/7119020967430455327")之后,继续复习`面向对象语法`

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a03e517565e54fa6895098e060598486~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

二、结构体
=====

1\. 基本概念
--------

*   在Swift**标准库中，绝大多数的公开类型都是结构体**，而**枚举和类只占很小一部分**
    *   比如`Bool、Int、String、Double、Array、Dictionary`等常见类型都是结构体
        
                struct Date {
                    var year: Int
                    var month: Int
                    var day: Int
                }
                var date = Date(year: 2019, month: 6, day: 23)
            复制代码
        
*   所有的结构体**都有一个编译器自动生成的初始化器**（`initializer`，初始化方法、构造器、构造方法）
    *   通过默认生成的初始化器初始化:传入所有成员值，用以初始化所有成员（`存储属性`，`Stored Property`）
        
               var date = Date(year: 2019, month: 6, day: 23)
            复制代码
        

2\. 结构体的初始化器
------------

*   编译器会根据情况，可能会为结构体生成多个初始化器，宗旨是：`保证所有成员都有初始值`
*   如果结构体的成员定义的时候都有默认值了，那么生成的初始化器不会报错 ![-w569](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c7f34e0c903b4112a1a603c46665c4ae~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    *   如果是下面这几种情况就会报错 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e364616dd6c944f28d5ab613284d4403~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/189bf09fbbf248df8396eaa8a9b74c33~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/de06012b6cec46dabe604d027cd1654a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    *   如果是可选类型的初始化器也不会报错，因为可选类型默认的值就是`nil` ![-w457](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1a73b4ae9ef8415ab4c5b3de861cd5fa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3\. 自定义初始化器
-----------

我们也可以自定义初始化器

    struct Point {
        var x: Int = 0
        var y: Int = 0
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
    } 
    var p1 = Point(x: 10, y: 10)
    复制代码

下面对变量`p2`、`p3`、`p4`初始化报错的原因是 因为我们 **`已经自定义初始化器了，编译器就不会再帮我们生成默认的初始化器了`** ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/da74440857c645b6990bc678cf0ab2f2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4\. 初始化器的本质
-----------

下面这两种写法是完全等效的

    struct Point {
        var x: Int = 0
        var y: Int = 0
    } 
    等效于 
    struct Point {
        var x: Int
        var y: Int
        
        init() {
            x = 0
            y = 0
        }
    } 
    var p4 = Point()
    复制代码

*   我们通过反汇编分别对比一下两种写法的实现，发现也是一样的:
*   因此,我们不难得出结论:  
    默认初始化器的本质,就是给存储属性做了默认赋值工作(比如这里给Int类型的两个属性默认赋值为`0`) ![-w713](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bde85343b7e74b75a53d605462260979~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w715](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a431a9e76973412dbfe8e6014d9bc01a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

5.结构体的内存结构
----------

1.  **我们通过打印,了解下结构体占用的内存大小 和 其 内存布局**

    struct Point {
        var x: Int = 10
        var y: Int = 20
    } 
    var p4 = Point() 
    print(MemoryLayout<Point>.stride) // 16
    print(MemoryLayout<Point>.size) // 16
    print(MemoryLayout<Point>.alignment) // 8
    
    print(Mems.memStr(ofVal: &p4)) // 0x000000000000000a 0x0000000000000014
    复制代码

通过控制台,我们可以看到:

*   系统一共分配了`16`个字节的内存空间
*   前8个字节存储的是10，后8个字节存储的是20

2.  我们再看下面这个结构体

    struct Point {
        var x: Int = 10
        var y: Int = 20
        var origin: Bool = false
    }
    
    var p4 = Point()
    
    print(MemoryLayout<Point>.stride) // 24
    print(MemoryLayout<Point>.size) // 17
    print(MemoryLayout<Point>.alignment) // 8
    
    print(Mems.memStr(ofVal: &p4)) // 0x000000000000000a 0x0000000000000014 0x0000000000000000
    复制代码

可以看到:

*   结构体实际只用了17个字节，而因为系统分配有内存对齐的概念,所以分配了24个字节
*   前8个字节存储的是10，中间8个字节存储的是20，最后1个字节存储的是false，也就是0

三、类
===

*   类的定义和结构体类似，但编译器并没有为类自动生成可以传入成员值的初始化器 ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/48faa928fa484b87a2ae3996bbcabac8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   如果成员没有初始值，所有的初始化器都会报错 ![-w648](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f5699df524e743128207ac9c2edbd947~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

1.类的初始化器
--------

*   如果类的所有成员都在定义的时候指定了初始值，编译器会为类生成 **`无参的初始化器`**
*   成员的初始化是在这个初始化器中完成的
    
        class Point {
            var x: Int = 0
            var y: Int = 0
        }
        
        let p1 = Point()
        复制代码
    
    *   下面这两种写法是完全等效的
        
            class Point {
                var x: Int = 0
                var y: Int = 0
            }
            
            等效于
            
            class Point {
                var x: Int
                var y: Int
            
                init() {
                    x = 0
                    y = 0
                }
            }
            
            let p1 = Point()
            复制代码
        

2\. 结构体与类的本质区别
--------------

*   结构体是`值类型`（枚举也是值类型），类是`引用类型`（指针类型）  
    下面我们分析函数内的局部变量分别都在内存的什么位置

    class Size {
        var width = 1
        var height = 2
    } 
    struct Point {
        var x: Int = 3
        var y: Int = 4
    }
    
    func test() {
        var size = Size()
        var point = Point()
    } 
    复制代码

*   `变量`size和point都是在栈空间
*   不同的是`局部变量point`是一个结构体类型。结构体是值类型，结构体变量会在栈空间中分配内存,它里面的两个成员x、y按顺序的排布
*   而`局部指针变量size`是一个类的实例，类是引用类型，所以`size指针`指向的已初始化的变量的存储空间,是在堆中分配的，size指针内部存储的是Size类的实例内存地址 ![-w1020](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/70ea6076fb1548509687cab9ebead2cd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3\. 分析类的内存布局
------------

*   1.  我们先来看一下类的占用内存大小是多少
    
            class Size {
                var width = 1
                var height = 2
            }
            print(MemoryLayout<Size>.stride) // 8
        复制代码
    
    通过打印我们可以发现`MemoryLayout`获取的8个字节实际上是指针变量占用多少存储空间，并不是对象在堆中的占用大小
    
*   2.  然后我们再看类的内存布局是怎样的
    
            var size = Size()
        
            print(Mems.ptr(ofVal: &size)) // 0x000000010000c388
            print(Mems.memStr(ofVal: &size)) // 0x000000010072dba0
        复制代码
    
    通过打印我们可以看到变量里面存储的值也是一个地址
    
*   3.  我们再打印该变量所指向的对象的内存布局是什么
    
            print(Mems.size(ofRef: size)) // 32
            print(Mems.ptr(ofRef: size)) // 0x000000010072dba0
            print(Mems.memStr(ofRef: size)) // 0x000000010000c278 0x0000000200000003 0x0000000000000001 0x0000000000000002
        复制代码
    
    通过打印可以看到在`堆中存储的对象的地址`和上面的`指针变量里存储的值`是一样的
    
    内存布局里一共占用32个字节:
    
    *   前16个字节分别用来存储一些`类信息`和`引用计数`
    *   后面16个字节存储着类的成员变量的值

> **下面我们再从反汇编的角度来分析**

*   我们要想确定类是否在堆空间中分配空间，通过反汇编来查看是否有调用`malloc函数` ![-w708](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7ff9723d317849f1a11137973bd89be3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4a45d9d80a3d43efb61a81f9e475e045~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   然后就一直跟进直到这里最好调用了`swift_slowAlloc` ![-w714](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/65b01d1dd467407f8ebc07a08d1c7d15~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   发现函数内部调用了系统的`malloc`在堆空间分配内存 ![-w709](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6a9514ee0c924446a07710bd1ca2f405~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**注意:**

*   结构体和枚举存储在哪里`取决于它们是在哪里分配`的
    *   如果是在函数中分配的那就是在栈里
    *   如果是在全局中分配的那就是在数据段
*   而类无论是在哪里分配的，对象都是在堆空间中
    *   指向对象内存的指针的存储位置是不确定的，可能在栈中也可能在数据段

> **我们再看下面的`类型`占用内存大小是多少**

    class Size {
        var width: Int = 0
        var height: Int = 0
        var test = true
    }
    
    let s = Size()
    
    print(Mems.size(ofRef: s)) // 48
    复制代码

*   在`Mac、iOS`中的`malloc函数`分配的内存大小总是`16的倍数`
*   类最前面会有`16个字节`用来存储`类的信息`和`引用计数`，所以实际占用内存是`33个字节`，但由于`malloc函数`分配的内存都是刚好大于或等于其所需内存的16最小倍数，所以分配`48个字节`
*   我们还可以通过`class_getInstanceSize`函数来获取类对象的内存大小

    // 获取的是经过内存对齐后的内存大小，不是malloc函数分配的内存大小
    print(class_getInstanceSize(type(of: s))) // 40
    print(class_getInstanceSize(Size.self)) // 40
    复制代码

四、值类型和引用类型
==========

1\. 值类型
-------

*   值类型赋值给`var、let或者给函数`传参，是直接将所有内容`拷贝一份`
*   类似于对文件进行`copy、paste`操作，产生了全新的文件副本，**属于深拷贝（deep copy）**

值类型进行拷贝的内存布局如下所示

    struct Point {
        var x: Int = 3
        var y: Int = 4
    }
    
    func test() {
        var p1 = Point(x: 10, y: 20)
        var p2 = p1
    
        p2.x = 4
        p2.y = 5
    
        print(p1.x, p1.y)
    }
    
    test()
    复制代码

![-w536](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7980c7fea817418aacefb9d17bcf5dba~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**我们通过反汇编来进行分析**

![-w712](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/92f3f7c5f9484dc9933d89ee94a26c59~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/602bd28e6ec6486c9096ab346f49e45e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w713](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9e673c56b74b4d768ebb91a504013d50~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1048](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/238779d785e24cc48720c582d965b587~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上述分析可以发现，值类型的赋值内部会先将p1的成员值保存起来，再给p2进行赋值，所以不会影响到p1

2\. 值类型的赋值操作
------------

*   在Swift标准库中，为了提升性能，`Array、String、Dictionary、Set`采用了`Copy On Write`的技术
*   如果`只是将赋值操作`，那么只会进行`浅拷贝`，两个变量使用的还是同一块存储空间
*   只有当`进行了”写“的操作`时，`才会进行深拷贝`操作
*   对于标准库值类型的赋值操作，Swift能确保最佳性能，所以没必要为了保证最佳性能来避免赋值
*   建议：**不需要修改值的，尽量定义成`let`**

    var s1 = "Jack"
    var s2 = s1
    s2.append("_Rose")
    
    print(s1) // Jack
    print(s2) // Jack_Rose
    复制代码

    var a1 = [1, 2, 3]
    var a2 = a1
    a2.append(4)
    a1[0] = 2
    
    print(a1) // [2, 2, 3]
    print(a2) // [1, 2, 3, 4]
    复制代码

    var d1 = ["max" : 10, "min" : 2]
    var d2 = d1
    d1["other"] = 7
    d2["max"] = 12
    
    print(d1) // ["other" : 7, "max" : 10, "min" : 2]
    print(d2) // ["max" : 12, "min" : 2]
    复制代码

**我们再看下面这段代码**  
对于p1来说，再次赋值也只是覆盖了成员`x、y`的值而已，都是同一个结构体变量

    struct Point {
        var x: Int
        var y: Int
    }
    var p1 = Point(x: 10, y: 20)
    p1 = Point(x: 11, y: 22)
    复制代码

**用let定义的赋值操作**

*   如果用`let`定义的常量赋值结构体类型会报错，并且修改结构体里的成员值也会报错
*   用`let`定义就意味着常量里存储的值不可更改，而结构体是由x和y这16个字节组成的，所以更改x和y就意味着结构体的值要被覆盖，所以报错

![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/02bc9cd358654834ae915998e2e45480~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3\. 引用类型
--------

*   引用赋值给`var、let或者给函数`传参，是将`内存地址拷贝一份`
*   类似于制作一个文件的替身（快捷方式、链接），指向的是同一个文件，属于 **`浅拷贝（shallow copy）`**
    
        class Size {
            var width = 0
            var height = 0
        
            init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }
        }
        
        func test() {
            var s1 = Size(width: 10, height: 20)
            var s2 = s1
        
            s2.width = 11
            s2.height = 22
        
            print(s1.height, s1.width)
        }
        
        test() 
        复制代码
    

由于s1和s2都指向的同一块存储空间，所以s2修改了成员变量，s1再调用成员变量也已经是改变后的了 ![-w1124](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3356c841c72c4fac841aa1dbf256f8cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> **我们通过反汇编来进行分析** ![-w1049](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b45ca53a5f0d46eb8eb3a28d3621a036~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1052](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/945d409630314dbcad7255cb126579f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1052](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5d1e1886aa3e48c590dcf63cf5882594~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   堆空间分配完内存之后，我们拿到`rax`的值查看内存布局
*   发现`rax`里和对象的结构一样，证明`rax`里存储的就是对象的地址 ![-w1051](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/704284210812484c9c6486811ee37673~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1187](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e9317bf166a4951a7755e6c8919506c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   将新的值11和22分别覆盖掉堆空间对象的成员值 ![-w1223](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/02b760674c0b45d38d11a9a86e1e8c40~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1224](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0643e6cb5cec4763aef3a0fa65a57c04~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1220](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/af6b9af0b43c4511887caf319cde7327~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1225](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/31c388e409914d1f8e4e2a526833b208~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上面的分析可以发现，修改的成员值都是改的同一个地址的对象，所以修改了p2的成员值，会影响到p1

4\. 对象的堆空间申请过程
--------------

*   **在Swift中，创建类的实例对象，要向堆空间申请内存，大概流程如下**
    *   `Class.__allocating_init()`
    *   libswiftCore.dylib:`_swift_allocObject_`
    *   libswiftCore.dylib:`swift_slowAlloc`
    *   libsystem\_malloc.dylib:`malloc`
*   在Mac、iOS中的`malloc`函数分配的内存大小总是16的倍数
*   通过`class_getInstanceSize`可以得知：类的对象至少需要占用多少内存
    
        class Point{
            var x = 11
            var test = true
            var y = 22
        } 
        var p = Point() 
        class_getInstanceSize(type(of: p)) // 40 
        class_getInstanceSize(Point.self) // 40
        复制代码
    

5\. 引用类型的赋值操作
-------------

*   1.  将引用类型初始化对象赋值给同一个指针变量，指针变量会指向另一块存储空间
    
        class Size {
            var width: Int
            var height: Int
        
            init(width: Int, height: Int) {
                self.width = width
                self.height = height
            }
        }
        
        var s1 = Size(width: 10, height: 20)
        s1 = Size(width: 11, height: 22)
        复制代码
    

> **用let定义的赋值操作**

*   2.  如果用`let`定义的常量赋值引用类型会报错，因为会改变指针常量里存储的8个字节的地址值
*   3.  但修改类里的属性值不会报错，因为修改属性值并不是修改的指针常量的内存，只是通过指针常量找到类所存储的堆空间的内存地址去修改类的属性 ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/83dccdb5d2be4945807070fcac919b0c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

6\. 嵌套类型
--------

    struct Poker {
        enum Suit: Character {
            case spades = "♠️",
                 hearts = "♥️",
                 diamonds = "♦️",
                 clubs = "♣️"
        }
        
        enum Rank: Int {
            case two = 2, three, four, five, six, seven, eight, nine, ten
            case jack, queen, king, ace
        }
    }
    
    print(Poker.Suit.hearts.rawValue)
    
    var suit = Poker.Suit.spades
    suit = .diamonds
    
    var rank = Poker.Rank.five
    rank = .king 
    复制代码

7\. 枚举、结构体、类都可以定义方法
-------------------

*   1.  一般把定义在枚举、结构体、类内部的函数，叫做方法
    
        struct Point {
            var x: Int = 10
            var y: Int = 10
        
            func show() {
                print("show")
            }
        }
        
        let p = Point()
        p.show()
        
        复制代码
    
        class Size {
            var width: Int = 10
            var height: Int = 10
        
            func show() {
                print("show")
            }
        }
        
        let s = Size()
        s.show()
        
        复制代码
    
        enum PokerFace: Character {
            case spades = "♠️",
                 hearts = "♥️",
                 diamonds = "♦️",
                 clubs = "♣️"
        
            func show() {
                print("show")
            }
        }
        
        let pf = PokerFace.hearts
        pf.show()
        
        复制代码
    
*   2.  方法不管放在哪里，其内存都是放在代码段中
*   3.  枚举、结构体、类里的方法其实会有隐式参数
    
        class Size {
            var width: Int = 10
            var height: Int = 10
        
            // 默认会有隐式参数，该参数类型为当前枚举、结构体、类
            func show(self: Size) {
                print(self.width, self.height)
            }
        }
        复制代码
    

六、属性
====

1\. 属性的基本概念
-----------

Swift中跟实例相关的属性可以分为2大类:

*   **`存储属性`**（Stored Property）
    *   类似于成员变量的概念
    *   存储在实例的内存中
    *   结构体、类可以定义存储属性
    *   枚举`不可以`定义存储属性
*   **`计算属性`**（Computed Property）
    *   本质就是方法（函数）
    *   不占用实例的内存
    *   枚举、结构体、类都可以定义计算属性

### 1.1 存储属性

关于存储属性，Swift有个明确的规定:

*   在创建类或结构体的实例时，**必须为所有的存储属性设置一个合适的初始值**
    *   可以在初始化器里为存储属性设置一个初始值
        
            struct Point {
                // 存储属性
                var x: Int
                var y: Int
            } 
            let p = Point(x: 10, y: 10) 
            复制代码
        
    *   可以分配一个默认的属性值作为属性定义的一部分
        
            struct Point {
                // 存储属性
                var x: Int = 10
                var y: Int = 10
            } 
            let p = Point() 
            复制代码
        

### 1.2 计算属性

定义计算属性只能用`var`，不能用`let`

*   `let`代表常量，值是一直不变的
*   计算属性的值是可能发生变化的（即使是只读计算属性）
    
        struct Circle {
            // 存储属性
            var radius: Double 
            // 计算属性
            var diameter: Double {
                set {
                    radius = newValue / 2
                } 
                get {
                    radius * 2
                }
            }
        }
        
        var circle = Circle(radius: 5)
        print(circle.radius) // 5.0
        print(circle.diameter) // 10.0
        
        circle.diameter = 12
        print(circle.radius) // 6.0
        print(circle.diameter) // 12.0
        复制代码
    
*   set传入的新值默认叫做`newValue`，也可以自定义
    
        struct Circle {
            // 存储属性
            var radius: Double 
            // 计算属性
            var diameter: Double {
                set(newDiameter) {
                    radius = newDiameter / 2
                } 
                get {
                    radius * 2
                }
            }
        } 
        var circle = Circle(radius: 5)
        circle.diameter = 12
        print(circle.diameter) 
        复制代码
    
*   只读计算属性，只有`get`，没有`set`
    
        struct Circle {
            // 存储属性
            var radius: Double 
            // 计算属性
            var diameter: Double {
                get {
                    radius * 2
                }
            }
        } 
        复制代码
    
        struct Circle {
            // 存储属性
            var radius: Double 
            // 计算属性
            var diameter: Double { radius * 2 }
            }
        } 
        复制代码
    
*   打印`Circle结构体`的内存大小，其占用才`8个字节`，其本质是因为计算属性相当于函数
    
        var circle = Circle(radius: 5)
        print(Mems.size(ofVal: &circle)) // 8
        复制代码
    

> **我们可以通过反汇编来查看其内部做了什么**

*   可以看到内部会调用`set方法`去计算 ![-w723](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cff94714670464aaf1eef4af8da8e12~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   然后我们在往下执行，还会看到`get方法`的调用 ![-w722](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3a9c5db06a704c67bc497a8ca021731e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   所以可以用此证明:计算属性只会生成`getter`和`setter`,不会开辟内存空间

**注意：**

*   一旦将存储属性变为计算属性，初始化构造器就会报错，只允许传入存储属性的值
*   因为存储属性是直接存储在结构体内存中的，如果改成计算属性则不会分配内存空间来存储 ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e864fd3b6104be586e659d1e1f1b02b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w525](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc57b13c70a0424ebbf7f6df42150499~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   如果只有`setter`也会报错 ![-w651](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/510b7dcc067d4d73a7ecc95efd8c7992~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   只读计算属性：只有`get`，没有`set`
    
        struct Circle {
            var radius: Double 
            var diameter: Double { 
                get { 
                    radius * 2 
                }
            } 
        }
        //可以简写成
        struct Circle {
            var radius: Double 
            var diameter: Double { radius * 2  } 
        }
        复制代码
    

2\. 枚举rawValue原理(计算属性)
----------------------

*   1.  枚举原始值`rawValue`的本质也是计算属性，而且是只读的计算属性
    
        enum TestEnum: Int {
            case test1, test2, test3
        
            var rawValue: Int {
                switch self {
                case .test1:
                    return 10
                case .test2:
                    return 20
                case .test3:
                    return 30
                }
            }
        } 
        print(TestEnum.test1.rawValue)//10
        复制代码
    
*   2.  下面我们去掉自己写的`rawValue`，然后转汇编看下本质是什么样的
    
    *   可以看到底层确实是调用了`getter`
    
            enum TestEnum: Int {
                case test1, test2, test3
            }
        
            print(TestEnum.test1.rawValue)
        复制代码
    
    ![-w717](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6ba17ae69a634b95941c98bd85d2785e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3\. 延迟存储属性（Lazy Stored Property）
--------------------------------

*   1.  使用`lazy`可以定义一个延迟存储属性，在`第一次用到属性的时候才会进行初始化`
    
    *   看下面的示例代码，如果不加`lazy`，那么Person初始化之后就会进行Car的初始化
    *   加上`lazy`，只有调用到属性的时候才会进行Car的初始化
    
        class Car {
            init() {
                print("Car init!")
            }
        
            func run() {
                print("Car is running!")
            }
        }
        
        class Person {
            lazy var car = Car()
        
            init() {
                print("Person init!")
            }
        
            func goOut() {
                car.run()
            }
        }
        
        let p = Person()
        print("----")
        p.goOut()
        
        // 打印：
        // Person init!
        // ----
        // Car init!
        // Car is running!
        复制代码
    
*   2.  `lazy`属性必须是`var`，不能是`let`  
        `let`必须在实例的初始化方法完成之前就拥有值
    
        class PhotoView {
            lazy var image: UIImage = {
                let url = "http://www.***.com/logo.png"
                let data = Data(url: url)
                return UIImage(data: data)
            }()
        } 
        复制代码
    
*   3.  **注意：** `lazy`属性和普通的存储属性内存布局是一样的，不同的只是什么分配内存的时机,而且lazy属性可以通过闭包进行初始化
*   4.  **延迟存储属性的注意点**
    
    *   1.如果多条线程同时第一次访问`lazy`属性，**无法保证属性只被初始化一次**
    *   2.当结构体包含一个延迟存储属性时，只有`var`才能访问延迟存储属性  
        因为延迟存储属性初始化时需要改变结构体的内存 ![-w652](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7d9eacdd4db540e7ab7cc23398bdb62c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4.属性观察器（Property Observer）
--------------------------

*   1.  可以为非`lazy`的`var存储属性`设置属性观察器
    
    *   只有存储属性可以设置属性观察器
    *   `willSet`会传递新值，默认叫`newValue`
    *   `didSet`会传递旧值，默认叫`oldValue`
    
        struct Circle {
            // 存储属性
            var radius: Double {
                willSet {
                    print("willSet", newValue)
                }
        
                didSet {
                    print("didSet", oldValue, radius)
                }
            }
        
            init() {
                radius = 1.0
                print("Circle init!")
            }
        }
        
        var circle = Circle()
        circle.radius = 10.5
        
        // 打印
        // willSet 10.5
        // didSet 1.0 10.5 
        复制代码
    
*   2.  在初始化器中设置属性值不会触发`willSet`和`didSet`
    
        struct Circle {
            // 存储属性
            var radius: Double {
                willSet {
                    print("willSet", newValue)
                }
        
                didSet {
                    print("didSet", oldValue, radius)
                }
            }
        
            init() {
                radius = 1.0
                print("Circle init!")
            }
        }
        
        var circle = Circle() 
        复制代码
    
*   3.  在属性定义时设置初始值也不会触发`willSet`和`didSet`
    
        struct Circle {
            // 存储属性
            var radius: Double = 1.0 {
                willSet {
                    print("willSet", newValue)
                }
        
                didSet {
                    print("didSet", oldValue, radius)
                }
            }
        }
        
        var circle = Circle()
        复制代码
    
*   4.  计算属性设置属性观察器会报错 ![-w657](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f0cb0a9d0e0e45858fa53006840c92ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

5\. 全局变量和局部变量
-------------

*   1.  属性观察器、计算属性的功能，同样可以应用在全局变量和局部变量身上

### 5.1 全局变量

    var num: Int {
        get {
            return 10
        }
        
        set {
            print("setNum", newValue)
        }
    }
    
    num = 11 // setNum 11
    print(num) // 10 
    复制代码

### 5.2 局部变量

    func test() {
        var age = 10 {
            willSet {
                print("willSet", newValue)
            }
            
            didSet {
                print("didSet", oldValue, age)
            }
        }
            
        age = 11
        // willSet 11
        // didSet 10 11
    }
    
    test() 
    复制代码

6\. inout对属性的影响
---------------

看下面的示例代码，分别输出什么，为什么？

    struct Shape { 
        var width: Int   
        var side: Int { 
            willSet { 
                print("willSet", newValue) 
            }
      
            didSet { 
                print("didSet", oldValue, side) 
            } 
        }
    
        
    
        var girth: Int { 
            set { 
                width = newValue / side 
                print("setGirth", newValue) 
            }  
    
            get { 
                print("getGirth") 
                return width * side 
            } 
        }
    
        
    
        func show() { 
            print("width=\(width), side=\(side), girth=\(girth)") 
        } 
    } 
    
    func test(_ num: inout Int) { 
        num = 20 
    }
     
    
    var s = Shape(width: 10, side: 4) 
    test(&s.width) 
    s.show()
     
    print("--------------------")   
    test(&s.side)
    
    s.show() 
    print("--------------------") 
    test(&s.girth) 
    s.show()
     
    
    // 打印: 
    //getGirth 
    //width=20, side=4, girth=80 
    //-------------------- 
    //willSet 20 
    //didSet 4 20 
    //getGirth 
    //width=20, side=20, girth=400 
    //-------------------- 
    //getGirth 
    //setGirth 20 
    //getGirth 
    //width=1, side=20, girth=20 
    复制代码

**第一段打印**  
初始化的时候会给width赋值为10，side赋值为4，并且不会调用side的属性观察器  
然后调用`test方法`，并传入width的地址值，width变成20  
然后调用`show方法`，会调用girth的getter，然后先执行打印，再计算，girth为80

**下面我们通过反汇编来进行分析** ![-w963](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5fc1d06411345e48b5298b546fc5eb5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w963](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4b1df2fda6114e7797c514b125c72220~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w965](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a8030cdce64e4915a42fe6e740e88470~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w807](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/77f27418b516496fae9563a089f7c8ba~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**第二段打印**  
现在width的值是20，side的值是4，girth的值是80  
然后调用`test方法`，并传入side的地址值，side变成20，并且触发属性观察器，执行打印  
然后调用`show方法`，会调用girth的getter，然后先执行打印，再计算，girth为400

**下面我们通过反汇编来进行分析**

![-w960](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2308139e5ef84fdfbe0529d07bbb728e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w351](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4016c951c10349d9b321482156ed3e06~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

将地址值存储到`rdi`中，并带入到`test`函数中进行计算

![-w959](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dc6c66b5d9d94477b8f3ec45a7fd7163~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w960](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18619de80d5e4433bff1110585cbc391~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w870](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fef68a991f484726b25c6404faa16aea~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   `setter`中才会真正的调用`willSet`和`didSet`方法
*   `willSet`和`didSet`之间的计算才是真正的将改变了的值覆盖了全局变量里的side
*   真正改变了side的值的时候是调用完`test函数`之后，在内部的`setter`里进行的

**第三段打印**  
现在width的值是20，side的值是20，girth的值是400  
然后调用`test方法`，并传入girth的getter的返回值为400，然后将20赋值给girth的setter计算，width变为1  
然后调用`show方法`，，会调用girth的getter，然后先执行打印，再计算，girth为20

**下面我们通过反汇编来进行分析**

![-w962](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fe71f0becd65491781c3db4c04ae8f24~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w371](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f44242dece54d9b8d0fddefdffd28c1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w961](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b9cc4aea2fd4feb863dbc9aedbf2f6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w963](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/230104d8a6ad497e84dca4ed40986ccd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w425](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4403db87443f44809960b4682a8f0491~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w958](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/31f115cc2baa4beebaa466923e5d557b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w399](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e096666a8f494dbc9ee87abcc9bef9bf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w961](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/10c3f0965b924847bce7b803acedfb15~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w675](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/64be28706705430a92d02e3e1b215f6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w963](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/624c73ef789a4b5da1b726eba248ce35~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w614](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/15246ce5ef6449e58c2566ba6fe15274~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w960](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/84cee3a22fcf45549921a6f894884adc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w822](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/de8c1f3d95d84590a6ac010cb595160d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w961](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6fa014e3ab3844b0bc76d2151fb12b55~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w958](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9efe2dbf0df44b579ebb387633cce472~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w837](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8ac8d16badd5455fbea46d694f74f6ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

再后面都是计算的过程了，这里就不详细跟进了

我们主要了解`inout`是怎么给计算属性进行关联调用的，从上面分析可以看出:

*   从调用girth的`getter`开始，都会将计算的结果放入一个寄存器中
*   然后通过这个寄存器的地址再进行传递
*   `inout`影响的也是修改这个寄存器中存储的值，然后再进一步传递到`setter`里进行计算

> **`inout的本质总结`**

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c080e2c15d74ed0b322d1d646e43026~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**对于没有属性观察器的`存储属性`来说:**

*   `inout`的本质就是传进来一个`地址值`，然后将值存储到这个地址对应的存储空间内

**对于设置了属性观察器和`计算属性`来说:**

*   `inout`会先将传进来的地址值放到一个局部变量中，然后改变局部变量地址值对应的存储空间
    
*   再将改变了的局部变量值覆盖最初传进来的参数的值
    
    *   这时会对应触发属性观察器`willSet、didSet`和计算属性的`setter、getter`的调用
*   如果不这么做，直接就改变了传进来的地址值的存储空间的话，就不会调用属性观察器了，而计算属性因为没有分配内存来存储值，也就没办法更改了
    
*   **总结:`inout`的本质就是引用传递（地址传递）**
    

7\. 类型属性（Type Property）
-----------------------

*   1.  严格来说，属性可以分为两大类:
    
    *   实例属性(Instance Property):只能通过实例去访问
        *   存储实例属性(Stored Instance Property):存储在实例的内存中，每个实例都有一份
        *   计算实例属性(Computed Instance Property)
    *   类型属性(Type Property):只能通过类去访问
        *   存储类型属性(Stored Type Property):整个程序运行过程中，就只有一份内存（类似于全局变量）
        *   计算类型属性(Computed Type Property)
*   2.  可以通过`static`定义类型属性
    
        struct Car {
            static var count: Int = 0
            init() {
                Car.count += 1
            }
        } 
        复制代码
    
*   3.  如果是类，也可以用关键字`class`修饰`计算属性类型`
    
        class Car {
            class var count: Int {
                return 10
            }
        } 
        print(Car.count) 
        复制代码
    
*   4.  类里面不能用`class`修饰`存储属性类型` ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e4adf6e0bd24884ba8f7449bb50ea73~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> 类型属性细节

*   不同于`存储实例属性`，`存储类型属性`**必须设定初始值**，不然会报错
*   因为类型没有像实例那样的`init初始化器`来初始化存储属性 ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fa55c7ff16054344b1687daea819fbd9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   `存储类型属性`可以用`let`
    
        struct Car {
            static let count: Int = 0 
        } 
        print(Car.count) 
        复制代码
    
*   枚举类型也可以定义类型属性（`存储类型属性`、`计算类型属性`）
    
        enum Shape {
            static var width: Int = 0
            case s1, s2, s3, s4
        } 
        var s = Shape.s1
        Shape.width = 5 
        复制代码
    
*   `存储类型属性`默认就是`lazy`，会在第一次使用的时候进行初始化
    *   就算被多个线程同时访问，保证只会初始化一次

> **通过反汇编来分析类型属性的底层实现**

我们先通过打印下面两组代码来做对比，发现存储类型属性的内存地址和前后两个全局变量正好相差8个字节，所以可以证明存储类型属性的本质就是类似于全局变量，只是放在了结构体或者类里面控制了访问权限:

    var num1 = 5
    var num2 = 6
    var num3 = 7
    
    print(Mems.ptr(ofVal: &num1)) // 0x000000010000c1c0
    print(Mems.ptr(ofVal: &num2)) // 0x000000010000c1c8
    print(Mems.ptr(ofVal: &num3)) // 0x000000010000c1d0
    复制代码

    var num1 = 5
    
    class Car {
        static var count = 1
    }
    
    Car.count = 6
    
    var num3 = 7
    
    print(Mems.ptr(ofVal: &num1)) // 0x000000010000c2f8
    print(Mems.ptr(ofVal: &Car.count)) // 0x000000010000c300
    print(Mems.ptr(ofVal: &num3)) // 0x000000010000c308
    复制代码

然后我们通过反汇编来观察: ![-w1086](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29f41f886ace4c11b2ec6996ace3668a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1086](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3fb52597aea24166872d4a77051d4100~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1085](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e597aad70a124c28b7ecd3eb2d735f2c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w508](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95036cbba74246ba85a028c66ffba1c7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1086](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5ab7bdb03dcf49f3907b2ee304181df8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过调用我们可以发现最后会调用到`GCD`的`dispatch_once`，所以存储类型属性才会说是线程安全的，并且只执行一次

并且`dispatch_once`里面执行的代码就是`static var count = 1`

8.单例模式
------

    public class FileManager {
        public static let shared = FileManager()
        private init() { }
        
        public func openFile() {
            
        }
    }
    
    FileManager.shared.openFile()
    复制代码

* * *

七、方法（Method）
============

1\. 基本概念
--------

枚举、结构体、类都可以定义`实例方法`、`类型方法`

*   实例方法（`Instance Method`）: 通过实例对象调用
*   类型方法（`Type Method`）: 通过类型调用
    *   实例方法调用
        
            class Car {
                var count = 0
            
                func getCount() -> Int {
                    count
                }
            }
            
            let car = Car()
            car.getCo 
            复制代码
        
    *   类型方法用`static`或者`class`关键字定义
        
            class Car {
                static var count = 0
            
                static func getCount() -> Int {
                    count
                }
            }
            
            Car.getCount() 
            复制代码
        
    *   类型方法中不能调用实例属性，反之实例方法中也不能调用类型属性 ![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/821ce590fc79410586ee545f4fb7a6e7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/34b3768d7ca04c149eab2017d5cffe29~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   不管是类型方法还是实例方法，都会传入隐藏参数`self`
*   `self`在实例方法中代表实例对象
*   `self`在类型方法中代表类型
    
        // count等于self.count、Car.self.count、Car.count
        static func getCount() -> Int {
            self.count
        } 
        复制代码
    

2\. mutating
------------

*   `结构体`和`枚举`是`值类型`,默认情况下,值类型的属性不能被自身的实例方法修改
*   在`func`关键字前面加上`mutating`可以允许这种修改行为
    
        struct Point {
            var x = 0.0, y = 0.0
        
            mutating func moveBy(deltaX: Double, deltaY: Double) {
                x += deltaX
                y += deltaY
            }
        } 
        复制代码
    
        enum StateSwitch {
            case low, middle, high
        
            mutating func next() {
                switch self {
                case .low:
                    self = .middle
                case .middle:
                    self = .high
                case .high:
                    self = .low
                }
            }
        } 
        复制代码
    

3\. @discardableResult
----------------------

*   在`func`前面加上`@discardableResult`，可以消除函数调用后`返回值未被使用的警告`
    
        struct Point {
            var x = 0.0, y = 0.0
        
            @discardableResult mutating func moveX(deltaX: Double) -> Double {
                x += deltaX
                return x
            }
        }
        
        var p = Point()
        p.moveX(deltaX: 10) 
        复制代码
    

八、下标（subscript）
===============

1\. 基本概念
--------

*   1.  使用`subscript`可以给任意类型（`枚举`、`结构体`、`类`）增加下标功能  
        有些地方也翻译成：下标脚本
*   2.  `subscript`的语法类似于实例方法、计算属性，本质就是方法（函数）

    class Point {
        var x = 0.0, y = 0.0
        
        subscript(index: Int) -> Double {
            set {
                if index == 0 {
                    x = newValue
                } else if index == 1 {
                    y = newValue
                }
            }
            
            get {
                if index == 0 {
                    return x
                } else if index == 1 {
                    return y
                } 
                return 0
            }
        }
    }
    
    var p = Point()
    p[0] = 11.1
    p[1] = 22.2
    print(p.x) // 11.1
    print(p.y) // 22.2
    print(p[0]) // 11.1
    print(p[1]) // 22.2 
    复制代码

*   3.  `subscript`中定义的返回值类型决定了`getter`中返回值类型和`setter`中`newValue`的类型
*   4.  `subscript`可以接收多个参数，并且类型任意
    
        class Grid {
            var data = [
                [0, 1 ,2],
                [3, 4, 5],
                [6, 7, 8]
            ]
        
            subscript(row: Int, column: Int) -> Int {
                set {
                    guard row >= 0 && row < 3 && column >= 0 && column < 3 else { return }
                    data[row][column] = newValue
                }
        
                get {
                    guard row >= 0 && row < 3 && column >= 0 && column < 3 else { return 0 }
                    return data[row][column]
                }
            }
        } 
        var grid = Grid()
        grid[0, 1] = 77
        grid[1, 2] = 88
        grid[2, 0] = 99 
        复制代码
    
*   5.  `subscript`可以没有`setter`，但必须要有`getter`，同计算属性
    
        class Point {
            var x = 0.0, y = 0.0 
            subscript(index: Int) -> Double {
                get {
                    if index == 0 {
                        return x
                    } else if index == 1 {
                        return y
                    } 
                    return 0
                }
            }
        } 
        复制代码
    
*   6.  `subscript`如果只有`getter`，可以省略`getter`
    
        class Point {
            var x = 0.0, y = 0.0 
            subscript(index: Int) -> Double {
                if index == 0 {
                    return x
                } else if index == 1 {
                    return y
                } 
                return 0
            }
        } 
        复制代码
    
*   7.  `subscript`可以设置参数标签  
        只有设置了自定义标签的调用才需要写上参数标签
        
            class Point {
                var x = 0.0, y = 0.0 
                subscript(index i: Int) -> Double {
                    if i == 0 {
                        return x
                    } else if i == 1 {
                        return y
                    }
            
                    return 0
                }
            }
            
            var p = Point()
            p.y = 22.2
            print(p[index: 1]) // 22.2 
            复制代码
        
*   8.`subscript`可以是类型方法
    
        class Sum {
            static subscript(v1: Int, v2: Int) -> Int {
                v1 + v2
            }
        } 
        print(Sum[10, 20]) // 30 
        复制代码
    

> **通过反汇编来分析**

看下面的示例代码，我们将断点打到图上的位置，然后观察反汇编

![-w710](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eee7f7f5299245879b4ee35b6898cf44~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

看到其内部是会调用`setter`来进行计算

![-w708](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5c779a1690154074ad390a09275cecff~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w714](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dcc337e8548b429fa24e06e8b36202f4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

然后再将断点打到这里来看

![-w552](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/61185b4065e54f1db581d1517112cacf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

看到其内部是会调用`getter`来进行计算 ![-w712](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29c9cb259eec4610936b97a9ab5fac3f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dad3b8fab86e43da91b7d7d8135a9f98~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

经上述分析就可以证明`subscript`本质就是方法调用

2\. 结构体和类作为返回值对比
----------------

看下面的示例代码

    struct Point {
        var x = 0, y = 0
    }
    
    class PointManager {
        var point = Point()
        subscript(index: Int) -> Point {
            set { point = newValue }
            get { point }
        }
    }
    
    var pm = PointManager()
    pm[0].x = 11 // 等价于pm[0] = Point(x: 11, y: pm[0].y)
    pm[0].y = 22 // 等价于pm[0] = Point(x: pm[0].x, y: 22) 
    复制代码

如果我们注释掉`setter`，那么调用会报错 ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a6291e522984427cab617ad5bc7b2d25~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 但是我们将结构体换成类，就不会报错了 ![-w624](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc397b02db4e4a8ba2bbf2502633b205~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   原因还是在于结构体是`值类型`，通过`getter`得到的`Point`结构体只是`临时的值`（可以想成计算属性），并不是真正的存储属性point，所以会报错
    *   通过打印也可以看出来要修改的并不是同一个地址值的point ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e035ac4da994f1ea8beb96d272fadc3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   但换成了类，那么通过`getter`得到的`Point`类是一个指针变量，而修改的是指向堆空间中的`Point`的属性，所以不会报错

3.接收多个参数的下标
-----------

    class Grid {
        var data = [
            [0, 1, 2], 
            [3, 4, 5], 
            [6, 7, 8] 
        ] 
        
        subscript(row: Int, column: Int) -> Int { 
            set { 
                guard row >= 0 && row < 3 && column >= 0 && column < 3 else {
                    return 
                }
                data[row][column] = newValue 
            } 
        
            get { 
                guard row >= 0 && row < 3 && column >= 0 && column < 3 else { 
                    return 0 
                } 
                return data[row][column] 
            }
    
        } 
    }
    
    var grid = Grid() 
    grid[0,1] = 77 
    grid[1,2] = 88 
    grid[2,0] = 99 
    print(grid.data)
    复制代码

九、继承（Inheritance）
=================

1\. 基本概念
--------

*   `继承:` 值类型（结构体、枚举）不支持继承，只有引用类型的类支持继承
*   `基类:` 没有父类的类，叫做基类
*   `Swift`并没有像`OC、Java`那样的规定，任何类最终都要继承自某个基类 ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ccf8006df0db467080740e343e7b7a54~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   `子类`可以重写从`父类`继承过来的`下标`、`方法`、`属性`。重写必须加上`override`
    
        class Car {
            func run() {
                print("run")
            }
        }
        
        
        class Truck: Car {
            override func run() {
        
            }
        } 
        复制代码
    

2.内存结构
------

看下面几个类的内存占用是多少

    class Animal {
        var age = 0
    }
    
    class Dog: Animal {
        var weight = 0
    }
    
    class ErHa: Dog {
        var iq = 0
    }
    
    let a = Animal()
    a.age = 10
    print(Mems.size(ofRef: a)) // 32
    print(Mems.memStr(ofRef: a))
    
    //0x000000010000c3c8
    //0x0000000000000003
    //0x000000000000000a
    //0x000000000000005f
    
    let d = Dog()
    d.age = 10
    d.weight = 20
    print(Mems.size(ofRef: d)) // 32
    print(Mems.memStr(ofRef: d))
    
    //0x000000010000c478
    //0x0000000000000003
    //0x000000000000000a
    //0x0000000000000014
    
    let e = ErHa()
    e.age = 10
    e.weight = 20
    e.iq = 30
    print(Mems.size(ofRef: e)) // 48
    print(Mems.memStr(ofRef: e))
    
    //0x000000010000c548
    //0x0000000000000003
    //0x000000000000000a
    //0x0000000000000014
    //0x000000000000001e
    //0x0000000000000000 
    复制代码

*   1.  首先类内部会有16个字节:存储`类信息`和`引用计数`
*   2.  然后才是成员变量/常量的内存(`存储属性`)
*   3.  又由于堆空间分配内存,存在内存对齐的概念,其原则分配的内存大小为16的倍数且刚好大于或等于初始化一个该数据类型变量所需的字节数
*   4.  基于前面的规则,最终得出结论:所分配的内存空间分别占用为`32`、`32`、`48`
*   5.  Tips:子类会继承自父类的属性，所以内存会算上父类的属性存储空间

3\. 重写实例方法、下标
-------------

    class Animal {
        func speak() {
            print("Animal speak")
        }
        
        subscript(index: Int) -> Int {
            index
        }
    }
    
    var ani: Animal
    ani = Animal()
    ani.speak()
    print(ani[6])
    
    class Cat: Animal {
        override func speak() {
            super.speak()
            
            print("Cat speak")
        }
        
        override subscript(index: Int) -> Int {
            super[index] + 1
        }
    }
    
    ani = Cat()
    ani.speak()
    print(ani[7]) 
    复制代码

*   1.  被`class`修饰的类型`方法`、`下标`，允许被子类重写
    
        class Animal {
            class func speak() {
                print("Animal speak")
            }
        
            class subscript(index: Int) -> Int {
                index
            }
        }
        
        
        Animal.speak()
        print(Animal[6])
        
        class Cat: Animal {
            override class func speak() {
                super.speak()
        
                print("Cat speak")
            }
        
            override class subscript(index: Int) -> Int {
                super[index] + 1
            }
        }
        
        Cat.speak()
        print(Cat[7]) 
        复制代码
    
*   2.  被`static`修饰的类型方法、下标，不允许被子类重写 ![-w571](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/615e2193e883491fbc45c9c531860185~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4afd111508704971875cca945f656fd0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   3.  但是被`class`修饰的类型方法、下标，子类重写时允许使用`static`修饰  
        但再后面的子类就不被允许了
    
        class Animal {
            class func speak() {
                print("Animal speak")
            }
        
            class subscript(index: Int) -> Int {
                index
            }
        }
        
        
        Animal.speak()
        print(Animal[6])
        
        class Cat: Animal {
            override static func speak() {
                super.speak()
        
                print("Cat speak")
            }
        
            override static subscript(index: Int) -> Int {
                super[index] + 1
            }
        }
        
        Cat.speak()
        print(Cat[7]) 
        复制代码
    
    ![-w634](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87766e3668e340fd912a5b87363b8f7b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4\. 重写属性
--------

*   1.  子类可以将父类的属性（存储、计算）重写为计算属性
    
        class Animal {
            var age = 0
        }
        
        class Dog: Animal {
            override var age: Int {
                set {
        
                }
        
                get {
                    10
                }
            }
            var weight = 0
        } 
        复制代码
    
*   2.  但子类`不可以`将父类的属性重写为`存储属性` ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d2d1a89318a143bebbb37a77ec8e93b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w638](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3506b968c7454367be459f52b85160b9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   3.  只能重写`var`属性，不能重新`let`属性 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ead7d3af36a4d0a8dd92e28121ee6cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   4.  重写时，属性名、类型要一致 ![-w639](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87ab8d0c201f424f988161c658f01b2f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   5.  子类重写后的属性权限不能小于父类的属性权限
    
    *   如果父类属性是`只读的`，那么子类重写后的属性`可以是只读的`，`也可以是可读可写的`
    *   如果父类属性是`可读可写的`，那么子类重写后的属性也`必须是可读可写的`

### 4.1 重写实例属性

    class Circle {
        // 存储属性
        var radius: Int = 0
    
        // 计算属性
        var diameter: Int {
            set(newDiameter) {
                print("Circle setDiameter")
                radius = newDiameter / 2
            }
    
            get {
                print("Circle getDiameter")
                return radius * 2
            }
        }
    }
    
    class SubCircle: Circle {
        override var radius: Int {
            set {
                print("SubCircle setRadius")
                super.radius = newValue > 0 ? newValue : 0
            }
    
            get {
                print("SubCircle getRadius")
                return super.radius
            }
        }
        
        override var diameter: Int {
            set {
                print("SubCircle setDiameter")
                super.diameter = newValue > 0 ? newValue : 0
            }
    
            get {
                print("SubCircle getDiameter")
                return super.diameter
            }
        }
    }
    
    var c = SubCircle()
    c.radius = 6
    print(c.diameter)
    
    c.diameter = 20
    print(c.radius)
    
    //SubCircle setRadius
    
    //SubCircle getDiameter
    //Circle getDiameter
    //SubCircle getRadius
    //12
    
    //SubCircle setDiameter
    //Circle setDiameter
    //SubCircle setRadius
    
    //SubCircle getRadius
    //10 
    复制代码

*   6.  从父类继承过来的`存储属性`，**都会分配内存空间**，**`不管`** 之后会不会被重写为计算属性
*   7.  如果重写的方法里的`setter`和`getter`不写`super`，那么就会死循环
    
        class SubCircle: Circle {
            override var radius: Int {
                set {
                    print("SubCircle setRadius")
                    radius = newValue > 0 ? newValue : 0
                }
        
                get {
                    print("SubCircle getRadius")
                    return radius
                }
            }    
        } 
        复制代码
    

### 4.2 重写类型属性

*   1.  被`class`修饰的计算类型属性，`可以`被子类重写

    class Circle {
        // 存储属性
        static var radius: Int = 0 
        // 计算属性
        class var diameter: Int {
            set(newDiameter) {
                print("Circle setDiameter")
                radius = newDiameter / 2
            } 
            get {
                print("Circle getDiameter")
                return radius * 2
            }
        }
    } 
    class SubCircle: Circle { 
        override static var diameter: Int {
            set {
                print("SubCircle setDiameter")
                super.diameter = newValue > 0 ? newValue : 0
            } 
            get {
                print("SubCircle getDiameter")
                return super.diameter
            }
        }
    }
    
    Circle.radius = 6
    print(Circle.diameter)
    
    Circle.diameter = 20
    print(Circle.radius)
    
    SubCircle.radius = 6
    print(SubCircle.diameter)
    
    SubCircle.diameter = 20
    print(SubCircle.radius)
    
    //Circle getDiameter
    //12
    
    //Circle setDiameter
    //10
    
    //SubCircle getDiameter
    //Circle getDiameter
    //12
    
    //SubCircle setDiameter
    //Circle setDiameter
    //10 
    复制代码

*   2.  被`static`修饰的类型属性(计算、存储）,`不可以`被子类重写 ![-w861](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18f27d1f7ebf4f45bb65dbaa2063f0cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

5\. 属性观察器
---------

*   1.  可以在子类中为父类属性（除了只读计算属性、`let`属性）增加属性观察器  
        重写后还是存储属性，不是变成了计算属性
    
        class Circle {
            var radius: Int = 1
        }
        
        class SubCircle: Circle {
            override var radius: Int {
                willSet {
                    print("SubCircle willSetRadius", newValue)
                }
        
                didSet {
                    print("SubCircle didSetRadius", oldValue, radius)
                }
            }
        }
        
        var circle = SubCircle()
        circle.radius = 10
        
        //SubCircle willSetRadius 10
        //SubCircle didSetRadius 1 10 
        复制代码
    
*   2.  如果父类里也有属性观察器:
    
    *   那么子类赋值时，会先调用自己的属性观察器`willSet`,然后调用父类的属性观察器`willSet`；
    *   并且在父类里面才是真正的进行赋值
    *   然后先父类的`didSet`，最后再调用自己的`didSet`
        
            class Circle {
                var radius: Int = 1 {
                    willSet {
                        print("Circle willSetRadius", newValue)
                    }
            
                    didSet {
                        print("Circle didSetRadius", oldValue, radius)
                    }
                }
            }
            
            class SubCircle: Circle {
                override var radius: Int {
                    willSet {
                        print("SubCircle willSetRadius", newValue)
                    }
            
                    didSet {
                        print("SubCircle didSetRadius", oldValue, radius)
                    }
                }
            }
            
            var circle = SubCircle()
            circle.radius = 10
            
            //SubCircle willSetRadius 10
            //Circle willSetRadius 10
            //Circle didSetRadius 1 10
            //SubCircle didSetRadius 1 10 
            复制代码
        
*   3.  可以给父类的`计算属性`增加属性观察器
    
        class Circle {
            var radius: Int {
                set {
                    print("Circle setRadius", newValue)
                }
        
                get {
                    print("Circle getRadius")
                    return 20
                }
            }
        }
        
        class SubCircle: Circle {
            override var radius: Int {
                willSet {
                    print("SubCircle willSetRadius", newValue)
                } 
                didSet {
                    print("SubCircle didSetRadius", oldValue, radius)
                }
            }
        }
        
        var circle = SubCircle()
        circle.radius = 10
        
        //Circle getRadius
        //SubCircle willSetRadius 10
        //Circle setRadius 10
        //Circle getRadius
        //SubCircle didSetRadius 20 20 
        复制代码
    

上面打印会先调用一次`Circle getRadius`是因为在设置值之前会先拿到它的`oldValue`，所以需要调用`getter`一次

为了测试，我们将`oldValue`的获取去掉后，再打印发现就没有第一次的`getter`的调用了

![-w717](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a0343cfec35740fcb77982ff96267dbd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

6.final
-------

*   1.  被`final`修饰的`方法`、`下标`、`属性`，禁止被重写 ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ccf17c068f94675958d85987162f5dd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b108314a8bc74118b5bb5dc9c213aea1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/61b66e59c2034bd0b3e373d0665d95d8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   2.  被`final`修饰的类，禁止被继承 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/115cfb3c712e48b6b94af68a9b1b65b1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

7\. 方法调用的本质
-----------

*   1.  我们先看下面的示例代码，分析`结构体`和`类`的调用方法区别是什么
    
        struct Animal {
            func speak() {
                print("Animal speak")
            }
        
            func eat() {
                print("Animal eat")
            }
        
            func sleep() {
                print("Animal sleep")
            }
        }
        
        var ani = Animal()
        ani.speak()
        ani.eat()
        ani.sleep() 
        复制代码
    
*   2.  反汇编之后，发现结构体的方法调用就是**直接找到方法所在地址直接调用**  
        结构体的`方法地址都是固定的` ![-w715](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/752cc3d50e4c45419ce8afbfabd8dbcc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   3.  接下来 我们在看换成`类`之后反汇编的实现是怎样的
    
        class Animal {
            func speak() {
                print("Animal speak")
            }
        
            func eat() {
                print("Animal eat")
            }
        
            func sleep() {
                print("Animal sleep")
            }
        }
        
        var ani = Animal()
        ani.speak()
        ani.eat()
        ani.sleep() 
        复制代码
    
*   4.  反汇编之后，会发现需要`调用的方法地址`是**不确定**的  
        所以凡是**调用固定地址**的`都不会是类的方法`的调用 ![-w1189](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df6aa4298ea04c36ba4c0c73278c1613~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1192](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6195c8a7683449b09fd9de09dcae7770~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1190](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1b553e2aec2a4dd6b137720c92927df6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1186](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/910f04a6b13a4401b3a8a089f00293dc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1185](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e1af14c97064f2b8a3b5292a12f6a9d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1187](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bee00d70a4945a2b43b3b5a34c23cb6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1189](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/550d001c28ea43f4810113b5fe8c0f74~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    
    *   而且上述的几个调用的方法地址都是从`rcx`往高地址偏移`8`个字节来调用的，也就说明几个方法地址都是连续的
    *   我们再来分析下方法调用前做了什么:
    *   通过反汇编我们可以看到:
        *   会从`全局变量`的指针找到其`指向的堆内存`中的类的存储空间
        *   然后`再根据类的前8个字节`里的`类信息`知道需要调用的方法地址
        *   从**类信息的地址进行偏移**找到`方法地址`，然后调用 ![-w1140](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/74b06640e5f344bda01f2a511199e65d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    *   然后我们将示例代码修改一下，再观察其本质是什么
    
        class Animal {
            func speak() {
                print("Animal speak")
            }
        
            func eat() {
                print("Animal eat")
            }
        
            func sleep() {
                print("Animal sleep")
            }
        }
        
        class Dog: Animal {
            override func speak() {
                print("Dog speak")
            }
        
            override func eat() {
                print("Dog eat")
            }
        
            func run() {
                print("Dog run")
            }
        }
        
        var ani = Animal()
        ani.speak()
        ani.eat()
        ani.sleep()
        
        ani = Dog()
        ani.speak()
        ani.eat()
        ani.sleep() 
        复制代码
    
    *   `增加了子类后`，Dog的类信息里的方法列表会存有重写后的父类方法，以及自己新增的方法
    
        class Dog: Animal {
            func run() {
                print("Dog run")
            }
        } 
        复制代码
    
    *   如果子类里`没有重写父类方法`，那么类信息里的方法列表会有父类的方法，以及自己新增的方法
        

十、初始化器
======

1\. 类的初始化器
----------

*   1.  `类`、`结构体`、`枚举`都可以定义初始化器
    
    *   **类有两种初始化器:**
    *   指定初始化器（`designated initializer`）
    *   便捷初始化器（`convenience initializer`）
        
            // 指定初始化器
            init(parameters) {
                statements
            }
            
            // 便捷初始化器
            convenience init(parameters) {
                statements
            } 
            复制代码
        
*   2.  每个类`至少有一个`**指定初始化器**  
        指定初始化器是类的主要初始化器
*   3.  默认初始化器总是类的指定初始化器
    
        class Size {
            init() {
        
            }
        
            init(age: Int) {
        
            }
        
            convenience init(height: Double) {
                self.init()
            }
        }
        
        var s = Size()
        s = Size(height: 180)
        s = Size(age: 10) 
        复制代码
    
*   4.  类本身会自带一个指定初始化器
    
        class Size {
        
        }
        
        var s = Size() 
        复制代码
    
*   5.  如果有自定义的指定初始化器，默认的指定初始化器就不存在了 ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/da7f3104587044b392f3d7b85f228080~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   6.  类偏向于`少量指定初始化器`  
        一个类通常只有一个指定初始化器
    
        class Size {
            var width: Double = 0
            var height: Double = 0
        
            init(height: Double, width: Double) {
                self.width = width
                self.height = height
            }
        
            convenience init(height: Double) {
                self.init(height: height, width: 0)
            }
        
            convenience init(width: Double) {
                self.init(height: 0,width: width)
            }
        }
        
        let size = Size(height: 180, width: 70) 
        复制代码
    

2\. 初始化器的相互调用
-------------

**初始化器的相互调用规则**

*   `指定初始化器`必须从它的直系父类调用`指定初始化器`
*   `便捷初始化器`必须从相同的类里调用`另一个初始化器`
*   `便捷初始化器`最终必须调用一个`指定初始化器`
    
        class Person {
            var age: Int
            init(age: Int) {
                self.age = age
            }
        
            convenience init() {
                self.init(age: 0)
        
                self.age = 10
            }
        }
        
        class Student: Person {
            var score: Int
        
            init(age: Int, score: Int) {
        
                self.score = score
                super.init(age: age)
        
                self.age = 30
            }
        
            convenience init(score: Int) {
                self.init(age: 0, score: score)
        
                self.score = 100
            }
        } 
        复制代码
    

**这一套规则保证了:**  
使用任何初始化器，都可以完整地初始化实例 ![-w1211](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ee15a2cdbe9249b5a2d4ba7c515497a4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3\. 两段式初始化和安全检查
---------------

Swift在编码安全方面煞费苦心，为了保证初始化过程的安全，设定了`两段式初始化`和`安全检查`

### 3.1 两段式初始化

**第一阶段: `初始化所有存储属性`**

*   外层调用 **`指定/便捷`初始化器**
*   分配内存给实例,但未初始化
*   **`指定初始化器`** 确保**当前类定义的存储属性都初始化**
*   **`指定初始化器`** 调用父类的初始化器,不断向上调用，形成`初始化器链`

**第二阶段: 设置新的存储属性值**

*   从顶部初始化器往下，链中的每一个指定初始化器**都有机会进一步定制**实例
*   初始化器现在能够使用`self`（访问、修改它的属性、调用它的实例方法等）
*   最终，链中任何便捷初始化器都有机会定制实例以及使用`self`

### 3.2 安全检查

*   `指定初始化器`**必须保证**在调用父类初始化器之前, 其所在类定义的`所有存储属性`都要初始化完成
*   `指定初始化器`必须先调用父类初始化器,然后才能为继承的属性设置新值
*   `便捷初始化器`必须先调用同类中的其他初始化器,然后再为任意属性设置新值
*   `初始化器`在第一阶段初始化完成之前,不能调用任何实例方法，不能读取任何实例属性的值，也不能引用`self`
*   直到第一阶段结束，实例才算完全合法

### 3.3 重写

*   1.  当重写父类的`指定初始化器`时，必须加上`override`（即使子类的实现的`便捷初始化器`）
*   2.  `指定初始化器`只`能纵向调用`，可以被子类调用
    
        class Person {
            var age: Int
            init(age: Int) {
                self.age = age
            }
        
            convenience init() {
                self.init(age: 0)
        
                self.age = 10
            }
        }
        
        class Student: Person {
            var score: Int
        
            override init(age: Int) {
                self.score = 0
                super.init(age: age)
            }
        } 
        复制代码
    
        class Person {
            var age: Int
            init(age: Int) {
                self.age = age
            }
        
            convenience init() {
                self.init(age: 0)
        
                self.age = 10
            }
        }
        
        class Student: Person {
            var score: Int
        
            init(age: Int, score: Int) {
        
                self.score = score
                super.init(age: age)
            }
        
            override convenience init(age: Int) {
                self.init(age: age, score: 0)
            }
        } 
        复制代码
    
*   3.  如果子类写了一个匹配父类`便捷初始化器`的初始化器，不用加`override`
    
        class Person {
            var age: Int
            init(age: Int) {
                self.age = age
            }
        
            convenience init() {
                self.init(age: 0)
            }
        }
        
        class Student: Person {
            var score: Int
        
            init(age: Int, score: Int) {
        
                self.score = score
                super.init(age: age)
            }
        
            convenience init() {
                self.init(age: 0, score: 0)
            }
        } 
        复制代码
    
    因为父类的便捷初始化器永远不会通过子类直接调用  
    因此，严格来说，**子类无法重写父类的`便捷初始化器`**
    
*   4.  `便捷初始化器`只能**横向调用**，不能被子类调用  
        子类没有权利更改父类的`便捷初始化器`，所以不能叫重写
    
        class Person {
            var age: Int
            init(age: Int) {
                self.age = age
            }
        
            convenience init() {
                self.init(age: 0)
            }
        }
        
        class Student: Person {
            var score: Int
        
            init(age: Int, score: Int) {
        
                self.score = score
                super.init(age: age)
            }
        
            init() {
                self.score = 0
                super.init(age: 0)
            }
        } 
        复制代码
    

4\. 自动继承
--------

*   1.  如果子类没有自定义任何指定初始化器，它会自动继承父类所有的指定初始化器
    
        class Person {
            var age: Int
        
            init(age: Int) {
                self.age = age
            }
        }
        
        class Student: Person {
        
        }
        
        var s = Student(age: 20) 
        复制代码
    
        class Person {
            var age: Int
        
            init(age: Int) {
                self.age = age
            }
        }
        
        class Student: Person {
        
            convenience init(name: String) {
                self.init(age: 0)
            }
        }
        
        var s = Student(name: "ray")
        s = Student(age: 20) 
        复制代码
    
*   2.  如果子类提供了父类所有`指定初始化器`的实现（要不通过上一种方式继承，要不重新）
    
        class Person {
            var age: Int
        
            init(age: Int) {
                self.age = age
            }
        
            convenience init(sex: Int) {
                self.init(age: 0)
            }
        }
        
        class Student: Person {
        
            override init(age: Int) {
                super.init(age: 20)
            }
        }
        
        var s = Student(age: 30) 
        复制代码
    
        class Person {
            var age: Int
        
            init(age: Int) {
                self.age = age
            }
        
            convenience init(sex: Int) {
                self.init(age: 0)
            }
        }
        
        class Student: Person {
        
            init(num: Int) {
                super.init(age: 0)
            }
        
            override convenience init(age: Int) {
                self.init(num: 200)
            }
        }
        
        var s = Student(age: 30) 
        复制代码
    
*   3.  如果子类自定义了`指定初始化器`，那么父类的`指定初始化器`便不会被继承  
        子类自动继承所有的父类`便捷初始化器` ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3f9d8da9ce41477ea3d937b0ad450f4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   4.  就算子类添加了更多的`便捷初始化器`，这些规则仍然适用
    
        class Person {
            var age: Int
        
            init(age: Int) {
                self.age = age
            }
        
            convenience init(sex: Int) {
                self.init(age: 0)
            }
        }
        
        class Student: Person {
        
            convenience init(isBoy: Bool) {
                self.init(age: 20)
            }
        
            convenience init(num: Int) {
                self.init(age: 20)
            }
        }
        
        var s = Student(age: 30)
        s = Student(sex: 24)
        s = Student(isBoy: true)
        s = Student(num: 6) 
        复制代码
    
*   5.  子类以`便捷初始化器`的形式重新父类的`指定初始化器`，也可以作为满足第二条规则的一部分
    
        class Person {
            var age: Int
        
            init(age: Int) {
                self.age = age
            }
        
            convenience init(sex: Int) {
                self.init(age: 0)
            }
        }
        
        class Student: Person {
        
            convenience init(sex: Int) {
                self.init(age: 20)
            }
        }
        
        var s = Student(age: 30)
        s = Student(sex: 24) 
        复制代码
    

5\. required
------------

*   1.  用`required`修饰`指定初始化器`，表明其**所有子类**都`必须实现`该初始化器（通过继承或者重写实现）

    class Person {
        var age: Int
        
        init(age: Int) {
            self.age = age
        }
        
        required init() {
            self.age = 0
        }
    }
    
    class Student: Person {
        
        
    }
    
    var s = Student(age: 30) 
    复制代码

*   2.  如果子类重写了`required`初始化器，也必须加上`required`，不用加`override`

    class Person {
        var age: Int
        
        init(age: Int) {
            self.age = age
        }
        
        required init() {
            self.age = 0
        }
    }
    
    class Student: Person {
        
        init(num: Int) {
            super.init(age: 0)
        }
        
        required init() {
            super.init()
        }
    }
    
    var s = Student(num: 30)
    s = Student() 
    复制代码

6\. 属性观察器
---------

*   1.  父类的属性在它自己的初始化器中赋值不会触发`属性观察器`  
        但在子类的初始化器中赋值会触发`属性观察器`
    
        class Person {
            var age: Int {
                willSet {
                    print("willSet", newValue)
                }
        
                didSet {
                    print("didSet", oldValue, age)
                }
            }
        
            init() {
                self.age = 0
            }
        }
        
        class Student: Person {
        
            override init() {
                super.init()
        
                age = 1
            }
        }
        
        var s = Student() 
        复制代码
    

7\. 可失败初始化器
-----------

*   1.  `类`、`结构体`、`枚举`都可以使用`init?`定义可失败初始化器
    
        class Person {
            var name: String
        
            init?(name: String) {
                if name.isEmpty {
                    return nil
                }
        
                self.name = name
            }
        }
        
        let p = Person(name: "Jack")
        print(p) 
        复制代码
    
    *   下面这几个也是使用了可失败初始化器
    
        var num = Int("123")
        
        enum Answer: Int {
            case wrong, right
        }
        
        var an = Answer(rawValue: 1) 
        复制代码
    
    ![-w539](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9ca5a14875fb4bda8ae27f64a6a4d04d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    
*   2.  不允许同时定义`参数标签`、`参数个数`、`参数类型相同`的`可失败初始化器`和`非可失败初始化器` ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8725835306874ef2a15e8ec405af5742~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   3.  可以用`init!`定义隐式解包的`可失败初始化器`
    
        class Person {
            var name: String
        
            init!(name: String) {
                if name.isEmpty {
                    return nil
                }
        
                self.name = name
            }
        }
        
        let p = Person(name: "Jack")
        print(p) 
        复制代码
    
*   4.  `可失败初始化器`可以调用`非可失败初始化器`  
        `非可失败初始化器`调用`可失败初始化器`需要进行`解包`
    
        class Person {
            var name: String
        
            convenience init?(name: String) {
                self.init()
        
                if name.isEmpty {
                    return nil
                }
        
                self.name = name
            }
        
            init() {
                self.name = ""
            }
        } 
        复制代码
    
        class Person {
            var name: String
        
            init?(name: String) {
        
                if name.isEmpty {
                    return nil
                }
        
                self.name = name
            }
        
            convenience init() {
                // 强制解包有风险
                self.init(name: "")!
        
                self.name = ""
            }
        } 
        复制代码
    
*   5.  如果初始化器调用一个`可失败初始化器`导致`初始化失败`，那么整个初始化过程都失败，并且之后的代码都停止执行
    
        class Person {
            var name: String
        
            init?(name: String) {
        
                if name.isEmpty {
                    return nil
                }
        
                self.name = name
            }
        
            convenience init?() {
                // 如果这一步返回为nil，那么后面的代码就不会继续执行了
                self.init(name: "")!
        
                self.name = ""
            }
        }
        
        let p = Person()
        print(p) 
        复制代码
    
*   6.  可以用一个`非可失败初始化器`重写一个`可失败初始化器`，但反过来是不行的
    
        class Person {
            var name: String
        
            init?(name: String) {
        
                if name.isEmpty {
                    return nil
                }
        
                self.name = name
            }
        }
        
        class Student: Person {
        
            override init(name: String) {
                super.init(name: name)!
            }
        } 
        复制代码
    
    ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd34f75d2bb946c9844fe54070a41aff~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    

7\. 反初始化器（deinit）
-----------------

*   1.  `deinit`叫做反初始化器，类似于C++的`析构函数`，OC中的`dealloc方法`
*   2.  当类的实例对象被释放内存时，就会调用实例对象的`deinit`方法
    
        class Person {
            var name: String
        
            init(name: String) {
                self.name = name
            }
        
            deinit {
                print("Person对象销毁了")
            }
        } 
        复制代码
    
*   3.  父类的`deinit`能被子类继承
*   4.  子类的`deinit`实现执行完毕后会调用父类的`deinit`
    
        class Person {
            var name: String 
            init(name: String) {
                self.name = name
            } 
            deinit {
                print("Person对象销毁了")
            }
        }
        
        class Student: Person { 
            deinit {
                print("Student对象销毁了")
            }
        }
        
        func test() {
            let stu = Student(name: "Jack")
        }
        
        test()
        
        // 打印
        // Student对象销毁了
        // Person对象销毁了 
        复制代码
    
*   5.  `deinit`不接受任何参数，不能写小括号，不能自行调用

十一、可选链（Optional Chaining）
=========================

看下面的示例代码:

    class Person {
        var name: String = ""
        var dog: Dog = Dog()
        var car: Car? = Car()
        
        func age() -> Int { 18 }
        
        func eat() {
            print("Person eat")
        }
        
        subscript(index: Int) -> Int { index }
    } 
    复制代码

*   1.  如果可选项为`nil`，调用方法、下标、属性失败，结果为`nil`
    
        var person: Person? = nil
        var age = person?.age()
        var name = person?.name
        var index = person?[6]
        
        print(age, name, index) // nil, nil, nil 
        复制代码
    
        // 如果person为nil，都不会调用getName
        func getName() -> String { "jack" }
        
        var person: Person? = nil
        person?.name = getName() 
        复制代码
    
*   2.  如果可选项不为`nil`，调用`方法`、`下标`、`属性`成功，结果会被包装成`可选项`
    
        var person: Person? = Person()
        var age = person?.age()
        var name = person?.name
        var index = person?[6]
        
        print(age, name, index) // Optional(18) Optional("") Optional(6) 
        复制代码
    
*   3.  如果结果`本来就是可选项`，不会进行再次包装
    
        print(person?.car) // Optional(test_enum.Car) 
        复制代码
    
*   4.  可以用可选绑定来判断可选项的方法调用是否成功
    
        let result: ()? = person?.eat()
        if let _ = result {
            print("调用成功")
        } else {
            print("调用失败")
        } 
        复制代码
    
        if let age = person?.age() {
            print("调用成功", age)
        } else {
            print("调用失败")
        } 
        复制代码
    
*   5.  没有设定返回值的方法默认返回的就是`元组类型` ![-w521](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b8b75b19c58c4059a2380e609ddb9540~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   6.  多个?可以连接在一起，组成可选链
    
        var dog = person?.dog
        var weight = person?.dog.weight
        var price = person?.car?.price 
        复制代码
    
*   7.  可选链中不管中间经历多少层，只要有一个节点是可选项的，那么最后的结果就是会被包装成可选项的
    
        print(dog, weight, price) // Optional(test_enum.Dog) Optional(0) Optional(0)
        复制代码
    
*   8.  如果链中任何一个节点是`nil`，那么整个链就会调用失败  
        看下面示例代码
    
        var num1: Int? = 5
        num1? = 10
        print(num1)
        
        var num2: Int? = nil
        num2? = 10
        print(num2) 
        复制代码
    
*   9.  给变量加上`?`是为了判断变量是否为`nil`，如果为`nil`，那么就不会执行赋值操作了，本质也是可选链
    
        var dict: [String : (Int, Int) -> Int] = [
            "sum" : (+),
            "difference" : (-)
        ]
        
        var value = dict["sum"]?(10, 20)
        print(value) 
        复制代码
    

从字典中通过key来取值，得到的也是可选类型，由于可选链中有一个节点是可选项，那么最后的结果也是可选项，最后的值也是`Int?`

十二、协议（Protocol）
===============

1\. 基本概念
--------

*   1.  `协议`可以用来定义`方法`、`属性`、`下标`的声明  
        `协议`可以被`结构体`、`类`、`枚举`遵守
    
        protocol Drawable {
            func draw()
            var x: Int { get set } // get和set只是声明
            var y: Int { get }
            subscript(index: Int) -> Int { get set }
        } 
        复制代码
    
*   2.  `多个协议`之间用逗号隔开
    
        protocol Test1 { }
        protocol Test2 { }
        protocol Test3 { }
        
        class TestClass: Test1, Test2, Test3 { } 
        复制代码
    
*   3.  协议中定义方法时不能有默认参数值 ![-w633](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f7119b8167f647fe819d6285c3c57f9f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   4.  默认情况下，协议中定义的内容必须全部都实现

2\. 协议中的属性
----------

*   1.  `协议`中定义属性必须用`var`关键字
*   2.  实现`协议`时的属性权限要不小于`协议`中定义的`属性权限`
    
    *   协议定义`get、set`，用`var`存储属性或`get、set`计算属性去实现
    *   协议定义`get`，用任何属性都可以实现
    
        protocol Drawable {
            func draw()
            var x: Int { get set }
            var y: Int { get }
            subscript(index: Int) -> Int { get set }
        }
        
        class Person1: Drawable {
            var x: Int = 0
            let y: Int = 0
        
            func draw() {
                print("Person1 draw")
            }
        
            subscript(index: Int) -> Int {
                set { }
                get { index }
            }
        }
        
        class Person2: Drawable {
            var x: Int {
                get { 0 }
                set { }
            }
        
            var y: Int { 0 }
        
            func draw() {
                print("Person2 draw")
            }
        
            subscript(index: Int) -> Int {
                set { }
                get { index }
            }
        }
        
        class Person3: Drawable {
            var x: Int {
                get { 0 }
                set { }
            }
        
            var y: Int {
                get { 0 }
                set { }
            }
        
            func draw() {
                print("Person3 draw")
            }
        
            subscript(index: Int) -> Int {
                set { }
                get { index }
            }
        } 
        复制代码
    

3\. static、class
----------------

*   1.  为了保证通用，`协议`中必须用`static`定义`类型方法`、`类型属性`、`类型下标`
    
        protocol Drawable {
            static func draw()
        }
        
        class Person1: Drawable {
            static func draw() {
                print("Person1 draw")
            }
        }
        
        class Person2: Drawable {
            class func draw() {
                print("Person2 draw")
            }
        } 
        复制代码
    

4\. mutating
------------

*   1.  只有将`协议`中的`实例方法`标记为`mutating`，才允许`结构体`、`枚举`的具体实现修改自身内存
*   2.  `类`在实现方法时不用加`mutating`，`结构体`、`枚举`才需要加`mutating`
    
        protocol Drawable {
            mutating func draw()
        }
        
        class Size: Drawable {
            var width: Int = 0
        
            func draw() {
                width = 10
            }
        }
        
        struct Point: Drawable {
            var x: Int = 0
            mutating func draw() {
                x = 10
            }
        } 
        复制代码
    

5\. init
--------

*   1.  协议中还可以定义初始化器`init`，非`final`类实现时必须加上`required`
*   2.  目的是为了让所有遵守这个协议的类都拥有初始化器，所以加上`required`强制子类必须实现，除非是加上`final`不需要子类的类
    
        protocol Drawable {
            init(x: Int, y: Int)
        }
        
        class Point: Drawable {
            required init(x: Int, y: Int) {
        
            }
        }
        
        final class Size: Drawable {
            init(x: Int, y: Int) {
        
            }
        } 
        复制代码
    
*   3.  如果从协议实现的初始化器，刚好是重写了父类的指定初始化器，那么这个初始化必须同时加上`required、override`
    
        protocol Livable {
            init(age: Int)
        }
        
        class Person {
            init(age: Int) { }
        }
        
        class Student: Person, Livable {
            required override init(age: Int) {
                super.init(age: age)
            }
        } 
        复制代码
    
*   4.  协议中定义的`init?、init!`，可以用`init、init?、init!`去实现
    
        protocol Livable {
            init()
            init?(age: Int)
            init!(no: Int)
        }
        
        class Person1: Livable {
            required init() {
        
            }
        
            required init?(age: Int) {
        
            }
        
            required init!(no: Int) {
        
            }
        }
        
        class Person2: Livable {
            required init() {
        
            }
        
            required init!(age: Int) {
        
            }
        
            required init?(no: Int) {
        
            }
        }
        
        class Person3: Livable {
            required init() {
        
            }
        
            required init(age: Int) {
        
            }
        
            required init(no: Int) {
        
            }
        } 
        复制代码
    
*   5.  协议中定义的`init`，可以用`init、init!`去实现
    
        protocol Livable {
            init()
            init?(age: Int)
            init!(no: Int)
        }
        
        class Person4: Livable {
            required init!() {
        
            }
        
            required init?(age: Int) {
        
            }
        
            required init!(no: Int) {
        
            }
        }  
        复制代码
    

6\. 协议的继承
---------

一个`协议`可以继承其他协议

    protocol Runnable {
        func run()
    }
    
    protocol Livable: Runnable {
        func breath()
    }
    
    class Person: Livable {
        func breath() {
    
        }
    
        func run() {
    
        }
    } 
    复制代码

7\. 协议组合
--------

协议组合可以包含一个类类型

    protocol Runnable { }
    protocol Livable { }
    class Person { }
    
    // 接收Person或者其子类的实例
    func fn0(obj: Person) { }
    
    // 接收遵守Livable协议的实例
    func fn1(obj: Livable) { }
    
    // 接收同时遵守Livable、Runnable协议的实例
    func fn2(obj: Livable & Runnable) { }
    
    // 接收同时遵守Livable、Runnable协议，并且是Person或者其子类的实例
    func fn3(obj: Person & Livable & Runnable) { }
    
    typealias RealPerson = Person & Livable & Runnable
    func fn4(obj: RealPerson) { } 
    复制代码

8\. CaseIterable
----------------

让枚举遵守`CaseIterable`协议，可以实现遍历枚举值

    enum Season: CaseIterable {
        case spring, summer, autumn, winter
    }
    
    let seasons = Season.allCases
    print(seasons.count)
    
    for season in seasons {
        print(season)
    } // spring, summer, autumn, winter 
    复制代码

9.CustomStringConvertible
-------------------------

*   1.  遵守`CustomStringConvertible、CustomDebugStringConvertible`协议，都可以自定义实例的打印字符串
    
        class Person: CustomStringConvertible, CustomDebugStringConvertible {
            var age = 0
            var description: String { "person_(age)" }
            var debugDescription: String { "debug_person_(age)" }
        }
        
        var person = Person()
        print(person) // person_0
        debugPrint(person) // debug_person_0 
        复制代码
    
*   2.  `print`调用的是`CustomStringConvertible`协议的`description`
*   3.  `debugPrint、po`调用的是`CustomDebugStringConvertible`协议的`debugDescription`

![-w529](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/acc8277e7aa14a60a23a27f52a4b11fc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

十三、Any、AnyObject
================

*   1.  Swift提供了两种特殊的类型`Any、AnyObject`
*   2.  `Any`可以代表任意类型（`枚举`、`结构体`、`类`，也包括`函数类型`）
    
        var stu: Any = 10
        stu = "Jack"
        stu = Size() 
        复制代码
    
        var data = [Any]()
        data.append(1)
        data.append(3.14)
        data.append(Size())
        data.append("Jack")
        data.append({ 10 }) 
        复制代码
    
*   3.  `AnyObject`可以代表任意类类型
*   4.  在协议后面写上`: AnyObject`，代表只有类能遵守这个协议 ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d3809ed07d17450d911eec4ad2731c0f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   5.  在协议后面写上`: class`，也代表只有类能遵守这个协议 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3c89cc874464f83a7bdb5c65a31b83c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

1\. is、as
---------

*   `is`用来判断是否为某种类型
    
        protocol Runnable {
            func run()
        }
        
        class Person { }
        
        class Student: Person, Runnable {
            func run() {
                print("Student run")
            }
        
            func study() {
                print("Student study")
            }
        }
        
        var stu: Any = 10
        print(stu is Int) // true
        
        stu = "Jack"
        print(stu is String) // true
        
        stu = Student()
        print(stu is Person) // true
        print(stu is Student) // true
        print(stu is Runnable) // true 
        复制代码
    
*   2.  `as`用来做强制类型转换(`as?`、`as!`、`as`)
    
        protocol Runnable {
            func run()
        }
        
        class Person { }
        
        class Student: Person, Runnable {
            func run() {
                print("Student run")
            }
        
            func study() {
                print("Student study")
            }
        }
        
        var stu: Any = 10
        (stu as? Student)?.study() // 没有调用study
        
        stu = Student()
        (stu as? Student)?.study() // Student study
        (stu as! Student).study() // Student study
        (stu as? Runnable)?.run() // Student run 
        复制代码
    
        var data = [Any]()
        data.append(Int("123") as Any)
        
        var d = 10 as Double
        print(d) // 10.0 
        复制代码
    

十四、 元类型
=======

1\. X.self
----------

*   1.  `X.self`是一个`元类型的指针`，`metadata`存放着`类型相关信息`
*   2.  `X.self`属于`X.Type`类型
    
        class Person { }
        
        class Student: Person { }
        
        var perType: Person.Type = Person.self
        var stuType: Student.Type = Student.self
        perType = Student.self
        
        var anyType: AnyObject.Type = Person.self
        anyType = Student.self
        
        var per = Person()
        perType = type(of: per)
        print(Person.self == type(of: per)) // true 
        复制代码
    
*   3.  `AnyClass`的本质就是`AnyObject.Type` ![-w492](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c534ec2adb474b47bc5ab8ab7221b02a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    
        var anyType2: AnyClass = Person.self
        anyType2 = Student.self 
        复制代码
    

2\. 元类型的应用
----------

    class Animal {
        required init() {
            
        }
    }
    
    class Cat: Animal {
        
    }
    
    class Dog: Animal {
        
    }
    
    class Pig: Animal {
        
    }
    
    func create(_ clses: [Animal.Type]) -> [Animal] {
        var arr = [Animal]()
        for cls in clses {
            arr.append(cls.init())
        }
        
        return arr
    }
    
    print(create([Cat.self, Dog.self, Pig.self]))
    
    // a1、a2、a3、a4的写法等价
    var a1 = Animal()
    var t = Animal.self
    var a2 = t.init()
    var a3 = Animal.self.init()
    var a4 = Animal.self() 
    复制代码

3.Self
------

*   1.  `Self`代表当前类型
    
        class Person {
            var age = 1
            static var count = 2
        
            func run() {
                print(self.age)
                print(Self.count)
            }
        } 
        复制代码
    
*   2.  `Self`一般用作返回值类型，限定返回值和方法调用者必须是同一类型（也可以作为参数类型）
    
        protocol Runnable {
            func test() -> Self
        }
        
        class Person: Runnable {
        
            required init() {
        
            }
        
            func test() -> Self {
                type(of: self).init()
            }
        }
        
        class Student: Person {
        
        }
        
        var p = Person()
        print(p.test()) // test_enum.Person
        
        var stu = Student()
        print(stu.test()) // test_enum.Student 
        复制代码
    

4\. 元类型的本质
----------

我们可以通过反汇编来查看元类型的实现是怎样的

    var p = Person()
    var pType = Person.self 
    复制代码

我们发现最后存储到全局变量pType中的地址值就是一开始调用的地址 ![-w1031](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8a38e68565b04a649793fd49e4962bc8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 再通过打印，我们发现pType的值就是Person实例对象的前8个字节的地址值，也就是类信息 ![-w1031](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f81fff9375c949a18a6e71f733e06da5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1032](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d84b816435c0422a9ea5bfde95b40861~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 我们再来看下面的示例代码

    var p = Person()
    var pType = type(of: p) 
    复制代码

通过分析我们可以看到`type(of: p)`本质不是函数调用，只是将Person实例对象的前8个字节存储到pType中，也证明了元类型的本质就是存储的类信息

![-w1031](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f11a754847b149eab14026ed50e0ff21~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1030](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aa877aa499e7423e86c1e96bd301d291~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们还可以用以下方式来获取Swift的隐藏基类`_TtCs12_SwiftObject`

    class Person {
        var age: Int = 0
    }
    
    class Student: Person {
        var no: Int = 0
    }
    
    print(class_getInstanceSize(Student.self)) // 32
    print(class_getSuperclass(Student.self)!) // Person
    print(class_getSuperclass(Student.self)!) // _TtCs12_SwiftObject
    print(class_getSuperclass(NSObject.self)) // nil 
    复制代码

我们可以查看Swift源码来分析该类型

发现`SwiftObject`里面也有一个`isa指针`

![-w686](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b4602a6c2194461caf1a20eefd72056b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

专题系列文章
======

### 1.前知识

*   **[01-探究iOS底层原理|综述](https://juejin.cn/post/7089043618803122183/ "https://juejin.cn/post/7089043618803122183/")**
*   **[02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】](https://juejin.cn/post/7093842449998561316/ "https://juejin.cn/post/7093842449998561316/")**
*   **[03-探究iOS底层原理|LLDB](https://juejin.cn/post/7095079758844674056 "https://juejin.cn/post/7095079758844674056")**
*   **[04-探究iOS底层原理|ARM64汇编](https://juejin.cn/post/7115302848270696485/ "https://juejin.cn/post/7115302848270696485/")**

### 2\. 基于OC语言探索iOS底层原理

*   **[05-探究iOS底层原理|OC的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")**
*   **[06-探究iOS底层原理|OC对象的本质](https://juejin.cn/post/7094503681684406302 "https://juejin.cn/post/7094503681684406302")**
*   **[07-探究iOS底层原理|几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012")**
*   **[08-探究iOS底层原理|Category底层结构、App启动时Class与Category装载过程、load 和 initialize 执行、关联对象](https://juejin.cn/post/7096480684847415303 "https://juejin.cn/post/7096480684847415303")**
*   **[09-探究iOS底层原理|KVO](https://juejin.cn/post/7115318628563550244/ "https://juejin.cn/post/7115318628563550244/")**
*   **[10-探究iOS底层原理|KVC](https://juejin.cn/post/7115320523805949960/ "https://juejin.cn/post/7115320523805949960/")**
*   **[11-探究iOS底层原理|探索Block的本质|【Block的数据类型(本质)与内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用】](https://juejin.cn/post/7115809219319693320/ "https://juejin.cn/post/7115809219319693320/")**
*   **[12-探究iOS底层原理|Runtime1【isa详解、class的结构、方法缓存cache\_t】](https://juejin.cn/post/7116103432095662111 "https://juejin.cn/post/7116103432095662111")**
*   **[13-探究iOS底层原理|Runtime2【消息处理(发送、转发)&&动态方法解析、super的本质】](https://juejin.cn/post/7116147057739431950 "https://juejin.cn/post/7116147057739431950")**
*   **[14-探究iOS底层原理|Runtime3【Runtime的相关应用】](https://juejin.cn/post/7116291178365976590/ "https://juejin.cn/post/7116291178365976590/")**
*   **[15-探究iOS底层原理|RunLoop【两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer】](https://juejin.cn/post/7116515606597206030/ "https://juejin.cn/post/7116515606597206030/")**
*   **[16-探究iOS底层原理|RunLoop的应用](https://juejin.cn/post/7116521653667889165/ "https://juejin.cn/post/7116521653667889165/")**
*   **[17-探究iOS底层原理|多线程技术的底层原理【GCD源码分析1:主队列、串行队列&&并行队列、全局并发队列】](https://juejin.cn/post/7116821775127674916/ "https://juejin.cn/post/7116821775127674916/")**
*   **[18-探究iOS底层原理|多线程技术【GCD源码分析1:dispatch\_get\_global\_queue与dispatch\_(a)sync、单例、线程死锁】](https://juejin.cn/post/7116878578091819045 "https://juejin.cn/post/7116878578091819045")**
*   **[19-探究iOS底层原理|多线程技术【GCD源码分析2:栅栏函数dispatch\_barrier\_(a)sync、信号量dispatch\_semaphore】](https://juejin.cn/post/7116897833126625316 "https://juejin.cn/post/7116897833126625316")**
*   **[20-探究iOS底层原理|多线程技术【GCD源码分析3:线程调度组dispatch\_group、事件源dispatch Source】](https://juejin.cn/post/7116898446358888485/ "https://juejin.cn/post/7116898446358888485/")**
*   **[21-探究iOS底层原理|多线程技术【线程锁：自旋锁、互斥锁、递归锁】](https://juejin.cn/post/7116898868737867789/ "https://juejin.cn/post/7116898868737867789/")**
*   **[22-探究iOS底层原理|多线程技术【原子锁atomic、gcd Timer、NSTimer、CADisplayLink】](https://juejin.cn/post/7116907029465137165 "https://juejin.cn/post/7116907029465137165")**
*   **[23-探究iOS底层原理|内存管理【Mach-O文件、Tagged Pointer、对象的内存管理、copy、引用计数、weak指针、autorelease](https://juejin.cn/post/7117274106940096520 "https://juejin.cn/post/7117274106940096520")**

### 3\. 基于Swift语言探索iOS底层原理

关于`函数`、`枚举`、`可选项`、`结构体`、`类`、`闭包`、`属性`、`方法`、`swift多态原理`、`String`、`Array`、`Dictionary`、`引用计数`、`MetaData`等Swift基本语法和相关的底层原理文章有如下几篇:

*   [Swift5核心语法1-基础语法](https://juejin.cn/post/7119020967430455327 "https://juejin.cn/post/7119020967430455327")
*   [Swift5核心语法2-面向对象语法1](https://juejin.cn/post/7119510159109390343 "https://juejin.cn/post/7119510159109390343")
*   [Swift5核心语法2-面向对象语法2](https://juejin.cn/post/7119513630550261774 "https://juejin.cn/post/7119513630550261774")
*   [Swift5常用核心语法3-其它常用语法](https://juejin.cn/post/7119714488181325860 "https://juejin.cn/post/7119714488181325860")
*   [Swift5应用实践常用技术点](https://juejin.cn/post/7119722433589805064 "https://juejin.cn/post/7119722433589805064")

其它底层原理专题
========

### 1.底层原理相关专题

*   [01-计算机原理|计算机图形渲染原理这篇文章](https://juejin.cn/post/7018755998823219213 "https://juejin.cn/post/7018755998823219213")
*   [02-计算机原理|移动终端屏幕成像与卡顿 ](https://juejin.cn/post/7019117942377807908 "https://juejin.cn/post/7019117942377807908")

### 2.iOS相关专题

*   [01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理](https://juejin.cn/post/7019193784806146079 "https://juejin.cn/post/7019193784806146079")
*   [02-iOS底层原理|iOS动画渲染原理](https://juejin.cn/post/7019200157119938590 "https://juejin.cn/post/7019200157119938590")
*   [03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理](https://juejin.cn/post/7019497906650497061/ "https://juejin.cn/post/7019497906650497061/")
*   [04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案](https://juejin.cn/post/7020613901033144351 "https://juejin.cn/post/7020613901033144351")

### 3.webApp相关专题

*   [01-Web和类RN大前端的渲染原理](https://juejin.cn/post/7021035020445810718/ "https://juejin.cn/post/7021035020445810718/")

### 4.跨平台开发方案相关专题

*   [01-Flutter页面渲染原理](https://juejin.cn/post/7021057396147486750/ "https://juejin.cn/post/7021057396147486750/")

### 5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较

*   [01-Native、WebApp、跨平台开发三种方案性能比较](https://juejin.cn/post/7021071990723182606/ "https://juejin.cn/post/7021071990723182606/")

### 6.Android、HarmonyOS页面渲染专题

*   [01-Android页面渲染原理](https://juejin.cn/post/7021840737431978020/ "https://juejin.cn/post/7021840737431978020/")
*   [02-HarmonyOS页面渲染原理](# "#") (`待输出`)

### 7.小程序页面渲染专题

*   [01-小程序框架渲染原理](https://juejin.cn/post/7021414123346853919 "https://juejin.cn/post/7021414123346853919")