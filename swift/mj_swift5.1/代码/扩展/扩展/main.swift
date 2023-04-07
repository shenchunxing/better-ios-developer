//
//  main.swift
//  扩展
//
//  Created by 沈春兴 on 2022/7/8.
//

import Foundation

extension Double {
    var km: Double { self * 1_000.0 }
    var m: Double { self }
    var dm: Double { self / 10.0 }
    var cm: Double { self / 100.0 }
    var mm: Double { self / 1_000.0 }
}

extension Int {
    func repetitions(task: () -> Void) {
        for _ in 0..<self {
            task()
        }
    }
    mutating func square() -> Int {
        self = self * self
        return self
    }
    enum Kind {
        case negative, zero, positive
    }
    var kind: Kind {
        switch self {
            case 0: return .zero
            case let x where x > 0: return .positive
            default: return .negative
       }
    }
    subscript(digitIndex: Int) -> Int {
        var decimalBase = 1
        for _ in 0..<digitIndex {
            decimalBase *= 10
        }
        return (self / decimalBase) % 10
    }
    
}

extension Array {
    subscript(nullable idx: Int) -> Element? {
        if (startIndex..<endIndex).contains(idx) {
            return self[idx]
        }
        return nil
   }
}
var arr = [10,20,30]
print(arr[nullable: -1] ?? 0)//nil
print(arr[nullable: 1] as Any) //Optional(20)
print(arr[nullable: 3] as Any)//nil

3.repetitions {
   print("1")
}

var age : Int = 10
print(age.square())

print(10.kind)
print(456[1])


class Person {
    var age: Int
    var name: String
    init(age: Int, name: String) {
        self.age = age
        self.name = name
    }
}
extension Person : Equatable {
    static func == (left: Person, right: Person) -> Bool {
        left.age == right.age && left.name == right.name
    }
    convenience init() { //扩展里面可以写原本被覆盖的init()初始化器
        self.init(age: 0, name: "")
    }
}
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
var p3 = Point(y: 20)
var p4 = Point(x: 10, y: 20)
var p5 = Point(p4)


//所有整数都遵守BinaryInteger协议
//判断是否是奇数
extension BinaryInteger {
    func isOdd() -> Bool { self % 2 != 0}
}


//扩展可以给协议提供默认实现，也间接实现『可选协议』的效果 n 扩展可以给协议扩充『协议中从未声明过的方法』
protocol TestProtocol {
    func test1()
}
extension TestProtocol {
    func test1() { print("TestProtocol test1") }
    func test2() { print("TestProtocol test2") }
}

class TestClass : TestProtocol {}
var cls = TestClass()
cls.test1() // TestProtocol test1
cls.test2() // TestProtocol test2
var cls1: TestProtocol = TestClass()
cls1.test1() // TestProtocol test1
cls1.test2() // TestProtocol test2


class TestClass2 : TestProtocol {
    func test1() { print("TestClass2 test1") }
    func test2() { print("TestClass2 test2") }
}
var cls2 = TestClass2()
cls2.test1() // TestClass2 test1 //默认自己类的方法实现
cls2.test2() // TestClass2 test2//默认自己类的方法实现
var cls22: TestProtocol = TestClass2()
cls22.test1() // TestClass22 test1 //默认自己类的方法实现（遵守TestProtocol的类肯定实现了test1）
cls22.test2() // TestProtocol test2 这里因为默认的TestProtocol是没有test2方法的，而又必须遵守的TestProtocol（遵守TestProtocol的类可能没有实现test2），会优先从协议扩展找
 



class Stack<E> {
    var elements = [E]()
    func push(_ element: E) { elements.append(element) }
    func pop() -> E { elements.removeLast() }
    func size() -> Int { elements.count }
}
// 扩展中依然可以使用原类型中的泛型类型
extension Stack {
    func top() -> E { elements.last! }
}
// 符合条件才扩展
extension Stack : Equatable where E : Equatable {
    static func == (left: Stack, right: Stack) -> Bool { left.elements == right.elements }
}
