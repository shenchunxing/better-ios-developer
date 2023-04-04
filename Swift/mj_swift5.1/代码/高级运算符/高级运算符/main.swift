//
//  main.swift
//  高级运算符
//
//  Created by 沈春兴 on 2022/7/7.
//

import Foundation

//Swift的算数运算符出现溢出时会抛出运行时错误
//Swift有溢出运算符(&+、&-、&*)，用来支持溢出运算
var min = UInt8.min
print(min &- 1) // 255, Int8.max
var max = UInt8.max
print(max &+ 1) // 0, Int8.min
print(max &* 3) // 253, 等价于 max &+ max &+ max


//运算符重载
//类、结构体、枚举可以为现有的运算符提供自定义的实现，这个操作叫做:运算符重载
struct Point {
    var x: Int, y: Int
}
//全局函数的方式
func + (p1: Point, p2: Point) -> Point {
    Point(x: p1.x + p2.x, y: p1.y + p2.y)
}
let p = Point(x: 10, y: 20) + Point(x: 11, y: 22)
print(p) // Point(x: 21, y: 42)


struct Point2 {
    var x: Int, y: Int
    static func + (p1: Point2, p2: Point2) -> Point2 {
       Point2(x: p1.x + p2.x, y: p1.y + p2.y)
    }
    
    static func - (p1: Point2, p2: Point2) -> Point2 {
        Point2(x: p1.x - p2.x, y: p1.y - p2.y)
    }
    
    //前缀
    static prefix func - (p: Point2) -> Point2 {
        Point2(x: -p.x, y: -p.y)
    }
    
    static func += (p1: inout Point2, p2: Point2) {
        p1 = p1 + p2
    }
    
    static prefix func ++ (p: inout Point2) -> Point2 {
        p += Point2(x: 1, y: 1)
        return p
    }
    
    //后缀
    static postfix func ++ (p: inout Point2) -> Point2 {
        let tmp = p
        p += Point2(x: 1, y: 1)
        return tmp
    }
    
    static func == (p1: Point2, p2: Point2) -> Bool {
        (p1.x == p2.x) && (p1.y == p2.y)
    }
}



//Equatable：要想得知2个实例是否等价，一般做法是遵守Equatable 协议，重载== 运算符 p与此同时，等价于重载了 != 运算符
//Swift为以下类型提供默认的Equatable实现 1.没有关联类型的枚举 2.只拥有遵守Equatable协议关联类型的枚举 3.只拥有遵守 Equatable 协议存储属性的结构体
struct Point3 : Equatable {
   var x: Int, y: Int
}
var p3 = Point3(x: 10, y: 20)
var p33 = Point3(x: 11, y: 22)
print(p3 == p33) // false
print(p3 != p33) // true
//引用类型比较存储的地址值是否相等(是否引用着同一个对象)，使用恒等运算符=== 、!==

class Person : Equatable {
    var age: Int
    init(age: Int) {
        self.age = age
    }
    static func == (lhs:Person , rhs:Person) -> Bool {
        lhs.age == rhs.age
    }
}
var person1 = Person(age: 10)
var person2 = Person(age: 10)
print(person1 == person2)

enum Answer {
    case wrong
    case right
}
var a1 = Answer.wrong
var a2 = Answer.right
print(a1 == a2)



//Comparable
// score大的比较大，若score相等，age小的比较大
struct Student : Comparable {
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

//要想比较2个实例的大小，一般做法是: 遵守Comparable协议  && 重载相应的运算符
var stu1 = Student(score: 100, age: 20)
var stu2 = Student(score: 98, age: 18)
var stu3 = Student(score: 100, age: 20)
print(stu1 > stu2) // true
print(stu1 >= stu2) // true
print(stu1 >= stu3) // true
print(stu1 <= stu3) // true
print(stu2 < stu1) // true
print(stu2 <= stu1) // true




//自定义运算符:需要全局作用域声明
prefix operator +++

//声明一个详细的中缀运算符+-
infix operator +- : PlusMinusPrecedence
precedencegroup PlusMinusPrecedence {
    associativity: none //结合性none表示没有结合性(left\right\none)
    higherThan: AdditionPrecedence //优先级比+高
    lowerThan: MultiplicationPrecedence//优先级比*低
    assignment: true//可选操作中拥有个赋值运算符一样的优先级
}

struct Point4 {
    var x: Int, y: Int
    static prefix func +++ (point: inout Point4) -> Point4 {
       Point4(x: point.x + point.x, y: point.y + point.y)
    }
    static func +- (left: Point4, right: Point4) -> Point4 {
       Point4(x: left.x + right.x, y: left.y - right.y)
    }
    static func +- (left: Point4?, right: Point4) -> Point4 {
       Point4(x: left?.x ?? 0 + right.x, y: left?.y ?? 0 - right.y)
    }
}

var p4 = Point4(x: 10, y: 30)
var p5 = p4 +- Point4(x: 1, y: 2)
