# 属性

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
    
```
struct Point {
 // 存储属性
 var x: Int
 var y: Int
} 
let p = Point(x: 10, y: 10)
```
    
*   可以分配一个默认的属性值作为属性定义的一部分
```
struct Point {
     // 存储属性
     var x: Int = 10
     var y: Int = 10
    } 
    let p = Point()
```
    

### 1.2 计算属性

定义计算属性只能用`var`，不能用`let`

*   `let`代表常量，值是一直不变的
*   计算属性的值是可能发生变化的（即使是只读计算属性）
    
```swift
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
    print(circle.diameter) // 12.0` 
```
    
*   set传入的新值默认叫做`newValue`，也可以自定义
```swift
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
    print(circle.diameter)//12
```
    
*   只读计算属性，只有`get`，没有`set`
```swift
struct Circle {
     // 存储属性
     var radius: Double //8字节
     // 计算属性
     var diameter: Double { radius * 2 }
   }
}
```
*   打印`Circle结构体`的内存大小，其占用才`8个字节`，其本质是因为计算属性相当于函数
```swift
var circle = Circle(radius: 5)
print(Mems.size(ofVal: &circle)) // 8
```

> **我们可以通过反汇编来查看其内部做了什么**

*   可以看到内部会调用`set方法`去计算 ![-w723](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cff94714670464aaf1eef4af8da8e12~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   然后我们在往下执行，还会看到`get方法`的调用 ![-w722](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3a9c5db06a704c67bc497a8ca021731e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   所以可以用此证明:计算属性只会生成`getter`和`setter`,不会开辟内存空间

**注意：**
*   一旦将存储属性变为计算属性，初始化构造器就会报错，只允许传入存储属性的值
*   因为存储属性是直接存储在结构体内存中的，如果改成计算属性则不会分配内存空间来存储 ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e864fd3b6104be586e659d1e1f1b02b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w525](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc57b13c70a0424ebbf7f6df42150499~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   如果只有`setter`也会报错 ![-w651](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/510b7dcc067d4d73a7ecc95efd8c7992~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   只读计算属性：只有`get`，没有`set`

2\. 枚举rawValue原理(计算属性)
----------------------

*   1.  枚举原始值`rawValue`的本质也是计算属性，而且是只读的计算属性
```swift
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
```
    
*   2.  下面我们去掉自己写的`rawValue`，然后转汇编看下本质是什么样的
    
    *   可以看到底层确实是调用了`getter`
    ```swift
    enum TestEnum: Int {
     case test1, test2, test3
     }
     print(TestEnum.test1.rawValue)
    ```

    
    ![-w717](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6ba17ae69a634b95941c98bd85d2785e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

3\. 延迟存储属性（Lazy Stored Property）
--------------------------------

*   1.  使用`lazy`可以定义一个延迟存储属性，在`第一次用到属性的时候才会进行初始化`
    
    *   看下面的示例代码，如果不加`lazy`，那么Person初始化之后就会进行Car的初始化
    *   加上`lazy`，只有调用到属性的时候才会进行Car的初始化
```swift
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
```
    
*   2.  `lazy`属性必须是`var`，不能是`let`  
        `let`必须在实例的初始化方法完成之前就拥有值
```swift
class PhotoView {
     lazy var image: UIImage = {
         let url = "http://www.***.com/logo.png"
         let data = Data(url: url)
         return UIImage(data: data)
     }()
}
```
    
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
```swift
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
```
    
*   2.  在初始化器中设置属性值不会触发`willSet`和`didSet`
```swift
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
```
*   3.  在属性定义时设置初始值也不会触发`willSet`和`didSet`
```swift
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
```
    
*   4.  计算属性设置属性观察器会报错 ![-w657](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f0cb0a9d0e0e45858fa53006840c92ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

5\. 全局变量和局部变量
-------------

*   1.  属性观察器、计算属性的功能，同样可以应用在全局变量和局部变量身上

### 5.1 全局变量
```swift
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
```

### 5.2 局部变量
```swift
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
```
二、inout
=======

1\. inout对属性的影响
---------------

看下面的示例代码，分别输出什么，为什么？
```swift
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
```

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
```swift
struct Car {
     static var count: Int = 0
     init() {
         Car.count += 1
     }
    }
```
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
