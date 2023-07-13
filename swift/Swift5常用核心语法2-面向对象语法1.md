
* **[05-📝Swift5常用核心语法|高级语法【可选链、协议、错误处理、泛型、String与Array、高级运算符、扩展、访问控制、内存管理、字面量、模式匹配】](https://juejin.cn/spost/7119722433589805064 "https://juejin.cn/spost/7119722433589805064")**

二、可选链（Optional Chaining）
========================

看下面的示例代码:

swift

复制代码

`class Person {
 var name: String = ""
 var dog: Dog = Dog()
 var car: Car? = Car()
  
 func age() -> Int { 18 }
  
 func eat() {
 print("Person eat")
 }
  
 subscript(index: Int) -> Int { index }
}` 

*   1.  如果可选项为`nil`，调用方法、下标、属性失败，结果为`nil`
    
    swift
    
    复制代码
    
    `var person: Person? = nil
    var age = person?.age()
    var name = person?.name
    var index = person?[6]
    print(age, name, index) // nil, nil, nil` 
    
    swift
    
    复制代码
    
    `// 如果person为nil，都不会调用getName
    func getName() -> String { "jack" }
    var person: Person? = nil
    person?.name = getName()` 
    
*   2.  如果可选项不为`nil`，调用`方法`、`下标`、`属性`成功，结果会被包装成`可选项`
    
    swift
    
    复制代码
    
    `var person: Person? = Person()
    var age = person?.age()
    var name = person?.name
    var index = person?[6]
    print(age, name, index) // Optional(18) Optional("") Optional(6)` 
    
*   3.  如果结果`本来就是可选项`，不会进行再次包装
    
    swift
    
    复制代码
    
    `print(person?.car) // Optional(test_enum.Car)` 
    
*   4.  可以用可选绑定来判断可选项的方法调用是否成功
    
    swift
    
    复制代码
    
    `let result: ()? = person?.eat()
    if let _ = result {
     print("调用成功")
    } else {
     print("调用失败")
    }` 
    
    swift
    
    复制代码
    
    `if let age = person?.age() {
     print("调用成功", age)
    } else {
     print("调用失败")
    }` 
    
*   5.  没有设定返回值的方法默认返回的就是`元组类型` ![-w521](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b8b75b19c58c4059a2380e609ddb9540~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   6.  多个?可以连接在一起，组成可选链
    
    swift
    
    复制代码
    
    `var dog = person?.dog
    var weight = person?.dog.weight
    var price = person?.car?.price` 
    
*   7.  可选链中不管中间经历多少层，只要有一个节点是可选项的，那么最后的结果就是会被包装成可选项的
    
    swift
    
    复制代码
    
    `print(dog, weight, price) // Optional(test_enum.Dog) Optional(0) Optional(0)` 
    
*   8.  如果链中任何一个节点是`nil`，那么整个链就会调用失败  
        看下面示例代码
    
    swift
    
    复制代码
    
    `var num1: Int? = 5
    num1? = 10
    print(num1)
    var num2: Int? = nil
    num2? = 10
    print(num2)` 
    
*   9.  给变量加上`?`是为了判断变量是否为`nil`，如果为`nil`，那么就不会执行赋值操作了，本质也是可选链
    
    swift
    
    复制代码
    
    `var dict: [String : (Int, Int) -> Int] = [
     "sum" : (+),
     "difference" : (-)
    ]
    var value = dict["sum"]?(10, 20)
    print(value)` 
    

从字典中通过key来取值，得到的也是可选类型，由于可选链中有一个节点是可选项，那么最后的结果也是可选项，最后的值也是`Int?`

三、协议（Protocol）
==============

1\. 基本概念
--------

*   1.  `协议`可以用来定义`方法`、`属性`、`下标`的声明  
        `协议`可以被`结构体`、`类`、`枚举`遵守
    
    swift
    
    复制代码
    
    `protocol Drawable {
     func draw()
     var x: Int { get set } // get和set只是声明
     var y: Int { get }
     subscript(index: Int) -> Int { get set }
    }` 
    
*   2.  `多个协议`之间用逗号隔开
    
    swift
    
    复制代码
    
    `protocol Test1 { }
    protocol Test2 { }
    protocol Test3 { }
    class TestClass: Test1, Test2, Test3 { }` 
    
*   3.  协议中定义方法时不能有默认参数值 ![-w633](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f7119b8167f647fe819d6285c3c57f9f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  默认情况下，协议中定义的内容必须全部都实现

2\. 协议中的属性
----------

*   1.  `协议`中定义属性必须用`var`关键字
*   2.  实现`协议`时的属性权限要不小于`协议`中定义的`属性权限`
    
    *   协议定义`get、set`，用`var`存储属性或`get、set`计算属性去实现
    *   协议定义`get`，用任何属性都可以实现
    
    swift
    
    复制代码
    
    `protocol Drawable {
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
    }` 
    

3\. static、class
----------------

*   1.  为了保证通用，`协议`中必须用`static`定义`类型方法`、`类型属性`、`类型下标`
    
    swift
    
    复制代码
    
    `protocol Drawable {
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
    }` 
    

4\. mutating
------------

*   1.  只有将`协议`中的`实例方法`标记为`mutating`，才允许`结构体`、`枚举`的具体实现修改自身内存
*   2.  `类`在实现方法时不用加`mutating`，`结构体`、`枚举`才需要加`mutating`
    
    swift
    
    复制代码
    
    `protocol Drawable {
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
    }` 
    

5\. init
--------

*   1.  协议中还可以定义初始化器`init`，非`final`类实现时必须加上`required`
*   2.  目的是为了让所有遵守这个协议的类都拥有初始化器，所以加上`required`强制子类必须实现，除非是加上`final`不需要子类的类
    
    swift
    
    复制代码
    
    `protocol Drawable {
     init(x: Int, y: Int)
    }
    class Point: Drawable {
     required init(x: Int, y: Int) {
     }
    }
    final class Size: Drawable {
     init(x: Int, y: Int) {
     }
    }` 
    
*   3.  如果从协议实现的初始化器，刚好是重写了父类的指定初始化器，那么这个初始化必须同时加上`required、override`
    
    swift
    
    复制代码
    
    `protocol Livable {
     init(age: Int)
    }
    class Person {
     init(age: Int) { }
    }
    class Student: Person, Livable {
     required override init(age: Int) {
     super.init(age: age)
     }
    }` 
    
*   4.  协议中定义的`init?、init!`，可以用`init、init?、init!`去实现
    
    swift
    
    复制代码
    
    `protocol Livable {
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
    }` 
    
*   5.  协议中定义的`init`，可以用`init、init!`去实现
    
    swift
    
    复制代码
    
    `protocol Livable {
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
    }` 
    

6\. 协议的继承
---------

一个`协议`可以继承其他协议

swift

复制代码

`protocol Runnable {
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
}` 

7\. 协议组合
--------

协议组合可以包含一个类类型

swift

复制代码

`protocol Runnable { }
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
func fn4(obj: RealPerson) { }` 

8\. CaseIterable
----------------

让枚举遵守`CaseIterable`协议，可以实现遍历枚举值

swift

复制代码

`enum Season: CaseIterable {
 case spring, summer, autumn, winter
}
let seasons = Season.allCases
print(seasons.count)
for season in seasons {
 print(season)
} // spring, summer, autumn, winter` 

9.CustomStringConvertible
-------------------------

*   1.  遵守`CustomStringConvertible、CustomDebugStringConvertible`协议，都可以自定义实例的打印字符串
    
    swift
    
    复制代码
    
    `class Person: CustomStringConvertible, CustomDebugStringConvertible {
     var age = 0
     var description: String { "person_(age)" }
     var debugDescription: String { "debug_person_(age)" }
    }
    var person = Person()
    print(person) // person_0
    debugPrint(person) // debug_person_0` 
    
*   2.  `print`调用的是`CustomStringConvertible`协议的`description`
*   3.  `debugPrint、po`调用的是`CustomDebugStringConvertible`协议的`debugDescription`

![-w529](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/acc8277e7aa14a60a23a27f52a4b11fc~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

四、Any、AnyObject与元类型
===================

1\. Any、AnyObject
-----------------

*   1.  Swift提供了两种特殊的类型`Any、AnyObject`
*   2.  `Any`可以代表任意类型（`枚举`、`结构体`、`类`，也包括`函数类型`）
    
    swift
    
    复制代码
    
    `var stu: Any = 10
    stu = "Jack"
    stu = Size()` 
    
    swift
    
    复制代码
    
    `var data = [Any]()
    data.append(1)
    data.append(3.14)
    data.append(Size())
    data.append("Jack")
    data.append({ 10 })` 
    
*   3.  `AnyObject`可以代表任意类类型
*   4.  在协议后面写上`: AnyObject`，代表只有类能遵守这个协议 ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d3809ed07d17450d911eec4ad2731c0f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   5.  在协议后面写上`: class`，也代表只有类能遵守这个协议 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3c89cc874464f83a7bdb5c65a31b83c~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

2\. is、as
---------

*   `is`用来判断是否为某种类型
    
    swift
    
    复制代码
    
    `protocol Runnable {
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
    print(stu is Runnable) // true` 
    
*   2.  `as`用来做强制类型转换(`as?`、`as!`、`as`)
    
    swift
    
    复制代码
    
    `protocol Runnable {
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
    (stu as? Runnable)?.run() // Student run` 
    
    swift
    
    复制代码
    
    `var data = [Any]()
    data.append(Int("123") as Any)
    var d = 10 as Double
    print(d) // 10.0` 
    

3\. X.self
----------

*   1.  `X.self`是一个`元类型的指针`，`metadata`存放着`类型相关信息`
*   2.  `X.self`属于`X.Type`类型
    
    swift
    
    复制代码
    
    `class Person { }
    class Student: Person { }
    var perType: Person.Type = Person.self
    var stuType: Student.Type = Student.self
    perType = Student.self
    var anyType: AnyObject.Type = Person.self
    anyType = Student.self
    var per = Person()
    perType = type(of: per)
    print(Person.self == type(of: per)) // true` 
    
*   3.  `AnyClass`的本质就是`AnyObject.Type` ![-w492](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c534ec2adb474b47bc5ab8ab7221b02a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
    
    swift
    
    复制代码
    
    `var anyType2: AnyClass = Person.self
    anyType2 = Student.self` 
    

4\. 元类型的应用
----------

swift

复制代码

`class Animal {
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
var a4 = Animal.self()` 

5\. Self
--------

*   1.  `Self`代表当前类型
    
    swift
    
    复制代码
    
    `class Person {
     var age = 1
     static var count = 2
     func run() {
     print(self.age)
     print(Self.count)
     }
    }` 
    
*   2.  `Self`一般用作返回值类型，限定返回值和方法调用者必须是同一类型（也可以作为参数类型）
    
    swift
    
    复制代码
    
    `protocol Runnable {
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
    print(stu.test()) // test_enum.Student` 
    

6\. 元类型的本质
----------

我们可以通过反汇编来查看元类型的实现是怎样的

swift

复制代码

`var p = Person()
var pType = Person.self` 

我们发现最后存储到全局变量pType中的地址值就是一开始调用的地址 ![-w1031](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8a38e68565b04a649793fd49e4962bc8~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) 再通过打印，我们发现pType的值就是Person实例对象的前8个字节的地址值，也就是类信息 ![-w1031](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f81fff9375c949a18a6e71f733e06da5~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1032](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d84b816435c0422a9ea5bfde95b40861~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) 我们再来看下面的示例代码

swift

复制代码

`var p = Person()
var pType = type(of: p)` 

通过分析我们可以看到`type(of: p)`本质不是函数调用，只是将Person实例对象的前8个字节存储到pType中，也证明了元类型的本质就是存储的类信息

![-w1031](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f11a754847b149eab14026ed50e0ff21~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1030](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aa877aa499e7423e86c1e96bd301d291~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

我们还可以用以下方式来获取Swift的隐藏基类`_TtCs12_SwiftObject`

swift

复制代码

`class Person {
 var age: Int = 0
}
class Student: Person {
 var no: Int = 0
}
print(class_getInstanceSize(Student.self)) // 32
print(class_getSuperclass(Student.self)!) // Person
print(class_getSuperclass(Student.self)!) // _TtCs12_SwiftObject
print(class_getSuperclass(NSObject.self)) // nil` 

我们可以查看Swift源码来分析该类型

发现`SwiftObject`里面也有一个`isa指针`

![-w686](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b4602a6c2194461caf1a20eefd72056b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

五、错误处理
======

1\. 错误处理
--------

### 1.1 错误类型

开发过程中常见的错误有

*   语法错误（编译报错）
*   逻辑错误
*   运行时错误（可能会导致闪退，一般也叫做异常）
*   ....

### 1.2 自定义错误

*   1.  Swift中可以通过`Error`协议自定义运行时的错误信息

swift

复制代码

`enum SomeError: Error {
 case illegalArg(String)
 case outOffBounds(Int, Int)
 case outOfMemory
}` 

*   2.  函数内部通过`throw`抛出自定义`Error`，可能会抛出`Error`的函数必须加上`throws`声明

swift

复制代码

`func divide(_ num1: Int, _ num2: Int) throws -> Int {
 if num2 == 0 {
 throw SomeError.illegalArg("0不能作为除数")
 }
 return num1 / num2
}` 

*   3.  需要使用`try`调用可能会抛出`Error`的函数

swift

复制代码

`var result = try divide(20, 10)` 

*   4.  抛出错误信息的情况 ![-w715](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7930b652084241faba9c27f010bc0d2d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

### 1.3 do—catch

*   1.  可以使用`do—catch`捕捉`Error`

swift

复制代码

`do {
 try divide(20, 0)
} catch let error {
 switch error {
 case let SomeError.illegalArg(msg):
 print("参数错误", msg)
 default:
 print("其他错误")
 }
}` 

*   2.  抛出`Error`后，`try`下一句直到作用域结束的代码都将停止运行

swift

复制代码

`func test() {
 print("1")
 do {
 print("2")
 print(try divide(20, 0)) // 这句抛出异常后面的代码不会执行了
 print("3")
 } catch let SomeError.illegalArg(msg) {
 print("参数异常:", msg)
 } catch let SomeError.outOffBounds(size, index) {
 print("下标越界:", "size=(size)", "index=(index)")
 } catch SomeError.outOfMemory {
 print("内存溢出")
 } catch {
 print("其他错误")
 }
 print("4")
}
test()
//1
//2
//参数异常: 0不能作为除数
//4` 

*   3.  `catch`作用域内默认就有`error`的变量可以捕获

swift

复制代码

`do {
 try divide(20, 0)
} catch {
 print(error)
}` 

2\. 处理Error
-----------

*   1.  处理`Error`的两种方式:
*   a. 通过`do—catch`捕捉`Error`
    
    swift
    
    复制代码
    
    `do {
     print(try divide(20, 0))
    } catch is SomeError {
     print("SomeError")
    }` 
    
*   b. 不捕捉`Error`，在当前函数增加`throws`声明，`Error`将自动抛给上层函数  
    如果最顶层函数`main函数`依然没有捕捉`Error`，那么程序将终止
    
    swift
    
    复制代码
    
    `func test() throws {
     print("1")
     print(try divide(20, 0))
     print("2")
    }
    try test()
    // 1
    // Fatal error: Error raised at top level` 
    
*   2.  调用函数如果是写在函数里面，没有进行捕捉`Error`就会报错，而写在外面就不会 ![-w648](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5b762799211d40e0a615dd5a6e22c6f3~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  然后我们加上`do-catch`发现还是会报错，因为捕捉`Error`的处理不够详细，要捕捉所有`Error`信息才可以 ![-w639](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cb1a1d7f29104af994f8efec21a18f1d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   这时我们加上`throws`就可以了
    
    swift
    
    复制代码
    
    `func test() throws {
     print("1")
     do {
     print("2")
     print(try divide(20, 0))
     print("3")
     } catch let error as SomeError {
     print(error)
     }
     print("4")
    }
    try test()
    // 1
    // 2
    // illegalArg("0不能作为除数")
    // 4` 
    
*   或者再加上一个`catch`捕获其他所有`Error`情况
    
    swift
    
    复制代码
    
    `func test() {
     print("1")
     do {
     print("2")
     print(try divide(20, 0))
     print("3")
     } catch let error as SomeError {
     print(error)
     } catch {
     print("其他错误情况")
     }
     print("4")
    }
    test()` 
    
*   看下面示例代码，执行后会输出什么
    
    swift
    
    复制代码
    
    `func test0() throws {
     print("1")
     try test1()
     print("2")
    }
    func test1() throws {
     print("3")
     try test2()
     print("4")
    }
    func test2() throws {
     print("5")
     try test3()
     print("6")
    }
    func test3() throws {
     print("7")
     try divide(20, 0)
     print("8")
    }
    try test0()` 
    
*   执行后打印如下，并会抛出错误信息 ![-w717](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fb0551c1a8ea45829511ba7bf79cfaa3~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

3\. try
-------

*   1.  可以使用`try?、try!`调用可能会抛出`Error`的函数，这样就不用去处理`Error`

swift

复制代码

`func test() {
 print("1")
 var result1 = try? divide(20, 10) // Optional(2), Int?
 var result2 = try? divide(20, 0) // nil
 var result3 = try! divide(20, 10) // 2, Int
 print("2")
}
test()` 

*   2.  a、b是等价的

swift

复制代码

`var a = try? divide(20, 0)
var b: Int?
do {
 b = try divide(20, 0)
} catch { b = nil }` 

4\. rethrows
------------

*   `rethrows`表明，函数本身不会抛出错误，但调用闭包参数抛出错误，那么它会将错误向上抛

swift

复制代码

`func exec(_ fn: (Int, Int) throws -> Int, _ num1: Int, _ num2: Int) rethrows {
print(try fn(num1, num2))
}
// Fatal error: Error raised at top level
try exec(divide, 20, 0)` 

*   空合并运算符就是用了`rethrows`来进行声明的 ![-w609](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3d973592ccd54e0a96c23cc6d9b4b4a5~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

5\. defer
---------

*   1.  `defer`语句，用来定义以任何方式（抛错误、return等）离开代码块前必须要执行的代码
*   2.  `defer`语句将延迟至当前作用域结束之前执行

swift

复制代码

`func open(_ filename: String) -> Int {
print("open")
return 0
}
func close(_ file: Int) {
print("close")
}
func processFile(_ filename: String) throws {
let file = open(filename)
defer {
 close(file)
}
// 使用file
// .....
try divide(20, 0)
// close将会在这里调用
}
try processFile("test.txt")
// open
// close
// Fatal error: Error raised at top level` 

*   3.  `defer`语句的执行顺序与定义顺序相反

swift

复制代码

`func fn1() { print("fn1") }
func fn2() { print("fn2") }
func test() {
defer { fn1() }
defer { fn2() }
}
test()
// fn2
// fn1` 

6\. assert（断言）
--------------

*   很多编程语言都有断言机制，不符合指定条件就抛出运行时错误，常用于调试`Debug`阶段的条件判断 ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9dd47e1150c04452aefc2cb0ff1fcefa~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   默认情况下，Swift的断言只会在`Debug`模式下生效，`Release`模式下会忽略
*   增加`Swift Flags`修改断言的默认行为
*   `-assert-config Release`：强制关闭断言
*   `-assert-config Debug`：强制开启断言 ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3876ff55e7b4d719e6639fb3f5f8e05~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

7\. fatalError
--------------

*   1.  如果遇到严重问题，希望结束程序运行时，可以直接使用`fatalError`函数抛出错误
*   2.  这是无法通过`do—catch`捕获的错误
*   3.  使用了`fatalError`函数，就不需要再写`return`

swift

复制代码

`func test(_ num: Int) -> Int {
 if num >= 0 {
 return 1
 }
 fatalError("num不能小于0")
}` 

*   4.  在某些不得不实现，但不希望别人调用的方法，可以考虑内部使用`fatalError`函数

swift

复制代码

`class Person { required init() {} }
class Student: Person {
 required init() {
 fatalError("don't call Student.init")
 }
 init(score: Int) {
 }
}
var stu1 = Student(score: 98)
var stu2 = Student()` 

8\. 局部作用域
---------

*   1.  可以使用`do`实现局部作用域

swift

复制代码

`do {
 let dog1 = Dog()
 dog1.age = 10
 dog1.run()
}
do {
 let dog2 = Dog()
 dog2.age = 10
 dog2.run()
}` 

六、泛型（Generics）
==============

1\. 基本概念
--------

*   1.1 `泛型`可以将`类型参数化`  
    提高代码复用率，减少代码量

swift

复制代码

`func swapValues<T>(_ a: inout T, _ b: inout T) {
 (a, b) = (b, a)
}
var i1 = 10
var i2 = 20
swap(&i1, &i2)
print(i1, i2) // 20, 10
struct Date {
 var year = 0, month = 0, day = 0
}
var d1 = Date(year: 2011, month: 9, day: 10)
var d2 = Date(year: 2012, month: 10, day: 20)
swap(&d1, &d2)
print(d1, d2) // Date(year: 2012, month: 10, day: 20), Date(year: 2011, month: 9, day: 10)` 

*   1.2 `泛型`函数赋值给变量

swift

复制代码

`func test<T1, T2>(_ t1: T1, _ t2: T2) {}
var fn: (Int, Double) -> () = test` 

2\. 泛型类型
--------

> Case1 `栈`

swift

复制代码

`class Stack<E> {
var elements = [E]()
func push(_ element: E) {
 elements.append(element)
}
func pop() -> E {
 elements.removeLast()
}
func top() -> E {
 elements.last!
}
func size() -> Int {
 elements.count
}
}
class SubStack<E>: Stack<E> {
}
var intStack = Stack<Int>()
var stringStack = Stack<String>()
var anyStack = Stack<Any>()` 

> Case1 `栈` 继续完善

swift

复制代码

`struct Stack<E> {
var elements = [E]()
mutating func push(_ element: E) {
 elements.append(element)
}
mutating func pop() -> E {
 elements.removeLast()
}
func top() -> E {
 elements.last!
}
func size() -> Int {
 elements.count
}
}
var stack = Stack<Int>()
stack.push(11)
stack.push(22)
stack.push(33)
print(stack.top()) // 33
print(stack.pop()) // 33
print(stack.pop()) // 22
print(stack.pop()) // 11
print(stack.size()) // 0` 

> Case2

swift

复制代码

`enum Score<T> {
case point(T)
case grade(String)
}
let score0 = Score<Int>.point(100)
let score1 = Score.point(99)
let score2 = Score.point(99.5)
let score3 = Score<Int>.grade("A")` 

3\. 关联类型（Associated Type）
-------------------------

*   1.  关联类型的作用: 给协议中用到的类型定义一个占位名称

swift

复制代码

`protocol Stackable {
 associatedtype Element
 mutating func push(_ element: Element)
 mutating func pop() -> Element
 func top() -> Element
 func size() -> Int
}
struct Stack<E>: Stackable {
 var elements = [E]()
 mutating func push(_ element: E) {
 elements.append(element)
 }
 mutating func pop() -> E {
 elements.removeLast()
 }
 func top() -> E {
 elements.last!
 }
 func size() -> Int {
 elements.count
 }
}
class StringStack: Stackable {
 var elements = [String]()
 func push(_ element: String) {
 elements.append(element)
 }
 func pop() -> String {
 elements.removeLast()
 }
 func top() -> String {
 elements.last!
 }
 func size() -> Int {
 elements.count
 }
}
var ss = StringStack()
ss.push("Jack")
ss.push("Rose")` 

*   2.  协议中可以拥有多个关联类型

swift

复制代码

`protocol Stackable {
 associatedtype Element
 associatedtype Element2
 mutating func push(_ element: Element)
 mutating func pop() -> Element
 func top() -> Element
 func size() -> Int
}` 

4\. 类型约束
--------

swift

复制代码

`protocol Runnable { }
class Person { }
func swapValues<T: Person & Runnable>(_ a: inout T, _ b: inout T) {
(a, b) = (b, a)
}` 

swift

复制代码

`protocol Stackable {
associatedtype Element: Equatable
}
class Stack<E: Equatable>: Stackable {
typealias Element = E
}
func equal<S1: Stackable, S2: Stackable>(_ s1: S1, _ s2: S2) -> Bool where S1.Element == S2.Element, S1.Element : Hashable {
 return false
}
var stack1 = Stack<Int>()
var stack2 = Stack<String>()
equal(stack1, stack2)` 

5\. 协议类型的注意点
------------

看下面的示例代码来分析

swift

复制代码

`protocol Runnable { }
class Person: Runnable { }
class Car: Runnable { }
func get(_ type: Int) -> Runnable {
if type == 0 {
 return Person()
}
return Car()
}
var r1 = get(0)
var r2 = get(1)` 

*   如果协议中有`associatedtype`

swift

复制代码

`protocol Runnable {
associatedtype Speed
var speed: Speed { get }
}
class Person: Runnable {
var speed: Double { 0.0 }
}
class Car: Runnable {
var speed: Int { 0 }
}` 

*   这样写会报错，因为无法在编译阶段知道`Speed`的真实类型是什么 ![-w638](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/efce02a4842a49258ed91629e11c620f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   可以用泛型来解决

swift

复制代码

`protocol Runnable {
 associatedtype Speed
 var speed: Speed { get }
}
class Person: Runnable {
 var speed: Double { 0.0 }
}
class Car: Runnable {
 var speed: Int { 0 }
}
func get<T: Runnable>(_ type: Int) -> T {
 if type == 0 {
 return Person() as! T
 }
 return Car() as! T
}
var r1: Person = get(0)
var r2: Car = get(1)` 

*   还可以使用`some`关键字声明一个`不透明类型`
*   `some`限制只能返回一种类型

swift

复制代码

`protocol Runnable {
 associatedtype Speed
 var speed: Speed { get }
}
class Person: Runnable {
 var speed: Double { 0.0 }
}
class Car: Runnable {
 var speed: Int { 0 }
}
func get(_ type: Int) -> some Runnable {
 return Car()
}
var r1 = get(0)
var r2 = get(1)` 

*   `some`除了用在返回值类型上，一般还可以用在属性类型上

swift

复制代码

`protocol Runnable {
 associatedtype Speed
}
class Dog: Runnable {
 typealias Speed = Double
}
class Person {
 var pet: some Runnable {
 return Dog()
 }
}` 

6\. 泛型的本质
---------

*   我们通过下面的示例代码来分析其内部具体是怎样实现的

swift

复制代码

`func swapValues<T>(_ a: inout T, _ b: inout T) {
 (a, b) = (b, a)
}
var i1 = 10
var i2 = 20
swap(&i1, &i2)
print(i1, i2) // 20, 10
var d1 = 10.0
var d2 = 20.0
swap(&d1, &d2)
print(d1, d2) // 20.0, 10.0` 

*   反汇编之后 ![-w1000](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/281c636f9b5b4cbba84bea1f8833610d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1002](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/423e799fe8324208b6a7ec356a5c90ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   从调用两个交换方法来看，最终调用的都是同一个函数，因为函数地址是一样的；
*   但不同的是分别会将`Int的metadata`和`Double的metadata`作为参数传递进去
*   所以推测`metadata`中应该分别指明对应的类型来做处理

7\. 可选项的本质
----------

*   1.  可选项的本质的本质是`enum`类型
*   2.  我们可以进到头文件中查看 ![-w1034](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4e338908efc74aa6b8f35758510ebafa~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   我们平时写的语法糖的真正写法如下:

swift

复制代码

`var age: Int? = 10
本质写法如下：
var ageOpt0: Optional<Int> = Optional<Int>.some(10)
var ageOpt1: Optional = .some(10)
var ageOpt2 = Optional.some(10)
var ageOpt3 = Optional(10)` 

swift

复制代码

`var age: Int? = nil
本质写法如下：
var ageOpt0: Optional<Int> = .none
var ageOpt1 = Optional<Int>.none` 

swift

复制代码

`var age: Int? = .none
age = 10
age = .some(20)
age = nil` 

*   3.  switch中可选项的使用

swift

复制代码

`switch age {
case let v?: // 加上?表示如果有值会解包赋值给v
 print("some", v)
case nil:
 print("none")
}
switch age {
case let .some(v):
 print("some", v)
case .none:
 print("none")
}` 

*   4.  多重可选项

swift

复制代码

`var age_: Int? = 10
var age: Int?? = age_
age = nil
var age0 = Optional.some(Optional.some(10))
age0 = .none
var age1: Optional<Optional> = .some(.some(10))
age1 = .none` 

swift

复制代码

`var age: Int?? = 10
var age0: Optional<Optional> = 10` 

七、String、Array的底层分析
===================

1\. String
----------

### 1.1 关于String的思考

> **我们先来思考String变量`占用多少内存`？**

swift

复制代码

`var str1 = "0123456789"
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xea00000000003938` 

*   1.  我们通过打印可以看到`String变量`占用了`16`个字节，并且打印内存布局，前后各占用了`8个字节`
*   2.  下面我们再进行`反汇编`来观察下:  
        可以看到这两句指令正是分配了前后8个字节给了`String变量` ![-w715](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6660d592d9af43a891376332ffd407f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

> **那String变量底层`存储的是什么`呢？**

*   1.  我们通过上面看到`String变量`的16个字节的值其实是对应转成的`ASCII码值`
*   2.  ASCII码表的地址：[www.ascii-code.com](https://link.juejin.cn?target=https%3A%2F%2Fwww.ascii-code.com "https://www.ascii-code.com") ![-w1139](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3e0acfa1dfc44f2bb9b58b0d2d7f9b0~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  我们看上图就可以得知:
    
    *   左边对应的是`0~9`的十六进制`ASCII码值`
    *   又因为`小端模式(高高低低)`下高字节放高地址，低字节放低地址的原则，对比正是我们打印的16个字节中存储的数据
        
        swift
        
        复制代码
        
        `0x3736353433323130 0xea00000000003938` 
        

> **然后我们再看后8个字节前面的`e`和`a`分别代表的是`类型`和`长度`**

*   如果`String`的数据是`直接存储在变量中`的,就是用`e`来标明类型
*   如果要是`存储在其他地方`,就会`用别的字母来表示`
*   我们`String`字符的长度正好是10，所以就是十六进制的`a`

swift

复制代码

`var str1 = "0123456789ABCDE"
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xef45444342413938` 

*   我们打印上面这个`String变量`，发现表示长度的值正好变成了`f`
*   而后7个字节也都被填满了，所以也证明了这种方式最多只能存储15个字节的数据
*   这种方式很像`OC`中的`Tagger Pointer`的存储方式

> **如果存储的数据超过15个字符，String变量又会是什么样呢？**

*   我们改变`String变量`的值，再进行打印观察

swift

复制代码

`var str1 = "0123456789ABCDEF"
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0xd000000000000010 0x80000001000079a0` 

*   我们发现`String变量`的内存占用还是16个字节，但是内存布局已经完全不一样了
*   这时我们就需要借助反汇编来进一步分析了: ![-w998](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5755335330d5408787db631d057a1c08~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   看上图能发现最后还是会先后分配`8个字节`给`String变量`，但不同的是在这之前会调用了函数，并将返回值给了`String变量`的`前8个字节`
*   而且分别将`字符串`的值还有长度作为参数传递了进去，下面我们就看看调用的函数里具体做了什么 ![-w995](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/104ab1a55d59499280f28b37fcf21205~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1058](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e7ba4e15d1e14911815c30f9f02d007a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   我们可以看到函数内部会将一个`掩码`的值和`String变量`的地址值相加，然后存储到`String变量`的后8个字节中
*   所以我们可以反向计算出所存储的数据真实地址值

swift

复制代码

`0x80000001000079a0 - 0x7fffffffffffffe0 = 0x1000079C0` 

*   其实也就是一开始存储到`rdi`中的值 ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c8be70d3fa449fa85d744375cabd040~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
    *   通过打印真实地址值可以看到16个字节确实都是存储着对应的`ASCII码值`

> **那么真实数据是存储在什么地方呢？**

*   通过观察它的地址我们可以大概推测是在`数据段`
*   为了更确切的认证我们的推测，使用`MachOView`来直接查看在可执行文件中这句代码的真正存储位置
*   我们找到项目中的可执行文件，然后右键`Show in Finder` ![-w357](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b9e34e897cad43a7aaf099869e9c9b59~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   然后右键通过`MachOView`的方式来打开 ![-w498](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1ce3b7c154d14f1493081d48953f99f5~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   最终我们发现在代码段中的字符串`常量区`中 ![-w1055](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/438688bb7e5a408e9c8302391914e0cd~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

> **对比两个字符串的存储位置**

*   我们现在分别查看下这两个字符串的存储位置是否相同

swift

复制代码

`var str1 = "0123456789"
var str2 = "0123456789ABCDEF"` 

*   我们还是用`MachOView`来打开可执行文件，发现两个字符串的真实地址都是放在代码段中的`字符串常量区`，并且相差`16个字节` ![-w1165](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/06b26919bbde4b98b028c96d686bc17e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   然后我们再看打印的地址的前8个字节

swift

复制代码

`0xd000000000000010 0x80000001000079a0` 

*   按照推测`10`应该也是表示长度的十六进制，而前面的`d`就代表着这种类型
*   我们更改下字符串的值，发现果然表示长度的值也随之变化了

swift

复制代码

`var str2 = "0123456789ABCDEFGH"
print(Mems.size(ofVal: &str2)) // 16
print(Mems.memStr(ofVal: &str2)) // 0xd000000000000012 0x80000001000079a0` 

> **如果分别给两个String变量进行拼接会怎样呢？**

swift

复制代码

`var str1 = "0123456789"
str1.append("G")
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xeb00000000473938
var str2 = "0123456789ABCDEF"
str2.append("G")
print(Mems.size(ofVal: &str2)) // 16
print(Mems.memStr(ofVal: &str2)) // 0xf000000000000011 0x0000000100776ed0` 

*   我们发现str1的后8个字节还有位置可以存放新的字符串，所以还是继续存储在内存变量里
*   而str2的内存布局不一样了，前8个字节可以看出来类型变成`f`，字符串长度也变为十六进制的`11`；
*   而后8个字节的地址很像`堆空间`的地址值

> **验证String变量的存储位置是否在堆空间**

*   为了验证我们的推测，下面用反汇编来进行观察
*   我们在验证之前先创建一个类的实例变量，然后跟进去在内部调用`malloc`的指令位置打上断点

swift

复制代码

`class Person { }
var p = Person()` 

![-w979](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/280785045b49499fb719596615a8d313~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   然后我们先将断点置灰，重新反汇编之前的`Sting变量` ![-w979](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bc12e07e8ae42f5bff7642c2af48169~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   然后将置灰的`malloc`的断点点亮，然后进入 ![-w978](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/efca144df3804ed08d949b79aca7f1b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   发现确实会进入到我们之前在调用`malloc`的断点处，所以这就验证了确实会分配堆空间内存来存储`String变量`的值了
*   我们还可以用`LLDB`的指令`bt`来打印调用栈详细信息来查看 ![-w979](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2d9a75d0d4cb4d7791e9baf68910218f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   发现也是在调用完`append方法`之后就会进行`malloc`的调用了，从这一层面也验证了我们的推测

> **那堆空间里存储的str2的值是怎样的呢？**

*   然后我们过掉了`append函数`后，打印str2的地址值，然后再打印后8个字节存放的堆空间地址值 ![-w981](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1b804928b02f43fdbe4d7364359a24db~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   其内部偏移了`32个字节`后，正是我们`String变量`的`ASCII码值`

### 1.2 总结

*   1.  **如果字符串长度小于等于0xF（十进制为15）**,字符串内容直接存储到字符串变量的内存中，并以`ASCII`码值的**小端模式来进行存储**
*   `第9个字节`会存储字符串`变量的类型`和`字符长度`

swift

复制代码

`var str1 = "0123456789"
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xeb00000000473938` 

> **进行字符串拼接操作后**

*   2.  **如果拼接后的字符串长度还是`小于等于`0xF（十进制为15）** ,存储位置同未拼接之前

swift

复制代码

`var str1 = "0123456789"
str1.append("ABCDE")
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xef45444342413938` 

*   3.  **如果拼接后的字符串长度`大于`0xF（十进制为15）**,会`开辟堆空间`来存储字符串内容
*   字符串的地址值中:
*   `前8个字节`存储`字符串变量的类型`和`字符长度`
*   `后8个字节`存储着`堆空间的地址值`，`堆空间地址 + 0x20`可以得到`真正的字符串内容`
*   堆空间地址的`前32个字节`是用来`存储描述信息`的
*   由于`常量区`是程序运行之前就已经确定位置了的,所以拼接字符串是运行时操作,不可能再回存放到常量区,所以`直接分配堆空间`进行存储

swift

复制代码

`var str1 = "0123456789"
str1.append("ABCDEF")
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0xf000000000000010 0x000000010051d600` 

*   4.  **如果字符串长度大于0xF（十进制为15）** , 字符串内容会存储在`__TEXT.cstring`中（常量区）
*   字符串的地址值中，`前8个字节`存储字符串变量的类型和字符长度，`后8个字节`存储着一个地址值，`地址值 & mask`可以得到字符串内容在常量区真正的地址值

swift

复制代码

`var str2 = "0123456789ABCDEF"
print(Mems.size(ofVal: &str2)) // 16
print(Mems.memStr(ofVal: &str2)) // 0xd000000000000010 0x80000001000079a0` 

*   5.  **进行字符串拼接操作后**，同上面开辟`堆空间`存储的方式

swift

复制代码

`var str2 = "0123456789ABCDEF"
str2.append("G")
print(Mems.size(ofVal: &str2)) // 16
print(Mems.memStr(ofVal: &str2)) // 0xf000000000000011 0x0000000106232230` 

### 1.3 dyld\_stub\_binder

*   1.  我们反汇编看到底层调用的`String.init`方法其实是`动态库`里的方法，而动态库在内存中的位置是在`Mach-O文件`的更高地址的位置，如下图所示 ![-w939](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/93c7a01e241b41249b9baa0f3a3c1e6a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   2.  所以我们这里看到的地址值其实是一个`假的地址值`，`只是用来占位的` ![-w999](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5d8bba1b0e54694b76952752cc2c49b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   我们再跟进发现其内部会跳转到另一个地址，取出其存储的真正需要调用的地址值去调用
*   下一个调用的地址值一般都是相差6个字节

swift

复制代码

`0x10000774e + 0x6 = 0x100007754
0x100007754 + 0x48bc(%rip) = 0x10000C010
最后就是去0x10000C010地址中找到需要调用的地址值0x100007858` 

![-w998](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5afbe8541244d9dab7347755bde2656~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w997](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3a48c418233d4ade9c0c935b1d3ed5c6~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   3\. 然后一直跟进，最后会进入到动态库的`dyld_stub_binder`中进行绑定 ![-w996](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8bb1f99041f24e3080de780b8405998c~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  最后才会真正进入到动态库中的`String.init`执行指令，而且可以发现其真正的地址值非常大，这也能侧面证明动态库是在可执行文件更高地址的位置 ![-w1000](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ffcbe445b3e94cf2ac38865229bfc08d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   5.  然后我们在执行到下一个`String.init`的调用 ![-w997](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/98f566de85184723a9edf493e4d5678e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   6.  跟进去发现这是要跳转的地址值就已经是动态库中的`String.init`真实地址值了 ![-w997](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e5179fdfdc2b4ad3ac626492ded5b6f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w999](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2df7d588ff9444c9ab6805413b925c62~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   7.  这也说明了`dyld_stub_binder`只会执行一次，而且是用到的时候在进行调用，也就是延迟绑定
*   8.  `dyld_stub_binder`的主要作用就是在程序运行时，将真正需要调用的函数地址替换掉之前的占位地址

2\. 关于Array的思考
--------------

> **我们来思考Array变量占用多少内存？**

swift

复制代码

`var array = [1, 2, 3, 4]
print(Mems.size(ofVal: &array)) // 8
print(Mems.ptr(ofVal: &array)) // 0x000000010000c1c8
print(Mems.ptr(ofRef: array)) // 0x0000000105862270` 

*   1.  我们通过打印可以看到`Array变量`占用了`8个字节`，其内存地址就是存储在`全局区`的地址
*   2.  然而我们发现其内存地址的存储空间存储的地址值更像一个堆空间的地址

> **Array变量存储在什么地方呢？**

*   3.带着疑问我们还是进行反汇编来观察下，并且在`malloc`的调用指令处打上断点 ![-w988](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/485f28a97e604a2eb8bf1c16ad4ec132~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   发现确实调用了`malloc`，那么就证明了`Array变量`内部会分配堆空间 ![-w1000](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b36e7c6d60d44389c801ec6a03ddd13~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  等执行完返回值给到`Array变量`之后，我们打印`Array变量`存储的地址值内存布局，发现其内部`偏移32个字节`的位置存储着元素1、2、3、4
*   我们还可以直接通过打印内存结构来观察
    
    swift
    
    复制代码
    
    `var array = [1, 2, 3, 4]
    print(Mems.memStr(ofRef: array))
    //0x00007fff88a8dd18
    //0x0000000200000003
    //0x0000000000000004
    //0x0000000000000008
    //0x0000000000000001
    //0x0000000000000002
    //0x0000000000000003
    //0x0000000000000004` 
    
*   我们调整一下元素数量，再打印观察
    
    swift
    
    复制代码
    
    `var array = [Int]()
    for i in 1...8 {
     array.append(i)
    }
    print(Mems.memStr(ofRef: array))
    //0x00007fff88a8e460
    //0x0000000200000003
    //0x0000000000000008
    //0x0000000000000010
    //0x0000000000000001
    //0x0000000000000002
    //0x0000000000000003
    //0x0000000000000004
    //0x0000000000000005
    //0x0000000000000006
    //0x0000000000000007
    //0x0000000000000008` 
    

八、高级运算符
=======

1\. 溢出运算符（Overflow Operator）
----------------------------

*   1.  Swift的算数运算符出现溢出时会抛出运行时错误
*   2.  Swift有溢出运算符`&+、&-、&*`，用来支持溢出运算 ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6978fad6d78746afae3d0c5a5cdeaf20~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp?)

swift

复制代码

`var min = UInt8.min
print(min &- 1) // 255, Int8.max
var max = UInt8.max
print(max &+ 1) // 0, Int8.min
print(max &* 2) // 254, 等价于 max &+ max、` 

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/92913b09c78f4c9d8f1b5abb6aecbda9~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp?)

> **计算方式**

*   1.  类似于一个循环，最大值255再+1，就会回到0；最小值0再-1，就会回到255
*   2.  而`max &* 2`就等于`max &+ max`，也就是255 + 1 + 254，255 + 1会变为0，那么最后的值就是254 ![-w596](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/052d8810d49e4f789585499c901372a4~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

2\. 运算符重载（Operator Overload）
----------------------------

*   1.  `类`、`结构体`、`枚举`可以为现有的运算符提供自定义的实现，这个操作叫做`运算符重载`

swift

复制代码

`struct Point {
 var x: Int, y: Int
}
func + (p1: Point, p2: Point) -> Point {
 Point(x: p1.x + p2.x, y: p1.y + p2.y)
}
let p = Point(x: 10, y: 20) + Point(x: 11, y: 22)
print(p) // Point(x: 21, y: 42) Point(x: 11, y: 22)` 

*   2.  一般将运算符重载写在相关的`结构体`、`类`、`枚举`的内部

swift

复制代码

`struct Point {
 var x: Int, y: Int
 // 默认就是中缀运算符
 static func + (p1: Point, p2: Point) -> Point {
 Point(x: p1.x + p2.x, y: p1.y + p2.y)
 }
 static func - (p1: Point, p2: Point) -> Point {
 Point(x: p1.x - p2.x, y: p1.y - p2.y)
 }
 // 前缀运算符
 static prefix func - (p: Point) -> Point {
 Point(x: -p.x, y: -p.y)
 }
 static func += (p1: inout Point, p2: Point) {
 p1 = p1 + p2
 }
 static prefix func ++ (p: inout Point) -> Point {
 p += Point(x: 1, y: 1)
 return p
 }
 // 后缀运算符
 static postfix func ++ (p: inout Point) -> Point {
 let tmp = p
 p += Point(x: 1, y: 1)
 return tmp
 }
 static func == (p1: Point, p2: Point) -> Bool {
 (p1.x == p2.x) && (p1.y == p2.y)
 }
}
var p1 = Point(x: 10, y: 20)
var p2 = Point(x: 11, y: 22)
print(p1 + p2) // Point(x: 21, y: 42)
print(p2 - p1) // Point(x: 1, y: 2)
print(-p1) // Point(x: -10, y: -20)
p1 += p2
print(p1, p2) // Point(x: 21, y: 42) Point(x: 11, y: 22)
p1 = ++p2
print(p1, p2) // Point(x: 12, y: 23) Point(x: 12, y: 23)
p1 = p2++
print(p1, p2) // Point(x: 12, y: 23) Point(x: 13, y: 24)
print(p1 == p2) // false` 

3\. Equatable
-------------

*   1.  要想得知两个实例是否等价，一般做法是遵守`Equatable协议`，重载`==`运算符 于此同时，等价于`!=`运算符

swift

复制代码

`class Person: Equatable {
 var age: Int
 init(age: Int) {
 self.age = age
 }
 static func == (lhs: Person, rhs: Person) -> Bool {
 lhs.age == rhs.age
 }
}
var p1 = Person(age: 10)
var p2 = Person(age: 20)
print(p1 == p2) // false
print(p1 != p2) // true` 

*   2.  如果没有遵守`Equatable协议`，使用`!=`就会报错 ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d27c4247a3b24460ac35ad8614007b19~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  如果没有遵守`Equatable协议`，只重载`==`运算符，也可以使用`p1 == p2`的判断，但是遵守`Equatable协议`是为了能够在有限制的泛型函数中作为参数使用

swift

复制代码

`func equal<T: Equatable>(_ t1: T, _ t2: T) -> Bool {
 t1 == t2
}
print(equal(p1, p2)) // false` 

> **Swift为以下类型提供默认的`Equatable`实现**

*   1.  没有关联类型的枚举

swift

复制代码

`enum Answer {
 case right, wrong
}
var s1 = Answer.right
var s2 = Answer.wrong
print(s1 == s2)` 

*   2.  只拥有遵守`Equatable协议`关联类型的枚举
*   3.  系统很多自带类型都已经遵守了`Equatable协议`，类似`Int、Double`等

swift

复制代码

`enum Answer: Equatable {
 case right, wrong(Int)
}
var s1 = Answer.wrong(20)
var s2 = Answer.wrong(10)
print(s1 == s2)` 

*   4.  关联类型没有遵守`Equatable协议`的就会报错 ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fbe5768c60e74704ab7c5996cb3174fb~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   5.  只拥有遵守`Equatable协议`存储属性的结构体

swift

复制代码

`struct Point: Equatable {
 var x: Int, y: Int
}
var p1 = Point(x: 10, y: 20)
var p2 = Point(x: 11, y: 22)
print(p1 == p2) // false
print(p1 != p2) // true` 

*   6.  引用类型比较存储的地址值是否相等（是否引用着同一个对象），使用恒等运算符`===、!==`

swift

复制代码

`class Person {
}
var p1 = Person()
var p2 = Person()
print(p1 === p2) // false
print(p1 !== p2) // true` 

4\. Comparable
--------------

*   1.  要想比较两个实例的大小，一般做法是遵守`Comparable协议`，重载相应的运算符

swift

复制代码

`struct Student: Comparable {
 var age: Int
 var score: Int
 init(score: Int, age: Int) {
 self.score = score
 self.age = age
 }
 static func < (lhs: Student, rhs: Student) -> Bool {
 (lhs.score < rhs.score) || (lhs.score == rhs.score && lhs.age > rhs.age)
 }
 static func > (lhs: Student, rhs: Student) -> Bool {
 (lhs.score > rhs.score) || (lhs.score == rhs.score && lhs.age < rhs.age)
 }
 static func <= (lhs: Student, rhs: Student) -> Bool {
 !(lhs > rhs)
 }
 static func >= (lhs: Student, rhs: Student) -> Bool {
 !(lhs < rhs)
 }
}
var stu1 = Student(score: 100, age: 20)
var stu2 = Student(score: 98, age: 18)
var stu3 = Student(score: 100, age: 20)
print(stu1 > stu2) // true
print(stu1 >= stu2) // true
print(stu1 >= stu3) // true
print(stu1 <= stu3) // true
print(stu2 < stu1) // true
print(stu2 <= stu1) // true` 

5\. 自定义运算符（Custom Operator）
---------------------------

*   1.  可以`自定义新的运算符`: 在全局作用域使用`operator`进行声明

swift

复制代码

`prefix operator 前缀运算符
postfix operator 后缀运算符
infix operator 中缀运算符：优先级组
precedencegroup 优先级组 {
 associativity: 结合性（left\right\none）
 higherThan: 比谁的优先级更高
 lowerThan: 比谁的优先级低
 assignment: true代表在可选链操作中拥有跟赋值运算符一样的优先级
}` 

*   2.  `自定义运算符`的使用示例如下

swift

复制代码

`prefix operator +++
prefix func +++ (_ i: inout Int) {
 i += 2
}
var age = 10
+++age
print(age) // 12` 

swift

复制代码

`infix operator +-: PlusMinusPrecedence
precedencegroup PlusMinusPrecedence {
 associativity: none
 higherThan: AdditionPrecedence
 lowerThan: MultiplicationPrecedence
 assignment: true
}
struct Point {
 var x = 0, y = 0
 static func +- (p1: Point, p2: Point) -> Point {
 Point(x: p1.x + p2.x, y: p1.y - p2.y)
 }
}
var p1 = Point(x: 10, y: 20)
var p2 = Point(x: 5, y: 10)
print(p1 +- p2) // Point(x: 15, y: 10)` 

> **优先级组中的associativity的设置影响**

swift

复制代码

`associativity对应的三个选项
left: 从左往右执行，可以多个进行结合
right: 从右往左执行，可以多个进行结合
none: 不支持多个结合` 

*   3.  如果再增加一个计算就会报错，因为我们设置的`associativity`为`none` ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc1d00a4584b47388f5e57ee164d9c2f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  我们把`associativity`改为`left`或者`right`，再运行就可以了

swift

复制代码

`infix operator +-: PlusMinusPrecedence
precedencegroup PlusMinusPrecedence {
 associativity: left
 higherThan: AdditionPrecedence
 lowerThan: MultiplicationPrecedence
 assignment: true
}
var p3 = Point(x: 5, y: 10)
print(p1 +- p2 +- p3) // Point(x: 20, y: 0)` 

> **优先级组中的assignment的设置影响**

我们先看下面的示例代码

swift

复制代码

`class Person {
var age = 0
var point: Point = Point()
}
var p: Person? = nil
print(p?.point +- Point(x: 10, y: 20))` 

设置`assignment`为`true`的意思就是如果在运算中，前面的可选项为`nil`，那么运算符后面的代码就不会执行了

Apple文档参考链接： [developer.apple.com/documentati…](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswift%2Fswift_standard_library%2Foperator_declarations "https://developer.apple.com/documentation/swift/swift_standard_library/operator_declarations")

另一个： [docs.swift.org/swift-book/…](https://link.juejin.cn?target=https%3A%2F%2Fdocs.swift.org%2Fswift-book%2FReferenceManual%2FDeclarations.html "https://docs.swift.org/swift-book/ReferenceManual/Declarations.html")

九、扩展（Extension）
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

swift

复制代码

`extension Double {
 var km: Double { self * 1_000.0 }
 var m: Double { self }
 var dm: Double { self / 10.0 }
 var cm: Double { self / 100.0 }
 var mm: Double { self / 1_000.0 }
}` 

swift

复制代码

`extension Array {
 subscript(nullable idx: Int) -> Element? {
 if (startIndex..<endIndex).contains(idx) {
 return self[idx]
 }
 return nil
 }
}` 

swift

复制代码

`extension Int {
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
}` 

3\. 初始化器
--------

swift

复制代码

`class Person {
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
}` 

*   如果希望自定义初始化器的同时，编译器也能够生成默认初始化器，可以在扩展中编写自定义初始化器
    
    swift
    
    复制代码
    
    `struct Point {
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
    var p5 = Point(p4)` 
    
*   `required`的初始化器也不能写在扩展中 ![-w634](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/86b30907739b411ba4860320550b8df6~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

4\. 协议
------

*   1.  如果一个类型`已经实现了协议`的所有要求，但是`还没有声明它遵守`了这个协议，`可以通过扩展来让他遵守`这个协议
    
    swift
    
    复制代码
    
    `protocol TestProtocol {
     func test1()
    }
    class TestClass {
     func test1() {
     print("TestClass test1")
     }
    }
    extension TestClass: TestProtocol { }` 
    
    swift
    
    复制代码
    
    `extension BinaryInteger {
     func isOdd() -> Bool {self % 2 != 0 }
    }
    print(10.isOdd())` 
    
*   2.  `扩展`可以给`协议`提供`默认实现`，也`间接实现可选协议`的结果  
        `扩展`可以给`协议`扩充协议中从未声明过的方法
    
    swift
    
    复制代码
    
    `protocol TestProtocol {
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
    cls2.test2() // TestProtocol test2` 
    
    swift
    
    复制代码
    
    `class TestClass: TestProtocol {
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
    cls2.test2() // TestProtocol test2` 
    

5\. 泛型
------

swift

复制代码

`class Stack<E> {
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
}` 

*   1.  扩展中依然可以使用原类型中的泛型类型
    
    swift
    
    复制代码
    
    `extension Stack {
     func top() -> E {
     elements.last!
     }
    }` 
    
*   2.  符合条件才扩展
    
    swift
    
    复制代码
    
    `extension Stack: Equatable where E : Equatable {
     static func == (left: Stack, right: Stack) -> Bool {
     left.elements == right.elements
     }
    }` 
    

十、访问控制（Access Control）
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

swift

复制代码

`internal class Person {} // 变量类型
fileprivate var person: Person // 变量` 

![-w635](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eea1ff7e061d4999aa10e06cc88f009d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   3\. 参数类型、返回值类型 ≥ 函数

swift

复制代码

`// 参数类型：Int、Double
// 函数：func test
internal func test(_ num: Int) -> Double {
 return Double(num)
}` 

*   4.  父类 ≥ 子类

swift

复制代码

`class Person {}
class Student: Person {}` 

swift

复制代码

`public class Person {}
class Student: Person {}` 

![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/253c5018731a4da5b5efb8cd7228dd78~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   5\. 父协议 ≥ 子协议

swift

复制代码

`public protocol Sportable {}
internal protocol Runnalbe: Sportable {}` 

![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8ed33acfc6054650bacb1de9a9c813e1~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   6\. 原类型 ≥ typealias

swift

复制代码

`class Person {} // 原类型
private typealias MyPerson = Person` 

*   7.  原始值类型\\关联值类型 ≥ 枚举类型

swift

复制代码

`typealias MyInt = Int
typealias MyString = String
enum Score {
 case point(MyInt)
 case grade(MyString)
}` 

![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d2da62d6a3d74091819315c6949b036b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   8\. 定义类型A时用到的其他类型 ≥ 类型A

swift

复制代码

`typealias MyString = String
struct Dog {}
class Person {
 var age: MyString = ""
 var dog: Dog?
}` 

![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/09023b2368544bdb81e245da6d1e9091~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

3\. 元组类型
--------

*   元组类型的访问级别是所有成员类型最低的那个

swift

复制代码

`internal struct Dog { }
fileprivate class Person { }
// (Dog, Person)中更低的访问级别是fileprivate，所以元组的访问级别就是fileprivate
fileprivate var datal: (Dog, Person)
private var data2: (Dog, Person)` 

4\. 泛型类型
--------

*   泛型类型的访问级别是类型的访问级别以及所有泛型类型参数的访问级别中最低的那个

swift

复制代码

`internal class Car {}
fileprivate class Dog {}
public class Person<T1, T2> {}
// Person<Car, Dog>中比较的是Person、Car、Dog三个的访问级别最低的那个，也就是fileprivate，fileprivate就是泛型类型的访问级别
fileprivate var p = Person<Car, Dog>()` 

5\. 成员、嵌套类型
-----------

*   1.  类型的访问级别会影响成员（`属性`、`方法`、`初始化器`、`下标`），嵌套类型的默认访问级别
*   2.  一般情况下，类型为`private`或`fileprivate`，那么成员\\嵌套类型默认也是`private`或`fileprivate`

swift

复制代码

`fileprivate class FilePrivateClass { // fileprivate
 func f1() {} // fileprivate
 private func f2() {} // private
}
private class PrivateClass { // private
 func f() {} // private
}` 

*   3.  一般情况下，类型为`internal`或`public`，那么成员/嵌套类型默认是`internal`

swift

复制代码

`public class PublicClass { // public
 public var p1 = 0 // public
 var p2 = 0 // internal
 fileprivate func f1() {} // fileprivate
 private func f2() {} // private
}
class InternalClass { // internal
 var p = 0 // internal
 fileprivate func f1() {} // fileprivate
 private func f2() {} // private
}` 

**看下面几个示例，编译能否通过？**

示例1

swift

复制代码

`private class Person {}
fileprivate class Student: Person {}` 

swift

复制代码

`class Test {
 private class Person {}
 fileprivate class Student: Person {}
}` 

结果是第一段代码编译通过，第二段代码编译报错

![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d750e03e5ce144fe98c26befa71887b7~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

第一段代码编译通过，是因为两个全局变量不管是`private`还是`fileprivate`，作用域都是当前文件，所以访问级别就相同了

第二段代码的两个属性的作用域局限到类里面了，那访问级别就有差异了

示例2

swift

复制代码

`private struct Dog {
 var age: Int = 0
 func run() {}
}
fileprivate struct Person {
 var dog: Dog = Dog()
 mutating func walk() {
 dog.run()
 dog.age = 1
 }
}` 

swift

复制代码

`private struct Dog {
 private var age: Int = 0
 private func run() {}
}
fileprivate struct Person {
 var dog: Dog = Dog()
 mutating func walk() {
 dog.run()
 dog.age = 1
 }
}` 

结果是第一段代码编译通过，第二段代码编译报错 ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/763c5459c3f14f1f876a6c67893bea4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

第一段代码编译通过，是因为两个结构体的访问级别都是该文件内，所以访问级别相同

第二段代码报错是因为Dog里的属性和方法的访问级别是更低的了，虽然两个结构体的访问级别相同，但从Person里调用Dog中的属性和方法是访问不到的

**结论：直接在全局作用域下定义的`private`等于`fileprivate`**

6\. 成员的重写
---------

子类重写成员的访问级别必须 ≥ 子类的访问级别，或者 ≥ 父类被重写成员的访问级别

swift

复制代码

`class Person {
 internal func run() {}
}
fileprivate class Student: Person {
 fileprivate override func run() {}
}` 

父类的成员不能被成员作用域外定义的子类重写 ![-w641](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/73b4fef531b8438b8df637149f2c1833~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

放到同一个作用域下

swift

复制代码

`public class Person {
 private var age: Int = 0
  
 public class Student: Person {
 override var age: Int {
 set {}
 get { 10 }
 }
 }
}` 

7\. getter、setter
-----------------

*   1.  `getter、setter`默认自动接收它们所属环境的访问级别
*   2.  可以给`setter`单独设置一个比`getter`更低的访问级别，用以限制写的权限

swift

复制代码

`fileprivate(set) public var num = 10
num = 10
print(num)` 

![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bf43c0b5920a4302902ad7e5ff56a35b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

8\. 初始化器
--------

*   1.  如果一个`public类`想在另一个模块调用编译生成的默认无参初始化器，必须显式提供`public`的无参初始化器，因为`public类`的默认初始化器是`internal`级别
    
    swift
    
    复制代码
    
    `public class Person {
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
    }` 
    
*   2.  `required`初始化器 ≥ 它的默认访问级别
    
    swift
    
    复制代码
    
    `fileprivate class Person {
     internal required init() {}
    }` 
    
*   3.  当类是`public`的时候，它的默认初始化器就是`internal`级别的，所以不会报错
    
    swift
    
    复制代码
    
    `public class Person {
     internal required init() {}
    }` 
    
    ![-w639](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/47ab245d23184e2a9c20f566f14c6555~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
    
*   4.  如果结构体有`private\fileprivate`的存储实例属性，那么它的成员初始化器也是`private\fileprivate`，否则默认就是`internal` ![-w641](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ea49c229a71148738b54d4194a77083a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   5.  结构体里有一个属性设置为private，带有其他属性的初始化器也没有了 ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9bbbbab59a884181bfb5b45020035d68~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

9\. 枚举类型的case
-------------

*   1.  不能给`enum`的每个case单独设置访问级别 ![-w641](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/31bbc797440645668025dc4f6101c2c4~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   2.  每个case自动接收`enum`的访问级别
    
    swift
    
    复制代码
    
    `fileprivate enum Season {
     case spring // fileprivate
     case summer // fileprivate
     case autumn // fileprivate
     case winter // fileprivate
    }` 
    
*   3.  `public enum`定义的case也是`public`
    
    swift
    
    复制代码
    
    `public enum Season {
     case spring // public
     case summer // public
     case autumn // public
     case winter // public
    }` 
    

10\. 协议
-------

*   1.  协议中定义的要求自动接收协议的访问级别，不能单独设置访问级别 ![-w637](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/17ae162147ba4460be6e0bbb2e49f20a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   2.  `public`协议定义的要求也是`public`
    
    swift
    
    复制代码
    
    `public protocol Runnable {
     func run()
    }` 
    
*   3.  协议实现的访问级别必须 ≥ 类型的访问级别，或者 ≥ 协议的访问级别 ![-w641](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/12a3840994aa443ea9f81a71b2025068~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/16d1b6478fd244b0b6e8cf7f54e91d8e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

11\. 扩展
-------

*   1.  如果有显式设置扩展的访问级别，扩展添加的成员自动接收扩展的访问级别
    
    swift
    
    复制代码
    
    `class Person {
    }
    private extension Person {
     func run() {} // private
    }` 
    
*   2.  如果没有显式设置扩展的访问级别，扩展添加的成员的默认访问级别，跟直接在类型中定义的成员一样
    
    swift
    
    复制代码
    
    `private class Person {
    }
    extension Person {
     func run() {} // private
    }` 
    
*   3.  可以单独给扩展添加的成员设置访问级别
    
    swift
    
    复制代码
    
    `class Person {
    }
    extension Person {
     private func run() {} 
    }` 
    
*   4.  不能给用于遵守协议的扩展显式设置扩展的访问级别 ![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8c688d9e860454b8417dcc7e6cf2a9d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   5.  在同一文件中的扩展，可以写成类似多个部分的类型声明
*   6.  在原本的声明中声明一个私有成员，可以在同一个文件的扩展中访问它
*   7.  在扩展中声明一个私有成员，可以在同一文件的其他扩展中、原本声明中访问它
    
    swift
    
    复制代码
    
    `public class Person {
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
    }` 
    

12\. 将方法赋值给var\\let
-------------------

*   1.  方法也可以像函数那样，赋值给一个`let`或者`var`
    
    swift
    
    复制代码
    
    `struct Person {
     var age: Int
     func run(_ v : Int) { print("func run", age, v)}
     static func run(_ v: Int) { print("static func run", v)}
    }
    let fn1 = Person.run
    fn1(10) // static func run 10
    let fn2: (Int) -> () = Person.run
    fn2(20) // static func run 20
    let fn3: (Person) -> ((Int) -> ()) = Person.run
    fn3(Person(age: 18))(30) // func run 18 30` 
    

十一、内存管理
=======

1\. 基本概念
--------

*   跟`OC`一样，Swift也是采取基于`引用计数的ARC`内存管理方案（`针对堆空间`）
*   Swift的ARC中有三种引用:
*   a. **强引用（strong reference）** ： 默认情况下，引用都是强引用
    
    swift
    
    复制代码
    
    `class Person { }
    var po: Person?` 
    
*   b. **弱引用（weak reference）** ：通过`weak`定义弱引用
    
    swift
    
    复制代码
    
    `class Person { }
    weak var po: Person?` 
    
    *   必须是可选类型的`var`，因为实例销毁后，ARC会自动将弱引用设置为`nil` ![-w634](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/96b77e643805422dbe1fc1674df9988c~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
        
    *   ARC自动给弱引用设置`nil`时，不会触发属性观察器
        
*   c. **无主引用（unowned reference）** ： 通过`unowned`定义无主引用  
    不会产生强引用，实例销毁后仍然存储着实例的内存地址（类似于`OC`中的`unsafe_unretained`）
    
    swift
    
    复制代码
    
    `class Person { }
    unowned var po: Person?` 
    
    *   试图在实例销毁后访问无主引用，会产生运行时错误（野指针）

2\. weak、unowned的使用限制
---------------------

*   1.  `weak、unowned`只能用在`类实例`上面
*   2.  只有`类`是存放在`堆空间`的，堆空间的内存是需要我们手动管理的

swift

复制代码

`protocol Liveable: AnyObject { }
class Person { }
weak var po: Person?
weak var p1: AnyObject?
weak var p2: Liveable?
unowned var p10: Person?
unowned var p11: AnyObject?
unowned var p12: Liveable?` 

3\. Autoreleasepool
-------------------

![-w628](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2423f7b20efc41a182c192968f2f029d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

swift

复制代码

`class Person {
var age: Int
var name: String
init(age: Int, name: String) {
 self.age = age
 self.name = name
}
func run() {}
}
autoreleasepool {
let p = Person(age: 20, name: "Jack")
p.run()
}` 

4\. 循环引用（Reference Cycle）
-------------------------

*   1.  `weak、unowned`都能解决循环引用的问题，`unowned`要比`weak`少一些性能消耗
*   2.  在生命周期中可能会变为`nil`的使用`weak` ![-w649](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ae54ada24fdd4980826c095c975900c3~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  初始化赋值后再也不会变为`nil`的使用`unowned` ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cf3332da09bc4522ba39c957fe78014d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

5\. 闭包的循环引用
-----------

*   1.  闭包表达式默认会对用到的外层对象产生额外的强引用（对外层对象进行了`retain`操作）
*   2.  下面代码会产生循环引用，导致Person对象无法释放（看不到Person的`deinit`被调用）

swift

复制代码

`class Person {
 var fn: (() -> ())?
 func run() { print("run") }
 deinit { print("deinit") }
}
func test() {
 let p = Person()
 p.fn = { p.run() }
}
test()` 

*   3.  在闭包表达式的捕获列表声明`weak`或`unowned`引用，解决循环引用问题

swift

复制代码

`func test() {
 let p = Person()
 p.fn = {
 [weak p] in
 p?.run()
 }
}` 

swift

复制代码

`func test() {
 let p = Person()
 p.fn = {
 [unowned p] in
 p.run()
 }
}` 

*   4.  如果想在定义闭包属性的同时引用`self`，这个闭包必须是`lazy`的（因为在实例初始化完毕之后才能引用`self`） ![-w645](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fd9d5910b51d48be8c9453ede114e27d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

swift

复制代码

`class Person {
 lazy var fn: (() -> ()) = {
 [weak self] in
 self?.run()
 }
 func run() { print("run") }
 deinit { print("deinit") }
}` 

*   5.  闭包fn内部如果用到了实例成员（属性、方法），编译器会强制要求明确写出`self` ![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1fcf107651554f919175ef073d648907~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   6.  如果`lazy属性`是闭包调用的结果，那么不用考虑循环引用的问题（因为闭包调用后，闭包的生命周期就结束了）

swift

复制代码

`class Person {
 var age: Int = 0
 lazy var getAge: Int = {
 self.age
 }()
 deinit { print("deinit") }
}` 

6\. @escaping
-------------

*   1.  非逃逸闭包、逃逸闭包，一般都是`当做参数`传递给函数
*   2.  非逃逸闭包：闭包调用发生在函数结束前，闭包调用在函数作用域内

swift

复制代码

`typealias Fn = () -> ()
func test1(_ fn: Fn) { fn() }` 

*   3.  逃逸闭包：闭包有可能在函数结束后调用，闭包调用逃离了函数的作用域，需要通过`@escaping`声明

swift

复制代码

`typealias Fn = () -> ()
var gFn: Fn?
func test2(_ fn: @escaping Fn) { gFn = fn }` 

*   4.  `DispatchQueue.global().async`也是一个逃逸闭包 ![-w605](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1ec645caee914960bfdc6c01b8ff915f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) 使用示例如下

swift

复制代码

`import Dispatch
typealias Fn = () -> ()
func test3(_ fn: @escaping Fn) {
DispatchQueue.global().async {
 fn()
}
}` 

swift

复制代码

`class Person {
var fn: Fn
// fn是逃逸闭包
init(fn: @escaping Fn) {
 self.fn = fn
}
func run() {
 // DispatchQueue.global().async也是一个逃逸闭包
 // 它用到了实例成员（属性、方法），编译器会强制要求明确写出self
 DispatchQueue.global().async {
 self.fn()
 }
}
}` 

*   5.  逃逸闭包不可以捕获`inout`参数  
        看下面的示例 ![-w646](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/13af1d9ba59c440db4a5adbe2103ac9a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w644](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a29ee1f1c3b340c99961c7165c92062e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   如果逃逸闭包里捕获的是外面的局部变量的地址值，就会有局部变量已经不存在了之后才会执行逃逸闭包的情况，那么捕获的值就是不合理的
*   而非逃逸闭包是可以保证在局部变量的生命周期没有结束的时候就能够执行闭包的

7\. 内存访问冲突（Conflicting Access to Memory）
----------------------------------------

内存访问冲突会在两个访问满足下列条件时发生：

*   `至少一个是写入`操作
*   它们访问的是`同一块内存`
*   它们的`访问时间重叠`（比如在同一个函数内）

1.  看下面示例，哪个会造成内存访问冲突

swift

复制代码

`func plus(_ num: inout Int) -> Int { num + 1 }
var number = 1
number = plus(&number)` 

swift

复制代码

`var step = 1
func increment(_ num: inout Int) { num += step }
increment(&step)` 

*   第一个不会造成`内存访问`冲突，第二个`会造成内存访问`冲突，并报错
*   因为在`num += step`中既访问了step的值，同时又进行了写入操作 ![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/13e0e749f3d84fa7a87497bcf9854523~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) 解决方案如下

swift

复制代码

`var step = 1
func increment(_ num: inout Int) { num += step }
var copyOfStep = step
increment(&copyOfStep)
step = copyOfStep` 

2.看下面示例，哪个会造成内存访问冲突

swift

复制代码

`func balance(_ x: inout Int, _ y: inout Int) {
let sum = x + y
x = sum / 2
y = sum - x
}
var num1 = 42
var num2 = 30
balance(&num1, &num2) // ok
balance(&num1, &num1) // Error` 

*   第一句执行不会报错，因为传进去的是两个变量的地址值，不会冲突
*   第二句会报错，传进去的都是同一个变量的地址值，而内部又同时进行了对num1的读写操作，所以会造成内存访问冲突
*   而且都不用运行，编译器直接就报错

![-w635](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6dfc7e4c8a4a4c3fac30b869db7d65c8~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

3.看下面示例，哪个会造成内存访问冲突

swift

复制代码

`struct Player {
var name: String
var health: Int
var energy: Int
mutating func shareHealth(with teammate: inout Player) {
 balance(&teammate.health, &health)
}
}
var oscar = Player(name: "Oscar", health: 10, energy: 10)
var maria = Player(name: "Maria", health: 5, energy: 10)
oscar.shareHealth(with: &maria)
oscar.shareHealth(with: &oscar)` 

*   第一句执行不会报错，第二句执行会报错
*   因为传入的地址都是同一个，会造成内存访问冲突，而且也是在编译阶段就直接报错了 ![-w647](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e1bf5017ac334ea085cf407349f5800e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

4.看下面示例，哪个会造成内存访问冲突

swift

复制代码

`var tuple = (health: 10, energy: 20)
balance(&tuple.health, &tuple.energy)
var holly = Player(name: "Holly", health: 10, energy: 10)
balance(&holly.health, &holly.energy)` 

*   这两个都会报错，都是操作了同一个存储空间，同时进行了读写操作 ![-w712](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2ca2a3d6d91a43b298cfecdfb8f3e96a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

如果下面的条件可以满足，就说明重叠访问结构体的属性是安全的

*   你只访问实例存储属性，不是计算属性或者类属性
*   结构体是局部变量而非全局变量
*   结构体要么没有被闭包捕获，要么只被非逃逸闭包捕获

swift

复制代码

 `func test() {
 var tuple = (health: 10, energy: 20)
 balance(&tuple.health, &tuple.energy)
 var holly = Player(name: "Holly", health: 10, energy: 10)
 balance(&holly.health, &holly.energy)
 }
 test()` 

十二、指针
=====

1\. 指针简介
--------

Swift中也有专门的指针类型，这些都被定性为`Unsafe`（不安全的）,常见的有以下四种类型:

*   **`UnsafePointer<Pointee>`:** 类似于

swift

复制代码

`const Pointee *` 

*   **`UnsafeMutablePointer<Pointee>`:** 类似于

swift

复制代码

`Pointee *` 

*   **`UnsafeRawPointer`:** 类似于

swift

复制代码

`const void *` 

*   **`UnsafeMutableRawPointer`:** 类似于

swift

复制代码

`void *` 

*   **`UnsafePointer`、`UnsafeMutablePointer`**

swift

复制代码

`var age = 10
func test1(_ ptr: UnsafeMutablePointer<Int>) {
ptr.pointee += 10
}
func test2(_ ptr: UnsafePointer<Int>) {
print(ptr.pointee)
}
test1(&age)
test2(&age) // 20
print(age) // 20` 

*   **`UnsafeRawPointer`、`UnsafeMutableRawPointer`**

swift

复制代码

`var age = 10 
func test3(_ ptr: UnsafeMutableRawPointer) {
ptr.storeBytes(of: 30, as: Int.self)
}
func test4(_ ptr: UnsafeRawPointer) {
print(ptr.load(as: Int.self))
}
test3(&age)
test4(&age) // 30
print(age) // 30` 

2\. 指针应用示例
----------

> **`NSArray`的遍历方法中也使用了指针类型**

![-w545](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/77332c011f144a93afe938beac6ba27d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

swift

复制代码

`var arr = NSArray(objects: 11, 22, 33, 44)
arr.enumerateObjects { (obj, idx, stop) in
print(idx, obj)
if idx == 2 { // 下标为2就停止遍历
 stop.pointee = true
}
print("----")
}
//0 11
//----
//1 22
//----
//2 33
//----` 

*   `arr.enumerateObjects`中的stop并不等同于`break`的作用，设置完stop也会继续执行完作用域中的代码，然后才会判断是否需要下一次循环
*   在Swift中遍历元素更适用于`enumerated`的方式

swift

复制代码

`var arr = NSArray(objects: 11, 22, 33, 44)
for (idx, obj) in arr.enumerated() {
 print(idx, obj)
 if idx == 2 { break }
}` 

3\. 获得指向某个变量的指针
---------------

*   我们可以调用`withUnsafeMutablePointer、withUnsafePointer`来获得指向变量的指针

swift

复制代码

`var age = 11
var ptr1 = withUnsafeMutablePointer(to: &age) { $0 }
var ptr2 = withUnsafePointer(to: &age) { $0 }
ptr1.pointee = 22
print(ptr2.pointee) // 22
print(age) // 22
var ptr3 = withUnsafeMutablePointer(to: &age) { UnsafeMutableRawPointer($0)}
var ptr4 = withUnsafePointer(to: &age) { UnsafeRawPointer($0) }
ptr3.storeBytes(of: 33, as: Int.self)
print(ptr4.load(as: Int.self)) // 33
print(age) // 33` 

*   `withUnsafeMutablePointer`的实现本质就是将传入的变量地址值放到闭包表达式中作为返回值

swift

复制代码

`func withUnsafeMutablePointer<Result, T>(to value: inout T, _ body: (UnsafeMutablePointer<T>) throws -> Result) rethrows -> Result {
 try body(&value)
}` 

4\. 获得指向堆空间实例的指针
----------------

swift

复制代码

`class Person {}
var person = Person()
// ptr中存储的还是person指针变量的地址值
var ptr = withUnsafePointer(to: &person) { UnsafeRawPointer($0) }
// 从指针变量里取8个字节，也就是取出存储的堆空间地址值
var heapPtr = UnsafeRawPointer(bitPattern: ptr.load(as: UInt.self))
print(heapPtr!)` 

5\. 创建指针
--------

> 第一种方式

swift

复制代码

`var ptr = UnsafeRawPointer(bitPattern: 0x100001234)` 

> 第二种方式

swift

复制代码

`// 创建
var ptr = malloc(16)
// 存
ptr?.storeBytes(of: 11, as: Int.self)
ptr?.storeBytes(of: 22, toByteOffset: 8, as: Int.self)
// 取
print(ptr?.load(as: Int.self)) // 11
print(ptr?.load(fromByteOffset: 8, as: Int.self)) // 22
// 销毁
free(ptr)` 

> 第三种方式

swift

复制代码

`var ptr = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 1)
// 从前8个字节开始存储11
ptr.storeBytes(of: 11, as: Int.self)
// 指向后8个字节开始存储22
ptr.advanced(by: 8).storeBytes(of: 22, as: Int.self)
print(ptr.load(as: Int.self)) // 11
print(ptr.advanced(by: 8).load(as: Int.self)) // 22
ptr.deallocate()` 

> 第四种方式

swift

复制代码

`var ptr = UnsafeMutablePointer<Int>.allocate(capacity: 3)
// 先初始化内存
ptr.initialize(to: 11)
// ptr.successor表示下一个Int，也就是跳一个类型字节大小
ptr.successor().initialize(to: 22)
ptr.successor().successor().initialize(to: 33)
print(ptr.pointee) // 11
// ptr + 1，意味着跳过一个Int类型大小的字节数
print((ptr + 1).pointee) // 22
print((ptr + 2).pointee) // 33
print(ptr[0]) // 11
print(ptr[1]) // 22
print(ptr[2]) // 33
// 释放要调用反初始化，调用了几个就释放几个
ptr.deinitialize(count: 3)
ptr.deallocate()` 

swift

复制代码

`class Person {
var age: Int
var name: String
init(age: Int, name: String) {
 self.age = age
 self.name = name
}
deinit {
 print(name, "deinit")
}
}
var ptr = UnsafeMutablePointer<Person>.allocate(capacity: 3)
ptr.initialize(to: Person(age: 10, name: "Jack"))
(ptr + 1).initialize(to: Person(age: 11, name: "Rose"))
(ptr + 2).initialize(to: Person(age: 12, name: "Kate"))
ptr.deinitialize(count: 3)
ptr.deallocate()` 

6\. 指针之间的转换
-----------

swift

复制代码

`var ptr = UnsafeMutableRawPointer.allocate(byteCount: 16, alignment: 1)
// 假想一个类型
ptr.assumingMemoryBound(to: Int.self)
// 不确定类型的pointer+8是真的加8个字节，不同于有类型的pointer
(ptr + 8).assumingMemoryBound(to: Double.self).pointee = 22.0
// 强制转换类型为Int
print(unsafeBitCast(ptr, to: UnsafePointer<Int>.self).pointee) // 11
print(unsafeBitCast((ptr + 8), to: UnsafePointer<Double>.self).pointee) // 22.0
ptr.deallocate()` 

*   `unsafeBitCast`是忽略数据类型的强制转换，不会因为数据类型的变化而改变原来的内存数据，所以这种转换也是不安全的
*   类似于`C++`中的`reinterpret_cast`
*   我们可以用`unsafeBitCast`的强制转换指针类型，直接将person变量里存储的堆空间地址值拷贝到ptr指针变量中，由于ptr是指针类型，那么它所指向的地址值就是堆空间地址

swift

复制代码

`class Person {}
var person = Person()
var ptr = unsafeBitCast(person, to: UnsafeRawPointer.self)
print(ptr)` 

*   另一个转换方式，可以先转成`UInt类型`的变量，然后再从变量中取出存储的地址值

swift

复制代码

`class Person {}
var person = Person()
var address = unsafeBitCast(person, to: UInt.self)
var ptr = UnsafeRawPointer(bitPattern: address)` 

看下面的示例 ![-w944](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3541f61318f34cf1be6e18394cba135c~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   `Int`和`Double`的内存结构应该是有差异的，但通过`unsafeBitCast`转换的age3的内存结构和age1是一样的，所以说`unsafeBitCast`只会转换数据类型，不会改变内存数据

十三、字面量（Literal）
===============

1\. 基本概念
--------

*   下面代码中的`10、false、"Jack"`就是字面量

swift

复制代码

`var age = 10
var isRed = false
var name = "Jack"` 

*   常见字面量的默认类型 ![-w507](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95680f960f7a4430b437754b0ce8567b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   可以通过`typealias`修改字面量的默认类型

swift

复制代码

`typealias FloatLiteralType = Float
typealias IntegerLiteralType = UInt8
var age = 10 // UInt8
var height = 1.68 // Float` 

Swift自带的绝大部分类型、都支持直接通过字面量进行初始化

swift

复制代码

`Bool、Int、Float、Double、String、Array、Dictionary、Set、Optional等` 

2\. 字面量协议
---------

Swift自带类型之所以能够通过字面量初始化，是因为它们遵守了对应的协议

*   Bool: `ExpressibleByBooleanLiteral`
*   Int: `ExpressibleByIntegerLiteral`
*   Float、Double: `ExpressibleByIntegerLiteral、ExpressibleByFloatLiteral`
*   String: `ExpressibleByStringLiteral`
*   Array、Set: `ExpressibleByArrayLiteral`
*   Dictionary: `ExpressibleByDictionaryLiteral`
*   Optional: `ExpressibleByNilLiteral`

swift

复制代码

`var b: Bool = false // ExpressibleByBooleanLiteral
var i: Int = 10 // ExpressibleByIntegerLiteral
var f0: Float = 10 // ExpressibleByIntegerLiteral
var f1: Float = 10.0 // ExpressibleByFloatLiteral
var d0: Double = 10 // ExpressibleByIntegerLiteral
var d1: Double = 10.0 // ExpressibleByFloatLiteral
var s: String = "jack" // ExpressibleByStringLiteral
var arr: Array = [1, 2, 3] // ExpressibleByArrayLiteral
var set: Set = [1, 2, 3] // ExpressibleByArrayLiteral
var dict: Dictionary = ["jack" : 60] // ExpressibleByDictionaryLiteral
var o: Optional<Int> = nil // ExpressibleByNilLiteral` 

3.字面量协议应用
---------

有点类似于`C++`中的`转换构造函数`

swift

复制代码

`extension Int: ExpressibleByBooleanLiteral {
public init(booleanLiteral value: Bool) {
 self = value ? 1 : 0
}
}
var num: Int = true
print(num) // 1` 

swift

复制代码

`class Student: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, CustomDebugStringConvertible {
var name: String = ""
var score: Double = 0
required init(floatLiteral value: Double) {
 self.score = value
}
required init(integerLiteral value: Int) {
 self.score = Double(value)
}
required init(stringLiteral value: String) {
 self.name = value
}
required init(unicodeScalarLiteral value: String) {
 self.name = value
}
required init(extendedGraphemeClusterLiteral value: String) {
 self.name = value
}
var debugDescription: String {
 "name=(name), score=(score)"
}
}
var stu: Student = 90
print(stu) // name=, score=90.0
stu = 98.5
print(stu) // name=, score=98.5
stu = "Jack"
print(stu) // name=Jack, score=0.0` 

swift

复制代码

`struct Point {
var x = 0.0, y = 0.0
}
extension Point: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
init(arrayLiteral elements: Double...) {
 guard elements.count > 0 else { return }
 self.x = elements[0]
 guard elements.count > 1 else { return }
 self.y = elements[1]
}
init(dictionaryLiteral elements: (String, Double)...) {
 for (k, v) in elements {
 if k == "x" { self.x = v }
 else if k == "y" { self.y = v }
 }
}
}
var p: Point = [10.5, 20.5]
print(p) // Point(x: 10.5, y: 20.5)
p = ["x" : 11, "y" : 22]
print(p) // Point(x: 11.0, y: 22.0)` 

十四、模式匹配（Pattern）
================

1\. 基本概念
--------

> **什么是模式？**

*   模式是用于匹配的规则，比如`switch的case、捕捉错误的catch、if\guard\while\for语句的条件`等

Swift中的模式有

*   通配符模式（Wildcard Pattern）
*   标识符模式（Identifier Pattern）
*   值绑定模式（Value-Binding Pattern）
*   元组模式（Tuple Pattern）
*   枚举Case模式（Enumeration Case Pattern）
*   可选模式（Optional Pattern）
*   类型转换模式（Type-Casting Pattern）
*   表达式模式（Expression Pattern）

2\. 通配符模式（Wildcard Pattern）
---------------------------

*   `_`匹配任何值
*   `_?`匹配非`nil`值

swift

复制代码

`enum Life {
case human(name: String, age: Int?)
case animal(name: String, age: Int?)
}
func check(_ life: Life) {
switch life {
case .human(let name, _):
 print("human", name)
case .animal(let name, _?):
 print("animal", name)
default:
 print("other")
}
}
check(.human(name: "Rose", age: 20)) // human Rose
check(.human(name: "Jack", age: nil)) // human Jack
check(.animal(name: "Dog", age: 5)) // animal Dog
check(.animal(name: "Cat", age: nil)) // other` 

2.标识符模式（Identifier Pattern）
---------------------------

给对应的变量、常量名赋值

swift

复制代码

`var age = 10
let name = "jack"` 

3.值绑定模式（Value-Binding Pattern）
------------------------------

swift

复制代码

`let point = (3, 2)
switch point {
case let (x, y):
print("The point is at ((x), (y).")
}` 

4.元组模式（Tuple Pattern）
---------------------

swift

复制代码

`let points = [(0, 0), (1, 0), (2, 0)]
for (x, _) in points {
print(x)
}` 

swift

复制代码

`let name: String? = "jack"
let age = 18
let info: Any = [1, 2]
switch (name, age, info) {
case (_?, _, _ as String):
print("case")
default:
print("default")
} // default` 

swift

复制代码

`var scores = ["jack" : 98, "rose" : 100, "kate" : 86]
for (name, score) in scores {
print(name, score)
}` 

5\. 枚举Case模式（Enumeration Case Pattern）
--------------------------------------

*   `if case`语句等价于只有1个`case`的`switch`语句

swift

复制代码

`let age = 2
// 原来的写法
if age >= 0 && age <= 9 {
print("[0, 9]")
}
// 枚举Case模式
if case 0...9 = age {
print("[0, 9]")
}
guard case 0...9 = age else { return }
print("[0, 9]")
// 等同于switch case
switch age {
case 0...9: print("[0, 9]")
default: break
}` 

swift

复制代码

`let ages: [Int?] = [2, 3, nil, 5]
for case nil in ages {
print("有nil值")
break
} // 有nil值` 

swift

复制代码

`let points = [(1, 0), (2, 1), (3, 0)]
for case let (x, 0) in points {
print(x)
} // 1 3` 

6\. 可选模式（Optional Pattern）
--------------------------

swift

复制代码

`let age: Int? = 42
if case .some(let x) = age { print(x) }
if case let x? = age { print(x) }` 

swift

复制代码

`let ages: [Int?] = [nil, 2, 3, nil, 5]
for case let age? in ages {
print(age)
} // 2 3 5
// 同上面效果等价
let ages: [Int?] = [nil, 2, 3, nil, 5]
for item in ages {
if let age = item {
 print(age)
}
}` 

swift

复制代码

`func check(_ num: Int?) {
switch num {
case 2?: print("2")
case 4?: print("4")
case 6?: print("6")
case _?: print("other")
case _: print("nil")
}
}
check(4) // 4
check(8) // other
check(nil) // nil` 

7.类型转换模式（Type-Casting Pattern）
------------------------------

swift

复制代码

`let num: Any = 6
switch num {
case is Int:
// 编译器依然认为num是Any类型
print("is Int", num)
//case let n as Int:
//    print("as Int", n + 1)
default:
break
}` 

swift

复制代码

`class Animal {
func eat() {
 print(type(of: self), "eat")
}
}
class Dog: Animal {
func run() {
 print(type(of: self), "run")
}
}
class Cat: Animal {
func jump() {
 print(type(of: self), "jump")
}
}
func check(_ animal: Animal) {
switch animal {
case let dog as Dog:
 dog.eat()
 dog.run()
case is Cat:
 animal.eat()
default: break
}
}
check(Dog()) // Dog eat, Dog run
check(Cat()) // Cat eat` 

8.表达式模式（Expression Pattern）
---------------------------

表达式模式用在`case`中

swift

复制代码

`let point = (1, 2)
switch point {
case (0, 0):
print("(0, 0) is at the origin.")
case (-2...2, -2...2):
print("((point.0), (point.1) is near the origin.")
default:
print("The point is at ((point.0), (point.1).")
} // (1, 2) is near the origin.` 

通过反汇编，我们可以看到其内部会调用`~=运算符`来计算`(-2...2, -2...2)`这个区间

![-w714](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e9c12335d5e4f01bac6820368e90f2b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

9\. 自定义表达式模式
------------

可以通过重载运算符，自定义表达式模式的匹配规则

swift

复制代码

`struct Student {
var score = 0, name = ""
// pattern：放的是case后面的值
// value：放的是switch后面的值
static func ~= (pattern: Int, value: Student) -> Bool {
 value.score >= pattern
}
static func ~= (pattern: ClosedRange<Int>, value: Student) -> Bool {
 pattern.contains(value.score)
}
static func ~= (pattern: Range<Int>, value: Student) -> Bool {
 pattern.contains(value.score)
}
}
var stu = Student(score: 75, name: "Jack")
switch stu {
case 100: print(">= 100")
case 90: print(">= 90")
case 80..<90: print("[80, 90]")
case 60...79: print("[60, 79]")
case 0: print(">= 0")
default: break
} // [60, 79]
if case 60 = stu {
print(">= 60")
} // >= 60
var info = (Student(score: 70, name: "Jack"), "及格")
switch info {
case let (60, text): print(text)
default: break
} // 及格` 

swift

复制代码

`extension String {
static func ~= (pattern: (String) -> Bool, value: String) -> Bool {
 pattern(value)
}
}
func hasPrefix(_ prefix: String) -> ((String) -> Bool) {
{ $0.hasPrefix(prefix) }
}
func hasSuffix(_ suffix: String) -> ((String) -> Bool) {
{ $0.hasSuffix(suffix) }
}
var str = "jack"
switch str {
case hasPrefix("j"), hasSuffix("k"):
print("以j开头，以k结尾")
default: break
} // 以j开头，以k结尾` 

swift

复制代码

`func isEven(_ i: Int) -> Bool { i % 2 == 0 }
func isOdd(_ i: Int) -> Bool { i % 2 != 0 }
extension Int {
static func ~= (pattern: (Int) -> Bool, value: Int) -> Bool {
 pattern(value)
}
}
var age = 9
switch age {
case isEven: print("偶数")
case isOdd: print("奇数")
default: print("其他")
}` 

swift

复制代码

`extension Int {
static func ~= (pattern: (Int) -> Bool, value: Int) -> Bool {
 pattern(value)
}
}
prefix operator ~>
prefix operator ~>=
prefix operator ~<
prefix operator ~<=
prefix func ~> (_ i: Int) -> ((Int) -> Bool) {{ $0 > i }}
prefix func ~>= (_ i: Int) -> ((Int) -> Bool) {{ $0 >= i }}
prefix func ~< (_ i: Int) -> ((Int) -> Bool) {{ $0 < i }}
prefix func ~<= (_ i: Int) -> ((Int) -> Bool) {{ $0 <= i }}
var age = 9
switch age {
case ~>=0: print("1")
case ~>10: print("2")
default: break
} // 1` 

10\. where
----------

可以使用`where`为模式匹配增加匹配条件

swift

复制代码

`var data = (10, "Jack")
switch data {
case let (age, _) where age > 10:
print(data.1, "age>10")
case let (age, _) where age > 0:
print(data.1, "age>0")
default:
break
}` 

swift

复制代码

`var ages = [10, 20, 44, 23, 55]
for age in ages where age > 30 {
print(age)
} // 44 55` 

swift

复制代码

`protocol Stackable {
associatedtype Element
}
protocol Container {
associatedtype Stack: Stackable where Stack.Element: Equatable
}
func equal<S1: Stackable, S2: Stackable>(_ s1: S1, _ s2: S2) -> Bool where S1.Element == S2.Element, S1.Element : Hashable { false }` 

swift

复制代码

`extension Container where Self.Stack.Element: Hashable { }` 

专题系列文章
======

1\. 前知识
-------

*   **[01-探究iOS底层原理|综述](https://juejin.cn/post/7089043618803122183/ "https://juejin.cn/post/7089043618803122183/")**
*   **[02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】](https://juejin.cn/post/7093842449998561316/ "https://juejin.cn/post/7093842449998561316/")**
*   **[03-探究iOS底层原理|LLDB](https://juejin.cn/post/7095079758844674056 "https://juejin.cn/post/7095079758844674056")**
*   **[04-探究iOS底层原理|ARM64汇编](https://juejin.cn/post/7115302848270696485/ "https://juejin.cn/post/7115302848270696485/")**

2\. 基于OC语言探索iOS底层原理
-------------------

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

3\. 基于Swift语言探索iOS底层原理
----------------------

关于`函数`、`枚举`、`可选项`、`结构体`、`类`、`闭包`、`属性`、`方法`、`swift多态原理`、`String`、`Array`、`Dictionary`、`引用计数`、`MetaData`等Swift基本语法和相关的底层原理文章有如下几篇:

*   **[01-📝Swift5常用核心语法|了解Swift【Swift简介、Swift的版本、Swift编译原理】](https://juejin.cn/spost/7119020967430455327 "https://juejin.cn/spost/7119020967430455327")**
*   **[02-📝Swift5常用核心语法|基础语法【Playground、常量与变量、常见数据类型、字面量、元组、流程控制、函数、枚举、可选项、guard语句、区间】](https://juejin.cn/spost/7119510159109390343 "https://juejin.cn/spost/7119510159109390343")**
*   **[03-📝Swift5常用核心语法|面向对象【闭包、结构体、类、枚举】](https://juejin.cn/spost/7119513630550261774 "https://juejin.cn/spost/7119513630550261774")**
*   **[04-📝Swift5常用核心语法|面向对象【属性、inout、类型属性、单例模式、方法、下标、继承、初始化】](https://juejin.cn/spost/7119714488181325860 "https://juejin.cn/spost/7119714488181325860")**
*   **[05-📝Swift5常用核心语法|高级语法【可选链、协议、错误处理、泛型、String与Array、高级运算符、扩展、访问控制、内存管理、字面量、模式匹配】](https://juejin.cn/spost/7119722433589805064 "https://juejin.cn/spost/7119722433589805064")**
*   **[06-📝Swift5常用核心语法|编程范式与Swift源码【从OC到Swift、函数式编程、面向协议编程、响应式编程、Swift源码分析】](https://juejin.cn/spost/7253350009289424933 "https://juejin.cn/spost/7253350009289424933")**

其它底层原理专题
========

1\. 底层原理相关专题
------------

*   **[01-计算机原理|计算机图形渲染原理这篇文章](https://juejin.cn/post/7018755998823219213 "https://juejin.cn/post/7018755998823219213")**
*   **[02-计算机原理|移动终端屏幕成像与卡顿 ](https://juejin.cn/post/7019117942377807908 "https://juejin.cn/post/7019117942377807908")**

2\. iOS相关专题
-----------

*   **[01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理](https://juejin.cn/post/7019193784806146079 "https://juejin.cn/post/7019193784806146079")**
*   **[02-iOS底层原理|iOS动画渲染原理](https://juejin.cn/post/7019200157119938590 "https://juejin.cn/post/7019200157119938590")**
*   **[03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理](https://juejin.cn/post/7019497906650497061/ "https://juejin.cn/post/7019497906650497061/")**
*   **[04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案](https://juejin.cn/post/7020613901033144351 "https://juejin.cn/post/7020613901033144351")**

3\. webApp相关专题
--------------

*   **[01-Web和类RN大前端的渲染原理](https://juejin.cn/post/7021035020445810718/ "https://juejin.cn/post/7021035020445810718/")**

4\. 跨平台开发方案相关专题
---------------

*   **[01-Flutter页面渲染原理](https://juejin.cn/post/7021057396147486750/ "https://juejin.cn/post/7021057396147486750/")**

5\. 阶段性总结:Native、WebApp、跨平台开发三种方案性能比较
-------------------------------------

*   **[01-Native、WebApp、跨平台开发三种方案性能比较](https://juejin.cn/post/7021071990723182606/ "https://juejin.cn/post/7021071990723182606/")**

6\. Android、HarmonyOS页面渲染专题
---------------------------

*   **[01-Android页面渲染原理](https://juejin.cn/post/7021840737431978020/ "https://juejin.cn/post/7021840737431978020/")**
*   **[02-HarmonyOS页面渲染原理](# "#") (`待输出`)**

7\. 小程序页面渲染专题
-------------

*   **[01-小程序框架渲染原理](https://juejin.cn/post/7021414123346853919 "https://juejin.cn/post/7021414123346853919")**