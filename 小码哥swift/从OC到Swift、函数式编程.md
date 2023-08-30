一、从OC到Swift
===========

1\. 标记
------

我们可以通过一些注释标记来特殊标明注释的含义

*   `// MARK:` 类似`OC`中的`#pragma mark`
*   `// MARK: -` 类似`OC`中的`#pragma mark -`
*   `// TODO:` 用于标记未完成的任务
*   `// FIXME:` 用于标记待修复的问题

使用示例如下

![-w370](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/503e1e80a2264029b79524650dc62c74~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w440](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/34ed563f13d74c0f92d8ed1336b66231~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们还可以使用`#warning`来作为警告的提示，效果更为显著

![-w714](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c05a9f610fd149389b6d9719617ab47c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2\. 条件编译
--------

![-w720](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5157980e7c574b31a5c37d39667d3c10~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们还可以在`Build Settings-> Swift Compiler -Custom Flags`自定义标记

在`Other Swift Flags`里自定义的标记要以`-D`开头

![-w716](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5a8057e99b664fd1b4125b33a0be75f0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

![-w278](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5eaf1ed438f24cda8833e9e6a2182470~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3\. 打印
------

我们可以自定义打印的内容，便于开发中的详情观察

    /*
     * msg: 打印的内容
     * file: 文件名
     * line: 所在行数
     * fn: 执行的函数名
     */
    func log<T>(_ msg: T, file: NSString = #file, line: Int = #line, fn: String = #function) {
        #if DEBUG
        let prefix = "(file.lastPathComponent)_(line)_(fn):"
        print(prefix, msg)
        #endif
    }
    
    func test() {
        log("哈哈")
    } 
    
    // 输出：
    // main.swift_66_test(): 哈哈 
    复制代码

4\. 系统的版本检测
-----------

    if #available(iOS 10, macOS 10.12, *) {
        // 对于iOS平台，只在iOS10及以上版本执行
        // 对于macOS平台，只在macOS 10.12以上版本执行
        // 最后的*表示在其他所有平台都执行
    } 
    复制代码

5\. API可用性说明
------------

    @available(iOS 10, macOS 10.12, *)
    class Person {}
    
    struct Student {
        // 旧的方法名更改，使用者用到时就会报错
        @available(*, unavailable, renamed: "study")
        func study_() {}
        func study() {}
        
        // 表示该方法在这个平台已经过期
        @available(iOS, deprecated: 11)
        @available(macOS, deprecated: 10.12)
        func run() {}
    } 
    复制代码

![-w642](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1aae54a5a9b34e69a0f5b0ad58548a54~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

更多用法参考：[docs.swift.org/swift-book/…](https://link.juejin.cn?target=https%3A%2F%2Fdocs.swift.org%2Fswift-book%2FReferenceManual%2FAttributes.html "https://link.juejin.cn?target=https%3A%2F%2Fdocs.swift.org%2Fswift-book%2FReferenceManual%2FAttributes.html")

6\. 程序入口
--------

在`AppDelegate`上面默认有个`@main`标记，这表示编译器自动生成入口代码（main函数代码），自动设置`AppDelegate`为APP的代理

![-w776](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1c7e5d9b0a024687be380d5f3e31c3ed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

之前的`Xcode`版本会生成`@UIApplicationMain`标记，和`@main`的作用一样

![-w776](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7232bfd8d235474daec8a836b6536209~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

也可以删掉`@main`或者`@UIApplicationMain`，自定义入口代码

1.创建`main.swift`文件

![-w728](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7645c407f7cf4f48a9e30d01ffc5830a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

2.去掉`AppDelegate`里的标记

![-w775](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/34896ddcd5ea4639b69827eadba0f9a1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

3.在`main.swift`里面自定义`UIApplication`并增加入口代码

![-w748](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f1cfff66a40a49c8bb4b8212148fb761~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

7\. Swift调用OC
-------------

如果我们在Swift项目中需要调用到OC的代码，需要建立一个桥接头文件，文件名格式为`{targetName}-Bridging-Header.h`

在桥接文件里引用需要的OC头文件

![-w1119](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/37741c059c2042fe91899f89c2216886~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

在`Build Setting -> Swift Compiler - General`中写好桥接文件路径

![-w849](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4598ea94c3e7465d81630f451ed8e7b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

如果我们是在Swift项目里第一次创建OC文件，`Xcode`会提示是否需要帮助创建桥接文件

![-w731](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e57cadadbef147678501a38b0aa6f9b8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

然后我们就可以在Swift文件里调用OC的代码了

![-w532](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1d68d5363bf6452d91a438f5ebae0b00~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w728](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1c2b5a1e962843c5a651b6f7107a6b1e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

如果C语言暴露给Swift的函数名和Swift中的其他函数名冲突了，可以在Swift中使用`@_silgen_name`修改C语言的函数名

    // C文件
    int sum(int a, int b) {
        return a + b;
    }
    
    // Swift文件
    func sum(_ a: Int, _ b: Int) -> Int {
        a - b
    }
    
    @_silgen_name("sum")
    func swift_sum(_ a: Int32, _ b: Int32) -> Int32
    
    print(sum(5, 6))
    print(swift_sum(5, 6)) 
    复制代码

`@_silgen_name`还可以用来调用C的私有函数

8\. OC调用Swift
-------------

我们要是想在OC文件中调用Swift代码，需要引用一个隐藏文件`{targetName}-Swift.h`

![-w847](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b7ee3e67cbd64afbafd980f77c1275ed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

Swift暴露给OC的类最终都要继承自`NSObject`

使用`@objc`修饰需要暴露给OC的成员

![-w400](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95b10b0c07a54d3bb366dbfc0603da69~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w592](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c09a72f8d1764594a8fe7abf349c3d01~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

使用`@objcMembers`修饰类，代表默认所有成员都会暴露给OC（包括扩展中定义的成员）

最终是否成功暴露，还需要考虑成员自身的权限问题

![-w496](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a03455cdbec8415ca2c8efa0cc7281c6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们进入到`test-Swift.h`里看看编译器默认帮我们转成的OC代码是怎样的

![-w722](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f3c621b1d7854c529d8596c0d4345821~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们还可以通过`@objc`来对Swift文件里的类和成员重命名，来更适应于OC的代码规范

![-w573](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9d7c4fff781e464dbfd50177c7b2a0b8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w635](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bdf387dd03044e158df292505ce6730d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

9.选择器
-----

Swift中依然可以使用选择器，使用`#selector(name)`定义一个选择器

必须是被`@objcMembers`或`@objc`修饰的方法才可以定义选择器

![-w728](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a485a1206acd4edc93cc8a20fa927aee~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

如果不加`@objcMembers`或`@objc`是会报错的

![-w777](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ffbcaad964884810b40513cba3491bcf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

10\. 混编调用的本质
------------

**我们先来思考一个问题，为什么Swift暴露给OC的类最终要继承NSObject？**

只有OC调用最后还是走的消息发送机制，要想能够实现消息机制，就需要有`isa指针`，所以要继承`NSObject`

我们在调用的地方打上断点，然后进行反汇编

![-w557](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4574b5b5d78347169f7dbe634f696c13~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们发现，反汇编内部最终调用了`objc_msgSend`，很明显是消息发送机制

![-w846](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ebd29213bfc4c6fb9fecd82a89fb3a8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**那Swift调用OC的方法，是走的消息发送机制，还是Swift本身的调用方式呢？**

我们在调用的地方打上断点，然后进行反汇编

![-w781](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3305857dbdb44dab9df8b61d78e72bc5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们发现，反汇编内部最终调用了`objc_msgSend`，很明显是消息发送机制

![-w846](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3240ca290794899999dd1d823160a82~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**暴露给OC使用的Swift函数和类，如果被Swift调用，是走的消息发送机制，还是Swift本身的调用方式呢？**

我们在调用的地方打上断点，然后进行反汇编

![-w784](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/99cab04169314f668cdd7830050e3836~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们发现，反汇编内部是按照根据元类信息里的函数地址去调用的方式，没有`Runtime`相关的调用

![-w841](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e0ad94a0f0e548079899cf2e491551e6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w847](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/17a8bb7f1d7445f0b865c5ade381ff21~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

我们可以加上`dynamic`关键字，这样不管是OC调用还是Swift调用都会走`Runtime`的消息发送机制

![-w505](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cffbba28d0e842c38114d4b205789d0c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

反汇编之后

![-w843](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ba276810bb6b4858b5ab13c4606f3bb3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

11\. String
-----------

Swift的字符串类型`String`，和OC的`NSString`，在API设计上还是有较大差异的

    // 空字符串
    var emptyStr1 = ""
    var emptyStr2 = String() 
    复制代码

    // 拼接字符串
    var str: String = "1"
    str.append("_2")
    
    // 重载运算符
    str = str + "_3"
    str += "_4"
    
    // 插值
    str = "(str)_5"
    print(str, str.count) // 1_2_3_4_5, 9 
    复制代码

    // 字符串的判断
    var str = "123456"
    print(str.hasPrefix("123")) // true
    print(str.hasSuffix("456")) // true 
    复制代码

### 11.1 String的插入和删除

    var str = "1_2"
    
    str.insert("_", at: str.endIndex) // 1_2_
    str.insert(contentsOf: "3_4", at: str.endIndex) // 1_2_3_4
    str.insert(contentsOf: "666", at: str.index(after: str.startIndex)) // 1666_2_3_4
    str.insert(contentsOf: "888", at: str.index(before: str.endIndex)) // 1666_2_3_8884
    str.insert(contentsOf: "hello", at: str.index(str.startIndex, offsetBy: 4)) // 1666hello_2_3_8884 
    复制代码

    str.remove(at: str.firstIndex(of: "1")!) // 666hello_2_3_8884
    str.removeAll { $0 == "6" } // hello_2_3_8884
        
    let range = str.index(str.endIndex, offsetBy: -4)..<str.index(before: str.endIndex)
    str.removeSubrange(range) // hello_2_3_4 
    复制代码

### 11.2 Substring

`String`可以通过`下标、prefix、suffix`等截取子串，子串类型不是`String`，而是`Substring`

    var str = "1_2_3_4_5"
    
    var substr1 = str.prefix(3) // 1_2
    var substr2 = str.suffix(3) // 4_5
    
    var range = str.startIndex..<str.index(str.startIndex, offsetBy: 3)
    var substr3 = str[range] // 1_2
    
    // 最初的String
    print(substr3.base) // 1_2_3_4_5
    
    // Substring -> String
    var str2 = String(substr3) 
    复制代码

*   `Substring`和它的`base`，共享字符串数据
*   其本质是`Substring`内部有一个指针指向`String`对应的区域
*   `Substring`发生修改或者转为`String`时，会分配新的内存存储字符串数据，不会影响到最初的`String`的内容，编译器会自动做优化 ![-w467](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6fbefa1a85e4471abcca65a83ef20b47~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

### 11.3 String与Character

    for c in "jack" { // c是Character类型
        print(c)
    } 
    复制代码

    var str = "jack"
    var c = str[str.startIndex] // c是Character类型 
    复制代码

### 11.4 String相关的协议

*   `BidirectionalCollection`协议包含的部分内容
    
    *   `startIndex`、`endIndex`属性、`index`方法
    *   `String`、`Array`都遵守了这个协议
*   `RangeReplaceableCollection`协议包含的部分内容
    
    *   `append`、`insert`、`remove`方法
    *   `String`、`Array`都遵守了这个协议
*   `Dictionary`、`Set`也有实现上述协议中声明的一些方法，只是并没有遵守上述协议
    

### 11.5 多行String

    let str = """
    1
        ”2“
    3
        '4'
    """ 
    复制代码

如果要显示3引号，至少转义1个引号

    let str = """
    Escaping the first quote """
    Escaping two quotes """
    Escaping all three quotes """
    """ 
    复制代码

以下两个字符是等价的

    let str1 = "These are the same."
    let str2 = """
    These are the same.
    """ 
    复制代码

缩进以结尾的3引号为对齐线

    let str = """
            1
                2
        3
            4
        """ 
    复制代码

### 11.6 String和NSString

*   `String`和`NSString`之间可以随时随地的桥接转换
*   如果你觉得`String`的API过于复杂难用，可以考虑将`String`转为`NSString`

    var str1: String = "jack"
    var str2: NSString = "rose"
    
    var str3 = str1 as NSString
    var str4 = str2 as String
    
    var str5 = str3.substring(with: NSRange(location: 0, length: 2))
    print(str5) // ja 
    复制代码

我们通过反汇编发现，`String`和`NSString`的转换会调用函数来实现的，相对会有性能的消耗，但由于编译器的优化，消耗的成本可以忽略不计

![-w715](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ebe0ffeb017440ad8bdba06af9d07524~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

**比较字符串内容是否等价**

*   `String`使用`==`运算符
*   `NSString`使用`isEqual`方法，也可以使用`==`运算符（本质还是调用了`isEqual`方法）

    var str1: NSString = "jack"
    var str2: String = "rose"
    var str5: String = "rose"
    var str6: NSString = "jack"
    
    print(str2 == str5)
    print(str1 == str6) 
    复制代码

通过反汇编，我们可以看到`==`运算符的本质还是调用了`isEqual`方法

![-w714](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/54a041f55100495d9d08b9ad2a82e727~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w714](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/70eb10bfdbff485d90798d2806b3fe11~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![\-w713](https://link.juejin.cn?target=https%3A%2F%2Fp3-juejin.byteimg.com%2Ftos-cn-i-k3u1fbpfcp%2Fbf842a9f550e41ea875c8b7aa0fc7fc7~tplv-k3u1fbpfcp-zoom-1.image "https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bf842a9f550e41ea875c8b7aa0fc7fc7~tplv-k3u1fbpfcp-zoom-1.image")

**下面是Swift和OC的几个类型的转换表格**

`String`和`NSString`可以相互转换，而`NSMutableString`就只能单向转换成`String`

其他类型同理

![-w506](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/045b94548fa64169ad7bbd9c1d0a839f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

12\. 只能被class继承的协议
------------------

*   如果协议对应`AnyObject、class、@objc`来修饰，那么只能被类所遵守 ![-w654](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/157c85f4208741afa8daba0486044620~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   被`@objc`修饰的协议，还可以暴露给OC去遵守协议实现

    // Swift文件
    @objc protocol Runnable4 {
        func run()
    }
    
    // OC文件
    @interface LLTest : NSObject<Runnable4>
    
    @end
    
    @implementation LLTest
    
    - (void)run { }
    @end 
    复制代码

可以通过`@objc`定义可选协议，这种协议只能被`class`遵守

    @objc protocol Runnable4 {
        func run()
        @objc optional func eat()
    }
    
    class Person: Runnable4 {
        func run() {
            print("run")
        }
    } 
    复制代码

13\. dynamic
------------

被`@objc dynamic`修饰的内容会具有动态性，比如调用方法会走`Runtime`的消息发送机制

    class Dog {
        @objc dynamic func test1() {}
        func test2() {}
    }
    
    var d = Dog()
    d.test1()
    d.test2() 
    复制代码

具体汇报调用过程可以参考上文`混编调用的本质`

14.KVC、KVO
----------

*   1.  Swift支持`KVC、KVO`的条件需要属性所在的类、监听器最终继承自`NSObject`
*   2.  用`@objc dynamic`修饰对应的属性

    class Observer: NSObject {
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            print("observeValue", change?[.newKey] as Any)
        }
    }
    
    class Person: NSObject {
        @objc dynamic var age: Int = 0
        var observer: Observer = Observer()
        
        override init() {
            super.init()
            
            addObserver(observer, forKeyPath: "age", options: .new, context: nil)
        }
        
        deinit {
            removeObserver(observer, forKeyPath: "age")
        }
    }
    
    
    var p = Person()
    p.age = 20
    p.setValue(25, forKey: "age")
    
    // Optional(20)
    // Optional(25) 
    复制代码

*   3.  `block`方式的\`KVO

    class Person: NSObject {
        @objc dynamic var age: Int = 0
        var observation: NSKeyValueObservation?
        
        override init() {
            super.init()
            
            observation = observe(\Person.age, options: .new, changeHandler: { (person, change) in
                print(change.newValue as Any)
            })
        }
    }
    
    
    var p = Person()
    p.age = 20
    p.setValue(25, forKey: "age")
    
    // Optional(20)
    // Optional(25) 
    复制代码

15\. 关联对象（Associated Object）
----------------------------

*   在Swift中，`class`依然可以使用关联对象
*   默认情况下，`extension`不可以增加存储属性
*   借助关联对象，可以实现类似`extension`为`class`增加存储属性的效果

    class Person {}
    extension Person {
        // Void类型只占一个字节
        private static var AGE_KEY: Void?
        var age: Int {
            get {
                (objc_getAssociatedObject(self, &Self.AGE_KEY) as? Int) ?? 0
            }
            
            set {
                objc_setAssociatedObject(self, &Self.AGE_KEY, newValue, .OBJC_ASSOCIATION_ASSIGN)
            }
        }
    }
    
    var p = Person()
    print(p.age) // 0
    
    p.age = 10
    print(p.age) // 10 
    复制代码

16\. 资源名管理
----------

我们日常在代码中对资源的使用如下

    let img = UIImage(named: "logo")
            
    let btn = UIButton(type: .custom)
    btn.setTitle("添加", for: .normal)
        
    performSegue(withIdentifier: "login_main", sender: self) 
    复制代码

*   我们采用`枚举`的方式对资源名进行管理
*   这种方式是参考了`Android`的资源名管理方式

    enum R {
        enum string: String {
            case add = "添加"
        }
        
        enum image: String {
            case logo
        }
        
        enum segue: String {
            case login_main
        }
    }
    
    class ViewController: UIViewController {
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let img = UIImage(named: R.image.logo)
    
            let btn = UIButton(type: .custom)
            btn.setTitle(R.string.add, for: .normal)
    
            performSegue(withIdentifier: R.segue.login_main, sender: self)
        }
    }
    
    extension UIImage {
        convenience init?(named name: R.image) {
            self.init(named: name.rawValue)
        }
    }
    
    extension UIViewController {
        func performSegue(withIdentifier identifier: R.segue, sender: Any?) {
            performSegue(withIdentifier: identifier.rawValue, sender: sender)
        }
    }
    
    extension UIButton {
        func setTitle(_ title: R.string, for state: UIControl.State) {
            setTitle(title.rawValue, for: state)
        }
    } 
    复制代码

资源名管理的其他思路

原始写法如下

    let img = UIImage(named: "logo")
    let font = UIFont(name: "Arial", size: 14)
    复制代码

    enum R {
        enum image {
            static var logo = UIImage(named: "logo")
        }
        
        enum font {
            static func arial(_ size: CGFloat) -> UIFont? {
                UIFont(name: "Arial", size: size)
            }
        }
    }
    
    class ViewController: UIViewController {
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let img = R.image.logo
            let font = R.font.arial(14)
        }
    } 
    复制代码

更多优秀的思路请参考以下链接：

*   [github.com/mac-cain13/…](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fmac-cain13%2FR.swift "https://github.com/mac-cain13/R.swift")
*   [github.com/SwiftGen/Sw…](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FSwiftGen%2FSwiftGen "https://github.com/SwiftGen/SwiftGen")

17\. 多线程开发
----------

*   利用`DispatchWorkItem`封装常用多线程执行函数

    public typealias Task = () -> Void
    
    public struct Asyncs {
        /// 异步执行
        public static func async(_ task: @escaping Task) {
            _async(task)
        }
    
        public static func async(_ task: @escaping Task,
                                 _ mainTask: @escaping Task) {
            _async(task, mainTask)
        }
        
        /// 主线程延迟执行
        @discardableResult
        public static func delay(_ seconds: Double,
                                 _ block: @escaping Task) -> DispatchWorkItem {
            let item = DispatchWorkItem(block: block)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
            
            return item
        }
        
        /// 异步延迟执行
        @discardableResult
        public static func asyncDelay(_ seconds: Double,
                                      _ task: @escaping Task) -> DispatchWorkItem {
            _asyncDelay(seconds, task)
        }
        
        @discardableResult
        public static func asyncDelay(_ seconds: Double,
                                      _ task: @escaping Task,
                                      _ mainTask: @escaping Task) -> DispatchWorkItem {
            _asyncDelay(seconds, task, mainTask)
        }
    }
    
    // MARK: - 私有API
    extension Asyncs {
        private static func _async(_ task: @escaping Task,
                                   _ mainTask: Task? = nil) {
            let item = DispatchWorkItem(block: task)
            DispatchQueue.global().async(execute: item)
            
            if let main = mainTask {
                item.notify(queue: DispatchQueue.main, execute: main)
            }
        }
        
        private static func _asyncDelay(_ seconds: Double,
                                        _ task: @escaping Task,
                                        _ mainTask: Task? = nil) -> DispatchWorkItem {
            let item = DispatchWorkItem(block: task)
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
            
            if let main = mainTask {
                item.notify(queue: DispatchQueue.main, execute: main)
            }
            
            return item
        }
    } 
    复制代码

*   `dispatch_once`在Swift中已被废弃，取而代之的是用`类型属性`或者`全局变量\常量`
*   默认自带`lazy+dispatch_once`效果

    fileprivate let initTask2: Void = {
        print("initTask2")
    }()
    
    class ViewController: UIViewController {
        static let initTask1: Void = {
            print("initTask1------------")
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            let _ = Self.initTask1
            let _ = initTask2
        }
    } 
    复制代码

*   多个线程操作同一份数据会有资源抢夺问题，需要进行加锁

    class Cache {
        private static var data = [String : Any]()
        private static var lock = DispatchSemaphore(value: 1)
        
        static func set(_ key: String, _ value: Any) {
            lock.wait()
            defer { lock.signal() }
            data[key] = value
        }
    } 
    复制代码

    private static var lock = NSLock()
    static func set(_ key: String, _ value: Any) {
        lock.lock()
        defer {
            lock.unlock()
        }
    } 
    复制代码

    private static var lock = NSRecursiveLock()
    static func set(_ key: String, _ value: Any) {
        lock.lock()
        defer {
            lock.unlock()
        }
    }
    复制代码

二、函数式编程（Funtional Programming）
==============================

1\. 基本概念
--------

函数式编程（Funtional Programming，简称FP）是一种编程范式，也就是如何编写程序的方法论

*   主要思想：把计算过程尽量分解成一系列可复用函数的调用
*   主要特征：”函数的第一等公民“，函数与其他数据类型一样的地位，可以赋值给其他变量，也可以作为函数参数、函数返回值

函数式编程最早出现在`LISP`语言，绝大部分的现代编程语言也对函数式编程做了不同程度的支持，比如`Haskell、JavaScript、Swift、Python、Kotlin、Scala`等

函数式编程中几个常用概念

*   Higher-Order Function、Function Currying
*   Functor、Applicative Functor、Monad

参考资料：

*   [adit.io/posts/2013-…](https://link.juejin.cn?target=http%3A%2F%2Fadit.io%2Fposts%2F2013-04-17-functors%2C_applicatives%2C_and_monads_in_pictures.html "http://adit.io/posts/2013-04-17-functors,_applicatives,_and_monads_in_pictures.html")
*   [mokacoding.com/blog/functo…](https://link.juejin.cn?target=https%3A%2F%2Fmokacoding.com%2Fblog%2Ffunctor-applicative-monads-in-pictures%2F "https://mokacoding.com/blog/functor-applicative-monads-in-pictures/")

2\. Array的常见操作
--------------

    var array = [1, 2, 3, 4]
    
    // map：遍历数组，可以将每个元素对应做调整变成新的元素，放入新的数组中
    var array2 = array.map { $0 * 2 } // [2, 4, 6, 8]
    
    // filter：遍历数组，选出符合条件的元素放入新的数组中
    var array3 = array.filter { $0 % 2 == 0 }
    
    // reduce：首先设定一个初始值（0）
    // $0：上一次遍历返回的结果（0，1，3，10）
    //$1：每次遍历到的数组元素（1，2，3，4）
    var array4 = array.reduce(0) { $0 + $1 } // 10
    var array5 = array.reduce(0, +) // 同array4一样 
    复制代码

    var array = [1, 2, 3, 4]
    func double(_ i: Int) -> Int { i * 2 }
    
    print(array.map(double)) // [2, 4, 6, 8]
    print(array.map { double($0) }) // [2, 4, 6, 8]
    复制代码

*   1.  `map`和`flatMap、compactMap`的区别
    
        var arr = [1, 2, 3]
        var arr2 = arr.map { Array(repeating: $0, count: $0) } // [[1], [2, 2], [3, 3, 3]]
        
        // flatMap会将处理完的新元素都放在同一个数组中
        var arr3 = arr.flatMap { Array(repeating: $0, count: $0) } // [1, 2, 2, 3, 3, 3]
        复制代码
    
        var arr = ["123", "test", "jack", "-30"]
        var arr1 = arr.map { Int($0) } // [Optional(123), nil, nil, Optional(-30)]
        var arr2 = arr.compactMap { Int($0) } // [123, -30]
        var arr3 = arr.flatMap(Int.init)
        复制代码
    
*   2.  使用`reduce`分别实现`map、filter`功能
    
        var arr = [1, 2, 3, 4]
        
        // map
        var arr1 = arr.map { $0 * 2 }
        print(arr1)
        
        var arr2 = arr.reduce([]) { $0 + [$1 * 2] }
        print(arr1)
        
        // filter
        var arr3 = arr.filter { $0 % 2 == 0 }
        print(arr3)
        
        var arr4 = arr.reduce([]) { $1 % 2 == 0 ? $0 + [$1] : $0 }
        print(arr4) 
        复制代码
    
*   3.  `lazy`的优化
    
        let arr = [1, 2, 3]
        
        let result = arr.lazy.map { (i: Int) -> Int in
            print("mapping (i)")
            return i * 2
        }
        
        print("begin-----")
        print("mapped", result[0])
        print("mapped", result[1])
        print("mapped", result[2])
        print("end-----")
        
        //begin-----
        //mapping 1
        //mapped 2
        //mapping 2
        //mapped 4
        //mapping 3
        //mapped 6
        //end----- 
        复制代码
    
*   4.  `Optional`的`map`和`flatMap`  
        会先将可选类型解包，处理完会再进行包装返回出去
    
        var num1: Int? = 10
        var num2 = num1.map { $0 * 2 } // Optional(20)
        
        var num3: Int? = nil
        var num4 = num3.map { $0 * 2 } // nil
        复制代码
    
        var num1: Int? = 10
        var num2 = num1.map { Optional.some($0 * 2) } // Optional(Optional(20))
        
        //flatMap发现其为可选项，不会再进行包装
        var num3 = num1.flatMap { Optional.some($0 * 2) } // Optional(20)
        var num4 = num1.flatMap { $0 * 2 } // Optional(20)
        复制代码
    
        var num1: Int? = 10
        var num2 = (num1 != nil) ? (num1! + 10) : nil // Optional(20)
        var num3 = num1.map { $0 + 10 } // Optional(20)
        复制代码
    
        var fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        var str: String? = "2011-09-10"
        var date1 = str != nil ? fmt.date(from: str!) : nil // Optional(2011-09-09 16:00:00 +0000)
        var date2 = str.flatMap(fmt.date) // Optional(2011-09-09 16:00:00 +0000)
        复制代码
    
        var score: Int? = 98
        var str1 = score != nil ? "score is (score!)" : "No score" // score is 98
        var str2 = score.map { "score is ($0)"} ?? "No score" // score is 98
        复制代码
    
        struct Person {
            var name: String
            var age: Int
        }
        
        var items = [
            Person(name: "jack", age: 20),
            Person(name: "rose", age: 21),
            Person(name: "kate", age: 22)
        ]
        
        func getPerson1(_ name: String) -> Person? {
            // 遍历数组找到对应的索引
            let index = items.firstIndex { $0.name == name }
            return index != nil ? items[index!] : nil
        }
        
        func getPerson2(_ name: String) -> Person? {
            items.firstIndex { $0.name == name }
                .map { items[$0] }
        }
        
        let p1 = getPerson1("rose")
        let p2 = getPerson2("rose")
        复制代码
    
        struct Person {
            var name: String
            var age: Int
        
            init?(_ json: [String : Any]) {
                guard let name = json["name"] as? String,
                      let age = json["age"] as? Int else { return nil }
        
                self.name = name
                self.age = age
            }
        }
        
        var json: Dictionary? = ["name" : "Jack", "age" : 10]
        var p1 = json != nil ? Person(json!) : nil // Optional(__lldb_expr_36.Person(name: "Jack", age: 10)) 
        var p2 = json.flatMap(Person.init) // Optional(__lldb_expr_36.Person(name: "Jack", age: 10))
        复制代码
    

3\. 函数式的写法
----------

*   假如要实现以下功能: `[(num + 3) * 5 - 1] % 10 / 2`
*   传统写法

    var num = 1
    
    func add(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
    func sub(_ v1: Int, _ v2: Int) -> Int { v1 - v2 }
    func multiple(_ v1: Int, _ v2: Int) -> Int { v1 * v2 }
    func divide(_ v1: Int, _ v2: Int) -> Int { v1 / v2 }
    func mod(_ v1: Int, _ v2: Int) -> Int { v1 % v2 }
    
    divide(mod(sub(multiple(add(num, 3), 5), 1), 10), 2)
    复制代码

*   函数式写法

    func add(_ v: Int) -> (Int) -> Int {{ $0 + v }}
    func sub(_ v: Int) -> (Int) -> Int {{ $0 - v }}
    func multiple(_ v: Int) -> (Int) -> Int {{ $0 * v }}
    func divide(_ v: Int) -> (Int) -> Int {{ $0 / v }}
    func mod(_ v: Int) -> (Int) -> Int {{ $0 % v }}
    
    infix operator >>> : AdditionPrecedence
    func >>><A, B, C>(_ f1: @escaping (A) -> B,
                      _ f2: @escaping (B) -> C) -> (A) -> C {{ f2(f1($0)) }}
    
    var fn = add(3) >>> multiple(5) >>> sub(1) >>> mod(10) >>> divide(2)
    fn(num) 
    复制代码

4\. 高阶函数（Higher-Order Function）
-------------------------------

高阶函数至少满足下列一个条件的函数：

*   接受一个或多个函数作为输入（map、filter、reduce等）
*   返回一个函数

FP中到处都是高阶函数

5.柯里化（Currying）
---------------

*   什么是柯里化？
*   将一个接受多参数的函数变换为一系列只接受单个参数的函数 ![-w633](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c65a4b56a69341e4831147a7e9b8de02~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)
*   `Array、Optional`的`map`方法接收的参数就是一个柯里化函数 ![-w619](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e3c435264b624d8bb4f46d786935e08e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

演变示例

    func add(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
    add(2 + 4)
    
    变为函数式的写法：
    
    func add(_ v2: Int) -> (Int) -> Int {
        return { v1 in
            return v1 + v2
        }
    }
    
    add(4)(2)
    
    再精简：
    
    func add(_ v2: Int) -> (Int) -> Int {{ v1 in v1 + v2 }}
    add(4)(2)
    
    再精简：
    
    func add(_ v: Int) -> (Int) -> Int {{ $0 + v }}
    add(4)(2)
    
    柯里化：
    
    func currying<A, B, C>(_ fn: @escaping (A, B) -> C) -> (B) -> (A) -> C {{ b in { a in fn(a, b) }}}
    
    let curriedAdd = currying(add)
    print(curriedAdd(4)(2)) 
    复制代码

    func add(_ v1: Int, _ v2: Int, _ v3: Int) -> Int { v1 + v2 + v3 }
    add(2, 3, 5)
    
    变为函数式的写法：
    
    func add(_ v3: Int) -> (Int) -> (Int) -> Int {
        // v2是3
        return { v2 in
            // v1是2
            return { v1 in
                return v1 + v2 + v3
            }
        }
    }
    
    add(5)(3)(2)
    
    再精简：
    
    func add(_ v3: Int) -> (Int) -> (Int) -> Int {{ v2 in { v1 in v1 + v2 + v3 }}}
    
    add(5)(3)(2)
    
    柯里化：
    
    func currying<A, B, C, D>(_ fn: @escaping (A, B, C) -> D) -> (C) -> (B) -> (A) -> D {{ c in { b in { a in fn(a, b, c) }}}}
    
    let curriedAdd = currying(add)
    print(curriedAdd(10)(20)(30)) 
    复制代码

一开始的示例就可以都保留旧的方法，然后通过柯里化来调用

    func add(_ v1: Int, _ v2: Int) -> Int { v1 + v2 }
    func sub(_ v1: Int, _ v2: Int) -> Int { v1 - v2 }
    func multiple(_ v1: Int, _ v2: Int) -> Int { v1 * v2 }
    func divide(_ v1: Int, _ v2: Int) -> Int { v1 / v2 }
    func mod(_ v1: Int, _ v2: Int) -> Int { v1 % v2 }
    
    prefix func ~<A, B, C>(_ fn: @escaping (A, B) -> C) -> (B) -> (A) -> C {{ b in { a in fn(a, b) }}}
    
    infix operator >>> : AdditionPrecedence
    func >>><A, B, C>(_ f1: @escaping (A) -> B,
                      _ f2: @escaping (B) -> C) -> (A) -> C {{ f2(f1($0)) }}
    
    var num = 1
    var fn = (~add)(3) >>> (~multiple)(5) >>> (~sub)(1) >>> (~mod)(10) >>> (~divide)(2)
    fn(num) 
    复制代码

6.函子（Functor）
-------------

*   像`Array、Optional`这样支持`map运算`的类型，称为函子（Functor） ![-w619](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a65a70a9420e450e888edc51d3ce8fd2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp) ![-w601](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3dc25bf331ae44c99d28f270dec602bf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

下图充分解释了函子

![-w910](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b3eff77056f149afac3c5e1a2c6b7304~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp)

7\. 适用函子（Applicative Functor）
-----------------------------

对任意一个函子`F`，如果能支持以下运算，该函子就是一个适用函子

    func pure<A>(_ value: A) -> F<A>
    func <*><A, B>(fn: F<(A) -> B>, value: F<A>) -> F<B>
    复制代码

*   `Optional`可以成为适用函子

    func pure<A>(_ value: A) -> A? { value }
    
    infix operator <*> : AdditionPrecedence
    func <*><A, B>(fn: ((A) -> B)?, value: A?) -> B? {
        guard let f = fn, let v = value else { return nil }
        return f(v)
    }
    
    var value: Int? = 10
    var fn: ((Int) -> Int)? = { $0 * 2 }
    print(fn <*> value as Any) // Optional(20)
    复制代码

*   `Array`可以成为适用函子

    func pure<A>(_ value: A) -> [A] { [value] }
    
    infix operator <*> : AdditionPrecedence
    func <*><A, B>(fn: [(A) -> B], value: [A]) -> [B] {
        var arr: [B] = []
        if fn.count == value.count {
            for i in fn.startIndex..<fn.endIndex {
                arr.append(fn[i](value[i]))
            }
        }
        
        return arr
    }
    
    print(pure(10)) // [10]
    
    var arr = [{ $0 * 2 }, { $0 + 10 }, { $0 - 5 }] <*> [1, 2 , 3]
    print(arr) // [2, 12, -2]
    复制代码

8.单子（Monad）
-----------

对任意一共类型`F`，如果能支持以下运算，那么就可以称为是一个单子

    func pure<A>(_ value: A) -> F<A>
    func flatMap<A, B>(_ value: F<A>, _ fn: (A) -> F<B>) -> F<B>
    复制代码

很显然，`Array、Optional`都是单子