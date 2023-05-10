# Swift5常用核心语法1-基础语法

<h1 data-id="heading-0">一、概述</h1>
<p>最近刚好有空,趁这段时间,复习一下Swift5核心语法,进行知识储备,以供日后温习 和  探索 Swift语言的底层原理做铺垫。</p>
<h1 data-id="heading-1">二、Swift5 简介</h1>
<h2 data-id="heading-2">1. Swift简介</h2>
<blockquote>
<h2 data-id="heading-3"><code>在学习Swift之前，我们先来了解下什么是Swift</code></h2>
</blockquote>
<ul>
<li>在Swift刚发布那会，百度\Google一下Swift，出现最多的搜索结果是 p美国著名女歌手<code>Taylor Swift</code>，中国歌迷称她为“霉霉” <img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c6e47a38ed474b5da8d0a92a64d29cf5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></li>
<li>现在的搜索结果以Swift编程语言相关的内容居多</li>
<li>Swift是<code>Apple</code>在2014年6月<code>WWDC</code>发布的全新编程语言，中文名和LOGO是”雨燕“</li>
<li>Swift之父是<code>Chris Lattner</code>，也是<code>Clang</code>编译器的作者，<code>LLVM</code>项目的主要发起人
<img src="https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/422db6557dc64aefb517e64047706181~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image">
<ul>
<li>如果你想了解一下LLVM、Clang等知识,也可以参考一下我这篇文章:</li>
<li><a href="https://juejin.cn/post/7093842449998561316" target="_blank" title="https://juejin.cn/post/7093842449998561316">探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM、Xcode编译的过程】</a></li>
</ul>
</li>
</ul>
<h2 data-id="heading-4">2.Swift版本</h2>
<p>Swift历时8年，从<code>Swift 1.*</code>更新到<code>Swift 5.*</code>，经历了多次重大改变，<code>ABI</code>终于稳定</p>
<ul>
<li>API（Application Programming Interface）：应用程序编程接口
<ul>
<li>源代码和库之间的接口</li>
</ul>
</li>
<li>ABI（Application Binary Interface）：应用程序二进制接口
<ul>
<li>应用程序和操作系统之间的底层接口</li>
<li>涉及的内容有：目标文件格式、数据类型的大小/布局/对齐，函数调用约定等</li>
</ul>
</li>
<li>随着ABI的稳定，Swift语法基本不会再有太大的变动，此时正是学习Swift的最佳时刻</li>
<li>截止至2022年11月，目前最新版本：<code>Swift5.8.x</code></li>
<li>Swift完全开源: <a href="https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fapple%2Fswift" target="_blank" title="https://github.com/apple/swift" ref="nofollow noopener noreferrer">github.com/apple/swift</a> 主要采用<a href="https://link.juejin.cn?target=https%3A%2F%2Fzh.wikipedia.org%2Fwiki%2FC%252B%252B" target="_blank" title="https://zh.wikipedia.org/wiki/C%2B%2B" ref="nofollow noopener noreferrer">C++</a>编写</li>
<li>Swift是完全开源的，下载地址：<a href="https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fapple%2Fswift" target="_blank" title="https://github.com/apple/swift" ref="nofollow noopener noreferrer">github.com/apple/swift</a></li>
</ul>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b35a9d1a95143c1919a33e9d38a8b38~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-5">3. Swift编译原理</h2>
<p>关于更详尽的iOS编译相关的知识,可以参考我这篇文章:<a href="https://juejin.cn/post/7093842449998561316" target="_blank" title="https://juejin.cn/post/7093842449998561316">探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM、Xcode编译的过程】</a><br>
在本文仅是简单回顾一下:</p>
<h3 data-id="heading-6">3.1 了解LLVM项目</h3>
<p><strong><code>LLVM</code>项目的架构如图:</strong> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a1361fe67fca43fd919e467dd657f0ba~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="image.png" loading="lazy" class="medium-zoom-image"> 从上图我们可以清晰看到,整个程序编译链可以划分为三部分:<code>编译器前端</code>(左边部分)、<code>优化器</code>(中间部分)、<code>编译器后端</code>(右边部分)。(从我的这篇文章可以更详细了解编译相关的知识:<a href="https://juejin.cn/post/7022956636901736462/" target="_blank" title="https://juejin.cn/post/7022956636901736462/">计算机编译原理</a>)</p>
<ul>
<li><strong>编译器前端（Frontend）</strong> :词法分析、语法分析、语义分析、生成中间代码llvm-ir</li>
<li><strong>优化器（Optimizer）</strong> :对中间代码进行优化、改造,使之变成性能更加高效的中间代码llvm-ir(内存空间、执行效率)</li>
<li><strong>编译器后端(Backend)</strong> :生成指定硬件架构的可执行文件</li>
</ul>
<p><strong>对编译器王者<code>LLVM</code>的进一步认识:</strong></p>
<ul>
<li><strong>使用统一的中间代码:</strong> 不同的编译器前端、编译器后端使用统一的中间代码LLVM Intermediate Representation (LLVM IR)</li>
<li><strong>只需实现一个前端:</strong> 如果需要支持一种新的编程语言，那么只需要实现一个新的前端</li>
<li><strong>只需实现一个后端:</strong> 如果需要支持一种新的硬件设备，那么只需要实现一个新的后端</li>
<li><strong>通用优化器:</strong> 优化阶段是一个通用的阶段，它针对的是统一的LLVM IR，不论是支持新的编程语言，还是支持新的硬件设备，都不需要对优化阶段做修改</li>
</ul>
<h3 data-id="heading-7">3.2 编译流程</h3>
<p>我们知道OC的编译器前端是<code>Clang</code>,而Swift的编译器前端是<code>swiftc</code><br>
通过LLVM编译链,不同的编译型语言的编译器前端可能不同，但在同一个硬件架构的硬件中,最终都会通过同一个编译器的后端生成二进制代码</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7340c46adb0f4b56b586665b3c5e1af7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w727" loading="lazy" class="medium-zoom-image"></p>
<p>整个编译流程如下图所示</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8870a2bedcfb4727805286871302da56~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w525" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li><strong>代码编辑/阅读阶段:</strong>
<ul>
<li><strong>Swift Code:</strong> 我们编写的Swift代码</li>
</ul>
</li>
<li><strong>编译器前端工作阶段:</strong>
<ul>
<li><strong>Swift AST:</strong> Swift语法树</li>
<li><strong>Raw Swift IL:</strong> Swift特有的中间代码</li>
</ul>
</li>
<li><strong>优化器工作阶段:</strong>
<ul>
<li><strong>Canonical Swift IL:</strong> 更简洁的Swift特有的中间代码</li>
<li><strong>LLVM IR:</strong>     LLVM的中间代码</li>
</ul>
</li>
<li><strong>编译器后端工作阶段:</strong>
<ul>
<li><strong>Assembly:</strong>   汇编代码</li>
<li><strong>Executable:</strong> 二进制可执行文件</li>
</ul>
</li>
</ul>
<p>关于Swift编译流程的详细讲解可以参考以下网址：<a href="https://link.juejin.cn?target=https%3A%2F%2Fswift.org%2Fswift-compiler%2F%23compiler-architecture" target="_blank" title="https://swift.org/swift-compiler/#compiler-architecture" ref="nofollow noopener noreferrer">swift.org/swift-compi…</a></p>
<h3 data-id="heading-8">3.3  swiftc</h3>
<p>我们打开终端，输入<code>swiftc -help</code>，会打印出相关指令，这也说明了<code>swiftc</code>已经存在于Xcode中
<img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/529073fbb5114e74b3e1d5bb781cf36c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<p>我们可以在应用程序中找到<code>Xcode</code>，然后<code>右键显示包内容</code>，通过该路径找到<code>swiftc</code>
路径：<code>/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin</code></p>
<p><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e3c9b58d277c4416a405660a1e2b5d73~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h3 data-id="heading-9">3.4  <code>SwiftC</code> 命令行指令</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 假设原始文件为main.swift</span>

<span class="hljs-comment">// 分析输出AST</span>
swiftc main.swift <span class="hljs-operator">-</span>dump<span class="hljs-operator">-</span>parse

<span class="hljs-comment">// 分析并且检查类型输出AST</span>
swiftc main.swift <span class="hljs-operator">-</span>dump<span class="hljs-operator">-</span>ast

<span class="hljs-comment">// 生成中间体语言（SIL），未优化</span>
swiftc main.swift <span class="hljs-operator">-</span>emit<span class="hljs-operator">-</span>silgen <span class="hljs-operator">-</span>o main.sil 

<span class="hljs-comment">// 生成中间体语言（SIL），优化后的</span>
swiftc main.swift <span class="hljs-operator">-</span>emit<span class="hljs-operator">-</span>sil <span class="hljs-operator">-</span>o main.sil 

<span class="hljs-comment">// 生成优化后的中间体语言（SIL）,并将结果导入到main.sil文件中</span>
swiftc main.swift <span class="hljs-operator">-</span>emit<span class="hljs-operator">-</span>sil  <span class="hljs-operator">-</span>o main.sil 

<span class="hljs-comment">// 生成优化后的中间体语言（SIL），并将sil文件中的乱码字符串进行还原，并将结果导入到main.sil文件中</span>
swiftc main.swift <span class="hljs-operator">-</span>emit<span class="hljs-operator">-</span>sil <span class="hljs-operator">|</span> xcrun swift<span class="hljs-operator">-</span>demangle <span class="hljs-operator">&gt;</span> main.sil

<span class="hljs-comment">// 生成LLVM中间体语言 （.ll文件）</span>
swiftc main.swift <span class="hljs-operator">-</span>emit<span class="hljs-operator">-</span>ir  <span class="hljs-operator">-</span>o main.ir

<span class="hljs-comment">// 生成LLVM中间体语言 （.bc文件）</span>
swiftc main.swift <span class="hljs-operator">-</span>emit<span class="hljs-operator">-</span>bc <span class="hljs-operator">-</span>o main.bc

<span class="hljs-comment">// 生成汇编</span>
swiftc main.swift <span class="hljs-operator">-</span>emit<span class="hljs-operator">-</span>assembly <span class="hljs-operator">-</span>o main.s

<span class="hljs-comment">// 编译生成可执行.out文件</span>
swiftc main.swift <span class="hljs-operator">-</span>o main.o 
 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3b0a17ed5e7645fe85e717787b6c4cde~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h1 data-id="heading-10">三、Swift基础语法</h1>
<p>通过前面的篇幅,我们基本了解了Swift,接下来我们通过后面的篇幅回顾Swift核心语法,首先引入一张Swift学习路径图:
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/24a0e9b9edef459698ab719ddd55e5ca~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-11">1. HelloWorld</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-built_in">print</span>(<span class="hljs-string">"Hello World"</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>不用编写main函数</code>，Swift将全局范围内的首句可执行代码作为程序入口
<ul>
<li>通过反汇编我们可以看到底层会执行<code>main函数</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d3812006b4554d1dab11c06773c70667~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1084" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
<li>一句代码尾部可以省略分号（<code>;</code>），多句代码写到同一行时必须用分号（<code>;</code>）隔开</li>
</ul>
<h2 data-id="heading-12">2. 常量和变量</h2>
<blockquote>
<p><strong>常量:</strong></p>
</blockquote>
<ul>
<li>1.用<code>let</code>定义常量(常量只能赋值一次)<br>
不用特意指明类型，编译器能自动推断出变量/常量的数据类型</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> a: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">let</span> b <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>2.它的值不要求在编译过程中确定，但使用之前必须赋值一次<br>
这样写确定了a的类型，之后再去赋值，也不会报错</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> a: <span class="hljs-type">Int</span>
a <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li>用函数给常量赋值也可以，函数是在运行时才会确定值的，所以只要保证使用之前赋值了就行</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">getNumber</span>() -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-keyword">return</span> <span class="hljs-number">10</span>
}

<span class="hljs-keyword">let</span> a: <span class="hljs-type">Int</span>
a <span class="hljs-operator">=</span> getNumber()
<span class="copy-code-btn">复制代码</span></code></pre>
<p>如果没有给a确定类型，也没有一开始定义的时候赋值，就会像下面这样报错</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/08edecb0ca46419ba036d09018216bf9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w643" loading="lazy" class="medium-zoom-image"></p>
<blockquote>
<p><strong>变量:</strong></p>
</blockquote>
<ul>
<li>1.用<code>var</code>定义变量</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> b <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
b <span class="hljs-operator">=</span> <span class="hljs-number">30</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>2.常量、变量在初始化之前，都不能使用
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/04bf944bbfc4417e8823fae37c842d4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-13">3.注释</h2>
<ul>
<li>1.Swift中有单行注释和多行注释<br>
注释之间嵌套也没有问题
<img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87b1be1e5f484713bd027b95238b96ea~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 单行注释</span>

<span class="hljs-comment">/*
 多行注释
*/</span>

<span class="hljs-comment">/*
  1
 <span class="hljs-comment">/* 释嵌套 */</span>
 2 
*/</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>2.<code>Playground</code>里的注释支持<code>Markup</code>语法（同Markdown）<br>
<code>Markup</code>语法只在<code>Playground</code>里有效，在项目中无效</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">//: # 一级标题</span>

<span class="hljs-comment">/*:
 ## 基础语法
 */</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>可以通过<code>Editor -&gt; Show Raw Markup</code>来预览</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fc0ce08a3f7e47ddb20ab8e25ee2390f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w299" loading="lazy" class="medium-zoom-image"></p>
<p>预览的效果如下</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/79c641b6ee6a41ffa4fc92e3042cc724~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w369" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-14">4.标识符</h2>
<p>1.标识符（比如常量名、变量名、函数名）几乎可以使用任何字符</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> 📒 <span class="hljs-operator">=</span> <span class="hljs-number">5</span>
<span class="hljs-keyword">var</span> 😁 <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

<span class="hljs-keyword">func</span> 👽() {
    
}
<span class="copy-code-btn">复制代码</span></code></pre>
<p>标识符不能以数字开头，不能包含空白字符、制表符、箭头等特殊字符</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8fcaf1f13cc64642a95cf7cad2b6d27c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w649" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-15">5.常见数据类型</h2>
<h3 data-id="heading-16">5.1 常见类型</h3>
<ul>
<li>值类型
<ul>
<li>枚举（enum）: Optional</li>
<li>结构体（struct）: Bool、Double、Float、Int、Character、String、Array、Dictionary、Set</li>
</ul>
</li>
<li>引用类型
<ul>
<li>类（class）</li>
</ul>
</li>
</ul>
<p>可以通过<code>command+control</code>进入到该类型的API中查看</p>
<p>例如Int类型</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2d867a4b7cb649cea7603c96674e93f3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w757" loading="lazy" class="medium-zoom-image"></p>
<h3 data-id="heading-17">5.2 整数类型</h3>
<ul>
<li>整数类型：<code>Int8</code>、<code>Int16</code>、<code>Int32</code>、<code>Int64</code>、<code>UInt8</code>、<code>UInt16</code>、<code>UInt32</code>、<code>UInt64</code></li>
<li>在32bit平台，<code>Int</code>等于<code>Int32</code>；在64bit平台，<code>Int</code>等于<code>Int64</code></li>
<li>整数的最值：<code>UInt8.max</code>，<code>Int16.min</code>
一般情况下，都是直接使用<code>Int</code>即可</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> a: <span class="hljs-type">Int8</span> <span class="hljs-operator">=</span> <span class="hljs-number">5</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-18">5.3 浮点类型</h3>
<ul>
<li>Float：32位，精度只有6位</li>
<li>Double：64位，精度至少15位
浮点型不指明类型默认就是<code>Double</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> a: <span class="hljs-type">Float</span> <span class="hljs-operator">=</span> <span class="hljs-number">2.0</span>
<span class="hljs-keyword">let</span> b <span class="hljs-operator">=</span> <span class="hljs-number">3.0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-19">6. 字面量</h2>
<p>字面量就是指这个量本身，就是一个固定值的表示法</p>
<p>下面这些都是字面量</p>
<h3 data-id="heading-20">6.1 Bool布尔</h3>
<p>一般用<code>Bool</code>类型来表示是否的判断，是为<code>true</code>，否为<code>false</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">//布尔</span>
<span class="hljs-keyword">let</span> bool <span class="hljs-operator">=</span> <span class="hljs-literal">true</span> <span class="hljs-comment">//取反是false</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-21">6.2 字符串、字符</h3>
<blockquote>
<p><strong>字符串的写法:</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> string <span class="hljs-operator">=</span> <span class="hljs-string">"hello"</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>字符类型要写上<code>Character</code>，否则会被认为是字符串<br>
字符可存储<code>ASCII字符、Unicode字符</code></p>
<blockquote>
<p><strong>字符写法:</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> character: <span class="hljs-type">Character</span> <span class="hljs-operator">=</span> <span class="hljs-string">"a"</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-22">6.3 整数</h3>
<blockquote>
<p><strong>不同进制的表示法:</strong></p>
</blockquote>
<ul>
<li>二进制以<code>0b</code>开头</li>
<li>八进制以<code>0o</code>开头</li>
<li>十六进制以<code>0x</code>开头</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> intDecimal <span class="hljs-operator">=</span> <span class="hljs-number">17</span> <span class="hljs-comment">// 十进制</span>
<span class="hljs-keyword">let</span> intBinary <span class="hljs-operator">=</span> <span class="hljs-number">0b10001</span> <span class="hljs-comment">// 二进制</span>
<span class="hljs-keyword">let</span> intOctal <span class="hljs-operator">=</span> <span class="hljs-number">0o21</span> <span class="hljs-comment">// 八进制</span>
<span class="hljs-keyword">let</span> intHexadecimal <span class="hljs-operator">=</span> <span class="hljs-number">0x11</span> <span class="hljs-comment">// 十六进制</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-23">6.4 浮点数</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> doubleDecimal <span class="hljs-operator">=</span> <span class="hljs-number">125.0</span> <span class="hljs-comment">// 十进制</span>
<span class="hljs-keyword">let</span> doubleDecimal2 <span class="hljs-operator">=</span> <span class="hljs-number">1.25e2</span> <span class="hljs-comment">// 也是125.0的另一种写法，表示1.25乘以10的二次方</span>

<span class="hljs-keyword">let</span> doubleDecimal3 <span class="hljs-operator">=</span> <span class="hljs-number">0.0125</span>
<span class="hljs-keyword">let</span> doubleDecimal4 <span class="hljs-operator">=</span> <span class="hljs-number">1.25e-2</span> <span class="hljs-comment">// 也是0.0125的另一种写法，表示1.25乘以10的负二次方</span>

<span class="hljs-keyword">let</span> doubleHexadecimal1 <span class="hljs-operator">=</span> <span class="hljs-number">0xFp2</span> <span class="hljs-comment">// 十六进制，意味着15*2^2（15乘以2的二次方），相当于十进制的60</span>
<span class="hljs-keyword">let</span> doubleHexadecimal2 <span class="hljs-operator">=</span> <span class="hljs-number">0xFp-2</span> <span class="hljs-comment">//十六进制，意味着15*2^-2（15乘以2的负二次方），相当于十进制的3.75</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>整数和浮点数可以添加额外的零或者下划线来<code>增强可读性</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> num <span class="hljs-operator">=</span> <span class="hljs-number">10_0000</span>
<span class="hljs-keyword">let</span> price <span class="hljs-operator">=</span> <span class="hljs-number">1_000.000_000_1</span>
<span class="hljs-keyword">let</span> decimal <span class="hljs-operator">=</span> <span class="hljs-number">000123.456</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-24">6.5 数组</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> array <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>]
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-25">6.6 字典</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> dictionary <span class="hljs-operator">=</span> [<span class="hljs-string">"age"</span> : <span class="hljs-number">18</span>, <span class="hljs-string">"height"</span> : <span class="hljs-number">1.75</span>, <span class="hljs-string">"weight"</span> : <span class="hljs-number">120</span>]
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-26">7.类型转换</h2>
<blockquote>
<p><strong>整数转换:</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> int1: <span class="hljs-type">UInt16</span> <span class="hljs-operator">=</span> <span class="hljs-number">2_000</span>
<span class="hljs-keyword">let</span> int2: <span class="hljs-type">UInt8</span> <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
<span class="hljs-keyword">let</span> int3 <span class="hljs-operator">=</span> int1 <span class="hljs-operator">+</span> <span class="hljs-type">UInt16</span>(int2)
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>整数、浮点数转换:</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> int <span class="hljs-operator">=</span> <span class="hljs-number">3</span>
<span class="hljs-keyword">let</span> double <span class="hljs-operator">=</span> <span class="hljs-number">0.1415926</span>
<span class="hljs-keyword">let</span> pi <span class="hljs-operator">=</span> <span class="hljs-type">Double</span>(int) <span class="hljs-operator">+</span> double
<span class="hljs-keyword">let</span> intPi <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(pi)
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>字面量可以直接相加，因为数字字面量本身没有明确的类型:</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> result <span class="hljs-operator">=</span> <span class="hljs-number">3</span> <span class="hljs-operator">+</span> <span class="hljs-number">0.14159</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-27">8.元组（tuple）</h2>
<p>元组是可以多种数据类型组合在一起</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> http404Error <span class="hljs-operator">=</span> (<span class="hljs-number">404</span>, <span class="hljs-string">"Not Found"</span>)
<span class="hljs-built_in">print</span>(<span class="hljs-string">"The status code is (http404Error.0)"</span>)

<span class="hljs-comment">// 可以分别把元组里的两个值分别进行赋值</span>
<span class="hljs-keyword">let</span> (statusCode, statusMsg) <span class="hljs-operator">=</span> http404Error
<span class="hljs-built_in">print</span>(<span class="hljs-string">"The status code is (statusCode)"</span>)

<span class="hljs-comment">// 可以只给元组里的某一个值进行赋值</span>
<span class="hljs-keyword">let</span> (justTheStatusCode, <span class="hljs-keyword">_</span>) <span class="hljs-operator">=</span> http404Error

<span class="hljs-comment">// 可以在定义的时候给元组里面的值起名</span>
<span class="hljs-keyword">let</span> http200Status <span class="hljs-operator">=</span> (statusCode: <span class="hljs-number">200</span>, description: <span class="hljs-string">"ok"</span>)
<span class="hljs-built_in">print</span>(<span class="hljs-string">"The status code is (http200Status.statusCode)"</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-28">9.流程控制</h2>
<h3 data-id="heading-29">9.1 条件分支语句if-else</h3>
<p>Swift里的<code>if else</code>后面的条件是可以省略小括号的，但大括号不可以省略</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span> 
<span class="hljs-keyword">if</span> age <span class="hljs-operator">&gt;=</span> <span class="hljs-number">22</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"Get married"</span>)
} <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> age <span class="hljs-operator">&gt;=</span> <span class="hljs-number">18</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"Being a adult"</span>)
} <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> age <span class="hljs-operator">&gt;=</span> <span class="hljs-number">7</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"Go to school"</span>)
} <span class="hljs-keyword">else</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"Just a child"</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
<p><code>if else</code>后面的条件只能是<code>Bool类型</code></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d70fc3c6157d4d7286323338f6a62764~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w718" loading="lazy" class="medium-zoom-image"></p>
<h3 data-id="heading-30">9.2 循环语句<code>while</code>/<code>repeat-while</code></h3>
<p><strong><code>while</code>:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">5</span>
<span class="hljs-keyword">while</span> num <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"num is (num)"</span>)
    <span class="hljs-comment">// 打印了五次</span>
}
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong><code>repeat-while</code>:</strong><br>
<code>repeat-while</code>相当于C语言中的<code>do-while</code></p>
<p>先执行一次，再判断条件循环</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-operator">-</span><span class="hljs-number">1</span>
<span class="hljs-keyword">repeat</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"num is (num)"</span>)
    <span class="hljs-comment">// 打印了一次</span>
} <span class="hljs-keyword">while</span> num <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>这里不用<code>num--</code>是因为<br>
<code>Swift3</code>开始，已经去掉了自增(++)、自减(--)运算符</p>
<h3 data-id="heading-31">9.3 循环语句for</h3>
<ul>
<li>
<p>1.闭区间运算符：<code>a...b</code>，相当于<code>a &lt;= 取值 &lt;= b</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 第一种写法</span>
<span class="hljs-keyword">let</span> names <span class="hljs-operator">=</span> [<span class="hljs-string">"Anna"</span>, <span class="hljs-string">"Alex"</span>, <span class="hljs-string">"Brian"</span>, <span class="hljs-string">"Jack"</span>]
<span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> <span class="hljs-number">0</span><span class="hljs-operator">...</span><span class="hljs-number">3</span> {
    <span class="hljs-built_in">print</span>(names[i])
}<span class="hljs-comment">// Anna Alex Brian Jack</span>
<span class="hljs-comment">// 第二种写法</span>
<span class="hljs-keyword">let</span> range <span class="hljs-operator">=</span> <span class="hljs-number">0</span><span class="hljs-operator">...</span><span class="hljs-number">3</span>
<span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> range {
    <span class="hljs-built_in">print</span>(names[i])
}<span class="hljs-comment">// Anna Alex Brian Jack</span>

<span class="hljs-comment">// 第三种写法</span>
<span class="hljs-keyword">let</span> a <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
<span class="hljs-keyword">let</span> b <span class="hljs-operator">=</span> <span class="hljs-number">3</span>
<span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> a<span class="hljs-operator">...</span>b {

}<span class="hljs-comment">// Alex Brian Jack</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>循环里的<code>i</code>默认是<code>let</code>，如需要更改加上<code>var</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">for</span> <span class="hljs-keyword">var</span> i <span class="hljs-keyword">in</span> <span class="hljs-number">1</span><span class="hljs-operator">...</span><span class="hljs-number">3</span> {
    i <span class="hljs-operator">+=</span> <span class="hljs-number">5</span>
    <span class="hljs-built_in">print</span>(i)
}<span class="hljs-comment">// 6 7 8</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>不需要值的时候用<code>_</code>来表示</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">for</span> <span class="hljs-keyword">_</span> <span class="hljs-keyword">in</span> <span class="hljs-number">0</span><span class="hljs-operator">...</span><span class="hljs-number">3</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"for"</span>)
}<span class="hljs-comment">// 打印了3次</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p>for – 区间运算符用在数组上</p>
</blockquote>
<ul>
<li>
<p>4.半开区间运算符：<code>a..&lt;b</code>，相当于<code>a &lt;= 取值 &lt; b</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> <span class="hljs-number">0</span><span class="hljs-operator">..&lt;</span><span class="hljs-number">3</span> {
    <span class="hljs-built_in">print</span>(i)
}<span class="hljs-comment">//0 1 2</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<p>6.单侧区间：让一个区间朝一个方向尽可能的远区间运算符还可以用在数组上）</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> names <span class="hljs-operator">=</span> [<span class="hljs-string">"Anna"</span>, <span class="hljs-string">"Alex"</span>, <span class="hljs-string">"Brian"</span>, <span class="hljs-string">"Jack"</span>] 
<span class="hljs-keyword">for</span> name <span class="hljs-keyword">in</span> names[<span class="hljs-number">0</span><span class="hljs-operator">...</span><span class="hljs-number">3</span>] { 
   <span class="hljs-built_in">print</span>(name)
} <span class="hljs-comment">// Anna Alex Brian Jack</span>


<span class="hljs-keyword">for</span> name <span class="hljs-keyword">in</span> names[<span class="hljs-number">2</span><span class="hljs-operator">...</span>] {
   <span class="hljs-built_in">print</span>(name)
} <span class="hljs-comment">// Brian Jack</span>

<span class="hljs-keyword">for</span> name <span class="hljs-keyword">in</span> names[<span class="hljs-operator">...</span><span class="hljs-number">2</span>] {
   <span class="hljs-built_in">print</span>(name)
} <span class="hljs-comment">// Anna Alex Brian</span>
  
<span class="hljs-keyword">for</span> name <span class="hljs-keyword">in</span> names[<span class="hljs-operator">..&lt;</span><span class="hljs-number">2</span>] {
   <span class="hljs-built_in">print</span>(name)
} <span class="hljs-comment">// Anna Alex</span>


<span class="hljs-keyword">let</span> range <span class="hljs-operator">=</span> <span class="hljs-operator">...</span><span class="hljs-number">5</span> 
range.contains(<span class="hljs-number">7</span>) <span class="hljs-comment">// false </span>
range.contains(<span class="hljs-number">4</span>) <span class="hljs-comment">// true </span>
range.contains(<span class="hljs-operator">-</span><span class="hljs-number">3</span>) <span class="hljs-comment">// true</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<p>7.区间的几种类型</p>
<pre><code class="hljs language-swift copyable" lang="swift">闭区间 <span class="hljs-type">ClosedRange</span>&lt;<span class="hljs-type">Int</span>&gt; 
<span class="hljs-number">1</span><span class="hljs-operator">...</span><span class="hljs-number">3</span>

半开区间 <span class="hljs-type">Range</span>&lt;<span class="hljs-type">Int</span>&gt;
 <span class="hljs-number">1</span><span class="hljs-operator">..&lt;</span><span class="hljs-number">3</span>

单侧区间 <span class="hljs-type">PartialRangeThrough</span>&lt;<span class="hljs-type">Int</span>&gt;
<span class="hljs-operator">...</span><span class="hljs-number">3</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<p>9.字符、字符串也能使用区间运算符，但默认不能用在<code>for-in</code>中</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> stringRange1 <span class="hljs-operator">=</span> <span class="hljs-string">"cc"</span><span class="hljs-operator">...</span><span class="hljs-string">"ff"</span><span class="hljs-comment">// ClosedRange&lt;String&gt;</span>
stringRange1.contains(<span class="hljs-string">"cd"</span>)<span class="hljs-comment">// false</span>
stringRange1.contains(<span class="hljs-string">"dz"</span>) <span class="hljs-comment">// true </span>
stringRange1.contains(<span class="hljs-string">"fg"</span>) <span class="hljs-comment">// false</span>

<span class="hljs-keyword">let</span> stringRange2 <span class="hljs-operator">=</span> <span class="hljs-string">"a"</span><span class="hljs-operator">...</span><span class="hljs-string">"f"</span>
stringRange2.contains(<span class="hljs-string">"d"</span>) <span class="hljs-comment">// true </span>
stringRange2.contains(<span class="hljs-string">"h"</span>) <span class="hljs-comment">// false</span>
<span class="hljs-comment">// \0到~囊括了所有可能要用到的ASCII字符</span>
<span class="hljs-keyword">let</span> characterRange:<span class="hljs-type">ClosedRange</span>&lt;<span class="hljs-type">Character</span>&gt; <span class="hljs-operator">=</span> <span class="hljs-string">"<span class="hljs-subst">\0</span>"</span><span class="hljs-operator">...</span><span class="hljs-string">"~"</span>
characterRange.contains(<span class="hljs-string">"G"</span>)<span class="hljs-comment">// true</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<p>10.带间隔的区间值</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> hours <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">let</span> hourInterval <span class="hljs-operator">=</span> <span class="hljs-number">2</span> 
<span class="hljs-comment">// tickmark的取值，从4开始，累加2，不超过10</span>
<span class="hljs-keyword">for</span> tickmark <span class="hljs-keyword">in</span> <span class="hljs-built_in">stride</span>(from: <span class="hljs-number">4</span>, through: hours, by: hourInterval) {
    <span class="hljs-built_in">print</span>(tickmark)
    <span class="hljs-comment">// 4,6,8,10</span>
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-32">9.4 选择语句switch</h3>
<p>使用同<code>C语言的switch</code>，不同的是:</p>
<ul>
<li>
<ol>
<li><code>case、default</code>后面不写<code>大括号{}</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> number <span class="hljs-operator">=</span> <span class="hljs-number">1</span>

<span class="hljs-keyword">switch</span> number {
<span class="hljs-keyword">case</span> <span class="hljs-number">1</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is 1"</span>)
    <span class="hljs-keyword">break</span>
<span class="hljs-keyword">case</span> <span class="hljs-number">2</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is 2"</span>)
    <span class="hljs-keyword">break</span>
<span class="hljs-keyword">default</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is other"</span>)
    <span class="hljs-keyword">break</span>
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>默认不写<code>break</code>，并不会贯穿到后面的条件</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> number <span class="hljs-operator">=</span> <span class="hljs-number">1</span>

<span class="hljs-keyword">switch</span> number {
<span class="hljs-keyword">case</span> <span class="hljs-number">1</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is 1"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">2</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is 2"</span>)
<span class="hljs-keyword">default</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is other"</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong><code>fallthrough</code></strong>
使用<code>fallthrough</code>可以实现贯穿效果</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> number <span class="hljs-operator">=</span> <span class="hljs-number">1</span>

<span class="hljs-keyword">switch</span> number {
<span class="hljs-keyword">case</span> <span class="hljs-number">1</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is 1"</span>)
    <span class="hljs-keyword">fallthrough</span>
<span class="hljs-keyword">case</span> <span class="hljs-number">2</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is 2"</span>)
<span class="hljs-keyword">default</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is other"</span>)
}

<span class="hljs-comment">// 会同时打印number is 1，number is 2</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<h2 data-id="heading-33">switch注意点</h2>
</blockquote>
<ul>
<li>
<ol>
<li><code>switch</code>必须要保证能处理所有情况
<strong>注意：像判断number的值，要考虑到所有整数的条件，如果不要判断全部情况，加上<code>default</code>就可以了</strong>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/78d920799421482894f1b9fc53db3ebd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w722" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="2">
<li><code>case、default</code>后面至少要有一条语句<br>
如果不想做任何事，加个<code>break</code>即可</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> number <span class="hljs-operator">=</span> <span class="hljs-number">1</span>

<span class="hljs-keyword">switch</span> number {
<span class="hljs-keyword">case</span> <span class="hljs-number">1</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is 1"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">2</span>:
    <span class="hljs-keyword">break</span>
<span class="hljs-keyword">default</span>:
    <span class="hljs-keyword">break</span>
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果能保证已处理所有情况，也可以不必使用<code>default</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Answer</span> { <span class="hljs-keyword">case</span> right, wrong }

<span class="hljs-keyword">let</span> answer <span class="hljs-operator">=</span> <span class="hljs-type">Answer</span>.right

<span class="hljs-keyword">switch</span> answer {
<span class="hljs-keyword">case</span> .right:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"right"</span>)
<span class="hljs-keyword">case</span> .wrong:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"wrong"</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>复合条件</strong></p>
</blockquote>
<ul>
<li>
<ol start="4">
<li><code>switch</code>也支持<code>Character</code>和<code>String</code>类型</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> string <span class="hljs-operator">=</span> <span class="hljs-string">"Jack"</span>

<span class="hljs-keyword">switch</span> string {
<span class="hljs-keyword">case</span> <span class="hljs-string">"Jack"</span>:
    <span class="hljs-keyword">fallthrough</span>
<span class="hljs-keyword">case</span> <span class="hljs-string">"Rose"</span>:
    <span class="hljs-built_in">print</span>(string)
<span class="hljs-keyword">default</span>:
    <span class="hljs-keyword">break</span>
}<span class="hljs-comment">//Jack</span>


<span class="hljs-keyword">let</span> character: <span class="hljs-type">Character</span> <span class="hljs-operator">=</span> <span class="hljs-string">"a"</span> 
<span class="hljs-keyword">switch</span> character {
<span class="hljs-keyword">case</span> <span class="hljs-string">"a"</span>, <span class="hljs-string">"A"</span>:
    <span class="hljs-built_in">print</span>(character)
<span class="hljs-keyword">default</span>:
    <span class="hljs-keyword">break</span>
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li><code>switch</code>可以同时判断多个条件</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> string <span class="hljs-operator">=</span> <span class="hljs-string">"Jack"</span>

<span class="hljs-keyword">switch</span> string {
<span class="hljs-keyword">case</span> <span class="hljs-string">"Jack"</span>, <span class="hljs-string">"Rose"</span>:
    <span class="hljs-built_in">print</span>(string)
<span class="hljs-keyword">default</span>:
    <span class="hljs-keyword">break</span>
}<span class="hljs-comment">// Right person  </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="6">
<li><code>switch</code>也支持区间匹配和元组匹配</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> count <span class="hljs-operator">=</span> <span class="hljs-number">62</span>

<span class="hljs-keyword">switch</span> count {
<span class="hljs-keyword">case</span> <span class="hljs-number">0</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"none"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">1</span><span class="hljs-operator">..&lt;</span><span class="hljs-number">5</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"a few"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">5</span><span class="hljs-operator">..&lt;</span><span class="hljs-number">12</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"several"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">12</span><span class="hljs-operator">..&lt;</span><span class="hljs-number">100</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"dozens of"</span>)
<span class="hljs-keyword">default</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"many"</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="7">
<li>可以使用下划线<code>_</code>忽略某个值<br>
关于<code>case</code>匹配问题，属于模式匹配（Pattern Matching）的范畴</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> point <span class="hljs-operator">=</span> (<span class="hljs-number">1</span>, <span class="hljs-number">1</span>)
<span class="hljs-keyword">switch</span> point: {
<span class="hljs-keyword">case</span> (<span class="hljs-number">2</span>, <span class="hljs-number">2</span>):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"1"</span>)
<span class="hljs-keyword">case</span> (<span class="hljs-keyword">_</span>, <span class="hljs-number">0</span>):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
<span class="hljs-keyword">case</span> (<span class="hljs-operator">-</span><span class="hljs-number">2</span><span class="hljs-operator">...</span><span class="hljs-number">2</span>, <span class="hljs-number">0</span><span class="hljs-operator">...</span>):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"3"</span>)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>值绑定:</strong></p>
</blockquote>
<ul>
<li>8.值绑定，必要时<code>let</code>也可以改成<code>var</code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> point <span class="hljs-operator">=</span> (<span class="hljs-number">2</span>, <span class="hljs-number">0</span>)
<span class="hljs-keyword">switch</span> point: {
<span class="hljs-keyword">case</span> (<span class="hljs-keyword">let</span> x, <span class="hljs-number">0</span>):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"on the x-axis with an x value of <span class="hljs-subst">\(x)</span>"</span>)
<span class="hljs-keyword">case</span> (<span class="hljs-number">0</span>, <span class="hljs-keyword">let</span> y):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"on the y-axis with a y value of <span class="hljs-subst">\(y)</span>"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (x, y):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"somewhere else at (<span class="hljs-subst">\(x)</span>, <span class="hljs-subst">\(y)</span>)"</span>)
} <span class="hljs-comment">// on the x-axis with an x value of 2</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-34">9.5 where</h3>
<p>一般<code>where</code>用来结合条件语句进行过滤</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> point <span class="hljs-operator">=</span> (<span class="hljs-number">1</span>, <span class="hljs-operator">-</span><span class="hljs-number">1</span>)
<span class="hljs-keyword">switch</span> point {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (x, y) <span class="hljs-keyword">where</span> x <span class="hljs-operator">==</span> y:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"on the line x == y"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (x, y) <span class="hljs-keyword">where</span> x <span class="hljs-operator">==</span> <span class="hljs-operator">-</span>y:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"on the line x == -y"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (x, y):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"(x), (y) is just some arbitrary point"</span>)
}<span class="hljs-comment">// on the line x == -y</span>

<span class="hljs-comment">// 将所有正数加起来 </span>
<span class="hljs-keyword">var</span> numbers <span class="hljs-operator">=</span> [<span class="hljs-number">10</span>, <span class="hljs-number">20</span>, <span class="hljs-operator">-</span><span class="hljs-number">10</span>, <span class="hljs-operator">-</span><span class="hljs-number">20</span>, <span class="hljs-number">30</span>, <span class="hljs-operator">-</span><span class="hljs-number">30</span>]
<span class="hljs-keyword">var</span> sum <span class="hljs-operator">=</span> <span class="hljs-number">0</span> 

<span class="hljs-keyword">for</span> num <span class="hljs-keyword">in</span> numbers <span class="hljs-keyword">where</span> num <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> { <span class="hljs-comment">// 使用where来过滤num </span>
    sum <span class="hljs-operator">+=</span> num 
}
<span class="hljs-built_in">print</span>(sum) <span class="hljs-comment">// 60</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-35">9.6标签语句</h3>
<p>用<code>outer</code>来标识循环跳出的条件</p>
<pre><code class="hljs language-swift copyable" lang="swift">outer: <span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> <span class="hljs-number">1</span><span class="hljs-operator">...</span><span class="hljs-number">4</span> {
     <span class="hljs-keyword">for</span> k <span class="hljs-keyword">in</span> <span class="hljs-number">1</span><span class="hljs-operator">...</span><span class="hljs-number">4</span> {
         <span class="hljs-keyword">if</span> k <span class="hljs-operator">==</span> <span class="hljs-number">3</span> {
             <span class="hljs-keyword">continue</span> outer
         }
         <span class="hljs-keyword">if</span> i <span class="hljs-operator">==</span> <span class="hljs-number">3</span> {
             <span class="hljs-keyword">break</span> outer
         }
         <span class="hljs-built_in">print</span>(<span class="hljs-string">"i == <span class="hljs-subst">\(i)</span>, k == <span class="hljs-subst">\(k)</span>"</span>)
    }
}
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-36">10.函数</h2>
<h3 data-id="heading-37">10.1 函数的定义</h3>
<h4 data-id="heading-38">a.)有返回值的函数</h4>
<p>形参默认是<code>let</code>，也只能是<code>let</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { 
    <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2 
}
<span class="copy-code-btn">复制代码</span></code></pre>
<h4 data-id="heading-39">b.)无返回值的函数</h4>
<p>返回值Void的本质就是一个<code>空元组</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 三种写法相同</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sayHello</span>() -&gt; <span class="hljs-type">Void</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"Hello"</span>)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">sayHello</span>() -&gt; () {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"Hello"</span>)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">sayHello</span>() {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"Hello"</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-40">10.2 隐式返回（Implicit Return）</h3>
<p>如果整个函数体是一个单一的表达式，那么函数会隐式的返回这个表达式</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">+</span> v2 }

sum(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>)<span class="hljs-comment">//30</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-41">10.3 返回元组，实现多返回值</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">calculate</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; (sum: <span class="hljs-type">Int</span>, difference: <span class="hljs-type">Int</span>, average: <span class="hljs-type">Int</span>) {
    <span class="hljs-keyword">let</span> sum <span class="hljs-operator">=</span> v1 <span class="hljs-operator">+</span> v2
    <span class="hljs-keyword">return</span> (sum, v1 <span class="hljs-operator">-</span> v2, sum <span class="hljs-operator">&gt;&gt;</span> <span class="hljs-number">1</span>)
}

<span class="hljs-keyword">let</span> result <span class="hljs-operator">=</span> calculate(v1: <span class="hljs-number">20</span>, v2: <span class="hljs-number">10</span>)
result.sum <span class="hljs-comment">// 30 </span>
result.difference <span class="hljs-comment">// 10 </span>
result.average <span class="hljs-comment">// 15</span>
<span class="hljs-built_in">print</span>(result.sum, result.difference, result.average)
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-42">10.4 函数的文档注释</h3>
<p>可以通过一定格式书写注释，方便阅读</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">/// 求和【概述】</span>
<span class="hljs-comment">///</span>
<span class="hljs-comment">/// 将2个整数相加【更详细的描述】</span>
<span class="hljs-comment">///</span>
<span class="hljs-comment">/// - Parameter v1: 第1个整数</span>
<span class="hljs-comment">/// - Parameter v2: 第2个整数</span>
<span class="hljs-comment">/// - Returns: 2个整数的和</span>
<span class="hljs-comment">///</span>
<span class="hljs-comment">/// - Note:传入2个整数即可【批注】</span>
<span class="hljs-comment">///</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    v1 <span class="hljs-operator">+</span> v2
}
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/33a18a41153c4c13a44b4ad849fe7246~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w592" loading="lazy" class="medium-zoom-image"></p>
<p><a href="https://link.juejin.cn?target=https%3A%2F%2Fswift.org%2Fdocumentation%2Fapi-design-guidelines%2F" title="https://link.juejin.cn?target=https%3A%2F%2Fswift.org%2Fdocumentation%2Fapi-design-guidelines%2F" target="_blank">详细参照Apple官方的api设计准则</a></p>
<h3 data-id="heading-43">10.5 参数标签（Argument Label）</h3>
<ul>
<li>
<ol>
<li>可以修改参数标签</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">gotoWork</span>(<span class="hljs-params">at</span> <span class="hljs-params">time</span>: <span class="hljs-type">String</span>) {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"this time is <span class="hljs-subst">\(time)</span>"</span>)
} 
gotoWork(at: <span class="hljs-string">"8:00"</span>)<span class="hljs-comment">// this time is 08:00</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>可以使用下划线<code>_</code>省略参数标签，为了阅读性一般不建议省略</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">value1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
     value1 <span class="hljs-operator">+</span> value2
} 
sum(<span class="hljs-number">5</span>, <span class="hljs-number">5</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-44">10.6 默认参数值（Default Parameter Value）</h3>
<ul>
<li>
<ol>
<li>参数可以有默认值</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">check</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">"nobody"</span>, <span class="hljs-params">age</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">job</span>: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">"none"</span>) {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"name=(name), age=(age), job=(job)"</span>)
}

check(name: <span class="hljs-string">"Jack"</span>, age: <span class="hljs-number">20</span>, job: <span class="hljs-string">"Doctor"</span>)<span class="hljs-comment">// name=Jack, age=20, job=Doctor</span>
check(name: <span class="hljs-string">"Jack"</span>, age: <span class="hljs-number">20</span>)<span class="hljs-comment">// name=Jack, age=20, job=none</span>
check(age: <span class="hljs-number">20</span>, job: <span class="hljs-string">"Doctor"</span>)<span class="hljs-comment">// name=nobody, age=20, job=Doctor</span>
check(age: <span class="hljs-number">20</span>)<span class="hljs-comment">// name=nobody, age=20, job=none</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li><code>C++</code>的默认参数值有个限制：必须从右往左设置；由于<code>Swift</code>拥有参数标签，因此没有此类限制</li>
</ol>
</li>
<li>
<ol start="3">
<li>但是在省略参数标签时，需要特别注意，避免出错</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 这里的middle不可以省略参数标签</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">first</span>: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>, <span class="hljs-params">middle</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">last</span>: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">30</span>) { }
test(middle: <span class="hljs-number">20</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-45">10.7 可变参数（Variadic Parameter）</h3>
<ul>
<li>
<ol>
<li>一个函数<code>最多只能有一个</code>可变参数</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">numbers</span>: <span class="hljs-type">Int</span>...) -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-keyword">var</span> total <span class="hljs-operator">=</span> <span class="hljs-number">0</span> 
    <span class="hljs-keyword">for</span> number <span class="hljs-keyword">in</span> numbers {
        total <span class="hljs-operator">+=</span> number
    } 
    <span class="hljs-keyword">return</span> total
} 
sum(<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>紧跟在可变参数 后面的参数<strong>不能省略参数标签</strong></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 参数string不能省略标签</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">get</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">number</span>: <span class="hljs-type">Int</span>..., <span class="hljs-params">string</span>: <span class="hljs-type">String</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">other</span>: <span class="hljs-type">String</span>) { }
<span class="hljs-keyword">get</span>(<span class="hljs-number">10</span>, <span class="hljs-number">20</span>, string: <span class="hljs-string">"Jack"</span>, <span class="hljs-string">"Rose"</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>Swift自带的print函数</strong>
我们可以参考下<code>Swift</code>自带的<code>print函数</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2b9dfed8ee594b1a8d86bcc51cf365c7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w828" loading="lazy" class="medium-zoom-image"></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-built_in">print</span>(<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>, <span class="hljs-number">5</span>)
<span class="hljs-built_in">print</span>(<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>, <span class="hljs-number">5</span>, separator: <span class="hljs-string">" "</span>, terminator: <span class="hljs-string">"<span class="hljs-subst">\n</span>"</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-46">10.8 输入输出参数（In-Out Parameter）</h3>
<ul>
<li>
<p>可以用<code>inout</code>定义一个输入输出参数：<strong><code>可以在函数内部修改外部实参的值</code></strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">swapValues</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) {
    <span class="hljs-keyword">let</span> tmp <span class="hljs-operator">=</span> v1
    v1 <span class="hljs-operator">=</span> v2
    v2 <span class="hljs-operator">=</span> tmp
} 
<span class="hljs-keyword">var</span> num1 <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> num2 <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
swapValues(<span class="hljs-operator">&amp;</span>num1, <span class="hljs-operator">&amp;</span>num2)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<p>官方自带<code>swap</code>的交换函数就是使用的<code>inout</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/43952303c3bb471e8eba264435526b70~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w674" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>可以利用元组来进行参数交换</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">swapValues</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) {
        (v1, v2) <span class="hljs-operator">=</span> (v2, v1)
}

<span class="hljs-keyword">var</span> num1 <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> num2 <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
swapValues(<span class="hljs-operator">&amp;</span>num1, <span class="hljs-operator">&amp;</span>num2)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol>
<li>可变参数不能标记为<code>inout</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8263bf403bab49aaa912ba72fef57894~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w708" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="2">
<li><code>inout</code>参数不能有默认值
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e47a2fe1fb194de085c3ed5eccce501d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w704" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li><code>inout</code>参数只能传入可以被多次赋值的</li>
</ol>
<ul>
<li>常量只能在定义的时候赋值一次，所以下面会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/46eef03d01ab4aba8c89fcaa2e2c2115~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w712" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
<li>
<ol start="4">
<li><code>inout</code>参数的本质是地址传递</li>
</ol>
<ul>
<li>我们新建个项目，通过反汇编来观察其本质
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/36720e938a04480f8e81f35b0244a41d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w671" loading="lazy" class="medium-zoom-image"></li>
<li><code>leaq</code>表示的就是地址传递，可以看出在调用函数之前先将两个变量的地址放到了寄存器中
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1a7c91c1476246b2bde575232db7ee41~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1119" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
</ul>
<h3 data-id="heading-47">10.9 函数重载（Function Overload）</h3>
<ul>
<li>
<ol>
<li>函数重载的规则</li>
</ol>
<ul>
<li>函数名相同</li>
<li>参数个数不同 <code>||</code> 参数类型不同 <code>||</code> 参数标签不同</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-params">value1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">value2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { value1 <span class="hljs-operator">+</span> value2 } 
<span class="hljs-comment">// 参数个数不同</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">value1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value2</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value3</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { value1 <span class="hljs-operator">+</span> value2 <span class="hljs-operator">+</span>  value3 } 
<span class="hljs-comment">// 参数标签不同</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">a</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">b</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {a <span class="hljs-operator">+</span> b} 
<span class="hljs-comment">// 参数类型不同</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">a</span>: <span class="hljs-type">Double</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">b</span>: <span class="hljs-type">Double</span>) -&gt; <span class="hljs-type">Int</span> { a <span class="hljs-operator">+</span> b }
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>函数重载注意点</strong></p>
</blockquote>
<ul>
<li>
<ol start="2">
<li>返回值类型和函数重载无关
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/04ee76b3d99d48069327272c41494455~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w711" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>默认参数值和函数重载一起使用产生二义性时，编译器并不会报错（C++中会报错）</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 不建议的写法</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">value1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value2</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value3</span>: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">5</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">+</span> v2 <span class="hljs-operator">+</span> v3 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">value1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">+</span> v2 } 
<span class="hljs-comment">//会调用sum(v1: Int, v2: Int)</span>
sum(<span class="hljs-number">10</span>, <span class="hljs-number">2</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li>可变参数、省略参数标签、函数重载一起使用产生二义性时，编译器有可能会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/257277aa85cf430994085cd31cebe3f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w723" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h3 data-id="heading-48">10.10 内联函数（Inline Function）</h3>
<p>如果开启了编译器优化（<code>Release模式</code>默认会开启优化），编译器会自动将某些函数变成<code>内联函数</code></p>
<ul>
<li>将函数调用展开成函数体
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/acd280a16b4f4358b5177df8f50f02f2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w829" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p><strong>我们分别来观察下更改Debug模式下的优化选项，编译器做了什么</strong><br>
1.我们新建一个项目，项目代码如下
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b6edcb39c8e741bfa91d531988986c6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w551" loading="lazy" class="medium-zoom-image">
2. 然后我们先通过反汇编观察没有被优化时的编译器做了什么
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/358df9cebe764320bc634c24dc50f639~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1059" loading="lazy" class="medium-zoom-image">
可以看到会调用<code>test函数</code>，然后<code>test函数</code>里面再执行打印</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fd21694cfed94d89a13825e9a42fae1b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1051" loading="lazy" class="medium-zoom-image"></p>
<ol start="3">
<li>现在我们开启<code>Debug</code>模型下的优化选项，然后运行程序
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4fc27a11e5554a55a2c388751af7dce3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w619" loading="lazy" class="medium-zoom-image">
发现<code>print</code>打印直接就在<code>main函数</code>里执行了，没有了<code>test函数</code>的调用过程<br>
相当于<code>print函数</code>直接放到了<code>main函数</code>中，编译器会将函数调用展开成函数体
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5a509bfde464474a4cbe5e667545cac~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1061" loading="lazy" class="medium-zoom-image"></li>
</ol>
<blockquote>
<p><strong><code>哪些函数不会被内联</code></strong></p>
</blockquote>
<ul>
<li>函数体比较长</li>
<li>包含递归调用</li>
<li>包含动态派发（运行时的多态调用(OC、Swift混编的时候才会有运行时<code>,纯粹的Swift项目是没有runtime的</code>)）</li>
</ul>
<blockquote>
<p><strong><code>@inline</code></strong>
<strong>我们可以使用<code>@inline</code>关键字，来主动控制编译器是否做进行优化</strong></p>
</blockquote>
<ul>
<li>
<ol>
<li><code>@inline(nerver)</code>：永远不会被内联，即使开启了编译器优化</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-meta">@inline</span>(nerver) <span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li><code>@inline(__alaways)</code>：开启编译器优化后，即使代码很长，也会被内联（递归调用和动态派发除外）</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-meta">@inline</span>(__alaways) <span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>在<code>Release模式下</code>，编译器已经开启优化，会自动决定哪些函数需要内联，因此没必要使用<code>@inline</code></li>
</ol>
</li>
</ul>
<h3 data-id="heading-49">10.11 函数类型（Function Type）</h3>
<ul>
<li>
<ol>
<li>每一个函数都是有类型的，函数类型由<code>形参类型</code>、<code>返回值类型</code>组成</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {}  <span class="hljs-comment">// () -&gt; Void 或 () -&gt; ()</span>


<span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-params">a</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">b</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    a <span class="hljs-operator">+</span> b 
}<span class="hljs-comment">// (Int, Int) -&gt; Int</span>

<span class="hljs-comment">// 定义变量</span>
<span class="hljs-keyword">var</span> fn: (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> sum
fn(<span class="hljs-number">5</span>, <span class="hljs-number">3</span>) <span class="hljs-comment">//8  调用时不需要参数标签</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>函数类型作为<code>函数参数</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
   v1 <span class="hljs-operator">+</span> v2
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">difference</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
  v1 <span class="hljs-operator">-</span> v2
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">printResult</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">mathFn</span>: (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">a</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">b</span>: <span class="hljs-type">Int</span>) {
  mathFn(a, b)
}

printResult(difference, <span class="hljs-number">5</span>, <span class="hljs-number">2</span>)<span class="hljs-comment">// Result: 3</span>
printResult(sum, <span class="hljs-number">5</span>, <span class="hljs-number">2</span>)<span class="hljs-comment">// Result: 7</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>函数类型作为<code>函数返回值</code><br>
返回值是函数类型的函数叫做<strong>高阶函数（<code>Higher-Order Function</code>）</strong></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">next</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">input</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
  input <span class="hljs-operator">+</span> <span class="hljs-number">1</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">previous</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">input</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
  input <span class="hljs-operator">-</span> <span class="hljs-number">1</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">forward</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">forward</span>: <span class="hljs-type">Bool</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
  forward <span class="hljs-operator">?</span> next : previous
}

forward(<span class="hljs-literal">true</span>)(<span class="hljs-number">3</span>)<span class="hljs-comment">//4</span>
forward(<span class="hljs-literal">false</span>)(<span class="hljs-number">3</span>)<span class="hljs-comment">//2</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-50">10.12 typealias</h3>
<blockquote>
<p>用来给类型起别名</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">Byte</span> <span class="hljs-operator">=</span> <span class="hljs-type">Int8</span>
<span class="hljs-keyword">typealias</span> <span class="hljs-type">Short</span> <span class="hljs-operator">=</span> <span class="hljs-type">Int16</span>
<span class="hljs-keyword">typealias</span> <span class="hljs-type">Long</span> <span class="hljs-operator">=</span> <span class="hljs-type">Int64</span>

<span class="hljs-keyword">typealias</span> <span class="hljs-type">Date</span> <span class="hljs-operator">=</span> (year: <span class="hljs-type">String</span>, mouth: <span class="hljs-type">String</span>, day: <span class="hljs-type">String</span>)
<span class="hljs-keyword">func</span> <span class="hljs-title function_">getDate</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">date</span>: <span class="hljs-type">Date</span>) {
    <span class="hljs-built_in">print</span>(date.day)
    <span class="hljs-built_in">print</span>(date.<span class="hljs-number">0</span>)
}

getDate((<span class="hljs-string">"2011"</span>, <span class="hljs-string">"9"</span>, <span class="hljs-string">"10"</span>))


<span class="hljs-keyword">typealias</span> <span class="hljs-type">IntFn</span> <span class="hljs-operator">=</span> (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>

<span class="hljs-keyword">func</span> <span class="hljs-title function_">difference</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    v1 <span class="hljs-operator">-</span> v2
}

<span class="hljs-keyword">let</span> fn: <span class="hljs-type">IntFn</span> <span class="hljs-operator">=</span> difference
fn(<span class="hljs-number">20</span>, <span class="hljs-number">10</span>)

<span class="hljs-keyword">func</span> <span class="hljs-title function_">setFn</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">fn</span>: <span class="hljs-type">IntFn</span>) { }
setFn(difference)

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getFn</span>() -&gt; <span class="hljs-type">IntFn</span> { difference }
<span class="copy-code-btn">复制代码</span></code></pre>
<p>按照<code>Swift标准库</code>的定义，<code>Void</code>就是<code>空元组()</code></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6b84a65143cf4123a83a08f943af6be0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w314" loading="lazy" class="medium-zoom-image"></p>
<h3 data-id="heading-51">10.13 嵌套函数(Nested Function)</h3>
<ul>
<li>
<ol>
<li>将函数定义在函数内部</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">forward</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">forward</span>: <span class="hljs-type">Bool</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">func</span> <span class="hljs-title function_">next</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">input</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
                input <span class="hljs-operator">+</span> <span class="hljs-number">1</span>
        }

        <span class="hljs-keyword">func</span> <span class="hljs-title function_">previous</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">input</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
                input <span class="hljs-operator">-</span> <span class="hljs-number">1</span>
        }

        forward <span class="hljs-operator">?</span> next : previous
}

forward(<span class="hljs-literal">true</span>)(<span class="hljs-number">3</span>)<span class="hljs-comment">//4</span>
forward(<span class="hljs-literal">false</span>)(<span class="hljs-number">3</span>)<span class="hljs-comment">//2</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-52">11. 枚举</h2>
<h3 data-id="heading-53">11.1 枚举的基本用法</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Direction</span> {
    <span class="hljs-keyword">case</span> north
    <span class="hljs-keyword">case</span> south
    <span class="hljs-keyword">case</span> east
    <span class="hljs-keyword">case</span> west
}

<span class="hljs-comment">// 简便写法</span>
<span class="hljs-keyword">enum</span> <span class="hljs-title class_">Direction</span> {
    <span class="hljs-keyword">case</span> north, south, east, west
}

<span class="hljs-keyword">var</span> dir <span class="hljs-operator">=</span> <span class="hljs-type">Direction</span>.west
dir <span class="hljs-operator">=</span> <span class="hljs-type">Direction</span>.east
dir <span class="hljs-operator">=</span> .north
<span class="hljs-built_in">print</span>(dir) <span class="hljs-comment">// north</span>

<span class="hljs-keyword">switch</span> dir {
<span class="hljs-keyword">case</span> .north:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"north"</span>)
<span class="hljs-keyword">case</span> .south:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"south"</span>)
<span class="hljs-keyword">case</span> .east:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"east"</span>)
<span class="hljs-keyword">case</span> .west:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"west"</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-54">11.2 关联值（Associated Values）</h3>
<p>有时会将<code>枚举的成员值</code>和<code>其他类型的值</code>关联 <strong><code>存储在一起</code></strong> ,会非常有用</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Score</span> {
     <span class="hljs-keyword">case</span> points(<span class="hljs-type">Int</span>)
     <span class="hljs-keyword">case</span> grade(<span class="hljs-type">Character</span>)
}

<span class="hljs-keyword">var</span> score <span class="hljs-operator">=</span> <span class="hljs-type">Score</span>.points(<span class="hljs-number">96</span>)
score <span class="hljs-operator">=</span> .grade(<span class="hljs-string">"A"</span>)

<span class="hljs-keyword">switch</span> score {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .points(i):
  <span class="hljs-built_in">debugPrint</span>(i)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .grade(i):
  <span class="hljs-built_in">debugPrint</span>(i)
}
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Date</span> {
    <span class="hljs-keyword">case</span> digit(year: <span class="hljs-type">Int</span>, month: <span class="hljs-type">Int</span>, day: <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> string(<span class="hljs-type">String</span>)
}

<span class="hljs-keyword">var</span> date <span class="hljs-operator">=</span> <span class="hljs-type">Date</span>.digit(year: <span class="hljs-number">2020</span>, month: <span class="hljs-number">12</span>, day: <span class="hljs-number">5</span>)
date <span class="hljs-operator">=</span> .string(<span class="hljs-string">"2022-07-10"</span>)
<span class="hljs-comment">//必要时【let】也可以改为【var】</span>
<span class="hljs-keyword">switch</span> date {
<span class="hljs-keyword">case</span> .digit(<span class="hljs-keyword">let</span> year, <span class="hljs-keyword">let</span> month, <span class="hljs-keyword">let</span> day):
  <span class="hljs-built_in">debugPrint</span>(year, month, day)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .string(value):
  <span class="hljs-built_in">debugPrint</span>(value)
}
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p>关联值举例
<img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/213b2a7017054921aab9ff40adb7f450~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image">
<img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ef6d6b00633049bd9d7052042ffdb84f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Password</span> {
    <span class="hljs-keyword">case</span> number(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> gesture(<span class="hljs-type">String</span>)
}

<span class="hljs-keyword">var</span> pwd <span class="hljs-operator">=</span> <span class="hljs-type">Password</span>.number(<span class="hljs-number">5</span>, <span class="hljs-number">6</span>, <span class="hljs-number">4</span>, <span class="hljs-number">7</span>)
pwd <span class="hljs-operator">=</span> .gesture(<span class="hljs-string">"12369"</span>)

<span class="hljs-keyword">switch</span> pwd {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .number(n1, n2, n3, n4):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"number is "</span>, n1, n2, n3, n4)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .gesture(str):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"gesture is "</span>, str)
}
<span class="copy-code-btn">复制代码</span></code></pre>
<p>必要时,使用了枚举关联值的<code>switch-case</code>语句 里面的 <code>let</code>也可以改成<code>var</code></p>
<h3 data-id="heading-55">11.3 原始值（Raw Values）</h3>
<p>枚举成员可以使用<code>相同类型</code>的默认值预先关联，这个默认值叫做<code>原始值</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">PokerSuit</span>: <span class="hljs-title class_">String</span> {
   <span class="hljs-keyword">case</span> spade <span class="hljs-operator">=</span> <span class="hljs-string">"♠"</span>
   <span class="hljs-keyword">case</span> heart <span class="hljs-operator">=</span> <span class="hljs-string">"♥"</span>
   <span class="hljs-keyword">case</span> diamond <span class="hljs-operator">=</span> <span class="hljs-string">"♦"</span> 
   <span class="hljs-keyword">case</span> club <span class="hljs-operator">=</span> <span class="hljs-string">"♣"</span>
}

<span class="hljs-keyword">let</span> suit <span class="hljs-operator">=</span> <span class="hljs-type">PokerSuit</span>.heart
<span class="hljs-built_in">debugPrint</span>(suit)<span class="hljs-comment">// heart</span>
<span class="hljs-built_in">debugPrint</span>(suit.rawValue)<span class="hljs-comment">// ♥</span>
<span class="hljs-built_in">debugPrint</span>(<span class="hljs-type">PokerSuit</span>.spade.rawValue)<span class="hljs-comment">// ♠ </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Grade</span> : <span class="hljs-title class_">String</span> { 
    <span class="hljs-keyword">case</span> perfect <span class="hljs-operator">=</span> <span class="hljs-string">"A"</span> 
    <span class="hljs-keyword">case</span> great <span class="hljs-operator">=</span> <span class="hljs-string">"B"</span> 
    <span class="hljs-keyword">case</span> good <span class="hljs-operator">=</span> <span class="hljs-string">"C"</span> 
    <span class="hljs-keyword">case</span> bad <span class="hljs-operator">=</span> <span class="hljs-string">"D"</span> 
} 
<span class="hljs-built_in">print</span>(<span class="hljs-type">Grade</span>.perfect.rawValue) <span class="hljs-comment">// A </span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Grade</span>.great.rawValue) <span class="hljs-comment">// B </span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Grade</span>.good.rawValue) <span class="hljs-comment">// C</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Grade</span>.bad.rawValue) <span class="hljs-comment">// D</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>注意:</p>
<ul>
<li>原始值不占用枚举变量的内存</li>
<li>原始值只是关联上了枚举变量，所以原始值占用内存的大小并不是枚举变量的大小</li>
<li>底层实现是通过计算属性/函数来获取原始值的</li>
</ul>
<h3 data-id="heading-56">11.4 隐式原始值(Implicitly Assigned Raw Values)</h3>
<p>如果枚举的原始值类型是<code>Int</code>、<code>String</code>，Swift会自动分配原始值</p>
<p>字符串默认分配的原始值就是其变量名</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Direction</span>: <span class="hljs-title class_">String</span> {
    <span class="hljs-keyword">case</span> north <span class="hljs-operator">=</span> <span class="hljs-string">"north"</span>
    <span class="hljs-keyword">case</span> south <span class="hljs-operator">=</span> <span class="hljs-string">"south"</span>
    <span class="hljs-keyword">case</span> east <span class="hljs-operator">=</span> <span class="hljs-string">"east"</span>
    <span class="hljs-keyword">case</span> west <span class="hljs-operator">=</span> <span class="hljs-string">"west"</span>
}

<span class="hljs-comment">// 等价于上面</span>
<span class="hljs-keyword">enum</span> <span class="hljs-title class_">Direction</span>: <span class="hljs-title class_">String</span> {
     <span class="hljs-keyword">case</span> north, south, east, west
}
<span class="hljs-built_in">print</span>(<span class="hljs-type">Direction</span>.north) <span class="hljs-comment">// north</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Direction</span>.north.rawValue) <span class="hljs-comment">// north</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong><code>Int类型</code>默认分配的原始值是从0开始递增的数字</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Season</span>: <span class="hljs-title class_">Int</span> {
    <span class="hljs-keyword">case</span> spring, summer, autumn, winter
}

<span class="hljs-built_in">print</span>(<span class="hljs-type">Season</span>.spring.rawValue) <span class="hljs-comment">// 0</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Season</span>.summer.rawValue) <span class="hljs-comment">// 1</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Season</span>.autumn.rawValue) <span class="hljs-comment">// 2</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Season</span>.winter.rawValue) <span class="hljs-comment">// 3</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>如果有指定原始值的，下一个就会按照已经指定的值递增分配</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Season</span>: <span class="hljs-title class_">Int</span> {
    <span class="hljs-keyword">case</span> spring <span class="hljs-operator">=</span> <span class="hljs-number">1</span>, summer, autumn <span class="hljs-operator">=</span> <span class="hljs-number">4</span>, winter
} 
<span class="hljs-built_in">print</span>(<span class="hljs-type">Season</span>.spring.rawValue) <span class="hljs-comment">// 1</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Season</span>.summer.rawValue) <span class="hljs-comment">// 2</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Season</span>.autumn.rawValue) <span class="hljs-comment">// 4</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Season</span>.winter.rawValue) <span class="hljs-comment">// 5</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-57">11.5 递归枚举（Recursive Enumeration）</h3>
<ul>
<li>
<ol>
<li>递归枚举要用<code>indirect</code>关键字来修饰<code>enum</code>，不然会报错</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">indirect</span> <span class="hljs-keyword">enum</span> <span class="hljs-title class_">ArithExpr</span> {
    <span class="hljs-keyword">case</span> number(<span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> sum(<span class="hljs-type">ArithExpr</span>, <span class="hljs-type">ArithExpr</span>)
    <span class="hljs-keyword">case</span> difference(<span class="hljs-type">ArithExpr</span>, <span class="hljs-type">ArithExpr</span>)
}

或者

<span class="hljs-keyword">enum</span> <span class="hljs-title class_">ArithExpr</span> {
    <span class="hljs-keyword">case</span> number(<span class="hljs-type">Int</span>)
    <span class="hljs-keyword">indirect</span> <span class="hljs-keyword">case</span> sum(<span class="hljs-type">ArithExpr</span>, <span class="hljs-type">ArithExpr</span>)
    <span class="hljs-keyword">indirect</span> <span class="hljs-keyword">case</span> difference(<span class="hljs-type">ArithExpr</span>, <span class="hljs-type">ArithExpr</span>)
}

<span class="hljs-keyword">let</span> five <span class="hljs-operator">=</span> <span class="hljs-type">ArithExpr</span>.number(<span class="hljs-number">5</span>)
<span class="hljs-keyword">let</span> four <span class="hljs-operator">=</span> <span class="hljs-type">ArithExpr</span>.number(<span class="hljs-number">4</span>)
<span class="hljs-keyword">let</span> sum <span class="hljs-operator">=</span> <span class="hljs-type">ArithExpr</span>.sum(five, four)
<span class="hljs-keyword">let</span> two <span class="hljs-operator">=</span> <span class="hljs-type">ArithExpr</span>.number(<span class="hljs-number">2</span>)
<span class="hljs-keyword">let</span> difference <span class="hljs-operator">=</span> <span class="hljs-type">ArithExpr</span>.difference(sum, two)

<span class="hljs-keyword">func</span> <span class="hljs-title function_">calculate</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">expr</span>: <span class="hljs-type">ArithExpr</span>) -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-keyword">switch</span> expr {
    <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .number(value):
        <span class="hljs-keyword">return</span> value
    <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .sum(left, right):
        <span class="hljs-keyword">return</span> calculate(left) <span class="hljs-operator">+</span> calculate(right)
    <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .difference(left, right):
        <span class="hljs-keyword">return</span> calculate(left) <span class="hljs-operator">-</span> calculate(right)
    }
}

calculate(difference)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-58">11.6 MemoryLayout</h3>
<ul>
<li>
<ol>
<li>可以使用<code>MemoryLayout</code>获取数据类型占用的内存大小<br>
<code>64bit</code>的<code>Int类型</code>占<code>8个字节</code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Int</span>&gt;.stride <span class="hljs-comment">// 8, 分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Int</span>&gt;.size <span class="hljs-comment">// 8, 实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Int</span>&gt;.alignment <span class="hljs-comment">// 8, 内存对齐参数</span>

等同于

<span class="hljs-type">MemoryLayout</span>.size(ofValue: age)
<span class="hljs-type">MemoryLayout</span>.stride(ofValue: age)
<span class="hljs-type">MemoryLayout</span>.alignment(ofValue: age)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ol>
</li>
</ul>
<p>关联值和原始值的区别：</p>
<ul>
<li>
<p>关联值类型会存储到枚举变量里面</p>
</li>
<li>
<p>原始值因为一开始就会知道默认值是多少，所以只做记录，不会存储</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Password</span> {
    <span class="hljs-keyword">case</span> number(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> other
}

<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Password</span>&gt;.stride <span class="hljs-comment">// 40，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Password</span>&gt;.size <span class="hljs-comment">// 33，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Password</span>&gt;.alignment <span class="hljs-comment">// 8，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Session</span>: <span class="hljs-title class_">Int</span> {
     <span class="hljs-keyword">case</span> spring, summer, autnmn, winter
}

<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.stride <span class="hljs-comment">// 1，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.size <span class="hljs-comment">// 1，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.alignment <span class="hljs-comment">// 1，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>思考下面枚举变量的内存布局:</strong>
<strong>案例1:</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> { 
    <span class="hljs-keyword">case</span> test1, test2, test3 
} 
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test1
t <span class="hljs-operator">=</span> .test2 
t <span class="hljs-operator">=</span> .test3
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 1，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 1，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 1，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>案例2:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> : <span class="hljs-title class_">Int</span> {
    <span class="hljs-keyword">case</span> test1 <span class="hljs-operator">=</span> <span class="hljs-number">1</span>, test2 <span class="hljs-operator">=</span> <span class="hljs-number">2</span>, test3 <span class="hljs-operator">=</span> <span class="hljs-number">3</span> 
}
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test1 
t <span class="hljs-operator">=</span> .test2 
t <span class="hljs-operator">=</span> .test3
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 1，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 1，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 1，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>案例3:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> {
    <span class="hljs-keyword">case</span> test1(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> test2(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> test3(<span class="hljs-type">Int</span>) 
    <span class="hljs-keyword">case</span> test4(<span class="hljs-type">Bool</span>) 
    <span class="hljs-keyword">case</span> test5
} 
<span class="hljs-keyword">var</span> e <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test1(<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>)
e <span class="hljs-operator">=</span> .test2(<span class="hljs-number">4</span>, <span class="hljs-number">5</span>)
e <span class="hljs-operator">=</span> .test3(<span class="hljs-number">6</span>) 
e <span class="hljs-operator">=</span> .test4(<span class="hljs-literal">true</span>)
e <span class="hljs-operator">=</span> .test5
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 32，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 25，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 8，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>案例4:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">//注意！！！！ &nbsp; 枚举选项只有一个,所以实际用到的内存空间 为0，但是要存储一个成员值 所以对其参数为1，给其分配一个字节</span>
<span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> { 
    <span class="hljs-keyword">case</span> test
} 
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 1，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 0，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 1，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>案例5:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> { 
    <span class="hljs-keyword">case</span> test(<span class="hljs-type">Int</span>)
} 
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test(<span class="hljs-number">10</span>)
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 8，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 8，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 8，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>案例6:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> { 
    <span class="hljs-keyword">case</span> test(<span class="hljs-type">Int</span>)
} 
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test(<span class="hljs-number">10</span>)
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 8，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 8，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 8，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>案例7:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> { 
    <span class="hljs-keyword">case</span> test0 
    <span class="hljs-keyword">case</span> test1 
    <span class="hljs-keyword">case</span> test2 
    <span class="hljs-keyword">case</span> test4(<span class="hljs-type">Int</span>) 
    <span class="hljs-keyword">case</span> test5(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> test6(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Bool</span>)
} 
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test(<span class="hljs-number">10</span>)
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 32，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 25，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 8，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>案例8:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> { 
    <span class="hljs-keyword">case</span> test0 
    <span class="hljs-keyword">case</span> test1 
    <span class="hljs-keyword">case</span> test2 
    <span class="hljs-keyword">case</span> test4(<span class="hljs-type">Int</span>) 
    <span class="hljs-keyword">case</span> test5(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> test6(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Bool</span>, <span class="hljs-type">Int</span>)
} 
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test(<span class="hljs-number">10</span>)
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 32，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 32，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 8，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>案例9:</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> { 
    <span class="hljs-keyword">case</span> test0 
    <span class="hljs-keyword">case</span> test1 
    <span class="hljs-keyword">case</span> test2 
    <span class="hljs-keyword">case</span> test4(<span class="hljs-type">Int</span>) 
    <span class="hljs-keyword">case</span> test5(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> test6(<span class="hljs-type">Int</span>, <span class="hljs-type">Bool</span>, <span class="hljs-type">Int</span>)
} 
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test(<span class="hljs-number">10</span>)
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">//32，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">//25，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">//8，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-59">11.7 枚举变量的内存布局</h3>
<p>我们知道通过<code>MemoryLayout</code>可以获取到枚举占用内存的大小，那枚举变量分别占用多少内存呢？</p>
<p>要想知道枚举变量的大小，我们需要通过查看枚举变量的内存布局来进行分析</p>
<p><strong>枚举变量的分析准备</strong></p>
<p>我们可以需要通过<code>Xcode</code>里的<code>View Memory</code>选项来查看详细的内存布局</p>
<p>1.可以在运行程序时，通过控制台打印的枚举变量右键选择<code>View Memory of *</code>进入到内存布局的页面</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5735d2c4062b49689021b7ffda252428~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w440" loading="lazy" class="medium-zoom-image"></p>
<p>2.还可以从<code>Xcode</code>标题栏中选择<code>Debug -&gt; Debug Workflow -&gt; View Memory</code>进入到内存布局的页面</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f74e3c087f614a4290c7dfb272c1c0fb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w569" loading="lazy" class="medium-zoom-image"></p>
<p>3.进入到该页面，然后通过输入变量的内存地址来查看</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/818945a0d9f742fa9adacb4be5803ea3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1129" loading="lazy" class="medium-zoom-image"></p>
<p>4.我们可以下载一个小工具来获取到变量的内存地址</p>
<p>下载地址：<a href="https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FCoderMJLee%2FMems" target="_blank" title="https://github.com/CoderMJLee/Mems" ref="nofollow noopener noreferrer">github.com/CoderMJLee/…</a></p>
<p>5.然后将下载好的这个文件<code>Mems.swift</code>拖到自己的<code>Xcode</code>中</p>
<p>调用这个函数就可以了</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>t))
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>我们来分析下面的枚举变量的情况</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> {
    <span class="hljs-keyword">case</span> test1, test2, test3
}

<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test1
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>t))

t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test2
t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test3

<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride) <span class="hljs-comment">// 1</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size) <span class="hljs-comment">// 1</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment) <span class="hljs-comment">// 1</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>分别将断点打在给<code>枚举变量t</code>赋值的三句代码上，然后运行程序观察每次断点之后的内存布局有什么变化</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b3707ff07b0142e68f0e0471423f4ffc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1127" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e44ad20c1e9d4b6eb27ed0706ea5a625~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1124" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aaa99ae5371e49e4a708ba9b6431a077~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1124" loading="lazy" class="medium-zoom-image"></p>
<p>通过上图可以看到，每个枚举变量都分配了一个字节的大小，并且存储的值分别是0、1、2，我们可以知道这一个字节的大小就是用来存储<code>枚举成员值</code>的</p>
<p><strong>我们再来分析一个枚举变量的情况</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span>: <span class="hljs-title class_">Int</span> {
    <span class="hljs-keyword">case</span> test1 <span class="hljs-operator">=</span> <span class="hljs-number">1</span>, test2 <span class="hljs-operator">=</span> <span class="hljs-number">2</span>, test3 <span class="hljs-operator">=</span> <span class="hljs-number">3</span>
}

<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test1
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>t))

t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test2
t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test3

<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride) <span class="hljs-comment">// 1</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size) <span class="hljs-comment">// 1</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment) <span class="hljs-comment">// 1</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f8b07ec91b874385b845918724871429~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1131" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5ae262e720a4c3292957b0115e8dd6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1126" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/74a579894f614963a3781c23a51e7974~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1125" loading="lazy" class="medium-zoom-image"></p>
<p>通过上图可以看到，每个枚举变量存储的值也是0、1、2，并且分配了一个字节的大小</p>
<p>可以证明枚举变量的内存大小和原始值类型无关，而且枚举变量里存储的值和原始值也无关</p>
<p><strong>我们再来分析一个枚举变量的情况</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> {
    <span class="hljs-keyword">case</span> test1(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) <span class="hljs-comment">// 24</span>
    <span class="hljs-keyword">case</span> test2(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) <span class="hljs-comment">// 16</span>
    <span class="hljs-keyword">case</span> test3(<span class="hljs-type">Int</span>) <span class="hljs-comment">// 8</span>
    <span class="hljs-keyword">case</span> test4(<span class="hljs-type">Bool</span>) <span class="hljs-comment">// 1</span>
    <span class="hljs-keyword">case</span> test5 <span class="hljs-comment">// 1</span>
}

<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test1(<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>)
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>t))

t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test2(<span class="hljs-number">4</span>, <span class="hljs-number">5</span>)
t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test3(<span class="hljs-number">6</span>)
t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test4(<span class="hljs-literal">true</span>)
t <span class="hljs-operator">=</span> <span class="hljs-type">TestEnum</span>.test5

<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.size <span class="hljs-comment">// 25</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.stride <span class="hljs-comment">// 32</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">TestEnum</span>&gt;.alignment <span class="hljs-comment">// 8</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>我们先通过打印了解到枚举类型总共分配了<code>32个字节</code>，然后我们通过断点分别来观察枚举变量的内存布局</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3ddde575d93346e6b93197ab125ff3ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w773" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/27bda96fd6df42699bb75099bf79d174~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1124" loading="lazy" class="medium-zoom-image"></p>
<p>执行完第一句我们可以看到，前面24个字节分别用来存储关联值1、2、3，第25个字节用来存储成员值0，之所以分配32个字节是因为内存对齐的原因</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 调整排版后的内存布局如下所示</span>
<span class="hljs-number">01</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">02</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">03</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/666710ea86264b0ca18d84c9f0100b29~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w719" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7a641539783c44769d07ef161b6391d2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1193" loading="lazy" class="medium-zoom-image"></p>
<p>执行完第二句我们可以看到，前面16个字节分半用来存储关联值4、5，然后第25个字节用来存储成员值1</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 调整排版后的内存布局如下所示</span>
<span class="hljs-number">04</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">05</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">01</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4ffec0c54ef14fbca354e62552e34d0f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w563" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4289e9afdf1346108ace6a521d34736b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1196" loading="lazy" class="medium-zoom-image"></p>
<p>执行完第三句我们可以看到，前面8个字节分半用来存储关联值6，然后第25个字节用来存储成员值2</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 调整排版后的内存布局如下所示</span>
<span class="hljs-number">06</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">02</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dab2856fa3a54d95b304759492b0118c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w665" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ff4710127fa346a39c3400dad0b0e575~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1192" loading="lazy" class="medium-zoom-image"></p>
<p>执行完第四句我们可以看到，由于是Bool类型，那么只用了第一个字节来存储关联值1，然后第25个字节用来存储成员值3</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 调整排版后的内存布局如下所示</span>
<span class="hljs-number">01</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">03</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f1e11f59919e4b6c8bc4331127debff1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w676" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2227a5c5afbe423ebed7698a7a15be28~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1191" loading="lazy" class="medium-zoom-image"></p>
<p>执行完最后一句我们可以看到，由于没有关联值，那么只用了第25个字节存储成员值4</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 调整排版后的内存布局如下所示</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="hljs-number">04</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span> <span class="hljs-number">00</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>总结：内存分配情况：一个字节存储成员值，n个字节存储关联值（n取占用内存最大的关联值），任何一个case的关联值都共有这n个字节</strong></p>
<p>我们再来看几个情况</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> {
    <span class="hljs-keyword">case</span> test
}

<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.stride <span class="hljs-comment">// 1，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.size <span class="hljs-comment">// 0，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.alignment <span class="hljs-comment">// 1，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>如果枚举里只有一个<code>case</code>，那么实际用到的空间为0，都不用特别分配内存来进行存储</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span> {
    <span class="hljs-keyword">case</span> test(<span class="hljs-type">Int</span>)
}

<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.stride <span class="hljs-comment">// 8，分配占用的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.size <span class="hljs-comment">// 8，实际用到的空间大小</span>
<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Session</span>&gt;.alignment <span class="hljs-comment">// 8，对齐参数</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>可以看到分配的内存大小就是关联值类型决定的，因为只有一个<code>case</code>，所以都不需要再额外分配内存来存储是哪个<code>case</code>了</p>
<h2 data-id="heading-60">12. 可选项（Optional）</h2>
<ul>
<li>
<ol>
<li>可选项，一般也叫可选类型，它允许将值设置为<code>nil</code></li>
</ol>
</li>
<li>
<ol start="2">
<li>在类型名称后面加个<code>问号</code> <code>?</code>来定义一个可选项</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果可选类型定义的时候没有给定值，默认值就是<code>nil</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>?

等价于
<span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>如果可选类型定义的时候赋值了，那么就是一个<code>Optional类型</code>的值</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>? <span class="hljs-operator">=</span> <span class="hljs-string">"Jack"</span> <span class="hljs-comment">// Optional(Jack)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li>可选类型也<code>可以作为函数返回值</code>使用</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> array <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>] 
<span class="hljs-keyword">func</span> <span class="hljs-title function_">get</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>? {
    <span class="hljs-keyword">if</span> index <span class="hljs-operator">&lt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">||</span> index <span class="hljs-operator">&gt;=</span> array.count {
        <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span>
    } 
    <span class="hljs-keyword">return</span> array[index]
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-61">12.1 强制解包（Forced Unwrapping）</h3>
<p>可选项是对其他类型的一层包装，可以理解为一个盒子</p>
<ul>
<li>
<ol>
<li>如果为<code>nil</code>，那么它就是个空盒子</li>
</ol>
</li>
<li>
<ol start="2">
<li>如果不为<code>nil</code>，那么盒子里装的是：<strong>被包装类型的数据</strong></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>?
age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
age <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>可选关系的类型大致如下图:
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bbb2195a00c4cf190a113afb28a8a07~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w606" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
<li>
<ol start="3">
<li>如果要从可选项中取出被包装的数据（将盒子里装的东西取出来），需要使用<code>感叹号</code> <code>!</code>进行强制解包</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> ageInt <span class="hljs-operator">=</span> age<span class="hljs-operator">!</span>
ageInt <span class="hljs-operator">+=</span> <span class="hljs-number">10</span> <span class="hljs-comment">// ageInt为Int类型</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>如果对值为<code>nil</code>的可选项（空盒子）进行强制解包，将会产生运行时错误
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e6b492766979492a9eb881d23be02d29~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w668" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h3 data-id="heading-62">12.2 可选项绑定（Optional Binding）</h3>
<ul>
<li>
<ol>
<li>我们可以判断可选项是否包含值</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> number <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(<span class="hljs-string">"123"</span>) <span class="hljs-comment">// number为Int?</span>

<span class="hljs-keyword">if</span> number <span class="hljs-operator">!=</span> <span class="hljs-literal">nil</span> {
    <span class="hljs-built_in">print</span>(number<span class="hljs-operator">!</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>还可以使用<code>可选项绑定</code>来判断可选项是否包含值</li>
</ol>
<ul>
<li>如果包含就<code>自动解包</code>，把值赋给一个<code>临时的常量（let）或者变量（var）</code>，并返回<code>true</code>，否则返回<code>false</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> number <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(<span class="hljs-string">"123"</span>) {
     <span class="hljs-built_in">print</span>(<span class="hljs-string">"字符串转换整数成功：(number)"</span>)
     <span class="hljs-comment">// number是强制解包之后的Int值</span>
     <span class="hljs-comment">// number作用域仅限于这个大括号</span>
} <span class="hljs-keyword">else</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"字符串转换整数失败"</span>)
}
<span class="hljs-comment">// 字符串转换整数成功：123</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果判断条件有多个，可以合并在一起，用逗号<code>,</code>来分隔开</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> first <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(<span class="hljs-string">"4"</span>) {
    <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> second <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(<span class="hljs-string">"42"</span>) {
        <span class="hljs-keyword">if</span> first <span class="hljs-operator">&lt;</span> second <span class="hljs-operator">&amp;&amp;</span> second <span class="hljs-operator">&lt;</span> <span class="hljs-number">100</span> {
             <span class="hljs-built_in">print</span>(<span class="hljs-string">"(first) &lt; (second) &lt; 100"</span>) 
        } 
    } 
}

等于

<span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> first <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(<span class="hljs-string">"4"</span>)，
    <span class="hljs-keyword">let</span> second <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(<span class="hljs-string">"42"</span>)，
    first <span class="hljs-operator">&lt;</span> second <span class="hljs-operator">&amp;&amp;</span> second <span class="hljs-operator">&lt;</span> <span class="hljs-number">100</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"(first) &lt; (second) &lt; 100"</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li><code>while循环</code>中使用可选项绑定</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> strs <span class="hljs-operator">=</span> [<span class="hljs-string">"10"</span>, <span class="hljs-string">"20"</span>, <span class="hljs-string">"abc"</span>, <span class="hljs-string">"-20"</span>, <span class="hljs-string">"30"</span>]

<span class="hljs-keyword">var</span> index <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
<span class="hljs-keyword">var</span> sum <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
<span class="hljs-keyword">while</span> <span class="hljs-keyword">let</span> num <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(strs[index]), num <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> {
    sum <span class="hljs-operator">+=</span> num
    index <span class="hljs-operator">+=</span> <span class="hljs-number">1</span>
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-63">12.3 空合并运算符（Nil-Coalescing Operator）</h3>
<p>我们可以使用空合并运算符<code>??</code>来对前一个值是否有值进行判断:</p>
<ul>
<li>如果前一个值为<code>nil</code>，就会返回后一个值
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a597a82e046946ada36ba2ec4a8f3667~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w860" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87b1be7f3acf4654bd9dc5f531b21aeb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w871" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p><strong>详细用法如下：</strong></p>
<ul>
<li><strong>a <code>??</code> b</strong>
<ul>
<li><code>a</code>是<strong>可选项</strong></li>
<li><code>b</code>是<strong>可选项</strong>或者<strong>不是可选项</strong></li>
<li><code>b</code>跟<code>a</code>的<strong>存储类型必须相同</strong></li>
<li></li>
<li>如果<code>a</code>不为<code>nil</code>，就返回<code>a</code>
<ul>
<li>如果<code>b</code>不是可选项，返回<code>a</code>时会自动解包</li>
</ul>
</li>
<li>如果<code>a</code>为<code>nil</code>，就返回<code>b</code></li>
</ul>
</li>
</ul>
<blockquote>
<p><strong>结果的类型取决于<code>??</code>后面的值类型是什么</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> a: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
<span class="hljs-keyword">let</span> b: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">2</span>
<span class="hljs-keyword">let</span> c <span class="hljs-operator">=</span> a <span class="hljs-operator">??</span> b <span class="hljs-comment">// c是Int , 1 </span>

<span class="hljs-keyword">let</span> a: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="hljs-keyword">let</span> b: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">2</span>
<span class="hljs-keyword">let</span> c <span class="hljs-operator">=</span> a <span class="hljs-operator">??</span> b <span class="hljs-comment">// c是Int , 2</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>多个<code>??</code>一起使用</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> a: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
<span class="hljs-keyword">let</span> b: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">2</span>
<span class="hljs-keyword">let</span> c <span class="hljs-operator">=</span> a <span class="hljs-operator">??</span> b <span class="hljs-operator">??</span> <span class="hljs-number">3</span> 

<span class="hljs-keyword">let</span> a: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="hljs-keyword">let</span> b: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">2</span>
<span class="hljs-keyword">let</span> c <span class="hljs-operator">=</span> a <span class="hljs-operator">??</span> b <span class="hljs-operator">??</span> <span class="hljs-number">3</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> a: <span class="hljs-type">Int</span>??? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> b: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
<span class="hljs-keyword">var</span> c: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">30</span>

<span class="hljs-built_in">print</span>(a <span class="hljs-operator">??</span> b) <span class="hljs-comment">// Optional(Optional(10))</span>
<span class="hljs-built_in">print</span>(a <span class="hljs-operator">??</span> c) <span class="hljs-comment">// Optional(Optional(10))</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong><code>??</code>和<code>if let</code>配合使用</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> a: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="hljs-keyword">let</span> b: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">2</span>
<span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> c <span class="hljs-operator">=</span> a <span class="hljs-operator">??</span> b {
   <span class="hljs-built_in">print</span>(c)
}<span class="hljs-comment">// 类似于if a != nil || b != nil</span>

<span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> c <span class="hljs-operator">=</span> a, <span class="hljs-keyword">let</span> d <span class="hljs-operator">=</span> b {
   <span class="hljs-built_in">print</span>(c)
   <span class="hljs-built_in">print</span>(d)
}<span class="hljs-comment">// 类似于if a != nil &amp;&amp; b != nil</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-64">12.4 guard语句</h3>
<ul>
<li>
<ol>
<li>当<code>guard语句</code>的条件为<code>false</code>时，就会执行大括号里面的代码</li>
</ol>
</li>
<li>
<ol start="2">
<li>当<code>guard语句</code>的条件为<code>true</code>时，就会跳过<code>guard语句</code></li>
</ol>
</li>
<li>
<ol start="3">
<li><code>guard语句</code>适合用来“提前退出”</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">guard</span> 条件 <span class="hljs-keyword">else</span> {
    <span class="hljs-comment">// do something....</span>
    退出当前作用域
    <span class="hljs-comment">// return、break、continue、throw error</span>
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>当使用<code>guard语句</code>进行可选项绑定时，绑定的<code>常量（let）、变量（var）</code>也能在外层作用域中使用</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">login</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">info</span>: [<span class="hljs-params">String</span> : <span class="hljs-type">String</span>]) {
        <span class="hljs-keyword">guard</span> <span class="hljs-keyword">let</span> username <span class="hljs-operator">=</span> info[<span class="hljs-string">"username"</span>] <span class="hljs-keyword">else</span> {
                <span class="hljs-built_in">print</span>(<span class="hljs-string">"请输入用户名"</span>)
                <span class="hljs-keyword">return</span>
        }

        <span class="hljs-keyword">guard</span> <span class="hljs-keyword">let</span> password <span class="hljs-operator">=</span> info[<span class="hljs-string">"password"</span>] <span class="hljs-keyword">else</span> {
                <span class="hljs-built_in">print</span>(<span class="hljs-string">"请输入密码"</span>)
                <span class="hljs-keyword">return</span>
        }

        <span class="hljs-comment">// if username ....</span>
        <span class="hljs-comment">// if password ....</span>
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"用户名：(username)"</span>, <span class="hljs-string">"密码：(password)"</span>, <span class="hljs-string">"登录ing"</span>)
}
login([<span class="hljs-string">"username"</span> : <span class="hljs-string">"jack"</span>, <span class="hljs-string">"password"</span> : <span class="hljs-string">"123456"</span>]) <span class="hljs-comment">// 用户名：jack 密码：123456 登陆ing </span>
login([<span class="hljs-string">"password"</span> : <span class="hljs-string">"123456"</span>]) <span class="hljs-comment">// 请输入密码 </span>
login([<span class="hljs-string">"username"</span> : <span class="hljs-string">"jack"</span>]) <span class="hljs-comment">// 请输入用户名</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>在没有<code>guard</code>语句之前,用if-else条件分支语句代码如下(比对):</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">login</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">info</span>: [<span class="hljs-params">String</span> : <span class="hljs-type">String</span>]) { 
    <span class="hljs-keyword">let</span> username: <span class="hljs-type">String</span>
    <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> tmp <span class="hljs-operator">=</span> info[<span class="hljs-string">"username"</span>] {
        username <span class="hljs-operator">=</span> tmp
    } <span class="hljs-keyword">else</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"请输入用户名"</span>)
        <span class="hljs-keyword">return</span> 
    } 
    
    <span class="hljs-keyword">let</span> password: <span class="hljs-type">String</span>
    <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> tmp <span class="hljs-operator">=</span> info[<span class="hljs-string">"password"</span>] {
        password <span class="hljs-operator">=</span> tmp 
    } <span class="hljs-keyword">else</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"请输入密码"</span>)
        <span class="hljs-keyword">return</span> 
    }
    <span class="hljs-comment">// if username ....</span>
    <span class="hljs-comment">// if password ....</span>
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"用户名：<span class="hljs-subst">\(username)</span>"</span>, <span class="hljs-string">"密码：<span class="hljs-subst">\(password)</span>"</span>, <span class="hljs-string">"登陆ing"</span>) 
}
login([<span class="hljs-string">"username"</span> : <span class="hljs-string">"jack"</span>, <span class="hljs-string">"password"</span> : <span class="hljs-string">"123456"</span>]) <span class="hljs-comment">// 用户名：jack 密码：123456 登陆ing </span>
login([<span class="hljs-string">"password"</span> : <span class="hljs-string">"123456"</span>]) <span class="hljs-comment">// 请输入密码 </span>
login([<span class="hljs-string">"username"</span> : <span class="hljs-string">"jack"</span>]) <span class="hljs-comment">// 请输入用户名</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-65">12.5 隐式解包（Implicitly Unwrapped Optional）</h3>
<ul>
<li>
<ol>
<li>在某些情况下，可选项一旦被设定值之后，就会一直拥有值</li>
</ol>
</li>
<li>
<ol start="2">
<li>在这种情况下，可以去掉检查，也不必每次访问的时候都进行解包，因为他能确定每次访问的时候都有值</li>
</ol>
</li>
<li>
<ol start="3">
<li>可以在类型后面加个感叹号<code>!</code>定义一个隐式解包的可选项</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> num1: <span class="hljs-type">Int</span>! <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">let</span> num2: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> num1

<span class="hljs-keyword">if</span> num1 <span class="hljs-operator">!=</span> <span class="hljs-literal">nil</span> {
    <span class="hljs-built_in">print</span>(num1 <span class="hljs-operator">+</span> <span class="hljs-number">6</span>)
}

<span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> num3 <span class="hljs-operator">=</span> num1 {
    <span class="hljs-built_in">print</span>(num3)
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<p>如果对空值的可选项进行隐式解包，也会报错:
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6f4c0ffe2df948bd931cbbde5d9828fc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w687" loading="lazy" class="medium-zoom-image"></p>
<p>用隐式解包的可选项类型，<strong>大多数是希望别人要给定一个不为空的值</strong></p>
<ul>
<li>如果别人传的是个空值那就报错，目的就是制定你的规则，<strong>更多适用于做一个接口来接收参数</strong>；</li>
<li><strong>更多还是建议不使用该类型</strong></li>
</ul>
<h3 data-id="heading-66">12.6 字符串插值</h3>
<ul>
<li>
<ol>
<li>可选项在字符串插值或者直接打印时，编译器会发出警告
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5fe6df8f0c1e47dca77116ea8eba93aa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w708" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="2">
<li>至少有三种方法消除警告</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

<span class="hljs-built_in">print</span>(<span class="hljs-string">"My age is <span class="hljs-subst">\(age<span class="hljs-operator">!</span>)</span>"</span>) <span class="hljs-comment">// My age is 10</span>
<span class="hljs-built_in">print</span>(<span class="hljs-string">"My age is <span class="hljs-subst">\(String(describing: age))</span>"</span>) <span class="hljs-comment">// My age is Optional(10)</span>
<span class="hljs-built_in">print</span>(<span class="hljs-string">"My age is <span class="hljs-subst">\(age <span class="hljs-operator">??</span> <span class="hljs-number">0</span>)</span>"</span>) <span class="hljs-comment">// My age is 10</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-67">12.7 多重可选项</h3>
<ul>
<li>
<ol>
<li>看下面几个可选类型，可以用以下图片来解析</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num1: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> num2: <span class="hljs-type">Int</span>?? <span class="hljs-operator">=</span> num1
<span class="hljs-keyword">var</span> num3: <span class="hljs-type">Int</span>?? <span class="hljs-operator">=</span> <span class="hljs-number">10</span> 

<span class="hljs-built_in">print</span>(num2 <span class="hljs-operator">==</span> num3) <span class="hljs-comment">// true</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c8d7cd77721747a595d8d6d7ddfeaed4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w787" loading="lazy" class="medium-zoom-image"></p>
</li>
<li>
<ol start="2">
<li>可使用<code>lldb</code>指令<code>frame variable -R</code>或者<code>fr v -R</code>查看区别
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/543a56b813164199980919899a2adbb6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1124" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>看下面几个可选类型，可以用以下图片来解析</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num1: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="hljs-keyword">var</span> num2: <span class="hljs-type">Int</span>?? <span class="hljs-operator">=</span> num1
<span class="hljs-keyword">var</span> num3: <span class="hljs-type">Int</span>?? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>

<span class="hljs-built_in">print</span>(num2 <span class="hljs-operator">==</span> num3) <span class="hljs-comment">// false</span>
<span class="hljs-built_in">print</span>(num3 <span class="hljs-operator">==</span> num1) <span class="hljs-comment">// false（因为类型不同）</span>

(num2 <span class="hljs-operator">??</span> <span class="hljs-number">1</span>) <span class="hljs-operator">??</span> <span class="hljs-number">2</span> <span class="hljs-comment">// 2</span>
(num3 <span class="hljs-operator">??</span> <span class="hljs-number">1</span>) <span class="hljs-operator">??</span> <span class="hljs-number">2</span> <span class="hljs-comment">// 1</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f1a5e933b9b245b2a641a9ef21cb13b9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w784" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>
<ol start="4">
<li>不管是多少层可选项，一旦赋值为<code>nil</code>，就只有最外层一个大盒子<br>
可使用<code>lldb</code>指令<code>frame variable -R</code>或者<code>fr v -R</code>查看区别
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/154d7c248b6a4837a648d63e71d4868f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1126" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-68">13. 闭包</h2>
<h3 data-id="heading-69">13.1 闭包表达式（Closure Expression）</h3>
<ul>
<li>
<ol>
<li>在Swift中，可以通过<code>func</code>定义一个函数，也可以通过<code>闭包表达式</code>定义一个函数</li>
</ol>
</li>
<li>
<ol start="2">
<li>闭包表达式格式如下:</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift">{
    (参数列表) -&gt; 返回值类型 <span class="hljs-keyword">in</span>
    函数体代码
}
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> {
    (v1: <span class="hljs-type">Int</span>, v2: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> <span class="hljs-keyword">in</span>
    <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2
}
fn(<span class="hljs-number">10</span>, <span class="hljs-number">20</span>)

{
    (v1: <span class="hljs-type">Int</span>, v2: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> <span class="hljs-keyword">in</span>
    <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2
}(<span class="hljs-number">10</span>, <span class="hljs-number">20</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>闭包表达式的简写如下:</li>
</ol>
<ul>
<li>case1</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> {
    (v1: <span class="hljs-type">Int</span>, v2: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> <span class="hljs-keyword">in</span>
    <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2
}

<span class="hljs-keyword">var</span> fn: (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-variable">$1</span> }
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>case2</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">exec</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">fn</span>: (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>) {
    <span class="hljs-built_in">print</span>(fn(v1, v2))
}


exec(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>) {
    (v1, v2) -&gt; <span class="hljs-type">Int</span> <span class="hljs-keyword">in</span>
    <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2
}

exec(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>, fn: {
    (v1, v2) -&gt; <span class="hljs-type">Int</span> <span class="hljs-keyword">in</span>
    <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2
})

exec(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>, fn: {
    (v1, v2) -&gt; <span class="hljs-type">Int</span> <span class="hljs-keyword">in</span>
    v1 <span class="hljs-operator">+</span> v2
})

exec(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>, fn: {
    v1, v2 <span class="hljs-keyword">in</span> <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2
})

exec(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>, fn: {
    v1, v2 <span class="hljs-keyword">in</span> v1 <span class="hljs-operator">+</span> v2
})

exec(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>, fn: { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-variable">$1</span> })

exec(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>, fn: <span class="hljs-operator">+</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-70">13.2 尾随闭包</h3>
<ul>
<li>
<ol>
<li>如果将一个<strong>很长的闭包表达式</strong>作为<code>函数的最后一个实参</code>，使用尾随闭包可以增强函数的可读性</li>
</ol>
</li>
<li>
<ol start="2">
<li>尾随闭包是一个被书写在函数调用括号外面（后面）的闭包表达式</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">exec</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">fn</span>: (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>) {
    <span class="hljs-built_in">print</span>(fn(v1, v2))
}

exec(v1: <span class="hljs-number">10</span>, v2: <span class="hljs-number">20</span>) {
    <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-variable">$1</span>
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果闭包表达式是函数的唯一实参，而且使用了尾随闭包的语法，那就不需要在函数名后边写圆括号</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">exec</span>(<span class="hljs-params">fn</span>: (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>) {
    <span class="hljs-built_in">print</span>(fn(<span class="hljs-number">1</span>, <span class="hljs-number">2</span>))
}

exec(fn: { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-variable">$1</span> })
exec() { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-variable">$1</span> }
exec { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-variable">$1</span> }
exec { <span class="hljs-keyword">_</span>, <span class="hljs-keyword">_</span> <span class="hljs-keyword">in</span> <span class="hljs-number">10</span> }
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>Swift中的<code>sort函数</code>用来排序的，使用的就是闭包的写法</strong>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f9ca96482e64b23a2070103d27e0864~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w449" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c14249c8cbee44eabecb4d75ac969fbc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w597" loading="lazy" class="medium-zoom-image"></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> nums <span class="hljs-operator">=</span> [<span class="hljs-number">11</span>, <span class="hljs-number">2</span>, <span class="hljs-number">18</span>, <span class="hljs-number">6</span>, <span class="hljs-number">5</span>, <span class="hljs-number">68</span>, <span class="hljs-number">45</span>]

<span class="hljs-comment">//1.</span>
nums.sort()

<span class="hljs-comment">//2.</span>
nums.sort { (i1, i2) -&gt; <span class="hljs-type">Bool</span> <span class="hljs-keyword">in</span>
    i1 <span class="hljs-operator">&lt;</span> i2
}

<span class="hljs-comment">//3.</span>
nums.sort(by: { (i1, i2) <span class="hljs-keyword">in</span> <span class="hljs-keyword">return</span> i1 <span class="hljs-operator">&lt;</span> i2 })

<span class="hljs-comment">//4.</span>
nums.sort(by: { (i1, i2) <span class="hljs-keyword">in</span> <span class="hljs-keyword">return</span> i1 <span class="hljs-operator">&lt;</span> i2 })

<span class="hljs-comment">//5.</span>
nums.sort(by: { (i1, i2) <span class="hljs-keyword">in</span> i1 <span class="hljs-operator">&lt;</span> i2 })

<span class="hljs-comment">//6.</span>
nums.sort(by: { <span class="hljs-variable">$0</span> <span class="hljs-operator">&lt;</span> <span class="hljs-variable">$1</span> })

<span class="hljs-comment">//7.</span>
nums.sort(by: <span class="hljs-operator">&lt;</span>)

<span class="hljs-comment">//8.</span>
nums.sort() { <span class="hljs-variable">$0</span> <span class="hljs-operator">&lt;</span> <span class="hljs-variable">$1</span> }

<span class="hljs-comment">//9.</span>
nums.sort { <span class="hljs-variable">$0</span> <span class="hljs-operator">&lt;</span> <span class="hljs-variable">$1</span> }
 
<span class="hljs-comment">//10.</span>
<span class="hljs-built_in">print</span>(nums) <span class="hljs-comment">// [2, 5, 6, 11, 18, 45, 68]</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-71">13.3 闭包的定义（Closure）</h3>
<p>网上有各种关于闭包的定义，个人觉得比较严谨的定义是:\</p>
<ul>
<li>
<p>一个函数和它所捕获的<code>变量/常量</code>环境组合起来，称为闭包</p>
<ul>
<li>一般指定义在函数内部的函数</li>
<li>一般它捕获的是外层函数的局部变量\常量</li>
<li>全局变量,全局都可以访问,内存只有一份,且只要程序不停止运行,其内存就不会回收</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">Fn</span> <span class="hljs-operator">=</span> (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getFn</span>() -&gt; <span class="hljs-type">Fn</span> {
    <span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        num <span class="hljs-operator">+=</span> i
        <span class="hljs-keyword">return</span> num
    }
    <span class="hljs-keyword">return</span> plus
}
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">getFn</span>() -&gt; <span class="hljs-type">Fn</span> {
    <span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">return</span> {
        num <span class="hljs-operator">+=</span> <span class="hljs-variable">$0</span>
        <span class="hljs-keyword">return</span> num
    }
}
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"> <span class="hljs-keyword">var</span> fn1 <span class="hljs-operator">=</span> getFn()
 <span class="hljs-keyword">var</span> fn2 <span class="hljs-operator">=</span> getFn() 
 
 fn1(<span class="hljs-number">1</span>) <span class="hljs-comment">// 1</span>
 fn2(<span class="hljs-number">2</span>) <span class="hljs-comment">// 2</span>
 fn1(<span class="hljs-number">3</span>) <span class="hljs-comment">// 4 </span>
 fn2(<span class="hljs-number">4</span>) <span class="hljs-comment">// 6</span>
 fn1(<span class="hljs-number">5</span>) <span class="hljs-comment">// 9 </span>
 fn2(<span class="hljs-number">6</span>) <span class="hljs-comment">// 12</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>通过汇编分析闭包的实现</strong>
看下面示例代码，分别打印为多少</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">getFn</span>() -&gt; <span class="hljs-type">Fn</span> {
    <span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        num <span class="hljs-operator">+=</span> i
        <span class="hljs-keyword">return</span> num
    }
    <span class="hljs-keyword">return</span> plus
}

<span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> getFn()

<span class="hljs-built_in">print</span>(fn(<span class="hljs-number">1</span>)) <span class="hljs-comment">// 1</span>
<span class="hljs-built_in">print</span>(fn(<span class="hljs-number">2</span>)) <span class="hljs-comment">// 3</span>
<span class="hljs-built_in">print</span>(fn(<span class="hljs-number">3</span>)) <span class="hljs-comment">// 6</span>
<span class="hljs-built_in">print</span>(fn(<span class="hljs-number">4</span>)) <span class="hljs-comment">// 10</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>我们通过反汇编来观察:
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d6738fd229b74dda8a490a4af0749cb6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1012" loading="lazy" class="medium-zoom-image">
通过这句调用可以看出:</p>
<ul>
<li>在<code>return plus</code>之前，闭包(表层通过<code>allicObject</code>)底层会调用<code>malloc函数</code>进行堆内存的分配，也就是将拷贝num的值到堆上来持有不被释放</li>
<li>而栈里的num由于<code>getFn</code>调用完毕就随着栈释放了，<code>plus函数</code>里操作的都是堆上的num</li>
<li>调用<code>malloc函数</code>之前需要告诉系统要分配多少内存，需要24个字节来存储内存
<ul>
<li>(因为在iOS系统中,分配堆内存的底层算法有内存对齐的概念，内存对齐的参数是16)而通过<code>malloc函数</code>分配的内存都是大于或等于其本身数据结构所需内存的16的最小倍数，所以会分配32个字节内存</li>
</ul>
</li>
</ul>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/46c0949ee2ef49bda6a3dd1e72f8c0f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1014" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/97ddb3df35cc4d7bb056ede40594e683~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w596" loading="lazy" class="medium-zoom-image"></p>
<p>我们打印<code>rax寄存器</code>的值可以知道:</p>
<ul>
<li>系统分配的32个字节，前16个字节用来存储其他信息</li>
<li>而且从图上的圈起来的地方也可以看到，将0移动16个字节</li>
<li>所以16个字节之后的8个字节才用来存储num的值</li>
</ul>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9dcceef7db894af68271c5622ac1db14~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w532" loading="lazy" class="medium-zoom-image"></p>
<p>调用<code>fn(1)</code>，将断点打在这里，然后查看反汇编指令</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2b0e109bf5ef45089e0d082fd181a8ed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1009" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e3b2bc9e7751486e9241c76521fcb8bd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w575" loading="lazy" class="medium-zoom-image"></p>
<p>然后调用到<code>plus函数</code>内部，再次打印<code>rax寄存器</code>的值，发现num的值已经变为1了</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e5341d04835242f9acb064f3c5c99601~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w575" loading="lazy" class="medium-zoom-image"></p>
<p>然后继续往下执行调用<code>fn(2)</code>，发现num的值已经变为3了</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/369ab4213cdf41908e77b2c703499416~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w606" loading="lazy" class="medium-zoom-image"></p>
<p>然后继续往下执行调用<code>fn(3)</code>，发现num的值已经变为6了</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/719e3ef11cb747e6aca1260882450353~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w596" loading="lazy" class="medium-zoom-image"></p>
<p>然后继续往下执行调用<code>fn(4)</code>，发现num的值已经变为10了</p>
<p><strong>闭包和类的相似之处</strong></p>
<p>我们可以把闭包想像成是一个类的实例对象</p>
<ul>
<li>内存在堆空间</li>
<li>捕获的局部变量\常量就是对象的成员（存储属性）</li>
<li>组成闭包的函数就是类内部定义的方法</li>
</ul>
<p>类似如下示例</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Closure</span> {
    <span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        num <span class="hljs-operator">+=</span> i
        <span class="hljs-keyword">return</span> num
    }
}

<span class="hljs-keyword">var</span> cs <span class="hljs-operator">=</span> <span class="hljs-type">Closure</span>()
cs.plus(<span class="hljs-number">1</span>)
cs.plus(<span class="hljs-number">2</span>)
cs.plus(<span class="hljs-number">3</span>)
cs.plus(<span class="hljs-number">4</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<p>而且通过反汇编也能看出类和闭包的共同之处:</p>
<ul>
<li>分配的堆内存空间前16个字节都是用来存储<code>数据类型信息</code>和<code>引用计数</code>的</li>
</ul>
<blockquote>
<p><strong>再看下面的示例</strong></p>
</blockquote>
<p>如果把num变成全局变量呢，还会不会分配堆内存</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">Fn</span> <span class="hljs-operator">=</span> (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>

<span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getFn</span>() -&gt; <span class="hljs-type">Fn</span> {

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        num <span class="hljs-operator">+=</span> i
        <span class="hljs-keyword">return</span> num
    }
    <span class="hljs-keyword">return</span> plus
}

<span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> getFn()

<span class="hljs-built_in">print</span>(fn(<span class="hljs-number">1</span>)) <span class="hljs-comment">// 1</span>
<span class="hljs-built_in">print</span>(fn(<span class="hljs-number">2</span>)) <span class="hljs-comment">// 3</span>
<span class="hljs-built_in">print</span>(fn(<span class="hljs-number">3</span>)) <span class="hljs-comment">// 6</span>
<span class="hljs-built_in">print</span>(fn(<span class="hljs-number">4</span>)) <span class="hljs-comment">// 10</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>我们通过反汇编可以看到，系统不再分配堆内存空间了</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d6a93827e65740c592f1a633795568cb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w717" loading="lazy" class="medium-zoom-image"></p>
<blockquote>
<p><strong>注意:</strong> 如果返回值是函数类型，那么参数的修饰要保持统一</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Void</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-params">v</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) {
        v <span class="hljs-operator">+=</span> num
    }
    
    <span class="hljs-keyword">return</span> plus
}

<span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">5</span>
add(<span class="hljs-number">20</span>)(<span class="hljs-operator">&amp;</span>num)

<span class="hljs-built_in">print</span>(num)
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-72">13.4 自动闭包</h3>
<p>我们先看下面的示例代码</p>
<p>如果调用<code>getFirstPositive</code>并传入两个参数，第一个参数符合条件，但是还需要调用<code>plus</code>来得到第二个参数，这种设计相比就稍许有些浪费了</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 如果第1个数大于0，返回第一个数。否则返回第2个数</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">getFirstPositive</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    v1 <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> v1 : v2
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">num2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"haha"</span>)
    <span class="hljs-keyword">return</span> num1 <span class="hljs-operator">+</span> num2
}

getFirstPositive(<span class="hljs-number">10</span>, plus(<span class="hljs-number">2</span>, <span class="hljs-number">4</span>))
<span class="copy-code-btn">复制代码</span></code></pre>
<p>我们进行了一些优化，将第二个参数的类型变为函数，只有条件成立的时候才会去调用</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">getFirstPositive</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: () -&gt; <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    v1 <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> v1 : v2()
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">num2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"haha"</span>)
    <span class="hljs-keyword">return</span> num1 <span class="hljs-operator">+</span> num2
}

getFirstPositive(<span class="hljs-number">10</span>, { plus(<span class="hljs-number">2</span>, <span class="hljs-number">4</span>)} )
<span class="copy-code-btn">复制代码</span></code></pre>
<p>这样确定能够满足条件避免多余的调用，但是可读性就会差一些</p>
<blockquote>
<p><strong>我们可以使用<code>自动闭包@autoclosure</code>来修饰形参</strong></p>
</blockquote>
<ul>
<li>
<ol>
<li><code>@autoclosure</code>会将传进来的类型包装成闭包表达式，这是编译器特性</li>
</ol>
</li>
<li>
<ol start="2">
<li><code>@autoclosure</code>只支持<code>() -&gt; T</code>格式的参数</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">getFirstPositive</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-keyword">@autoclosure</span> () -&gt; <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    v1 <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> v1 : v2()
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">num2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"haha"</span>)
    <span class="hljs-keyword">return</span> num1 <span class="hljs-operator">+</span> num2
}

getFirstPositive(<span class="hljs-number">10</span>, plus(<span class="hljs-number">2</span>, <span class="hljs-number">4</span>))
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li><code>@autoclosure</code>并非只支持最后一个参数</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">getFirstPositive</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-keyword">@autoclosure</span> () -&gt; <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v3</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> 
{
    v1 <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> v1 : v2()
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li><code>空合并运算符??</code>中就使用了<code>@autoclosure</code>来将<code>??</code>后面的参数进行了包装
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd984c9d6f3643dab1b92ab556f30183~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w860" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="5">
<li>有<code>@autoclosure</code>和无<code>@autoclosure</code>会构成函数重载，不会报错</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">getFirstPositive</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: () -&gt; <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    v1 <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> v1 : v2()
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getFirstPositive</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-keyword">@autoclosure</span> () -&gt; <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    v1 <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> v1 : v2()
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<p><strong>注意：为了避免与期望冲突，使用了<code>@autoclosure</code>的地方最好明确注释清楚：这个值会被推迟执行</strong></p>
<h3 data-id="heading-73">13.5 通过汇编进行底层分析</h3>
<p><strong>1.分析下面这个函数的内存布局</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">+</span> v2 }

<span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> sum
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>.stride(ofValue: fn)) <span class="hljs-comment">// 16</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>反汇编之后
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a4ba5da513114259b612ace0f69a5aed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w717" loading="lazy" class="medium-zoom-image">
可以看到:</p>
<ul>
<li>底层会先计算sum的值，然后移动到fn的前8个字节</li>
<li>再将0移动到fn的后8个字节，总共占用16个字节
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7b5f06739b3245a58064cb8f6a325600~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p>两个地址相差8个字节，所以是连续的，都表示fn的前后8个字节的地址值</p>
<p><strong>2.分析下面这个函数的内存布局</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">Fn</span> <span class="hljs-operator">=</span> (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getFn</span>() -&gt; <span class="hljs-type">Fn</span> {
    <span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">return</span> i
    }
    <span class="hljs-keyword">return</span> plus
}

<span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> getFn()

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>fn)) <span class="hljs-comment">// 16</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>反汇编之后
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a378d1df3a52495fb11f4faeb14dd569~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image"></p>
<p>我们能看到:</p>
<ul>
<li>
<ol>
<li>先调用<code>getFn</code></li>
</ol>
</li>
<li>
<ol start="2">
<li>之后<code>rax</code>和<code>rdx</code>会给fn分配16个字节</li>
</ol>
</li>
</ul>
<p>然后我们进入<code>getFn</code>看看<code>rax</code>和<code>rdx</code>存储的值分别是什么</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ad095c56c2a84749ad673f279bd1931e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w715" loading="lazy" class="medium-zoom-image"></p>
<p>可以看到会将<code>plus的返回值</code>放到<code>rax</code>中
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/085cd31f92be495199b099b63083aa34~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w949" loading="lazy" class="medium-zoom-image"></p>
<p>可以看到<code>ecx</code>和自己进行异或运算，并把结果0存储到<code>rdx</code>中</p>
<p>所以回过头看第一张图就知道了，fn的<code>16</code>个字节中，前8个字节存储的是<code>plus</code>的返回值，后8个字节存储的是0<br>
等同于将<code>plus函数</code>赋值给fn</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> plus()
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>3.分析下面这个函数的内存布局</strong></p>
<p>我们将上面示例里的<code>plus函数</code>内部对num进行捕获，看看其内存布局有什么变化</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">Fn</span> <span class="hljs-operator">=</span> (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getFn</span>() -&gt; <span class="hljs-type">Fn</span> {
    <span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        num <span class="hljs-operator">+=</span> i
        <span class="hljs-keyword">return</span> num
    }
    <span class="hljs-keyword">return</span> plus
}

<span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> getFn()

fn(<span class="hljs-number">1</span>)
fn(<span class="hljs-number">2</span>)
fn(<span class="hljs-number">3</span>)

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>fn)) <span class="hljs-comment">// 16</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>反汇编之后</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/359c67b88a43494086592a1db8b278e1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w945" loading="lazy" class="medium-zoom-image"></p>
<p>我们可以看到，调用完<code>getFn</code>之后，会分别将<code>rax</code>和<code>rdx</code>的值移动到<code>rip+内存地址</code>，也就是给全局变量fn进行赋值操作</p>
<p>我们通过打印获取fn的内存占用知道是16个字节，fn的前8个字节就是<code>rax</code>里存储的值，而后8个字节存储的是<code>rdx</code>里的值</p>
<p>我们只需要找到<code>rax</code>和<code>rdx</code>里分别存储的是什么就可以了</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ded70d76d4864333b63e1a29636cc9f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image"></p>
<p>可以看到在堆空间分配完内存之后的<code>rax</code>给上面几个都进行了赋值，最后的<code>rdx</code>里存储的就是堆空间的地址值</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/647e6838c3f24c4eb26ef62086e1d306~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w944" loading="lazy" class="medium-zoom-image"></p>
<p>从这句看<code>rax</code>里存储的应该是和<code>plus函数</code>相关，下面我们就要找到<code>rax</code>里存储的是什么</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/905044a7ab2e4a6092d55c9c4f0f71c2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1f1a75e937114d70811f800dc4f78bf7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w946" loading="lazy" class="medium-zoom-image"></p>
<p>而且我们调用fn(1)时也可以推导出是调用的全局变量fn的前八个字节</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7fee0fda6ede44099ed1fe6adab5e262~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image"></p>
<p>参数1会存储到<code>edi</code>中</p>
<p>而经过上面的推导我们知道<code>-0xf8(%rbp)</code>中存储的是fn的前8个字节，那么往后8位就是<code>-0x100(%rbp)</code>，里面放的肯定就是堆空间的地址值了，存储到了<code>r13</code>中</p>
<p>我们在这里打断点，来观察<code>rax</code>里到底存储的是什么</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/96ff7d5814604fedb11ba3968cdb7ce4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f0cd10a8dcbe430cba1fb3675e49deb3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w946" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/905e16cba0fd44a48538817ff1df9c8d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/62511fbce3fe436caa43c1e6a671f0c7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/718280ea6726479ea4c13567165e2145~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w949" loading="lazy" class="medium-zoom-image"></p>
<p>经过一系列的跳转，重要来到了plus真正的函数地址</p>
<p>而且<code>r13</code>最后给了<code>rsi</code>，<code>rdi</code>中存储的还是参数1</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df72a2a945654c71a6b0b194e747d7fa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2369455bac414bd29408f0a23b3d0a49~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w946" loading="lazy" class="medium-zoom-image"></p>
<p>进到<code>plus函数</code>中，然后找到进行相加计算的地方，因为传进来的参数是变化的，所以不可能是和固定地址值进行相加</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5b3056bee744af690d00c5355b5d913~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/235f74a0520a4ad58200b36fd23a5969~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w946" loading="lazy" class="medium-zoom-image"></p>
<p>通过推导得知<code>rcx</code>里存储的值就是<code>rdi</code>中的参数1</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/037d3d0619c34d2587f3ffc37ffd1e4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w945" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d961d60c35c54becab0b2e34028a9e9f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w945" loading="lazy" class="medium-zoom-image"></p>
<p>通过推导得知<code>rdx</code>里存储的值就是<code>rsi</code>中的堆内存的num地址</p>
<p>所以可以得知<code>0x10(%rdx)</code>也就是<code>rdx</code>跳过16个字节的值就是num的值</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f4d1ea7c9c4944b18af51213921f2bbd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w741" loading="lazy" class="medium-zoom-image"></p>
<p>通过打印也可以证明我们的分析是正确的</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c28a28b9ae264d3d98844a06e0a5fb2b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ff502270a2884bde85bf51405764b28f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w946" loading="lazy" class="medium-zoom-image"></p>
<p>通过推导可以发现<code>rax</code>中存储的是<code>rsi</code>的num的地址值</p>
<p>然后将<code>rcx</code>中的值覆盖掉<code>rax</code>中的num地址值</p>
<p>而且真正进行捕获变量的时机是在<code>getFn</code>即将return之前做的事</p>
<p><strong>4.分析下面这个函数的内存布局</strong></p>
<p>我们来看下面这个闭包里的变量会被捕获几次</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">Fn</span> <span class="hljs-operator">=</span> (<span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getFns</span>() -&gt; (<span class="hljs-type">Fn</span>, <span class="hljs-type">Fn</span>) {
    <span class="hljs-keyword">var</span> num1 <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> num2 <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) {
        num1 <span class="hljs-operator">+=</span> i <span class="hljs-comment">// 6 + 0 = 6, 1 + 4 = 5,</span>
        num2 <span class="hljs-operator">+=</span> i <span class="hljs-operator">&lt;&lt;</span> <span class="hljs-number">1</span> <span class="hljs-comment">// 1100 = 12 + 0 = 12, 1000 = 8 + 2 = 10</span>
        <span class="hljs-keyword">return</span> (num1, num2)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">minus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) {
        num1 <span class="hljs-operator">-=</span> i <span class="hljs-comment">// 6 - 5 = 1, 5 - 3 = 2</span>
        num2 <span class="hljs-operator">-=</span> i <span class="hljs-operator">&lt;&lt;</span> <span class="hljs-number">1</span> <span class="hljs-comment">// 1010 = 12 - 10 = 2, 0110 = 10 - 6 = 4</span>
        <span class="hljs-keyword">return</span> (num1, num2)
    }

    <span class="hljs-keyword">return</span> (plus, minus)
}

<span class="hljs-keyword">let</span> (p, m) <span class="hljs-operator">=</span> getFns()
<span class="hljs-built_in">print</span>(p(<span class="hljs-number">6</span>)) <span class="hljs-comment">// 6, 12</span>
<span class="hljs-built_in">print</span>(m(<span class="hljs-number">5</span>)) <span class="hljs-comment">// 1, 2</span>
<span class="hljs-built_in">print</span>(p(<span class="hljs-number">4</span>)) <span class="hljs-comment">// 5, 10</span>
<span class="hljs-built_in">print</span>(m(<span class="hljs-number">3</span>)) <span class="hljs-comment">// 2, 4</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>反汇编之后</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bd66e2c622e4b06ae82ed5f8fc7e2bb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w946" loading="lazy" class="medium-zoom-image"></p>
<p>发现其底层分别会分配两个堆空间，但是num1、num2也只是分别捕获一次，然后两个函数<code>plus、minus</code>共有</p>
<h2 data-id="heading-74">14. 集合类型</h2>
<h3 data-id="heading-75">1.集合类型的定义</h3>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1d558acdd0b241509f7ee8671eca1dff~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image">
<strong>集合的定义:</strong></p>
<ul>
<li>集合就是用来存储一组数据的容器。</li>
<li>三种典型的集合类型：<code>数组</code>、<code>集合</code>和<code>字典</code>。</li>
</ul>
<h3 data-id="heading-76">2.集合和字典</h3>
<p><strong>集合和字典:</strong></p>
<ul>
<li>集合和字典类型也是存储了<code>相同类型数据</code>的集合，但是数据之间是<code>无序</code>的。</li>
<li><code>集合不允许值重复</code>出现。</li>
<li>字典中的值可以重复出现，但是每一个值都有唯一的键值与其对应。</li>
</ul>
<h4 data-id="heading-77">2.1 集合</h4>
<blockquote>
<p>定义</p>
</blockquote>
<ul>
<li>集合中的元素是相同数据类型的，并且元素值是唯一的。</li>
<li>集合中的元素是无序的。</li>
</ul>
<blockquote>
<p>声明格式</p>
</blockquote>
<ul>
<li><code>Set&lt;DataType&gt;</code></li>
</ul>
<h5 data-id="heading-78">a.集合的初始化</h5>
<p><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/daf562c552d540b083a486076378bcad~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-79">b.集合的为空判断和元素插入</h5>
<p><img src="https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5f8969c8b1844499119205b292eb500~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-80">c.删除元素</h5>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ef393fb0eabb4885872bdad49628d346~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-81">d.检索特定元素</h5>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e57cadd690554832a3edf594505aa45a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-82">e.遍历集合</h5>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4556e3d27fa44be1b6c4868c351a1cfc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-83">f.集合排序</h5>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f8d15a91d5924c31b942d075803cc929~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-84">g.集合间的运算</h5>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c4e7ecd0c3224945b06e232bc90e26e7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-85">2.2 字典</h4>
<h5 data-id="heading-86">a. 字典的声明</h5>
<p><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5b4dacda5b5542eeac223e9163e7feda~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-87">b. 字典的初始化</h5>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9d2b97f23ccf44b294fcab0845e97068~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-88">c. 字典元素的更新</h5>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9469d0c683f341e8a7dc0a2336abd771~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-89">d. 字典元素的删除</h5>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3f1fee908c04417189ecf6a20e9520c4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-90">e. 遍历字典</h5>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df8672a4ea784831ae4778a90e99cf24~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h5 data-id="heading-91">f. 字典的keys属性和values属性</h5>
<p><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/189cbae4ca9a4e21a50ca59cefdd0d1a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h3 data-id="heading-92">3.数组</h3>
<p><strong>数组定义</strong>
数组是一种按照顺序来存储相同类型数据的集合，相同的值可以多次出现在一个数组中的不同位置</p>
<ul>
<li>类型安全
<ul>
<li>数组是类型安全的，数组中包含的数据类型必须是明确的</li>
</ul>
</li>
<li>声明格式
<ul>
<li>数组的声明格式为： <code>Array&lt;DataType&gt;</code> 或 <code>[DataType] </code></li>
</ul>
</li>
</ul>
<h4 data-id="heading-93">3.1 常用函数</h4>
<ul>
<li>
<ol>
<li><code>isEmpty</code> 用来判断数组是否为空</li>
</ol>
</li>
<li>
<ol start="2">
<li><code>append</code> 用来向数组的末端添加一个元素</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">//实例</span>
<span class="hljs-comment">//创建了一个空的字符串数组，然后通过isEmpty来判断数组是否为空，再通过append来添加新的元素到数组中。</span>
<span class="hljs-keyword">var</span> animalArray <span class="hljs-operator">=</span> [<span class="hljs-type">String</span>]()
<span class="hljs-keyword">if</span> animalArray.isEmpty {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"数组animalArray是空的 "</span>)
}
animalArray.append(<span class="hljs-string">"tiger"</span>)
animalArray.append(<span class="hljs-string">"lion"</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<h4 data-id="heading-94">3.2 数组初始化</h4>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/534acc3fd20741749c938805fe40cd24~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-95">3.3 数组的相加和累加</h4>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1fd21716f0b543e6bf788df973f2f576~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-96">3.4 数组的下标操作</h4>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc3618f5bb684b6aa5e7495c2b48ce4d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-97">3.5 插入和删除元素</h4>
<p><img src="https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e565174695814c728800281db1d982d8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-98">3.6 数组的遍历</h4>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3b0dc210590246c8a95927519bc3c483~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-99">3.7 数组的片段</h4>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8f32af5fc70f4e77b424ba84018a32a5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/24ceded110f248d8b56bc25e7de1255e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-100">3.8 通过数组片段生成新数组</h4>
<p><img src="https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b26720d1eea04b6cb68af34fd0bd5795~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-101">3.9 元素交换位置</h4>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/64aa272fb9194fd7833e4adf7f6e6a46~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-102">3.10 数组排序</h4>
<p><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eb57b9d5588d4d8787f1059ad2872047~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h4 data-id="heading-103">3.11 数组元素的检索</h4>
<p><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bc507e4c084e460bad9c7a625afcd69f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h1 data-id="heading-104">专题系列文章</h1>
<h3 data-id="heading-105">1.前知识</h3>
<ul>
<li><strong><a href="https://juejin.cn/post/7089043618803122183/" target="_blank" title="https://juejin.cn/post/7089043618803122183/">01-探究iOS底层原理|综述</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7093842449998561316/" target="_blank" title="https://juejin.cn/post/7093842449998561316/">02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7095079758844674056" target="_blank" title="https://juejin.cn/post/7095079758844674056">03-探究iOS底层原理|LLDB</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7115302848270696485/" target="_blank" title="https://juejin.cn/post/7115302848270696485/">04-探究iOS底层原理|ARM64汇编</a></strong></li>
</ul>
<h3 data-id="heading-106">2. 基于OC语言探索iOS底层原理</h3>
<ul>
<li><strong><a href="https://juejin.cn/post/7094409219361193997/" target="_blank" title="https://juejin.cn/post/7094409219361193997/">05-探究iOS底层原理|OC的本质</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7094503681684406302" target="_blank" title="https://juejin.cn/post/7094503681684406302">06-探究iOS底层原理|OC对象的本质</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7096087582370431012" target="_blank" title="https://juejin.cn/post/7096087582370431012">07-探究iOS底层原理|几种OC对象【实例对象、类对象、元类】、对象的isa指针、superclass、对象的方法调用、Class的底层本质</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7096480684847415303" target="_blank" title="https://juejin.cn/post/7096480684847415303">08-探究iOS底层原理|Category底层结构、App启动时Class与Category装载过程、load 和 initialize 执行、关联对象</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7115318628563550244/" target="_blank" title="https://juejin.cn/post/7115318628563550244/">09-探究iOS底层原理|KVO</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7115320523805949960/" target="_blank" title="https://juejin.cn/post/7115320523805949960/">10-探究iOS底层原理|KVC</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7115809219319693320/" target="_blank" title="https://juejin.cn/post/7115809219319693320/">11-探究iOS底层原理|探索Block的本质|【Block的数据类型(本质)与内存布局、变量捕获、Block的种类、内存管理、Block的修饰符、循环引用】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116103432095662111" target="_blank" title="https://juejin.cn/post/7116103432095662111">12-探究iOS底层原理|Runtime1【isa详解、class的结构、方法缓存cache_t】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116147057739431950" target="_blank" title="https://juejin.cn/post/7116147057739431950">13-探究iOS底层原理|Runtime2【消息处理(发送、转发)&amp;&amp;动态方法解析、super的本质】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116291178365976590/" target="_blank" title="https://juejin.cn/post/7116291178365976590/">14-探究iOS底层原理|Runtime3【Runtime的相关应用】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116515606597206030/" target="_blank" title="https://juejin.cn/post/7116515606597206030/">15-探究iOS底层原理|RunLoop【两种RunloopMode、RunLoopMode中的Source0、Source1、Timer、Observer】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116521653667889165/" target="_blank" title="https://juejin.cn/post/7116521653667889165/">16-探究iOS底层原理|RunLoop的应用</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116821775127674916/" target="_blank" title="https://juejin.cn/post/7116821775127674916/">17-探究iOS底层原理|多线程技术的底层原理【GCD源码分析1:主队列、串行队列&amp;&amp;并行队列、全局并发队列】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116878578091819045" target="_blank" title="https://juejin.cn/post/7116878578091819045">18-探究iOS底层原理|多线程技术【GCD源码分析1:dispatch_get_global_queue与dispatch_(a)sync、单例、线程死锁】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116897833126625316" target="_blank" title="https://juejin.cn/post/7116897833126625316">19-探究iOS底层原理|多线程技术【GCD源码分析2:栅栏函数dispatch_barrier_(a)sync、信号量dispatch_semaphore】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116898446358888485/" target="_blank" title="https://juejin.cn/post/7116898446358888485/">20-探究iOS底层原理|多线程技术【GCD源码分析3:线程调度组dispatch_group、事件源dispatch Source】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116898868737867789/" target="_blank" title="https://juejin.cn/post/7116898868737867789/">21-探究iOS底层原理|多线程技术【线程锁：自旋锁、互斥锁、递归锁】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7116907029465137165" target="_blank" title="https://juejin.cn/post/7116907029465137165">22-探究iOS底层原理|多线程技术【原子锁atomic、gcd Timer、NSTimer、CADisplayLink】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7117274106940096520" target="_blank" title="https://juejin.cn/post/7117274106940096520">23-探究iOS底层原理|内存管理【Mach-O文件、Tagged Pointer、对象的内存管理、copy、引用计数、weak指针、autorelease</a></strong></li>
</ul>
<h3 data-id="heading-107">3. 基于Swift语言探索iOS底层原理</h3>
<p>关于<code>函数</code>、<code>枚举</code>、<code>可选项</code>、<code>结构体</code>、<code>类</code>、<code>闭包</code>、<code>属性</code>、<code>方法</code>、<code>swift多态原理</code>、<code>String</code>、<code>Array</code>、<code>Dictionary</code>、<code>引用计数</code>、<code>MetaData</code>等Swift基本语法和相关的底层原理文章有如下几篇:</p>
<ul>
<li><a href="https://juejin.cn/post/7119020967430455327" target="_blank" title="https://juejin.cn/post/7119020967430455327">Swift5核心语法1-基础语法</a></li>
<li><a href="https://juejin.cn/post/7119510159109390343" target="_blank" title="https://juejin.cn/post/7119510159109390343">Swift5核心语法2-面向对象语法1</a></li>
<li><a href="https://juejin.cn/post/7119513630550261774" target="_blank" title="https://juejin.cn/post/7119513630550261774">Swift5核心语法2-面向对象语法2</a></li>
<li><a href="https://juejin.cn/post/7119714488181325860" target="_blank" title="https://juejin.cn/post/7119714488181325860">Swift5常用核心语法3-其它常用语法</a></li>
<li><a href="https://juejin.cn/post/7119722433589805064" target="_blank" title="https://juejin.cn/post/7119722433589805064">Swift5应用实践常用技术点</a></li>
</ul>
<h1 data-id="heading-108">其它底层原理专题</h1>
<h3 data-id="heading-109">1.底层原理相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7018755998823219213" target="_blank" title="https://juejin.cn/post/7018755998823219213">01-计算机原理|计算机图形渲染原理这篇文章</a></li>
<li><a href="https://juejin.cn/post/7019117942377807908" target="_blank" title="https://juejin.cn/post/7019117942377807908">02-计算机原理|移动终端屏幕成像与卡顿&nbsp;</a></li>
</ul>
<h3 data-id="heading-110">2.iOS相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7019193784806146079" target="_blank" title="https://juejin.cn/post/7019193784806146079">01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019200157119938590" target="_blank" title="https://juejin.cn/post/7019200157119938590">02-iOS底层原理|iOS动画渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019497906650497061/" target="_blank" title="https://juejin.cn/post/7019497906650497061/">03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理</a></li>
<li><a href="https://juejin.cn/post/7020613901033144351" target="_blank" title="https://juejin.cn/post/7020613901033144351">04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案</a></li>
</ul>
<h3 data-id="heading-111">3.webApp相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021035020445810718/" target="_blank" title="https://juejin.cn/post/7021035020445810718/">01-Web和类RN大前端的渲染原理</a></li>
</ul>
<h3 data-id="heading-112">4.跨平台开发方案相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021057396147486750/" target="_blank" title="https://juejin.cn/post/7021057396147486750/">01-Flutter页面渲染原理</a></li>
</ul>
<h3 data-id="heading-113">5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较</h3>
<ul>
<li><a href="https://juejin.cn/post/7021071990723182606/" target="_blank" title="https://juejin.cn/post/7021071990723182606/">01-Native、WebApp、跨平台开发三种方案性能比较</a></li>
</ul>
<h3 data-id="heading-114">6.Android、HarmonyOS页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021840737431978020/" target="_blank" title="https://juejin.cn/post/7021840737431978020/">01-Android页面渲染原理</a></li>
<li><a href="#" title="#">02-HarmonyOS页面渲染原理</a> (<code>待输出</code>)</li>
</ul>
<h3 data-id="heading-115">7.小程序页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021414123346853919" target="_blank" title="https://juejin.cn/post/7021414123346853919">01-小程序框架渲染原理</a></li>
</ul></div></div>