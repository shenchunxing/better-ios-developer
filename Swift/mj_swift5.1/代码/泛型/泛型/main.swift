//
//  main.swift
//  泛型
//
//  Created by 沈春兴 on 2022/7/7.
//

import Foundation

//泛型可以将类型参数化，提高代码复用率，减少代码量 n 泛型函数赋值给变量
//c++泛型本质：生成多个泛型函数
//swift泛型本质：Swift 中的所有类型都存在多个抽象级别。比如：一个 Int 值是一个具体类型，可以传递给确定类型的函数。但是 Int 值也可能传递给类型为泛型 T 的函数，此时该泛型函数希望能够间接接收该参数，从而适应其他可能的泛型类型，如：Float、String 等。当 Int 值传递给泛型函数时，它被认为比其为 Int 时处于更高的抽象级别。这种在抽象级别之间进行转化的过程被称为是 重抽象。
func swapValues<T>(_ a: inout T, _ b: inout T) {
      (a, b) = (b, a)
}
func test<T1, T2>(_ t1: T1, _ t2: T2) {
    
}
var fn: (Int, Double) -> () = test

var i1 = 10
var i2 = 20
swapValues(&i1, &i2)

var d1 = 10.0
var d2 = 20.0
swapValues(&d1, &d2)

struct Date {
   var year = 0, month = 0, day = 0
}
var dd1 = Date(year: 2011, month: 9, day: 10)
var dd2 = Date(year: 2012, month: 10, day: 11)
swapValues(&dd1, &dd2) //交换date



class Stack<E> {
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
//泛型继承
class SubStack<E> : Stack<E> {
    
}
var stack = Stack<Int>()
stack.push(11)
stack.push(22)
stack.push(33)
print(stack.top()) // 33
print(stack.pop()) // 33
print(stack.pop()) // 22
print(stack.pop()) // 11
print(stack.size()) // 0


//结构体泛型
struct Stack2<E> {
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

//泛型枚举
enum Score<T> {
    case point(T)
    case grade(String)
}
let score0 = Score<Int>.point(100)
let score1 = Score.point(100)
let score2 = Score.point(99.5)
let score3 = Score<Int>.grade("A")


//关联类型
protocol Stackable {
    associatedtype Element // 关联类型
    mutating func push(_ element: Element)
    mutating func pop() -> Element
    func top() -> Element
    func size() -> Int
}

class Stack3<E> : Stackable {
  // typealias Element = E
  var elements = [E]()
  func push(_ element: E) { elements.append(element) }
  func pop() -> E {  elements.removeLast() }
  func top() -> E { elements.last! }
  func size() -> Int { elements.count }
}

class StringStack : Stackable {
    // 给关联类型设定真实类型
    // typealias Element = String
    var elements = [String]()
    func push(_ element: String) { elements.append(element) }
    func pop() -> String { elements.removeLast() }
    func top() -> String { elements.last! }
    func size() -> Int { elements.count }
}
var ss = StringStack()
ss.push("Jack")
ss.push("Rose")



//类型约束
protocol Runnable { }
class Person { }

func swapValues<T : Person & Runnable>(_ a: inout T, _ b: inout T) {
   (a, b) = (b, a)
}

protocol Stackable4 {
   associatedtype Element: Equatable //协议类型约束必须遵守Equatable
}
class Stack4<E : Equatable> : Stackable4 {
    typealias Element = E
}

func equal<S1: Stackable4, S2: Stackable4>(_ s1: S1, _ s2: S2) -> Bool where S1.Element == S2.Element, S1.Element : Hashable { //S1、S2遵守Stackable4协议，同时S1、S2的关联类型是相同的，S1的关联类型遵守Hashable
   return false
}

var stack1 = Stack4<Int>()
var stack2 = Stack4<String>()
// error: requires the types 'Int' and 'String' be equivalent equal(stack1, stack2)
//equal(stack1, stack2)


//协议类型的注意点
protocol Runnable2 { }
class Person2 : Runnable2 {}
class Car2 : Runnable2 {}
func get2(_ type: Int) -> Runnable2 {
    if type == 0 {
        return Person2()
    }
    return Car2()
}
var r2 = get2(0)
var r22 = get2(1)

//如果协议中有associatedtype
 protocol Runnable3 {
    associatedtype Speed
    var speed: Speed { get }
}
class Person3 : Runnable3 {
    var speed: Double { 0.0 }
}
class Car3 : Runnable3 {
    var speed: Int { 0 }
}

//Runnable3里面有关联类型，Speed，编译无法确定。因此报错
//func get2(_ type: Int) -> Runnable3 {
//    if type == 0 {
//        return Person2()
//    }
//    return Car2()
//}

//解决方案1:泛型解决
func get3<T : Runnable3>(_ type: Int) -> T {
   if type == 0 {
       return Person3() as! T
   }
   return Car3() as! T
}
var r3: Person3 = get3(0)
var r33: Car3 = get3(1)

//不透明类型
//解决方案2:使用some关键字声明一个不透明类型
func get4(_ type: Int) -> some Runnable3 { Car3() }
var r4 = get4(0)
var r44 = get4(1)
//some限制只能返回一种类型
//Protocol 'Runnable3' can only be used as a generic constraint because it has Self or associated type requirements
//func get5(_ type: Int) -> Runnable3 {
//    if type == 0 {
//        return Person3()
//    }
//    return Car3()
//}


//some除了用在返回值类型上，一般还可以用在属性类型上
protocol Runnable5 { associatedtype Speed }
class Dog5 : Runnable5 { typealias Speed = Double }
class Person5 {
    var pet: some Runnable5 {
        return Dog5()
    }
}


//可选项的本质就是泛型枚举类型
//public enum Optional<Wrapped> : ExpressibleByNilLiteral {
//    case none
//    case some(Wrapped)
//    public init(_ some: Wrapped)
//}

//等价写法
var age: Int? = 10
var age0: Optional<Int> = Optional<Int>.some(10)
var age1: Optional = .some(10)
var age2 = Optional.some(10)
var age3 = Optional(10)

//等价写法
age = nil
age3 = .none

//等价写法
var age22: Int? = nil
var age222 = Optional<Int>.none
var age2222: Optional<Int> = .none

//可以混合写：语法糖
var age00: Int? = .none
age00 = 10
age00 = .some(20)
age00 = nil


//可选项和switch的配合使用
switch age {
case let v?: //age存在
  print("some", v)
case nil: //age = nil
  print("none")
}

switch age {
case let .some(v): //age存在
  print("some", v)
case .none: //age = nil
  print("none")
}


//多重可选项
var width: Int? = 10
var width_: Int?? = width
width_ = nil

//等价于
var width1 = Optional.some(Optional.some(10))
width1 = .none


var height:Int?? = 10
//等价于
var height1:Optional<Optional> = 10

