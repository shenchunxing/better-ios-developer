//
//  main.swift
//  String和Array
//
//  Created by 沈春兴 on 2022/7/7.
//

import Foundation

//1个String变量占用多少内存? 16个字节。字符串长度不超过15位，内容直接放到变量内存中。长度超过15位，字符串内容存放在常量区，内存中的后8个字节存放的是字符串内容真实存放的内存地址，前8个字节存放的是字符串长度及标识符（标识符用来标记字符串存放到哪个区域）

//如果对String进行拼接操作， String变量的存储会发生什么变化? 只要长度超过15位拼接字符串，都会重新开辟堆空间存放字符串内容

//内 存 地 址 从 低 到 高
//代码区
//常量区
//全局区(数据段)
//堆空间
//栈空间
//动态库

//长度小于15位的字符串
var str1 = "0123456789"
print(MemoryLayout.size(ofValue: str1))// 16
print(Mems.memStr(ofVal: &str1))//0x3736353433323130 0xea00000000003938
//前8个字节0x3736353433323130分离后 ： 0x37 36 35 34 33 32 31 30 都是ASCII值
//后8个字节0xea00000000003938分离后 ： 0xea0000000000 39 38  38 39也是ASCII   a表示字符串长度是10，最大是f，也就是15位

//长度为15位的字符串
var str11 = "0123456789ABCDE"
print(MemoryLayout.size(ofValue: str11))//16
print(Mems.memStr(ofVal: &str11))//0x3736353433323130 0xef45444342413938
//前8个字节0x3736353433323130分离后 ： 0x37 36 35 34 33 32 31 30 都是ASCII值
//后8个字节0xea00000000003938分离后 ： 0xea0000000000 39 38  38 39也是ASCII  15位长度字符串，位数已经用f表示了。这种情况类似于OC中的tagger pointer（字符串的内容直接放到对象str1内存里面了）。


//长度超过15位的字符串
var str111 = "0123456789ABCDEF"
print(MemoryLayout.size(ofValue: str111))//16
print(Mems.memStr(ofVal: &str111))//0xd000000000000010 0x80000001000075f0


str1.append("A")
print(MemoryLayout.size(ofValue: str1))//0x3736353433323130 0xeb00000000413938 长度不超过15字符串内容依然是直接放到内存里面的


str111.append("G") //0xf000000000000011 0x000000010043f8a0
print(MemoryLayout.size(ofValue: str111))//长度超过15，字符串是存放到常量区的，也就意味着内存是不允许修改的。所以修改字符串内容时（超过15位），会在堆空间重新开辟一块内存来存储内容



print("---------------------")


//1个Array变量占用多少内存？
struct Point {
    var x = 0, y = 0
}
var p = Point()
print(MemoryLayout.stride(ofValue: p)) //16 结构体的内存占用大小是把存放到结构体中的变量占用内存大小加起来。

print("---------------------")

var arr = [1, 2, 3, 4]
print(MemoryLayout.stride(ofValue: arr))//8 ，存储的是堆空间的地址
print(Mems.memStr(ofRef: arr))
//0x00007fff8e5f54d8：存放着数组相关引用类型信息内存地址
//0x0000000200000002：数组的引用计数
//0x0000000000000004：数组的元素个数
//0x0000000000000008：数组的容量：自动扩容至元素个数的两倍
//0x0000000000000001 0x0000000000000002 0x0000000000000003 0x0000000000000004 存储的4个元素

print("---------------------")

arr.append(5)
print(Mems.memStr(ofRef: arr))
//0x00007fff8e5f54d8：存放着数组相关引用类型信息内存地址
//0x0000000200000002：数组的引用计数
//0x0000000000000005：数组的元素个数
//0x0000000000000010：数组的容量：自动扩容至元素个数的两倍
//0x0000000000000001 0x0000000000000002 0x0000000000000003 0x0000000000000004
//0x0000000000000005 0x0000000000000000 0x0000000000000000 0x0000000000000000

print("---------------------")

arr.append(6)
arr.append(7)
arr.append(8)
arr.append(9)
print(Mems.memStr(ofRef: arr))
//0x00007fff8e5f54d8：存放着数组相关引用类型信息内存地址
//0x0000000200000002：数组的引用计数
//0x0000000000000009：数组的元素个数
//0x0000000000000020：数组的容量：自动扩容至20
//0x0000000000000001 0x0000000000000002 0x0000000000000003 0x0000000000000004
//0x0000000000000005 0x0000000000000006 0x0000000000000007 0x0000000000000008
//0x0000000000000009 0x0000000000000006 0x0000000000000007 0x0000000000000008


//数组的表象是结构体，但其本质是引用类型。
