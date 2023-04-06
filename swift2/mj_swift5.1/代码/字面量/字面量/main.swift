//
//  main.swift
//  字面量
//
//  Created by 沈春兴 on 2022/7/8.
//

import Foundation

//字面量协议应用
extension Int : ExpressibleByBooleanLiteral {
   public init(booleanLiteral value: Bool) {
       self = value ? 1 : 0
   }
}
var num: Int = true
print(num) // 1
//有点类似于C++中的转换构造函数

class Student : ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, ExpressibleByStringLiteral, CustomStringConvertible {
    var name: String = ""
    var score: Double = 0
    required init(floatLiteral value: Double) { self.score = value }
    required init(integerLiteral value: Int) { self.score = Double(value) }
    //字符串初始化有多种实现
    required init(stringLiteral value: String) { self.name = value }
    required init(unicodeScalarLiteral value: String) { self.name = value }
    required init(extendedGraphemeClusterLiteral value: String) { self.name = value }
    var description: String { "name=\(name),score=\(score)" }
}
var stu: Student = 90
print(stu) // name=,score=90.0
stu = 98.5
print(stu) // name=,score=98.5
stu = "Jack"
print(stu) // name=Jack,score=0.0


struct Point {
   var x = 0.0, y = 0.0
}
extension Point : ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {
    init(arrayLiteral elements: Double...) {
        guard elements.count > 0 else {
            return
        }
        self.x = elements[0]
        
        guard elements.count > 1 else {
            return
        }
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
print(p) // Point(x: 11.0, y: 22.0)

