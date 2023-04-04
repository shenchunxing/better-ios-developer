//
//  main.swift
//  从OC到Swift
//
//  Created by 沈春兴 on 2022/7/8.
//

import Foundation

//选择器(Selector)
//Swift中依然可以使用选择器，使用#selector(name)定义一个选择器
//必须是被@objcMembers或@objc修饰的方法才可以定义选择器
@objcMembers class Person: NSObject {
   func test1(v1: Int) { print("test1") }
   func test2(v1: Int, v2: Int) { print("test2(v1:v2:)") }
   func test2(_ v1: Double, _ v2: Double) { print("test2(_:_:)") }
   func run() {
       perform(#selector(test1))
       perform(#selector(test1(v1:)))
       perform(#selector(test2(v1:v2:)))
       perform(#selector(test2(_:_:)))
       perform(#selector(test2 as (Double, Double) -> Void))
} }



//String
//Swift的字符串类型String，跟OC的NSString，在API设计上还是有较大差异
  // 空字符串
var emptyStr1 = ""
var emptyStr2 = String()

var str = "123456"
print(str.hasPrefix("123")) // true
print(str.hasSuffix("456")) // true

var str2: String = "1" // 拼接，jack_rose
str2.append("_2")
// 重载运算符 +
str2 = str + "_3" // 重载运算符 +=
str += "_4"
// \()插值
str2 = "\(str)_5"
// 长度，9，1_2_3_4_5
print(str.count)



//String的插入和删除
var str3 = "1_2"
// 1_2_
str3.insert("_", at: str3.endIndex)
// 1_2_3_4
str3.insert(contentsOf: "3_4", at: str3.endIndex)
// 1666_2_3_4
str3.insert(contentsOf: "666", at: str3.index(after: str3.startIndex))
// 1666_2_3_8884
str3.insert(contentsOf: "888", at: str3.index(before: str3.endIndex))
// 1666hello_2_3_8884
str3.insert(contentsOf: "hello", at: str3.index(str3.startIndex, offsetBy: 4))
 // 666hello_2_3_8884
str3.remove(at: str3.firstIndex(of: "1")!)
// hello_2_3_8884
str3.removeAll { $0 == "6" }
var range = str3.index(str3.endIndex, offsetBy: -4)..<str3.index(before: str3.endIndex) // hello_2_3_4
str.removeSubrange(range)



//String 与 NSString
//String 与 NSString 之间可以随时随地桥接转换
//如果你觉得String的API过于复杂难用，可以考虑将String转为NSString
var str11: String = "jack"
var str22: NSString = "rose"
var str33 = str11 as NSString
var str44 = str22 as String
// ja
var str55 = str33.substring(with: NSRange(location: 0, length: 2))
print(str55)
//比较字符串内容是否等价
//String使用 == 运算符
//NSString使用isEqual方法，也可以使用 == 运算符(本质还是调用了isEqual方法)



//只能被class继承的协议
protocol Runnable1: AnyObject {}
protocol Runnable2: class {}
@objc protocol Runnable3 {}
//被@objc 修饰的协议，还可以暴露给OC去遵守实现


//可选协议
//可以通过@objc 定义可选协议，这种协议只能被class 遵守
@objc protocol Runnable {
    func run1()
    @objc optional func run2()
    func run3()
 }
class Dog: Runnable {
    func run3() { print("Dog run3") }
    func run1() { print("Dog run1") }
}
var d = Dog()
d.run1() // Dog run1
d.run3() // Dog run3



//dynamic
//被 @objc dynamic 修饰的内容会具有动态性，比如调用方法会走runtime那一套流程
 class Dog2: NSObject {
    @objc dynamic func test1() {}
    func test2() {}
}
var d2 = Dog2()
d2.test1()
d2.test2()



//KVC\KVO
//Swift 支持 KVC \ KVO 的条件 p属性所在的类、监听器最终继承自 NSObject p用 @objc dynamic 修饰对应的属性
class Observer: NSObject {
    override func observeValue(forKeyPath keyPath: String?,
                                   of object: Any?,
                                   change: [NSKeyValueChangeKey : Any]?,
                                   context: UnsafeMutableRawPointer?) {
    print("observeValue", change?[.newKey] as Any) }
}

class Person2: NSObject {
    @objc dynamic var age: Int = 0
    var observer: Observer = Observer()
    override init() {
        super.init()
        self.addObserver(observer,
                         forKeyPath: "age",
                         options: .new,
                         context: nil)
    }
    deinit {
        self.removeObserver(observer, forKeyPath: "age")
    }
    
}
var p = Person2()
// observeValue Optional(20)
p.age = 20
// observeValue Optional(25)
p.setValue(25, forKey: "age")




//关联对象(Associated Object)
//在Swift中，class依然可以使用关联对象
//默认情况，extension不可以增加存储属性
//借助关联对象，可以实现类似extension为class增加存储属性的效果
class Person3 {}
extension Person3 {
    private static var AGE_KEY: Void?
    var age: Int {
        get {
            (objc_getAssociatedObject(self, &Self.AGE_KEY) as? Int) ?? 0
        } set {
            objc_setAssociatedObject(self, &Self.AGE_KEY,newValue , .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}
var p3 = Person3()
print(p.age)//0
p.age = 20
print(p.age)//20



