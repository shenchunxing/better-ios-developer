# Swift5常用核心语法1-基础语法

一、概述
====

最近刚好有空,趁这段时间,复习一下Swift5核心语法,进行知识储备,以供日后温习 和 探索 Swift语言的底层原理做铺垫。

二、Swift5 简介
===========

1\. Swift简介
-----------

> `在学习Swift之前，我们先来了解下什么是Swift`
> ----------------------------

*   在Swift刚发布那会，百度\\Google一下Swift，出现最多的搜索结果是 p美国著名女歌手`Taylor Swift`，中国歌迷称她为“霉霉” ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c6e47a38ed474b5da8d0a92a64d29cf5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
*   现在的搜索结果以Swift编程语言相关的内容居多
*   Swift是`Apple`在2014年6月`WWDC`发布的全新编程语言，中文名和LOGO是”雨燕“
*   Swift之父是`Chris Lattner`，也是`Clang`编译器的作者，`LLVM`项目的主要发起人 ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/422db6557dc64aefb517e64047706181~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)
    *   如果你想了解一下LLVM、Clang等知识,也可以参考一下我这篇文章:
    *   [探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM、Xcode编译的过程】](https://juejin.cn/post/7093842449998561316 "https://juejin.cn/post/7093842449998561316")

2.Swift版本
---------

Swift历时8年，从`Swift 1.*`更新到`Swift 5.*`，经历了多次重大改变，`ABI`终于稳定

*   API（Application Programming Interface）：应用程序编程接口
    *   源代码和库之间的接口
*   ABI（Application Binary Interface）：应用程序二进制接口
    *   应用程序和操作系统之间的底层接口
    *   涉及的内容有：目标文件格式、数据类型的大小/布局/对齐，函数调用约定等
*   随着ABI的稳定，Swift语法基本不会再有太大的变动，此时正是学习Swift的最佳时刻
*   截止至2022年11月，目前最新版本：`Swift5.8.x`
*   Swift完全开源: [github.com/apple/swift](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fapple%2Fswift "https://github.com/apple/swift") 主要采用[C++](https://link.juejin.cn?target=https%3A%2F%2Fzh.wikipedia.org%2Fwiki%2FC%252B%252B "https://zh.wikipedia.org/wiki/C%2B%2B")编写
*   Swift是完全开源的，下载地址：[github.com/apple/swift](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fapple%2Fswift "https://github.com/apple/swift")

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b35a9d1a95143c1919a33e9d38a8b38~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

3\. Swift编译原理
-------------

关于更详尽的iOS编译相关的知识,可以参考我这篇文章:[探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM、Xcode编译的过程】](https://juejin.cn/post/7093842449998561316 "https://juejin.cn/post/7093842449998561316")  
在本文仅是简单回顾一下:

### 3.1 了解LLVM项目

**`LLVM`项目的架构如图:** ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a1361fe67fca43fd919e467dd657f0ba~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 从上图我们可以清晰看到,整个程序编译链可以划分为三部分:`编译器前端`(左边部分)、`优化器`(中间部分)、`编译器后端`(右边部分)。(从我的这篇文章可以更详细了解编译相关的知识:[计算机编译原理](https://juejin.cn/post/7022956636901736462/ "https://juejin.cn/post/7022956636901736462/"))

*   **编译器前端（Frontend）** :词法分析、语法分析、语义分析、生成中间代码llvm-ir
*   **优化器（Optimizer）** :对中间代码进行优化、改造,使之变成性能更加高效的中间代码llvm-ir(内存空间、执行效率)
*   **编译器后端(Backend)** :生成指定硬件架构的可执行文件

**对编译器王者`LLVM`的进一步认识:**

*   **使用统一的中间代码:** 不同的编译器前端、编译器后端使用统一的中间代码LLVM Intermediate Representation (LLVM IR)
*   **只需实现一个前端:** 如果需要支持一种新的编程语言，那么只需要实现一个新的前端
*   **只需实现一个后端:** 如果需要支持一种新的硬件设备，那么只需要实现一个新的后端
*   **通用优化器:** 优化阶段是一个通用的阶段，它针对的是统一的LLVM IR，不论是支持新的编程语言，还是支持新的硬件设备，都不需要对优化阶段做修改

### 3.2 编译流程

我们知道OC的编译器前端是`Clang`,而Swift的编译器前端是`swiftc`  
通过LLVM编译链,不同的编译型语言的编译器前端可能不同，但在同一个硬件架构的硬件中,最终都会通过同一个编译器的后端生成二进制代码

![-w727](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7340c46adb0f4b56b586665b3c5e1af7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

整个编译流程如下图所示

![-w525](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8870a2bedcfb4727805286871302da56~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   **代码编辑/阅读阶段:**
    *   **Swift Code:** 我们编写的Swift代码
*   **编译器前端工作阶段:**
    *   **Swift AST:** Swift语法树
    *   **Raw Swift IL:** Swift特有的中间代码
*   **优化器工作阶段:**
    *   **Canonical Swift IL:** 更简洁的Swift特有的中间代码
    *   **LLVM IR:** LLVM的中间代码
*   **编译器后端工作阶段:**
    *   **Assembly:** 汇编代码
    *   **Executable:** 二进制可执行文件

关于Swift编译流程的详细讲解可以参考以下网址：[swift.org/swift-compi…](https://link.juejin.cn?target=https%3A%2F%2Fswift.org%2Fswift-compiler%2F%23compiler-architecture "https://swift.org/swift-compiler/#compiler-architecture")

### 3.3 swiftc

我们打开终端，输入`swiftc -help`，会打印出相关指令，这也说明了`swiftc`已经存在于Xcode中 ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/529073fbb5114e74b3e1d5bb781cf36c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

我们可以在应用程序中找到`Xcode`，然后`右键显示包内容`，通过该路径找到`swiftc` 路径：`/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin`

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e3c9b58d277c4416a405660a1e2b5d73~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

### 3.4 `SwiftC` 命令行指令

    // 假设原始文件为main.swift
    
    // 分析输出AST
    swiftc main.swift -dump-parse
    
    // 分析并且检查类型输出AST
    swiftc main.swift -dump-ast
    
    // 生成中间体语言（SIL），未优化
    swiftc main.swift -emit-silgen -o main.sil 
    
    // 生成中间体语言（SIL），优化后的
    swiftc main.swift -emit-sil -o main.sil 
    
    // 生成优化后的中间体语言（SIL）,并将结果导入到main.sil文件中
    swiftc main.swift -emit-sil  -o main.sil 
    
    // 生成优化后的中间体语言（SIL），并将sil文件中的乱码字符串进行还原，并将结果导入到main.sil文件中
    swiftc main.swift -emit-sil | xcrun swift-demangle > main.sil
    
    // 生成LLVM中间体语言 （.ll文件）
    swiftc main.swift -emit-ir  -o main.ir
    
    // 生成LLVM中间体语言 （.bc文件）
    swiftc main.swift -emit-bc -o main.bc
    
    // 生成汇编
    swiftc main.swift -emit-assembly -o main.s
    
    // 编译生成可执行.out文件
    swiftc main.swift -o main.o 
     
    复制代码

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3b0a17ed5e7645fe85e717787b6c4cde~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

三、Swift基础语法
===========

通过前面的篇幅,我们基本了解了Swift,接下来我们通过后面的篇幅回顾Swift核心语法,首先引入一张Swift学习路径图: ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/24a0e9b9edef459698ab719ddd55e5ca~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

1\. HelloWorld
--------------

    print("Hello World")
    复制代码

*   `不用编写main函数`，Swift将全局范围内的首句可执行代码作为程序入口
    *   通过反汇编我们可以看到底层会执行`main函数` ![-w1084](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d3812006b4554d1dab11c06773c70667~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   一句代码尾部可以省略分号（`;`），多句代码写到同一行时必须用分号（`;`）隔开

2\. 常量和变量
---------

> **常量:**

*   1.用`let`定义常量(常量只能赋值一次)  
    不用特意指明类型，编译器能自动推断出变量/常量的数据类型

    let a: Int = 10
    let b = 20
    复制代码

*   2.它的值不要求在编译过程中确定，但使用之前必须赋值一次  
    这样写确定了a的类型，之后再去赋值，也不会报错

    let a: Int
    a = 10
    复制代码

*   3.  用函数给常量赋值也可以，函数是在运行时才会确定值的，所以只要保证使用之前赋值了就行

    func getNumber() -> Int {
        return 10
    }
    
    let a: Int
    a = getNumber()
    复制代码

如果没有给a确定类型，也没有一开始定义的时候赋值，就会像下面这样报错

![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/08edecb0ca46419ba036d09018216bf9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> **变量:**

*   1.用`var`定义变量

    var b = 20
    b = 30
    复制代码

*   2.常量、变量在初始化之前，都不能使用 ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/04bf944bbfc4417e8823fae37c842d4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3.注释
----

*   1.Swift中有单行注释和多行注释  
    注释之间嵌套也没有问题 ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87b1be1e5f484713bd027b95238b96ea~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    // 单行注释
    
    /*
     多行注释
    */
    
    /*
      1
     /* 释嵌套 */
     2 
    */ 
    复制代码

*   2.`Playground`里的注释支持`Markup`语法（同Markdown）  
    `Markup`语法只在`Playground`里有效，在项目中无效

    //: # 一级标题
    
    /*:
     ## 基础语法
     */
    复制代码

可以通过`Editor -> Show Raw Markup`来预览

![-w299](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fc0ce08a3f7e47ddb20ab8e25ee2390f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

预览的效果如下

![-w369](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/79c641b6ee6a41ffa4fc92e3042cc724~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4.标识符
-----

1.标识符（比如常量名、变量名、函数名）几乎可以使用任何字符

    let 📒 = 5
    var 😁 = 10
    
    func 👽() {
        
    }
    复制代码

标识符不能以数字开头，不能包含空白字符、制表符、箭头等特殊字符

![-w649](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8fcaf1f13cc64642a95cf7cad2b6d27c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

5.常见数据类型
--------

### 5.1 常见类型

*   值类型
    *   枚举（enum）: Optional
    *   结构体（struct）: Bool、Double、Float、Int、Character、String、Array、Dictionary、Set
*   引用类型
    *   类（class）

可以通过`command+control`进入到该类型的API中查看

例如Int类型

![-w757](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2d867a4b7cb649cea7603c96674e93f3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 5.2 整数类型

*   整数类型：`Int8`、`Int16`、`Int32`、`Int64`、`UInt8`、`UInt16`、`UInt32`、`UInt64`
*   在32bit平台，`Int`等于`Int32`；在64bit平台，`Int`等于`Int64`
*   整数的最值：`UInt8.max`，`Int16.min` 一般情况下，都是直接使用`Int`即可

    let a: Int8 = 5
    复制代码

### 5.3 浮点类型

*   Float：32位，精度只有6位
*   Double：64位，精度至少15位 浮点型不指明类型默认就是`Double`

    let a: Float = 2.0
    let b = 3.0
    复制代码

6\. 字面量
-------

字面量就是指这个量本身，就是一个固定值的表示法

下面这些都是字面量

### 6.1 Bool布尔

一般用`Bool`类型来表示是否的判断，是为`true`，否为`false`

    //布尔
    let bool = true //取反是false
    复制代码

### 6.2 字符串、字符

> **字符串的写法:**

    let string = "hello"
    复制代码

字符类型要写上`Character`，否则会被认为是字符串  
字符可存储`ASCII字符、Unicode字符`

> **字符写法:**

    let character: Character = "a"
    复制代码

### 6.3 整数

> **不同进制的表示法:**

*   二进制以`0b`开头
*   八进制以`0o`开头
*   十六进制以`0x`开头

    let intDecimal = 17 // 十进制
    let intBinary = 0b10001 // 二进制
    let intOctal = 0o21 // 八进制
    let intHexadecimal = 0x11 // 十六进制
    复制代码

### 6.4 浮点数

    let doubleDecimal = 125.0 // 十进制
    let doubleDecimal2 = 1.25e2 // 也是125.0的另一种写法，表示1.25乘以10的二次方
    
    let doubleDecimal3 = 0.0125
    let doubleDecimal4 = 1.25e-2 // 也是0.0125的另一种写法，表示1.25乘以10的负二次方
    
    let doubleHexadecimal1 = 0xFp2 // 十六进制，意味着15*2^2（15乘以2的二次方），相当于十进制的60
    let doubleHexadecimal2 = 0xFp-2 //十六进制，意味着15*2^-2（15乘以2的负二次方），相当于十进制的3.75
    复制代码

整数和浮点数可以添加额外的零或者下划线来`增强可读性`

    let num = 10_0000
    let price = 1_000.000_000_1
    let decimal = 000123.456
    复制代码

### 6.5 数组

    let array = [1, 2, 3, 4]
    复制代码

### 6.6 字典

    let dictionary = ["age" : 18, "height" : 1.75, "weight" : 120]
    复制代码

7.类型转换
------

> **整数转换:**

    let int1: UInt16 = 2_000
    let int2: UInt8 = 1
    let int3 = int1 + UInt16(int2)
    复制代码

> **整数、浮点数转换:**

    let int = 3
    let double = 0.1415926
    let pi = Double(int) + double
    let intPi = Int(pi)
    复制代码

> **字面量可以直接相加，因为数字字面量本身没有明确的类型:**

    let result = 3 + 0.14159
    复制代码

8.元组（tuple）
-----------

元组是可以多种数据类型组合在一起

    let http404Error = (404, "Not Found")
    print("The status code is (http404Error.0)")
    
    // 可以分别把元组里的两个值分别进行赋值
    let (statusCode, statusMsg) = http404Error
    print("The status code is (statusCode)")
    
    // 可以只给元组里的某一个值进行赋值
    let (justTheStatusCode, _) = http404Error
    
    // 可以在定义的时候给元组里面的值起名
    let http200Status = (statusCode: 200, description: "ok")
    print("The status code is (http200Status.statusCode)")
    复制代码

9.流程控制
------

### 9.1 条件分支语句if-else

Swift里的`if else`后面的条件是可以省略小括号的，但大括号不可以省略

    let age = 10 
    if age >= 22 {
        print("Get married")
    } else if age >= 18 {
        print("Being a adult")
    } else if age >= 7 {
        print("Go to school")
    } else {
        print("Just a child")
    }
    复制代码

`if else`后面的条件只能是`Bool类型`

![-w718](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d70fc3c6157d4d7286323338f6a62764~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 9.2 循环语句`while`/`repeat-while`

**`while`:**

    var num = 5
    while num > 0 {
        print("num is (num)")
        // 打印了五次
    }
    复制代码

**`repeat-while`:**  
`repeat-while`相当于C语言中的`do-while`

先执行一次，再判断条件循环

    var num = -1
    repeat {
        print("num is (num)")
        // 打印了一次
    } while num > 0
    复制代码

这里不用`num--`是因为  
`Swift3`开始，已经去掉了自增(++)、自减(--)运算符

### 9.3 循环语句for

*   1.闭区间运算符：`a...b`，相当于`a <= 取值 <= b`
    
        // 第一种写法
        let names = ["Anna", "Alex", "Brian", "Jack"]
        for i in 0...3 {
            print(names[i])
        }// Anna Alex Brian Jack
        // 第二种写法
        let range = 0...3
        for i in range {
            print(names[i])
        }// Anna Alex Brian Jack
        
        // 第三种写法
        let a = 1
        let b = 3
        for i in a...b {
        
        }// Alex Brian Jack
        复制代码
    
*   2.  循环里的`i`默认是`let`，如需要更改加上`var`
    
        for var i in 1...3 {
            i += 5
            print(i)
        }// 6 7 8
        复制代码
    
*   3.  不需要值的时候用`_`来表示
    
        for _ in 0...3 {
            print("for")
        }// 打印了3次
        复制代码
    

> for – 区间运算符用在数组上

*   4.半开区间运算符：`a..<b`，相当于`a <= 取值 < b`
    
        for i in 0..<3 {
            print(i)
        }//0 1 2
        复制代码
    
*   6.单侧区间：让一个区间朝一个方向尽可能的远区间运算符还可以用在数组上）
    
        let names = ["Anna", "Alex", "Brian", "Jack"] 
        for name in names[0...3] { 
           print(name)
        } // Anna Alex Brian Jack
        
        
        for name in names[2...] {
           print(name)
        } // Brian Jack
        
        for name in names[...2] {
           print(name)
        } // Anna Alex Brian
          
        for name in names[..<2] {
           print(name)
        } // Anna Alex
        
        
        let range = ...5 
        range.contains(7) // false 
        range.contains(4) // true 
        range.contains(-3) // true
        复制代码
    
*   7.区间的几种类型
    
        闭区间 ClosedRange<Int> 
        1...3
        
        半开区间 Range<Int>
         1..<3
        
        单侧区间 PartialRangeThrough<Int>
        ...3
        复制代码
    
*   9.字符、字符串也能使用区间运算符，但默认不能用在`for-in`中
    
        let stringRange1 = "cc"..."ff"// ClosedRange<String>
        stringRange1.contains("cd")// false
        stringRange1.contains("dz") // true 
        stringRange1.contains("fg") // false
        
        let stringRange2 = "a"..."f"
        stringRange2.contains("d") // true 
        stringRange2.contains("h") // false
        // \0到~囊括了所有可能要用到的ASCII字符
        let characterRange:ClosedRange<Character> = "\0"..."~"
        characterRange.contains("G")// true
        复制代码
    
*   10.带间隔的区间值
    
        let hours = 10
        let hourInterval = 2 
        // tickmark的取值，从4开始，累加2，不超过10
        for tickmark in stride(from: 4, through: hours, by: hourInterval) {
            print(tickmark)
            // 4,6,8,10
        }
        复制代码
    

### 9.4 选择语句switch

使用同`C语言的switch`，不同的是:

*   1.  `case、default`后面不写`大括号{}`
    
        var number = 1
        
        switch number {
        case 1:
            print("number is 1")
            break
        case 2:
            print("number is 2")
            break
        default:
            print("number is other")
            break
        }
        复制代码
    
*   2.  默认不写`break`，并不会贯穿到后面的条件
    
        var number = 1
        
        switch number {
        case 1:
            print("number is 1")
        case 2:
            print("number is 2")
        default:
            print("number is other")
        }
        复制代码
    

> **`fallthrough`** 使用`fallthrough`可以实现贯穿效果

    var number = 1
    
    switch number {
    case 1:
        print("number is 1")
        fallthrough
    case 2:
        print("number is 2")
    default:
        print("number is other")
    }
    
    // 会同时打印number is 1，number is 2
    复制代码

> switch注意点
> ---------

*   1.  `switch`必须要保证能处理所有情况 **注意：像判断number的值，要考虑到所有整数的条件，如果不要判断全部情况，加上`default`就可以了** ![-w722](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/78d920799421482894f1b9fc53db3ebd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   2.  `case、default`后面至少要有一条语句  
        如果不想做任何事，加个`break`即可
    
        var number = 1
        
        switch number {
        case 1:
            print("number is 1")
        case 2:
            break
        default:
            break
        }
        复制代码
    
*   3.  如果能保证已处理所有情况，也可以不必使用`default`
    
        enum Answer { case right, wrong }
        
        let answer = Answer.right
        
        switch answer {
        case .right:
            print("right")
        case .wrong:
            print("wrong")
        }
        复制代码
    

> **复合条件**

*   4.  `switch`也支持`Character`和`String`类型
    
        let string = "Jack"
        
        switch string {
        case "Jack":
            fallthrough
        case "Rose":
            print(string)
        default:
            break
        }//Jack
        
        
        let character: Character = "a" 
        switch character {
        case "a", "A":
            print(character)
        default:
            break
        }
        复制代码
    
*   5.  `switch`可以同时判断多个条件
    
        let string = "Jack"
        
        switch string {
        case "Jack", "Rose":
            print(string)
        default:
            break
        }// Right person  
        复制代码
    
*   6.  `switch`也支持区间匹配和元组匹配
    
        let count = 62
        
        switch count {
        case 0:
            print("none")
        case 1..<5:
            print("a few")
        case 5..<12:
            print("several")
        case 12..<100:
            print("dozens of")
        default:
            print("many")
        }
        复制代码
    
*   7.  可以使用下划线`_`忽略某个值  
        关于`case`匹配问题，属于模式匹配（Pattern Matching）的范畴
    
        let point = (1, 1)
        switch point: {
        case (2, 2):
            print("1")
        case (_, 0):
            print("2")
        case (-2...2, 0...):
            print("3")
        } 
        复制代码
    

> **值绑定:**

*   8.值绑定，必要时`let`也可以改成`var`
    
        let point = (2, 0)
        switch point: {
        case (let x, 0):
            print("on the x-axis with an x value of \(x)")
        case (0, let y):
            print("on the y-axis with a y value of \(y)")
        case let (x, y):
            print("somewhere else at (\(x), \(y))")
        } // on the x-axis with an x value of 2
        复制代码
    

### 9.5 where

一般`where`用来结合条件语句进行过滤

    let point = (1, -1)
    switch point {
    case let (x, y) where x == y:
        print("on the line x == y")
    case let (x, y) where x == -y:
        print("on the line x == -y")
    case let (x, y):
        print("(x), (y) is just some arbitrary point")
    }// on the line x == -y
    
    // 将所有正数加起来 
    var numbers = [10, 20, -10, -20, 30, -30]
    var sum = 0 
    
    for num in numbers where num > 0 { // 使用where来过滤num 
        sum += num 
    }
    print(sum) // 60
    复制代码

### 9.6标签语句

用`outer`来标识循环跳出的条件

    outer: for i in 1...4 {
         for k in 1...4 {
             if k == 3 {
                 continue outer
             }
             if i == 3 {
                 break outer
             }
             print("i == \(i), k == \(k)")
        }
    }
    复制代码

10.函数
-----

### 10.1 函数的定义

#### a.)有返回值的函数

形参默认是`let`，也只能是`let`

    func sum(v1: Int, v2: Int) -> Int { 
        return v1 + v2 
    }
    复制代码

#### b.)无返回值的函数

返回值Void的本质就是一个`空元组`

    // 三种写法相同
    func sayHello() -> Void {
        print("Hello")
    }
    
    func sayHello() -> () {
        print("Hello")
    }
    
    func sayHello() {
        print("Hello")
    }
    复制代码

### 10.2 隐式返回（Implicit Return）

如果整个函数体是一个单一的表达式，那么函数会隐式的返回这个表达式

    func sum(v1: Int, v2: Int) -> Int { v1 + v2 }
    
    sum(v1: 10, v2: 20)//30
    复制代码

### 10.3 返回元组，实现多返回值

    func calculate(v1: Int, v2: Int) -> (sum: Int, difference: Int, average: Int) {
        let sum = v1 + v2
        return (sum, v1 - v2, sum >> 1)
    }
    
    let result = calculate(v1: 20, v2: 10)
    result.sum // 30 
    result.difference // 10 
    result.average // 15
    print(result.sum, result.difference, result.average)
    复制代码

### 10.4 函数的文档注释

可以通过一定格式书写注释，方便阅读

    /// 求和【概述】
    ///
    /// 将2个整数相加【更详细的描述】
    ///
    /// - Parameter v1: 第1个整数
    /// - Parameter v2: 第2个整数
    /// - Returns: 2个整数的和
    ///
    /// - Note:传入2个整数即可【批注】
    ///
    func sum(v1: Int, v2: Int) -> Int {
        v1 + v2
    }
    复制代码

![-w592](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/33a18a41153c4c13a44b4ad849fe7246~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

[详细参照Apple官方的api设计准则](https://link.juejin.cn?target=https%3A%2F%2Fswift.org%2Fdocumentation%2Fapi-design-guidelines%2F "https://link.juejin.cn?target=https%3A%2F%2Fswift.org%2Fdocumentation%2Fapi-design-guidelines%2F")

### 10.5 参数标签（Argument Label）

*   1.  可以修改参数标签

    func gotoWork(at time: String) {
        print("this time is \(time)")
    } 
    gotoWork(at: "8:00")// this time is 08:00
    复制代码

*   2.  可以使用下划线`_`省略参数标签，为了阅读性一般不建议省略

    func sum(_ value1: Int, _ value2: Int) -> Int {
         value1 + value2
    } 
    sum(5, 5)
    复制代码

### 10.6 默认参数值（Default Parameter Value）

*   1.  参数可以有默认值

    func check(name: String = "nobody", age: Int, job: String = "none") {
        print("name=(name), age=(age), job=(job)")
    }
    
    check(name: "Jack", age: 20, job: "Doctor")// name=Jack, age=20, job=Doctor
    check(name: "Jack", age: 20)// name=Jack, age=20, job=none
    check(age: 20, job: "Doctor")// name=nobody, age=20, job=Doctor
    check(age: 20)// name=nobody, age=20, job=none
    复制代码

*   2.  `C++`的默认参数值有个限制：必须从右往左设置；由于`Swift`拥有参数标签，因此没有此类限制
*   3.  但是在省略参数标签时，需要特别注意，避免出错

    // 这里的middle不可以省略参数标签
    func test(_ first: Int = 10, middle: Int, _ last: Int = 30) { }
    test(middle: 20)
    复制代码

### 10.7 可变参数（Variadic Parameter）

*   1.  一个函数`最多只能有一个`可变参数
    
        func sum(_ numbers: Int...) -> Int {
            var total = 0 
            for number in numbers {
                total += number
            } 
            return total
        } 
        sum(1, 2, 3, 4)
        复制代码
    
*   2.  紧跟在可变参数 后面的参数**不能省略参数标签**
    
        // 参数string不能省略标签
        func get(_ number: Int..., string: String, _ other: String) { }
        get(10, 20, string: "Jack", "Rose")
        复制代码
    

> **Swift自带的print函数** 我们可以参考下`Swift`自带的`print函数` ![-w828](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2b9dfed8ee594b1a8d86bcc51cf365c7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

    print(1, 2, 3, 4, 5)
    print(1, 2, 3, 4, 5, separator: " ", terminator: "\n")
    复制代码

### 10.8 输入输出参数（In-Out Parameter）

*   可以用`inout`定义一个输入输出参数：**`可以在函数内部修改外部实参的值`**
    
        func swapValues(_ v1: inout Int, _ v2: inout Int) {
            let tmp = v1
            v1 = v2
            v2 = tmp
        } 
        var num1 = 10
        var num2 = 20
        swapValues(&num1, &num2)
        复制代码
    
*   官方自带`swap`的交换函数就是使用的`inout` ![-w674](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/43952303c3bb471e8eba264435526b70~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    
    *   可以利用元组来进行参数交换
    
        func swapValues(_ v1: inout Int, _ v2: inout Int) {
                (v1, v2) = (v2, v1)
        }
        
        var num1 = 10
        var num2 = 20
        swapValues(&num1, &num2)
        复制代码
    
*   1.  可变参数不能标记为`inout` ![-w708](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8263bf403bab49aaa912ba72fef57894~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   2.  `inout`参数不能有默认值 ![-w704](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e47a2fe1fb194de085c3ed5eccce501d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   3.  `inout`参数只能传入可以被多次赋值的
    
    *   常量只能在定义的时候赋值一次，所以下面会报错 ![-w712](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/46eef03d01ab4aba8c89fcaa2e2c2115~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   4.  `inout`参数的本质是地址传递
    
    *   我们新建个项目，通过反汇编来观察其本质 ![-w671](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/36720e938a04480f8e81f35b0244a41d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    *   `leaq`表示的就是地址传递，可以看出在调用函数之前先将两个变量的地址放到了寄存器中 ![-w1119](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1a7c91c1476246b2bde575232db7ee41~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 10.9 函数重载（Function Overload）

*   1.  函数重载的规则
    
    *   函数名相同
    *   参数个数不同 `||` 参数类型不同 `||` 参数标签不同
    
        func sum(value1: Int, value2: Int) -> Int { value1 + value2 } 
        // 参数个数不同
        func sum(_ value1: Int, _ value2: Int, _ value3: Int) -> Int { value1 + value2 +  value3 } 
        // 参数标签不同
        func sum(_ a: Int, _ b: Int) -> Int {a + b} 
        // 参数类型不同
        func sum(_ a: Double, _ b: Double) -> Int { a + b }
        复制代码
    

> **函数重载注意点**

*   2.  返回值类型和函数重载无关 ![-w711](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/04ee76b3d99d48069327272c41494455~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   3.  默认参数值和函数重载一起使用产生二义性时，编译器并不会报错（C++中会报错）

    // 不建议的写法
    func sum(_ value1: Int, _ value2: Int, _ value3: Int = 5) -> Int { v1 + v2 + v3 }
    func sum(_ value1: Int, _ value2: Int) -> Int { v1 + v2 } 
    //会调用sum(v1: Int, v2: Int)
    sum(10, 2)
    复制代码

*   4.  可变参数、省略参数标签、函数重载一起使用产生二义性时，编译器有可能会报错 ![-w723](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/257277aa85cf430994085cd31cebe3f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 10.10 内联函数（Inline Function）

如果开启了编译器优化（`Release模式`默认会开启优化），编译器会自动将某些函数变成`内联函数`

*   将函数调用展开成函数体 ![-w829](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/acd280a16b4f4358b5177df8f50f02f2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**我们分别来观察下更改Debug模式下的优化选项，编译器做了什么**  
1.我们新建一个项目，项目代码如下 ![-w551](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b6edcb39c8e741bfa91d531988986c6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 2. 然后我们先通过反汇编观察没有被优化时的编译器做了什么 ![-w1059](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/358df9cebe764320bc634c24dc50f639~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 可以看到会调用`test函数`，然后`test函数`里面再执行打印

![-w1051](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fd21694cfed94d89a13825e9a42fae1b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3.  现在我们开启`Debug`模型下的优化选项，然后运行程序 ![-w619](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4fc27a11e5554a55a2c388751af7dce3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 发现`print`打印直接就在`main函数`里执行了，没有了`test函数`的调用过程  
    相当于`print函数`直接放到了`main函数`中，编译器会将函数调用展开成函数体 ![-w1061](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5a509bfde464474a4cbe5e667545cac~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> **`哪些函数不会被内联`**

*   函数体比较长
*   包含递归调用
*   包含动态派发（运行时的多态调用(OC、Swift混编的时候才会有运行时`,纯粹的Swift项目是没有runtime的`)）

> **`@inline`** **我们可以使用`@inline`关键字，来主动控制编译器是否做进行优化**

*   1.  `@inline(nerver)`：永远不会被内联，即使开启了编译器优化
    
        @inline(nerver) func test() {}
        复制代码
    
*   2.  `@inline(__alaways)`：开启编译器优化后，即使代码很长，也会被内联（递归调用和动态派发除外）
    
        @inline(__alaways) func test() {}
        复制代码
    
*   3.  在`Release模式下`，编译器已经开启优化，会自动决定哪些函数需要内联，因此没必要使用`@inline`

### 10.11 函数类型（Function Type）

*   1.  每一个函数都是有类型的，函数类型由`形参类型`、`返回值类型`组成
    
        func test() {}  // () -> Void 或 () -> ()
        
        
        func sum(a: Int, b: Int) -> Int {
            a + b 
        }// (Int, Int) -> Int
        
        // 定义变量
        var fn: (Int, Int) -> Int = sum
        fn(5, 3) //8  调用时不需要参数标签
        复制代码
    
*   2.  函数类型作为`函数参数`
    
        func sum(v1: Int, v2: Int) -> Int {
           v1 + v2
        }
        
        func difference(v1: Int, v2: Int) -> Int {
          v1 - v2
        }
        
        func printResult(_ mathFn: (Int, Int) -> Int, _ a: Int, _ b: Int) {
          mathFn(a, b)
        }
        
        printResult(difference, 5, 2)// Result: 3
        printResult(sum, 5, 2)// Result: 7
        复制代码
    
*   3.  函数类型作为`函数返回值`  
        返回值是函数类型的函数叫做**高阶函数（`Higher-Order Function`）**
    
        func next(_ input: Int) -> Int {
          input + 1
        }
        
        func previous(_ input: Int) -> Int {
          input - 1
        }
        
        func forward(_ forward: Bool) -> (Int) -> Int {
          forward ? next : previous
        }
        
        forward(true)(3)//4
        forward(false)(3)//2
        复制代码
    

### 10.12 typealias

> 用来给类型起别名

    typealias Byte = Int8
    typealias Short = Int16
    typealias Long = Int64
    
    typealias Date = (year: String, mouth: String, day: String)
    func getDate(_ date: Date) {
        print(date.day)
        print(date.0)
    }
    
    getDate(("2011", "9", "10"))
    
    
    typealias IntFn = (Int, Int) -> Int
    
    func difference(v1: Int, v2: Int) -> Int {
        v1 - v2
    }
    
    let fn: IntFn = difference
    fn(20, 10)
    
    func setFn(_ fn: IntFn) { }
    setFn(difference)
    
    func getFn() -> IntFn { difference }
    复制代码

按照`Swift标准库`的定义，`Void`就是`空元组()`

![-w314](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6b84a65143cf4123a83a08f943af6be0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 10.13 嵌套函数(Nested Function)

*   1.  将函数定义在函数内部
    
        func forward(_ forward: Bool) -> (Int) -> Int {
                func next(_ input: Int) -> Int {
                        input + 1
                }
        
                func previous(_ input: Int) -> Int {
                        input - 1
                }
        
                forward ? next : previous
        }
        
        forward(true)(3)//4
        forward(false)(3)//2
        复制代码
    

11\. 枚举
-------

### 11.1 枚举的基本用法

    enum Direction {
        case north
        case south
        case east
        case west
    }
    
    // 简便写法
    enum Direction {
        case north, south, east, west
    }
    
    var dir = Direction.west
    dir = Direction.east
    dir = .north
    print(dir) // north
    
    switch dir {
    case .north:
        print("north")
    case .south:
        print("south")
    case .east:
        print("east")
    case .west:
        print("west")
    }
    复制代码

### 11.2 关联值（Associated Values）

有时会将`枚举的成员值`和`其他类型的值`关联 **`存储在一起`** ,会非常有用

    enum Score {
         case points(Int)
         case grade(Character)
    }
    
    var score = Score.points(96)
    score = .grade("A")
    
    switch score {
    case let .points(i):
      debugPrint(i)
    case let .grade(i):
      debugPrint(i)
    }
    复制代码

    enum Date {
        case digit(year: Int, month: Int, day: Int)
        case string(String)
    }
    
    var date = Date.digit(year: 2020, month: 12, day: 5)
    date = .string("2022-07-10")
    //必要时【let】也可以改为【var】
    switch date {
    case .digit(let year, let month, let day):
      debugPrint(year, month, day)
    case let .string(value):
      debugPrint(value)
    }
    复制代码

> 关联值举例 ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/213b2a7017054921aab9ff40adb7f450~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) ![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ef6d6b00633049bd9d7052042ffdb84f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

    enum Password {
        case number(Int, Int, Int, Int)
        case gesture(String)
    }
    
    var pwd = Password.number(5, 6, 4, 7)
    pwd = .gesture("12369")
    
    switch pwd {
    case let .number(n1, n2, n3, n4):
        print("number is ", n1, n2, n3, n4)
    case let .gesture(str):
        print("gesture is ", str)
    }
    复制代码

必要时,使用了枚举关联值的`switch-case`语句 里面的 `let`也可以改成`var`

### 11.3 原始值（Raw Values）

枚举成员可以使用`相同类型`的默认值预先关联，这个默认值叫做`原始值`

    enum PokerSuit: String {
       case spade = "♠"
       case heart = "♥"
       case diamond = "♦" 
       case club = "♣"
    }
    
    let suit = PokerSuit.heart
    debugPrint(suit)// heart
    debugPrint(suit.rawValue)// ♥
    debugPrint(PokerSuit.spade.rawValue)// ♠ 
    复制代码

    enum Grade : String { 
        case perfect = "A" 
        case great = "B" 
        case good = "C" 
        case bad = "D" 
    } 
    print(Grade.perfect.rawValue) // A 
    print(Grade.great.rawValue) // B 
    print(Grade.good.rawValue) // C
    print(Grade.bad.rawValue) // D
    复制代码

注意:

*   原始值不占用枚举变量的内存
*   原始值只是关联上了枚举变量，所以原始值占用内存的大小并不是枚举变量的大小
*   底层实现是通过计算属性/函数来获取原始值的

### 11.4 隐式原始值(Implicitly Assigned Raw Values)

如果枚举的原始值类型是`Int`、`String`，Swift会自动分配原始值

字符串默认分配的原始值就是其变量名

    enum Direction: String {
        case north = "north"
        case south = "south"
        case east = "east"
        case west = "west"
    }
    
    // 等价于上面
    enum Direction: String {
         case north, south, east, west
    }
    print(Direction.north) // north
    print(Direction.north.rawValue) // north
    复制代码

**`Int类型`默认分配的原始值是从0开始递增的数字**

    enum Season: Int {
        case spring, summer, autumn, winter
    }
    
    print(Season.spring.rawValue) // 0
    print(Season.summer.rawValue) // 1
    print(Season.autumn.rawValue) // 2
    print(Season.winter.rawValue) // 3
    复制代码

**如果有指定原始值的，下一个就会按照已经指定的值递增分配**

    enum Season: Int {
        case spring = 1, summer, autumn = 4, winter
    } 
    print(Season.spring.rawValue) // 1
    print(Season.summer.rawValue) // 2
    print(Season.autumn.rawValue) // 4
    print(Season.winter.rawValue) // 5
    复制代码

### 11.5 递归枚举（Recursive Enumeration）

*   1.  递归枚举要用`indirect`关键字来修饰`enum`，不然会报错
    
        indirect enum ArithExpr {
            case number(Int)
            case sum(ArithExpr, ArithExpr)
            case difference(ArithExpr, ArithExpr)
        }
        
        或者
        
        enum ArithExpr {
            case number(Int)
            indirect case sum(ArithExpr, ArithExpr)
            indirect case difference(ArithExpr, ArithExpr)
        }
        
        let five = ArithExpr.number(5)
        let four = ArithExpr.number(4)
        let sum = ArithExpr.sum(five, four)
        let two = ArithExpr.number(2)
        let difference = ArithExpr.difference(sum, two)
        
        func calculate(_ expr: ArithExpr) -> Int {
            switch expr {
            case let .number(value):
                return value
            case let .sum(left, right):
                return calculate(left) + calculate(right)
            case let .difference(left, right):
                return calculate(left) - calculate(right)
            }
        }
        
        calculate(difference)
        复制代码
    

### 11.6 MemoryLayout

*   1.  可以使用`MemoryLayout`获取数据类型占用的内存大小  
        `64bit`的`Int类型`占`8个字节`
        
            let age = 10
            
            MemoryLayout<Int>.stride // 8, 分配占用的空间大小
            MemoryLayout<Int>.size // 8, 实际用到的空间大小
            MemoryLayout<Int>.alignment // 8, 内存对齐参数
            
            等同于
            
            MemoryLayout.size(ofValue: age)
            MemoryLayout.stride(ofValue: age)
            MemoryLayout.alignment(ofValue: age)
            复制代码
        

关联值和原始值的区别：

*   关联值类型会存储到枚举变量里面
    
*   原始值因为一开始就会知道默认值是多少，所以只做记录，不会存储
    
        enum Password {
            case number(Int, Int, Int, Int)
            case other
        }
        
        MemoryLayout<Password>.stride // 40，分配占用的空间大小
        MemoryLayout<Password>.size // 33，实际用到的空间大小
        MemoryLayout<Password>.alignment // 8，对齐参数
        复制代码
    
        enum Session: Int {
             case spring, summer, autnmn, winter
        }
        
        MemoryLayout<Session>.stride // 1，分配占用的空间大小
        MemoryLayout<Session>.size // 1，实际用到的空间大小
        MemoryLayout<Session>.alignment // 1，对齐参数
        复制代码
    

> **思考下面枚举变量的内存布局:** **案例1:**

    enum TestEnum { 
        case test1, test2, test3 
    } 
    var t = TestEnum.test1
    t = .test2 
    t = .test3
    MemoryLayout<TestEnum>.stride // 1，分配占用的空间大小
    MemoryLayout<TestEnum>.size // 1，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment // 1，对齐参数
    复制代码

**案例2:**

    enum TestEnum : Int {
        case test1 = 1, test2 = 2, test3 = 3 
    }
    var t = TestEnum.test1 
    t = .test2 
    t = .test3
    MemoryLayout<TestEnum>.stride // 1，分配占用的空间大小
    MemoryLayout<TestEnum>.size // 1，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment // 1，对齐参数
    复制代码

**案例3:**

    enum TestEnum {
        case test1(Int, Int, Int)
        case test2(Int, Int)
        case test3(Int) 
        case test4(Bool) 
        case test5
    } 
    var e = TestEnum.test1(1, 2, 3)
    e = .test2(4, 5)
    e = .test3(6) 
    e = .test4(true)
    e = .test5
    MemoryLayout<TestEnum>.stride // 32，分配占用的空间大小
    MemoryLayout<TestEnum>.size // 25，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment // 8，对齐参数
    复制代码

**案例4:**

    //注意！！！！   枚举选项只有一个,所以实际用到的内存空间 为0，但是要存储一个成员值 所以对其参数为1，给其分配一个字节
    enum TestEnum { 
        case test
    } 
    var t = TestEnum.test
    MemoryLayout<TestEnum>.stride // 1，分配占用的空间大小
    MemoryLayout<TestEnum>.size // 0，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment // 1，对齐参数
    复制代码

**案例5:**

    enum TestEnum { 
        case test(Int)
    } 
    var t = TestEnum.test(10)
    MemoryLayout<TestEnum>.stride // 8，分配占用的空间大小
    MemoryLayout<TestEnum>.size // 8，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment // 8，对齐参数
    复制代码

**案例6:**

    enum TestEnum { 
        case test(Int)
    } 
    var t = TestEnum.test(10)
    MemoryLayout<TestEnum>.stride // 8，分配占用的空间大小
    MemoryLayout<TestEnum>.size // 8，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment // 8，对齐参数
    复制代码

**案例7:**

    enum TestEnum { 
        case test0 
        case test1 
        case test2 
        case test4(Int) 
        case test5(Int, Int)
        case test6(Int, Int, Int, Bool)
    } 
    var t = TestEnum.test(10)
    MemoryLayout<TestEnum>.stride // 32，分配占用的空间大小
    MemoryLayout<TestEnum>.size // 25，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment // 8，对齐参数
    复制代码

**案例8:**

    enum TestEnum { 
        case test0 
        case test1 
        case test2 
        case test4(Int) 
        case test5(Int, Int)
        case test6(Int, Int, Bool, Int)
    } 
    var t = TestEnum.test(10)
    MemoryLayout<TestEnum>.stride // 32，分配占用的空间大小
    MemoryLayout<TestEnum>.size // 32，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment // 8，对齐参数
    复制代码

**案例9:**

    enum TestEnum { 
        case test0 
        case test1 
        case test2 
        case test4(Int) 
        case test5(Int, Int)
        case test6(Int, Bool, Int)
    } 
    var t = TestEnum.test(10)
    MemoryLayout<TestEnum>.stride //32，分配占用的空间大小
    MemoryLayout<TestEnum>.size //25，实际用到的空间大小
    MemoryLayout<TestEnum>.alignment //8，对齐参数
    复制代码

### 11.7 枚举变量的内存布局

我们知道通过`MemoryLayout`可以获取到枚举占用内存的大小，那枚举变量分别占用多少内存呢？

要想知道枚举变量的大小，我们需要通过查看枚举变量的内存布局来进行分析

**枚举变量的分析准备**

我们可以需要通过`Xcode`里的`View Memory`选项来查看详细的内存布局

1.可以在运行程序时，通过控制台打印的枚举变量右键选择`View Memory of *`进入到内存布局的页面

![-w440](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5735d2c4062b49689021b7ffda252428~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2.还可以从`Xcode`标题栏中选择`Debug -> Debug Workflow -> View Memory`进入到内存布局的页面

![-w569](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f74e3c087f614a4290c7dfb272c1c0fb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3.进入到该页面，然后通过输入变量的内存地址来查看

![-w1129](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/818945a0d9f742fa9adacb4be5803ea3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4.我们可以下载一个小工具来获取到变量的内存地址

下载地址：[github.com/CoderMJLee/…](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FCoderMJLee%2FMems "https://github.com/CoderMJLee/Mems")

5.然后将下载好的这个文件`Mems.swift`拖到自己的`Xcode`中

调用这个函数就可以了

    print(Mems.ptr(ofVal: &t))
    复制代码

**我们来分析下面的枚举变量的情况**

    enum TestEnum {
        case test1, test2, test3
    }
    
    var t = TestEnum.test1
    print(Mems.ptr(ofVal: &t))
    
    t = TestEnum.test2
    t = TestEnum.test3
    
    print(MemoryLayout<TestEnum>.stride) // 1
    print(MemoryLayout<TestEnum>.size) // 1
    print(MemoryLayout<TestEnum>.alignment) // 1
    复制代码

分别将断点打在给`枚举变量t`赋值的三句代码上，然后运行程序观察每次断点之后的内存布局有什么变化

![-w1127](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b3707ff07b0142e68f0e0471423f4ffc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w1124](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e44ad20c1e9d4b6eb27ed0706ea5a625~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w1124](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aaa99ae5371e49e4a708ba9b6431a077~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上图可以看到，每个枚举变量都分配了一个字节的大小，并且存储的值分别是0、1、2，我们可以知道这一个字节的大小就是用来存储`枚举成员值`的

**我们再来分析一个枚举变量的情况**

    enum TestEnum: Int {
        case test1 = 1, test2 = 2, test3 = 3
    }
    
    var t = TestEnum.test1
    print(Mems.ptr(ofVal: &t))
    
    t = TestEnum.test2
    t = TestEnum.test3
    
    print(MemoryLayout<TestEnum>.stride) // 1
    print(MemoryLayout<TestEnum>.size) // 1
    print(MemoryLayout<TestEnum>.alignment) // 1
    复制代码

![-w1131](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f8b07ec91b874385b845918724871429~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w1126](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5ae262e720a4c3292957b0115e8dd6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w1125](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/74a579894f614963a3781c23a51e7974~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过上图可以看到，每个枚举变量存储的值也是0、1、2，并且分配了一个字节的大小

可以证明枚举变量的内存大小和原始值类型无关，而且枚举变量里存储的值和原始值也无关

**我们再来分析一个枚举变量的情况**

    enum TestEnum {
        case test1(Int, Int, Int) // 24
        case test2(Int, Int) // 16
        case test3(Int) // 8
        case test4(Bool) // 1
        case test5 // 1
    }
    
    var t = TestEnum.test1(1, 2, 3)
    print(Mems.ptr(ofVal: &t))
    
    t = TestEnum.test2(4, 5)
    t = TestEnum.test3(6)
    t = TestEnum.test4(true)
    t = TestEnum.test5
    
    MemoryLayout<TestEnum>.size // 25
    MemoryLayout<TestEnum>.stride // 32
    MemoryLayout<TestEnum>.alignment // 8
    复制代码

我们先通过打印了解到枚举类型总共分配了`32个字节`，然后我们通过断点分别来观察枚举变量的内存布局

![-w773](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3ddde575d93346e6b93197ab125ff3ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1124](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/27bda96fd6df42699bb75099bf79d174~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

执行完第一句我们可以看到，前面24个字节分别用来存储关联值1、2、3，第25个字节用来存储成员值0，之所以分配32个字节是因为内存对齐的原因

    // 调整排版后的内存布局如下所示
    01 00 00 00 00 00 00 00
    02 00 00 00 00 00 00 00
    03 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    复制代码

![-w719](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/666710ea86264b0ca18d84c9f0100b29~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1193](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7a641539783c44769d07ef161b6391d2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

执行完第二句我们可以看到，前面16个字节分半用来存储关联值4、5，然后第25个字节用来存储成员值1

    // 调整排版后的内存布局如下所示
    04 00 00 00 00 00 00 00
    05 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    01 00 00 00 00 00 00 00
    复制代码

![-w563](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4ffec0c54ef14fbca354e62552e34d0f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1196](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4289e9afdf1346108ace6a521d34736b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

执行完第三句我们可以看到，前面8个字节分半用来存储关联值6，然后第25个字节用来存储成员值2

    // 调整排版后的内存布局如下所示
    06 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    02 00 00 00 00 00 00 00
    复制代码

![-w665](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dab2856fa3a54d95b304759492b0118c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1192](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ff4710127fa346a39c3400dad0b0e575~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

执行完第四句我们可以看到，由于是Bool类型，那么只用了第一个字节来存储关联值1，然后第25个字节用来存储成员值3

    // 调整排版后的内存布局如下所示
    01 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    03 00 00 00 00 00 00 00
    复制代码

![-w676](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f1e11f59919e4b6c8bc4331127debff1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w1191](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2227a5c5afbe423ebed7698a7a15be28~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

执行完最后一句我们可以看到，由于没有关联值，那么只用了第25个字节存储成员值4

    // 调整排版后的内存布局如下所示
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    00 00 00 00 00 00 00 00
    04 00 00 00 00 00 00 00
    复制代码

**总结：内存分配情况：一个字节存储成员值，n个字节存储关联值（n取占用内存最大的关联值），任何一个case的关联值都共有这n个字节**

我们再来看几个情况

    enum TestEnum {
        case test
    }
    
    MemoryLayout<Session>.stride // 1，分配占用的空间大小
    MemoryLayout<Session>.size // 0，实际用到的空间大小
    MemoryLayout<Session>.alignment // 1，对齐参数
    复制代码

如果枚举里只有一个`case`，那么实际用到的空间为0，都不用特别分配内存来进行存储

    enum TestEnum {
        case test(Int)
    }
    
    MemoryLayout<Session>.stride // 8，分配占用的空间大小
    MemoryLayout<Session>.size // 8，实际用到的空间大小
    MemoryLayout<Session>.alignment // 8，对齐参数
    复制代码

可以看到分配的内存大小就是关联值类型决定的，因为只有一个`case`，所以都不需要再额外分配内存来存储是哪个`case`了

12\. 可选项（Optional）
------------------

*   1.  可选项，一般也叫可选类型，它允许将值设置为`nil`
*   2.  在类型名称后面加个`问号` `?`来定义一个可选项

     ```
        var name: String? = nil
     ```
    
*   3.  如果可选类型定义的时候没有给定值，默认值就是`nil`
    ```
        var age: Int?
        
        等价于
        var age: Int? = nil
    ```
    
*   4.  如果可选类型定义的时候赋值了，那么就是一个`Optional类型`的值
    ```
        var name: String? = "Jack" // Optional(Jack)
    ```
    
*   5.  可选类型也`可以作为函数返回值`使用
    ```
        var array = [1, 2, 3, 4] 
        func get(_ index: Int) -> Int? {
            if index < 0 || index >= array.count {
                return nil
            } 
            return array[index]
        }
    ```
    

### 12.1 强制解包（Forced Unwrapping）

可选项是对其他类型的一层包装，可以理解为一个盒子

*   1.  如果为`nil`，那么它就是个空盒子
*   2.  如果不为`nil`，那么盒子里装的是：**被包装类型的数据**
    ```
        var age: Int?
        age = 10
        age = nil
    ```
    
    *   可选关系的类型大致如下图: ![-w606](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bbb2195a00c4cf190a113afb28a8a07~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   3.  如果要从可选项中取出被包装的数据（将盒子里装的东西取出来），需要使用`感叹号` `!`进行强制解包
    ```
        var age: Int? = 10
        var ageInt = age!
        ageInt += 10 // ageInt为Int类型
    ```
    
*   4.  如果对值为`nil`的可选项（空盒子）进行强制解包，将会产生运行时错误 ![-w668](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e6b492766979492a9eb881d23be02d29~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 12.2 可选项绑定（Optional Binding）

*   1.  我们可以判断可选项是否包含值
    ```
        let number = Int("123") // number为Int?
        
        if number != nil {
            print(number!)
        }
    ```
    
*   2.  还可以使用`可选项绑定`来判断可选项是否包含值
    
    *   如果包含就`自动解包`，把值赋给一个`临时的常量（let）或者变量（var）`，并返回`true`，否则返回`false`
     ```
        if let number = Int("123") {
             print("字符串转换整数成功：(number)")
             // number是强制解包之后的Int值
             // number作用域仅限于这个大括号
        } else {
            print("字符串转换整数失败")
        }
        // 字符串转换整数成功：123
      ```
    
*   3.  如果判断条件有多个，可以合并在一起，用逗号`,`来分隔开
     ```
        if let first = Int("4") {
            if let second = Int("42") {
                if first < second && second < 100 {
                     print("(first) < (second) < 100") 
                } 
            } 
        }
        
        等于
        
        if let first = Int("4")，
            let second = Int("42")，
            first < second && second < 100 {
                print("(first) < (second) < 100")
        }
      ``` 
    
*   4.  `while循环`中使用可选项绑定
    ```
        let strs = ["10", "20", "abc", "-20", "30"]
        
        var index = 0
        var sum = 0
        while let num = Int(strs[index]), num > 0 {
            sum += num
            index += 1
        }
     ```
    

### 12.3 空合并运算符（Nil-Coalescing Operator）

我们可以使用空合并运算符`??`来对前一个值是否有值进行判断:

*   如果前一个值为`nil`，就会返回后一个值 ![-w860](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a597a82e046946ada36ba2ec4a8f3667~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w871](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87b1be7f3acf4654bd9dc5f531b21aeb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**详细用法如下：**

*   **a `??` b**
    *   `a`是**可选项**
    *   `b`是**可选项**或者**不是可选项**
    *   `b`跟`a`的**存储类型必须相同**
    
    *   如果`a`不为`nil`，就返回`a`
        *   如果`b`不是可选项，返回`a`时会自动解包
    *   如果`a`为`nil`，就返回`b`

> **结果的类型取决于`??`后面的值类型是什么**
```
    let a: Int? = 1
    let b: Int = 2
    let c = a ?? b // c是Int , 1 
    
    let a: Int? = nil
    let b: Int = 2
    let c = a ?? b // c是Int , 2
```

> **多个`??`一起使用**
```
    let a: Int? = 1
    let b: Int? = 2
    let c = a ?? b ?? 3 
    
    let a: Int? = nil
    let b: Int? = 2
    let c = a ?? b ?? 3
```
```
    var a: Int??? = 10
    var b: Int = 20
    var c: Int? = 30
    
    print(a ?? b) // Optional(Optional(10))
    print(a ?? c) // Optional(Optional(10))
```

> **`??`和`if let`配合使用**
```
    let a: Int? = nil
    let b: Int? = 2
    if let c = a ?? b {
       print(c)
    }// 类似于if a != nil || b != nil
    
    if let c = a, let d = b {
       print(c)
       print(d)
    }// 类似于if a != nil && b != nil
```

### 12.4 guard语句

*   1.  当`guard语句`的条件为`false`时，就会执行大括号里面的代码
*   2.  当`guard语句`的条件为`true`时，就会跳过`guard语句`
*   3.  `guard语句`适合用来“提前退出”
```   
        guard 条件 else {
            // do something....
            退出当前作用域
            // return、break、continue、throw error
        }
```
    
*   4.  当使用`guard语句`进行可选项绑定时，绑定的`常量（let）、变量（var）`也能在外层作用域中使用
    
        func login(_ info: [String : String]) {
                guard let username = info["username"] else {
                        print("请输入用户名")
                        return
                }
        
                guard let password = info["password"] else {
                        print("请输入密码")
                        return
                }
        
                // if username ....
                // if password ....
                print("用户名：(username)", "密码：(password)", "登录ing")
        }
        login(["username" : "jack", "password" : "123456"]) // 用户名：jack 密码：123456 登陆ing 
        login(["password" : "123456"]) // 请输入密码 
        login(["username" : "jack"]) // 请输入用户名
        复制代码
    
    *   在没有`guard`语句之前,用if-else条件分支语句代码如下(比对):
    
        func login(_ info: [String : String]) { 
            let username: String
            if let tmp = info["username"] {
                username = tmp
            } else {
                print("请输入用户名")
                return 
            } 
            
            let password: String
            if let tmp = info["password"] {
                password = tmp 
            } else {
                print("请输入密码")
                return 
            }
            // if username ....
            // if password ....
            print("用户名：\(username)", "密码：\(password)", "登陆ing") 
        }
        login(["username" : "jack", "password" : "123456"]) // 用户名：jack 密码：123456 登陆ing 
        login(["password" : "123456"]) // 请输入密码 
        login(["username" : "jack"]) // 请输入用户名
        复制代码
    

### 12.5 隐式解包（Implicitly Unwrapped Optional）

*   1.  在某些情况下，可选项一旦被设定值之后，就会一直拥有值
*   2.  在这种情况下，可以去掉检查，也不必每次访问的时候都进行解包，因为他能确定每次访问的时候都有值
*   3.  可以在类型后面加个感叹号`!`定义一个隐式解包的可选项
    
        let num1: Int! = 10
        let num2: Int = num1
        
        if num1 != nil {
            print(num1 + 6)
        }
        
        if let num3 = num1 {
            print(num3)
        }
        复制代码
    

如果对空值的可选项进行隐式解包，也会报错: ![-w687](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6f4c0ffe2df948bd931cbbde5d9828fc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

用隐式解包的可选项类型，**大多数是希望别人要给定一个不为空的值**

*   如果别人传的是个空值那就报错，目的就是制定你的规则，**更多适用于做一个接口来接收参数**；
*   **更多还是建议不使用该类型**

### 12.6 字符串插值

*   1.  可选项在字符串插值或者直接打印时，编译器会发出警告 ![-w708](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5fe6df8f0c1e47dca77116ea8eba93aa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   2.  至少有三种方法消除警告
    
        var age: Int? = 10
        
        print("My age is \(age!)") // My age is 10
        print("My age is \(String(describing: age))") // My age is Optional(10)
        print("My age is \(age ?? 0)") // My age is 10
        复制代码
    

### 12.7 多重可选项

*   1.  看下面几个可选类型，可以用以下图片来解析
    
        var num1: Int? = 10
        var num2: Int?? = num1
        var num3: Int?? = 10 
        
        print(num2 == num3) // true
        复制代码
    
    ![-w787](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c8d7cd77721747a595d8d6d7ddfeaed4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    
*   2.  可使用`lldb`指令`frame variable -R`或者`fr v -R`查看区别 ![-w1124](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/543a56b813164199980919899a2adbb6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   3.  看下面几个可选类型，可以用以下图片来解析
    
        var num1: Int? = nil
        var num2: Int?? = num1
        var num3: Int?? = nil
        
        print(num2 == num3) // false
        print(num3 == num1) // false（因为类型不同）
        
        (num2 ?? 1) ?? 2 // 2
        (num3 ?? 1) ?? 2 // 1
        复制代码
    

![-w784](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f1a5e933b9b245b2a641a9ef21cb13b9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   4.  不管是多少层可选项，一旦赋值为`nil`，就只有最外层一个大盒子  
        可使用`lldb`指令`frame variable -R`或者`fr v -R`查看区别 ![-w1126](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/154d7c248b6a4837a648d63e71d4868f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

13\. 闭包
-------

### 13.1 闭包表达式（Closure Expression）

*   1.  在Swift中，可以通过`func`定义一个函数，也可以通过`闭包表达式`定义一个函数
*   2.  闭包表达式格式如下:
    
        {
            (参数列表) -> 返回值类型 in
            函数体代码
        }
        复制代码
    
        var fn = {
            (v1: Int, v2: Int) -> Int in
            return v1 + v2
        }
        fn(10, 20)
        
        {
            (v1: Int, v2: Int) -> Int in
            return v1 + v2
        }(10, 20)
        复制代码
    
*   3.  闭包表达式的简写如下:
    
    *   case1
    
        var fn = {
            (v1: Int, v2: Int) -> Int in
            return v1 + v2
        }
        
        var fn: (Int, Int) -> Int = { $0 + $1 }
        复制代码
    
    *   case2
    
        func exec(v1: Int, v2: Int, fn: (Int, Int) -> Int) {
            print(fn(v1, v2))
        }
        
        
        exec(v1: 10, v2: 20) {
            (v1, v2) -> Int in
            return v1 + v2
        }
        
        exec(v1: 10, v2: 20, fn: {
            (v1, v2) -> Int in
            return v1 + v2
        })
        
        exec(v1: 10, v2: 20, fn: {
            (v1, v2) -> Int in
            v1 + v2
        })
        
        exec(v1: 10, v2: 20, fn: {
            v1, v2 in return v1 + v2
        })
        
        exec(v1: 10, v2: 20, fn: {
            v1, v2 in v1 + v2
        })
        
        exec(v1: 10, v2: 20, fn: { $0 + $1 })
        
        exec(v1: 10, v2: 20, fn: +)
        复制代码
    

### 13.2 尾随闭包

*   1.  如果将一个**很长的闭包表达式**作为`函数的最后一个实参`，使用尾随闭包可以增强函数的可读性
*   2.  尾随闭包是一个被书写在函数调用括号外面（后面）的闭包表达式
    
        func exec(v1: Int, v2: Int, fn: (Int, Int) -> Int) {
            print(fn(v1, v2))
        }
        
        exec(v1: 10, v2: 20) {
            $0 + $1
        }
        复制代码
    
*   3.  如果闭包表达式是函数的唯一实参，而且使用了尾随闭包的语法，那就不需要在函数名后边写圆括号
    
        func exec(fn: (Int, Int) -> Int) {
            print(fn(1, 2))
        }
        
        exec(fn: { $0 + $1 })
        exec() { $0 + $1 }
        exec { $0 + $1 }
        exec { _, _ in 10 }
        复制代码
    

> **Swift中的`sort函数`用来排序的，使用的就是闭包的写法** ![-w449](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f9ca96482e64b23a2070103d27e0864~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w597](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c14249c8cbee44eabecb4d75ac969fbc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

    var nums = [11, 2, 18, 6, 5, 68, 45]
    
    //1.
    nums.sort()
    
    //2.
    nums.sort { (i1, i2) -> Bool in
        i1 < i2
    }
    
    //3.
    nums.sort(by: { (i1, i2) in return i1 < i2 })
    
    //4.
    nums.sort(by: { (i1, i2) in return i1 < i2 })
    
    //5.
    nums.sort(by: { (i1, i2) in i1 < i2 })
    
    //6.
    nums.sort(by: { $0 < $1 })
    
    //7.
    nums.sort(by: <)
    
    //8.
    nums.sort() { $0 < $1 }
    
    //9.
    nums.sort { $0 < $1 }
     
    //10.
    print(nums) // [2, 5, 6, 11, 18, 45, 68]
    复制代码

### 13.3 闭包的定义（Closure）

网上有各种关于闭包的定义，个人觉得比较严谨的定义是:\\

*   一个函数和它所捕获的`变量/常量`环境组合起来，称为闭包
    
    *   一般指定义在函数内部的函数
    *   一般它捕获的是外层函数的局部变量\\常量
    *   全局变量,全局都可以访问,内存只有一份,且只要程序不停止运行,其内存就不会回收
    
        typealias Fn = (Int) -> Int
        
        func getFn() -> Fn {
            var num = 0
            func plus(_ i: Int) -> Int {
                num += i
                return num
            }
            return plus
        }
        复制代码
    
        func getFn() -> Fn {
            var num = 0
            return {
                num += $0
                return num
            }
        }
        复制代码
    
         var fn1 = getFn()
         var fn2 = getFn() 
         
         fn1(1) // 1
         fn2(2) // 2
         fn1(3) // 4 
         fn2(4) // 6
         fn1(5) // 9 
         fn2(6) // 12
        复制代码
    

> **通过汇编分析闭包的实现** 看下面示例代码，分别打印为多少

    func getFn() -> Fn {
        var num = 0
        func plus(_ i: Int) -> Int {
            num += i
            return num
        }
        return plus
    }
    
    var fn = getFn()
    
    print(fn(1)) // 1
    print(fn(2)) // 3
    print(fn(3)) // 6
    print(fn(4)) // 10
    复制代码

我们通过反汇编来观察: ![-w1012](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d6738fd229b74dda8a490a4af0749cb6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 通过这句调用可以看出:

*   在`return plus`之前，闭包(表层通过`allicObject`)底层会调用`malloc函数`进行堆内存的分配，也就是将拷贝num的值到堆上来持有不被释放
*   而栈里的num由于`getFn`调用完毕就随着栈释放了，`plus函数`里操作的都是堆上的num
*   调用`malloc函数`之前需要告诉系统要分配多少内存，需要24个字节来存储内存
    *   (因为在iOS系统中,分配堆内存的底层算法有内存对齐的概念，内存对齐的参数是16)而通过`malloc函数`分配的内存都是大于或等于其本身数据结构所需内存的16的最小倍数，所以会分配32个字节内存

![-w1014](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/46c0949ee2ef49bda6a3dd1e72f8c0f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w596](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/97ddb3df35cc4d7bb056ede40594e683~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们打印`rax寄存器`的值可以知道:

*   系统分配的32个字节，前16个字节用来存储其他信息
*   而且从图上的圈起来的地方也可以看到，将0移动16个字节
*   所以16个字节之后的8个字节才用来存储num的值

![-w532](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9dcceef7db894af68271c5622ac1db14~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

调用`fn(1)`，将断点打在这里，然后查看反汇编指令

![-w1009](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2b0e109bf5ef45089e0d082fd181a8ed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w575](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e3b2bc9e7751486e9241c76521fcb8bd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

然后调用到`plus函数`内部，再次打印`rax寄存器`的值，发现num的值已经变为1了

![-w575](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e5341d04835242f9acb064f3c5c99601~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

然后继续往下执行调用`fn(2)`，发现num的值已经变为3了

![-w606](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/369ab4213cdf41908e77b2c703499416~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

然后继续往下执行调用`fn(3)`，发现num的值已经变为6了

![-w596](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/719e3ef11cb747e6aca1260882450353~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

然后继续往下执行调用`fn(4)`，发现num的值已经变为10了

**闭包和类的相似之处**

我们可以把闭包想像成是一个类的实例对象

*   内存在堆空间
*   捕获的局部变量\\常量就是对象的成员（存储属性）
*   组成闭包的函数就是类内部定义的方法

类似如下示例

    class Closure {
        var num = 0
        
        func plus(_ i: Int) -> Int {
            num += i
            return num
        }
    }
    
    var cs = Closure()
    cs.plus(1)
    cs.plus(2)
    cs.plus(3)
    cs.plus(4)
    复制代码

而且通过反汇编也能看出类和闭包的共同之处:

*   分配的堆内存空间前16个字节都是用来存储`数据类型信息`和`引用计数`的

> **再看下面的示例**

如果把num变成全局变量呢，还会不会分配堆内存

    typealias Fn = (Int) -> Int
    
    var num = 0
    
    func getFn() -> Fn {
    
        func plus(_ i: Int) -> Int {
            num += i
            return num
        }
        return plus
    }
    
    var fn = getFn()
    
    print(fn(1)) // 1
    print(fn(2)) // 3
    print(fn(3)) // 6
    print(fn(4)) // 10
    复制代码

我们通过反汇编可以看到，系统不再分配堆内存空间了

![-w717](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d6a93827e65740c592f1a633795568cb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

> **注意:** 如果返回值是函数类型，那么参数的修饰要保持统一

    func add(_ num: Int) -> (inout Int) -> Void {
        func plus(v: inout Int) {
            v += num
        }
        
        return plus
    }
    
    var num = 5
    add(20)(&num)
    
    print(num)
    复制代码

### 13.4 自动闭包

我们先看下面的示例代码

如果调用`getFirstPositive`并传入两个参数，第一个参数符合条件，但是还需要调用`plus`来得到第二个参数，这种设计相比就稍许有些浪费了

    // 如果第1个数大于0，返回第一个数。否则返回第2个数
    func getFirstPositive(_ v1: Int, _ v2: Int) -> Int {
        v1 > 0 ? v1 : v2
    }
    
    func plus(_ num1: Int, _ num2: Int) -> Int {
        print("haha")
        return num1 + num2
    }
    
    getFirstPositive(10, plus(2, 4))
    复制代码

我们进行了一些优化，将第二个参数的类型变为函数，只有条件成立的时候才会去调用

    func getFirstPositive(_ v1: Int, _ v2: () -> Int) -> Int {
        v1 > 0 ? v1 : v2()
    }
    
    func plus(_ num1: Int, _ num2: Int) -> Int {
        print("haha")
        return num1 + num2
    }
    
    getFirstPositive(10, { plus(2, 4)} )
    复制代码

这样确定能够满足条件避免多余的调用，但是可读性就会差一些

> **我们可以使用`自动闭包@autoclosure`来修饰形参**

*   1.  `@autoclosure`会将传进来的类型包装成闭包表达式，这是编译器特性
*   2.  `@autoclosure`只支持`() -> T`格式的参数
    
        func getFirstPositive(_ v1: Int, _ v2: @autoclosure () -> Int) -> Int {
            v1 > 0 ? v1 : v2()
        }
        
        func plus(_ num1: Int, _ num2: Int) -> Int {
            print("haha")
            return num1 + num2
        }
        
        getFirstPositive(10, plus(2, 4))
        复制代码
    
*   3.  `@autoclosure`并非只支持最后一个参数
    
        func getFirstPositive(_ v1: Int, _ v2: @autoclosure () -> Int, _ v3: Int) -> Int 
        {
            v1 > 0 ? v1 : v2()
        }
        复制代码
    
*   4.  `空合并运算符??`中就使用了`@autoclosure`来将`??`后面的参数进行了包装 ![-w860](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd984c9d6f3643dab1b92ab556f30183~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   5.  有`@autoclosure`和无`@autoclosure`会构成函数重载，不会报错
    
        func getFirstPositive(_ v1: Int, _ v2: () -> Int) -> Int {
            v1 > 0 ? v1 : v2()
        }
        
        func getFirstPositive(_ v1: Int, _ v2: @autoclosure () -> Int) -> Int {
            v1 > 0 ? v1 : v2()
        }
        复制代码
    

**注意：为了避免与期望冲突，使用了`@autoclosure`的地方最好明确注释清楚：这个值会被推迟执行**

### 13.5 通过汇编进行底层分析

**1.分析下面这个函数的内存布局**

    func sum(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
    
    var fn = sum
    print(MemoryLayout.stride(ofValue: fn)) // 16
    复制代码

反汇编之后 ![-w717](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a4ba5da513114259b612ace0f69a5aed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 可以看到:

*   底层会先计算sum的值，然后移动到fn的前8个字节
*   再将0移动到fn的后8个字节，总共占用16个字节 ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7b5f06739b3245a58064cb8f6a325600~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

两个地址相差8个字节，所以是连续的，都表示fn的前后8个字节的地址值

**2.分析下面这个函数的内存布局**

    typealias Fn = (Int) -> Int
    
    func getFn() -> Fn {
        var num = 0
        
        func plus(_ i: Int) -> Int {
            return i
        }
        return plus
    }
    
    var fn = getFn()
    
    print(Mems.size(ofVal: &fn)) // 16
    复制代码

反汇编之后 ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a378d1df3a52495fb11f4faeb14dd569~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们能看到:

*   1.  先调用`getFn`
*   2.  之后`rax`和`rdx`会给fn分配16个字节

然后我们进入`getFn`看看`rax`和`rdx`存储的值分别是什么

![-w715](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ad095c56c2a84749ad673f279bd1931e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

可以看到会将`plus的返回值`放到`rax`中 ![-w949](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/085cd31f92be495199b099b63083aa34~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

可以看到`ecx`和自己进行异或运算，并把结果0存储到`rdx`中

所以回过头看第一张图就知道了，fn的`16`个字节中，前8个字节存储的是`plus`的返回值，后8个字节存储的是0  
等同于将`plus函数`赋值给fn

    var fn = plus()
    复制代码

**3.分析下面这个函数的内存布局**

我们将上面示例里的`plus函数`内部对num进行捕获，看看其内存布局有什么变化

    typealias Fn = (Int) -> Int
    
    func getFn() -> Fn {
        var num = 0
        
        func plus(_ i: Int) -> Int {
            num += i
            return num
        }
        return plus
    }
    
    var fn = getFn()
    
    fn(1)
    fn(2)
    fn(3)
    
    print(Mems.size(ofVal: &fn)) // 16
    复制代码

反汇编之后

![-w945](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/359c67b88a43494086592a1db8b278e1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们可以看到，调用完`getFn`之后，会分别将`rax`和`rdx`的值移动到`rip+内存地址`，也就是给全局变量fn进行赋值操作

我们通过打印获取fn的内存占用知道是16个字节，fn的前8个字节就是`rax`里存储的值，而后8个字节存储的是`rdx`里的值

我们只需要找到`rax`和`rdx`里分别存储的是什么就可以了

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ded70d76d4864333b63e1a29636cc9f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

可以看到在堆空间分配完内存之后的`rax`给上面几个都进行了赋值，最后的`rdx`里存储的就是堆空间的地址值

![-w944](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/647e6838c3f24c4eb26ef62086e1d306~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

从这句看`rax`里存储的应该是和`plus函数`相关，下面我们就要找到`rax`里存储的是什么

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/905044a7ab2e4a6092d55c9c4f0f71c2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w946](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1f1a75e937114d70811f800dc4f78bf7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

而且我们调用fn(1)时也可以推导出是调用的全局变量fn的前八个字节

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7fee0fda6ede44099ed1fe6adab5e262~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

参数1会存储到`edi`中

而经过上面的推导我们知道`-0xf8(%rbp)`中存储的是fn的前8个字节，那么往后8位就是`-0x100(%rbp)`，里面放的肯定就是堆空间的地址值了，存储到了`r13`中

我们在这里打断点，来观察`rax`里到底存储的是什么

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/96ff7d5814604fedb11ba3968cdb7ce4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w946](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f0cd10a8dcbe430cba1fb3675e49deb3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/905e16cba0fd44a48538817ff1df9c8d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/62511fbce3fe436caa43c1e6a671f0c7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w949](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/718280ea6726479ea4c13567165e2145~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

经过一系列的跳转，重要来到了plus真正的函数地址

而且`r13`最后给了`rsi`，`rdi`中存储的还是参数1

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df72a2a945654c71a6b0b194e747d7fa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w946](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2369455bac414bd29408f0a23b3d0a49~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

进到`plus函数`中，然后找到进行相加计算的地方，因为传进来的参数是变化的，所以不可能是和固定地址值进行相加

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5b3056bee744af690d00c5355b5d913~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w946](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/235f74a0520a4ad58200b36fd23a5969~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过推导得知`rcx`里存储的值就是`rdi`中的参数1

![-w945](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/037d3d0619c34d2587f3ffc37ffd1e4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w945](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d961d60c35c54becab0b2e34028a9e9f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过推导得知`rdx`里存储的值就是`rsi`中的堆内存的num地址

所以可以得知`0x10(%rdx)`也就是`rdx`跳过16个字节的值就是num的值

![-w741](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f4d1ea7c9c4944b18af51213921f2bbd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过打印也可以证明我们的分析是正确的

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c28a28b9ae264d3d98844a06e0a5fb2b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w946](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ff502270a2884bde85bf51405764b28f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

通过推导可以发现`rax`中存储的是`rsi`的num的地址值

然后将`rcx`中的值覆盖掉`rax`中的num地址值

而且真正进行捕获变量的时机是在`getFn`即将return之前做的事

**4.分析下面这个函数的内存布局**

我们来看下面这个闭包里的变量会被捕获几次

    typealias Fn = (Int) -> (Int, Int)
    
    func getFns() -> (Fn, Fn) {
        var num1 = 0
        var num2 = 0
    
        func plus(_ i: Int) -> (Int, Int) {
            num1 += i // 6 + 0 = 6, 1 + 4 = 5,
            num2 += i << 1 // 1100 = 12 + 0 = 12, 1000 = 8 + 2 = 10
            return (num1, num2)
        }
    
        func minus(_ i: Int) -> (Int, Int) {
            num1 -= i // 6 - 5 = 1, 5 - 3 = 2
            num2 -= i << 1 // 1010 = 12 - 10 = 2, 0110 = 10 - 6 = 4
            return (num1, num2)
        }
    
        return (plus, minus)
    }
    
    let (p, m) = getFns()
    print(p(6)) // 6, 12
    print(m(5)) // 1, 2
    print(p(4)) // 5, 10
    print(m(3)) // 2, 4
    复制代码

反汇编之后

![-w946](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bd66e2c622e4b06ae82ed5f8fc7e2bb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

发现其底层分别会分配两个堆空间，但是num1、num2也只是分别捕获一次，然后两个函数`plus、minus`共有

14\. 集合类型
---------

### 1.集合类型的定义

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1d558acdd0b241509f7ee8671eca1dff~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) **集合的定义:**

*   集合就是用来存储一组数据的容器。
*   三种典型的集合类型：`数组`、`集合`和`字典`。

### 2.集合和字典

**集合和字典:**

*   集合和字典类型也是存储了`相同类型数据`的集合，但是数据之间是`无序`的。
*   `集合不允许值重复`出现。
*   字典中的值可以重复出现，但是每一个值都有唯一的键值与其对应。

#### 2.1 集合

> 定义

*   集合中的元素是相同数据类型的，并且元素值是唯一的。
*   集合中的元素是无序的。

> 声明格式

*   `Set<DataType>`

##### a.集合的初始化

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/daf562c552d540b083a486076378bcad~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### b.集合的为空判断和元素插入

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5f8969c8b1844499119205b292eb500~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### c.删除元素

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ef393fb0eabb4885872bdad49628d346~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### d.检索特定元素

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e57cadd690554832a3edf594505aa45a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### e.遍历集合

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4556e3d27fa44be1b6c4868c351a1cfc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### f.集合排序

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f8d15a91d5924c31b942d075803cc929~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### g.集合间的运算

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c4e7ecd0c3224945b06e232bc90e26e7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 2.2 字典

##### a. 字典的声明

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5b4dacda5b5542eeac223e9163e7feda~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### b. 字典的初始化

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9d2b97f23ccf44b294fcab0845e97068~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### c. 字典元素的更新

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9469d0c683f341e8a7dc0a2336abd771~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### d. 字典元素的删除

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3f1fee908c04417189ecf6a20e9520c4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### e. 遍历字典

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df8672a4ea784831ae4778a90e99cf24~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

##### f. 字典的keys属性和values属性

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/189cbae4ca9a4e21a50ca59cefdd0d1a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

### 3.数组

**数组定义** 数组是一种按照顺序来存储相同类型数据的集合，相同的值可以多次出现在一个数组中的不同位置

*   类型安全
    *   数组是类型安全的，数组中包含的数据类型必须是明确的
*   声明格式
    *   数组的声明格式为： `Array<DataType>` 或 `[DataType]`

#### 3.1 常用函数

*   1.  `isEmpty` 用来判断数组是否为空
*   2.  `append` 用来向数组的末端添加一个元素

    //实例
    //创建了一个空的字符串数组，然后通过isEmpty来判断数组是否为空，再通过append来添加新的元素到数组中。
    var animalArray = [String]()
    if animalArray.isEmpty {
        print("数组animalArray是空的 ")
    }
    animalArray.append("tiger")
    animalArray.append("lion")
    复制代码

#### 3.2 数组初始化

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/534acc3fd20741749c938805fe40cd24~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.3 数组的相加和累加

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1fd21716f0b543e6bf788df973f2f576~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.4 数组的下标操作

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc3618f5bb684b6aa5e7495c2b48ce4d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.5 插入和删除元素

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e565174695814c728800281db1d982d8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.6 数组的遍历

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3b0dc210590246c8a95927519bc3c483~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.7 数组的片段

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8f32af5fc70f4e77b424ba84018a32a5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?) ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/24ceded110f248d8b56bc25e7de1255e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.8 通过数组片段生成新数组

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b26720d1eea04b6cb68af34fd0bd5795~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.9 元素交换位置

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/64aa272fb9194fd7833e4adf7f6e6a46~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.10 数组排序

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eb57b9d5588d4d8787f1059ad2872047~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

#### 3.11 数组元素的检索

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc507e4c084e460bad9c7a625afcd69f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

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