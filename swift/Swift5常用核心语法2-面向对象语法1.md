# Swift5常用核心语法2-面向对象语法1

<h1 data-id="heading-0">一、概述</h1>
<p>最近刚好有空,趁这段时间,复习一下<code>Swift5</code>核心语法,进行知识储备,以供日后温习 和 进一步探索<code>Swift</code>语言的底层原理做铺垫。</p>
<p>本文继上一篇文章<a href="https://juejin.cn/post/7119020967430455327" target="_blank" title="https://juejin.cn/post/7119020967430455327">Swift5核心语法1-基础语法</a>之后,继续复习<code>面向对象语法</code></p>
<p><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a03e517565e54fa6895098e060598486~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<h1 data-id="heading-1">二、结构体</h1>
<h2 data-id="heading-2">1. 基本概念</h2>
<ul>
<li>在Swift<strong>标准库中，绝大多数的公开类型都是结构体</strong>，而<strong>枚举和类只占很小一部分</strong>
<ul>
<li>比如<code>Bool、Int、String、Double、Array、Dictionary</code>等常见类型都是结构体
<pre><code class="hljs language-swift copyable" lang="swift">    <span class="hljs-keyword">struct</span> <span class="hljs-title class_">Date</span> {
        <span class="hljs-keyword">var</span> year: <span class="hljs-type">Int</span>
        <span class="hljs-keyword">var</span> month: <span class="hljs-type">Int</span>
        <span class="hljs-keyword">var</span> day: <span class="hljs-type">Int</span>
    }
    <span class="hljs-keyword">var</span> date <span class="hljs-operator">=</span> <span class="hljs-type">Date</span>(year: <span class="hljs-number">2019</span>, month: <span class="hljs-number">6</span>, day: <span class="hljs-number">23</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
</li>
<li>所有的结构体<strong>都有一个编译器自动生成的初始化器</strong>（<code>initializer</code>，初始化方法、构造器、构造方法）
<ul>
<li>通过默认生成的初始化器初始化:传入所有成员值，用以初始化所有成员（<code>存储属性</code>，<code>Stored Property</code>）
<pre><code class="hljs language-swift copyable" lang="swift">   <span class="hljs-keyword">var</span> date <span class="hljs-operator">=</span> <span class="hljs-type">Date</span>(year: <span class="hljs-number">2019</span>, month: <span class="hljs-number">6</span>, day: <span class="hljs-number">23</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
</li>
</ul>
<h2 data-id="heading-3">2. 结构体的初始化器</h2>
<ul>
<li>编译器会根据情况，可能会为结构体生成多个初始化器，宗旨是：<code>保证所有成员都有初始值</code></li>
<li>如果结构体的成员定义的时候都有默认值了，那么生成的初始化器不会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c7f34e0c903b4112a1a603c46665c4ae~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w569" loading="lazy" class="medium-zoom-image">
<ul>
<li>如果是下面这几种情况就会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e364616dd6c944f28d5ab613284d4403~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/189bf09fbbf248df8396eaa8a9b74c33~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w645" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/de06012b6cec46dabe604d027cd1654a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w640" loading="lazy" class="medium-zoom-image"></li>
<li>如果是可选类型的初始化器也不会报错，因为可选类型默认的值就是<code>nil</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1a73b4ae9ef8415ab4c5b3de861cd5fa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w457" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
</ul>
<h2 data-id="heading-4">3. 自定义初始化器</h2>
<p>我们也可以自定义初始化器</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    
    <span class="hljs-keyword">init</span>(<span class="hljs-params">x</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">y</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.x <span class="hljs-operator">=</span> x
        <span class="hljs-keyword">self</span>.y <span class="hljs-operator">=</span> y
    }
} 
<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">10</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<p>下面对变量<code>p2</code>、<code>p3</code>、<code>p4</code>初始化报错的原因是 因为我们 <strong><code>已经自定义初始化器了，编译器就不会再帮我们生成默认的初始化器了</code></strong>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/da74440857c645b6990bc678cf0ab2f2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w643" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-5">4. 初始化器的本质</h2>
<p>下面这两种写法是完全等效的</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
} 
等效于 
<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span>
    
    <span class="hljs-keyword">init</span>() {
        x <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
        y <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    }
} 
<span class="hljs-keyword">var</span> p4 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>我们通过反汇编分别对比一下两种写法的实现，发现也是一样的:</li>
<li>因此,我们不难得出结论:  <br>
默认初始化器的本质,就是给存储属性做了默认赋值工作(比如这里给Int类型的两个属性默认赋值为<code>0</code>)
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bde85343b7e74b75a53d605462260979~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w713" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a431a9e76973412dbfe8e6014d9bc01a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w715" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-6">5.结构体的内存结构</h2>
<ol>
<li><strong>我们通过打印,了解下结构体占用的内存大小 和 其 内存布局</strong></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
} 
<span class="hljs-keyword">var</span> p4 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>() 
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Point</span>&gt;.stride) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Point</span>&gt;.size) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Point</span>&gt;.alignment) <span class="hljs-comment">// 8</span>

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>p4)) <span class="hljs-comment">// 0x000000000000000a 0x0000000000000014</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>通过控制台,我们可以看到:</p>
<ul>
<li>系统一共分配了<code>16</code>个字节的内存空间</li>
<li>前8个字节存储的是10，后8个字节存储的是20</li>
</ul>
<ol start="2">
<li>我们再看下面这个结构体</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
    <span class="hljs-keyword">var</span> origin: <span class="hljs-type">Bool</span> <span class="hljs-operator">=</span> <span class="hljs-literal">false</span>
}

<span class="hljs-keyword">var</span> p4 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()

<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Point</span>&gt;.stride) <span class="hljs-comment">// 24</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Point</span>&gt;.size) <span class="hljs-comment">// 17</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Point</span>&gt;.alignment) <span class="hljs-comment">// 8</span>

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>p4)) <span class="hljs-comment">// 0x000000000000000a 0x0000000000000014 0x0000000000000000</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>可以看到:</p>
<ul>
<li>结构体实际只用了17个字节，而因为系统分配有内存对齐的概念,所以分配了24个字节</li>
<li>前8个字节存储的是10，中间8个字节存储的是20，最后1个字节存储的是false，也就是0</li>
</ul>
<h1 data-id="heading-7">三、类</h1>
<ul>
<li>类的定义和结构体类似，但编译器并没有为类自动生成可以传入成员值的初始化器
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/48faa928fa484b87a2ae3996bbcabac8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w646" loading="lazy" class="medium-zoom-image"></li>
<li>如果成员没有初始值，所有的初始化器都会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f5699df524e743128207ac9c2edbd947~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w648" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-8">1.类的初始化器</h2>
<ul>
<li>如果类的所有成员都在定义的时候指定了初始值，编译器会为类生成 <strong><code>无参的初始化器</code></strong></li>
<li>成员的初始化是在这个初始化器中完成的
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">let</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>下面这两种写法是完全等效的
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

等效于

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>() {
        x <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
        y <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    }
}

<span class="hljs-keyword">let</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
</li>
</ul>
<h2 data-id="heading-9">2. 结构体与类的本质区别</h2>
<ul>
<li>结构体是<code>值类型</code>（枚举也是值类型），类是<code>引用类型</code>（指针类型）<br>
下面我们分析函数内的局部变量分别都在内存的什么位置</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
    <span class="hljs-keyword">var</span> width <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
    <span class="hljs-keyword">var</span> height <span class="hljs-operator">=</span> <span class="hljs-number">2</span>
} 
<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">3</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">4</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-keyword">var</span> size <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>()
    <span class="hljs-keyword">var</span> point <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>变量</code>size和point都是在栈空间</li>
<li>不同的是<code>局部变量point</code>是一个结构体类型。结构体是值类型，结构体变量会在栈空间中分配内存,它里面的两个成员x、y按顺序的排布</li>
<li>而<code>局部指针变量size</code>是一个类的实例，类是引用类型，所以<code>size指针</code>指向的已初始化的变量的存储空间,是在堆中分配的，size指针内部存储的是Size类的实例内存地址
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/70ea6076fb1548509687cab9ebead2cd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1020" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-10">3. 分析类的内存布局</h2>
<ul>
<li>
<ol>
<li>我们先来看一下类的占用内存大小是多少</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift">    <span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
        <span class="hljs-keyword">var</span> width <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
        <span class="hljs-keyword">var</span> height <span class="hljs-operator">=</span> <span class="hljs-number">2</span>
    }
    <span class="hljs-built_in">print</span>(<span class="hljs-type">MemoryLayout</span>&lt;<span class="hljs-type">Size</span>&gt;.stride) <span class="hljs-comment">// 8</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>通过打印我们可以发现<code>MemoryLayout</code>获取的8个字节实际上是指针变量占用多少存储空间，并不是对象在堆中的占用大小</p>
</li>
<li>
<ol start="2">
<li>然后我们再看类的内存布局是怎样的</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift">    <span class="hljs-keyword">var</span> size <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>()

    <span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>size)) <span class="hljs-comment">// 0x000000010000c388</span>
    <span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>size)) <span class="hljs-comment">// 0x000000010072dba0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>通过打印我们可以看到变量里面存储的值也是一个地址</p>
</li>
<li>
<ol start="3">
<li>我们再打印该变量所指向的对象的内存布局是什么</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift">    <span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofRef: size)) <span class="hljs-comment">// 32</span>
    <span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofRef: size)) <span class="hljs-comment">// 0x000000010072dba0</span>
    <span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofRef: size)) <span class="hljs-comment">// 0x000000010000c278 0x0000000200000003 0x0000000000000001 0x0000000000000002</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>通过打印可以看到在<code>堆中存储的对象的地址</code>和上面的<code>指针变量里存储的值</code>是一样的</p>
<p>内存布局里一共占用32个字节:</p>
<ul>
<li>前16个字节分别用来存储一些<code>类信息</code>和<code>引用计数</code></li>
<li>后面16个字节存储着类的成员变量的值</li>
</ul>
</li>
</ul>
<blockquote>
<p><strong>下面我们再从反汇编的角度来分析</strong></p>
</blockquote>
<ul>
<li>我们要想确定类是否在堆空间中分配空间，通过反汇编来查看是否有调用<code>malloc函数</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7ff9723d317849f1a11137973bd89be3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w708" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4a45d9d80a3d43efb61a81f9e475e045~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image"></li>
<li>然后就一直跟进直到这里最好调用了<code>swift_slowAlloc</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/65b01d1dd467407f8ebc07a08d1c7d15~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w714" loading="lazy" class="medium-zoom-image"></li>
<li>发现函数内部调用了系统的<code>malloc</code>在堆空间分配内存
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6a9514ee0c924446a07710bd1ca2f405~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w709" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p><strong>注意:</strong></p>
<ul>
<li>结构体和枚举存储在哪里<code>取决于它们是在哪里分配</code>的
<ul>
<li>如果是在函数中分配的那就是在栈里</li>
<li>如果是在全局中分配的那就是在数据段</li>
</ul>
</li>
<li>而类无论是在哪里分配的，对象都是在堆空间中
<ul>
<li>指向对象内存的指针的存储位置是不确定的，可能在栈中也可能在数据段</li>
</ul>
</li>
</ul>
<blockquote>
<p><strong>我们再看下面的<code>类型</code>占用内存大小是多少</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
    <span class="hljs-keyword">var</span> width: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> height: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> test <span class="hljs-operator">=</span> <span class="hljs-literal">true</span>
}

<span class="hljs-keyword">let</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>()

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofRef: s)) <span class="hljs-comment">// 48</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>在<code>Mac、iOS</code>中的<code>malloc函数</code>分配的内存大小总是<code>16的倍数</code></li>
<li>类最前面会有<code>16个字节</code>用来存储<code>类的信息</code>和<code>引用计数</code>，所以实际占用内存是<code>33个字节</code>，但由于<code>malloc函数</code>分配的内存都是刚好大于或等于其所需内存的16最小倍数，所以分配<code>48个字节</code></li>
<li>我们还可以通过<code>class_getInstanceSize</code>函数来获取类对象的内存大小</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 获取的是经过内存对齐后的内存大小，不是malloc函数分配的内存大小</span>
<span class="hljs-built_in">print</span>(class_getInstanceSize(<span class="hljs-built_in">type</span>(of: s))) <span class="hljs-comment">// 40</span>
<span class="hljs-built_in">print</span>(class_getInstanceSize(<span class="hljs-type">Size</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// 40</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-11">四、值类型和引用类型</h1>
<h2 data-id="heading-12">1. 值类型</h2>
<ul>
<li>值类型赋值给<code>var、let或者给函数</code>传参，是直接将所有内容<code>拷贝一份</code></li>
<li>类似于对文件进行<code>copy、paste</code>操作，产生了全新的文件副本，<strong>属于深拷贝（deep copy）</strong></li>
</ul>
<p>值类型进行拷贝的内存布局如下所示</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">3</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">4</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">20</span>)
    <span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> p1

    p2.x <span class="hljs-operator">=</span> <span class="hljs-number">4</span>
    p2.y <span class="hljs-operator">=</span> <span class="hljs-number">5</span>

    <span class="hljs-built_in">print</span>(p1.x, p1.y)
}

test()
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7980c7fea817418aacefb9d17bcf5dba~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w536" loading="lazy" class="medium-zoom-image"></p>
<p><strong>我们通过反汇编来进行分析</strong></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/92f3f7c5f9484dc9933d89ee94a26c59~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w712" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/602bd28e6ec6486c9096ab346f49e45e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9e673c56b74b4d768ebb91a504013d50~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w713" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/238779d785e24cc48720c582d965b587~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1048" loading="lazy" class="medium-zoom-image"></p>
<p>通过上述分析可以发现，值类型的赋值内部会先将p1的成员值保存起来，再给p2进行赋值，所以不会影响到p1</p>
<h2 data-id="heading-13">2. 值类型的赋值操作</h2>
<ul>
<li>在Swift标准库中，为了提升性能，<code>Array、String、Dictionary、Set</code>采用了<code>Copy On Write</code>的技术</li>
<li>如果<code>只是将赋值操作</code>，那么只会进行<code>浅拷贝</code>，两个变量使用的还是同一块存储空间</li>
<li>只有当<code>进行了”写“的操作</code>时，<code>才会进行深拷贝</code>操作</li>
<li>对于标准库值类型的赋值操作，Swift能确保最佳性能，所以没必要为了保证最佳性能来避免赋值</li>
<li>建议：<strong>不需要修改值的，尽量定义成<code>let</code></strong></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> s1 <span class="hljs-operator">=</span> <span class="hljs-string">"Jack"</span>
<span class="hljs-keyword">var</span> s2 <span class="hljs-operator">=</span> s1
s2.append(<span class="hljs-string">"_Rose"</span>)

<span class="hljs-built_in">print</span>(s1) <span class="hljs-comment">// Jack</span>
<span class="hljs-built_in">print</span>(s2) <span class="hljs-comment">// Jack_Rose</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> a1 <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>]
<span class="hljs-keyword">var</span> a2 <span class="hljs-operator">=</span> a1
a2.append(<span class="hljs-number">4</span>)
a1[<span class="hljs-number">0</span>] <span class="hljs-operator">=</span> <span class="hljs-number">2</span>

<span class="hljs-built_in">print</span>(a1) <span class="hljs-comment">// [2, 2, 3]</span>
<span class="hljs-built_in">print</span>(a2) <span class="hljs-comment">// [1, 2, 3, 4]</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> d1 <span class="hljs-operator">=</span> [<span class="hljs-string">"max"</span> : <span class="hljs-number">10</span>, <span class="hljs-string">"min"</span> : <span class="hljs-number">2</span>]
<span class="hljs-keyword">var</span> d2 <span class="hljs-operator">=</span> d1
d1[<span class="hljs-string">"other"</span>] <span class="hljs-operator">=</span> <span class="hljs-number">7</span>
d2[<span class="hljs-string">"max"</span>] <span class="hljs-operator">=</span> <span class="hljs-number">12</span>

<span class="hljs-built_in">print</span>(d1) <span class="hljs-comment">// ["other" : 7, "max" : 10, "min" : 2]</span>
<span class="hljs-built_in">print</span>(d2) <span class="hljs-comment">// ["max" : 12, "min" : 2]</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>我们再看下面这段代码</strong><br>
对于p1来说，再次赋值也只是覆盖了成员<code>x、y</code>的值而已，都是同一个结构体变量</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span>
}
<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">20</span>)
p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">11</span>, y: <span class="hljs-number">22</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>用let定义的赋值操作</strong></p>
<ul>
<li>如果用<code>let</code>定义的常量赋值结构体类型会报错，并且修改结构体里的成员值也会报错</li>
<li>用<code>let</code>定义就意味着常量里存储的值不可更改，而结构体是由x和y这16个字节组成的，所以更改x和y就意味着结构体的值要被覆盖，所以报错</li>
</ul>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/02bc9cd358654834ae915998e2e45480~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w645" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-14">3. 引用类型</h2>
<ul>
<li>引用赋值给<code>var、let或者给函数</code>传参，是将<code>内存地址拷贝一份</code></li>
<li>类似于制作一个文件的替身（快捷方式、链接），指向的是同一个文件，属于 <strong><code>浅拷贝（shallow copy）</code></strong>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
    <span class="hljs-keyword">var</span> width <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> height <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">width</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">height</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.width <span class="hljs-operator">=</span> width
        <span class="hljs-keyword">self</span>.height <span class="hljs-operator">=</span> height
    }
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-keyword">var</span> s1 <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>(width: <span class="hljs-number">10</span>, height: <span class="hljs-number">20</span>)
    <span class="hljs-keyword">var</span> s2 <span class="hljs-operator">=</span> s1

    s2.width <span class="hljs-operator">=</span> <span class="hljs-number">11</span>
    s2.height <span class="hljs-operator">=</span> <span class="hljs-number">22</span>

    <span class="hljs-built_in">print</span>(s1.height, s1.width)
}

test() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<p>由于s1和s2都指向的同一块存储空间，所以s2修改了成员变量，s1再调用成员变量也已经是改变后的了
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3356c841c72c4fac841aa1dbf256f8cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1124" loading="lazy" class="medium-zoom-image"></p>
<blockquote>
<p><strong>我们通过反汇编来进行分析</strong>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b45ca53a5f0d46eb8eb3a28d3621a036~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1049" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/945d409630314dbcad7255cb126579f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1052" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5d1e1886aa3e48c590dcf63cf5882594~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1052" loading="lazy" class="medium-zoom-image"></p>
</blockquote>
<ul>
<li>堆空间分配完内存之后，我们拿到<code>rax</code>的值查看内存布局</li>
<li>发现<code>rax</code>里和对象的结构一样，证明<code>rax</code>里存储的就是对象的地址
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/704284210812484c9c6486811ee37673~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1051" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e9317bf166a4951a7755e6c8919506c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1187" loading="lazy" class="medium-zoom-image"></li>
<li>将新的值11和22分别覆盖掉堆空间对象的成员值
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/02b760674c0b45d38d11a9a86e1e8c40~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1223" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0643e6cb5cec4763aef3a0fa65a57c04~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1224" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/af6b9af0b43c4511887caf319cde7327~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1220" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/31c388e409914d1f8e4e2a526833b208~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1225" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p>通过上面的分析可以发现，修改的成员值都是改的同一个地址的对象，所以修改了p2的成员值，会影响到p1</p>
<h2 data-id="heading-15">4. 对象的堆空间申请过程</h2>
<ul>
<li><strong>在Swift中，创建类的实例对象，要向堆空间申请内存，大概流程如下</strong>
<ul>
<li><code>Class.__allocating_init()</code></li>
<li>libswiftCore.dylib:<code>_swift_allocObject_</code></li>
<li>libswiftCore.dylib:<code>swift_slowAlloc</code></li>
<li>libsystem_malloc.dylib:<code>malloc</code></li>
</ul>
</li>
<li>在Mac、iOS中的<code>malloc</code>函数分配的内存大小总是16的倍数</li>
<li>通过<code>class_getInstanceSize</code>可以得知：类的对象至少需要占用多少内存
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span>{
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">11</span>
    <span class="hljs-keyword">var</span> test <span class="hljs-operator">=</span> <span class="hljs-literal">true</span>
    <span class="hljs-keyword">var</span> y <span class="hljs-operator">=</span> <span class="hljs-number">22</span>
} 
<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>() 
class_getInstanceSize(<span class="hljs-built_in">type</span>(of: p)) <span class="hljs-comment">// 40 </span>
class_getInstanceSize(<span class="hljs-type">Point</span>.<span class="hljs-keyword">self</span>) <span class="hljs-comment">// 40</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-16">5. 引用类型的赋值操作</h2>
<ul>
<li>
<ol>
<li>将引用类型初始化对象赋值给同一个指针变量，指针变量会指向另一块存储空间</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
    <span class="hljs-keyword">var</span> width: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">var</span> height: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">width</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">height</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.width <span class="hljs-operator">=</span> width
        <span class="hljs-keyword">self</span>.height <span class="hljs-operator">=</span> height
    }
}

<span class="hljs-keyword">var</span> s1 <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>(width: <span class="hljs-number">10</span>, height: <span class="hljs-number">20</span>)
s1 <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>(width: <span class="hljs-number">11</span>, height: <span class="hljs-number">22</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>用let定义的赋值操作</strong></p>
</blockquote>
<ul>
<li>
<ol start="2">
<li>如果用<code>let</code>定义的常量赋值引用类型会报错，因为会改变指针常量里存储的8个字节的地址值</li>
</ol>
</li>
<li>
<ol start="3">
<li>但修改类里的属性值不会报错，因为修改属性值并不是修改的指针常量的内存，只是通过指针常量找到类所存储的堆空间的内存地址去修改类的属性
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/83dccdb5d2be4945807070fcac919b0c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w643" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-17">6. 嵌套类型</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Poker</span> {
    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">Suit</span>: <span class="hljs-title class_">Character</span> {
        <span class="hljs-keyword">case</span> spades <span class="hljs-operator">=</span> <span class="hljs-string">"♠️"</span>,
             hearts <span class="hljs-operator">=</span> <span class="hljs-string">"♥️"</span>,
             diamonds <span class="hljs-operator">=</span> <span class="hljs-string">"♦️"</span>,
             clubs <span class="hljs-operator">=</span> <span class="hljs-string">"♣️"</span>
    }
    
    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">Rank</span>: <span class="hljs-title class_">Int</span> {
        <span class="hljs-keyword">case</span> two <span class="hljs-operator">=</span> <span class="hljs-number">2</span>, three, four, five, six, seven, eight, nine, ten
        <span class="hljs-keyword">case</span> jack, queen, king, ace
    }
}

<span class="hljs-built_in">print</span>(<span class="hljs-type">Poker</span>.<span class="hljs-type">Suit</span>.hearts.rawValue)

<span class="hljs-keyword">var</span> suit <span class="hljs-operator">=</span> <span class="hljs-type">Poker</span>.<span class="hljs-type">Suit</span>.spades
suit <span class="hljs-operator">=</span> .diamonds

<span class="hljs-keyword">var</span> rank <span class="hljs-operator">=</span> <span class="hljs-type">Poker</span>.<span class="hljs-type">Rank</span>.five
rank <span class="hljs-operator">=</span> .king 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-18">7. 枚举、结构体、类都可以定义方法</h2>
<ul>
<li>
<ol>
<li>一般把定义在枚举、结构体、类内部的函数，叫做方法</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">show</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"show"</span>)
    }
}

<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
p.show()

<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
    <span class="hljs-keyword">var</span> width: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    <span class="hljs-keyword">var</span> height: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">show</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"show"</span>)
    }
}

<span class="hljs-keyword">let</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>()
s.show()

<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">PokerFace</span>: <span class="hljs-title class_">Character</span> {
    <span class="hljs-keyword">case</span> spades <span class="hljs-operator">=</span> <span class="hljs-string">"♠️"</span>,
         hearts <span class="hljs-operator">=</span> <span class="hljs-string">"♥️"</span>,
         diamonds <span class="hljs-operator">=</span> <span class="hljs-string">"♦️"</span>,
         clubs <span class="hljs-operator">=</span> <span class="hljs-string">"♣️"</span>

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">show</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"show"</span>)
    }
}

<span class="hljs-keyword">let</span> pf <span class="hljs-operator">=</span> <span class="hljs-type">PokerFace</span>.hearts
pf.show()

<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>方法不管放在哪里，其内存都是放在代码段中</li>
</ol>
</li>
<li>
<ol start="3">
<li>枚举、结构体、类里的方法其实会有隐式参数</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
    <span class="hljs-keyword">var</span> width: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    <span class="hljs-keyword">var</span> height: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

    <span class="hljs-comment">// 默认会有隐式参数，该参数类型为当前枚举、结构体、类</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">show</span>(<span class="hljs-params">self</span>: <span class="hljs-type">Size</span>) {
        <span class="hljs-built_in">print</span>(<span class="hljs-keyword">self</span>.width, <span class="hljs-keyword">self</span>.height)
    }
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h1 data-id="heading-19">六、属性</h1>
<h2 data-id="heading-20">1. 属性的基本概念</h2>
<p>Swift中跟实例相关的属性可以分为2大类:</p>
<ul>
<li><strong><code>存储属性</code></strong>（Stored Property）
<ul>
<li>类似于成员变量的概念</li>
<li>存储在实例的内存中</li>
<li>结构体、类可以定义存储属性</li>
<li>枚举<code>不可以</code>定义存储属性</li>
</ul>
</li>
<li><strong><code>计算属性</code></strong>（Computed Property）
<ul>
<li>本质就是方法（函数）</li>
<li>不占用实例的内存</li>
<li>枚举、结构体、类都可以定义计算属性</li>
</ul>
</li>
</ul>
<h3 data-id="heading-21">1.1 存储属性</h3>
<p>关于存储属性，Swift有个明确的规定:</p>
<ul>
<li>在创建类或结构体的实例时，<strong>必须为所有的存储属性设置一个合适的初始值</strong>
<ul>
<li>可以在初始化器里为存储属性设置一个初始值
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span>
} 
<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">10</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>可以分配一个默认的属性值作为属性定义的一部分
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
} 
<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
</li>
</ul>
<h3 data-id="heading-22">1.2 计算属性</h3>
<p>定义计算属性只能用<code>var</code>，不能用<code>let</code></p>
<ul>
<li><code>let</code>代表常量，值是一直不变的</li>
<li>计算属性的值是可能发生变化的（即使是只读计算属性）
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> 
    <span class="hljs-comment">// 计算属性</span>
    <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">set</span> {
            radius <span class="hljs-operator">=</span> newValue <span class="hljs-operator">/</span> <span class="hljs-number">2</span>
        } 
        <span class="hljs-keyword">get</span> {
            radius <span class="hljs-operator">*</span> <span class="hljs-number">2</span>
        }
    }
}

<span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">Circle</span>(radius: <span class="hljs-number">5</span>)
<span class="hljs-built_in">print</span>(circle.radius) <span class="hljs-comment">// 5.0</span>
<span class="hljs-built_in">print</span>(circle.diameter) <span class="hljs-comment">// 10.0</span>

circle.diameter <span class="hljs-operator">=</span> <span class="hljs-number">12</span>
<span class="hljs-built_in">print</span>(circle.radius) <span class="hljs-comment">// 6.0</span>
<span class="hljs-built_in">print</span>(circle.diameter) <span class="hljs-comment">// 12.0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>set传入的新值默认叫做<code>newValue</code>，也可以自定义
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> 
    <span class="hljs-comment">// 计算属性</span>
    <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">set</span>(newDiameter) {
            radius <span class="hljs-operator">=</span> newDiameter <span class="hljs-operator">/</span> <span class="hljs-number">2</span>
        } 
        <span class="hljs-keyword">get</span> {
            radius <span class="hljs-operator">*</span> <span class="hljs-number">2</span>
        }
    }
} 
<span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">Circle</span>(radius: <span class="hljs-number">5</span>)
circle.diameter <span class="hljs-operator">=</span> <span class="hljs-number">12</span>
<span class="hljs-built_in">print</span>(circle.diameter) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>只读计算属性，只有<code>get</code>，没有<code>set</code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> 
    <span class="hljs-comment">// 计算属性</span>
    <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">get</span> {
            radius <span class="hljs-operator">*</span> <span class="hljs-number">2</span>
        }
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> 
    <span class="hljs-comment">// 计算属性</span>
    <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Double</span> { radius <span class="hljs-operator">*</span> <span class="hljs-number">2</span> }
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>打印<code>Circle结构体</code>的内存大小，其占用才<code>8个字节</code>，其本质是因为计算属性相当于函数
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">Circle</span>(radius: <span class="hljs-number">5</span>)
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>circle)) <span class="hljs-comment">// 8</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>我们可以通过反汇编来查看其内部做了什么</strong></p>
</blockquote>
<ul>
<li>可以看到内部会调用<code>set方法</code>去计算
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7cff94714670464aaf1eef4af8da8e12~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w723" loading="lazy" class="medium-zoom-image"></li>
<li>然后我们在往下执行，还会看到<code>get方法</code>的调用
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3a9c5db06a704c67bc497a8ca021731e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w722" loading="lazy" class="medium-zoom-image"></li>
<li>所以可以用此证明:计算属性只会生成<code>getter</code>和<code>setter</code>,不会开辟内存空间</li>
</ul>
<p><strong>注意：</strong></p>
<ul>
<li>一旦将存储属性变为计算属性，初始化构造器就会报错，只允许传入存储属性的值</li>
<li>因为存储属性是直接存储在结构体内存中的，如果改成计算属性则不会分配内存空间来存储
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e864fd3b6104be586e659d1e1f1b02b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w646" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc57b13c70a0424ebbf7f6df42150499~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w525" loading="lazy" class="medium-zoom-image"></li>
<li>如果只有<code>setter</code>也会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/510b7dcc067d4d73a7ecc95efd8c7992~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w651" loading="lazy" class="medium-zoom-image"></li>
<li>只读计算属性：只有<code>get</code>，没有<code>set</code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> 
    <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Double</span> { 
        <span class="hljs-keyword">get</span> { 
            radius <span class="hljs-operator">*</span> <span class="hljs-number">2</span> 
        }
    } 
}
<span class="hljs-comment">//可以简写成</span>
<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> 
    <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Double</span> { radius <span class="hljs-operator">*</span> <span class="hljs-number">2</span>  } 
}
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-23">2. 枚举rawValue原理(计算属性)</h2>
<ul>
<li>
<ol>
<li>枚举原始值<code>rawValue</code>的本质也是计算属性，而且是只读的计算属性</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span>: <span class="hljs-title class_">Int</span> {
    <span class="hljs-keyword">case</span> test1, test2, test3

    <span class="hljs-keyword">var</span> rawValue: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">switch</span> <span class="hljs-keyword">self</span> {
        <span class="hljs-keyword">case</span> .test1:
            <span class="hljs-keyword">return</span> <span class="hljs-number">10</span>
        <span class="hljs-keyword">case</span> .test2:
            <span class="hljs-keyword">return</span> <span class="hljs-number">20</span>
        <span class="hljs-keyword">case</span> .test3:
            <span class="hljs-keyword">return</span> <span class="hljs-number">30</span>
        }
    }
} 
<span class="hljs-built_in">print</span>(<span class="hljs-type">TestEnum</span>.test1.rawValue)<span class="hljs-comment">//10</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>下面我们去掉自己写的<code>rawValue</code>，然后转汇编看下本质是什么样的</li>
</ol>
<ul>
<li>可以看到底层确实是调用了<code>getter</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift">    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">TestEnum</span>: <span class="hljs-title class_">Int</span> {
        <span class="hljs-keyword">case</span> test1, test2, test3
    }

    <span class="hljs-built_in">print</span>(<span class="hljs-type">TestEnum</span>.test1.rawValue)
<span class="copy-code-btn">复制代码</span></code></pre>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6ba17ae69a634b95941c98bd85d2785e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w717" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-24">3. 延迟存储属性（Lazy Stored Property）</h2>
<ul>
<li>
<ol>
<li>使用<code>lazy</code>可以定义一个延迟存储属性，在<code>第一次用到属性的时候才会进行初始化</code></li>
</ol>
<ul>
<li>看下面的示例代码，如果不加<code>lazy</code>，那么Person初始化之后就会进行Car的初始化</li>
<li>加上<code>lazy</code>，只有调用到属性的时候才会进行Car的初始化</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">init</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Car init!"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Car is running!"</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">lazy</span> <span class="hljs-keyword">var</span> car <span class="hljs-operator">=</span> <span class="hljs-type">Car</span>()

    <span class="hljs-keyword">init</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person init!"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">goOut</span>() {
        car.run()
    }
}

<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-built_in">print</span>(<span class="hljs-string">"----"</span>)
p.goOut()

<span class="hljs-comment">// 打印：</span>
<span class="hljs-comment">// Person init!</span>
<span class="hljs-comment">// ----</span>
<span class="hljs-comment">// Car init!</span>
<span class="hljs-comment">// Car is running!</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li><code>lazy</code>属性必须是<code>var</code>，不能是<code>let</code><br>
<code>let</code>必须在实例的初始化方法完成之前就拥有值</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">PhotoView</span> {
    <span class="hljs-keyword">lazy</span> <span class="hljs-keyword">var</span> image: <span class="hljs-type">UIImage</span> <span class="hljs-operator">=</span> {
        <span class="hljs-keyword">let</span> url <span class="hljs-operator">=</span> <span class="hljs-string">"http://www.***.com/logo.png"</span>
        <span class="hljs-keyword">let</span> data <span class="hljs-operator">=</span> <span class="hljs-type">Data</span>(url: url)
        <span class="hljs-keyword">return</span> <span class="hljs-type">UIImage</span>(data: data)
    }()
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li><strong>注意：</strong> <code>lazy</code>属性和普通的存储属性内存布局是一样的，不同的只是什么分配内存的时机,而且lazy属性可以通过闭包进行初始化</li>
</ol>
</li>
<li>
<ol start="4">
<li><strong>延迟存储属性的注意点</strong></li>
</ol>
<ul>
<li>1.如果多条线程同时第一次访问<code>lazy</code>属性，<strong>无法保证属性只被初始化一次</strong></li>
<li>2.当结构体包含一个延迟存储属性时，只有<code>var</code>才能访问延迟存储属性<br>
因为延迟存储属性初始化时需要改变结构体的内存
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7d9eacdd4db540e7ab7cc23398bdb62c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w652" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
</ul>
<h2 data-id="heading-25">4.属性观察器（Property Observer）</h2>
<ul>
<li>
<ol>
<li>可以为非<code>lazy</code>的<code>var存储属性</code>设置属性观察器</li>
</ol>
<ul>
<li>只有存储属性可以设置属性观察器</li>
<li><code>willSet</code>会传递新值，默认叫<code>newValue</code></li>
<li><code>didSet</code>会传递旧值，默认叫<code>oldValue</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"willSet"</span>, newValue)
        }

        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"didSet"</span>, oldValue, radius)
        }
    }

    <span class="hljs-keyword">init</span>() {
        radius <span class="hljs-operator">=</span> <span class="hljs-number">1.0</span>
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle init!"</span>)
    }
}

<span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">Circle</span>()
circle.radius <span class="hljs-operator">=</span> <span class="hljs-number">10.5</span>

<span class="hljs-comment">// 打印</span>
<span class="hljs-comment">// willSet 10.5</span>
<span class="hljs-comment">// didSet 1.0 10.5 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>在初始化器中设置属性值不会触发<code>willSet</code>和<code>didSet</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"willSet"</span>, newValue)
        }

        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"didSet"</span>, oldValue, radius)
        }
    }

    <span class="hljs-keyword">init</span>() {
        radius <span class="hljs-operator">=</span> <span class="hljs-number">1.0</span>
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle init!"</span>)
    }
}

<span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">Circle</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>在属性定义时设置初始值也不会触发<code>willSet</code>和<code>didSet</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Double</span> <span class="hljs-operator">=</span> <span class="hljs-number">1.0</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"willSet"</span>, newValue)
        }

        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"didSet"</span>, oldValue, radius)
        }
    }
}

<span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">Circle</span>()
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>计算属性设置属性观察器会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f0cb0a9d0e0e45858fa53006840c92ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w657" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-26">5. 全局变量和局部变量</h2>
<ul>
<li>
<ol>
<li>属性观察器、计算属性的功能，同样可以应用在全局变量和局部变量身上</li>
</ol>
</li>
</ul>
<h3 data-id="heading-27">5.1 全局变量</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num: <span class="hljs-type">Int</span> {
    <span class="hljs-keyword">get</span> {
        <span class="hljs-keyword">return</span> <span class="hljs-number">10</span>
    }
    
    <span class="hljs-keyword">set</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"setNum"</span>, newValue)
    }
}

num <span class="hljs-operator">=</span> <span class="hljs-number">11</span> <span class="hljs-comment">// setNum 11</span>
<span class="hljs-built_in">print</span>(num) <span class="hljs-comment">// 10 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-28">5.2 局部变量</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"willSet"</span>, newValue)
        }
        
        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"didSet"</span>, oldValue, age)
        }
    }
        
    age <span class="hljs-operator">=</span> <span class="hljs-number">11</span>
    <span class="hljs-comment">// willSet 11</span>
    <span class="hljs-comment">// didSet 10 11</span>
}

test() 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-29">6. inout对属性的影响</h2>
<p>看下面的示例代码，分别输出什么，为什么？</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Shape</span> { 
&nbsp; &nbsp; <span class="hljs-keyword">var</span> width: <span class="hljs-type">Int</span>   
&nbsp; &nbsp; <span class="hljs-keyword">var</span> side: <span class="hljs-type">Int</span> { 
&nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-keyword">willSet</span> { 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-built_in">print</span>(<span class="hljs-string">"willSet"</span>, newValue) 
&nbsp; &nbsp; &nbsp; &nbsp; }
  
&nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-keyword">didSet</span> { 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-built_in">print</span>(<span class="hljs-string">"didSet"</span>, oldValue, side) 
&nbsp; &nbsp; &nbsp; &nbsp; } 
&nbsp; &nbsp; }

&nbsp;&nbsp; &nbsp;

&nbsp; &nbsp; <span class="hljs-keyword">var</span> girth: <span class="hljs-type">Int</span> { 
&nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-keyword">set</span> { 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; width <span class="hljs-operator">=</span> newValue <span class="hljs-operator">/</span> side 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-built_in">print</span>(<span class="hljs-string">"setGirth"</span>, newValue) 
&nbsp; &nbsp; &nbsp; &nbsp; }  

&nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-keyword">get</span> { 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-built_in">print</span>(<span class="hljs-string">"getGirth"</span>) 
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-keyword">return</span> width <span class="hljs-operator">*</span> side 
&nbsp; &nbsp; &nbsp; &nbsp; } 
&nbsp; &nbsp; }

&nbsp;&nbsp; &nbsp;

&nbsp; &nbsp; <span class="hljs-keyword">func</span> <span class="hljs-title function_">show</span>() { 
&nbsp; &nbsp; &nbsp; &nbsp; <span class="hljs-built_in">print</span>(<span class="hljs-string">"width=<span class="hljs-subst">\(width)</span>, side=<span class="hljs-subst">\(side)</span>, girth=<span class="hljs-subst">\(girth)</span>"</span>) 
&nbsp; &nbsp; } 
} 

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) { 
&nbsp; &nbsp; num <span class="hljs-operator">=</span> <span class="hljs-number">20</span> 
}
 

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Shape</span>(width: <span class="hljs-number">10</span>, side: <span class="hljs-number">4</span>) 
test(<span class="hljs-operator">&amp;</span>s.width) 
s.show()
 
<span class="hljs-built_in">print</span>(<span class="hljs-string">"--------------------"</span>)   
test(<span class="hljs-operator">&amp;</span>s.side)

s.show() 
<span class="hljs-built_in">print</span>(<span class="hljs-string">"--------------------"</span>) 
test(<span class="hljs-operator">&amp;</span>s.girth) 
s.show()
 

<span class="hljs-comment">// 打印: </span>
<span class="hljs-comment">//getGirth </span>
<span class="hljs-comment">//width=20, side=4, girth=80 </span>
<span class="hljs-comment">//-------------------- </span>
<span class="hljs-comment">//willSet 20 </span>
<span class="hljs-comment">//didSet 4 20 </span>
<span class="hljs-comment">//getGirth </span>
<span class="hljs-comment">//width=20, side=20, girth=400 </span>
<span class="hljs-comment">//-------------------- </span>
<span class="hljs-comment">//getGirth </span>
<span class="hljs-comment">//setGirth 20 </span>
<span class="hljs-comment">//getGirth </span>
<span class="hljs-comment">//width=1, side=20, girth=20 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>第一段打印</strong><br>
初始化的时候会给width赋值为10，side赋值为4，并且不会调用side的属性观察器<br>
然后调用<code>test方法</code>，并传入width的地址值，width变成20<br>
然后调用<code>show方法</code>，会调用girth的getter，然后先执行打印，再计算，girth为80</p>
<p><strong>下面我们通过反汇编来进行分析</strong>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5fc1d06411345e48b5298b546fc5eb5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w963" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4b1df2fda6114e7797c514b125c72220~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w963" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a8030cdce64e4915a42fe6e740e88470~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w965" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/77f27418b516496fae9563a089f7c8ba~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w807" loading="lazy" class="medium-zoom-image"></p>
<p><strong>第二段打印</strong><br>
现在width的值是20，side的值是4，girth的值是80<br>
然后调用<code>test方法</code>，并传入side的地址值，side变成20，并且触发属性观察器，执行打印<br>
然后调用<code>show方法</code>，会调用girth的getter，然后先执行打印，再计算，girth为400</p>
<p><strong>下面我们通过反汇编来进行分析</strong></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2308139e5ef84fdfbe0529d07bbb728e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w960" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4016c951c10349d9b321482156ed3e06~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w351" loading="lazy" class="medium-zoom-image"></p>
<p>将地址值存储到<code>rdi</code>中，并带入到<code>test</code>函数中进行计算</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dc6c66b5d9d94477b8f3ec45a7fd7163~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w959" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18619de80d5e4433bff1110585cbc391~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w960" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fef68a991f484726b25c6404faa16aea~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w870" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li><code>setter</code>中才会真正的调用<code>willSet</code>和<code>didSet</code>方法</li>
<li><code>willSet</code>和<code>didSet</code>之间的计算才是真正的将改变了的值覆盖了全局变量里的side</li>
<li>真正改变了side的值的时候是调用完<code>test函数</code>之后，在内部的<code>setter</code>里进行的</li>
</ul>
<p><strong>第三段打印</strong><br>
现在width的值是20，side的值是20，girth的值是400<br>
然后调用<code>test方法</code>，并传入girth的getter的返回值为400，然后将20赋值给girth的setter计算，width变为1<br>
然后调用<code>show方法</code>，，会调用girth的getter，然后先执行打印，再计算，girth为20</p>
<p><strong>下面我们通过反汇编来进行分析</strong></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fe71f0becd65491781c3db4c04ae8f24~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w962" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5f44242dece54d9b8d0fddefdffd28c1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w371" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b9cc4aea2fd4feb863dbc9aedbf2f6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w961" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/230104d8a6ad497e84dca4ed40986ccd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w963" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4403db87443f44809960b4682a8f0491~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w425" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/31f115cc2baa4beebaa466923e5d557b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w958" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e096666a8f494dbc9ee87abcc9bef9bf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w399" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/10c3f0965b924847bce7b803acedfb15~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w961" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/64be28706705430a92d02e3e1b215f6f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w675" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/624c73ef789a4b5da1b726eba248ce35~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w963" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/15246ce5ef6449e58c2566ba6fe15274~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w614" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/84cee3a22fcf45549921a6f894884adc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w960" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/de8c1f3d95d84590a6ac010cb595160d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w822" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6fa014e3ab3844b0bc76d2151fb12b55~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w961" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9efe2dbf0df44b579ebb387633cce472~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w958" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8ac8d16badd5455fbea46d694f74f6ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w837" loading="lazy" class="medium-zoom-image"></p>
<p>再后面都是计算的过程了，这里就不详细跟进了</p>
<p>我们主要了解<code>inout</code>是怎么给计算属性进行关联调用的，从上面分析可以看出:</p>
<ul>
<li>从调用girth的<code>getter</code>开始，都会将计算的结果放入一个寄存器中</li>
<li>然后通过这个寄存器的地址再进行传递</li>
<li><code>inout</code>影响的也是修改这个寄存器中存储的值，然后再进一步传递到<code>setter</code>里进行计算</li>
</ul>
<blockquote>
<p><strong><code>inout的本质总结</code></strong></p>
</blockquote>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c080e2c15d74ed0b322d1d646e43026~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w947" loading="lazy" class="medium-zoom-image"></p>
<p><strong>对于没有属性观察器的<code>存储属性</code>来说:</strong></p>
<ul>
<li><code>inout</code>的本质就是传进来一个<code>地址值</code>，然后将值存储到这个地址对应的存储空间内</li>
</ul>
<p><strong>对于设置了属性观察器和<code>计算属性</code>来说:</strong></p>
<ul>
<li>
<p><code>inout</code>会先将传进来的地址值放到一个局部变量中，然后改变局部变量地址值对应的存储空间</p>
</li>
<li>
<p>再将改变了的局部变量值覆盖最初传进来的参数的值</p>
<ul>
<li>这时会对应触发属性观察器<code>willSet、didSet</code>和计算属性的<code>setter、getter</code>的调用</li>
</ul>
</li>
<li>
<p>如果不这么做，直接就改变了传进来的地址值的存储空间的话，就不会调用属性观察器了，而计算属性因为没有分配内存来存储值，也就没办法更改了</p>
</li>
<li>
<p><strong>总结:<code>inout</code>的本质就是引用传递（地址传递）</strong></p>
</li>
</ul>
<h2 data-id="heading-30">7. 类型属性（Type Property）</h2>
<ul>
<li>
<ol>
<li>严格来说，属性可以分为两大类:</li>
</ol>
<ul>
<li>实例属性(Instance Property):只能通过实例去访问
<ul>
<li>存储实例属性(Stored Instance Property):存储在实例的内存中，每个实例都有一份</li>
<li>计算实例属性(Computed Instance Property)</li>
</ul>
</li>
<li>类型属性(Type Property):只能通过类去访问
<ul>
<li>存储类型属性(Stored Type Property):整个程序运行过程中，就只有一份内存（类似于全局变量）</li>
<li>计算类型属性(Computed Type Property)</li>
</ul>
</li>
</ul>
</li>
<li>
<ol start="2">
<li>可以通过<code>static</code>定义类型属性</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> count: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">init</span>() {
        <span class="hljs-type">Car</span>.count <span class="hljs-operator">+=</span> <span class="hljs-number">1</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果是类，也可以用关键字<code>class</code>修饰<code>计算属性类型 </code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">class</span> <span class="hljs-title class_">var</span> <span class="hljs-title class_">count</span>: <span class="hljs-title class_">Int</span> {
        <span class="hljs-keyword">return</span> <span class="hljs-number">10</span>
    }
} 
<span class="hljs-built_in">print</span>(<span class="hljs-type">Car</span>.count) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>类里面不能用<code>class</code>修饰<code>存储属性类型</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e4adf6e0bd24884ba8f7449bb50ea73~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<blockquote>
<p>类型属性细节</p>
</blockquote>
<ul>
<li>不同于<code>存储实例属性</code>，<code>存储类型属性</code><strong>必须设定初始值</strong>，不然会报错</li>
<li>因为类型没有像实例那样的<code>init初始化器</code>来初始化存储属性
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fa55c7ff16054344b1687daea819fbd9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w640" loading="lazy" class="medium-zoom-image"></li>
<li><code>存储类型属性</code>可以用<code>let</code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">let</span> count: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span> 
} 
<span class="hljs-built_in">print</span>(<span class="hljs-type">Car</span>.count) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>枚举类型也可以定义类型属性（<code>存储类型属性</code>、<code>计算类型属性</code>）
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Shape</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> width: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">case</span> s1, s2, s3, s4
} 
<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Shape</span>.s1
<span class="hljs-type">Shape</span>.width <span class="hljs-operator">=</span> <span class="hljs-number">5</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li><code>存储类型属性</code>默认就是<code>lazy</code>，会在第一次使用的时候进行初始化
<ul>
<li>就算被多个线程同时访问，保证只会初始化一次</li>
</ul>
</li>
</ul>
<blockquote>
<p><strong>通过反汇编来分析类型属性的底层实现</strong></p>
</blockquote>
<p>我们先通过打印下面两组代码来做对比，发现存储类型属性的内存地址和前后两个全局变量正好相差8个字节，所以可以证明存储类型属性的本质就是类似于全局变量，只是放在了结构体或者类里面控制了访问权限:</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num1 <span class="hljs-operator">=</span> <span class="hljs-number">5</span>
<span class="hljs-keyword">var</span> num2 <span class="hljs-operator">=</span> <span class="hljs-number">6</span>
<span class="hljs-keyword">var</span> num3 <span class="hljs-operator">=</span> <span class="hljs-number">7</span>

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>num1)) <span class="hljs-comment">// 0x000000010000c1c0</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>num2)) <span class="hljs-comment">// 0x000000010000c1c8</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>num3)) <span class="hljs-comment">// 0x000000010000c1d0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num1 <span class="hljs-operator">=</span> <span class="hljs-number">5</span>

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> count <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
}

<span class="hljs-type">Car</span>.count <span class="hljs-operator">=</span> <span class="hljs-number">6</span>

<span class="hljs-keyword">var</span> num3 <span class="hljs-operator">=</span> <span class="hljs-number">7</span>

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>num1)) <span class="hljs-comment">// 0x000000010000c2f8</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span><span class="hljs-type">Car</span>.count)) <span class="hljs-comment">// 0x000000010000c300</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>num3)) <span class="hljs-comment">// 0x000000010000c308</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>然后我们通过反汇编来观察:
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29f41f886ace4c11b2ec6996ace3668a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1086" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3fb52597aea24166872d4a77051d4100~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1086" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e597aad70a124c28b7ecd3eb2d735f2c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1085" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95036cbba74246ba85a028c66ffba1c7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w508" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5ab7bdb03dcf49f3907b2ee304181df8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1086" loading="lazy" class="medium-zoom-image"></p>
<p>通过调用我们可以发现最后会调用到<code>GCD</code>的<code>dispatch_once</code>，所以存储类型属性才会说是线程安全的，并且只执行一次</p>
<p>并且<code>dispatch_once</code>里面执行的代码就是<code>static var count = 1</code></p>
<h2 data-id="heading-31">8.单例模式</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">FileManager</span> {
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">let</span> shared <span class="hljs-operator">=</span> <span class="hljs-type">FileManager</span>()
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">init</span>() { }
    
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">openFile</span>() {
        
    }
}

<span class="hljs-type">FileManager</span>.shared.openFile()
<span class="copy-code-btn">复制代码</span></code></pre>
<hr>
<h1 data-id="heading-32">七、方法（Method）</h1>
<h2 data-id="heading-33">1. 基本概念</h2>
<p>枚举、结构体、类都可以定义<code>实例方法</code>、<code>类型方法</code></p>
<ul>
<li>实例方法（<code>Instance Method</code>）: 通过实例对象调用</li>
<li>类型方法（<code>Type Method</code>）: 通过类型调用
<ul>
<li>实例方法调用
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">var</span> count <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">getCount</span>() -&gt; <span class="hljs-type">Int</span> {
        count
    }
}

<span class="hljs-keyword">let</span> car <span class="hljs-operator">=</span> <span class="hljs-type">Car</span>()
car.getCo 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>类型方法用<code>static</code>或者<code>class</code>关键字定义
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> count <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">getCount</span>() -&gt; <span class="hljs-type">Int</span> {
        count
    }
}

<span class="hljs-type">Car</span>.getCount() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>类型方法中不能调用实例属性，反之实例方法中也不能调用类型属性
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/821ce590fc79410586ee545f4fb7a6e7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w645" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/34b3768d7ca04c149eab2017d5cffe29~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
<li>不管是类型方法还是实例方法，都会传入隐藏参数<code>self</code></li>
<li><code>self</code>在实例方法中代表实例对象</li>
<li><code>self</code>在类型方法中代表类型
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// count等于self.count、Car.self.count、Car.count</span>
<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">getCount</span>() -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-keyword">self</span>.count
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-34">2. mutating</h2>
<ul>
<li><code>结构体</code>和<code>枚举</code>是<code>值类型</code>,默认情况下,值类型的属性不能被自身的实例方法修改</li>
<li>在<code>func</code>关键字前面加上<code>mutating</code>可以允许这种修改行为
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>

    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">moveBy</span>(<span class="hljs-params">deltaX</span>: <span class="hljs-type">Double</span>, <span class="hljs-params">deltaY</span>: <span class="hljs-type">Double</span>) {
        x <span class="hljs-operator">+=</span> deltaX
        y <span class="hljs-operator">+=</span> deltaY
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">StateSwitch</span> {
    <span class="hljs-keyword">case</span> low, middle, high

    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">next</span>() {
        <span class="hljs-keyword">switch</span> <span class="hljs-keyword">self</span> {
        <span class="hljs-keyword">case</span> .low:
            <span class="hljs-keyword">self</span> <span class="hljs-operator">=</span> .middle
        <span class="hljs-keyword">case</span> .middle:
            <span class="hljs-keyword">self</span> <span class="hljs-operator">=</span> .high
        <span class="hljs-keyword">case</span> .high:
            <span class="hljs-keyword">self</span> <span class="hljs-operator">=</span> .low
        }
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-35">3. @discardableResult</h2>
<ul>
<li>在<code>func</code>前面加上<code>@discardableResult</code>，可以消除函数调用后<code>返回值未被使用的警告 </code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>

    <span class="hljs-keyword">@discardableResult</span> <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">moveX</span>(<span class="hljs-params">deltaX</span>: <span class="hljs-type">Double</span>) -&gt; <span class="hljs-type">Double</span> {
        x <span class="hljs-operator">+=</span> deltaX
        <span class="hljs-keyword">return</span> x
    }
}

<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
p.moveX(deltaX: <span class="hljs-number">10</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h1 data-id="heading-36">八、下标（subscript）</h1>
<h2 data-id="heading-37">1. 基本概念</h2>
<ul>
<li>
<ol>
<li>使用<code>subscript</code>可以给任意类型（<code>枚举</code>、<code>结构体</code>、<code>类</code>）增加下标功能<br>
有些地方也翻译成：下标脚本</li>
</ol>
</li>
<li>
<ol start="2">
<li><code>subscript</code>的语法类似于实例方法、计算属性，本质就是方法（函数）</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>
    
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">set</span> {
            <span class="hljs-keyword">if</span> index <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
                x <span class="hljs-operator">=</span> newValue
            } <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> index <span class="hljs-operator">==</span> <span class="hljs-number">1</span> {
                y <span class="hljs-operator">=</span> newValue
            }
        }
        
        <span class="hljs-keyword">get</span> {
            <span class="hljs-keyword">if</span> index <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
                <span class="hljs-keyword">return</span> x
            } <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> index <span class="hljs-operator">==</span> <span class="hljs-number">1</span> {
                <span class="hljs-keyword">return</span> y
            } 
            <span class="hljs-keyword">return</span> <span class="hljs-number">0</span>
        }
    }
}

<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
p[<span class="hljs-number">0</span>] <span class="hljs-operator">=</span> <span class="hljs-number">11.1</span>
p[<span class="hljs-number">1</span>] <span class="hljs-operator">=</span> <span class="hljs-number">22.2</span>
<span class="hljs-built_in">print</span>(p.x) <span class="hljs-comment">// 11.1</span>
<span class="hljs-built_in">print</span>(p.y) <span class="hljs-comment">// 22.2</span>
<span class="hljs-built_in">print</span>(p[<span class="hljs-number">0</span>]) <span class="hljs-comment">// 11.1</span>
<span class="hljs-built_in">print</span>(p[<span class="hljs-number">1</span>]) <span class="hljs-comment">// 22.2 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li><code>subscript</code>中定义的返回值类型决定了<code>getter</code>中返回值类型和<code>setter</code>中<code>newValue</code>的类型</li>
</ol>
</li>
<li>
<ol start="4">
<li><code>subscript</code>可以接收多个参数，并且类型任意</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Grid</span> {
    <span class="hljs-keyword">var</span> data <span class="hljs-operator">=</span> [
        [<span class="hljs-number">0</span>, <span class="hljs-number">1</span> ,<span class="hljs-number">2</span>],
        [<span class="hljs-number">3</span>, <span class="hljs-number">4</span>, <span class="hljs-number">5</span>],
        [<span class="hljs-number">6</span>, <span class="hljs-number">7</span>, <span class="hljs-number">8</span>]
    ]

    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">row</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">column</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> {
            <span class="hljs-keyword">guard</span> row <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> row <span class="hljs-operator">&lt;</span> <span class="hljs-number">3</span> <span class="hljs-operator">&amp;&amp;</span> column <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> column <span class="hljs-operator">&lt;</span> <span class="hljs-number">3</span> <span class="hljs-keyword">else</span> { <span class="hljs-keyword">return</span> }
            data[row][column] <span class="hljs-operator">=</span> newValue
        }

        <span class="hljs-keyword">get</span> {
            <span class="hljs-keyword">guard</span> row <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> row <span class="hljs-operator">&lt;</span> <span class="hljs-number">3</span> <span class="hljs-operator">&amp;&amp;</span> column <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> column <span class="hljs-operator">&lt;</span> <span class="hljs-number">3</span> <span class="hljs-keyword">else</span> { <span class="hljs-keyword">return</span> <span class="hljs-number">0</span> }
            <span class="hljs-keyword">return</span> data[row][column]
        }
    }
} 
<span class="hljs-keyword">var</span> grid <span class="hljs-operator">=</span> <span class="hljs-type">Grid</span>()
grid[<span class="hljs-number">0</span>, <span class="hljs-number">1</span>] <span class="hljs-operator">=</span> <span class="hljs-number">77</span>
grid[<span class="hljs-number">1</span>, <span class="hljs-number">2</span>] <span class="hljs-operator">=</span> <span class="hljs-number">88</span>
grid[<span class="hljs-number">2</span>, <span class="hljs-number">0</span>] <span class="hljs-operator">=</span> <span class="hljs-number">99</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li><code>subscript</code>可以没有<code>setter</code>，但必须要有<code>getter</code>，同计算属性</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span> 
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">get</span> {
            <span class="hljs-keyword">if</span> index <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
                <span class="hljs-keyword">return</span> x
            } <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> index <span class="hljs-operator">==</span> <span class="hljs-number">1</span> {
                <span class="hljs-keyword">return</span> y
            } 
            <span class="hljs-keyword">return</span> <span class="hljs-number">0</span>
        }
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="6">
<li><code>subscript</code>如果只有<code>getter</code>，可以省略<code>getter</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span> 
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">if</span> index <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
            <span class="hljs-keyword">return</span> x
        } <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> index <span class="hljs-operator">==</span> <span class="hljs-number">1</span> {
            <span class="hljs-keyword">return</span> y
        } 
        <span class="hljs-keyword">return</span> <span class="hljs-number">0</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="7">
<li><code>subscript</code>可以设置参数标签<br>
只有设置了自定义标签的调用才需要写上参数标签
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span> 
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Double</span> {
        <span class="hljs-keyword">if</span> i <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
            <span class="hljs-keyword">return</span> x
        } <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> i <span class="hljs-operator">==</span> <span class="hljs-number">1</span> {
            <span class="hljs-keyword">return</span> y
        }

        <span class="hljs-keyword">return</span> <span class="hljs-number">0</span>
    }
}

<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
p.y <span class="hljs-operator">=</span> <span class="hljs-number">22.2</span>
<span class="hljs-built_in">print</span>(p[index: <span class="hljs-number">1</span>]) <span class="hljs-comment">// 22.2 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ol>
</li>
<li>8.<code>subscript</code>可以是类型方法
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Sum</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">subscript</span>(<span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        v1 <span class="hljs-operator">+</span> v2
    }
} 
<span class="hljs-built_in">print</span>(<span class="hljs-type">Sum</span>[<span class="hljs-number">10</span>, <span class="hljs-number">20</span>]) <span class="hljs-comment">// 30 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<blockquote>
<p><strong>通过反汇编来分析</strong></p>
</blockquote>
<p>看下面的示例代码，我们将断点打到图上的位置，然后观察反汇编</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eee7f7f5299245879b4ee35b6898cf44~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w710" loading="lazy" class="medium-zoom-image"></p>
<p>看到其内部是会调用<code>setter</code>来进行计算</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5c779a1690154074ad390a09275cecff~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w708" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dcc337e8548b429fa24e06e8b36202f4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w714" loading="lazy" class="medium-zoom-image"></p>
<p>然后再将断点打到这里来看</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/61185b4065e54f1db581d1517112cacf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w552" loading="lazy" class="medium-zoom-image"></p>
<p>看到其内部是会调用<code>getter</code>来进行计算 <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/29c9cb259eec4610936b97a9ab5fac3f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w712" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dad3b8fab86e43da91b7d7d8135a9f98~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image"></p>
<p>经上述分析就可以证明<code>subscript</code>本质就是方法调用</p>
<h2 data-id="heading-38">2. 结构体和类作为返回值对比</h2>
<p>看下面的示例代码</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">PointManager</span> {
    <span class="hljs-keyword">var</span> point <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Point</span> {
        <span class="hljs-keyword">set</span> { point <span class="hljs-operator">=</span> newValue }
        <span class="hljs-keyword">get</span> { point }
    }
}

<span class="hljs-keyword">var</span> pm <span class="hljs-operator">=</span> <span class="hljs-type">PointManager</span>()
pm[<span class="hljs-number">0</span>].x <span class="hljs-operator">=</span> <span class="hljs-number">11</span> <span class="hljs-comment">// 等价于pm[0] = Point(x: 11, y: pm[0].y)</span>
pm[<span class="hljs-number">0</span>].y <span class="hljs-operator">=</span> <span class="hljs-number">22</span> <span class="hljs-comment">// 等价于pm[0] = Point(x: pm[0].x, y: 22) </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>如果我们注释掉<code>setter</code>，那么调用会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a6291e522984427cab617ad5bc7b2d25~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image">
但是我们将结构体换成类，就不会报错了
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc397b02db4e4a8ba2bbf2502633b205~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w624" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>原因还是在于结构体是<code>值类型</code>，通过<code>getter</code>得到的<code>Point</code>结构体只是<code>临时的值</code>（可以想成计算属性），并不是真正的存储属性point，所以会报错
<ul>
<li>通过打印也可以看出来要修改的并不是同一个地址值的point
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e035ac4da994f1ea8beb96d272fadc3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
<li>但换成了类，那么通过<code>getter</code>得到的<code>Point</code>类是一个指针变量，而修改的是指向堆空间中的<code>Point</code>的属性，所以不会报错</li>
</ul>
<h2 data-id="heading-39">3.接收多个参数的下标</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Grid</span> {
    <span class="hljs-keyword">var</span> data <span class="hljs-operator">=</span> [
        [<span class="hljs-number">0</span>, <span class="hljs-number">1</span>, <span class="hljs-number">2</span>], 
        [<span class="hljs-number">3</span>, <span class="hljs-number">4</span>, <span class="hljs-number">5</span>], 
        [<span class="hljs-number">6</span>, <span class="hljs-number">7</span>, <span class="hljs-number">8</span>] 
    ] 
    
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">row</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">column</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { 
        <span class="hljs-keyword">set</span> { 
            <span class="hljs-keyword">guard</span> row <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> row <span class="hljs-operator">&lt;</span> <span class="hljs-number">3</span> <span class="hljs-operator">&amp;&amp;</span> column <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> column <span class="hljs-operator">&lt;</span> <span class="hljs-number">3</span> <span class="hljs-keyword">else</span> {
                <span class="hljs-keyword">return</span> 
            }
            data[row][column] <span class="hljs-operator">=</span> newValue 
        } 
    
        <span class="hljs-keyword">get</span> { 
            <span class="hljs-keyword">guard</span> row <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> row <span class="hljs-operator">&lt;</span> <span class="hljs-number">3</span> <span class="hljs-operator">&amp;&amp;</span> column <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> column <span class="hljs-operator">&lt;</span> <span class="hljs-number">3</span> <span class="hljs-keyword">else</span> { 
                <span class="hljs-keyword">return</span> <span class="hljs-number">0</span> 
            } 
            <span class="hljs-keyword">return</span> data[row][column] 
        }

    } 
}

<span class="hljs-keyword">var</span> grid <span class="hljs-operator">=</span> <span class="hljs-type">Grid</span>() 
grid[<span class="hljs-number">0</span>,<span class="hljs-number">1</span>] <span class="hljs-operator">=</span> <span class="hljs-number">77</span> 
grid[<span class="hljs-number">1</span>,<span class="hljs-number">2</span>] <span class="hljs-operator">=</span> <span class="hljs-number">88</span> 
grid[<span class="hljs-number">2</span>,<span class="hljs-number">0</span>] <span class="hljs-operator">=</span> <span class="hljs-number">99</span> 
<span class="hljs-built_in">print</span>(grid.data)
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-40">九、继承（Inheritance）</h1>
<h2 data-id="heading-41">1. 基本概念</h2>
<ul>
<li><code>继承:</code> 值类型（结构体、枚举）不支持继承，只有引用类型的类支持继承</li>
<li><code>基类:</code> 没有父类的类，叫做基类</li>
<li><code>Swift</code>并没有像<code>OC、Java</code>那样的规定，任何类最终都要继承自某个基类
<img src="https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ccf8006df0db467080740e343e7b7a54~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></li>
<li><code>子类</code>可以重写从<code>父类</code>继承过来的<code>下标</code>、<code>方法</code>、<code>属性</code>。重写必须加上<code>override</code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"run"</span>)
    }
}


<span class="hljs-keyword">class</span> <span class="hljs-title class_">Truck</span>: <span class="hljs-title class_">Car</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {

    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-42">2.内存结构</h2>
<p>看下面几个类的内存占用是多少</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span>: <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">var</span> weight <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">ErHa</span>: <span class="hljs-title class_">Dog</span> {
    <span class="hljs-keyword">var</span> iq <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">let</span> a <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>()
a.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofRef: a)) <span class="hljs-comment">// 32</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofRef: a))

<span class="hljs-comment">//0x000000010000c3c8</span>
<span class="hljs-comment">//0x0000000000000003</span>
<span class="hljs-comment">//0x000000000000000a</span>
<span class="hljs-comment">//0x000000000000005f</span>

<span class="hljs-keyword">let</span> d <span class="hljs-operator">=</span> <span class="hljs-type">Dog</span>()
d.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
d.weight <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofRef: d)) <span class="hljs-comment">// 32</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofRef: d))

<span class="hljs-comment">//0x000000010000c478</span>
<span class="hljs-comment">//0x0000000000000003</span>
<span class="hljs-comment">//0x000000000000000a</span>
<span class="hljs-comment">//0x0000000000000014</span>

<span class="hljs-keyword">let</span> e <span class="hljs-operator">=</span> <span class="hljs-type">ErHa</span>()
e.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
e.weight <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
e.iq <span class="hljs-operator">=</span> <span class="hljs-number">30</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofRef: e)) <span class="hljs-comment">// 48</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofRef: e))

<span class="hljs-comment">//0x000000010000c548</span>
<span class="hljs-comment">//0x0000000000000003</span>
<span class="hljs-comment">//0x000000000000000a</span>
<span class="hljs-comment">//0x0000000000000014</span>
<span class="hljs-comment">//0x000000000000001e</span>
<span class="hljs-comment">//0x0000000000000000 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol>
<li>首先类内部会有16个字节:存储<code>类信息</code>和<code>引用计数</code></li>
</ol>
</li>
<li>
<ol start="2">
<li>然后才是成员变量/常量的内存(<code>存储属性</code>)</li>
</ol>
</li>
<li>
<ol start="3">
<li>又由于堆空间分配内存,存在内存对齐的概念,其原则分配的内存大小为16的倍数且刚好大于或等于初始化一个该数据类型变量所需的字节数</li>
</ol>
</li>
<li>
<ol start="4">
<li>基于前面的规则,最终得出结论:所分配的内存空间分别占用为<code>32</code>、<code>32</code>、<code>48</code></li>
</ol>
</li>
<li>
<ol start="5">
<li>Tips:子类会继承自父类的属性，所以内存会算上父类的属性存储空间</li>
</ol>
</li>
</ul>
<h2 data-id="heading-43">3. 重写实例方法、下标</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">speak</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal speak"</span>)
    }
    
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        index
    }
}

<span class="hljs-keyword">var</span> ani: <span class="hljs-type">Animal</span>
ani <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>()
ani.speak()
<span class="hljs-built_in">print</span>(ani[<span class="hljs-number">6</span>])

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Cat</span>: <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">speak</span>() {
        <span class="hljs-keyword">super</span>.speak()
        
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Cat speak"</span>)
    }
    
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">super</span>[index] <span class="hljs-operator">+</span> <span class="hljs-number">1</span>
    }
}

ani <span class="hljs-operator">=</span> <span class="hljs-type">Cat</span>()
ani.speak()
<span class="hljs-built_in">print</span>(ani[<span class="hljs-number">7</span>]) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol>
<li>被<code>class</code>修饰的类型<code>方法</code>、<code>下标</code>，允许被子类重写</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">class</span> <span class="hljs-title class_">func</span> <span class="hljs-title class_">speak</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal speak"</span>)
    }

    <span class="hljs-keyword">class</span> <span class="hljs-title class_">subscript</span>(<span class="hljs-title class_">index</span>: <span class="hljs-title class_">Int</span>) -&gt; <span class="hljs-title class_">Int</span> {
        index
    }
}


<span class="hljs-type">Animal</span>.speak()
<span class="hljs-built_in">print</span>(<span class="hljs-type">Animal</span>[<span class="hljs-number">6</span>])

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Cat</span>: <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">func</span> <span class="hljs-title class_">speak</span>() {
        <span class="hljs-keyword">super</span>.speak()

        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Cat speak"</span>)
    }

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">subscript</span>(<span class="hljs-title class_">index</span>: <span class="hljs-title class_">Int</span>) -&gt; <span class="hljs-title class_">Int</span> {
        <span class="hljs-keyword">super</span>[index] <span class="hljs-operator">+</span> <span class="hljs-number">1</span>
    }
}

<span class="hljs-type">Cat</span>.speak()
<span class="hljs-built_in">print</span>(<span class="hljs-type">Cat</span>[<span class="hljs-number">7</span>]) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>被<code>static</code>修饰的类型方法、下标，不允许被子类重写
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/615e2193e883491fbc45c9c531860185~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w571" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4afd111508704971875cca945f656fd0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w646" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>但是被<code>class</code>修饰的类型方法、下标，子类重写时允许使用<code>static</code>修饰<br>
但再后面的子类就不被允许了</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">class</span> <span class="hljs-title class_">func</span> <span class="hljs-title class_">speak</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal speak"</span>)
    }

    <span class="hljs-keyword">class</span> <span class="hljs-title class_">subscript</span>(<span class="hljs-title class_">index</span>: <span class="hljs-title class_">Int</span>) -&gt; <span class="hljs-title class_">Int</span> {
        index
    }
}


<span class="hljs-type">Animal</span>.speak()
<span class="hljs-built_in">print</span>(<span class="hljs-type">Animal</span>[<span class="hljs-number">6</span>])

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Cat</span>: <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">speak</span>() {
        <span class="hljs-keyword">super</span>.speak()

        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Cat speak"</span>)
    }

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">super</span>[index] <span class="hljs-operator">+</span> <span class="hljs-number">1</span>
    }
}

<span class="hljs-type">Cat</span>.speak()
<span class="hljs-built_in">print</span>(<span class="hljs-type">Cat</span>[<span class="hljs-number">7</span>]) 
<span class="copy-code-btn">复制代码</span></code></pre>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87766e3668e340fd912a5b87363b8f7b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w634" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-44">4. 重写属性</h2>
<ul>
<li>
<ol>
<li>子类可以将父类的属性（存储、计算）重写为计算属性</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span>: <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> {

        }

        <span class="hljs-keyword">get</span> {
            <span class="hljs-number">10</span>
        }
    }
    <span class="hljs-keyword">var</span> weight <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>但子类<code>不可以</code>将父类的属性重写为<code>存储属性</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d2d1a89318a143bebbb37a77ec8e93b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3506b968c7454367be459f52b85160b9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w638" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>只能重写<code>var</code>属性，不能重新<code>let</code>属性
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ead7d3af36a4d0a8dd92e28121ee6cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="4">
<li>重写时，属性名、类型要一致
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/87ab8d0c201f424f988161c658f01b2f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w639" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="5">
<li>子类重写后的属性权限不能小于父类的属性权限</li>
</ol>
<ul>
<li>如果父类属性是<code>只读的</code>，那么子类重写后的属性<code>可以是只读的</code>，<code>也可以是可读可写的</code></li>
<li>如果父类属性是<code>可读可写的</code>，那么子类重写后的属性也<code>必须是可读可写的</code></li>
</ul>
</li>
</ul>
<h3 data-id="heading-45">4.1 重写实例属性</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

    <span class="hljs-comment">// 计算属性</span>
    <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span>(newDiameter) {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle setDiameter"</span>)
            radius <span class="hljs-operator">=</span> newDiameter <span class="hljs-operator">/</span> <span class="hljs-number">2</span>
        }

        <span class="hljs-keyword">get</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle getDiameter"</span>)
            <span class="hljs-keyword">return</span> radius <span class="hljs-operator">*</span> <span class="hljs-number">2</span>
        }
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">SubCircle</span>: <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle setRadius"</span>)
            <span class="hljs-keyword">super</span>.radius <span class="hljs-operator">=</span> newValue <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> newValue : <span class="hljs-number">0</span>
        }

        <span class="hljs-keyword">get</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle getRadius"</span>)
            <span class="hljs-keyword">return</span> <span class="hljs-keyword">super</span>.radius
        }
    }
    
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle setDiameter"</span>)
            <span class="hljs-keyword">super</span>.diameter <span class="hljs-operator">=</span> newValue <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> newValue : <span class="hljs-number">0</span>
        }

        <span class="hljs-keyword">get</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle getDiameter"</span>)
            <span class="hljs-keyword">return</span> <span class="hljs-keyword">super</span>.diameter
        }
    }
}

<span class="hljs-keyword">var</span> c <span class="hljs-operator">=</span> <span class="hljs-type">SubCircle</span>()
c.radius <span class="hljs-operator">=</span> <span class="hljs-number">6</span>
<span class="hljs-built_in">print</span>(c.diameter)

c.diameter <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
<span class="hljs-built_in">print</span>(c.radius)

<span class="hljs-comment">//SubCircle setRadius</span>

<span class="hljs-comment">//SubCircle getDiameter</span>
<span class="hljs-comment">//Circle getDiameter</span>
<span class="hljs-comment">//SubCircle getRadius</span>
<span class="hljs-comment">//12</span>

<span class="hljs-comment">//SubCircle setDiameter</span>
<span class="hljs-comment">//Circle setDiameter</span>
<span class="hljs-comment">//SubCircle setRadius</span>

<span class="hljs-comment">//SubCircle getRadius</span>
<span class="hljs-comment">//10 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="6">
<li>从父类继承过来的<code>存储属性</code>，<strong>都会分配内存空间</strong>，<strong><code>不管</code></strong> 之后会不会被重写为计算属性</li>
</ol>
</li>
<li>
<ol start="7">
<li>如果重写的方法里的<code>setter</code>和<code>getter</code>不写<code>super</code>，那么就会死循环</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">SubCircle</span>: <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle setRadius"</span>)
            radius <span class="hljs-operator">=</span> newValue <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> newValue : <span class="hljs-number">0</span>
        }

        <span class="hljs-keyword">get</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle getRadius"</span>)
            <span class="hljs-keyword">return</span> radius
        }
    }    
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h3 data-id="heading-46">4.2 重写类型属性</h3>
<ul>
<li>
<ol>
<li>被<code>class</code>修饰的计算类型属性，<code>可以</code>被子类重写</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-comment">// 存储属性</span>
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span> 
    <span class="hljs-comment">// 计算属性</span>
    <span class="hljs-keyword">class</span> <span class="hljs-title class_">var</span> <span class="hljs-title class_">diameter</span>: <span class="hljs-title class_">Int</span> {
        <span class="hljs-keyword">set</span>(newDiameter) {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle setDiameter"</span>)
            radius <span class="hljs-operator">=</span> newDiameter <span class="hljs-operator">/</span> <span class="hljs-number">2</span>
        } 
        <span class="hljs-keyword">get</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle getDiameter"</span>)
            <span class="hljs-keyword">return</span> radius <span class="hljs-operator">*</span> <span class="hljs-number">2</span>
        }
    }
} 
<span class="hljs-keyword">class</span> <span class="hljs-title class_">SubCircle</span>: <span class="hljs-title class_">Circle</span> { 
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> diameter: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle setDiameter"</span>)
            <span class="hljs-keyword">super</span>.diameter <span class="hljs-operator">=</span> newValue <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> newValue : <span class="hljs-number">0</span>
        } 
        <span class="hljs-keyword">get</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle getDiameter"</span>)
            <span class="hljs-keyword">return</span> <span class="hljs-keyword">super</span>.diameter
        }
    }
}

<span class="hljs-type">Circle</span>.radius <span class="hljs-operator">=</span> <span class="hljs-number">6</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Circle</span>.diameter)

<span class="hljs-type">Circle</span>.diameter <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Circle</span>.radius)

<span class="hljs-type">SubCircle</span>.radius <span class="hljs-operator">=</span> <span class="hljs-number">6</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">SubCircle</span>.diameter)

<span class="hljs-type">SubCircle</span>.diameter <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">SubCircle</span>.radius)

<span class="hljs-comment">//Circle getDiameter</span>
<span class="hljs-comment">//12</span>

<span class="hljs-comment">//Circle setDiameter</span>
<span class="hljs-comment">//10</span>

<span class="hljs-comment">//SubCircle getDiameter</span>
<span class="hljs-comment">//Circle getDiameter</span>
<span class="hljs-comment">//12</span>

<span class="hljs-comment">//SubCircle setDiameter</span>
<span class="hljs-comment">//Circle setDiameter</span>
<span class="hljs-comment">//10 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>被<code>static</code>修饰的类型属性(计算、存储）,<code>不可以</code>被子类重写
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/18f27d1f7ebf4f45bb65dbaa2063f0cf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w861" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-47">5. 属性观察器</h2>
<ul>
<li>
<ol>
<li>可以在子类中为父类属性（除了只读计算属性、<code>let</code>属性）增加属性观察器<br>
重写后还是存储属性，不是变成了计算属性</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">SubCircle</span>: <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle willSetRadius"</span>, newValue)
        }

        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle didSetRadius"</span>, oldValue, radius)
        }
    }
}

<span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">SubCircle</span>()
circle.radius <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

<span class="hljs-comment">//SubCircle willSetRadius 10</span>
<span class="hljs-comment">//SubCircle didSetRadius 1 10 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>如果父类里也有属性观察器:</li>
</ol>
<ul>
<li>那么子类赋值时，会先调用自己的属性观察器<code>willSet</code>,然后调用父类的属性观察器<code>willSet</code>；</li>
<li>并且在父类里面才是真正的进行赋值</li>
<li>然后先父类的<code>didSet</code>，最后再调用自己的<code>didSet</code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">1</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle willSetRadius"</span>, newValue)
        }

        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle didSetRadius"</span>, oldValue, radius)
        }
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">SubCircle</span>: <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle willSetRadius"</span>, newValue)
        }

        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle didSetRadius"</span>, oldValue, radius)
        }
    }
}

<span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">SubCircle</span>()
circle.radius <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

<span class="hljs-comment">//SubCircle willSetRadius 10</span>
<span class="hljs-comment">//Circle willSetRadius 10</span>
<span class="hljs-comment">//Circle didSetRadius 1 10</span>
<span class="hljs-comment">//SubCircle didSetRadius 1 10 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
</li>
<li>
<ol start="3">
<li>可以给父类的<code>计算属性</code>增加属性观察器</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle setRadius"</span>, newValue)
        }

        <span class="hljs-keyword">get</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"Circle getRadius"</span>)
            <span class="hljs-keyword">return</span> <span class="hljs-number">20</span>
        }
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">SubCircle</span>: <span class="hljs-title class_">Circle</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">var</span> radius: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle willSetRadius"</span>, newValue)
        } 
        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"SubCircle didSetRadius"</span>, oldValue, radius)
        }
    }
}

<span class="hljs-keyword">var</span> circle <span class="hljs-operator">=</span> <span class="hljs-type">SubCircle</span>()
circle.radius <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

<span class="hljs-comment">//Circle getRadius</span>
<span class="hljs-comment">//SubCircle willSetRadius 10</span>
<span class="hljs-comment">//Circle setRadius 10</span>
<span class="hljs-comment">//Circle getRadius</span>
<span class="hljs-comment">//SubCircle didSetRadius 20 20 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<p>上面打印会先调用一次<code>Circle getRadius</code>是因为在设置值之前会先拿到它的<code>oldValue</code>，所以需要调用<code>getter</code>一次</p>
<p>为了测试，我们将<code>oldValue</code>的获取去掉后，再打印发现就没有第一次的<code>getter</code>的调用了</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a0343cfec35740fcb77982ff96267dbd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w717" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-48">6.final</h2>
<ul>
<li>
<ol>
<li>被<code>final</code>修饰的<code>方法</code>、<code>下标</code>、<code>属性</code>，禁止被重写
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ccf17c068f94675958d85987162f5dd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w643" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b108314a8bc74118b5bb5dc9c213aea1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/61b66e59c2034bd0b3e373d0665d95d8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w640" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="2">
<li>被<code>final</code>修饰的类，禁止被继承
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/115cfb3c712e48b6b94af68a9b1b65b1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-49">7. 方法调用的本质</h2>
<ul>
<li>
<ol>
<li>我们先看下面的示例代码，分析<code>结构体</code>和<code>类</code>的调用方法区别是什么</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">speak</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal speak"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal eat"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">sleep</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal sleep"</span>)
    }
}

<span class="hljs-keyword">var</span> ani <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>()
ani.speak()
ani.eat()
ani.sleep() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>反汇编之后，发现结构体的方法调用就是<strong>直接找到方法所在地址直接调用</strong><br>
结构体的<code>方法地址都是固定的</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/752cc3d50e4c45419ce8afbfabd8dbcc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w715" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>接下来 我们在看换成<code>类</code>之后反汇编的实现是怎样的</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">speak</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal speak"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal eat"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">sleep</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal sleep"</span>)
    }
}

<span class="hljs-keyword">var</span> ani <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>()
ani.speak()
ani.eat()
ani.sleep() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>反汇编之后，会发现需要<code>调用的方法地址</code>是<strong>不确定</strong>的<br>
所以凡是<strong>调用固定地址</strong>的<code>都不会是类的方法</code>的调用
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/df6aa4298ea04c36ba4c0c73278c1613~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1189" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6195c8a7683449b09fd9de09dcae7770~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1192" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1b553e2aec2a4dd6b137720c92927df6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1190" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/910f04a6b13a4401b3a8a089f00293dc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1186" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1e1af14c97064f2b8a3b5292a12f6a9d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1185" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bee00d70a4945a2b43b3b5a34c23cb6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1187" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/550d001c28ea43f4810113b5fe8c0f74~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1189" loading="lazy" class="medium-zoom-image"></li>
</ol>
<ul>
<li>而且上述的几个调用的方法地址都是从<code>rcx</code>往高地址偏移<code>8</code>个字节来调用的，也就说明几个方法地址都是连续的</li>
<li>我们再来分析下方法调用前做了什么:</li>
<li>通过反汇编我们可以看到:
<ul>
<li>会从<code>全局变量</code>的指针找到其<code>指向的堆内存</code>中的类的存储空间</li>
<li>然后<code>再根据类的前8个字节</code>里的<code>类信息</code>知道需要调用的方法地址</li>
<li>从<strong>类信息的地址进行偏移</strong>找到<code>方法地址</code>，然后调用
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/74b06640e5f344bda01f2a511199e65d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1140" loading="lazy" class="medium-zoom-image"></li>
</ul>
</li>
<li>然后我们将示例代码修改一下，再观察其本质是什么</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">speak</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal speak"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal eat"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">sleep</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Animal sleep"</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span>: <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">speak</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Dog speak"</span>)
    }

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Dog eat"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Dog run"</span>)
    }
}

<span class="hljs-keyword">var</span> ani <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>()
ani.speak()
ani.eat()
ani.sleep()

ani <span class="hljs-operator">=</span> <span class="hljs-type">Dog</span>()
ani.speak()
ani.eat()
ani.sleep() 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>增加了子类后</code>，Dog的类信息里的方法列表会存有重写后的父类方法，以及自己新增的方法</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span>: <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Dog run"</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<p>如果子类里<code>没有重写父类方法</code>，那么类信息里的方法列表会有父类的方法，以及自己新增的方法</p>
</li>
</ul>
</li>
</ul>
<h1 data-id="heading-50">十、初始化器</h1>
<h2 data-id="heading-51">1. 类的初始化器</h2>
<ul>
<li>
<ol>
<li><code>类</code>、<code>结构体</code>、<code>枚举</code>都可以定义初始化器</li>
</ol>
<ul>
<li><strong>类有两种初始化器:</strong></li>
<li>指定初始化器（<code>designated initializer</code>）</li>
<li>便捷初始化器（<code>convenience initializer</code>）
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 指定初始化器</span>
<span class="hljs-keyword">init</span>(parameters) {
    statements
}

<span class="hljs-comment">// 便捷初始化器</span>
<span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(parameters) {
    statements
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
</li>
<li>
<ol start="2">
<li>每个类<code>至少有一个</code><strong>指定初始化器</strong><br>
指定初始化器是类的主要初始化器</li>
</ol>
</li>
<li>
<ol start="3">
<li>默认初始化器总是类的指定初始化器</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
    <span class="hljs-keyword">init</span>() {

    }

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {

    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">height</span>: <span class="hljs-type">Double</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>()
    }
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>()
s <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>(height: <span class="hljs-number">180</span>)
s <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>(age: <span class="hljs-number">10</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>类本身会自带一个指定初始化器</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {

}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li>如果有自定义的指定初始化器，默认的指定初始化器就不存在了
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/da7f3104587044b392f3d7b85f228080~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="6">
<li>类偏向于<code>少量指定初始化器</code><br>
一个类通常只有一个指定初始化器</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span> {
    <span class="hljs-keyword">var</span> width: <span class="hljs-type">Double</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> height: <span class="hljs-type">Double</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">height</span>: <span class="hljs-type">Double</span>, <span class="hljs-params">width</span>: <span class="hljs-type">Double</span>) {
        <span class="hljs-keyword">self</span>.width <span class="hljs-operator">=</span> width
        <span class="hljs-keyword">self</span>.height <span class="hljs-operator">=</span> height
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">height</span>: <span class="hljs-type">Double</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(height: height, width: <span class="hljs-number">0</span>)
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">width</span>: <span class="hljs-type">Double</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(height: <span class="hljs-number">0</span>,width: width)
    }
}

<span class="hljs-keyword">let</span> size <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>(height: <span class="hljs-number">180</span>, width: <span class="hljs-number">70</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-52">2. 初始化器的相互调用</h2>
<p><strong>初始化器的相互调用规则</strong></p>
<ul>
<li><code>指定初始化器</code>必须从它的直系父类调用<code>指定初始化器</code></li>
<li><code>便捷初始化器</code>必须从相同的类里调用<code>另一个初始化器</code></li>
<li><code>便捷初始化器</code>最终必须调用一个<code>指定初始化器 </code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)

        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> score: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">score</span>: <span class="hljs-type">Int</span>) {

        <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> score
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: age)

        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> <span class="hljs-number">30</span>
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">score</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>, score: score)

        <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> <span class="hljs-number">100</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<p><strong>这一套规则保证了:</strong><br>
使用任何初始化器，都可以完整地初始化实例
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ee15a2cdbe9249b5a2d4ba7c515497a4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1211" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-53">3. 两段式初始化和安全检查</h2>
<p>Swift在编码安全方面煞费苦心，为了保证初始化过程的安全，设定了<code>两段式初始化</code>和<code>安全检查</code></p>
<h3 data-id="heading-54">3.1 两段式初始化</h3>
<p><strong>第一阶段: <code>初始化所有存储属性</code></strong></p>
<ul>
<li>外层调用 <strong><code>指定/便捷</code>初始化器</strong></li>
<li>分配内存给实例,但未初始化</li>
<li><strong><code>指定初始化器</code></strong> 确保<strong>当前类定义的存储属性都初始化</strong></li>
<li><strong><code>指定初始化器</code></strong> 调用父类的初始化器,不断向上调用，形成<code>初始化器链</code></li>
</ul>
<p><strong>第二阶段: 设置新的存储属性值</strong></p>
<ul>
<li>从顶部初始化器往下，链中的每一个指定初始化器<strong>都有机会进一步定制</strong>实例</li>
<li>初始化器现在能够使用<code>self</code>（访问、修改它的属性、调用它的实例方法等）</li>
<li>最终，链中任何便捷初始化器都有机会定制实例以及使用<code>self</code></li>
</ul>
<h3 data-id="heading-55">3.2 安全检查</h3>
<ul>
<li><code>指定初始化器</code><strong>必须保证</strong>在调用父类初始化器之前, 其所在类定义的<code>所有存储属性</code>都要初始化完成</li>
<li><code>指定初始化器</code>必须先调用父类初始化器,然后才能为继承的属性设置新值</li>
<li><code>便捷初始化器</code>必须先调用同类中的其他初始化器,然后再为任意属性设置新值</li>
<li><code>初始化器</code>在第一阶段初始化完成之前,不能调用任何实例方法，不能读取任何实例属性的值，也不能引用<code>self</code></li>
<li>直到第一阶段结束，实例才算完全合法</li>
</ul>
<h3 data-id="heading-56">3.3 重写</h3>
<ul>
<li>
<ol>
<li>当重写父类的<code>指定初始化器</code>时，必须加上<code>override</code>（即使子类的实现的<code>便捷初始化器</code>）</li>
</ol>
</li>
<li>
<ol start="2">
<li><code>指定初始化器</code>只<code>能纵向调用</code>，可以被子类调用</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)

        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> score: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: age)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)

        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> score: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">score</span>: <span class="hljs-type">Int</span>) {

        <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> score
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: age)
    }

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: age, score: <span class="hljs-number">0</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果子类写了一个匹配父类<code>便捷初始化器</code>的初始化器，不用加<code>override</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> score: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">score</span>: <span class="hljs-type">Int</span>) {

        <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> score
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: age)
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>, score: <span class="hljs-number">0</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>因为父类的便捷初始化器永远不会通过子类直接调用<br>
因此，严格来说，<strong>子类无法重写父类的<code>便捷初始化器</code></strong></p>
</li>
<li>
<ol start="4">
<li><code>便捷初始化器</code>只能<strong>横向调用</strong>，不能被子类调用<br>
子类没有权利更改父类的<code>便捷初始化器</code>，所以不能叫重写</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> score: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">score</span>: <span class="hljs-type">Int</span>) {

        <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> score
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: age)
    }

    <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-57">4. 自动继承</h2>
<ul>
<li>
<ol>
<li>如果子类没有自定义任何指定初始化器，它会自动继承父类所有的指定初始化器</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(age: <span class="hljs-number">20</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(name: <span class="hljs-string">"ray"</span>)
s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(age: <span class="hljs-number">20</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>如果子类提供了父类所有<code>指定初始化器</code>的实现（要不通过上一种方式继承，要不重新）</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">sex</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">20</span>)
    }
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(age: <span class="hljs-number">30</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">sex</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

    <span class="hljs-keyword">init</span>(<span class="hljs-params">num</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(num: <span class="hljs-number">200</span>)
    }
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(age: <span class="hljs-number">30</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果子类自定义了<code>指定初始化器</code>，那么父类的<code>指定初始化器</code>便不会被继承<br>
子类自动继承所有的父类<code>便捷初始化器</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3f9d8da9ce41477ea3d937b0ad450f4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w643" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="4">
<li>就算子类添加了更多的<code>便捷初始化器</code>，这些规则仍然适用</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">sex</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">isBoy</span>: <span class="hljs-type">Bool</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">20</span>)
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">num</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">20</span>)
    }
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(age: <span class="hljs-number">30</span>)
s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(sex: <span class="hljs-number">24</span>)
s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(isBoy: <span class="hljs-literal">true</span>)
s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(num: <span class="hljs-number">6</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li>子类以<code>便捷初始化器</code>的形式重新父类的<code>指定初始化器</code>，也可以作为满足第二条规则的一部分</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">sex</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">sex</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">20</span>)
    }
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(age: <span class="hljs-number">30</span>)
s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(sex: <span class="hljs-number">24</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-58">5. required</h2>
<ul>
<li>
<ol>
<li>用<code>required</code>修饰<code>指定初始化器</code>，表明其<strong>所有子类</strong>都<code>必须实现</code>该初始化器（通过继承或者重写实现）</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }
    
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    
    
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(age: <span class="hljs-number">30</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>如果子类重写了<code>required</code>初始化器，也必须加上<code>required</code>，不用加<code>override</code></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }
    
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    
    <span class="hljs-keyword">init</span>(<span class="hljs-params">num</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>)
    }
    
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>()
    }
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(num: <span class="hljs-number">30</span>)
s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-59">6. 属性观察器</h2>
<ul>
<li>
<ol>
<li>父类的属性在它自己的初始化器中赋值不会触发<code>属性观察器</code><br>
但在子类的初始化器中赋值会触发<code>属性观察器</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">willSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"willSet"</span>, newValue)
        }

        <span class="hljs-keyword">didSet</span> {
            <span class="hljs-built_in">print</span>(<span class="hljs-string">"didSet"</span>, oldValue, age)
        }
    }

    <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>()

        age <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
    }
}

<span class="hljs-keyword">var</span> s <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-60">7. 可失败初始化器</h2>
<ul>
<li>
<ol>
<li><code>类</code>、<code>结构体</code>、<code>枚举</code>都可以使用<code>init?</code>定义可失败初始化器</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>

    <span class="hljs-keyword">init?</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
        <span class="hljs-keyword">if</span> name.isEmpty {
            <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span>
        }

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    }
}

<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>(name: <span class="hljs-string">"Jack"</span>)
<span class="hljs-built_in">print</span>(p) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>下面这几个也是使用了可失败初始化器</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>(<span class="hljs-string">"123"</span>)

<span class="hljs-keyword">enum</span> <span class="hljs-title class_">Answer</span>: <span class="hljs-title class_">Int</span> {
    <span class="hljs-keyword">case</span> wrong, right
}

<span class="hljs-keyword">var</span> an <span class="hljs-operator">=</span> <span class="hljs-type">Answer</span>(rawValue: <span class="hljs-number">1</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9ca5a14875fb4bda8ae27f64a6a4d04d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w539" loading="lazy" class="medium-zoom-image"></p>
</li>
<li>
<ol start="2">
<li>不允许同时定义<code>参数标签</code>、<code>参数个数</code>、<code>参数类型相同</code>的<code>可失败初始化器</code>和<code>非可失败初始化器</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8725835306874ef2a15e8ec405af5742~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>可以用<code>init!</code>定义隐式解包的<code>可失败初始化器</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>

    <span class="hljs-keyword">init!</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
        <span class="hljs-keyword">if</span> name.isEmpty {
            <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span>
        }

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    }
}

<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>(name: <span class="hljs-string">"Jack"</span>)
<span class="hljs-built_in">print</span>(p) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li><code>可失败初始化器</code>可以调用<code>非可失败初始化器</code><br>
<code>非可失败初始化器</code>调用<code>可失败初始化器</code>需要进行<code>解包</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init?</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>()

        <span class="hljs-keyword">if</span> name.isEmpty {
            <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span>
        }

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    }

    <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> <span class="hljs-string">""</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>

    <span class="hljs-keyword">init?</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {

        <span class="hljs-keyword">if</span> name.isEmpty {
            <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span>
        }

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-comment">// 强制解包有风险</span>
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(name: <span class="hljs-string">""</span>)<span class="hljs-operator">!</span>

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> <span class="hljs-string">""</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li>如果初始化器调用一个<code>可失败初始化器</code>导致<code>初始化失败</code>，那么整个初始化过程都失败，并且之后的代码都停止执行</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>

    <span class="hljs-keyword">init?</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {

        <span class="hljs-keyword">if</span> name.isEmpty {
            <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span>
        }

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    }

    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init?</span>() {
        <span class="hljs-comment">// 如果这一步返回为nil，那么后面的代码就不会继续执行了</span>
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(name: <span class="hljs-string">""</span>)<span class="hljs-operator">!</span>

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> <span class="hljs-string">""</span>
    }
}

<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-built_in">print</span>(p) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="6">
<li>可以用一个<code>非可失败初始化器</code>重写一个<code>可失败初始化器</code>，但反过来是不行的</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>

    <span class="hljs-keyword">init?</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {

        <span class="hljs-keyword">if</span> name.isEmpty {
            <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span>
        }

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(name: name)<span class="hljs-operator">!</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bd34f75d2bb946c9844fe54070a41aff~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w643" loading="lazy" class="medium-zoom-image"></p>
</li>
</ul>
<h2 data-id="heading-61">7. 反初始化器（deinit）</h2>
<ul>
<li>
<ol>
<li><code>deinit</code>叫做反初始化器，类似于C++的<code>析构函数</code>，OC中的<code>dealloc方法</code></li>
</ol>
</li>
<li>
<ol start="2">
<li>当类的实例对象被释放内存时，就会调用实例对象的<code>deinit</code>方法</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    }

    <span class="hljs-keyword">deinit</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person对象销毁了"</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>父类的<code>deinit</code>能被子类继承</li>
</ol>
</li>
<li>
<ol start="4">
<li>子类的<code>deinit</code>实现执行完毕后会调用父类的<code>deinit</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span> 
    <span class="hljs-keyword">init</span>(<span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    } 
    <span class="hljs-keyword">deinit</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person对象销毁了"</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> { 
    <span class="hljs-keyword">deinit</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Student对象销毁了"</span>)
    }
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-keyword">let</span> stu <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(name: <span class="hljs-string">"Jack"</span>)
}

test()

<span class="hljs-comment">// 打印</span>
<span class="hljs-comment">// Student对象销毁了</span>
<span class="hljs-comment">// Person对象销毁了 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li><code>deinit</code>不接受任何参数，不能写小括号，不能自行调用</li>
</ol>
</li>
</ul>
<h1 data-id="heading-62">十一、可选链（Optional Chaining）</h1>
<p>看下面的示例代码:</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">""</span>
    <span class="hljs-keyword">var</span> dog: <span class="hljs-type">Dog</span> <span class="hljs-operator">=</span> <span class="hljs-type">Dog</span>()
    <span class="hljs-keyword">var</span> car: <span class="hljs-type">Car</span>? <span class="hljs-operator">=</span> <span class="hljs-type">Car</span>()
    
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">age</span>() -&gt; <span class="hljs-type">Int</span> { <span class="hljs-number">18</span> }
    
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person eat"</span>)
    }
    
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { index }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol>
<li>如果可选项为<code>nil</code>，调用方法、下标、属性失败，结果为<code>nil</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> person: <span class="hljs-type">Person</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.age()
<span class="hljs-keyword">var</span> name <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.name
<span class="hljs-keyword">var</span> index <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>[<span class="hljs-number">6</span>]

<span class="hljs-built_in">print</span>(age, name, index) <span class="hljs-comment">// nil, nil, nil </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 如果person为nil，都不会调用getName</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">getName</span>() -&gt; <span class="hljs-type">String</span> { <span class="hljs-string">"jack"</span> }

<span class="hljs-keyword">var</span> person: <span class="hljs-type">Person</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
person<span class="hljs-operator">?</span>.name <span class="hljs-operator">=</span> getName() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>如果可选项不为<code>nil</code>，调用<code>方法</code>、<code>下标</code>、<code>属性</code>成功，结果会被包装成<code>可选项</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> person: <span class="hljs-type">Person</span>? <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.age()
<span class="hljs-keyword">var</span> name <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.name
<span class="hljs-keyword">var</span> index <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>[<span class="hljs-number">6</span>]

<span class="hljs-built_in">print</span>(age, name, index) <span class="hljs-comment">// Optional(18) Optional("") Optional(6) </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果结果<code>本来就是可选项</code>，不会进行再次包装</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-built_in">print</span>(person<span class="hljs-operator">?</span>.car) <span class="hljs-comment">// Optional(test_enum.Car) </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>可以用可选绑定来判断可选项的方法调用是否成功</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> result: ()<span class="hljs-operator">?</span> <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.eat()
<span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> <span class="hljs-keyword">_</span> <span class="hljs-operator">=</span> result {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"调用成功"</span>)
} <span class="hljs-keyword">else</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"调用失败"</span>)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> age <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.age() {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"调用成功"</span>, age)
} <span class="hljs-keyword">else</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"调用失败"</span>)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li>没有设定返回值的方法默认返回的就是<code>元组类型</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b8b75b19c58c4059a2380e609ddb9540~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w521" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="6">
<li>多个?可以连接在一起，组成可选链</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> dog <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.dog
<span class="hljs-keyword">var</span> weight <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.dog.weight
<span class="hljs-keyword">var</span> price <span class="hljs-operator">=</span> person<span class="hljs-operator">?</span>.car<span class="hljs-operator">?</span>.price 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="7">
<li>可选链中不管中间经历多少层，只要有一个节点是可选项的，那么最后的结果就是会被包装成可选项的</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-built_in">print</span>(dog, weight, price) <span class="hljs-comment">// Optional(test_enum.Dog) Optional(0) Optional(0)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="8">
<li>如果链中任何一个节点是<code>nil</code>，那么整个链就会调用失败<br>
看下面示例代码</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num1: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">5</span>
num1<span class="hljs-operator">?</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-built_in">print</span>(num1)

<span class="hljs-keyword">var</span> num2: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
num2<span class="hljs-operator">?</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-built_in">print</span>(num2) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="9">
<li>给变量加上<code>?</code>是为了判断变量是否为<code>nil</code>，如果为<code>nil</code>，那么就不会执行赋值操作了，本质也是可选链</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> dict: [<span class="hljs-type">String</span> : (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>] <span class="hljs-operator">=</span> [
    <span class="hljs-string">"sum"</span> : (<span class="hljs-operator">+</span>),
    <span class="hljs-string">"difference"</span> : (<span class="hljs-operator">-</span>)
]

<span class="hljs-keyword">var</span> value <span class="hljs-operator">=</span> dict[<span class="hljs-string">"sum"</span>]<span class="hljs-operator">?</span>(<span class="hljs-number">10</span>, <span class="hljs-number">20</span>)
<span class="hljs-built_in">print</span>(value) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<p>从字典中通过key来取值，得到的也是可选类型，由于可选链中有一个节点是可选项，那么最后的结果也是可选项，最后的值也是<code>Int?</code></p>
<h1 data-id="heading-63">十二、协议（Protocol）</h1>
<h2 data-id="heading-64">1. 基本概念</h2>
<ul>
<li>
<ol>
<li><code>协议</code>可以用来定义<code>方法</code>、<code>属性</code>、<code>下标</code>的声明<br>
<code>协议</code>可以被<code>结构体</code>、<code>类</code>、<code>枚举</code>遵守</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>()
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> { <span class="hljs-keyword">get</span> <span class="hljs-keyword">set</span> } <span class="hljs-comment">// get和set只是声明</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> { <span class="hljs-keyword">get</span> }
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { <span class="hljs-keyword">get</span> <span class="hljs-keyword">set</span> }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li><code>多个协议</code>之间用逗号隔开</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Test1</span> { }
<span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Test2</span> { }
<span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Test3</span> { }

<span class="hljs-keyword">class</span> <span class="hljs-title class_">TestClass</span>: <span class="hljs-title class_">Test1</span>, <span class="hljs-title class_">Test2</span>, <span class="hljs-title class_">Test3</span> { } 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>协议中定义方法时不能有默认参数值
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f7119b8167f647fe819d6285c3c57f9f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w633" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="4">
<li>默认情况下，协议中定义的内容必须全部都实现</li>
</ol>
</li>
</ul>
<h2 data-id="heading-65">2. 协议中的属性</h2>
<ul>
<li>
<ol>
<li><code>协议</code>中定义属性必须用<code>var</code>关键字</li>
</ol>
</li>
<li>
<ol start="2">
<li>实现<code>协议</code>时的属性权限要不小于<code>协议</code>中定义的<code>属性权限</code></li>
</ol>
<ul>
<li>协议定义<code>get、set</code>，用<code>var</code>存储属性或<code>get、set</code>计算属性去实现</li>
<li>协议定义<code>get</code>，用任何属性都可以实现</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>()
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> { <span class="hljs-keyword">get</span> <span class="hljs-keyword">set</span> }
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> { <span class="hljs-keyword">get</span> }
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { <span class="hljs-keyword">get</span> <span class="hljs-keyword">set</span> }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person1</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">let</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person1 draw"</span>)
    }

    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> { }
        <span class="hljs-keyword">get</span> { index }
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person2</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">get</span> { <span class="hljs-number">0</span> }
        <span class="hljs-keyword">set</span> { }
    }

    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> { <span class="hljs-number">0</span> }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person2 draw"</span>)
    }

    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> { }
        <span class="hljs-keyword">get</span> { index }
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person3</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">get</span> { <span class="hljs-number">0</span> }
        <span class="hljs-keyword">set</span> { }
    }

    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">get</span> { <span class="hljs-number">0</span> }
        <span class="hljs-keyword">set</span> { }
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person3 draw"</span>)
    }

    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">index</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">set</span> { }
        <span class="hljs-keyword">get</span> { index }
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-66">3. static、class</h2>
<ul>
<li>
<ol>
<li>为了保证通用，<code>协议</code>中必须用<code>static</code>定义<code>类型方法</code>、<code>类型属性</code>、<code>类型下标</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>()
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person1</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person1 draw"</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person2</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">class</span> <span class="hljs-title class_">func</span> <span class="hljs-title class_">draw</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Person2 draw"</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-67">4. mutating</h2>
<ul>
<li>
<ol>
<li>只有将<code>协议</code>中的<code>实例方法</code>标记为<code>mutating</code>，才允许<code>结构体</code>、<code>枚举</code>的具体实现修改自身内存</li>
</ol>
</li>
<li>
<ol start="2">
<li><code>类</code>在实现方法时不用加<code>mutating</code>，<code>结构体</code>、<code>枚举</code>才需要加<code>mutating</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>()
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">var</span> width: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>() {
        width <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    }
}

<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">draw</span>() {
        x <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-68">5. init</h2>
<ul>
<li>
<ol>
<li>协议中还可以定义初始化器<code>init</code>，非<code>final</code>类实现时必须加上<code>required</code></li>
</ol>
</li>
<li>
<ol start="2">
<li>目的是为了让所有遵守这个协议的类都拥有初始化器，所以加上<code>required</code>强制子类必须实现，除非是加上<code>final</code>不需要子类的类</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">init</span>(<span class="hljs-params">x</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">y</span>: <span class="hljs-type">Int</span>)
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Point</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">x</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">y</span>: <span class="hljs-type">Int</span>) {

    }
}

<span class="hljs-keyword">final</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Size</span>: <span class="hljs-title class_">Drawable</span> {
    <span class="hljs-keyword">init</span>(<span class="hljs-params">x</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">y</span>: <span class="hljs-type">Int</span>) {

    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>如果从协议实现的初始化器，刚好是重写了父类的指定初始化器，那么这个初始化必须同时加上<code>required、override</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>)
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) { }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span>, <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">override</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>(age: age)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>协议中定义的<code>init?、init!</code>，可以用<code>init、init?、init!</code>去实现</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">init</span>()
    <span class="hljs-keyword">init?</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">init!</span>(<span class="hljs-params">no</span>: <span class="hljs-type">Int</span>)
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person1</span>: <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {

    }

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init?</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {

    }

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init!</span>(<span class="hljs-params">no</span>: <span class="hljs-type">Int</span>) {

    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person2</span>: <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {

    }

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init!</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {

    }

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init?</span>(<span class="hljs-params">no</span>: <span class="hljs-type">Int</span>) {

    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person3</span>: <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {

    }

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {

    }

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">no</span>: <span class="hljs-type">Int</span>) {

    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="5">
<li>协议中定义的<code>init</code>，可以用<code>init、init!</code>去实现</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">init</span>()
    <span class="hljs-keyword">init?</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">init!</span>(<span class="hljs-params">no</span>: <span class="hljs-type">Int</span>)
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person4</span>: <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init!</span>() {

    }

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init?</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {

    }

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init!</span>(<span class="hljs-params">no</span>: <span class="hljs-type">Int</span>) {

    }
}  
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-69">6. 协议的继承</h2>
<p>一个<code>协议</code>可以继承其他协议</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>()
}

<span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Livable</span>: <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">breath</span>()
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Livable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">breath</span>() {

    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {

    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-70">7. 协议组合</h2>
<p>协议组合可以包含一个类类型</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> { }
<span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Livable</span> { }
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }

<span class="hljs-comment">// 接收Person或者其子类的实例</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">fn0</span>(<span class="hljs-params">obj</span>: <span class="hljs-type">Person</span>) { }

<span class="hljs-comment">// 接收遵守Livable协议的实例</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">fn1</span>(<span class="hljs-params">obj</span>: <span class="hljs-type">Livable</span>) { }

<span class="hljs-comment">// 接收同时遵守Livable、Runnable协议的实例</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">fn2</span>(<span class="hljs-params">obj</span>: <span class="hljs-type">Livable</span> &amp; <span class="hljs-type">Runnable</span>) { }

<span class="hljs-comment">// 接收同时遵守Livable、Runnable协议，并且是Person或者其子类的实例</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">fn3</span>(<span class="hljs-params">obj</span>: <span class="hljs-type">Person</span> &amp; <span class="hljs-type">Livable</span> &amp; <span class="hljs-type">Runnable</span>) { }

<span class="hljs-keyword">typealias</span> <span class="hljs-type">RealPerson</span> <span class="hljs-operator">=</span> <span class="hljs-type">Person</span> &amp; <span class="hljs-type">Livable</span> &amp; <span class="hljs-type">Runnable</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">fn4</span>(<span class="hljs-params">obj</span>: <span class="hljs-type">RealPerson</span>) { } 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-71">8. CaseIterable</h2>
<p>让枚举遵守<code>CaseIterable</code>协议，可以实现遍历枚举值</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Season</span>: <span class="hljs-title class_">CaseIterable</span> {
    <span class="hljs-keyword">case</span> spring, summer, autumn, winter
}

<span class="hljs-keyword">let</span> seasons <span class="hljs-operator">=</span> <span class="hljs-type">Season</span>.allCases
<span class="hljs-built_in">print</span>(seasons.count)

<span class="hljs-keyword">for</span> season <span class="hljs-keyword">in</span> seasons {
    <span class="hljs-built_in">print</span>(season)
} <span class="hljs-comment">// spring, summer, autumn, winter </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-72">9.CustomStringConvertible</h2>
<ul>
<li>
<ol>
<li>遵守<code>CustomStringConvertible、CustomDebugStringConvertible</code>协议，都可以自定义实例的打印字符串</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">CustomStringConvertible</span>, <span class="hljs-title class_">CustomDebugStringConvertible</span> {
    <span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> description: <span class="hljs-type">String</span> { <span class="hljs-string">"person_(age)"</span> }
    <span class="hljs-keyword">var</span> debugDescription: <span class="hljs-type">String</span> { <span class="hljs-string">"debug_person_(age)"</span> }
}

<span class="hljs-keyword">var</span> person <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-built_in">print</span>(person) <span class="hljs-comment">// person_0</span>
<span class="hljs-built_in">debugPrint</span>(person) <span class="hljs-comment">// debug_person_0 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li><code>print</code>调用的是<code>CustomStringConvertible</code>协议的<code>description</code></li>
</ol>
</li>
<li>
<ol start="3">
<li><code>debugPrint、po</code>调用的是<code>CustomDebugStringConvertible</code>协议的<code>debugDescription</code></li>
</ol>
</li>
</ul>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/acc8277e7aa14a60a23a27f52a4b11fc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w529" loading="lazy" class="medium-zoom-image"></p>
<h1 data-id="heading-73">十三、Any、AnyObject</h1>
<ul>
<li>
<ol>
<li>Swift提供了两种特殊的类型<code>Any、AnyObject</code></li>
</ol>
</li>
<li>
<ol start="2">
<li><code>Any</code>可以代表任意类型（<code>枚举</code>、<code>结构体</code>、<code>类</code>，也包括<code>函数类型</code>）</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> stu: <span class="hljs-keyword">Any</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
stu <span class="hljs-operator">=</span> <span class="hljs-string">"Jack"</span>
stu <span class="hljs-operator">=</span> <span class="hljs-type">Size</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> data <span class="hljs-operator">=</span> [<span class="hljs-keyword">Any</span>]()
data.append(<span class="hljs-number">1</span>)
data.append(<span class="hljs-number">3.14</span>)
data.append(<span class="hljs-type">Size</span>())
data.append(<span class="hljs-string">"Jack"</span>)
data.append({ <span class="hljs-number">10</span> }) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li><code>AnyObject</code>可以代表任意类类型</li>
</ol>
</li>
<li>
<ol start="4">
<li>在协议后面写上<code>: AnyObject</code>，代表只有类能遵守这个协议
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d3809ed07d17450d911eec4ad2731c0f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="5">
<li>在协议后面写上<code>: class</code>，也代表只有类能遵守这个协议
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3c89cc874464f83a7bdb5c65a31b83c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-74">1. is、as</h2>
<ul>
<li><code>is</code>用来判断是否为某种类型
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>()
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span>, <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Student run"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">study</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Student study"</span>)
    }
}

<span class="hljs-keyword">var</span> stu: <span class="hljs-keyword">Any</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-built_in">print</span>(stu <span class="hljs-keyword">is</span> <span class="hljs-type">Int</span>) <span class="hljs-comment">// true</span>

stu <span class="hljs-operator">=</span> <span class="hljs-string">"Jack"</span>
<span class="hljs-built_in">print</span>(stu <span class="hljs-keyword">is</span> <span class="hljs-type">String</span>) <span class="hljs-comment">// true</span>

stu <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>()
<span class="hljs-built_in">print</span>(stu <span class="hljs-keyword">is</span> <span class="hljs-type">Person</span>) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(stu <span class="hljs-keyword">is</span> <span class="hljs-type">Student</span>) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(stu <span class="hljs-keyword">is</span> <span class="hljs-type">Runnable</span>) <span class="hljs-comment">// true </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li><code>as</code>用来做强制类型转换(<code>as?</code>、<code>as!</code>、<code>as</code>)</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>()
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span>, <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Student run"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">study</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"Student study"</span>)
    }
}

<span class="hljs-keyword">var</span> stu: <span class="hljs-keyword">Any</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
(stu <span class="hljs-keyword">as?</span> <span class="hljs-type">Student</span>)<span class="hljs-operator">?</span>.study() <span class="hljs-comment">// 没有调用study</span>

stu <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>()
(stu <span class="hljs-keyword">as?</span> <span class="hljs-type">Student</span>)<span class="hljs-operator">?</span>.study() <span class="hljs-comment">// Student study</span>
(stu <span class="hljs-keyword">as!</span> <span class="hljs-type">Student</span>).study() <span class="hljs-comment">// Student study</span>
(stu <span class="hljs-keyword">as?</span> <span class="hljs-type">Runnable</span>)<span class="hljs-operator">?</span>.run() <span class="hljs-comment">// Student run </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> data <span class="hljs-operator">=</span> [<span class="hljs-keyword">Any</span>]()
data.append(<span class="hljs-type">Int</span>(<span class="hljs-string">"123"</span>) <span class="hljs-keyword">as</span> <span class="hljs-keyword">Any</span>)

<span class="hljs-keyword">var</span> d <span class="hljs-operator">=</span> <span class="hljs-number">10</span> <span class="hljs-keyword">as</span> <span class="hljs-type">Double</span>
<span class="hljs-built_in">print</span>(d) <span class="hljs-comment">// 10.0 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h1 data-id="heading-75">十四、 元类型</h1>
<h2 data-id="heading-76">1. X.self</h2>
<ul>
<li>
<ol>
<li><code>X.self</code>是一个<code>元类型的指针</code>，<code>metadata</code>存放着<code>类型相关信息</code></li>
</ol>
</li>
<li>
<ol start="2">
<li><code>X.self</code>属于<code>X.Type</code>类型</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> { }

<span class="hljs-keyword">var</span> perType: <span class="hljs-type">Person</span>.<span class="hljs-keyword">Type</span> <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>.<span class="hljs-keyword">self</span>
<span class="hljs-keyword">var</span> stuType: <span class="hljs-type">Student</span>.<span class="hljs-keyword">Type</span> <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>.<span class="hljs-keyword">self</span>
perType <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>.<span class="hljs-keyword">self</span>

<span class="hljs-keyword">var</span> anyType: <span class="hljs-type">AnyObject</span>.<span class="hljs-keyword">Type</span> <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>.<span class="hljs-keyword">self</span>
anyType <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>.<span class="hljs-keyword">self</span>

<span class="hljs-keyword">var</span> per <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
perType <span class="hljs-operator">=</span> <span class="hljs-built_in">type</span>(of: per)
<span class="hljs-built_in">print</span>(<span class="hljs-type">Person</span>.<span class="hljs-keyword">self</span> <span class="hljs-operator">==</span> <span class="hljs-built_in">type</span>(of: per)) <span class="hljs-comment">// true </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li><code>AnyClass</code>的本质就是<code>AnyObject.Type</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c534ec2adb474b47bc5ab8ab7221b02a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w492" loading="lazy" class="medium-zoom-image"></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> anyType2: <span class="hljs-type">AnyClass</span> <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>.<span class="hljs-keyword">self</span>
anyType2 <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>.<span class="hljs-keyword">self</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-77">2. 元类型的应用</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {
        
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Cat</span>: <span class="hljs-title class_">Animal</span> {
    
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span>: <span class="hljs-title class_">Animal</span> {
    
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Pig</span>: <span class="hljs-title class_">Animal</span> {
    
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">create</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">clses</span>: [<span class="hljs-type">Animal</span>.<span class="hljs-keyword">Type</span>]) -&gt; [<span class="hljs-type">Animal</span>] {
    <span class="hljs-keyword">var</span> arr <span class="hljs-operator">=</span> [<span class="hljs-type">Animal</span>]()
    <span class="hljs-keyword">for</span> cls <span class="hljs-keyword">in</span> clses {
        arr.append(cls.<span class="hljs-keyword">init</span>())
    }
    
    <span class="hljs-keyword">return</span> arr
}

<span class="hljs-built_in">print</span>(create([<span class="hljs-type">Cat</span>.<span class="hljs-keyword">self</span>, <span class="hljs-type">Dog</span>.<span class="hljs-keyword">self</span>, <span class="hljs-type">Pig</span>.<span class="hljs-keyword">self</span>]))

<span class="hljs-comment">// a1、a2、a3、a4的写法等价</span>
<span class="hljs-keyword">var</span> a1 <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>()
<span class="hljs-keyword">var</span> t <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>.<span class="hljs-keyword">self</span>
<span class="hljs-keyword">var</span> a2 <span class="hljs-operator">=</span> t.<span class="hljs-keyword">init</span>()
<span class="hljs-keyword">var</span> a3 <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>.<span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>()
<span class="hljs-keyword">var</span> a4 <span class="hljs-operator">=</span> <span class="hljs-type">Animal</span>.<span class="hljs-keyword">self</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-78">3.Self</h2>
<ul>
<li>
<ol>
<li><code>Self</code>代表当前类型</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> count <span class="hljs-operator">=</span> <span class="hljs-number">2</span>

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-keyword">self</span>.age)
        <span class="hljs-built_in">print</span>(<span class="hljs-keyword">Self</span>.count)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li><code>Self</code>一般用作返回值类型，限定返回值和方法调用者必须是同一类型（也可以作为参数类型）</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() -&gt; <span class="hljs-keyword">Self</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Runnable</span> {

    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {

    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() -&gt; <span class="hljs-keyword">Self</span> {
        <span class="hljs-built_in">type</span>(of: <span class="hljs-keyword">self</span>).<span class="hljs-keyword">init</span>()
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {

}

<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-built_in">print</span>(p.test()) <span class="hljs-comment">// test_enum.Person</span>

<span class="hljs-keyword">var</span> stu <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>()
<span class="hljs-built_in">print</span>(stu.test()) <span class="hljs-comment">// test_enum.Student </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-79">4. 元类型的本质</h2>
<p>我们可以通过反汇编来查看元类型的实现是怎样的</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-keyword">var</span> pType <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>.<span class="hljs-keyword">self</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>我们发现最后存储到全局变量pType中的地址值就是一开始调用的地址
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8a38e68565b04a649793fd49e4962bc8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1031" loading="lazy" class="medium-zoom-image">
再通过打印，我们发现pType的值就是Person实例对象的前8个字节的地址值，也就是类信息
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f81fff9375c949a18a6e71f733e06da5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1031" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d84b816435c0422a9ea5bfde95b40861~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1032" loading="lazy" class="medium-zoom-image">
我们再来看下面的示例代码</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-keyword">var</span> pType <span class="hljs-operator">=</span> <span class="hljs-built_in">type</span>(of: p) 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>通过分析我们可以看到<code>type(of: p)</code>本质不是函数调用，只是将Person实例对象的前8个字节存储到pType中，也证明了元类型的本质就是存储的类信息</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f11a754847b149eab14026ed50e0ff21~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1031" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aa877aa499e7423e86c1e96bd301d291~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1030" loading="lazy" class="medium-zoom-image"></p>
<p>我们还可以用以下方式来获取Swift的隐藏基类<code>_TtCs12_SwiftObject</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> no: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-built_in">print</span>(class_getInstanceSize(<span class="hljs-type">Student</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// 32</span>
<span class="hljs-built_in">print</span>(class_getSuperclass(<span class="hljs-type">Student</span>.<span class="hljs-keyword">self</span>)<span class="hljs-operator">!</span>) <span class="hljs-comment">// Person</span>
<span class="hljs-built_in">print</span>(class_getSuperclass(<span class="hljs-type">Student</span>.<span class="hljs-keyword">self</span>)<span class="hljs-operator">!</span>) <span class="hljs-comment">// _TtCs12_SwiftObject</span>
<span class="hljs-built_in">print</span>(class_getSuperclass(<span class="hljs-type">NSObject</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// nil </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>我们可以查看Swift源码来分析该类型</p>
<p>发现<code>SwiftObject</code>里面也有一个<code>isa指针</code></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b4602a6c2194461caf1a20eefd72056b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w686" loading="lazy" class="medium-zoom-image"></p>
<h1 data-id="heading-80">专题系列文章</h1>
<h3 data-id="heading-81">1.前知识</h3>
<ul>
<li><strong><a href="https://juejin.cn/post/7089043618803122183/" target="_blank" title="https://juejin.cn/post/7089043618803122183/">01-探究iOS底层原理|综述</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7093842449998561316/" target="_blank" title="https://juejin.cn/post/7093842449998561316/">02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7095079758844674056" target="_blank" title="https://juejin.cn/post/7095079758844674056">03-探究iOS底层原理|LLDB</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7115302848270696485/" target="_blank" title="https://juejin.cn/post/7115302848270696485/">04-探究iOS底层原理|ARM64汇编</a></strong></li>
</ul>
<h3 data-id="heading-82">2. 基于OC语言探索iOS底层原理</h3>
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
<h3 data-id="heading-83">3. 基于Swift语言探索iOS底层原理</h3>
<p>关于<code>函数</code>、<code>枚举</code>、<code>可选项</code>、<code>结构体</code>、<code>类</code>、<code>闭包</code>、<code>属性</code>、<code>方法</code>、<code>swift多态原理</code>、<code>String</code>、<code>Array</code>、<code>Dictionary</code>、<code>引用计数</code>、<code>MetaData</code>等Swift基本语法和相关的底层原理文章有如下几篇:</p>
<ul>
<li><a href="https://juejin.cn/post/7119020967430455327" target="_blank" title="https://juejin.cn/post/7119020967430455327">Swift5核心语法1-基础语法</a></li>
<li><a href="https://juejin.cn/post/7119510159109390343" target="_blank" title="https://juejin.cn/post/7119510159109390343">Swift5核心语法2-面向对象语法1</a></li>
<li><a href="https://juejin.cn/post/7119513630550261774" target="_blank" title="https://juejin.cn/post/7119513630550261774">Swift5核心语法2-面向对象语法2</a></li>
<li><a href="https://juejin.cn/post/7119714488181325860" target="_blank" title="https://juejin.cn/post/7119714488181325860">Swift5常用核心语法3-其它常用语法</a></li>
<li><a href="https://juejin.cn/post/7119722433589805064" target="_blank" title="https://juejin.cn/post/7119722433589805064">Swift5应用实践常用技术点</a></li>
</ul>
<h1 data-id="heading-84">其它底层原理专题</h1>
<h3 data-id="heading-85">1.底层原理相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7018755998823219213" target="_blank" title="https://juejin.cn/post/7018755998823219213">01-计算机原理|计算机图形渲染原理这篇文章</a></li>
<li><a href="https://juejin.cn/post/7019117942377807908" target="_blank" title="https://juejin.cn/post/7019117942377807908">02-计算机原理|移动终端屏幕成像与卡顿&nbsp;</a></li>
</ul>
<h3 data-id="heading-86">2.iOS相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7019193784806146079" target="_blank" title="https://juejin.cn/post/7019193784806146079">01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019200157119938590" target="_blank" title="https://juejin.cn/post/7019200157119938590">02-iOS底层原理|iOS动画渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019497906650497061/" target="_blank" title="https://juejin.cn/post/7019497906650497061/">03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理</a></li>
<li><a href="https://juejin.cn/post/7020613901033144351" target="_blank" title="https://juejin.cn/post/7020613901033144351">04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案</a></li>
</ul>
<h3 data-id="heading-87">3.webApp相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021035020445810718/" target="_blank" title="https://juejin.cn/post/7021035020445810718/">01-Web和类RN大前端的渲染原理</a></li>
</ul>
<h3 data-id="heading-88">4.跨平台开发方案相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021057396147486750/" target="_blank" title="https://juejin.cn/post/7021057396147486750/">01-Flutter页面渲染原理</a></li>
</ul>
<h3 data-id="heading-89">5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较</h3>
<ul>
<li><a href="https://juejin.cn/post/7021071990723182606/" target="_blank" title="https://juejin.cn/post/7021071990723182606/">01-Native、WebApp、跨平台开发三种方案性能比较</a></li>
</ul>
<h3 data-id="heading-90">6.Android、HarmonyOS页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021840737431978020/" target="_blank" title="https://juejin.cn/post/7021840737431978020/">01-Android页面渲染原理</a></li>
<li><a href="#" title="#">02-HarmonyOS页面渲染原理</a> (<code>待输出</code>)</li>
</ul>
<h3 data-id="heading-91">7.小程序页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021414123346853919" target="_blank" title="https://juejin.cn/post/7021414123346853919">01-小程序框架渲染原理</a></li>
</ul></div></div>