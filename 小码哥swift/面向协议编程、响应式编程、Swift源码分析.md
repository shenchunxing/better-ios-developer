

三、面向协议编程（Protocol Oriented Programming）
=======================================

1\. 基本概念
--------

面向协议编程（Protocol Oriented Programming，简称POP）

*   是Swift的一种编程范式，`Apple`于2015年`WWDC`提出
*   在Swift标准库中，能见到大量`POP`的影子 同时，Swift也是一门面向对象的编程语言（Object Oriented Programming，简称OOP）

在Swift开发中，`OOP`和`POP`是相辅相成的，任何一方并不能取代另一方

`POP`能弥补`OOP`一些设计上的不足

2.OOP和POP
---------

**回顾OOP**

*   `OOP`的三大特性：`封装`、**继承**、`多态`
*   继承的经典使用场合:  
    当多个类（比如A、B、C类）具有很大共性时，可以将这些共性抽取到一个父类中（比如D类），最后A、B、C类继承D类

![-w514](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/346429b4d3da44dd9518b93f365e4cb4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

*   **OOP的不足**
*   但有些问题，使用`OOP`并不能很好解决，比如如何将BVC、DVC的`公共方法run`抽出来

    class BVC: UIViewController {
        func run() {
            print("run")
        }
    }
    
    class DVC: UITableViewController {
        func run() {
            print("run")
        }
    } 
    复制代码

*   **基于`OOP`想到的一些解决方案：**

1.将`run方法`放到另一个对象A中，然后BVC、DVC拥有对象A属性

*   多了一些额外的依赖关系

2.将`run方法`增加到`UIViewController分类`中

*   `UIViewController`会越来越臃肿，而且会影响它的其他所有子类

3.将`run方法`抽取到新的父类，采用多继承（`C++`支持多继承）

*   会增加程序设计的复杂度，产生菱形继承等问题，需要开发者额外解决

**POP的解决方案**

    protocol Runnable {
        func run()
    }
    
    extension Runnable {
        func run() {
            print("run")
        }
    }
    
    class BVC: UIViewController, Runnable {}
    class DVC: UITableViewController, Runnable {} 
    复制代码

![-w447](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/73c69593f53f4225ab370615f9449cee~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**POP的注意点**

*   优先考虑创建协议，而不是父类（基类）
*   优先考虑值类型（struct、enum），而不是引用类型（class）
*   巧用协议的扩展功能
*   不要为了面向协议而使用协议

3.POP的应用
--------

下面我们利用协议来实现前缀效果

    var string = "123fdsf434"
    
    protocol NameSpaceWrapperProtocol {
        associatedtype WrappedType
        var wrappedValue: WrappedType { get set }
        
        init(value: WrappedType)
    }
    
    struct NameSpaceWrapper<T>: NameSpaceWrapperProtocol {
        
        var wrappedValue: T
        
        init(value: T) {
            self.wrappedValue = value
        }
    }
    
    protocol NamespaceWrappable { }
    
    extension NamespaceWrappable {
        var ll: NameSpaceWrapper<Self> {
            get { NameSpaceWrapper(value: self) }
            
            set {}
        }
        
        static var ll: NameSpaceWrapper<Self>.Type {
            get { NameSpaceWrapper.self }
            
            set {}
        }
    }
    
    extension NameSpaceWrapperProtocol where WrappedType: ExpressibleByStringLiteral {
        var numberCount: Int {
            (wrappedValue as? String)?.filter { ("0"..."9").contains($0) }.count ?? 0
        }
    }
    
    extension String: NamespaceWrappable {}
    extension NSString: NamespaceWrappable {}
    
    print(string.ll.numberCount)
    print((string as NSString).ll.numberCount) // 6
    复制代码

利用协议实现类型判断

    func isArray(_ value: Any) -> Bool { value is [Any] }
    
    print(isArray([1, 2])) // true
    print(isArray(["1", 2])) // true
    print(isArray(NSArray())) // true
    print(isArray(NSMutableArray())) // true
    
    
    protocol ArrayType {}
    func isArrayType(_ type: Any.Type) -> Bool { type is ArrayType.Type }
    
    extension Array: ArrayType {}
    extension NSArray: ArrayType {}
    
    print(isArrayType([Int].self)) // true
    print(isArrayType([Any].self)) // true
    print(isArrayType(NSArray.self)) // true
    print(isArrayType(NSMutableArray.self)) // true
    print(isArrayType(String.self)) // false
    复制代码

四、响应式编程（Reactive Programming）
=============================

1\. 基本概念
--------

响应式编程（Reactive Programming，简称RP），是一种编程范式，于1997年提出，可以简化异步编程，提供更优雅的数据绑定

一般与函数式融合在一起，所以也会叫做：函数响应式编程（Functional Reactive Programming，简称FRP）

比较著名的、成熟的响应式框架

*   **ReactiveCocoa**：简称RAC，有Objective-C、Swift版本
*   **ReactiveX**：简称Rx，有众多编程语言版本，比如RxJava、RxKotlin、RxJS、RxCpp、RxPHP、RxGo、RxSwift等

2\. RxSwift
-----------

`RxSwift`（ReactiveX for Swift），`ReactiveX`的`Swift`版本

源码： [github.com/ReactiveX/R…](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FReactiveX%2FRxSwift "https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FReactiveX%2FRxSwift") [beeth0ven.github.io/RxSwift-Chi…](https://link.juejin.cn?target=https%3A%2F%2Fbeeth0ven.github.io%2FRxSwift-Chinese-Documentation%2F "https://link.juejin.cn?target=https%3A%2F%2Fbeeth0ven.github.io%2FRxSwift-Chinese-Documentation%2F")

五、Swift源码分析
===========

我们通过分析`Swift标准库源码`来更近一步了解Swift的语法

1.Array相关
---------

**map、filter**的源码路径:`/swift-main/stdlib/public/core/Sequence.swift`

**flatMap、compactMap、reduce**的源码路径:`/swift-main/stdlib/public/core/SequenceAlgorithms.swift`

### 1.1 map

    @inlinable
    public func map<T>(
    _ transform: (Element) throws -> T
    ) rethrows -> [T] {
    
      let initialCapacity = underestimatedCount
      var result = ContiguousArray<T>()
      result.reserveCapacity(initialCapacity)
    
      var iterator = self.makeIterator()
    
      // Add elements up to the initial capacity without checking for regrowth.
      for _ in 0..<initialCapacity {
        result.append(try transform(iterator.next()!))
      }
      
      // Add remaining elements, if any.
      while let element = iterator.next() {
        // 如果element是数组，会把整个数组作为元素加到新数组中
        result.append(try transform(element))
      }
      
      return Array(result)
    } 
    复制代码

### 1.2 flatMap

    @inlinable
    public func flatMap<SegmentOfResult: Sequence>(
    _ transform: (Element) throws -> SegmentOfResult
    ) rethrows -> [SegmentOfResult.Element] {
    
      var result: [SegmentOfResult.Element] = []
      for element in self {
        // 将数组元素添加到新数组中
        result.append(contentsOf: try transform(element))
      } 
      
      return result
    } 
    复制代码

### 1.3 filter

    @inlinable
    public __consuming func filter(
    _ isIncluded: (Element) throws -> Bool
    ) rethrows -> [Element] {
      return try _filter(isIncluded)
    }
    
    @_transparent
    public func _filter(
    _ isIncluded: (Element) throws -> Bool
    ) rethrows -> [Element] {
    
      var result = ContiguousArray<Element>()
    
      var iterator = self.makeIterator()
    
      while let element = iterator.next() {
        if try isIncluded(element) {
          result.append(element)
        }
      }
    
      return Array(result)
    } 
    复制代码

### 1.4 compactMap

    @inlinable // protocol-only
    public func compactMap<ElementOfResult>(
    _ transform: (Element) throws -> ElementOfResult?
    ) rethrows -> [ElementOfResult] {
      return try _compactMap(transform)
    }
    
    @inlinable // protocol-only
    @inline(__always)
    public func _compactMap<ElementOfResult>(
    _ transform: (Element) throws -> ElementOfResult?
    ) rethrows -> [ElementOfResult] {
    
      var result: [ElementOfResult] = []
      
      for element in self {
        // 会进行解包，只有不为空才会被加到数组中
        if let newElement = try transform(element) {
          result.append(newElement)
        }
      }
      
      return result
    } 
    复制代码

### 1.5 reduce

    @inlinable
    public func reduce<Result>(
    _ initialResult: Result,
    _ nextPartialResult:
    (_ partialResult: Result, Element) throws -> Result
    ) rethrows -> Result {
    
      // 上一次的结果
      var accumulator = initialResult
        
      for element in self {
        accumulator = try nextPartialResult(accumulator, element)
      }
      
      return accumulator
    } 
    复制代码

2\. Substring相关
---------------

**Substring**的源码路径:`/swift-main/stdlib/public/core/Substring.swift`

### 2.1初始化

    @frozen
    public struct Substring: ConcurrentValue {
      @usableFromInline
      internal var _slice: Slice<String>
    
      @inlinable
      internal init(_ slice: Slice<String>) {
        let _guts = slice.base._guts
        let start = _guts.scalarAlign(slice.startIndex)
        let end = _guts.scalarAlign(slice.endIndex)
        
        // 保存传进来的字符串的内容和位置
        self._slice = Slice(
          base: slice.base,
          bounds: Range(_uncheckedBounds: (start, end))) 
        _invariantCheck()
      }
    
      @inline(__always)
      internal init(_ slice: _StringGutsSlice) {
        self.init(String(slice._guts)[slice.range])
      }
    
      /// Creates an empty substring.
      @inlinable @inline(__always)
      public init() {
        self.init(Slice())
      }
    }
    
    extension Substring {
      /// Returns the underlying string from which this Substring was derived.
      @_alwaysEmitIntoClient
      
      // _slice.base就是初始化传进来的字符串
      public var base: String { return _slice.base }
    
      @inlinable @inline(__always)
      internal var _wholeGuts: _StringGuts { return base._guts }
    
      @inlinable @inline(__always)
    
      // 从这里也能看出和传进来的String共有的是同一块区域，在这块区域进行偏移获取Substring的内容
      internal var _offsetRange: Range<Int> {
        return Range(
          _uncheckedBounds: (startIndex._encodedOffset, endIndex._encodedOffset))
      }
    
      #if !INTERNAL_CHECKS_ENABLED
      @inlinable @inline(__always) internal func _invariantCheck() {}
      #else
      @usableFromInline @inline(never) @_effects(releasenone)
      internal func _invariantCheck() {
        // Indices are always scalar aligned
        _internalInvariant(
          _slice.startIndex == base._guts.scalarAlign(_slice.startIndex) &&
          _slice.endIndex == base._guts.scalarAlign(_slice.endIndex))
    
        self.base._invariantCheck()
      }
      #endif // INTERNAL_CHECKS_ENABLED
    } 
    复制代码

### 2.2 append

    extension Substring: RangeReplaceableCollection {
      @_specialize(where S == String)
      @_specialize(where S == Substring)
      @_specialize(where S == Array<Character>)
      public init<S: Sequence>(_ elements: S)
      where S.Element == Character {
        if let str = elements as? String {
          self.init(str)
          return
        }
        if let subStr = elements as? Substring {
          self = subStr
          return
        }
        self.init(String(elements))
      }
    
      // Substring的拼接
      @inlinable // specialize
      public mutating func append<S: Sequence>(contentsOf elements: S)
      where S.Element == Character {
    
        // 拼接时会创建一个新的字符串
        var string = String(self)
        self = Substring() // Keep unique storage if possible
        string.append(contentsOf: elements)
        self = Substring(string)
      }
    } 
    复制代码

### 2.3 lowercased、uppercased

    extension Substring {
      public func lowercased() -> String {
        return String(self).lowercased()
      }
    
      public func uppercased() -> String {
        return String(self).uppercased()
      }
    
      public func filter(
        _ isIncluded: (Element) throws -> Bool
      ) rethrows -> String {
        return try String(self.lazy.filter(isIncluded))
      }
    } 
    复制代码

3\. Optional相关
--------------

**Optional**的源码路径:`/swift-main/stdlib/public/core/Optional.swift`

### 3.1 map

    @inlinable
    public func map<U>(
    _ transform: (Wrapped) throws -> U
    ) rethrows -> U? {
      switch self {
      case .some(let y): // 先解包进行处理
        return .some(try transform(y)) // 然后再包装一层可选类型返回出去
      case .none:
        return .none
      }
    } 
    复制代码

### 3.2flatMap

    @inlinable
    public func flatMap<U>(
    _ transform: (Wrapped) throws -> U?
    ) rethrows -> U? {
      switch self {
      case .some(let y): // 先进行解包
        return try transform(y) // 将解包后的处理完直接给出去
      case .none:
        return .none
      }
    } 
    复制代码

### 3.3 ==

*   `==`两边都为`可选项`

    @inlinable
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
    复制代码

*   `==`左边为`可选项`，右边为`nil`

    @_transparent
    public static func ==(lhs: Wrapped?, rhs: _OptionalNilComparisonType) -> Bool {
      switch lhs {
        case .some:
          return false
        case .none:
          return true
      }
    } 
    复制代码

*   `==`左边为`nil`，右边为`可选项`

    @_transparent
    public static func ==(lhs: _OptionalNilComparisonType, rhs: Wrapped?) -> Bool {
      switch rhs {
        case .some:
          return false
        case .none:
          return true
      }
    } 
    复制代码

*   `_OptionalNilComparisonType`是一个遵守`ExpressibleByNilLiteral`协议的结构体，可以用`nil`来进行初始化

    // 遵守ExpressibleByNilLiteral协议的结构体，可以用nil来进行初始化
    @frozen
    public struct _OptionalNilComparisonType: ExpressibleByNilLiteral {
      /// Create an instance initialized with `nil`.
      @_transparent
      public init(nilLiteral: ()) {
      }
    } 
    复制代码

### 3.4 ??

    @_transparent
    public func ?? <T>(optional: T?, defaultValue: @autoclosure () throws -> T)
        rethrows -> T {
      switch optional {
      case .some(let value):
        return value
      case .none:
        return try defaultValue()
      }
    } 
    复制代码

    @_transparent
    public func ?? <T>(optional: T?, defaultValue: @autoclosure () throws -> T?)
        rethrows -> T? {
      switch optional {
      case .some(let value):
        return value
      case .none:
        return try defaultValue()
      }
    } 
    复制代码

4\. Metadata相关
--------------

源码路径:

*   `/swift-main/include/swift/ABI/Metadata.h`
*   `/swift-main/include/swift/ABI/MetadataKind.def`
*   `/swift-main/include/swift/ABI/MetadataValues.h`
*   `/swift-main/include/swift/Reflection/Records.h`

文档路径:

*   `/swift-main/docs/ABI/TypeMetadata.rst`

**Swift中很多类型都有自己的`metadata`**

![-w1020](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eaca2dbfa6fc44628c3eee1c30d427a3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**Class Metadata**

我们可以从第三方库`KaKaJSON`中的`ClassType`，以及对应`Metadata`的相关文档来分析`Class Metadata`信息

    struct ClassLayout: ModelLayout {
        let kind: UnsafeRawPointer
        
        /// 指向父类类型的指针
        let superclass: Any.Type
        
        /// The cache data is used for certain dynamic lookups; it is owned by the runtime and generally needs to interoperate with Objective-C's use
        /// 缓存数据用于某些动态查找；它属于运行时，通常需要与Objective-C的使用进行互操作
        let runtimeReserved0: UInt
        let runtimeReserved1: UInt
        
        /// The data pointer is used for out-of-line metadata and is generally opaque, except that the compiler sets the low bit in order to indicate that this is a Swift metatype and therefore that the type metadata header is present
        let rodata: UInt
        
        /// Swift-specific class flags
        /// 类标志
        let flags: UInt32
        
        /// The address point of instances of this type
        /// 实例的地址值
        let instanceAddressPoint: UInt32
    
        /// The required size of instances of this type. 'InstanceAddressPoint' bytes go before the address point; 'InstanceSize - InstanceAddressPoint' bytes go after it
        /// 实例大小
        let instanceSize: UInt32
    
        /// The alignment mask of the address point of instances of this type
        /// 实例对齐掩码
        let instanceAlignMask: UInt16
    
        /// Reserved for runtime use
        /// 运行时保留字段
        let reserved: UInt16
    
        /// The total size of the class object, including prefix and suffix extents
        /// 类对象的大小
        let classSize: UInt32
    
        /// The offset of the address point within the class object
        /// 类对象地址
        let classAddressPoint: UInt32
    
        // Description is by far the most likely field for a client to try to access directly, so we force access to go through accessors
        /// An out-of-line Swift-specific description of the type, or null if this is an artificial subclass.  We currently provide no supported mechanism for making a non-artificial subclass dynamically
        var description: UnsafeMutablePointer<ClassDescriptor>
        
        /// A function for destroying instance variables, used to clean up after an early return from a constructor. If null, no clean up will be performed and all ivars must be trivial
        let iVarDestroyer: UnsafeRawPointer
        
        var genericTypeOffset: Int {
            let descriptor = description.pointee
            // don't have resilient superclass
            if (0x4000 & flags) == 0 {
                return (flags & 0x800) == 0
                ? Int(descriptor.metadataPositiveSizeInWords - descriptor.numImmediateMembers)
                : -Int(descriptor.metadataNegativeSizeInWords)
            }
            return GenenicTypeOffset.wrong
        }
    }
    复制代码
