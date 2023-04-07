//
//  main.swift
//  面向协议编程
//
//  Created by 沈春兴 on 2022/7/13.
//

import Foundation

//利用协议实现前缀效果
var string = "123fdsf434"
print(string.mj.numberCount())

//直接以字符串的方式，可能导致命名冲突，一般都需要加一个前缀名，类似c++命名空间的效果
struct MJ<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

//给MJCompatible同时设置类型属性和存储属性mj，可以适配
protocol MJCompatible {}
extension MJCompatible {
    static var mj: MJ<Self>.Type {
        get { MJ<Self>.self }
        set {}
    }
    var mj: MJ<Self> {
        get { MJ(self) }
        set {}//为了mutating编译通过
    }
}
//String独有的方法numberCount，同时有mj前缀
extension String: MJCompatible {}
extension MJ where Base == String {
    func numberCount() -> Int {
        var count = 0
        for c in base where ("0"..."9").contains(c) {
            count += 1
        }
        return count
    }
}

//Person独有的方法run和test，同时有mj前缀
class Person {}
class Student: Person {}
extension Person: MJCompatible {}
extension MJ where Base: Person {
    func run() {}
    static func test() {}
}

Person.mj.test()
Student.mj.test()
let p = Person()
p.mj.run()
let s = Student()
s.mj.run()



//适配NSString、NSMutableString，让他们都可以使用numberCount，
//ExpressibleByStringLiteral：字面量协议
//NSMutableString继承自NSString，同时NSString和String都实现了ExpressibleByStringLiteral协议
//NSString强转String
var s1: String = "123fdsf434"
var s2: NSString = "123fdsf434"
var s3: NSMutableString = "123fdsf434"
print(s1.mj.numberCount())
print(s2.mj.numberCount())
print(s3.mj.numberCount())

extension NSString: MJCompatible {}
extension MJ where Base: ExpressibleByStringLiteral {
    func numberCount() -> Int {
        let string = base as! String
        var count = 0
        for c in string where ("0"..."9").contains(c) {
            count += 1
        }
        return count
    }
}
 



//利用协议实现类型判断
//传入一个实例
func isArray(_ value: Any) -> Bool { value is [Any] }
isArray( [1, 2] )
isArray( ["1", 2] )
isArray( NSArray() )
isArray( NSMutableArray() )


//不优雅的写法，应该用协议
func isArray(_ type: Any.Type) -> Bool {
    if type is [Any].Type
        || type is [Int].Type
         || type is [String].Type
        || type is NSArray.Type {
        return true
    }
    return false
}

protocol ArrayType {} 
extension Array: ArrayType {}
extension NSArray: ArrayType {}
//传入一个类型
func isArrayType(_ type: Any.Type) -> Bool { type is ArrayType.Type }
isArrayType([Int].self)
isArrayType([Any].self)
isArrayType(NSArray.self)
isArrayType(NSMutableArray.self)
