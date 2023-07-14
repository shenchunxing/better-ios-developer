二、属性
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
    
    swift
    
    复制代码
    
    `struct Point {
     // 存储属性
     var x: Int
     var y: Int
    } 
    let p = Point(x: 10, y: 10)` 
    
*   可以分配一个默认的属性值作为属性定义的一部分
    
    swift
    
    复制代码
    
    `struct Point {
     // 存储属性
     var x: Int = 10
     var y: Int = 10
    } 
    let p = Point()` 
    

### 1.2 计算属性

定义计算属性只能用`var`，不能用`let`

*   `let`代表常量，值是一直不变的
*   计算属性的值是可能发生变化的（即使是只读计算属性）
    
    swift
    
    复制代码
    
    `struct Circle {
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
    print(circle.diameter) // 12.0` 
    
*   set传入的新值默认叫做`newValue`，也可以自定义
    
    swift
    
    复制代码
    
    `struct Circle {
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
    print(circle.diameter)` 
    
*   只读计算属性，只有`get`，没有`set`
    
    swift
    
    复制代码
    
    `struct Circle {
     // 存储属性
     var radius: Double 
     // 计算属性
     var diameter: Double {
     get {
     radius * 2
     }
     }
    }` 
    
    swift
    
    复制代码
    
    `struct Circle {
     // 存储属性
     var radius: Double 
     // 计算属性
     var diameter: Double { radius * 2 }
     }
    }` 
    
*   打印`Circle结构体`的内存大小，其占用才`8个字节`，其本质是因为计算属性相当于函数
    
    swift
    
    复制代码
    
    `var circle = Circle(radius: 5)
    print(Mems.size(ofVal: &circle)) // 8` 
    

> **我们可以通过反汇编来查看其内部做了什么**

*   可以看到内部会调用`set方法`去计算 ![-w723](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cff94714670464aaf1eef4af8da8e12~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   然后我们在往下执行，还会看到`get方法`的调用 ![-w722](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3a9c5db06a704c67bc497a8ca021731e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   所以可以用此证明:计算属性只会生成`getter`和`setter`,不会开辟内存空间

**注意：**

*   一旦将存储属性变为计算属性，初始化构造器就会报错，只允许传入存储属性的值
*   因为存储属性是直接存储在结构体内存中的，如果改成计算属性则不会分配内存空间来存储 ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e864fd3b6104be586e659d1e1f1b02b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w525](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc57b13c70a0424ebbf7f6df42150499~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   如果只有`setter`也会报错 ![-w651](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/510b7dcc067d4d73a7ecc95efd8c7992~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   只读计算属性：只有`get`，没有`set`
    
    swift
    
    复制代码
    
    `struct Circle {
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
    }` 
    

2\. 枚举rawValue原理(计算属性)
----------------------

*   1.  枚举原始值`rawValue`的本质也是计算属性，而且是只读的计算属性
    
    swift
    
    复制代码
    
    `enum TestEnum: Int {
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
    print(TestEnum.test1.rawValue)//10` 
    
*   2.  下面我们去掉自己写的`rawValue`，然后转汇编看下本质是什么样的
    
    *   可以看到底层确实是调用了`getter`
    
    swift
    
    复制代码
    
     `enum TestEnum: Int {
     case test1, test2, test3
     }
     print(TestEnum.test1.rawValue)` 
    
    ![-w717](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6ba17ae69a634b95941c98bd85d2785e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

3\. 延迟存储属性（Lazy Stored Property）
--------------------------------

*   1.  使用`lazy`可以定义一个延迟存储属性，在`第一次用到属性的时候才会进行初始化`
    
    *   看下面的示例代码，如果不加`lazy`，那么Person初始化之后就会进行Car的初始化
    *   加上`lazy`，只有调用到属性的时候才会进行Car的初始化
    
    swift
    
    复制代码
    
    `class Car {
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
    // Car is running!` 
    
*   2.  `lazy`属性必须是`var`，不能是`let`  
        `let`必须在实例的初始化方法完成之前就拥有值
    
    swift
    
    复制代码
    
    `class PhotoView {
     lazy var image: UIImage = {
     let url = "http://www.***.com/logo.png"
     let data = Data(url: url)
     return UIImage(data: data)
     }()
    }` 
    
*   3.  **注意：** `lazy`属性和普通的存储属性内存布局是一样的，不同的只是什么分配内存的时机,而且lazy属性可以通过闭包进行初始化
*   4.  **延迟存储属性的注意点**
    
    *   1.如果多条线程同时第一次访问`lazy`属性，**无法保证属性只被初始化一次**
    *   2.当结构体包含一个延迟存储属性时，只有`var`才能访问延迟存储属性  
        因为延迟存储属性初始化时需要改变结构体的内存 ![-w652](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7d9eacdd4db540e7ab7cc23398bdb62c~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

4\. 属性观察器（Property Observer）
----------------------------

*   1.  可以为非`lazy`的`var存储属性`设置属性观察器
    
    *   只有存储属性可以设置属性观察器
    *   `willSet`会传递新值，默认叫`newValue`
    *   `didSet`会传递旧值，默认叫`oldValue`
    
    swift
    
    复制代码
    
    `struct Circle {
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
    // didSet 1.0 10.5` 
    
*   2.  在初始化器中设置属性值不会触发`willSet`和`didSet`
    
    swift
    
    复制代码
    
    `struct Circle {
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
    var circle = Circle()` 
    
*   3.  在属性定义时设置初始值也不会触发`willSet`和`didSet`
    
    swift
    
    复制代码
    
    `struct Circle {
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
    var circle = Circle()` 
    
*   4.  计算属性设置属性观察器会报错 ![-w657](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f0cb0a9d0e0e45858fa53006840c92ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

5\. 全局变量和局部变量
-------------

*   1.  属性观察器、计算属性的功能，同样可以应用在全局变量和局部变量身上

### 5.1 全局变量

swift

复制代码

`var num: Int {
 get {
 return 10
 }
  
 set {
 print("setNum", newValue)
 }
}
num = 11 // setNum 11
print(num) // 10` 

### 5.2 局部变量

swift

复制代码

`func test() {
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
test()` 

二、inout
=======

1\. inout对属性的影响
---------------

看下面的示例代码，分别输出什么，为什么？

swift

复制代码

`struct Shape { 
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
//width=1, side=20, girth=20` 

**第一段打印**  
初始化的时候会给width赋值为10，side赋值为4，并且不会调用side的属性观察器  
然后调用`test方法`，并传入width的地址值，width变成20  
然后调用`show方法`，会调用girth的getter，然后先执行打印，再计算，girth为80

**下面我们通过反汇编来进行分析** ![-w963](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5fc1d06411345e48b5298b546fc5eb5~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w963](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4b1df2fda6114e7797c514b125c72220~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w965](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a8030cdce64e4915a42fe6e740e88470~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w807](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/77f27418b516496fae9563a089f7c8ba~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

**第二段打印**  
现在width的值是20，side的值是4，girth的值是80  
然后调用`test方法`，并传入side的地址值，side变成20，并且触发属性观察器，执行打印  
然后调用`show方法`，会调用girth的getter，然后先执行打印，再计算，girth为400

**下面我们通过反汇编来进行分析**

![-w960](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2308139e5ef84fdfbe0529d07bbb728e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w351](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4016c951c10349d9b321482156ed3e06~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

将地址值存储到`rdi`中，并带入到`test`函数中进行计算

![-w959](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dc6c66b5d9d94477b8f3ec45a7fd7163~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w960](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18619de80d5e4433bff1110585cbc391~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w870](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fef68a991f484726b25c6404faa16aea~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   `setter`中才会真正的调用`willSet`和`didSet`方法
*   `willSet`和`didSet`之间的计算才是真正的将改变了的值覆盖了全局变量里的side
*   真正改变了side的值的时候是调用完`test函数`之后，在内部的`setter`里进行的

**第三段打印**  
现在width的值是20，side的值是20，girth的值是400  
然后调用`test方法`，并传入girth的getter的返回值为400，然后将20赋值给girth的setter计算，width变为1  
然后调用`show方法`，，会调用girth的getter，然后先执行打印，再计算，girth为20

**下面我们通过反汇编来进行分析**

![-w962](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fe71f0becd65491781c3db4c04ae8f24~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w371](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f44242dece54d9b8d0fddefdffd28c1~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

![-w961](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b9cc4aea2fd4feb863dbc9aedbf2f6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w963](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/230104d8a6ad497e84dca4ed40986ccd~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w425](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4403db87443f44809960b4682a8f0491~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

![-w958](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/31f115cc2baa4beebaa466923e5d557b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w399](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e096666a8f494dbc9ee87abcc9bef9bf~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

![-w961](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/10c3f0965b924847bce7b803acedfb15~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w675](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/64be28706705430a92d02e3e1b215f6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

![-w963](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/624c73ef789a4b5da1b726eba248ce35~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w614](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/15246ce5ef6449e58c2566ba6fe15274~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

![-w960](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/84cee3a22fcf45549921a6f894884adc~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w822](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/de8c1f3d95d84590a6ac010cb595160d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

![-w961](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6fa014e3ab3844b0bc76d2151fb12b55~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w958](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9efe2dbf0df44b579ebb387633cce472~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w837](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8ac8d16badd5455fbea46d694f74f6ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

再后面都是计算的过程了，这里就不详细跟进了

我们主要了解`inout`是怎么给计算属性进行关联调用的，从上面分析可以看出:

*   从调用girth的`getter`开始，都会将计算的结果放入一个寄存器中
*   然后通过这个寄存器的地址再进行传递
*   `inout`影响的也是修改这个寄存器中存储的值，然后再进一步传递到`setter`里进行计算

2\. `inout的本质总结`
----------------

![-w947](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c080e2c15d74ed0b322d1d646e43026~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

**对于没有属性观察器的`存储属性`来说:**

*   `inout`的本质就是传进来一个`地址值`，然后将值存储到这个地址对应的存储空间内

**对于设置了属性观察器和`计算属性`来说:**

*   `inout`会先将传进来的地址值放到一个局部变量中，然后改变局部变量地址值对应的存储空间
    
*   再将改变了的局部变量值覆盖最初传进来的参数的值
    
    *   这时会对应触发属性观察器`willSet、didSet`和计算属性的`setter、getter`的调用
*   如果不这么做，直接就改变了传进来的地址值的存储空间的话，就不会调用属性观察器了，而计算属性因为没有分配内存来存储值，也就没办法更改了
    
*   **总结:`inout`的本质就是引用传递（地址传递）**
    

三、类型属性（Type Property）
=====================

1\. 两类属性
--------

严格来说，属性可以分为两大类:

*   实例属性(Instance Property):只能通过实例去访问
    *   存储实例属性(Stored Instance Property):存储在实例的内存中，每个实例都有一份
    *   计算实例属性(Computed Instance Property)
*   类型属性(Type Property):只能通过类去访问
    *   存储类型属性(Stored Type Property):整个程序运行过程中，就只有一份内存（类似于全局变量）
    *   计算类型属性(Computed Type Property)
*   2.  可以通过`static`定义类型属性
    
    swift
    
    复制代码
    
    `struct Car {
     static var count: Int = 0
     init() {
     Car.count += 1
     }
    }` 
    
*   3.  如果是类，也可以用关键字`class`修饰`计算属性类型`
    
    swift
    
    复制代码
    
    `class Car {
     class var count: Int {
     return 10
     }
    } 
    print(Car.count)` 
    
*   4.  类里面不能用`class`修饰`存储属性类型` ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e4adf6e0bd24884ba8f7449bb50ea73~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

2\. 类型属性细节
----------

*   不同于`存储实例属性`，`存储类型属性`**必须设定初始值**，不然会报错
*   因为类型没有像实例那样的`init初始化器`来初始化存储属性 ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fa55c7ff16054344b1687daea819fbd9~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   `存储类型属性`可以用`let`
    
    swift
    
    复制代码
    
    `struct Car {
     static let count: Int = 0 
    } 
    print(Car.count)` 
    
*   枚举类型也可以定义类型属性（`存储类型属性`、`计算类型属性`）
    
    swift
    
    复制代码
    
    `enum Shape {
     static var width: Int = 0
     case s1, s2, s3, s4
    } 
    var s = Shape.s1
    Shape.width = 5` 
    
*   `存储类型属性`默认就是`lazy`，会在第一次使用的时候进行初始化
    *   就算被多个线程同时访问，保证只会初始化一次

> **通过反汇编来分析类型属性的底层实现**

我们先通过打印下面两组代码来做对比，发现存储类型属性的内存地址和前后两个全局变量正好相差8个字节，所以可以证明存储类型属性的本质就是类似于全局变量，只是放在了结构体或者类里面控制了访问权限:

swift

复制代码

`var num1 = 5
var num2 = 6
var num3 = 7
print(Mems.ptr(ofVal: &num1)) // 0x000000010000c1c0
print(Mems.ptr(ofVal: &num2)) // 0x000000010000c1c8
print(Mems.ptr(ofVal: &num3)) // 0x000000010000c1d0` 

swift

复制代码

`var num1 = 5
class Car {
 static var count = 1
}
Car.count = 6
var num3 = 7
print(Mems.ptr(ofVal: &num1)) // 0x000000010000c2f8
print(Mems.ptr(ofVal: &Car.count)) // 0x000000010000c300
print(Mems.ptr(ofVal: &num3)) // 0x000000010000c308` 

然后我们通过反汇编来观察: ![-w1086](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29f41f886ace4c11b2ec6996ace3668a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1086](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3fb52597aea24166872d4a77051d4100~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1085](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e597aad70a124c28b7ecd3eb2d735f2c~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

![-w508](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95036cbba74246ba85a028c66ffba1c7~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1086](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5ab7bdb03dcf49f3907b2ee304181df8~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

通过调用我们可以发现最后会调用到`GCD`的`dispatch_once`，所以存储类型属性才会说是线程安全的，并且只执行一次

并且`dispatch_once`里面执行的代码就是`static var count = 1`

四、单例模式
======

swift

复制代码

`public class FileManager {
 public static let shared = FileManager()
 private init() { }
  
 public func openFile() {
  
 }
}
FileManager.shared.openFile()` 

五、方法（Method）
============

1\. 基本概念
--------

枚举、结构体、类都可以定义`实例方法`、`类型方法`

*   实例方法（`Instance Method`）: 通过实例对象调用
*   类型方法（`Type Method`）: 通过类型调用
    *   实例方法调用
        
        swift
        
        复制代码
        
        `class Car {
         var count = 0
         func getCount() -> Int {
         count
         }
        }
        let car = Car()
        car.getCo` 
        
    *   类型方法用`static`或者`class`关键字定义
        
        swift
        
        复制代码
        
        `class Car {
         static var count = 0
         static func getCount() -> Int {
         count
         }
        }
        Car.getCount()` 
        
    *   类型方法中不能调用实例属性，反之实例方法中也不能调用类型属性 ![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/821ce590fc79410586ee545f4fb7a6e7~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/34b3768d7ca04c149eab2017d5cffe29~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   不管是类型方法还是实例方法，都会传入隐藏参数`self`
*   `self`在实例方法中代表实例对象
*   `self`在类型方法中代表类型
    
    swift
    
    复制代码
    
    `// count等于self.count、Car.self.count、Car.count
    static func getCount() -> Int {
     self.count
    }` 
    

2\. mutating
------------

*   `结构体`和`枚举`是`值类型`,默认情况下,值类型的属性不能被自身的实例方法修改
*   在`func`关键字前面加上`mutating`可以允许这种修改行为
    
    swift
    
    复制代码
    
    `struct Point {
     var x = 0.0, y = 0.0
     mutating func moveBy(deltaX: Double, deltaY: Double) {
     x += deltaX
     y += deltaY
     }
    }` 
    
    swift
    
    复制代码
    
    `enum StateSwitch {
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
    }` 
    

3\. @discardableResult
----------------------

*   在`func`前面加上`@discardableResult`，可以消除函数调用后`返回值未被使用的警告`
    
    swift
    
    复制代码
    
    `struct Point {
     var x = 0.0, y = 0.0
     @discardableResult mutating func moveX(deltaX: Double) -> Double {
     x += deltaX
     return x
     }
    }
    var p = Point()
    p.moveX(deltaX: 10)` 
    

六、下标（subscript）
===============

1\. 基本概念
--------

*   1.  使用`subscript`可以给任意类型（`枚举`、`结构体`、`类`）增加下标功能  
        有些地方也翻译成：下标脚本
*   2.  `subscript`的语法类似于实例方法、计算属性，本质就是方法（函数）

swift

复制代码

`class Point {
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
print(p[1]) // 22.2` 

*   3.  `subscript`中定义的返回值类型决定了`getter`中返回值类型和`setter`中`newValue`的类型
*   4.  `subscript`可以接收多个参数，并且类型任意
    
    swift
    
    复制代码
    
    `class Grid {
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
    grid[2, 0] = 99` 
    
*   5.  `subscript`可以没有`setter`，但必须要有`getter`，同计算属性
    
    swift
    
    复制代码
    
    `class Point {
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
    }` 
    
*   6.  `subscript`如果只有`getter`，可以省略`getter`
    
    swift
    
    复制代码
    
    `class Point {
     var x = 0.0, y = 0.0 
     subscript(index: Int) -> Double {
     if index == 0 {
     return x
     } else if index == 1 {
     return y
     } 
     return 0
     }
    }` 
    
*   7.  `subscript`可以设置参数标签  
        只有设置了自定义标签的调用才需要写上参数标签
        
        swift
        
        复制代码
        
        `class Point {
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
        print(p[index: 1]) // 22.2` 
        
*   8.`subscript`可以是类型方法
    
    swift
    
    复制代码
    
    `class Sum {
     static subscript(v1: Int, v2: Int) -> Int {
     v1 + v2
     }
    } 
    print(Sum[10, 20]) // 30` 
    

> **通过反汇编来分析**

看下面的示例代码，我们将断点打到图上的位置，然后观察反汇编

![-w710](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eee7f7f5299245879b4ee35b6898cf44~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

看到其内部是会调用`setter`来进行计算

![-w708](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5c779a1690154074ad390a09275cecff~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w714](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dcc337e8548b429fa24e06e8b36202f4~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

然后再将断点打到这里来看

![-w552](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/61185b4065e54f1db581d1517112cacf~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

看到其内部是会调用`getter`来进行计算 ![-w712](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29c9cb259eec4610936b97a9ab5fac3f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dad3b8fab86e43da91b7d7d8135a9f98~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

经上述分析就可以证明`subscript`本质就是方法调用

2\. 结构体和类作为返回值对比
----------------

看下面的示例代码

swift

复制代码

`struct Point {
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
pm[0].y = 22 // 等价于pm[0] = Point(x: pm[0].x, y: 22)` 

如果我们注释掉`setter`，那么调用会报错 ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a6291e522984427cab617ad5bc7b2d25~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) 但是我们将结构体换成类，就不会报错了 ![-w624](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc397b02db4e4a8ba2bbf2502633b205~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   原因还是在于结构体是`值类型`，通过`getter`得到的`Point`结构体只是`临时的值`（可以想成计算属性），并不是真正的存储属性point，所以会报错
    *   通过打印也可以看出来要修改的并不是同一个地址值的point ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e035ac4da994f1ea8beb96d272fadc3~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   但换成了类，那么通过`getter`得到的`Point`类是一个指针变量，而修改的是指向堆空间中的`Point`的属性，所以不会报错

3.接收多个参数的下标
-----------

swift

复制代码

`class Grid {
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
print(grid.data)` 

七、继承（Inheritance）
=================

1\. 基本概念
--------

*   `继承:` 值类型（结构体、枚举）不支持继承，只有引用类型的类支持继承
*   `基类:` 没有父类的类，叫做基类
*   `Swift`并没有像`OC、Java`那样的规定，任何类最终都要继承自某个基类 ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ccf8006df0db467080740e343e7b7a54~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp?)
*   `子类`可以重写从`父类`继承过来的`下标`、`方法`、`属性`。重写必须加上`override`
    
    swift
    
    复制代码
    
    `class Car {
     func run() {
     print("run")
     }
    }
    class Truck: Car {
     override func run() {
     }
    }` 
    

2.内存结构
------

看下面几个类的内存占用是多少

swift

复制代码

`class Animal {
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
//0x0000000000000000` 

*   1.  首先类内部会有16个字节:存储`类信息`和`引用计数`
*   2.  然后才是成员变量/常量的内存(`存储属性`)
*   3.  又由于堆空间分配内存,存在内存对齐的概念,其原则分配的内存大小为16的倍数且刚好大于或等于初始化一个该数据类型变量所需的字节数
*   4.  基于前面的规则,最终得出结论:所分配的内存空间分别占用为`32`、`32`、`48`
*   5.  Tips:子类会继承自父类的属性，所以内存会算上父类的属性存储空间

3\. 重写实例方法、下标
-------------

swift

复制代码

`class Animal {
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
print(ani[7])` 

*   1.  被`class`修饰的类型`方法`、`下标`，允许被子类重写
    
    swift
    
    复制代码
    
    `class Animal {
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
    print(Cat[7])` 
    
*   2.  被`static`修饰的类型方法、下标，不允许被子类重写 ![-w571](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/615e2193e883491fbc45c9c531860185~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4afd111508704971875cca945f656fd0~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  但是被`class`修饰的类型方法、下标，子类重写时允许使用`static`修饰  
        但再后面的子类就不被允许了
    
    swift
    
    复制代码
    
    `class Animal {
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
    print(Cat[7])` 
    
    ![-w634](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87766e3668e340fd912a5b87363b8f7b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

4\. 重写属性
--------

*   1.  子类可以将父类的属性（存储、计算）重写为计算属性
    
    swift
    
    复制代码
    
    `class Animal {
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
    }` 
    
*   2.  但子类`不可以`将父类的属性重写为`存储属性` ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d2d1a89318a143bebbb37a77ec8e93b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w638](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3506b968c7454367be459f52b85160b9~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  只能重写`var`属性，不能重新`let`属性 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ead7d3af36a4d0a8dd92e28121ee6cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  重写时，属性名、类型要一致 ![-w639](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87ab8d0c201f424f988161c658f01b2f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   5.  子类重写后的属性权限不能小于父类的属性权限
    
    *   如果父类属性是`只读的`，那么子类重写后的属性`可以是只读的`，`也可以是可读可写的`
    *   如果父类属性是`可读可写的`，那么子类重写后的属性也`必须是可读可写的`

### 4.1 重写实例属性

swift

复制代码

`class Circle {
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
//10` 

*   6.  从父类继承过来的`存储属性`，**都会分配内存空间**，**`不管`** 之后会不会被重写为计算属性
*   7.  如果重写的方法里的`setter`和`getter`不写`super`，那么就会死循环
    
    swift
    
    复制代码
    
    `class SubCircle: Circle {
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
    }` 
    

### 4.2 重写类型属性

*   1.  被`class`修饰的计算类型属性，`可以`被子类重写

swift

复制代码

`class Circle {
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
//10` 

*   2.  被`static`修饰的类型属性(计算、存储）,`不可以`被子类重写 ![-w861](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18f27d1f7ebf4f45bb65dbaa2063f0cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

5\. 属性观察器
---------

*   1.  可以在子类中为父类属性（除了只读计算属性、`let`属性）增加属性观察器  
        重写后还是存储属性，不是变成了计算属性
    
    swift
    
    复制代码
    
    `class Circle {
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
    //SubCircle didSetRadius 1 10` 
    
*   2.  如果父类里也有属性观察器:
    
    *   那么子类赋值时，会先调用自己的属性观察器`willSet`,然后调用父类的属性观察器`willSet`；
    *   并且在父类里面才是真正的进行赋值
    *   然后先父类的`didSet`，最后再调用自己的`didSet`
        
        swift
        
        复制代码
        
        `class Circle {
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
        //SubCircle didSetRadius 1 10` 
        
*   3.  可以给父类的`计算属性`增加属性观察器
    
    swift
    
    复制代码
    
    `class Circle {
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
    //SubCircle didSetRadius 20 20` 
    

上面打印会先调用一次`Circle getRadius`是因为在设置值之前会先拿到它的`oldValue`，所以需要调用`getter`一次

为了测试，我们将`oldValue`的获取去掉后，再打印发现就没有第一次的`getter`的调用了

![-w717](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a0343cfec35740fcb77982ff96267dbd~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

6\. final
---------

*   1.  被`final`修饰的`方法`、`下标`、`属性`，禁止被重写 ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ccf17c068f94675958d85987162f5dd~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b108314a8bc74118b5bb5dc9c213aea1~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/61b66e59c2034bd0b3e373d0665d95d8~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   2.  被`final`修饰的类，禁止被继承 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/115cfb3c712e48b6b94af68a9b1b65b1~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

7\. 方法调用的本质
-----------

*   1.  我们先看下面的示例代码，分析`结构体`和`类`的调用方法区别是什么
    
    swift
    
    复制代码
    
    `struct Animal {
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
    ani.sleep()` 
    
*   2.  反汇编之后，发现结构体的方法调用就是**直接找到方法所在地址直接调用**  
        结构体的`方法地址都是固定的` ![-w715](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/752cc3d50e4c45419ce8afbfabd8dbcc~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  接下来 我们在看换成`类`之后反汇编的实现是怎样的
    
    swift
    
    复制代码
    
    `class Animal {
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
    ani.sleep()` 
    
*   4.  反汇编之后，会发现需要`调用的方法地址`是**不确定**的  
        所以凡是**调用固定地址**的`都不会是类的方法`的调用 ![-w1189](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df6aa4298ea04c36ba4c0c73278c1613~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1192](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6195c8a7683449b09fd9de09dcae7770~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1190](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1b553e2aec2a4dd6b137720c92927df6~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1186](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/910f04a6b13a4401b3a8a089f00293dc~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1185](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e1af14c97064f2b8a3b5292a12f6a9d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1187](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bee00d70a4945a2b43b3b5a34c23cb6~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1189](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/550d001c28ea43f4810113b5fe8c0f74~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
    
    *   而且上述的几个调用的方法地址都是从`rcx`往高地址偏移`8`个字节来调用的，也就说明几个方法地址都是连续的
    *   我们再来分析下方法调用前做了什么:
    *   通过反汇编我们可以看到:
        *   会从`全局变量`的指针找到其`指向的堆内存`中的类的存储空间
        *   然后`再根据类的前8个字节`里的`类信息`知道需要调用的方法地址
        *   从**类信息的地址进行偏移**找到`方法地址`，然后调用 ![-w1140](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/74b06640e5f344bda01f2a511199e65d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
    *   然后我们将示例代码修改一下，再观察其本质是什么
    
    swift
    
    复制代码
    
    `class Animal {
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
    ani.sleep()` 
    
    *   `增加了子类后`，Dog的类信息里的方法列表会存有重写后的父类方法，以及自己新增的方法
    
    swift
    
    复制代码
    
    `class Dog: Animal {
     func run() {
     print("Dog run")
     }
    }` 
    
    *   如果子类里`没有重写父类方法`，那么类信息里的方法列表会有父类的方法，以及自己新增的方法
        

八、多态及实现原理
=========

*   面向对象语言三大特性：封装、继承、多态。
*   在**OC**中多态是用`Runtime`实现的，在**C++**中用虚表实现多态，今天我们了解一下**Swift**中的多态及其原理
    *   和 **C++** 类似，都是使用虚表
*   什么是多态？父类指针指向子类对象就是多态

1\. 函数调用比较
----------

### 1.1 结构体的函数

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/61cb13f9e8a54892b814ebdc5df97f8d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ff073ce4983a4ab4bb7fb127b3ac9b39~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

通过汇编分析可以看到:

*   因为`不存在继承重写行为`，调用的`函数地址都是在编译时期确定`的。

### 1.2. 类的函数

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a70e61f83c9d4d54a11c1e5a15d2996b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   `speak`函数调用栈: ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ad1485f82f2d4c7e830dfbaffaed076b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   `eat`函数调用栈: ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/977046cc009e485e8926885824796e95~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   `sleep`函数调用栈 ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/67fced14b12045ea978cc66bae9506ec~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   类生成的汇编代码非常多，相比结构体复杂了很多，并且通过函数调用发现:
    *   函数地址是动态变化的
    *   所以，**如果没有继承行为或简单的类，建议使用结构体，效率更高。**（机器指令越少,意味着要执行的代码越高效）
*   类的函数调用地址之所以变化是为因为
    *   **子类继承父类** 会导致 `函数实际调用地址` 发生变化
    *   这也是**多态**的体现。

2、汇编分析`类的继承`
------------

示例代码：

swift

复制代码

`class Animal {
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
var animal = Animal()
animal.speak()
animal.eat()
animal.sleep()
/*
 输出：
 Animal speak
 Animal eat
 Animal sleep
 */
animal = Dog()
animal.speak()
animal.eat()
animal.sleep()
/*
 输出：
 Dog speak
 Dog eat
 Animal sleep
 */` 

汇编分析：

*   ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ae9de7ab0804dbf8881e0b6b4b11fec~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1c1723ba41c8404584d7f13de0eae245~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

**分析：**

*   类的实例前8个字节保存的是类的信息，所以上面的汇编代码会一值围绕着实例`animal`的前8个字节去查找函数地址。
*   而`animal`最后一次指向的是对象`Dog`在堆空间的内存，所以最终调用的是`Dog`中的`speak`函数。
*   其实就是虚表: ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cf6275a2984142df8279ed0e1f47deae~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   `callq *0x50(%rcx)`中的`0x50`就是偏移量，跳过`0x50`就是函数`speak`的地址。

总结起来其实很简单:

*   先找到全局变量`animal`的地址；
*   `animal`地址保存的是堆空间`Dog`对象的内存地址；
*   `Dog`对象前8个字节保存的是对象类型信息地址；
*   对象类型信息地址保存着类中函数的地址。

> **注意：** 无论创建多少个同类型对象，对象的类型信息都指向同一块内存地址。对象类型信息保存在全局区。

九、初始化
=====

1\. 类的初始化器
----------

*   1.  `类`、`结构体`、`枚举`都可以定义初始化器
    
    *   **类有两种初始化器:**
    *   指定初始化器（`designated initializer`）
    *   便捷初始化器（`convenience initializer`）
        
        swift
        
        复制代码
        
        `// 指定初始化器
        init(parameters) {
         statements
        }
        // 便捷初始化器
        convenience init(parameters) {
         statements
        }` 
        
*   2.  每个类`至少有一个`**指定初始化器**  
        指定初始化器是类的主要初始化器
*   3.  默认初始化器总是类的指定初始化器
    
    swift
    
    复制代码
    
    `class Size {
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
    s = Size(age: 10)` 
    
*   4.  类本身会自带一个指定初始化器
    
    swift
    
    复制代码
    
    `class Size {
    }
    var s = Size()` 
    
*   5.  如果有自定义的指定初始化器，默认的指定初始化器就不存在了 ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/da7f3104587044b392f3d7b85f228080~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   6.  类偏向于`少量指定初始化器`  
        一个类通常只有一个指定初始化器
    
    swift
    
    复制代码
    
    `class Size {
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
    let size = Size(height: 180, width: 70)` 
    

2\. 初始化器的相互调用
-------------

**初始化器的相互调用规则**

*   `指定初始化器`必须从它的直系父类调用`指定初始化器`
*   `便捷初始化器`必须从相同的类里调用`另一个初始化器`
*   `便捷初始化器`最终必须调用一个`指定初始化器`
    
    swift
    
    复制代码
    
    `class Person {
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
    }` 
    

**这一套规则保证了:**  
使用任何初始化器，都可以完整地初始化实例 ![-w1211](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ee15a2cdbe9249b5a2d4ba7c515497a4~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

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
    
    swift
    
    复制代码
    
    `class Person {
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
    }` 
    
    swift
    
    复制代码
    
    `class Person {
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
    }` 
    
*   3.  如果子类写了一个匹配父类`便捷初始化器`的初始化器，不用加`override`
    
    swift
    
    复制代码
    
    `class Person {
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
    }` 
    
    因为父类的便捷初始化器永远不会通过子类直接调用  
    因此，严格来说，**子类无法重写父类的`便捷初始化器`**
    
*   4.  `便捷初始化器`只能**横向调用**，不能被子类调用  
        子类没有权利更改父类的`便捷初始化器`，所以不能叫重写
    
    swift
    
    复制代码
    
    `class Person {
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
    }` 
    

4\. 自动继承
--------

*   1.  如果子类没有自定义任何指定初始化器，它会自动继承父类所有的指定初始化器
    
    swift
    
    复制代码
    
    `class Person {
     var age: Int
     init(age: Int) {
     self.age = age
     }
    }
    class Student: Person {
    }
    var s = Student(age: 20)` 
    
    swift
    
    复制代码
    
    `class Person {
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
    s = Student(age: 20)` 
    
*   2.  如果子类提供了父类所有`指定初始化器`的实现（要不通过上一种方式继承，要不重新）
    
    swift
    
    复制代码
    
    `class Person {
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
    var s = Student(age: 30)` 
    
    swift
    
    复制代码
    
    `class Person {
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
    var s = Student(age: 30)` 
    
*   3.  如果子类自定义了`指定初始化器`，那么父类的`指定初始化器`便不会被继承  
        子类自动继承所有的父类`便捷初始化器` ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3f9d8da9ce41477ea3d937b0ad450f4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  就算子类添加了更多的`便捷初始化器`，这些规则仍然适用
    
    swift
    
    复制代码
    
    `class Person {
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
    s = Student(num: 6)` 
    
*   5.  子类以`便捷初始化器`的形式重新父类的`指定初始化器`，也可以作为满足第二条规则的一部分
    
    swift
    
    复制代码
    
    `class Person {
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
    s = Student(sex: 24)` 
    

5\. required
------------

*   1.  用`required`修饰`指定初始化器`，表明其**所有子类**都`必须实现`该初始化器（通过继承或者重写实现）

swift

复制代码

`class Person {
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
var s = Student(age: 30)` 

*   2.  如果子类重写了`required`初始化器，也必须加上`required`，不用加`override`

swift

复制代码

`class Person {
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
s = Student()` 

6\. 属性观察器
---------

*   1.  父类的属性在它自己的初始化器中赋值不会触发`属性观察器`  
        但在子类的初始化器中赋值会触发`属性观察器`
    
    swift
    
    复制代码
    
    `class Person {
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
    var s = Student()` 
    

7\. 可失败初始化器
-----------

*   1.  `类`、`结构体`、`枚举`都可以使用`init?`定义可失败初始化器
    
    swift
    
    复制代码
    
    `class Person {
     var name: String
     init?(name: String) {
     if name.isEmpty {
     return nil
     }
     self.name = name
     }
    }
    let p = Person(name: "Jack")
    print(p)` 
    
    *   下面这几个也是使用了可失败初始化器
    
    swift
    
    复制代码
    
    `var num = Int("123")
    enum Answer: Int {
     case wrong, right
    }
    var an = Answer(rawValue: 1)` 
    
    ![-w539](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9ca5a14875fb4bda8ae27f64a6a4d04d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
    
*   2.  不允许同时定义`参数标签`、`参数个数`、`参数类型相同`的`可失败初始化器`和`非可失败初始化器` ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8725835306874ef2a15e8ec405af5742~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  可以用`init!`定义隐式解包的`可失败初始化器`
    
    swift
    
    复制代码
    
    `class Person {
     var name: String
     init!(name: String) {
     if name.isEmpty {
     return nil
     }
     self.name = name
     }
    }
    let p = Person(name: "Jack")
    print(p)` 
    
*   4.  `可失败初始化器`可以调用`非可失败初始化器`  
        `非可失败初始化器`调用`可失败初始化器`需要进行`解包`
    
    swift
    
    复制代码
    
    `class Person {
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
    }` 
    
    swift
    
    复制代码
    
    `class Person {
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
    }` 
    
*   5.  如果初始化器调用一个`可失败初始化器`导致`初始化失败`，那么整个初始化过程都失败，并且之后的代码都停止执行
    
    swift
    
    复制代码
    
    `class Person {
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
    print(p)` 
    
*   6.  可以用一个`非可失败初始化器`重写一个`可失败初始化器`，但反过来是不行的
    
    swift
    
    复制代码
    
    `class Person {
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
    }` 
    
    ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd34f75d2bb946c9844fe54070a41aff~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
    

7\. 反初始化器（deinit）
-----------------

*   1.  `deinit`叫做反初始化器，类似于C++的`析构函数`，OC中的`dealloc方法`
*   2.  当类的实例对象被释放内存时，就会调用实例对象的`deinit`方法
    
    swift
    
    复制代码
    
    `class Person {
     var name: String
     init(name: String) {
     self.name = name
     }
     deinit {
     print("Person对象销毁了")
     }
    }` 
    
*   3.  父类的`deinit`能被子类继承
*   4.  子类的`deinit`实现执行完毕后会调用父类的`deinit`
    
    swift
    
    复制代码
    
    `class Person {
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
    // Person对象销毁了` 
    
*   5.  `deinit`不接受任何参数，不能写小括号，不能自行调用
