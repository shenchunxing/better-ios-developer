//
//  main.swift
//  下标
//
//  Created by 沈春兴 on 2022/7/6.
//

import Foundation

class Point2 {
    var x = 10, y = 10
}

class PointManager {
    var point = Point2()
    subscript(index: Int) -> Point2 {
        get { point }
    }
}

var pm = PointManager()
pm[0].x = 11
pm[0].y = 22



class Point {
    var x = 0.0, y = 0.0
    subscript(index: Int) -> Double {
        set {
            if index == 0 {
                x = newValue
            } else if index == 1 {
                y = newValue
            }
        }
        get {
            if index == 0 {
                return x
            } else if index == 1 {
                return y
            }
            return 0
        }
    }
}

var p = Point()
p[0] = 11.1
p[1] = 22.2
print(p.x) // 11.1
print(p.y) // 22.2
print(p[0]) // 11.1
print(p[1]) // 22.2


//接受多个参数的下标
class Grid {
    var data = [
        [0,1,2]
        ,
        [3,4,5],
        [6,7,8]
    ]
    
    subscript(row : Int , col : Int) -> Int {
        set {
            guard row >= 0 && row < 3 && col >= 0 && col < 3 else {
                return
            }
            data[row][col] = newValue
        }
        get {
            guard row >= 0 && row < 3 && col >= 0 && col < 3 else {
                return 0
            }
            return data[row][col]
        }
    }
}

var grid = Grid()
grid[0,1] = 44
grid[1,2] = 88
