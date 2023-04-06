//
//  main.swift
//  属性
//
//  Created by 沈春兴 on 2022/7/6.
//

import Foundation

struct Circle {
    var radius : Double //存储属性：类似于成员变量，存储在实例的内存中，结构体和类可以定义存储属性，枚举不可以定义存储属性
    var diameter : Double { //计算属性：本质就是方法，不占用实例的内存，结构体、类、枚举都可以定义
       //定义计算属性，只能是var，因为会变化
        set {
            radius = newValue / 2
        }
        get {
            return radius * 2
        }
    }
}
print(MemoryLayout<Circle>.stride) //8
var circle = Circle(radius: 5)
print(circle.radius) //5.0
print(circle.diameter)//10.0
circle.diameter = 12
print(circle.radius) //6.0
print(circle.diameter)//12.0


//枚举原始值rawvalue的原理
enum TestEnum : Int {
    case test1 = 1,test2 = 2, test3 = 3
    var rawValue: Int {
        switch self {
        case .test1 :
            return 10
        case .test2 :
            return 11
        case .test3 :
            return 12
        }
    }
}
print(TestEnum.test3.rawValue) //12


//延迟存储属性
class Car {
    init() {
        print("car init")
    }
    func run() {
        print("car is running")
    }
}
class Person {
    lazy var car : Car = Car() //lazy必须是var ，lazy不是多线程安全的，可能被初始化多次
    init() {
        print("person init")
    }
    func goOut() {
        car.run()
    }
}

//class PhotoView {
//    lazy var image : Image = {
//       let url = "xxxx"
//        let data = Data(url:url)
//        return Image(data:data)
//    }()
//}


struct Point {
    var x = 0
    var y = 0
    lazy var z = 0
}
//let p  = Point()
//print(p.z) //Cannot use mutating getter on immutable value: 'p' is a 'let' constant
var p1 = Point() //p1必须是var类型
print(p1.z)


//属性观察器
struct Circle2 {
    var raidus : Double {
        willSet { //willSet会传递新值，默认是newValue
            print("willset", newValue)
        }
        didSet { //didSet会传递旧值，默认oldValue
            print("didset",oldValue,raidus)
        }
    }
    
    init() {
        self.raidus = 1.0
        print("circle init!")
    }
}
var circle2 = Circle2()
circle2.raidus = 10
print(circle2.raidus)

//全局变量和局部变量都可以使用属性观察期
var num2 : Int {
    get {
        return 10
    }
    set {
        print("setnum2 = ", newValue)
    }
}
func test() {
    var age : Int {
        get {
            return 10
        }
        set {
            print("age =  ", age)
        }
    }
}


//inout的再次研究
struct Shape {
    var width : Int
    var side : Int {
        willSet {
            print("willsetside",newValue)
        }
        didSet {
            print("didsetside",oldValue,side)
        }
    }
    var girth : Int {
        set {
            width = newValue / side
            print("setGirth",newValue)
        }
        get {
            print("getGirth")
            return width * side
        }
    }
    func show() {
        print("width = \(width) , side = \(side) , girth = \(girth)")
    }
}

func test2(_ num : inout Int) {
    num = 20
}
var s = Shape(width: 10, side: 4)
print("-------")
test2(&s.width)
s.show()
print("-------")
test2(&s.side)
s.show()
print("-------")
test2(&s.girth)
s.show()



//类型属性:整个程序运行过程中，只有1份内存，类似全局变量
struct Car2 {
    static var count : Int = 0 //默认就是lazy的。会在第一次使用的时候初始化，多线程安全，只会初始化一次，可以是let修饰
    init() {
        Car2.count += 1
    }
}
let c1 = Car2()
let c2 = Car2()
let c3 = Car2()
print(Car2.count)


//单例模式
class FileManager {
    static public let shared : FileManager = FileManager()
    //等效写法
    static public let shared2 = {
        //这里可以写一写初始化需要做的前置事情
       return FileManager()
    }()
    private init() {}
}
