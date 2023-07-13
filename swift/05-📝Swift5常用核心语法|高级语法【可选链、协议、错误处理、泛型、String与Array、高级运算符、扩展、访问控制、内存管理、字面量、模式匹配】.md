# Swift5常用核心语法2-面向对象语法2

一、概述
====

最近刚好有空,趁这段时间,复习一下`Swift5`核心语法,进行知识储备,以供日后温习 和 进一步探索`Swift`语言的底层原理做铺垫。

本文继前两篇文章:

*   [Swift5核心语法1-基础语法](https://juejin.cn/post/7119020967430455327 "https://juejin.cn/post/7119020967430455327")
*   [Swift5常用核心语法2-面向对象语法1](https://juejin.cn/post/7119510159109390343 "https://juejin.cn/post/7119510159109390343")之后,继续复习`面向对象语法`

二、访问控制（Access Control）
======================

1\. 基本概念
--------

在访问权限控制这块，Swift提供了5个不同的访问级别（以下是从高到低排列，实体指被访问级别修饰的内容）

*   `open`: 允许在定义实体的模块、其他模块中访问，允许其他模块进行继承、重写（open只能用在类、类成员上）
*   `public`: 允许在定义实体的模块、其他模块中访问，不允许其他模块进行继承、重写
*   `internal`: 只允许在定义实体的模块中访问，不允许在其他模块中访问
*   `fileprivate`: 只允许在定义实体的源文件中访问
*   `private`： 只允许在定义实体的封闭声明中访问

绝大部分实体默认都是`internal`级别

2\. 访问级别的使用准则
-------------

*   1.  一个实体不可以被更低访问级别的实体定义
*   2.  变量\\常量类型 ≥ 变量\\常量

    internal class Person {} // 变量类型
    fileprivate var person: Person // 变量 
    复制代码

![-w635](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eea1ff7e061d4999aa10e06cc88f009d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   3\. 参数类型、返回值类型 ≥ 函数

    // 参数类型：Int、Double
    // 函数：func test
    internal func test(_ num: Int) -> Double {
        return Double(num)
    } 
    复制代码

*   4.  父类 ≥ 子类

    class Person {}
    class Student: Person {} 
    复制代码

    public class Person {}
    class Student: Person {} 
    复制代码

![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/253c5018731a4da5b5efb8cd7228dd78~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   5\. 父协议 ≥ 子协议

    public protocol Sportable {}
    internal protocol Runnalbe: Sportable {} 
    复制代码

![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8ed33acfc6054650bacb1de9a9c813e1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   6\. 原类型 ≥ typealias

    class Person {} // 原类型
    private typealias MyPerson = Person 
    复制代码

*   7.  原始值类型\\关联值类型 ≥ 枚举类型

    typealias MyInt = Int
    typealias MyString = String
    
    enum Score {
        case point(MyInt)
        case grade(MyString)
    } 
    复制代码

![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d2da62d6a3d74091819315c6949b036b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   8\. 定义类型A时用到的其他类型 ≥ 类型A

    typealias MyString = String
    
    struct Dog {}
    
    class Person {
        var age: MyString = ""
        var dog: Dog?
    } 
    复制代码

![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/09023b2368544bdb81e245da6d1e9091~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3\. 元组类型
--------

*   元组类型的访问级别是所有成员类型最低的那个

    internal struct Dog { }
    fileprivate class Person { }
    
    // (Dog, Person)中更低的访问级别是fileprivate，所以元组的访问级别就是fileprivate
    fileprivate var datal: (Dog, Person)
    private var data2: (Dog, Person) 
    复制代码

4\. 泛型类型
--------

*   泛型类型的访问级别是类型的访问级别以及所有泛型类型参数的访问级别中最低的那个

    internal class Car {}
    fileprivate class Dog {}
    public class Person<T1, T2> {}
    
    // Person<Car, Dog>中比较的是Person、Car、Dog三个的访问级别最低的那个，也就是fileprivate，fileprivate就是泛型类型的访问级别
    fileprivate var p = Person<Car, Dog>() 
    复制代码

5\. 成员、嵌套类型
-----------

*   1.  类型的访问级别会影响成员（`属性`、`方法`、`初始化器`、`下标`），嵌套类型的默认访问级别
*   2.  一般情况下，类型为`private`或`fileprivate`，那么成员\\嵌套类型默认也是`private`或`fileprivate`

    fileprivate class FilePrivateClass { // fileprivate
        func f1() {} // fileprivate
        private func f2() {} // private
    }
    
    private class PrivateClass { // private
        func f() {} // private
    } 
    复制代码

*   3.  一般情况下，类型为`internal`或`public`，那么成员/嵌套类型默认是`internal`

    public class PublicClass { // public
        public var p1 = 0 // public
        var p2 = 0 // internal
        fileprivate func f1() {} // fileprivate
        private func f2() {} // private
    }
    
    class InternalClass { // internal
        var p = 0 // internal
        fileprivate func f1() {} // fileprivate
        private func f2() {} // private
    } 
    复制代码

**看下面几个示例，编译能否通过？**

示例1

    private class Person {}
    fileprivate class Student: Person {} 
    复制代码

    class Test {
        private class Person {}
        fileprivate class Student: Person {}
    } 
    复制代码

结果是第一段代码编译通过，第二段代码编译报错

![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d750e03e5ce144fe98c26befa71887b7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

第一段代码编译通过，是因为两个全局变量不管是`private`还是`fileprivate`，作用域都是当前文件，所以访问级别就相同了

第二段代码的两个属性的作用域局限到类里面了，那访问级别就有差异了

示例2

    private struct Dog {
        var age: Int = 0
        func run() {}
    }
    
    fileprivate struct Person {
        var dog: Dog = Dog()
        mutating func walk() {
            dog.run()
            dog.age = 1
        }
    } 
    复制代码

    private struct Dog {
        private var age: Int = 0
        private func run() {}
    }
    
    fileprivate struct Person {
        var dog: Dog = Dog()
        mutating func walk() {
            dog.run()
            dog.age = 1
        }
    } 
    复制代码

结果是第一段代码编译通过，第二段代码编译报错 ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/763c5459c3f14f1f876a6c67893bea4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

第一段代码编译通过，是因为两个结构体的访问级别都是该文件内，所以访问级别相同

第二段代码报错是因为Dog里的属性和方法的访问级别是更低的了，虽然两个结构体的访问级别相同，但从Person里调用Dog中的属性和方法是访问不到的

**结论：直接在全局作用域下定义的`private`等于`fileprivate`**

6\. 成员的重写
---------

子类重写成员的访问级别必须 ≥ 子类的访问级别，或者 ≥ 父类被重写成员的访问级别

    class Person {
        internal func run() {}
    }
    
    fileprivate class Student: Person {
        fileprivate override func run() {}
    } 
    复制代码

父类的成员不能被成员作用域外定义的子类重写 ![-w641](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/73b4fef531b8438b8df637149f2c1833~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

放到同一个作用域下

    public class Person {
        private var age: Int = 0
        
        public class Student: Person {
            override var age: Int {
                set {}
                get { 10 }
            }
        }
    } 
    复制代码

7\. getter、setter
-----------------

*   1.  `getter、setter`默认自动接收它们所属环境的访问级别
*   2.  可以给`setter`单独设置一个比`getter`更低的访问级别，用以限制写的权限

    fileprivate(set) public var num = 10
    num = 10
    print(num) 
    复制代码

![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bf43c0b5920a4302902ad7e5ff56a35b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

8\. 初始化器
--------

*   1.  如果一个`public类`想在另一个模块调用编译生成的默认无参初始化器，必须显式提供`public`的无参初始化器，因为`public类`的默认初始化器是`internal`级别
    
        public class Person {
            // 默认生成的，因为是internal，所以外部无法调用到该初始化器
        //    internal init() {
        //
        //    }
        }
        
        变成这样
        
        public class Person {
            // 自己手动添加指定初始化器，并用public修饰，外部才能访问的到
            public init() {
        
            }
        } 
        复制代码
    
*   2.  `required`初始化器 ≥ 它的默认访问级别
    
        fileprivate class Person {
            internal required init() {}
        } 
        复制代码
    
*   3.  当类是`public`的时候，它的默认初始化器就是`internal`级别的，所以不会报错
    
        public class Person {
            internal required init() {}
        } 
        复制代码
    
    ![-w639](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/47ab245d23184e2a9c20f566f14c6555~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
    
*   4.  如果结构体有`private\fileprivate`的存储实例属性，那么它的成员初始化器也是`private\fileprivate`，否则默认就是`internal` ![-w641](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ea49c229a71148738b54d4194a77083a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   5.  结构体里有一个属性设置为private，带有其他属性的初始化器也没有了 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9bbbbab59a884181bfb5b45020035d68~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

9\. 枚举类型的case
-------------

*   1.  不能给`enum`的每个case单独设置访问级别 ![-w641](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/31bbc797440645668025dc4f6101c2c4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   2.  每个case自动接收`enum`的访问级别
    
        fileprivate enum Season {
            case spring // fileprivate
            case summer // fileprivate
            case autumn // fileprivate
            case winter // fileprivate
        } 
        复制代码
    
*   3.  `public enum`定义的case也是`public`
    
        public enum Season {
            case spring // public
            case summer // public
            case autumn // public
            case winter // public
        } 
        复制代码
    

10\. 协议
-------

*   1.  协议中定义的要求自动接收协议的访问级别，不能单独设置访问级别 ![-w637](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/17ae162147ba4460be6e0bbb2e49f20a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   2.  `public`协议定义的要求也是`public`
    
        public protocol Runnable {
            func run()
        } 
        复制代码
    
*   3.  协议实现的访问级别必须 ≥ 类型的访问级别，或者 ≥ 协议的访问级别 ![-w641](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/12a3840994aa443ea9f81a71b2025068~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/16d1b6478fd244b0b6e8cf7f54e91d8e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

11.扩展
-----

*   1.  如果有显式设置扩展的访问级别，扩展添加的成员自动接收扩展的访问级别
    
        class Person {
        
        }
        
        private extension Person {
            func run() {} // private
        } 
        复制代码
    
*   2.  如果没有显式设置扩展的访问级别，扩展添加的成员的默认访问级别，跟直接在类型中定义的成员一样
    
        private class Person {
        
        }
        
        extension Person {
            func run() {} // private
        } 
        复制代码
    
*   3.  可以单独给扩展添加的成员设置访问级别
    
        class Person {
        
        }
        
        extension Person {
            private func run() {} 
        } 
        复制代码
    
*   4.  不能给用于遵守协议的扩展显式设置扩展的访问级别 ![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8c688d9e860454b8417dcc7e6cf2a9d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   5.  在同一文件中的扩展，可以写成类似多个部分的类型声明
*   6.  在原本的声明中声明一个私有成员，可以在同一个文件的扩展中访问它
*   7.  在扩展中声明一个私有成员，可以在同一文件的其他扩展中、原本声明中访问它
    
        public class Person {
            private func run0() {}
            private func eat0() {
                run1()
            }
        }
        
        extension Person {
            private func run1() {}
            private func eat1() {
                run0()
            }
        }
        
        extension Person {
            private func eat2() {
                run1()
            }
        } 
        复制代码
    

12\. 将方法赋值给var\\let
-------------------

*   1.  方法也可以像函数那样，赋值给一个`let`或者`var`
    
        struct Person {
            var age: Int
            func run(_ v : Int) { print("func run", age, v)}
            static func run(_ v: Int) { print("static func run", v)}
        }
        
        let fn1 = Person.run
        fn1(10) // static func run 10
        
        let fn2: (Int) -> () = Person.run
        fn2(20) // static func run 20
        
        let fn3: (Person) -> ((Int) -> ()) = Person.run
        fn3(Person(age: 18))(30) // func run 18 30
        复制代码
    

三、扩展（Extension）
===============

1\. 基本概念
--------

*   1.  Swift中的扩展，类似于`OC`中的`Category`
*   2.  扩展可以为`枚举`、`类`、`结构体`、`协议`添加新功能；可以添加方法、`便捷初始化器`、`计算属性`、`下标`、`嵌套类型`、`协议`等
*   3.  扩展`不能做到`以下这几项
    
    *   不能覆盖原有的功能
    *   不能添加存储属性，不能向已有的属性添加属性观察器
    *   不能添加父类
    *   不能添加指定初始化器，不能添加反初始化器
    *   ....

2\. 计算属性、方法、下标、嵌套类型
-------------------

    extension Double {
        var km: Double { self * 1_000.0 }
        var m: Double { self }
        var dm: Double { self / 10.0 }
        var cm: Double { self / 100.0 }
        var mm: Double { self / 1_000.0 }
    }  
    复制代码

    extension Array {
        subscript(nullable idx: Int) -> Element? {
            if (startIndex..<endIndex).contains(idx) {
                return self[idx]
            }
            return nil
        }
    } 
    复制代码

    extension Int {
        func repetitions(task: () -> Void) {
            for _ in 0..<self { task() }
        }
        
        mutating func square() -> Int {
            self = self * self
            return self
        }
        
        enum Kind { case negative, zero, positive }
        
        var kind: Kind {
            switch self {
            case 0: return .zero
            case let x where x > 0: return .positive
            default: return .negative
            }
        }
        
        subscript(digitIndex: Int) -> Int {
            var decimalBase = 1
            for _ in 0..<digitIndex { decimalBase += 10 }
            return (self / decimalBase) % 10
        }
    } 
    复制代码

3\. 初始化器
--------

    class Person {
        var age: Int
        var name: String
        init (age: Int, name: String) {
            self.age = age
            self.name = name
        }
    }
    
    extension Person: Equatable {
        static func == (left: Person, right: Person) -> Bool {
            left.age == right.age && left.name == right.name
        }
        
        convenience init() {
            self.init(age: 0, name: "")
        }
    } 
    复制代码

*   如果希望自定义初始化器的同时，编译器也能够生成默认初始化器，可以在扩展中编写自定义初始化器
    
        struct Point {
            var x: Int = 0
            var y: Int = 0
        }
        
        extension Point {
            init(_ point: Point) {
                self.init(x: point.x, y: point.y)
            }
        }
        
        var p1 = Point()
        var p2 = Point(x: 10)
        var p3 = Point(y: 10)
        var p4 = Point(x: 10, y: 20)
        var p5 = Point(p4) 
        复制代码
    
*   `required`的初始化器也不能写在扩展中 ![-w634](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/86b30907739b411ba4860320550b8df6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

4.协议
----

*   1.  如果一个类型`已经实现了协议`的所有要求，但是`还没有声明它遵守`了这个协议，`可以通过扩展来让他遵守`这个协议
    
        protocol TestProtocol {
            func test1()
        }
        
        class TestClass {
            func test1() {
                print("TestClass test1")
            }
        }
        
        extension TestClass: TestProtocol { } 
        复制代码
    
        extension BinaryInteger {
            func isOdd() -> Bool {self % 2 != 0 }
        }
        
        print(10.isOdd()) 
        复制代码
    
*   2.  `扩展`可以给`协议`提供`默认实现`，也`间接实现可选协议`的结果  
        `扩展`可以给`协议`扩充协议中从未声明过的方法
    
        protocol TestProtocol {
            func test1()
        }
        
        extension TestProtocol {
            func test1() {
                print("TestProtocol test1")
            }
        
            func test2() {
                print("TestProtocol test2")
            }
        }
        
        class TestClass: TestProtocol { }
        var cls = TestClass()
        cls.test1() // TestProtocol test1
        cls.test2() // TestProtocol test2
        
        var cls2: TestProtocol = TestClass()
        cls2.test1() // TestProtocol test1
        cls2.test2() // TestProtocol test2 
        复制代码
    
        class TestClass: TestProtocol {
            func test1() {
                print("TestClass test1")
            }
        
            func test2() {
                print("TestClass test2")
            }
        }
        
        var cls = TestClass()
        cls.test1() // TestClass test1
        cls.test2() // TestClass test2
        
        var cls2: TestProtocol = TestClass()
        cls2.test1() // TestClass test1
        cls2.test2() // TestProtocol test2 
        复制代码
    

5\. 泛型
------

    class Stack<E> {
        var elements = [E]()
        func push(_ element: E) {
            elements.append(element)
        }
        
        func pop() -> E {
            elements.removeLast()
        }
        
        func size() -> Int {
            elements.count
        }
    }  
    复制代码

*   1.  扩展中依然可以使用原类型中的泛型类型
    
        extension Stack {
            func top() -> E {
                elements.last!
            }
        } 
        复制代码
    
*   2.  符合条件才扩展
    
        extension Stack: Equatable where E : Equatable {
            static func == (left: Stack, right: Stack) -> Bool {
                left.elements == right.elements
            }
        } 
        复制代码
    

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