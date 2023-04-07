import Foundation
var age = 10

//MemoryLayout<Int>.size
//MemoryLayout<Int>.stride
//MemoryLayout<Int>.alignment

//MemoryLayout.size(ofValue: age)
//MemoryLayout.stride(ofValue: age)
//MemoryLayout.alignment(ofValue: age)

enum Password {
    case number(Int, Int, Int, Int) // 关联值：每个枚举变量都需要单独的内存，32个字节（必须有4个int类型的）
    case other //1个字节就够了
}
var pwd = Password.number(5, 6, 4, 7) // 33
pwd = .other // 0
var pwd2 = Password.number(10, 9, 100, 19999)
var pwd3 = Password.number(111, 222, 100, 19999)
MemoryLayout<Password>.stride // 40 分配的内存大小，因为内存对齐是8
MemoryLayout<Password>.size // 33 //实际内存大小
MemoryLayout<Password>.alignment // 8 内存对齐


enum Season : Int {
    case spring = 1, summer, autumn, winter //原始值：枚举已经固定了的，底层1个字节就够了,不会存到枚举变量中
}
var s = Season.spring
var s1 = Season.spring
var s2 = Season.spring
s2.rawValue //1
MemoryLayout<Season>.size // 1
MemoryLayout<Season>.stride // 1
MemoryLayout<Season>.alignment // 1


enum Score {
    case points(Int)
    case grade(Character)
}

var score : Score = .points(96)
score = .grade("A")

switch score {
case let .points(i):
    print(i,"points")
case let .grade(i):
    print("grade",i)
}

enum Date {
    case digit(year:Int , month: Int , day : Int)
    case string(String)
}

var date : Date = Date.digit(year: 2011, month: 12, day: 3)
date = .string("2021.2.3")
switch date {
case .digit(let year , let month , let day) :
    print("year = \(year) , month = \(month) , day = \(day)")
case let .string(value) :
    print(value)
}

enum Direction : String {
 case north , south , east , west
}
print(Direction.north)
