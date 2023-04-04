//
//  main.swift
//  初始化
//
//  Created by 沈春兴 on 2022/7/7.
//

import Foundation

class Size {
    var width : Int = 0
    var height : Int = 0

    //便捷初始化器必须调用指定初始化器
    //一个指定初始化器，多个便捷初始化器
    init(width : Int , height : Int) {
        self.width = width
        self.height = height
    }
    
    convenience init() {
        self.init(width: 0, height: 0)
    }
    
    convenience init(width : Int) {
        self.init(width: width, height: 0)
    }
    
    convenience init(height : Int) {
        self.init(width: 0, height: height)
    }
}

class Person {
    var age: Int
    init(age: Int) {
        self.age = age
    }
    
    convenience init() {
        self.init(age: 0)
    }
}

class Student : Person {
    var score: Int
    //指定初始化器必须调用父类的指定初始化器,为了让子和父的存储属性都初始化
    init(age: Int, score: Int) {
        self.score = score
        super.init(age: age)
    }

    convenience init() {
        self.init(score: 0)
    }
    
    convenience init(score: Int) {
        self.init(age: 0, score: score)
    }
}

class Person1 {
    //required 子类必须实现
    required init() {
        print("Person1 - init")
    }
    
    init(age: Int) {
        
    }
    
    deinit {
        print("Person1 deinit")
    }
}

class Student1 : Person1 {
    var name : String
    required init() {
        self.name = ""
        super.init()
        print("Student1 - init")
    }
    
    convenience init?(name : String) {
        self.init()
        if name.isEmpty {
            return nil
        }
        self.name = name
    }
    
    deinit {
        print("Student1 deinit")
    }
}

func test() {
    var stu1 = Student1()
}

print("1")
test()
print("2")


//deinit可以被继承,
class Person2  {
    deinit {
        print("Person2 deinit") //Person2 deinit被打印
    }
}
class Student2 : Person2 {}

func test2() {
    let p2 = Person2()
}
test2()

//多种等价初始化,都会调用init()
let p3 = Person2()
let p4 = Person2.self()
let p5 = Person2.init()
let p6 = Person2.self.init()
