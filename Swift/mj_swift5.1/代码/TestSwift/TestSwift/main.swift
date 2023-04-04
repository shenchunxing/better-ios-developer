//
//  main.swift
//  TestSwift
//
//  Created by MJ Lee on 2019/6/16.
//  Copyright © 2019 MJ Lee. All rights reserved.
//

//var age1: Int? = nil
//var age2: Int?? = nil
//// false
//print(age1 == age2)

class FileManager {
    public static let shareInstance : FileManager = FileManager()
    private init() {}
    func open() { }
    func close() { }
}
FileManager.shareInstance.open()

extension Optional where Wrapped: Equatable {
    public static func ==(lhs: _OptionalNilComparisonType, rhs: Wrapped?) -> Bool {
      switch rhs {
      case .some:
        return false
      case .none:
        return true
      }
    }
    
    public static func ==(lhs: Wrapped?, rhs: _OptionalNilComparisonType) -> Bool {
      switch lhs {
      case .some:
        return false
      case .none:
        return true
      }
    }
    
    // Wrapped = Int???
    public static func ==(lhs: Wrapped?, rhs: Wrapped?) -> Bool {
      switch (lhs, rhs) {
      case let (l?, r?):
        return l == r
      case (nil, nil):
        return true
      default:
        return false
      }
    }
}

var age1: Int???? = 20
var age2: Int = 20
print(age1 == age2)

// T == Int???
public func ?? <T>(optional: T?, defaultValue: @autoclosure () throws -> T)
    rethrows -> T {
  switch optional {
  case .some(let value):
    return value
  case .none:
    return try defaultValue()
  }
}
// T ==  Int
public func ?? <T>(optional: T?, defaultValue: @autoclosure () throws -> T?)
    rethrows -> T? {
  switch optional {
  case .some(let value):
    return value
  case .none:
    return try defaultValue()
  }
}
