//
//  main.swift
//  继承
//
//  Created by 沈春兴 on 2022/7/6.
//

import Foundation

/*
 多态的实现原理：
 1.OC：Runtime
 2.C++：虚表（虚函数表）
 
 Swift中多态的实现原理：类似虚表的设计，对象的前8个字节是类型信息，后面是方法的地址。根据偏移量找到方法，然后调用
 */

class Animal {
    func speak() {
        print("Animal speak")
    }
    func eat() {
        print("Animal eat")
    }
    func sleep() {
        print("Animal sleep")
    }
}

class Dog : Animal {
    override func speak() {
        super.speak()
        print("Dog speak")
    }
    override func eat() {
        super.speak()
        super.eat()
        print("Dog eat")
    }
    func run() {
        print("Dog run")
    }
}

///*
// 堆空间
// 全局区
// 代码区
// */
//
var dog1 = Dog()
dog1.eat()

// MachOView  TEXT  DATA  窥探mach-o文件
// 代码区        0x100001db0
// 代码区        0x100002270
// dog1全局变量   0x10000F048
// rcx metadata  0x10000e9c0
// 堆空间Dog对象  0x10280cfa0



//子类重写了父类的存储属性、计算属性
class Circle {
    var radius: Int = 0
    var diameter: Int {
        set {
            print("Circle setDiameter")
            radius = newValue / 2
        }
        get {
            print("Circle getDiameter")
            return radius * 2
        }
    }
}

class SubCircle : Circle {
    override var radius: Int {
        set {
            print("SubCircle setRadius")
            super.radius = newValue > 0 ? newValue : 0
        }
        get {
            print("SubCircle getRadius")
            return super.radius
        }
    }
    override var diameter: Int {
        set {
            print("SubCircle setDiameter")
            super.diameter = newValue > 0 ? newValue : 0
        }
        get {
            print("SubCircle getDiameter")
            return super.diameter
        }
    }
}

var circle = SubCircle()
// SubCircle setRadius
circle.radius = 6

// SubCircle getDiameter
// Circle getDiameter
// SubCircle getRadius
// 12
print(circle.diameter)

// SubCircle setDiameter
// Circle setDiameter
// SubCircle setRadius
circle.diameter = 20

// SubCircle getRadius
// 10
print(circle.radius)

print("--------------")

func test() {
    class Circle {
        class var radius: Int {
            set {
                print("Circle setRadius", newValue)
            }
            get {
                print("Circle getRadius")
                return 20
            }
        }
    }
    
    class SubCircle : Circle {
        override class var radius: Int {
            willSet {
                print("SubCircle willSetRadius", newValue)
            }
            didSet {
                print("SubCircle didSetRadius", oldValue,radius)
            }
        }
    }
    
//    Circle getRadius
//    SubCircle willSetRadius 10
//    Circle setRadius 10
//    Circle getRadius
//    SubCircle didSetRadius 20 20
    SubCircle.radius = 10
}
test()
