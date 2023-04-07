//
//  main.swift
//  协议
//
//  Created by 沈春兴 on 2022/7/7.
//

import Foundation

protocol Drawable {
    func draw()
    var x: Int { get set } //可读可写
    var y: Int { get } //只读
    subscript(index: Int) -> Int { get set } //下标可读可写
    
    static func draw2() //类型方法
    static func draw3() //类型方法
    
    mutating func draw4() //允许值类型修改自身实现协议
    
    init(x: Int , y:Int) //初始化
}
//协议中定义方法时不能有默认参数值
//默认情况下，协议中定义的内容必须全部都实现 p 也有办法办到只实现部分内容，以后的课程会讲到

protocol Test1 {}
protocol Test2 {}
protocol Test3 {}

class TestClass : Test1, Test2, Test3 {}


class Person : Drawable {
    var x: Int { //可读可写 ，另一种实现：var x : Int = 0
        get { 0 }
        set {}
    }
    var y: Int { 0 } //只读 ，另一种实现：let y : Int = 0
    func draw() {
        print("Person draw")
    }
    subscript(index: Int) -> Int { //可读可写
        set {}
        get { index }
    }
    
    //禁止重写
    static func draw2() {
        
    }
    
    //允许重写
    class func draw3() {
        
    }
    
    //类不需要mutating
    func draw4() {
        
    }
    
    //自动会加上required
    required init(x: Int, y: Int) {
        
    }
}

//协议名称和父类方法相同，override是继承要求，required是协议必须要的
protocol Livable2 {
    init(age: Int)
}
class Person2 {
    init(age: Int) {}
}
class Student2 : Person2, Livable2 {
    required override init(age: Int) { //协议名称和父类方法相同，override是继承要求，required是协议必须要的
        super.init(age: age)
    }
}


//init、init?、init!的实现
protocol Livable3 {
  init()
  init?(age: Int)
  init!(no: Int)
}
class Person3 : Livable3 {
  required init() {}
  // required init!() {}
    
  required init?(age: Int) {}
  // required init!(age: Int) {}
  // required init(age: Int) {}
    
  required init!(no: Int) {}
  // required init?(no: Int) {}
  // required init(no: Int) {}
}


//协议的继承
protocol Runnable4 {
   func run()
}
protocol Livable4 : Runnable4 {
   func breath()
}
class Person4 : Livable4 {
   func breath() {}
   func run() {}
}


//协议组合
protocol Livable5 {}
protocol Runnable5 {}
class Person5 {}
//协议组合，可以包含1个类类型(最多1个)
// 接收Person或者其子类的实例
func fn0(obj: Person5) {}
// 接收遵守Livable协议的实例
func fn1(obj: Livable5) {}
// 接收同时遵守Livable、Runnable协议的实例
func fn2(obj: Livable5 & Runnable5) {}
// 接收同时遵守Livable、Runnable协议、并且是Person或者其子类的实例 func fn3(obj: Person & Livable & Runnable) {}
typealias RealPerson = Person5 & Livable5 & Runnable5
// 接收同时遵守Livable、Runnable协议、并且是Person或者其子类的实例 func fn4(obj: RealPerson) {}


//让枚举遵守CaseIterable协议，可以遍历枚举
enum Season : CaseIterable {
    case spring, summer, autumn, winter
}
let seasons = Season.allCases
print(seasons.count) // 4
for season in seasons {
    print(season)
} // spring summer autumn winter


//遵守CustomStringConvertible、 CustomDebugStringConvertible协议，都可以自定义实例的打印字符串
class Person6 : CustomStringConvertible, CustomDebugStringConvertible {
    var age = 0
    var description: String { "person_\(age)" }
    var debugDescription: String { "debug_person_\(age)" }
}
var person = Person6()
print(person) // person_0 debugPrint(person) // debug_person_0
debugPrint(person)
//print调用的是CustomStringConvertible协议的description
//debugPrint、po调用的是CustomDebugStringConvertible协议的debugDescription


//Swift提供了2种特殊的类型:Any、AnyObject
//Any:可以代表任意类型(枚举、结构体、类，也包括函数类型)
//AnyObject:可以代表任意类类型(在协议后面写上: AnyObject代表只有类能遵守这个协议) 在协议后面写上:AnyObject也代表只有类能遵守这个协议
var stu: Any = 10
stu = "Jack"
stu = Person6()
// 创建1个能存放任意类型的数组
//var data = Array<Any>()
var data = [Any]()
data.append(1)
data.append(3.14)
data.append(Person6())
data.append("Jack")
data.append({ 10 })


//is as? as! as
//is用来判断是否为某种类型，as用来做强制类型转换
protocol Runnable7 { func run() }
class Person7 {}
class Student7 : Person7, Runnable7 {
    func run() {
        print("Student run")
    }
    func study() {
        print("Student study")
    }
}

var stu77: Any = 10
print(stu77 is Int) // true
stu77 = "Jack"
print(stu77 is String) // true
stu77 = Student7()
print(stu77 is Person7) // true
print(stu77 is Student7) // true
print(stu77 is Runnable7) // true

var stu7: Any = 10
(stu7 as? Student7)?.study() // 没有调用study
stu7 = Student7()
(stu7 as? Student7)?.study() // Student study
(stu7 as! Student7).study() // Student study
(stu7 as? Runnable7)?.run() // Student run

var data7 = [Any]()
data7.append(Int("123") as Any)

var d7 = 10 as Double
print(d7) // 10.0



//X.self、 X.Type 、AnyClass
//X.self是一个元类型(metadata)的指针，metadata存放着类型相关信息，8个字节
//X.self属于X.Type类型
class Person8 {}
class Student8 : Person8 {}
var perType: Person8.Type = Person8.self
var stuType: Student8.Type = Student8.self
perType = Student8.self

var anyType: AnyObject.Type = Person8.self //AnyObject.Type 任何类类型
anyType = Student8.self

var anyType2: AnyClass = Person8.self //系统定义：public typealias AnyClass = AnyObject.Type
anyType2 = Student8.self

var per = Person8()
var perType88 = type(of: per) // Person8.self
print(Person8.self == type(of: per)) // true


//元类型
class Animal { required init() {} } //为了让子类必须实现init，可以cls.init()创建类
class Cat : Animal {}
class Dog : Animal {}
class Pig : Animal {}
func create(_ clses: [Animal.Type]) -> [Animal] { //传入类的类型数组，创建类
    var arr = [Animal]()
    for cls in clses {
      arr.append(cls.init())
    }
    return arr
}
print(create([Cat.self, Dog.self, Pig.self]))//[Cat,Dog,Pig]


class Person9 {
    var age: Int = 0
}
class Student9 : Person9 {
    var no: Int = 0
}
print(class_getInstanceSize(Student9.self)) // 32 要求传入的就是AnyClass类型，也就是AnyObject.Type
print(class_getSuperclass(Student9.self)!) // Person9 获取Student9的父类
print(class_getSuperclass(Person9.self)!) // Swift._SwiftObject 获取Person9的父类，根类Swift._SwiftObject
print(class_getSuperclass(NSObject.self)) // nil
//从结果可以看得出来，Swift还有个隐藏的基类:Swift._SwiftObject p可以参考Swift源码:https://github.com/apple/swift/blob/master/stdlib/public/runtime/SwiftObject.h


//Self代表当前类型
 class Person10 {
    var age = 1
    static var count = 2
    func run() {
        print(self.age) // 1
        print(Self.count) // 2
    }
}
//Self一般用作返回值类型，限定返回值跟方法调用者必须是同一类型(也可以作为参数类型)。类似oc的instancetype
protocol Runnable11 {
    func test() -> Self
}
class Person11 : Runnable11 {
    required init() {} //必须加上required，为了让子类必须实现，直接调用init
    func test() -> Self {
        type(of: self).init()
    }
}
class Student11 : Person11 {}
var p11 = Person11()
print(p11.test()) // Person11
var stu11 = Student11()
print(stu11.test())// Student11

