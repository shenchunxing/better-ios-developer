//
//  main.swift
//  函数式编程
//
//  Created by 沈春兴 on 2022/7/13.
//

import Foundation

var arr8 = [1, 2, 3, 4]
// [2, 4, 6, 8]
var arr9 = arr8.map { $0 * 2 }
// [2, 4]
var arr10 = arr8.filter { $0 % 2 == 0 }
// 10 reduce:$0:上一次遍历返回的结果（初始值是0） $1:每次遍历到的数组元素
var arr11 = arr8.reduce(0) { $0 + $1 }
// 10
var arr12 = arr8.reduce(0, +)

//传入一个函数实现
func double(_ i: Int) -> Int { i * 2 }
var arr4 = [1, 2, 3, 4]
// [2, 4, 6, 8]
print(arr4.map(double))


var arr5 = [1, 2, 3]
// [[1], [2, 2], [3, 3, 3]] map会创建多个数组
var arr6 = arr5.map { Array.init(repeating: $0, count: $0) }
// [1, 2, 2, 3, 3, 3]，flatMap只会创建一个数组
var arr7 = arr5.flatMap { Array.init(repeating: $0, count: $0) }

//Array的常见操作
var arr = ["123", "test", "jack", "-30"]
// [Optional(123), nil, nil, Optional(-30)]
var arr2 = arr.map { Int($0) }
// [123, -30],compactMap只过滤出可以转换成功的结果
var arr3 = arr.compactMap { Int($0) }

// 使用reduce实现map、filter的功能
var arr13 = [1, 2, 3, 4]
// [2, 4, 6, 8]
print(arr13.map { $0 * 2 })
//一开始$0是[],$1是1，则$0 = [] + [2] = [2],数组是支持运算符重载的。下一次：[2] + [4] = [2,4]
print(arr13.reduce([]) { $0 + [$1 * 2] })
// [2, 4]
print(arr13.filter { $0 % 2 == 0 })
//[]  ->  []+[2] = [2]   ->   [2]  ->  [2]+[4] = [2,4]
print(arr13.reduce([]) { $1 % 2 == 0 ? $0 + [$1] : $0 })




//lazy的优化
let arr14 = [1, 2, 3]
let result = arr14.map {
    (i: Int) -> Int in
    print("mapping \(i)")
    return i * 2
}
//直接打印了mapping 1  mapping 2  mapping 3，还没运行到begin
print("begin-----")
print("mapped", result[0])//mapping 2
print("mapped", result[1])//mapping 4
print("mapped", result[2])//mapping 6
print("end----")

let arr15 = [1, 2, 3]
let result2 = arr15.lazy.map {
    (i: Int) -> Int in
    print("mapping \(i)")
    return i * 2
}
print("begin-----")
print("mapped", result2[0])//mapping 1  mapping 2。实现了调用的时候才去加载
print("mapped", result2[1])//mapping 2  mapping 4
print("mapped", result2[2])//mapping 3  mapping 6
print("end----")




//Optional的map和flatMap
var num1: Int? = 10
// Optional(20)
var num2 = num1.map { $0 * 2 } // $0 = 10，已经被解包了的
var num3: Int? = nil
// nil
var num4 = num3.map { $0 * 2 } //nil直接返回，并没有执行map


var num5: Int? = 10
// Optional(Optional(20))
var num6 = num5.map { Optional.some($0 * 2) }
// Optional(20) flatMap只会包装一层
var num7 = num5.flatMap { Optional.some($0 * 2) }

var num8: Int? = 10
var num9 = (num8 != nil) ? (num8! + 10) : nil
var num10 = num8.map { $0 + 10 }
// num10、num9写法是等价的

var fmt = DateFormatter()
fmt.dateFormat = "yyyy-MM-dd"
var str: String? = "2011-09-10"
// old
var date1 = str != nil ? fmt.date(from: str!) : nil
var date2 = str.flatMap {fmt.date(from:$0)}
// new
var date3 = str.flatMap(fmt.date)

var score: Int? = 98
// old
var str1 = score != nil ? "socre is \(score!)" : "No score"
// new
var str2 = score.map { "score is \($0)" } ?? "No score"


struct Person {
   var name: String
   var age: Int
}
var items = [
    Person(name: "jack", age: 20),
    Person(name: "rose", age: 21),
    Person(name: "kate", age: 22)
]
// old
func getPerson1(_ name: String) -> Person? {
    let index = items.firstIndex { $0.name == name }
    return index != nil ? items[index!] : nil
}
// new
func getPerson2(_ name: String) -> Person? {
    return items.firstIndex { $0.name == name }.map { items[$0] }
}


struct Person2 {
var name: String
var age: Int
init?(_ json: [String : Any]) {
    guard let name = json["name"] as? String, let age = json["age"] as? Int else {
    return nil
           }
           self.name = name
           self.age = age
    }
}
var json: Dictionary? = ["name" : "Jack", "age" : 10]
// old
var p1 = json != nil ? Person2(json!) : nil
var p2 = json.flatMap {Person2.init($0)}
// new
var p3 = json.flatMap(Person2.init)



//FP实践 – 传统写法
 // 假设要实现以下功能:[(num + 3) * 5 - 1] % 10 / 2
var num = 1
func add1(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
func sub1(_ v1: Int, _ v2: Int) -> Int { v1 - v2 }
func multiple1(_ v1: Int, _ v2: Int) -> Int { v1 * v2 }
func divide1(_ v1: Int, _ v2: Int) -> Int { v1 / v2 }
func mod1(_ v1: Int, _ v2: Int) -> Int { v1 % v2 }
print(divide1(mod1(sub1(multiple1(add1(num, 3), 5), 1), 10), 2))



//FP实践 – 函数式写法
//接受2个参数的变成只接受一个参数，返回一个函数
func add(_ v: Int) -> (Int) -> Int { { $0 + v } } //$0 是 返回的函数的参数
func sub(_ v: Int) -> (Int) -> Int { { $0 - v } }
func multiple(_ v: Int) -> (Int) -> Int { { $0 * v } }
func divide(_ v: Int) -> (Int) -> Int { { $0 / v } }
func mod(_ v: Int) -> (Int) -> Int { { $0 % v } }

let fn1 = add(3)
let fn2 = multiple(5)
let fn3 = sub(1)
let fn4 = mod(10)
let fn5 = divide(2)
print(fn5(fn4(fn3(fn2(fn1(num))))))


//函数合成
func composite(_ f1 : @escaping (Int) -> Int , _ f2 :  @escaping (Int) -> Int) -> (Int) -> Int {
    return  { f2(f1($0)) }
}
let f = composite(add(3),multiple(5))
print(composite(add(3),composite(multiple(5),composite(sub(1), composite(mod(10),divide(2)))))(num))


infix operator >>> : AdditionPrecedence
func >>><A, B, C>(_ f1: @escaping (A) -> B,
                  _ f2: @escaping (B) -> C) -> (A) -> C { { f2(f1($0)) } }
var fn = add(3) >>> multiple(5) >>> sub(1) >>> mod(10) >>> divide(2)
fn(num)



//柯里化(Currying)
//什么是柯里化? p将一个接受多参数的函数变换为一系列只接受单个参数的函数
func add2(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
add2(10, 20)
func add3(_ v: Int) -> (Int) -> Int { { $0 + v } }
add3(10)(20)
//Array、Optional的map方法接收的参数就是一个柯里化函数

func add4(_ v1: Int, _ v2: Int, _ v3:Int) -> Int { v1 + v2 + v3}


func currying<A, B, C>(_ fn: @escaping (A, B) -> C)
   -> (B) -> (A) -> C {
   { b in { a in fn(a, b) } }
}
func currying<A, B, C, D>(_ fn: @escaping (A, B, C) -> D)
   -> (C) -> (B) -> (A) -> D {
   { c in { b in { a in fn(a, b, c) } } }
}
let curriedAdd1 = currying(add2)
print(curriedAdd1(10)(20))
let curriedAdd2 = currying(add4)
print(curriedAdd2(10)(20)(30))




//函子(Functor)
//像Array、Optional这样支持map运算的类型，称为函子(Functor)
// Array<Element>
public func map<T>(_ transform: (Element) -> T) -> Array<T>
 // Optional<Wrapped>
public func map<U>(_ transform: (Wrapped) -> U) -> Optional<U>


//适用函子(Applicative Functor)
//对任意一个函子 F，如果能支持以下运算，该函子就是一个适用函子
//Optional可以成为适用函子
func pure<A>(_ value: A) -> F<A>
func <*><A, B>(fn: F<(A) -> B>, value: F<A>) -> F<B>

func pure<A>(_ value: A) -> A? { value }
infix operator <*> : AdditionPrecedence
func <*><A, B>(fn: ((A) -> B)?, value: A?) -> B? {
    guard let f = fn, let v = value else { return nil }
return f(v) }

var value: Int? = 10
var fn6: ((Int) -> Int)? = { $0 * 2}
// Optional(20)
print(fn6 <*> value as Any)

//Array可以成为适用函子
func pure<A>(_ value: A) -> [A] { [value] }
func <*><A, B>(fn: [(A) -> B], value: [A]) -> [B] {
    var arr: [B] = []
    if fn.count == value.count {
for i in fn.startIndex..<fn.endIndex { arr.append(fn[i](value[i]))
} }
return arr }
 // [10]
print(pure(10))
var arr = [{ $0 * 2}, { $0 + 10 }, { $0 - 5 }] <*> [1, 2, 3]
// [2, 12, -2]
print(arr)
 


//单子(Monad)
//对任意一个类型 F，如果能支持以下运算，那么就可以称为是一个单子(Monad)
func pure<A>(_ value: A) -> F<A>
func flatMap<A, B>(_ value: F<A>, _ fn: (A) -> F<B>) -> F<B>
//很显然，Array、Optional都是单子

