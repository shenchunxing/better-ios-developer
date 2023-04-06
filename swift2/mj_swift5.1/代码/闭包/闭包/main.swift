//
//  main.swift
//  闭包
//
//  Created by 沈春兴 on 2022/7/6.
//

import Foundation

//闭包的写法
func sum(_ v1 : Int , _ v2 : Int) -> Int { v1 + v2}

var fn = {
    (v1 : Int , v2 : Int) -> Int in
    return v1 + v2
}
fn(10,20)

let fn2 = {
    (v1 : Int , v2 : Int) -> Int in
    return v1 + v2
}(10,20)


//闭包简写
func exec(v1 : Int , v2 : Int , fn:(Int , Int) -> Int) {
    print(fn(v1, v2))
}
exec(v1: 10, v2: 20) { (v1 : Int, v2 : Int) -> Int in
    return v1 + v2
}
exec(v1: 10, v2: 20) { v1, v2 in
    v1 + v2
}
exec(v1: 10, v2: 20, fn: {$0 + $1})
exec(v1: 10, v2: 20, fn: +)

//尾随闭包
func exec(fn:(Int , Int) -> Int) {
    print(fn(1,2))
}
exec(fn: {$0 + $1})
exec() {$0 + $1}
exec{$0 + $1}


//数组排序
var nums = [11,2,18,6,5,68,45]
func cmp(i1 : Int , i2 : Int) -> Bool {
    return i1 > i2
}
nums.sort(by: cmp)
nums.sort { i1, i2 in
    return i1 < i2
}
nums.sort(by: { i1, i2 in return i1 < i2 })
nums.sort(by: { i1,i2 in i1 < i2 })
nums.sort(by: {$0 < $1})
nums.sort(by: <)
nums.sort() {$0 < $1}
nums.sort{$0 < $1}

var functions:[() -> Int] = []
for i in 1...3 {
    functions.append { i }
}
for f in functions {
    print(f())
}

//返回值是函数类型，那么参数的修饰要保持统一
func add(_ num : Int) -> (inout Int) -> Void {
    func plus(v : inout Int) {
        v += num
    }
    return plus
}
var num1 = 5
add(20)(&num1)
print("num1 = \(num1)")

func testClosure5() {
    func getNumber() -> Int {
        let a = 10
        let b = 11
        print("getNumber")
        return a + b
    }
    
    func getFirstPositive1(_ v1: Int, _ v2: () -> Int) -> Int {
        print("getFirstPositive1")
        return v1 > 0 ? v1 : v2()
    }
    
    // 如果第1个数大于0，返回第一个数。否则返回第2个数
    func getFirstPositive2(_ v1: Int, _ v2: @autoclosure () -> Int) -> Int {
        print("getFirstPositive2")
        return v1 > 0 ? v1 : v2()
    }
    
    getFirstPositive2(10, 20)
}
print("---------")
testClosure5()

func testClosure4() {
    var functions: [() -> Int] = []
    for i in 1...3 {
        functions.append { i }
        //    func myFunc() -> Int {
        //        return i
        //    }
        //    functions.append(myFunc)
    }
    for f in functions {
        print(f())
    }
}

func testClosure3() {
    typealias Fn = (Int) -> (Int, Int)
    
    func getFns() -> (Fn, Fn) {
        var num1 = 0 // alloc
        var num2 = 0 // alloc
        func plus(_ i: Int) -> (Int, Int) {
            num1 += i
            num2 += i << 1
            return (num1, num2)
        }
        func minus(_ i: Int) -> (Int, Int) {
            num1 -= i
            num2 -= i << 1
            return (num1, num2)
        }
        return (plus, minus)
    }
    
    let (p, m) = getFns()
    p(6) // (6, 12)
    m(5) // (1, 2)
    p(4) // (5, 10)
    m(3) // (2, 4)
}

func testClosure2() {
    class Person {
        var age: Int = 10
    }
    
    typealias Fn = (Int) -> Int
    
    
    func getFn() -> Fn {
        // 局部变量
        var person1 = Person()
        var person2 = Person()
        
        func plus(_ i: Int) -> Int {
            person1.age += i
            person2.age += i
            return person1.age + person2.age
        }
        
        return plus
    } // 返回的plus和num形成了闭包
    
    var fn1 = getFn()
    print(fn1(1)) // 1
    print(fn1(3)) // 4
    
    var fn2 = getFn()
    print(fn2(2)) // 2
    print(fn2(4)) // 6
}

func testClosure() {
    var fn: (Int, Int) -> Int = { $0 + $1 }
    func exec(fn: (Int, Int) -> Int) {
        print(fn(1, 2))
    }
    exec { $0 + $1 }
}
