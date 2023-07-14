七、String、Array的底层分析
===================

1\. String
----------

### 1.1 关于String的思考

> **我们先来思考String变量`占用多少内存`？**

swift

复制代码

`var str1 = "0123456789"
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xea00000000003938` 

*   1.  我们通过打印可以看到`String变量`占用了`16`个字节，并且打印内存布局，前后各占用了`8个字节`
*   2.  下面我们再进行`反汇编`来观察下:  
        可以看到这两句指令正是分配了前后8个字节给了`String变量` ![-w715](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6660d592d9af43a891376332ffd407f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

> **那String变量底层`存储的是什么`呢？**

*   1.  我们通过上面看到`String变量`的16个字节的值其实是对应转成的`ASCII码值`
*   2.  ASCII码表的地址：[www.ascii-code.com](https://link.juejin.cn?target=https%3A%2F%2Fwww.ascii-code.com "https://www.ascii-code.com") ![-w1139](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3e0acfa1dfc44f2bb9b58b0d2d7f9b0~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  我们看上图就可以得知:
    
    *   左边对应的是`0~9`的十六进制`ASCII码值`
    *   又因为`小端模式(高高低低)`下高字节放高地址，低字节放低地址的原则，对比正是我们打印的16个字节中存储的数据
        
        swift
        
        复制代码
        
        `0x3736353433323130 0xea00000000003938` 
        

> **然后我们再看后8个字节前面的`e`和`a`分别代表的是`类型`和`长度`**

*   如果`String`的数据是`直接存储在变量中`的,就是用`e`来标明类型
*   如果要是`存储在其他地方`,就会`用别的字母来表示`
*   我们`String`字符的长度正好是10，所以就是十六进制的`a`

swift

复制代码

`var str1 = "0123456789ABCDE"
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xef45444342413938` 

*   我们打印上面这个`String变量`，发现表示长度的值正好变成了`f`
*   而后7个字节也都被填满了，所以也证明了这种方式最多只能存储15个字节的数据
*   这种方式很像`OC`中的`Tagger Pointer`的存储方式

> **如果存储的数据超过15个字符，String变量又会是什么样呢？**

*   我们改变`String变量`的值，再进行打印观察

swift

复制代码

`var str1 = "0123456789ABCDEF"
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0xd000000000000010 0x80000001000079a0` 

*   我们发现`String变量`的内存占用还是16个字节，但是内存布局已经完全不一样了
*   这时我们就需要借助反汇编来进一步分析了: ![-w998](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5755335330d5408787db631d057a1c08~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   看上图能发现最后还是会先后分配`8个字节`给`String变量`，但不同的是在这之前会调用了函数，并将返回值给了`String变量`的`前8个字节`
*   而且分别将`字符串`的值还有长度作为参数传递了进去，下面我们就看看调用的函数里具体做了什么 ![-w995](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/104ab1a55d59499280f28b37fcf21205~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w1058](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e7ba4e15d1e14911815c30f9f02d007a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   我们可以看到函数内部会将一个`掩码`的值和`String变量`的地址值相加，然后存储到`String变量`的后8个字节中
*   所以我们可以反向计算出所存储的数据真实地址值

swift

复制代码

`0x80000001000079a0 - 0x7fffffffffffffe0 = 0x1000079C0` 

*   其实也就是一开始存储到`rdi`中的值 ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c8be70d3fa449fa85d744375cabd040~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
    *   通过打印真实地址值可以看到16个字节确实都是存储着对应的`ASCII码值`

> **那么真实数据是存储在什么地方呢？**

*   通过观察它的地址我们可以大概推测是在`数据段`
*   为了更确切的认证我们的推测，使用`MachOView`来直接查看在可执行文件中这句代码的真正存储位置
*   我们找到项目中的可执行文件，然后右键`Show in Finder` ![-w357](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b9e34e897cad43a7aaf099869e9c9b59~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   然后右键通过`MachOView`的方式来打开 ![-w498](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1ce3b7c154d14f1493081d48953f99f5~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   最终我们发现在代码段中的字符串`常量区`中 ![-w1055](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/438688bb7e5a408e9c8302391914e0cd~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

> **对比两个字符串的存储位置**

*   我们现在分别查看下这两个字符串的存储位置是否相同

swift

复制代码

`var str1 = "0123456789"
var str2 = "0123456789ABCDEF"` 

*   我们还是用`MachOView`来打开可执行文件，发现两个字符串的真实地址都是放在代码段中的`字符串常量区`，并且相差`16个字节` ![-w1165](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/06b26919bbde4b98b028c96d686bc17e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   然后我们再看打印的地址的前8个字节

swift

复制代码

`0xd000000000000010 0x80000001000079a0` 

*   按照推测`10`应该也是表示长度的十六进制，而前面的`d`就代表着这种类型
*   我们更改下字符串的值，发现果然表示长度的值也随之变化了

swift

复制代码

`var str2 = "0123456789ABCDEFGH"
print(Mems.size(ofVal: &str2)) // 16
print(Mems.memStr(ofVal: &str2)) // 0xd000000000000012 0x80000001000079a0` 

> **如果分别给两个String变量进行拼接会怎样呢？**

swift

复制代码

`var str1 = "0123456789"
str1.append("G")
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xeb00000000473938
var str2 = "0123456789ABCDEF"
str2.append("G")
print(Mems.size(ofVal: &str2)) // 16
print(Mems.memStr(ofVal: &str2)) // 0xf000000000000011 0x0000000100776ed0` 

*   我们发现str1的后8个字节还有位置可以存放新的字符串，所以还是继续存储在内存变量里
*   而str2的内存布局不一样了，前8个字节可以看出来类型变成`f`，字符串长度也变为十六进制的`11`；
*   而后8个字节的地址很像`堆空间`的地址值

> **验证String变量的存储位置是否在堆空间**

*   为了验证我们的推测，下面用反汇编来进行观察
*   我们在验证之前先创建一个类的实例变量，然后跟进去在内部调用`malloc`的指令位置打上断点

swift

复制代码

`class Person { }
var p = Person()` 

![-w979](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/280785045b49499fb719596615a8d313~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   然后我们先将断点置灰，重新反汇编之前的`Sting变量` ![-w979](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bc12e07e8ae42f5bff7642c2af48169~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   然后将置灰的`malloc`的断点点亮，然后进入 ![-w978](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/efca144df3804ed08d949b79aca7f1b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   发现确实会进入到我们之前在调用`malloc`的断点处，所以这就验证了确实会分配堆空间内存来存储`String变量`的值了
*   我们还可以用`LLDB`的指令`bt`来打印调用栈详细信息来查看 ![-w979](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2d9a75d0d4cb4d7791e9baf68910218f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   发现也是在调用完`append方法`之后就会进行`malloc`的调用了，从这一层面也验证了我们的推测

> **那堆空间里存储的str2的值是怎样的呢？**

*   然后我们过掉了`append函数`后，打印str2的地址值，然后再打印后8个字节存放的堆空间地址值 ![-w981](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1b804928b02f43fdbe4d7364359a24db~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   其内部偏移了`32个字节`后，正是我们`String变量`的`ASCII码值`

### 1.2 总结

*   1.  **如果字符串长度小于等于0xF（十进制为15）**,字符串内容直接存储到字符串变量的内存中，并以`ASCII`码值的**小端模式来进行存储**
*   `第9个字节`会存储字符串`变量的类型`和`字符长度`

swift

复制代码

`var str1 = "0123456789"
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xeb00000000473938` 

> **进行字符串拼接操作后**

*   2.  **如果拼接后的字符串长度还是`小于等于`0xF（十进制为15）** ,存储位置同未拼接之前

swift

复制代码

`var str1 = "0123456789"
str1.append("ABCDE")
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0x3736353433323130 0xef45444342413938` 

*   3.  **如果拼接后的字符串长度`大于`0xF（十进制为15）**,会`开辟堆空间`来存储字符串内容
*   字符串的地址值中:
*   `前8个字节`存储`字符串变量的类型`和`字符长度`
*   `后8个字节`存储着`堆空间的地址值`，`堆空间地址 + 0x20`可以得到`真正的字符串内容`
*   堆空间地址的`前32个字节`是用来`存储描述信息`的
*   由于`常量区`是程序运行之前就已经确定位置了的,所以拼接字符串是运行时操作,不可能再回存放到常量区,所以`直接分配堆空间`进行存储

swift

复制代码

`var str1 = "0123456789"
str1.append("ABCDEF")
print(Mems.size(ofVal: &str1)) // 16
print(Mems.memStr(ofVal: &str1)) // 0xf000000000000010 0x000000010051d600` 

*   4.  **如果字符串长度大于0xF（十进制为15）** , 字符串内容会存储在`__TEXT.cstring`中（常量区）
*   字符串的地址值中，`前8个字节`存储字符串变量的类型和字符长度，`后8个字节`存储着一个地址值，`地址值 & mask`可以得到字符串内容在常量区真正的地址值

swift

复制代码

`var str2 = "0123456789ABCDEF"
print(Mems.size(ofVal: &str2)) // 16
print(Mems.memStr(ofVal: &str2)) // 0xd000000000000010 0x80000001000079a0` 

*   5.  **进行字符串拼接操作后**，同上面开辟`堆空间`存储的方式

swift

复制代码

`var str2 = "0123456789ABCDEF"
str2.append("G")
print(Mems.size(ofVal: &str2)) // 16
print(Mems.memStr(ofVal: &str2)) // 0xf000000000000011 0x0000000106232230` 

### 1.3 dyld\_stub\_binder

*   1.  我们反汇编看到底层调用的`String.init`方法其实是`动态库`里的方法，而动态库在内存中的位置是在`Mach-O文件`的更高地址的位置，如下图所示 ![-w939](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/93c7a01e241b41249b9baa0f3a3c1e6a~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   2.  所以我们这里看到的地址值其实是一个`假的地址值`，`只是用来占位的` ![-w999](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5d8bba1b0e54694b76952752cc2c49b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   我们再跟进发现其内部会跳转到另一个地址，取出其存储的真正需要调用的地址值去调用
*   下一个调用的地址值一般都是相差6个字节

swift

复制代码

`0x10000774e + 0x6 = 0x100007754
0x100007754 + 0x48bc(%rip) = 0x10000C010
最后就是去0x10000C010地址中找到需要调用的地址值0x100007858` 

![-w998](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5afbe8541244d9dab7347755bde2656~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w997](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3a48c418233d4ade9c0c935b1d3ed5c6~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

*   3\. 然后一直跟进，最后会进入到动态库的`dyld_stub_binder`中进行绑定 ![-w996](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8bb1f99041f24e3080de780b8405998c~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  最后才会真正进入到动态库中的`String.init`执行指令，而且可以发现其真正的地址值非常大，这也能侧面证明动态库是在可执行文件更高地址的位置 ![-w1000](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ffcbe445b3e94cf2ac38865229bfc08d~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   5.  然后我们在执行到下一个`String.init`的调用 ![-w997](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/98f566de85184723a9edf493e4d5678e~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   6.  跟进去发现这是要跳转的地址值就已经是动态库中的`String.init`真实地址值了 ![-w997](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e5179fdfdc2b4ad3ac626492ded5b6f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp) ![-w999](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2df7d588ff9444c9ab6805413b925c62~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   7.  这也说明了`dyld_stub_binder`只会执行一次，而且是用到的时候在进行调用，也就是延迟绑定
*   8.  `dyld_stub_binder`的主要作用就是在程序运行时，将真正需要调用的函数地址替换掉之前的占位地址

2\. 关于Array的思考
--------------

> **我们来思考Array变量占用多少内存？**

swift

复制代码

`var array = [1, 2, 3, 4]
print(Mems.size(ofVal: &array)) // 8
print(Mems.ptr(ofVal: &array)) // 0x000000010000c1c8
print(Mems.ptr(ofRef: array)) // 0x0000000105862270` 

*   1.  我们通过打印可以看到`Array变量`占用了`8个字节`，其内存地址就是存储在`全局区`的地址
*   2.  然而我们发现其内存地址的存储空间存储的地址值更像一个堆空间的地址

> **Array变量存储在什么地方呢？**

*   3.带着疑问我们还是进行反汇编来观察下，并且在`malloc`的调用指令处打上断点 ![-w988](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/485f28a97e604a2eb8bf1c16ad4ec132~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   发现确实调用了`malloc`，那么就证明了`Array变量`内部会分配堆空间 ![-w1000](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b36e7c6d60d44389c801ec6a03ddd13~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  等执行完返回值给到`Array变量`之后，我们打印`Array变量`存储的地址值内存布局，发现其内部`偏移32个字节`的位置存储着元素1、2、3、4
*   我们还可以直接通过打印内存结构来观察
    
    swift
    
    复制代码
    
    `var array = [1, 2, 3, 4]
    print(Mems.memStr(ofRef: array))
    //0x00007fff88a8dd18
    //0x0000000200000003
    //0x0000000000000004
    //0x0000000000000008
    //0x0000000000000001
    //0x0000000000000002
    //0x0000000000000003
    //0x0000000000000004` 
    
*   我们调整一下元素数量，再打印观察
    
    swift
    
    复制代码
    
    `var array = [Int]()
    for i in 1...8 {
     array.append(i)
    }
    print(Mems.memStr(ofRef: array))
    //0x00007fff88a8e460
    //0x0000000200000003
    //0x0000000000000008
    //0x0000000000000010
    //0x0000000000000001
    //0x0000000000000002
    //0x0000000000000003
    //0x0000000000000004
    //0x0000000000000005
    //0x0000000000000006
    //0x0000000000000007
    //0x0000000000000008` 
    

八、高级运算符
=======

1\. 溢出运算符（Overflow Operator）
----------------------------

*   1.  Swift的算数运算符出现溢出时会抛出运行时错误
*   2.  Swift有溢出运算符`&+、&-、&*`，用来支持溢出运算 ![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6978fad6d78746afae3d0c5a5cdeaf20~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp?)

swift

复制代码

`var min = UInt8.min
print(min &- 1) // 255, Int8.max
var max = UInt8.max
print(max &+ 1) // 0, Int8.min
print(max &* 2) // 254, 等价于 max &+ max、` 

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/92913b09c78f4c9d8f1b5abb6aecbda9~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp?)

> **计算方式**

*   1.  类似于一个循环，最大值255再+1，就会回到0；最小值0再-1，就会回到255
*   2.  而`max &* 2`就等于`max &+ max`，也就是255 + 1 + 254，255 + 1会变为0，那么最后的值就是254 ![-w596](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/052d8810d49e4f789585499c901372a4~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

2\. 运算符重载（Operator Overload）
----------------------------

*   1.  `类`、`结构体`、`枚举`可以为现有的运算符提供自定义的实现，这个操作叫做`运算符重载`

swift

复制代码

`struct Point {
 var x: Int, y: Int
}
func + (p1: Point, p2: Point) -> Point {
 Point(x: p1.x + p2.x, y: p1.y + p2.y)
}
let p = Point(x: 10, y: 20) + Point(x: 11, y: 22)
print(p) // Point(x: 21, y: 42) Point(x: 11, y: 22)` 

*   2.  一般将运算符重载写在相关的`结构体`、`类`、`枚举`的内部

swift

复制代码

`struct Point {
 var x: Int, y: Int
 // 默认就是中缀运算符
 static func + (p1: Point, p2: Point) -> Point {
 Point(x: p1.x + p2.x, y: p1.y + p2.y)
 }
 static func - (p1: Point, p2: Point) -> Point {
 Point(x: p1.x - p2.x, y: p1.y - p2.y)
 }
 // 前缀运算符
 static prefix func - (p: Point) -> Point {
 Point(x: -p.x, y: -p.y)
 }
 static func += (p1: inout Point, p2: Point) {
 p1 = p1 + p2
 }
 static prefix func ++ (p: inout Point) -> Point {
 p += Point(x: 1, y: 1)
 return p
 }
 // 后缀运算符
 static postfix func ++ (p: inout Point) -> Point {
 let tmp = p
 p += Point(x: 1, y: 1)
 return tmp
 }
 static func == (p1: Point, p2: Point) -> Bool {
 (p1.x == p2.x) && (p1.y == p2.y)
 }
}
var p1 = Point(x: 10, y: 20)
var p2 = Point(x: 11, y: 22)
print(p1 + p2) // Point(x: 21, y: 42)
print(p2 - p1) // Point(x: 1, y: 2)
print(-p1) // Point(x: -10, y: -20)
p1 += p2
print(p1, p2) // Point(x: 21, y: 42) Point(x: 11, y: 22)
p1 = ++p2
print(p1, p2) // Point(x: 12, y: 23) Point(x: 12, y: 23)
p1 = p2++
print(p1, p2) // Point(x: 12, y: 23) Point(x: 13, y: 24)
print(p1 == p2) // false` 

3\. Equatable
-------------

*   1.  要想得知两个实例是否等价，一般做法是遵守`Equatable协议`，重载`==`运算符 于此同时，等价于`!=`运算符

swift

复制代码

`class Person: Equatable {
 var age: Int
 init(age: Int) {
 self.age = age
 }
 static func == (lhs: Person, rhs: Person) -> Bool {
 lhs.age == rhs.age
 }
}
var p1 = Person(age: 10)
var p2 = Person(age: 20)
print(p1 == p2) // false
print(p1 != p2) // true` 

*   2.  如果没有遵守`Equatable协议`，使用`!=`就会报错 ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d27c4247a3b24460ac35ad8614007b19~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   3.  如果没有遵守`Equatable协议`，只重载`==`运算符，也可以使用`p1 == p2`的判断，但是遵守`Equatable协议`是为了能够在有限制的泛型函数中作为参数使用

swift

复制代码

`func equal<T: Equatable>(_ t1: T, _ t2: T) -> Bool {
 t1 == t2
}
print(equal(p1, p2)) // false` 

> **Swift为以下类型提供默认的`Equatable`实现**

*   1.  没有关联类型的枚举

swift

复制代码

`enum Answer {
 case right, wrong
}
var s1 = Answer.right
var s2 = Answer.wrong
print(s1 == s2)` 

*   2.  只拥有遵守`Equatable协议`关联类型的枚举
*   3.  系统很多自带类型都已经遵守了`Equatable协议`，类似`Int、Double`等

swift

复制代码

`enum Answer: Equatable {
 case right, wrong(Int)
}
var s1 = Answer.wrong(20)
var s2 = Answer.wrong(10)
print(s1 == s2)` 

*   4.  关联类型没有遵守`Equatable协议`的就会报错 ![-w640](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fbe5768c60e74704ab7c5996cb3174fb~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   5.  只拥有遵守`Equatable协议`存储属性的结构体

swift

复制代码

`struct Point: Equatable {
 var x: Int, y: Int
}
var p1 = Point(x: 10, y: 20)
var p2 = Point(x: 11, y: 22)
print(p1 == p2) // false
print(p1 != p2) // true` 

*   6.  引用类型比较存储的地址值是否相等（是否引用着同一个对象），使用恒等运算符`===、!==`

swift

复制代码

`class Person {
}
var p1 = Person()
var p2 = Person()
print(p1 === p2) // false
print(p1 !== p2) // true` 

4\. Comparable
--------------

*   1.  要想比较两个实例的大小，一般做法是遵守`Comparable协议`，重载相应的运算符

swift

复制代码

`struct Student: Comparable {
 var age: Int
 var score: Int
 init(score: Int, age: Int) {
 self.score = score
 self.age = age
 }
 static func < (lhs: Student, rhs: Student) -> Bool {
 (lhs.score < rhs.score) || (lhs.score == rhs.score && lhs.age > rhs.age)
 }
 static func > (lhs: Student, rhs: Student) -> Bool {
 (lhs.score > rhs.score) || (lhs.score == rhs.score && lhs.age < rhs.age)
 }
 static func <= (lhs: Student, rhs: Student) -> Bool {
 !(lhs > rhs)
 }
 static func >= (lhs: Student, rhs: Student) -> Bool {
 !(lhs < rhs)
 }
}
var stu1 = Student(score: 100, age: 20)
var stu2 = Student(score: 98, age: 18)
var stu3 = Student(score: 100, age: 20)
print(stu1 > stu2) // true
print(stu1 >= stu2) // true
print(stu1 >= stu3) // true
print(stu1 <= stu3) // true
print(stu2 < stu1) // true
print(stu2 <= stu1) // true` 

5\. 自定义运算符（Custom Operator）
---------------------------

*   1.  可以`自定义新的运算符`: 在全局作用域使用`operator`进行声明

swift

复制代码

`prefix operator 前缀运算符
postfix operator 后缀运算符
infix operator 中缀运算符：优先级组
precedencegroup 优先级组 {
 associativity: 结合性（left\right\none）
 higherThan: 比谁的优先级更高
 lowerThan: 比谁的优先级低
 assignment: true代表在可选链操作中拥有跟赋值运算符一样的优先级
}` 

*   2.  `自定义运算符`的使用示例如下

swift

复制代码

`prefix operator +++
prefix func +++ (_ i: inout Int) {
 i += 2
}
var age = 10
+++age
print(age) // 12` 

swift

复制代码

`infix operator +-: PlusMinusPrecedence
precedencegroup PlusMinusPrecedence {
 associativity: none
 higherThan: AdditionPrecedence
 lowerThan: MultiplicationPrecedence
 assignment: true
}
struct Point {
 var x = 0, y = 0
 static func +- (p1: Point, p2: Point) -> Point {
 Point(x: p1.x + p2.x, y: p1.y - p2.y)
 }
}
var p1 = Point(x: 10, y: 20)
var p2 = Point(x: 5, y: 10)
print(p1 +- p2) // Point(x: 15, y: 10)` 

> **优先级组中的associativity的设置影响**

swift

复制代码

`associativity对应的三个选项
left: 从左往右执行，可以多个进行结合
right: 从右往左执行，可以多个进行结合
none: 不支持多个结合` 

*   3.  如果再增加一个计算就会报错，因为我们设置的`associativity`为`none` ![-w643](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc1d00a4584b47388f5e57ee164d9c2f~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)
*   4.  我们把`associativity`改为`left`或者`right`，再运行就可以了

swift

复制代码

`infix operator +-: PlusMinusPrecedence
precedencegroup PlusMinusPrecedence {
 associativity: left
 higherThan: AdditionPrecedence
 lowerThan: MultiplicationPrecedence
 assignment: true
}
var p3 = Point(x: 5, y: 10)
print(p1 +- p2 +- p3) // Point(x: 20, y: 0)` 

> **优先级组中的assignment的设置影响**

我们先看下面的示例代码

swift

复制代码

`class Person {
var age = 0
var point: Point = Point()
}
var p: Person? = nil
print(p?.point +- Point(x: 10, y: 20))` 

设置`assignment`为`true`的意思就是如果在运算中，前面的可选项为`nil`，那么运算符后面的代码就不会执行了

Apple文档参考链接： [developer.apple.com/documentati…](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswift%2Fswift_standard_library%2Foperator_declarations "https://developer.apple.com/documentation/swift/swift_standard_library/operator_declarations")

另一个： [docs.swift.org/swift-book/…](https://link.juejin.cn?target=https%3A%2F%2Fdocs.swift.org%2Fswift-book%2FReferenceManual%2FDeclarations.html "https://docs.swift.org/swift-book/ReferenceManual/Declarations.html")

九、扩展（Extension）
===============

1\. 基本概念
--------

*   1.  Swift中的扩展，类似于`OC`中的`Category`
*   2.  扩展可以为`枚举`、`类`、`结构体`、`协议`添加新功能；可以添加方法、`便捷初始化器`、`计算属性`、`下标`、`嵌套类型`、`协议`等
*   3.  扩展`不能做到`以下这几项
    
    *   不能覆盖原有的功能
    *   不能添加存储属性，不能向已有的属性添加属性观察器
    *   不能添加父类
    *   不能添加指定初始化器，不能添加反初始化器
    *   ....

2\. 计算属性、方法、下标、嵌套类型
-------------------

swift

复制代码

`extension Double {
 var km: Double { self * 1_000.0 }
 var m: Double { self }
 var dm: Double { self / 10.0 }
 var cm: Double { self / 100.0 }
 var mm: Double { self / 1_000.0 }
}` 

swift

复制代码

`extension Array {
 subscript(nullable idx: Int) -> Element? {
 if (startIndex..<endIndex).contains(idx) {
 return self[idx]
 }
 return nil
 }
}` 

swift

复制代码

`extension Int {
 func repetitions(task: () -> Void) {
 for _ in 0..<self { task() }
 }
  
 mutating func square() -> Int {
 self = self * self
 return self
 }
  
 enum Kind { case negative, zero, positive }
  
 var kind: Kind {
 switch self {
 case 0: return .zero
 case let x where x > 0: return .positive
 default: return .negative
 }
 }
  
 subscript(digitIndex: Int) -> Int {
 var decimalBase = 1
 for _ in 0..<digitIndex { decimalBase += 10 }
 return (self / decimalBase) % 10
 }
}` 

3\. 初始化器
--------

swift

复制代码

`class Person {
 var age: Int
 var name: String
 init (age: Int, name: String) {
 self.age = age
 self.name = name
 }
}
extension Person: Equatable {
 static func == (left: Person, right: Person) -> Bool {
 left.age == right.age && left.name == right.name
 }
  
 convenience init() {
 self.init(age: 0, name: "")
 }
}` 

*   如果希望自定义初始化器的同时，编译器也能够生成默认初始化器，可以在扩展中编写自定义初始化器
    
    swift
    
    复制代码
    
    `struct Point {
     var x: Int = 0
     var y: Int = 0
    }
    extension Point {
     init(_ point: Point) {
     self.init(x: point.x, y: point.y)
     }
    }
    var p1 = Point()
    var p2 = Point(x: 10)
    var p3 = Point(y: 10)
    var p4 = Point(x: 10, y: 20)
    var p5 = Point(p4)` 
    
*   `required`的初始化器也不能写在扩展中 ![-w634](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/86b30907739b411ba4860320550b8df6~tplv-k3u1fbpfcp-zoom-in-crop-mark:1512:0:0:0.awebp)

4\. 协议
------

*   1.  如果一个类型`已经实现了协议`的所有要求，但是`还没有声明它遵守`了这个协议，`可以通过扩展来让他遵守`这个协议
    
    swift
    
    复制代码
    
    `protocol TestProtocol {
     func test1()
    }
    class TestClass {
     func test1() {
     print("TestClass test1")
     }
    }
    extension TestClass: TestProtocol { }` 
    
    swift
    
    复制代码
    
    `extension BinaryInteger {
     func isOdd() -> Bool {self % 2 != 0 }
    }
    print(10.isOdd())` 
    
*   2.  `扩展`可以给`协议`提供`默认实现`，也`间接实现可选协议`的结果  
        `扩展`可以给`协议`扩充协议中从未声明过的方法
    
    swift
    
    复制代码
    
    `protocol TestProtocol {
     func test1()
    }
    extension TestProtocol {
     func test1() {
     print("TestProtocol test1")
     }
     func test2() {
     print("TestProtocol test2")
     }
    }
    class TestClass: TestProtocol { }
    var cls = TestClass()
    cls.test1() // TestProtocol test1
    cls.test2() // TestProtocol test2
    var cls2: TestProtocol = TestClass()
    cls2.test1() // TestProtocol test1
    cls2.test2() // TestProtocol test2` 
    
    swift
    
    复制代码
    
    `class TestClass: TestProtocol {
     func test1() {
     print("TestClass test1")
     }
     func test2() {
     print("TestClass test2")
     }
    }
    var cls = TestClass()
    cls.test1() // TestClass test1
    cls.test2() // TestClass test2
    var cls2: TestProtocol = TestClass()
    cls2.test1() // TestClass test1
    cls2.test2() // TestProtocol test2` 
    

5\. 泛型
------

swift

复制代码

`class Stack<E> {
 var elements = [E]()
 func push(_ element: E) {
 elements.append(element)
 }
  
 func pop() -> E {
 elements.removeLast()
 }
  
 func size() -> Int {
 elements.count
 }
}` 

*   1.  扩展中依然可以使用原类型中的泛型类型
    
    swift
    
    复制代码
    
    `extension Stack {
     func top() -> E {
     elements.last!
     }
    }` 
    
*   2.  符合条件才扩展
    
    swift
    
    复制代码
    
    `extension Stack: Equatable where E : Equatable {
     static func == (left: Stack, right: Stack) -> Bool {
     left.elements == right.elements
     }
    }` 
    