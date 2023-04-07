//
//  main.swift
//  结构体和类
//
//  Created by 沈春兴 on 2022/7/6.
//

import Foundation

struct Point {
    var x : Int = 0 //8
    var y : Int = 0 //8
    var origin : Bool = false //1
}
print(MemoryLayout<Point>.size)//使用内存的大小 17
print(MemoryLayout<Point>.stride)//申请内存的大小 24
print(MemoryLayout<Point>.alignment) //内存对齐 8


//类：malloc分配的内存大小是16的倍数，实际Point2对象申请的是48字节。
class Point2 {
    var x = 11
    var y = 22
    var test = false
}
//类的内存布局 ： 类型信息占用8字节、引用计数占用8字节、成员变量x占用8字节，成员变量y占用8字节，成员变量test占用1字节，一共33字节
var p = Point2()
print(class_getInstanceSize(type(of: p))) //获取类对象至少需要多少内存 40（内存对其为8字节）
print(class_getInstanceSize(Point2.self)) //等价写法 40（内存对其为8字节）  [Point class]  [p class]
print(Mems.size(ofRef: p))//实际申请内存大小 48


func testClassAndStruct() {
    class Size {
        var width = 1
        var height = 2
    }
    
    struct Point {
        var x = 3
        var y = 4
    }
    
     var ptr = malloc(17)
     print(malloc_size(ptr)) //32,16的倍数
    
    print("MemoryLayout<Size>.stride", MemoryLayout<Size>.stride) //8，这是指的是size指针变量的大小，8个字节。并不是对象内存的大小32字节
    print("MemoryLayout<Point>.stride", MemoryLayout<Point>.stride)//16
    
    print("------------------------")
    
    var size = Size()
    
    print(Mems.size(ofRef: size)) //获取对象内存大小：32
    
    print("size变量的地址", Mems.ptr(ofVal: &size))//0x00000003040db138 栈上
    print("size变量的存储内容", Mems.memStr(ofVal: &size))//0x0000000108f068b0,存储的是指向的对象的地址，在堆上
    
    print("size所指向内存的地址", Mems.ptr(ofRef: size))//0x0000000108f068b0 ，堆上
    print("size所指向内存的存储内容", Mems.memStr(ofRef: size))//32个字节，0x000000010000c480（类型信息） 0x0000000200000003（引用计数） 0x0000000000000001（width） 0x0000000000000002（height）
    
    print("------------------------")
    
    var point = Point()
    print("point变量的地址", Mems.ptr(ofVal: &point)) //0x00000003040db110 栈上
    print("point变量的存储内容", Mems.memStr(ofVal: &point))//16个字节。0x0000000000000003。前8个字节放3 ，0x0000000000000004。后8个字节放4
}
testClassAndStruct()


func testClassAndStruct2() {
    struct Point {
        var x : Int //8
        var b1 : Bool//1
        var b2 : Bool//1
        var y : Int//8
    }
    
    class Size {
        var width : Int //8
        var b1 : Bool //1
        var b2 : Bool//1
        var height : Int //8
        init(width : Int , b1 : Bool , b2 : Bool , height :Int) {
            self.width = width
            self.height = height
            self.b1 = b1
            self.b2 = b2
        }
    }
    
    print("testClassAndStruct2------------------------")
    
    var p = Point(x: 10, b1: true, b2: true, y: 20)
    print("p变量的地址", Mems.ptr(ofVal: &p))//0x00000003040e3130 栈
    print("p变量的存储内容", Mems.memStr(ofVal: &p))//0x000000000000000a 0x0000000000000101（b1、b2） 0x0000000000000014
    
    var s = Size(width: 10, b1: true, b2: true, height: 20)
    print(Mems.size(ofRef: s)) //48字节
    print("s变量的地址", Mems.ptr(ofVal: &s))//0x00000003040e3110 栈
    print("s变量的存储内容", Mems.memStr(ofVal: &s)) //0x0000000108f26420 堆
    print("s所指向内存的地址", Mems.ptr(ofRef: s))//0x0000000108f26420 堆
    print("s所指向内存的存储内容", Mems.memStr(ofRef: s))//一共48字节 ：0x0000000100010668（类型信息） 0x0000000200000003（引用计数） 0x000000000000000a（width） 0x00007ff854270101(b1、b2) 0x0000000000000014（height） 0x0000000000000000
}
testClassAndStruct2()
