# Swift提高代码质量的一些Tips
==================

在讨论如何使用`Swift`提高代码质量之前，我们先来看看`Swift`本身相比`ObjC`或其他编程语言有什么优势。`Swift`有三个重要的特性分别是`富有表现力`/`安全性`/`快速`，接下来我们分别从这三个特性简单介绍一下：

### 富有表现力

`Swift`提供更多的`编程范式`和`特性`支持，可以编写更少的代码，而且易于阅读和维护。

*   `基础类型` - 元组、Enum`关联类型`
*   `方法` - `方法重载`
*   `protocol` - 不限制只支持`class`、协议`默认`实现、`类`专属协议
*   `泛型` - `protocol`关联类型、`where`实现类型约束、泛型扩展
*   `可选值` - 可选值申明、可选链、隐式可选值
*   `属性` - let、lazy、计算属性\`、willset/didset、Property Wrappers
*   `函数式编程` - 集合`filter/map/reduce`方法，提供更多标准库方法
*   `并发` - async/await、actor
*   `标准库框架` - `Combine`响应式框架、`SwiftUI`申明式UI框架、`Codable`JSON模型转换
*   `Result builder` - 描述实现`DSL`的能力
*   `动态性` - dynamicCallable、dynamicMemberLookup
*   `其他` - 扩展、subscript、操作符重写、嵌套类型、区间
*   `Swift Package Manager` - 基于Swift的包管理工具，可以直接用`Xcode`进行管理更方便
*   `struct` - 初始化方法自动补齐
*   `类型推断` - 通过编译器强大的`类型推断`编写代码时可以减少很多类型申明

> 提示：类型推断同时也会增加一定的编译`耗时`，不过`Swift`团队也在不断的改善编译速度。

### 安全性

#### 代码安全

*   `let属性` - 使用`let`申明常量避免被修改。
*   `值类型` - 值类型可以避免在方法调用等`参数传递`过程中状态被修改。
*   `访问控制` - 通过`public`和`final`限制模块外使用`class`不能被`继承`和`重写`。
*   `强制异常处理` - 方法需要抛出异常时，需要申明为`throw`方法。当调用可能会`throw`异常的方法，需要强制捕获异常避免将异常暴露到上层。
*   `模式匹配` - 通过模式匹配检测`switch`中未处理的case。

#### 类型安全

*   `强制类型转换` - 禁止`隐式类型转换`避免转换中带来的异常问题。同时类型转换不会带来`额外`的运行时消耗。。

> 提示：编写`ObjC`代码时，我们通常会在编码时添加类型检查避免运行时崩溃导致`Crash`。

*   `KeyPath` - `KeyPath`相比使用`字符串`可以提供属性名和类型信息，可以利用编译器检查。
*   `泛型` - 提供`泛型`和协议`关联类型`，可以编写出类型安全的代码。相比`Any`可以更多利用编译时检查发现类型问题。
*   `Enum关联类型` - 通过给特定枚举指定类型避免使用`Any`。

#### 内存安全

*   `空安全` - 通过标识可选值避免`空指针`带来的异常问题
*   `ARC` - 使用`自动`内存管理避免`手动`管理内存带来的各种内存问题
*   `强制初始化` - 变量使用前必须`初始化`
*   `内存独占访问` - 通过编译器检查发现潜在的内存冲突问题

#### 线程安全

*   `值类型` - 更多使用值类型减少在多线程中遇到的`数据竞争`问题
*   `async/await` - 提供`async`函数使我们可以用结构化的方式编写并发操作。避免基于`闭包`的异步方式带来的内存`循环引用`和无法抛出异常的问题
*   `Actor` - 提供`Actor`模型避免多线程开发中进行数据共享时发生的数据竞争问题，同时避免在使用锁时带来的死锁等问题

### 快速

*   `值类型` - 相比`class`不需要额外的`堆内存`分配/释放和更少的内存消耗
*   `方法静态派发` - 方法调用支持`静态`调用相比原有ObjC`消息转发`调用性能更好
*   `编译器优化` - Swift的`静态性`可以使编译器做更多优化。例如`Tree Shaking`相关优化移除未使用的类型/方法等减少二进制文件大小。使用`静态派发`/`方法内联优化`/`泛型特化`/`写时复制`等优化提高运行时性能

> 提示：`ObjC`消息派发会导致编译器无法进行移除无用方法/类的优化，编译器并不知道是否可能被用到。

*   `ARC优化` - 虽然和`ObjC`一样都是使用`ARC`，`Swift`通过编译器优化，可以进行更快的内存回收和更少的内存引用计数管理

> 提示： 相比`ObjC`，Swift内部不需要使用`autorelease`进行管理。

代码质量指标
======

![代码质量指标](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8f8f0f4ff0424a3e8415ae77e0d38a88~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) 以上是一些常见的代码质量指标。我们的目标是如何更好的使用`Swift`编写出符合代码质量指标要求的代码。

> 提示：本文不涉及设计模式/架构，更多关注如何通过合理使用`Swift`特性做局部代码段的重构。

一些不错的实践
-------

### 利用编译检查

#### 减少使用`Any/AnyObject`

因为`Any/AnyObject`缺少明确的类型信息，编译器无法进行类型检查，会带来一些问题：

*   编译器无法检查类型是否正确保证类型安全
*   代码中大量的`as?`转换
*   类型的缺失导致编译器无法做一些潜在的`编译优化`

##### 使用`as?`带来的问题

当使用`Any/AnyObject`时会频繁使用`as?`进行类型转换。这好像没什么问题因为使用`as?`并不会导致程序`Crash`。不过代码错误至少应该分为两类，一类是程序本身的错误通常会引发Crash，另外一种是业务逻辑错误。使用`as?`只是避免了程序错误`Crash`，但是并不能防止业务逻辑错误。

    func do(data: Any?) {
        guard let string = data as? String else {
            return
        }
        // 
    }
    
    do(1)
    do("")
    复制代码

以上面的例子为例，我们进行了`as?`转换，当`data`为`String`时才会进行处理。但是当`do`方法内`String`类型发生了改变函数，使用方并不知道已变更没有做相应的适配，这时候就会造成业务逻辑的错误。

> 提示：这类错误通常更难发现，这也是我们在一次真实`bug`场景遇到的。

#### 使用`自定义类型`代替`Dictionary`

代码中大量`Dictionary`数据结构会降低代码可维护性，同时带来潜在的`bug`：

*   `key`需要字符串硬编码，编译时无法检查
*   `value`没有类型限制。`修改`时类型无法限制，读取时需要重复类型转换和解包操作
*   无法利用`空安全`特性，指定某个属性必须有值

> 提示：`自定义类型`还有个好处，例如`JSON`转`自定义类型`时会进行`类型/nil/属性名`检查，可以避免将错误数据丢到下一层。

##### 不推荐

    let dic: [String: Any]
    let num = dic["value"] as? Int
    dic["name"] = "name"
    复制代码

##### 推荐

    struct Data {
      let num: Int
      var name: String?
    }
    let num = data.num
    data.name = "name"
    复制代码

##### 适合使用`Dictionary`的场景

*   `数据不使用` - 数据并不`读取`只是用来传递。
*   `解耦` - 1.`组件间通信`解耦使用`HashMap`传递参数进行通信。2.跨技术栈边界的场景，`混合栈间通信/前后端通信`使用`HashMap`/`JSON`进行通信。

#### 使用`枚举关联值`代替`Any`

例如使用枚举改造`NSAttributedString`API，原有API`value`为`Any`类型无法限制特定的类型。

##### 优化前

    let string = NSMutableAttributedString()
    string.addAttribute(.foregroundColor, value: UIColor.red, range: range)
    复制代码

##### 改造后

    enum NSAttributedStringKey {
      case foregroundColor(UIColor)
    }
    let string = NSMutableAttributedString()
    string.addAttribute(.foregroundColor(UIColor.red), range: range) // 不传递Color会报错
    复制代码

#### 使用`泛型`/`协议关联类型`代替`Any`

使用`泛型`或`协议关联类型`代替`Any`，通过`泛型类型约束`来使编译器进行更多的类型检查。

#### 使用`枚举`/`常量`代替`硬编码`

代码中存在重复的`硬编码`字符串/数字，在修改时可能会因为不同步引发`bug`。尽可能减少`硬编码`字符串/数字，使用`枚举`或`常量`代替。

#### 使用`KeyPath`代替`字符串`硬编码

`KeyPath`包含属性名和类型信息，可以避免`硬编码`字符串，同时当属性名或类型改变时编译器会进行检查。

##### 不推荐

    class SomeClass: NSObject {
        @objc dynamic var someProperty: Int
        init(someProperty: Int) {
            self.someProperty = someProperty
        }
    }
    let object = SomeClass(someProperty: 10)
    object.observeValue(forKeyPath: "", of: nil, change: nil, context: nil)
    复制代码

##### 推荐

    let object = SomeClass(someProperty: 10)
    object.observe(\.someProperty) { object, change in
    }
    复制代码

### 内存安全

#### 减少使用`!`属性

`!`属性会在读取时隐式`强解包`，当值不存在时产生运行时异常导致Crash。

    class ViewController: UIViewController {
        @IBOutlet private var label: UILabel! // @IBOutlet需要使用!
    }
    复制代码

#### 减少使用`!`进行强解包

使用`!`强解包会在值不存在时产生运行时异常导致Crash。

    var num: Int?
    let num2 = num! // 错误
    复制代码

> 提示：建议只在小范围的局部代码段使用`!`强解包。

#### 避免使用`try!`进行错误处理

使用`try!`会在方法抛出异常时产生运行时异常导致Crash。

    try! method()
    复制代码

#### 使用`weak`/`unowned`避免循环引用

    resource.request().onComplete { [weak self] response in
      guard let self = self else {
        return
      }
      let model = self.updateModel(response)
      self.updateUI(model)
    }
    
    resource.request().onComplete { [unowned self] response in
      let model = self.updateModel(response)
      self.updateUI(model)
    }
    复制代码

#### 减少使用`unowned`

`unowned`在值不存在时会产生运行时异常导致Crash，只有在确定`self`一定会存在时才使用`unowned`。

    class Class {
        @objc unowned var object: Object
        @objc weak var object: Object?
    }
    复制代码

`unowned`/`weak`区别：

*   `weak` - 必须设置为可选值，会进行弱引用处理性能更差。会自动设置为`nil`
*   `unowned` - 可以不设置为可选值，不会进行弱引用处理性能更好。但是不会自动设置为`nil`, 如果`self`已释放会触发错误.

### 错误处理方式

*   `可选值` - 调用方并不关注内部可能会发生错误，当发生错误时返回`nil`
*   `try/catch` - 明确提示调用方需要处理异常，需要实现`Error`协议定义明确的错误类型
*   `assert` - 断言。只能在`Debug`模式下生效
*   `precondition` - 和`assert`类似，可以再`Debug`/`Release`模式下生效
*   `fatalError` - 产生运行时崩溃会导致Crash，应避免使用
*   `Result` - 通常用于`闭包`异步回调返回值

### 减少使用可选值

`可选值`的价值在于通过明确标识值可能会为`nil`并且编译器强制对值进行`nil`判断。但是不应该随意的定义可选值，可选值不能用`let`定义，并且使用时必须进行`解包`操作相对比较繁琐。在代码设计时应考虑`这个值是否有可能为nil`，只在合适的场景使用可选值。

#### 使用`init`注入代替`可选值`属性

##### 不推荐

    class Object {
      var num: Int?
    }
    let object = Object()
    object.num = 1
    复制代码

##### 推荐

    class Object {
      let num: Int
    
      init(num: Int) {
        self.num = num
      }
    }
    let object = Object(num: 1)
    复制代码

#### 避免随意给予可选值默认值

在使用可选值时，通常我们需要在可选值为`nil`时进行异常处理。有时候我们会通过给予可选值`默认值`的方式来处理。但是这里应考虑在什么场景下可以给予默认值。在不能给予默认值的场景应当及时使用`return`或`抛出异常`，避免错误的值被传递到更多的业务流程。

##### 不推荐

    func confirmOrder(id: String) {}
    // 给予错误的值会导致错误的值被传递到更多的业务流程
    confirmOrder(id: orderId ?? "")
    复制代码

##### 推荐

    func confirmOrder(id: String) {}
    
    guard let orderId = orderId else {
        // 异常处理
        return
    }
    confirmOrder(id: orderId)
    复制代码

> 提示：通常强业务相关的值不能给予默认值：例如`商品/订单id`或是`价格`。在可以使用兜底逻辑的场景使用默认值，例如`默认文字/文字颜色`。

#### 使用枚举优化可选值

`Object`结构同时只会有一个值存在：

##### 优化前

    class Object {
        var name: Int?
        var num: Int?
    }
    复制代码

##### 优化后

*   `降低内存占用` - `枚举关联类型`的大小取决于最大的关联类型大小
*   `逻辑更清晰` - 使用`enum`相比大量使用`if/else`逻辑更清晰

    enum CustomType {
        case name(String)
        case num(Int)
    }
    复制代码

### 减少`var`属性

#### 使用计算属性

使用`计算属性`可以减少多个变量同步带来的潜在bug。

##### 不推荐

    class model {
      var data: Object?
      var loaded: Bool
    }
    model.data = Object()
    loaded = false
    复制代码

##### 推荐

    class model {
      var data: Object?
      var loaded: Bool {
        return data != nil
      }
    }
    model.data = Object()
    复制代码

> 提示：计算属性因为每次都会重复计算，所以计算过程需要轻量避免带来性能问题。

### 控制流

#### 使用`filter/reduce/map`代替`for`循环

使用`filter/reduce/map`可以带来很多好处，包括更少的局部变量，减少模板代码，代码更加清晰，可读性更高。

##### 不推荐

    let nums = [1, 2, 3]
    var result = []
    for num in nums {
        if num < 3 {
            result.append(String(num))
        }
    }
    // result = ["1", "2"]
    复制代码

##### 推荐

    let nums = [1, 2, 3]
    let result = nums.filter { $0 < 3 }.map { String($0) }
    // result = ["1", "2"]
    复制代码

#### 使用`guard`进行提前返回

##### 推荐

    guard !a else {
        return
    }
    guard !b else {
        return
    }
    // do
    复制代码

##### 不推荐

    if a {
        if b {
            // do
        }
    }
    复制代码

#### 使用三元运算符`?:`

###### 推荐

    let b = true
    let a = b ? 1 : 2
    
    let c: Int?
    let b = c ?? 1
    复制代码

###### 不推荐

    var a: Int?
    if b {
        a = 1
    } else {
        a = 2
    }
    复制代码

#### 使用`for where`优化循环

`for`循环添加`where`语句，只有当`where`条件满足时才会进入循环

##### 不推荐

    for item in collection {
      if item.hasProperty {
        // ...
      }
    }
    复制代码

##### 推荐

    for item in collection where item.hasProperty {
      // item.hasProperty == true，才会进入循环
    }
    复制代码

#### 使用`defer`

`defer`可以保证在函数退出前一定会执行。可以使用`defer`中实现退出时一定会执行的操作例如`资源释放`等避免遗漏。

    func method() {
        lock.lock()
        defer {
            lock.unlock()
            // 会在method作用域结束的时候调用
        }
        // do
    }
    复制代码

### defer可以保证在函数退出前一定会执行,内部是怎么实现的？
defer 语句的执行原理是使用了栈（stack）结构。当 defer 语句遇到时，其中的代码块会被添加到一个栈中，以便在当前作用域结束前按照后进先出（LIFO）的顺序执行。

具体实现的原理如下：

当遇到 defer 语句时，其中的代码块被添加到一个栈中。

在当前作用域结束之前，无论是通过正常的 return 语句、抛出异常、或其他控制流改变，Swift 都会确保执行栈中的 defer 语句。

defer 语句按照后进先出（LIFO）的顺序执行，即最后添加的 defer 语句最先执行。

通过这种方式，defer 语句可以保证在当前作用域结束之前一定会执行，无论控制流如何改变。 


### 字符串

#### 使用`"""`

在定义`复杂`字符串时，使用`多行字符串字面量`可以保持原有字符串的换行符号/引号等特殊字符，不需要使用`\`进行转义。

    let quotation = """
    The White Rabbit put on his spectacles.  "Where shall I begin,
    please your Majesty?" he asked.
    
    "Begin at the beginning," the King said gravely, "and go on
    till you come to the end; then stop."
    """
    复制代码

> 提示：上面字符串中的`""`和换行可以自动保留。

#### 使用字符串插值

使用字符串插值可以提高代码可读性。

##### 不推荐

    let multiplier = 3
    let message = String(multiplier) + "times 2.5 is" + String((Double(multiplier) * 2.5))
    复制代码

##### 推荐

    let multiplier = 3
    let message = "\(multiplier) times 2.5 is \(Double(multiplier) * 2.5)"
    复制代码

### 集合

#### 使用标准库提供的高阶函数

##### 不推荐

    var nums = []
    nums.count == 0
    nums[0]
    复制代码

##### 推荐

    var nums = []
    nums.isEmpty
    nums.first
    复制代码

### 访问控制

`Swift`中默认访问控制级别为`internal`。编码中应当尽可能减小`属性`/`方法`/`类型`的访问控制级别隐藏内部实现。

> 提示：同时也有利于编译器进行优化。

#### 使用`private`/`fileprivate`修饰私有`属性`和`方法`

    private let num = 1
    class MyClass {
        private var num: Int
    }
    复制代码

#### 使用`private(set)`修饰外部只读/内部可读写属性

    class MyClass {
        private(set) var num = 1
    }
    let num = MyClass().num
    MyClass().num = 2 // 会编译报错
    复制代码

### 函数

#### 使用参数默认值

使用参数`默认值`，可以使调用方传递`更少`的参数。

##### 不推荐

    func test(a: Int, b: String?, c: Int?) {
    }
    test(1, nil, nil)
    复制代码

##### 推荐

    func test(a: Int, b: String? = nil, c: Int? = nil) {
    }
    test(1)
    复制代码

> 提示：相比`ObjC`，`参数默认值`也可以让我们定义更少的方法。

#### 限制参数数量

当方法参数过多时考虑使用`自定义类型`代替。

##### 不推荐

    func f(a: Int, b: Int, c: Int, d: Int, e: Int, f: Int) {
    }
    复制代码

##### 推荐

    struct Params {
        let a, b, c, d, e, f: Int
    }
    func f(params: Params) {
    }
    复制代码

#### 使用`@discardableResult`

某些方法使用方并不一定会处理返回值，可以考虑添加`@discardableResult`标识提示`Xcode`允许不处理返回值不进行`warning`提示。

    // 上报方法使用方不关心是否成功
    func report(id: String) -> Bool {} 
    
    @discardableResult func report2(id: String) -> Bool {}
    
    report("1") // 编译器会警告
    report2("1") // 不处理返回值编译器不会警告
    复制代码

### 元组

#### 避免过长的元组

元组虽然具有类型信息，但是并不包含`变量名`信息，使用方并不清晰知道变量的含义。所以当元组数量过多时考虑使用`自定义类型`代替。

    func test() -> (Int, Int, Int) {
    
    }
    
    let (a, b, c) = test()
    // a，b，c类型一致，没有命名信息不清楚每个变量的含义
    复制代码

### 系统库

#### `KVO`/`Notification` 使用 `block` API

`block` API的优势：

*   `KVO` 可以支持 `KeyPath`
*   不需要主动移除监听，`observer`释放时自动移除监听

##### 不推荐

    class Object: NSObject {
      init() {
        super.init()
        addObserver(self, forKeyPath: "value", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(test), name: NSNotification.Name(rawValue: ""), object: nil)
      }
    
      override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
      }
    
      @objc private func test() {
      }
    
      deinit {
        removeObserver(self, forKeyPath: "value")
        NotificationCenter.default.removeObserver(self)
      }
    
    }
    复制代码

##### 推荐

    class Object: NSObject {
    
      private var observer: AnyObserver?
      private var kvoObserver: NSKeyValueObservation?
    
      init() {
        super.init()
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ""), object: nil, queue: nil) { (_) in 
        }
        kvoObserver = foo.observe(\.value, options: [.new]) { (foo, change) in
        }
      }
    }
    复制代码

### Protocol

#### 使用`protocol`代替继承

`Swift`中针对`protocol`提供了很多新特性，例如`默认实现`，`关联类型`，支持值类型。在代码设计时可以优先考虑使用`protocol`来避免臃肿的父类同时更多使用值类型。

> 提示：一些无法用`protocol`替代`继承`的场景：1.需要继承NSObject子类。2.需要调用`super`方法。3.实现`抽象类`的能力。

### Extension

#### 使用`extension`组织代码

使用`extension`将`私有方法`/`父类方法`/`协议方法`等不同功能代码进行分离更加清晰/易维护。

    class MyViewController: UIViewController {
      // class stuff here
    }
    // MARK: - Private
    extension: MyViewController {
        private func method() {}
    }
    // MARK: - UITableViewDataSource
    extension MyViewController: UITableViewDataSource {
      // table view data source methods
    }
    // MARK: - UIScrollViewDelegate
    extension MyViewController: UIScrollViewDelegate {
      // scroll view delegate methods
    }
    复制代码

### 代码风格

良好的代码风格可以提高代码的`可读性`，统一的代码风格可以降低团队内相互`理解成本`。对于`Swift`的代码`格式化`建议使用自动格式化工具实现，将自动格式化添加到代码提交流程，通过定义Lint`规则`统一团队内代码风格。考虑使用`SwiftFormat`和`SwiftLint`。

> 提示：`SwiftFormat`主要关注代码样式的格式化，`SwiftLint`可以使用`autocorrect`自动修复部分不规范的代码。

##### 常见的自动格式化修正

*   移除多余的`;`
*   最多只保留一行换行
*   自动对齐`空格`
*   限制每行的宽度`自动换行`

性能优化
----

性能优化上主要关注提高`运行时性能`和降低`二进制体积`。需要考虑如何更好的使用`Swift`特性，同时提供更多信息给`编译器`进行优化。

### 使用`Whole Module Optimization`

当`Xcode`开启`WMO`优化时，编译器可以将整个程序编译为一个文件进行更多的优化。例如通过`推断final`/`函数内联`/`泛型特化`更多使用静态派发，并且可以`移除`部分未使用的代码。

### 使用`源代码`打包

当我们使用`组件化`时，为了提高`编译速度`和`打包效率`，通常单个组件独立编译生成`静态库`，最后多个组件直接使用`静态库`进行打包。这种场景下`WMO`仅针对`internal`以内作用域生效，对于`public/open`缺少外部使用信息所以无法进行优化。所以对于大量使用`Swift`的项目，使用`全量代码打包`更有利于编译器做更多优化。

### 减少方法`动态`派发

*   `使用final` - `class`/`方法`/`属性`申明为`final`，编译器可以优化为静态派发
*   `使用private` - `方法`/`属性`申明为`private`，编译器可以优化为静态派发
*   `避免使用dynamic` - `dynamic`会使方法通过ObjC`消息转发`的方式派发
*   `使用WMO` - 编译器可以自动分析推断出`final`优化为静态派发

### 使用`Slice`共享内存优化性能

在使用`Array`/`String`时，可以使用`Slice`切片获取一部分数据。`Slice`保存对原始`Array`/`String`的引用共享内存数据，不需要重新分配空间进行存储。

    let midpoint = absences.count / 2
    
    let firstHalf = absences[..<midpoint]
    let secondHalf = absences[midpoint...]
    // firstHalf/secondHalf并不会复制和占用更多内存
    复制代码

> 提示：应`避免`一直持有`Slice`，`Slice`会延长原始`Array`/`String`的生命周期导致无法被释放造成`内存泄漏`。

### `protocol`添加`AnyObject`

    protocol AnyProtocol {}
    
    protocol ObjectProtocol: AnyObject {}
    复制代码

当`protocol`仅限制为`class`使用时，继承`AnyObject`协议可以使编译器不需要考虑`值类型`实现，提高运行时性能。

### 使用`@inlinable`进行方法内联优化

    // 原始代码
    let label = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = UIColor.black
        $0.text = "Hello, World!"
    }
    复制代码

以`then`库为例，他使用闭包进行对象初始化以后的相关设置。但是 `then` 方法以及`闭包`也会带来额外的性能消耗。

#### 内联优化

    @inlinable
    public func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
    复制代码

    // 编译器内联优化后
    let label = UILabel() 
    label.textAlignment = .center
    label.textColor = UIColor.black
    label.text = "Hello, World!"
    复制代码

### 属性

#### 使用`lazy`延时初始化属性

    class View {
        var lazy label: UILabel = {
            let label = UILabel()
            self.addSubView(label)
            return label
        }()
    }
    复制代码

`lazy`属性初始化会`延迟`到第一次使用时，常见的使用场景：

*   初始化比较耗时
*   可能不会被使用到
*   初始化过程需要使用`self`

> 提示：`lazy`属性不能保证线程安全

#### 避免使用`private let`属性

`private let`属性会增加每个`class`对象的内存大小。同时会增加`包大小`，因为需要为属性生成相关的信息。可以考虑使用文件级`private let`申明或`static`常量代替。

##### 不推荐

    class Object {
        private let title = "12345"
    }
    复制代码

##### 推荐

    private let title = "12345"
    class Object {
        static let title = ""
    }
    复制代码

> 提示：这里并不包括通过`init`初始化注入的属性。

#### 使用`didSet`/`willSet`时进行`Diff`

某些场景需要使用`didSet`/`willSet`属性检查器监控属性变化，做一些额外的计算。但是由于`didSet`/`willSet`并不会检查`新/旧`值是否相同，可以考虑添加`新/旧`值判断，只有当值真的改变时才进行运算提高性能。

##### 优化前

    class Object {
        var orderId: String? {
            didSet {
                // 拉取接口等操作
            }
        }
    }
    复制代码

例如上面的例子，当每一次`orderId`变更时需要重新拉取当前订单的数据，但是当orderId值一样时，拉取订单数据是无效执行。

##### 优化后

    class Object {
        var orderId: String? {
            didSet {
                // 判断新旧值是否相等
                guard oldValue != orderId else {
                    return
                }
                // 拉取接口等操作
            }
        }
    }
    复制代码

### 集合

#### 集合使用`lazy`延迟序列

    var nums = [1, 2, 3]
    var result = nums.lazy.map { String($0) }
    result[0] // 对1进行map操作
    result[1] // 对2进行map操作
    复制代码

在集合操作时使用`lazy`，可以将数组运算操作`推迟`到第一次使用时，避免一次性全部计算。注意：这里的lazy是指每个项都是在使用的时候才去懒加载的意思，而不是使用到result去懒加载所有项

> 提示：例如长列表，我们需要创建每个`cell`对应的`视图模型`，一次性创建太耗费时间。

### lazy是怎么做到按需和延迟加载的？
lazy 是通过使用闭包（closure）和惰性计算的机制来实现按需和延迟加载的特性。

当你使用 lazy 关键字修饰一个属性或创建一个序列时，实际的初始化或计算过程会被推迟到首次访问属性或序列元素时才会执行。

具体的实现机制如下：

定义属性或序列时，使用 lazy 关键字修饰，并提供一个闭包（或称为延迟加载闭包）作为属性的初始化器或序列的生成器。

闭包中包含了实际初始化或计算属性值的逻辑。但是，该闭包并不会立即执行，而是在首次访问属性或序列元素时才会被调用。

当首次访问属性或序列元素时，系统会检测到属性或序列是 lazy 的，然后自动调用闭包来执行实际的初始化或计算过程，并返回结果。

闭包执行完毕后，返回的结果会被缓存起来，下一次访问属性或序列元素时直接使用缓存的结果，避免重复执行闭包。

这种机制使得属性或序列的实际初始化或计算过程可以推迟到首次访问时执行，而不是立即执行。这样可以节省资源和提高性能，特别是当你只需要使用属性或序列的一部分时，避免了不必要的初始化或计算开销。

需要注意的是，由于闭包的执行是在首次访问时进行，因此如果闭包中有副作用（例如打印日志、更新状态等），那么这些副作用也会被推迟到首次访问时发生。

综上所述，lazy 通过使用闭包和惰性计算的机制来实现按需和延迟加载的特性。这种机制允许属性或序列的实际初始化或计算过程在首次访问时执行，并避免了不必要的计算开销，提高了性能和资源利用率。


#### 使用合适的集合方法优化性能

##### 不推荐

    var items = [1, 2, 3]
    items.filter({ $0 > 1 }).first // 查找出所有大于1的元素，之后找出第一个
    复制代码

##### 推荐

    var items = [1, 2, 3]
    items.first(where: { $0 > 1 }) // 查找出第一个大于1的元素直接返回
    复制代码

### 使用值类型

`Swift`中的值类型主要是`结构体`/`枚举`/`元组`。

*   `启动性能` - `APP启动`时值类型没有额外的消耗，`class`有一定额外的消耗。
*   `运行时性能`\- 值类型不需要在堆上分配空间/额外的引用计数管理。更少的内存占用和更快的性能。
*   `包大小` - 相比`class`，值类型不需要创建`ObjC`类对应的`ro_data_t`数据结构。

> 提示：`class`即使没有继承`NSObject`也会生成`ro_data_t`，里面包含了`ivars`属性信息。如果`属性/方法`申明为`@objc`还会生成对应的方法列表。

> 提示：`struct`无法代替`class`的一些场景：1.需要使用`继承`调用`super`。2.需要使用引用类型。3.需要使用`deinit`。4.需要在运行时动态转换一个实例的类型。

> 提示：不是所有`struct`都会保存在`栈`上，部分数据大的`struct`也会保存在堆上。


### swift中不是所有struct都会保存在栈上，部分数据大的struct也会保存在堆上？
在 Swift 中，结构体（Struct）通常会被分配在栈上，尤其是当结构体较小且被存储在函数的局部变量或方法的参数中时。这种情况下，结构体的实例在超出其作用域后会自动释放。

然而，对于一些特殊情况，结构体实例可能会被分配在堆上，这通常发生在以下情况下：

结构体作为类（Class）的属性或变量时：当结构体作为类的属性或变量存储时，它们会被分配在堆上。这是因为类实例存储在堆上，而结构体实例作为类的一部分也会随之存储在堆上。

结构体使用了引用类型：如果结构体定义了引用类型的属性（如类实例、闭包等），那么结构体实例将被分配在堆上。这是因为引用类型需要动态分配内存，并通过引用进行访问，所以整个结构体实例也需要存储在堆上。

结构体使用了 Copy-on-Write 机制：Copy-on-Write（COW）是一种优化技术，用于在结构体被多个引用共享时避免不必要的复制。当结构体使用了 COW 机制时，如果进行了修改操作，原始结构体会被复制到堆上，并且修改只针对复制的副本进行。这样可以避免多次复制操作，提高性能。

需要注意的是，这些情况下结构体实例在堆上的分配并不是默认行为，而是由特定的条件触发。大多数情况下，结构体实例仍然被分配在栈上，而只有在特定情况下才会分配在堆上。

此外，对于小型的结构体，即使在某些情况下分配在堆上，由于其相对较小，分配和释放的开销通常仍然很小。

综上所述，尽管结构体通常会被分配在栈上，但在某些特定情况下，它们可能会被分配在堆上。这些情况包括结构体作为类的属性、结构体使用引用类型、以及使用了 Copy-on-Write 机制。

#### 集合元素使用值类型

集合元素使用值类型。因为`NSArray`并不支持值类型，编译器不需要处理可能需要桥接到`NSArray`的场景，可以移除部分消耗。

#### 纯静态类型避免使用`class`

当`class`只包含`静态方法/属性`时，考虑使用`enum`代替`class`，因为`class`会生成更多的二进制代码。

##### 不推荐

    class Object {
        static var num: Int
        static func test() {}
    }
    复制代码

##### 推荐

    enum Object {
        static var num: Int
        static func test() {}
    }
    复制代码

> 提示：为什么用`enum`而不是`struct`，因为`struct`会额外生成`init`方法。

### 值类型性能优化

#### 考虑使用引用类型

值类型为了维持`值语义`，会在每次`赋值`/`参数传递`/`修改`时进行复制。虽然编译器本身会做一些优化，例如`写时复制优化`，在`修改`时减少复制频率，但是这仅针对于标准库提供的`集合`和`String`结构有效，对于`自定义结构`需要自己实现。对于`参数传递`编译器在一些场景会优化为直接`传递引用`的方式避免复制行为。

但是对于一些数据特别大的结构，同时需要频繁变更修改时也可以考虑使用`引用类型`实现。

#### 使用`inout`传递参数减少复制

虽然编译器本身会进行`写时复制`的优化，但是部分场景编译器无法处理。

##### 不推荐

    func append_one(_ a: [Int]) -> [Int] {
      var a = a
      a.append(1) // 无法被编译器优化，因为这时候有2个引用持有数组
      return a
    }
    
    var a = [1, 2, 3]
    a = append_one(a)
    复制代码

##### 推荐

直接使用`inout`传递参数

    func append_one_in_place(a: inout [Int]) {
      a.append(1)
    }
    
    var a = [1, 2, 3]
    append_one_in_place(&a)
    复制代码

#### 使用`isKnownUniquelyReferenced`实现`写时复制`

默认情况下结构体中包含`引用类型`，在修改时只会重新拷贝引用。但是我们希望`CustomData`具备值类型的特性，所以当修改时需要重新复制`NSMutableData`避免复用。但是`复制`操作本身是耗时操作，我们希望可以减少一些不必要的复制。

##### 优化前

    struct CustomData {
        fileprivate var _data: NSMutableData
        var _dataForWriting: NSMutableData {
            mutating get {
                _data = _data.mutableCopy() as! NSMutableData
                return _data
            }
        }
        init(_ data: NSData) {
            self._data = data.mutableCopy() as! NSMutableData
        }
    
        mutating func append(_ other: MyData) {
            _dataForWriting.append(other._data as Data)
        }
    }
    
    var buffer = CustomData(NSData())
    for _ in 0..<5 {
        buffer.append(x) // 每一次调用都会复制
    }
    复制代码

##### 优化后

使用`isKnownUniquelyReferenced`检查如果是`唯一引用`不进行复制。

    final class Box<A> {
        var unbox: A
        init(_ value: A) { self.unbox = value }
    }
    
    struct CustomData {
        fileprivate var _data: Box<NSMutableData>
        var _dataForWriting: NSMutableData {
            mutating get {
                // 检查引用是否唯一
                if !isKnownUniquelyReferenced(&_data) {
                    _data = Box(_data.unbox.mutableCopy() as! NSMutableData)
                }
                return _data.unbox
            }
        }
        init(_ data: NSData) {
            self._data = Box(data.mutableCopy() as! NSMutableData)
        }
    }
    
    var buffer = CustomData(NSData())
    for _ in 0..<5 {
        buffer.append(x) // 只会在第一次调用时进行复制
    }
    复制代码

> 提示：对于`ObjC`类型`isKnownUniquelyReferenced`会直接返回`false`。

### 减少使用`Objc`特性

#### 避免使用`Objc`类型

尽可能避免在`Swift`中使用`NSString`/`NSArray`/`NSDictionary`等`ObjC`基础类型。以`Dictionary`为例，虽然`Swift Runtime`可以在`NSArray`和`Array`之间进行隐式桥接需要`O(1)`的时间。但是字典当`Key`和`Value`既不是类也不是`@objc`协议时，需要对`每个值`进行桥接，可能会导致消耗`O(n)`时间。

### 减少添加`@objc`标识

`@objc`标识虽然不会强制使用`消息转发`的方式来调用`方法/属性`，但是他会默认`ObjC`是可见的会生成和`ObjC`一样的`ro_data_t`结构。

#### 避免使用`@objcMembers`

使用`@objcMembers`修饰的类，默认会为`类`/`属性`/`方法`/`扩展`都加上`@objc`标识。

    @objcMembers class Object: NSObject {
    }
    复制代码

> 提示：你也可以使用`@nonobjc`取消支持`ObjC`。

#### 避免继承`NSObject`

你只需要在需要使用`NSObject`特性时才需要继承，例如需要实现`UITableViewDataSource`相关协议。

### 使用`let`变量/属性

##### 优化集合创建

集合不需要修改时，使用`let`修饰，编译器会优化创建集合的性能。例如针对`let`集合，`编译器`在创建时可以分配更小的`内存大小`。

##### 优化逃逸闭包

在`Swift`中，当捕获`var`变量时编译器需要生成一个在堆上的`Box`保存变量用于之后对于变量的`读/写`，同时需要额外的内存管理操作。如果是`let`变量，编译器可以保存`值复制或引用`，避免使用`Box`。

### 避免使用大型`struct`使用`class`代替

大型`struct`通常是指属性特别多并且嵌套类型很多。目前`swift`编译器针对struct等值类型编译优化处理的并不好，会生成大量的`assignWithCopy`、`assignWithCopy`等copy相关方法，生成大量的二进制代码。使用`class`类型可以避免生成相关的copy方法。

> 提示：不要小看这部分二进制的影响，个人在日常项目中遇到过复杂的大型struct能生成`几百KB`的二进制代码。但是目前并没有好的方法去发现这类`struct`去做优化，只能通过相关工具去查看生成的二进制详细信息。希望官方可以早点优化。

### 优先使用`Encodable/Decodable`协议代替`Codable`

因为实现`Encodable`和`Decodable`协议的结构，编译器在编译时会自动生成对应的`init(from decoder: Decoder)`和`encode(to: Encoder)`方法。`Codable`同时实现了`Encodable`和`Decodable`协议，但是大部分场景下我们只需要`encode`或`decode`能力，所以明确指定实现`Encodable`或`Decodable`协议可以减少生成对应的方法`减少包体积`。

> 提示：对于属性比较多的类型结构会产生很大的二进制代码，有兴趣可以用相关的工具看看生成的二进制文件。

### 减少使用`Equatable`协议

因为实现`Equatable`协议的结构，编译器在编译时会自动生成对应的`equal`方法。默认实现是针对所有字段进行比较会生成大量的代码。所以当我们不需要实现`==`比较能力时不要实现`Equatable`或者对于属性特别多的类型也可以考虑重写`Equatable`协议，只针对部分属性进行比较，这样可以生成更少的代码`减少包体积`。

> 提示：对于属性特别多的类型也可以考虑重写`Equatable`协议，只针对部分属性进行比较，同时也可以提升性能。

总结
==

个人从`Swift`3.0开始将`Swift`作为第一语言使用。编写`Swift`代码并不只是简单对于`ObjC`代码的翻译/重写，需要对于`Swift`特性更多的理解才能更好的利用这些特性带来更多的收益。同时我们需要关注每个版本`Swift`的优化/改进和新特性。在这过程中也会提高我们的编码能力，加深对于一些通用编程概念/思想的理解，包括`空安全、值类型、协程、不共享数据的Actor并发模型、函数式编程、面向协议编程、内存所有权`等。对于新的现代编程语言例如`Swift`/`Dart`/`TS`/`Kotlin`/`Rust`等，很多特性/思想都是相互借鉴，当我们理解这些概念/思想以后对于理解其他语言也会更容易。

这里推荐有兴趣可以关注[Swift Evolution](https://link.juejin.cn?target=https%3A%2F%2Fapple.github.io%2Fswift-evolution%2F "https://apple.github.io/swift-evolution/")，每个特性加入都会有一个提案，里面会详细介绍`动机`/`使用场景`/`实现方式`/`未来方向`。

扩展链接
====

*   [The Swift Programming Language](https://link.juejin.cn?target=https%3A%2F%2Fdocs.swift.org%2Fswift-book%2F "https://docs.swift.org/swift-book/")
*   [Swift 进阶](https://link.juejin.cn?target=https%3A%2F%2Fobjccn.io%2Fproducts%2Fadvanced-swift%2F "https://objccn.io/products/advanced-swift/")
*   [SwiftLint Rules](https://link.juejin.cn?target=https%3A%2F%2Frealm.github.io%2FSwiftLint%2Frule-directory.html "https://realm.github.io/SwiftLint/rule-directory.html")
*   [OptimizationTips](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fapple%2Fswift%2Fblob%2Fmain%2Fdocs%2FOptimizationTips.rst "https://github.com/apple/swift/blob/main/docs/OptimizationTips.rst")
*   [深入剖析Swift性能优化](https://link.juejin.cn?target=https%3A%2F%2Ftech.meituan.com%2F2018%2F11%2F01%2Fswift-compile-performance-optimization.html "https://tech.meituan.com/2018/11/01/swift-compile-performance-optimization.html")
*   [Google Swift Style Guide](https://link.juejin.cn?target=https%3A%2F%2Fgoogle.github.io%2Fswift%2F "https://google.github.io/swift/")
*   [Swift Evolution](https://link.juejin.cn?target=https%3A%2F%2Fapple.github.io%2Fswift-evolution%2F "https://apple.github.io/swift-evolution/")
*   [Dictionary](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswift%2Fdictionary "https://developer.apple.com/documentation/swift/dictionary")
*   [Array](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswift%2Fdictionary "https://developer.apple.com/documentation/swift/dictionary")
*   [String](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswift%2Fdictionary "https://developer.apple.com/documentation/swift/dictionary")
*   [struct](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswift%2Fchoosing_between_structures_and_classes "https://developer.apple.com/documentation/swift/choosing_between_structures_and_classes")