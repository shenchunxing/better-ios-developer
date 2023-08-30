# Swift5常用核心语法1-基础语法

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
