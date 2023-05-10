# Swift5应用实践常用技术点

一、概述
====

最近刚好有空,趁这段时间,复习一下`Swift5`核心语法,进行知识储备,以供日后温习 和 进一步探索`Swift`语言的底层原理做铺垫。

本文继前三篇文章复习:

*   [Swift5核心语法1-基础语法](https://juejin.cn/post/7119020967430455327 "https://juejin.cn/post/7119020967430455327")
*   [Swift5核心语法2-面向对象语法1](https://juejin.cn/post/7119510159109390343 "https://juejin.cn/post/7119510159109390343")
*   [Swift5核心语法2-面向对象语法2](https://juejin.cn/post/7119513630550261774 "https://juejin.cn/post/7119513630550261774")
*   [Swift5常用核心语法3-其它常用语法](https://juejin.cn/post/7119714488181325860 "https://juejin.cn/post/7119714488181325860")
*   我们通过本文继续复习`Swift5应用实践常用技术要点` ![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a03e517565e54fa6895098e060598486~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?)

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

专题系列文章
======

### 1.前知识

*   **[01-探究iOS底层原理|综述](https://juejin.cn/post/7089043618803122183/ "https://juejin.cn/post/7089043618803122183/")**
*   **[02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】](https://juejin.cn/post/7093842449998561316/ "https://juejin.cn/post/7093842449998561316/")**
*   **[03-探究iOS底层原理|LLDB](https://juejin.cn/post/7095079758844674056 "https://juejin.cn/post/7095079758844674056")**
*   **[04-探究iOS底层原理|ARM64汇编](https://juejin.cn/post/7115302848270696485/ "https://juejin.cn/post/7115302848270696485/")**

### 2\. 基于OC语言探索iOS底层原理

*   **[05-探究iOS底层原理|OC的本质](https://juejin.cn/post/7094409219361193997/ "https://juejin.cn/post/7094409219361193997/")**
*   **[06-探究iOS底层原理|OC对象的本质](https://juejin.cn/post/7094503681684406302 "https://juejin.cn/post/7094503681684406302")**
*   **[07-探究iOS底层原理|几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质](https://juejin.cn/post/7096087582370431012 "https://juejin.cn/post/7096087582370431012")**
*   **[08-探究iOS底层原理|Category底层结构、App启动时Class与Category装载过程、load 和 initialize 执行、关联对象](https://juejin.cn/post/7096480684847415303 "https://juejin.cn/post/7096480684847415303")**
*   **[09-探究iOS底层原理|KVO](https://juejin.cn/post/7115318628563550244/ "https://juejin.cn/post/7115318628563550244/")**
*   **[10-探究iOS底层原理|KVC](https://juejin.cn/post/7115320523805949960/ "https://juejin.cn/post/7115320523805949960/")**
*   **[11-探究iOS底层原理|探索Block的本质|【Block的数据类型(本质)与内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用】](https://juejin.cn/post/7115809219319693320/ "https://juejin.cn/post/7115809219319693320/")**
*   **[12-探究iOS底层原理|Runtime1【isa详解、class的结构、方法缓存cache\_t】](https://juejin.cn/post/7116103432095662111 "https://juejin.cn/post/7116103432095662111")**
*   **[13-探究iOS底层原理|Runtime2【消息处理(发送、转发)&&动态方法解析、super的本质】](https://juejin.cn/post/7116147057739431950 "https://juejin.cn/post/7116147057739431950")**
*   **[14-探究iOS底层原理|Runtime3【Runtime的相关应用】](https://juejin.cn/post/7116291178365976590/ "https://juejin.cn/post/7116291178365976590/")**
*   **[15-探究iOS底层原理|RunLoop【两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer】](https://juejin.cn/post/7116515606597206030/ "https://juejin.cn/post/7116515606597206030/")**
*   **[16-探究iOS底层原理|RunLoop的应用](https://juejin.cn/post/7116521653667889165/ "https://juejin.cn/post/7116521653667889165/")**
*   **[17-探究iOS底层原理|多线程技术的底层原理【GCD源码分析1:主队列、串行队列&&并行队列、全局并发队列】](https://juejin.cn/post/7116821775127674916/ "https://juejin.cn/post/7116821775127674916/")**
*   **[18-探究iOS底层原理|多线程技术【GCD源码分析1:dispatch\_get\_global\_queue与dispatch\_(a)sync、单例、线程死锁】](https://juejin.cn/post/7116878578091819045 "https://juejin.cn/post/7116878578091819045")**
*   **[19-探究iOS底层原理|多线程技术【GCD源码分析2:栅栏函数dispatch\_barrier\_(a)sync、信号量dispatch\_semaphore】](https://juejin.cn/post/7116897833126625316 "https://juejin.cn/post/7116897833126625316")**
*   **[20-探究iOS底层原理|多线程技术【GCD源码分析3:线程调度组dispatch\_group、事件源dispatch Source】](https://juejin.cn/post/7116898446358888485/ "https://juejin.cn/post/7116898446358888485/")**
*   **[21-探究iOS底层原理|多线程技术【线程锁：自旋锁、互斥锁、递归锁】](https://juejin.cn/post/7116898868737867789/ "https://juejin.cn/post/7116898868737867789/")**
*   **[22-探究iOS底层原理|多线程技术【原子锁atomic、gcd Timer、NSTimer、CADisplayLink】](https://juejin.cn/post/7116907029465137165 "https://juejin.cn/post/7116907029465137165")**
*   **[23-探究iOS底层原理|内存管理【Mach-O文件、Tagged Pointer、对象的内存管理、copy、引用计数、weak指针、autorelease](https://juejin.cn/post/7117274106940096520 "https://juejin.cn/post/7117274106940096520")**

### 3\. 基于Swift语言探索iOS底层原理

关于`函数`、`枚举`、`可选项`、`结构体`、`类`、`闭包`、`属性`、`方法`、`swift多态原理`、`String`、`Array`、`Dictionary`、`引用计数`、`MetaData`等Swift基本语法和相关的底层原理文章有如下几篇:

*   [Swift5核心语法1-基础语法](https://juejin.cn/post/7119020967430455327 "https://juejin.cn/post/7119020967430455327")
*   [Swift5核心语法2-面向对象语法1](https://juejin.cn/post/7119510159109390343 "https://juejin.cn/post/7119510159109390343")
*   [Swift5核心语法2-面向对象语法2](https://juejin.cn/post/7119513630550261774 "https://juejin.cn/post/7119513630550261774")
*   [Swift5常用核心语法3-其它常用语法](https://juejin.cn/post/7119714488181325860 "https://juejin.cn/post/7119714488181325860")
*   [Swift5应用实践常用技术点](https://juejin.cn/post/7119722433589805064 "https://juejin.cn/post/7119722433589805064")

其它底层原理专题
========

### 1.底层原理相关专题

*   [01-计算机原理|计算机图形渲染原理这篇文章](https://juejin.cn/post/7018755998823219213 "https://juejin.cn/post/7018755998823219213")
*   [02-计算机原理|移动终端屏幕成像与卡顿 ](https://juejin.cn/post/7019117942377807908 "https://juejin.cn/post/7019117942377807908")

### 2.iOS相关专题

*   [01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理](https://juejin.cn/post/7019193784806146079 "https://juejin.cn/post/7019193784806146079")
*   [02-iOS底层原理|iOS动画渲染原理](https://juejin.cn/post/7019200157119938590 "https://juejin.cn/post/7019200157119938590")
*   [03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理](https://juejin.cn/post/7019497906650497061/ "https://juejin.cn/post/7019497906650497061/")
*   [04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案](https://juejin.cn/post/7020613901033144351 "https://juejin.cn/post/7020613901033144351")

### 3.webApp相关专题

*   [01-Web和类RN大前端的渲染原理](https://juejin.cn/post/7021035020445810718/ "https://juejin.cn/post/7021035020445810718/")

### 4.跨平台开发方案相关专题

*   [01-Flutter页面渲染原理](https://juejin.cn/post/7021057396147486750/ "https://juejin.cn/post/7021057396147486750/")

### 5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较

*   [01-Native、WebApp、跨平台开发三种方案性能比较](https://juejin.cn/post/7021071990723182606/ "https://juejin.cn/post/7021071990723182606/")

### 6.Android、HarmonyOS页面渲染专题

*   [01-Android页面渲染原理](https://juejin.cn/post/7021840737431978020/ "https://juejin.cn/post/7021840737431978020/")
*   [02-HarmonyOS页面渲染原理](# "#") (`待输出`)

### 7.小程序页面渲染专题

*   [01-小程序框架渲染原理](https://juejin.cn/post/7021414123346853919 "https://juejin.cn/post/7021414123346853919")