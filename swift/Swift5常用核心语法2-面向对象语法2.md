# Swift5常用核心语法2-面向对象语法2

<h1 data-id="heading-0">一、概述</h1>
<p>最近刚好有空,趁这段时间,复习一下<code>Swift5</code>核心语法,进行知识储备,以供日后温习 和 进一步探索<code>Swift</code>语言的底层原理做铺垫。</p>
<p>本文继前两篇文章:</p>
<ul>
<li><a href="https://juejin.cn/post/7119020967430455327" title="https://juejin.cn/post/7119020967430455327" target="_blank">Swift5核心语法1-基础语法</a></li>
<li><a href="https://juejin.cn/post/7119510159109390343" target="_blank" title="https://juejin.cn/post/7119510159109390343">Swift5常用核心语法2-面向对象语法1</a>之后,继续复习<code>面向对象语法</code></li>
</ul>
<h1 data-id="heading-1">二、访问控制（Access Control）</h1>
<h2 data-id="heading-2">1. 基本概念</h2>
<p>在访问权限控制这块，Swift提供了5个不同的访问级别（以下是从高到低排列，实体指被访问级别修饰的内容）</p>
<ul>
<li><code>open</code>: 允许在定义实体的模块、其他模块中访问，允许其他模块进行继承、重写（open只能用在类、类成员上）</li>
<li><code>public</code>: 允许在定义实体的模块、其他模块中访问，不允许其他模块进行继承、重写</li>
<li><code>internal</code>: 只允许在定义实体的模块中访问，不允许在其他模块中访问</li>
<li><code>fileprivate</code>: 只允许在定义实体的源文件中访问</li>
<li><code>private</code>： 只允许在定义实体的封闭声明中访问</li>
</ul>
<p>绝大部分实体默认都是<code>internal</code>级别</p>
<h2 data-id="heading-3">2. 访问级别的使用准则</h2>
<ul>
<li>
<ol>
<li>一个实体不可以被更低访问级别的实体定义</li>
</ol>
</li>
<li>
<ol start="2">
<li>变量\常量类型 ≥ 变量\常量</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">internal</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {} <span class="hljs-comment">// 变量类型</span>
<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">var</span> person: <span class="hljs-type">Person</span> <span class="hljs-comment">// 变量 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eea1ff7e061d4999aa10e06cc88f009d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w635" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>3. 参数类型、返回值类型 ≥ 函数</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 参数类型：Int、Double</span>
<span class="hljs-comment">// 函数：func test</span>
<span class="hljs-keyword">internal</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Double</span> {
    <span class="hljs-keyword">return</span> <span class="hljs-type">Double</span>(num)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li>父类 ≥ 子类</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/253c5018731a4da5b5efb8cd7228dd78~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w645" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>5. 父协议 ≥ 子协议</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Sportable</span> {}
<span class="hljs-keyword">internal</span> <span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnalbe</span>: <span class="hljs-title class_">Sportable</span> {} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8ed33acfc6054650bacb1de9a9c813e1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w646" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>6. 原类型 ≥ typealias</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {} <span class="hljs-comment">// 原类型</span>
<span class="hljs-keyword">private</span> <span class="hljs-keyword">typealias</span> <span class="hljs-type">MyPerson</span> <span class="hljs-operator">=</span> <span class="hljs-type">Person</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="7">
<li>原始值类型\关联值类型 ≥ 枚举类型</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">MyInt</span> <span class="hljs-operator">=</span> <span class="hljs-type">Int</span>
<span class="hljs-keyword">typealias</span> <span class="hljs-type">MyString</span> <span class="hljs-operator">=</span> <span class="hljs-type">String</span>

<span class="hljs-keyword">enum</span> <span class="hljs-title class_">Score</span> {
    <span class="hljs-keyword">case</span> point(<span class="hljs-type">MyInt</span>)
    <span class="hljs-keyword">case</span> grade(<span class="hljs-type">MyString</span>)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d2da62d6a3d74091819315c6949b036b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w640" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>8. 定义类型A时用到的其他类型 ≥ 类型A</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">MyString</span> <span class="hljs-operator">=</span> <span class="hljs-type">String</span>

<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Dog</span> {}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">MyString</span> <span class="hljs-operator">=</span> <span class="hljs-string">""</span>
    <span class="hljs-keyword">var</span> dog: <span class="hljs-type">Dog</span>?
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/09023b2368544bdb81e245da6d1e9091~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w645" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-4">3. 元组类型</h2>
<ul>
<li>元组类型的访问级别是所有成员类型最低的那个</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">internal</span> <span class="hljs-keyword">struct</span> <span class="hljs-title class_">Dog</span> { }
<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }

<span class="hljs-comment">// (Dog, Person)中更低的访问级别是fileprivate，所以元组的访问级别就是fileprivate</span>
<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">var</span> datal: (<span class="hljs-type">Dog</span>, <span class="hljs-type">Person</span>)
<span class="hljs-keyword">private</span> <span class="hljs-keyword">var</span> data2: (<span class="hljs-type">Dog</span>, <span class="hljs-type">Person</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-5">4. 泛型类型</h2>
<ul>
<li>泛型类型的访问级别是类型的访问级别以及所有泛型类型参数的访问级别中最低的那个</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">internal</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span> {}
<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span> {}
<span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>&lt;<span class="hljs-title class_">T1</span>, <span class="hljs-title class_">T2</span>&gt; {}

<span class="hljs-comment">// Person&lt;Car, Dog&gt;中比较的是Person、Car、Dog三个的访问级别最低的那个，也就是fileprivate，fileprivate就是泛型类型的访问级别</span>
<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>&lt;<span class="hljs-type">Car</span>, <span class="hljs-type">Dog</span>&gt;() 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-6">5. 成员、嵌套类型</h2>
<ul>
<li>
<ol>
<li>类型的访问级别会影响成员（<code>属性</code>、<code>方法</code>、<code>初始化器</code>、<code>下标</code>），嵌套类型的默认访问级别</li>
</ol>
</li>
<li>
<ol start="2">
<li>一般情况下，类型为<code>private</code>或<code>fileprivate</code>，那么成员\嵌套类型默认也是<code>private</code>或<code>fileprivate</code></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">FilePrivateClass</span> { <span class="hljs-comment">// fileprivate</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">f1</span>() {} <span class="hljs-comment">// fileprivate</span>
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">f2</span>() {} <span class="hljs-comment">// private</span>
}

<span class="hljs-keyword">private</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">PrivateClass</span> { <span class="hljs-comment">// private</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">f</span>() {} <span class="hljs-comment">// private</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li>一般情况下，类型为<code>internal</code>或<code>public</code>，那么成员/嵌套类型默认是<code>internal</code></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">PublicClass</span> { <span class="hljs-comment">// public</span>
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-number">0</span> <span class="hljs-comment">// public</span>
    <span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> <span class="hljs-number">0</span> <span class="hljs-comment">// internal</span>
    <span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">f1</span>() {} <span class="hljs-comment">// fileprivate</span>
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">f2</span>() {} <span class="hljs-comment">// private</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">InternalClass</span> { <span class="hljs-comment">// internal</span>
    <span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-number">0</span> <span class="hljs-comment">// internal</span>
    <span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">f1</span>() {} <span class="hljs-comment">// fileprivate</span>
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">f2</span>() {} <span class="hljs-comment">// private</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><strong>看下面几个示例，编译能否通过？</strong></p>
<p>示例1</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">private</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}
<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Test</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}
    <span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {}
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>结果是第一段代码编译通过，第二段代码编译报错</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d750e03e5ce144fe98c26befa71887b7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image"></p>
<p>第一段代码编译通过，是因为两个全局变量不管是<code>private</code>还是<code>fileprivate</code>，作用域都是当前文件，所以访问级别就相同了</p>
<p>第二段代码的两个属性的作用域局限到类里面了，那访问级别就有差异了</p>
<p>示例2</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">private</span> <span class="hljs-keyword">struct</span> <span class="hljs-title class_">Dog</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {}
}

<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">struct</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> dog: <span class="hljs-type">Dog</span> <span class="hljs-operator">=</span> <span class="hljs-type">Dog</span>()
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">walk</span>() {
        dog.run()
        dog.age <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">private</span> <span class="hljs-keyword">struct</span> <span class="hljs-title class_">Dog</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {}
}

<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">struct</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> dog: <span class="hljs-type">Dog</span> <span class="hljs-operator">=</span> <span class="hljs-type">Dog</span>()
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">walk</span>() {
        dog.run()
        dog.age <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>结果是第一段代码编译通过，第二段代码编译报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/763c5459c3f14f1f876a6c67893bea4f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w646" loading="lazy" class="medium-zoom-image"></p>
<p>第一段代码编译通过，是因为两个结构体的访问级别都是该文件内，所以访问级别相同</p>
<p>第二段代码报错是因为Dog里的属性和方法的访问级别是更低的了，虽然两个结构体的访问级别相同，但从Person里调用Dog中的属性和方法是访问不到的</p>
<p><strong>结论：直接在全局作用域下定义的<code>private</code>等于<code>fileprivate</code></strong></p>
<h2 data-id="heading-7">6. 成员的重写</h2>
<p>子类重写成员的访问级别必须 ≥ 子类的访问级别，或者 ≥ 父类被重写成员的访问级别</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">internal</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {}
}

<span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {}
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>父类的成员不能被成员作用域外定义的子类重写
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/73b4fef531b8438b8df637149f2c1833~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w641" loading="lazy" class="medium-zoom-image"></p>
<p>放到同一个作用域下</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
        <span class="hljs-keyword">override</span> <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> {
            <span class="hljs-keyword">set</span> {}
            <span class="hljs-keyword">get</span> { <span class="hljs-number">10</span> }
        }
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-8">7. getter、setter</h2>
<ul>
<li>
<ol>
<li><code>getter、setter</code>默认自动接收它们所属环境的访问级别</li>
</ol>
</li>
<li>
<ol start="2">
<li>可以给<code>setter</code>单独设置一个比<code>getter</code>更低的访问级别，用以限制写的权限</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">fileprivate(set)</span> <span class="hljs-keyword">public</span> <span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
num <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-built_in">print</span>(num) 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bf43c0b5920a4302902ad7e5ff56a35b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w645" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-9">8. 初始化器</h2>
<ul>
<li>
<ol>
<li>如果一个<code>public类</code>想在另一个模块调用编译生成的默认无参初始化器，必须显式提供<code>public</code>的无参初始化器，因为<code>public类</code>的默认初始化器是<code>internal</code>级别</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-comment">// 默认生成的，因为是internal，所以外部无法调用到该初始化器</span>
<span class="hljs-comment">//    internal init() {</span>
<span class="hljs-comment">//</span>
<span class="hljs-comment">//    }</span>
}

变成这样

<span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-comment">// 自己手动添加指定初始化器，并用public修饰，外部才能访问的到</span>
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">init</span>() {

    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li><code>required</code>初始化器 ≥ 它的默认访问级别</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">internal</span> <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {}
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>当类是<code>public</code>的时候，它的默认初始化器就是<code>internal</code>级别的，所以不会报错</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">internal</span> <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {}
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/47ab245d23184e2a9c20f566f14c6555~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w639" loading="lazy" class="medium-zoom-image"></p>
</li>
<li>
<ol start="4">
<li>如果结构体有<code>private\fileprivate</code>的存储实例属性，那么它的成员初始化器也是<code>private\fileprivate</code>，否则默认就是<code>internal</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ea49c229a71148738b54d4194a77083a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w641" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="5">
<li>结构体里有一个属性设置为private，带有其他属性的初始化器也没有了
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9bbbbab59a884181bfb5b45020035d68~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-10">9. 枚举类型的case</h2>
<ul>
<li>
<ol>
<li>不能给<code>enum</code>的每个case单独设置访问级别
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/31bbc797440645668025dc4f6101c2c4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w641" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="2">
<li>每个case自动接收<code>enum</code>的访问级别</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">enum</span> <span class="hljs-title class_">Season</span> {
    <span class="hljs-keyword">case</span> spring <span class="hljs-comment">// fileprivate</span>
    <span class="hljs-keyword">case</span> summer <span class="hljs-comment">// fileprivate</span>
    <span class="hljs-keyword">case</span> autumn <span class="hljs-comment">// fileprivate</span>
    <span class="hljs-keyword">case</span> winter <span class="hljs-comment">// fileprivate</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li><code>public enum</code>定义的case也是<code>public</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">enum</span> <span class="hljs-title class_">Season</span> {
    <span class="hljs-keyword">case</span> spring <span class="hljs-comment">// public</span>
    <span class="hljs-keyword">case</span> summer <span class="hljs-comment">// public</span>
    <span class="hljs-keyword">case</span> autumn <span class="hljs-comment">// public</span>
    <span class="hljs-keyword">case</span> winter <span class="hljs-comment">// public</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-11">10. 协议</h2>
<ul>
<li>
<ol>
<li>协议中定义的要求自动接收协议的访问级别，不能单独设置访问级别
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/17ae162147ba4460be6e0bbb2e49f20a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w637" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="2">
<li><code>public</code>协议定义的要求也是<code>public</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>()
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>协议实现的访问级别必须 ≥ 类型的访问级别，或者 ≥ 协议的访问级别
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/12a3840994aa443ea9f81a71b2025068~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w641" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/16d1b6478fd244b0b6e8cf7f54e91d8e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w640" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-12">11.扩展</h2>
<ul>
<li>
<ol>
<li>如果有显式设置扩展的访问级别，扩展添加的成员自动接收扩展的访问级别</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {

}

<span class="hljs-keyword">private</span> <span class="hljs-keyword">extension</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {} <span class="hljs-comment">// private</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>如果没有显式设置扩展的访问级别，扩展添加的成员的默认访问级别，跟直接在类型中定义的成员一样</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">private</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {

}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {} <span class="hljs-comment">// private</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li>可以单独给扩展添加的成员设置访问级别</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {

}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {} 
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li>不能给用于遵守协议的扩展显式设置扩展的访问级别
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e8c688d9e860454b8417dcc7e6cf2a9d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w645" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="5">
<li>在同一文件中的扩展，可以写成类似多个部分的类型声明</li>
</ol>
</li>
<li>
<ol start="6">
<li>在原本的声明中声明一个私有成员，可以在同一个文件的扩展中访问它</li>
</ol>
</li>
<li>
<ol start="7">
<li>在扩展中声明一个私有成员，可以在同一文件的其他扩展中、原本声明中访问它</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">run0</span>() {}
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat0</span>() {
        run1()
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">run1</span>() {}
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat1</span>() {
        run0()
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat2</span>() {
        run1()
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-13">12. 将方法赋值给var\let</h2>
<ul>
<li>
<ol>
<li>方法也可以像函数那样，赋值给一个<code>let</code>或者<code>var</code></li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v</span> : <span class="hljs-type">Int</span>) { <span class="hljs-built_in">print</span>(<span class="hljs-string">"func run"</span>, age, v)}
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v</span>: <span class="hljs-type">Int</span>) { <span class="hljs-built_in">print</span>(<span class="hljs-string">"static func run"</span>, v)}
}

<span class="hljs-keyword">let</span> fn1 <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>.run
fn1(<span class="hljs-number">10</span>) <span class="hljs-comment">// static func run 10</span>

<span class="hljs-keyword">let</span> fn2: (<span class="hljs-type">Int</span>) -&gt; () <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>.run
fn2(<span class="hljs-number">20</span>) <span class="hljs-comment">// static func run 20</span>

<span class="hljs-keyword">let</span> fn3: (<span class="hljs-type">Person</span>) -&gt; ((<span class="hljs-type">Int</span>) -&gt; ()) <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>.run
fn3(<span class="hljs-type">Person</span>(age: <span class="hljs-number">18</span>))(<span class="hljs-number">30</span>) <span class="hljs-comment">// func run 18 30</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h1 data-id="heading-14">三、扩展（Extension）</h1>
<h2 data-id="heading-15">1. 基本概念</h2>
<ul>
<li>
<ol>
<li>Swift中的扩展，类似于<code>OC</code>中的<code>Category</code></li>
</ol>
</li>
<li>
<ol start="2">
<li>扩展可以为<code>枚举</code>、<code>类</code>、<code>结构体</code>、<code>协议</code>添加新功能；可以添加方法、<code>便捷初始化器</code>、<code>计算属性</code>、<code>下标</code>、<code>嵌套类型</code>、<code>协议</code>等</li>
</ol>
</li>
<li>
<ol start="3">
<li>扩展<code>不能做到</code>以下这几项</li>
</ol>
<ul>
<li>不能覆盖原有的功能</li>
<li>不能添加存储属性，不能向已有的属性添加属性观察器</li>
<li>不能添加父类</li>
<li>不能添加指定初始化器，不能添加反初始化器</li>
<li>....</li>
</ul>
</li>
</ul>
<h2 data-id="heading-16">2. 计算属性、方法、下标、嵌套类型</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Double</span> {
    <span class="hljs-keyword">var</span> km: <span class="hljs-type">Double</span> { <span class="hljs-keyword">self</span> <span class="hljs-operator">*</span> <span class="hljs-number">1_000.0</span> }
    <span class="hljs-keyword">var</span> m: <span class="hljs-type">Double</span> { <span class="hljs-keyword">self</span> }
    <span class="hljs-keyword">var</span> dm: <span class="hljs-type">Double</span> { <span class="hljs-keyword">self</span> <span class="hljs-operator">/</span> <span class="hljs-number">10.0</span> }
    <span class="hljs-keyword">var</span> cm: <span class="hljs-type">Double</span> { <span class="hljs-keyword">self</span> <span class="hljs-operator">/</span> <span class="hljs-number">100.0</span> }
    <span class="hljs-keyword">var</span> mm: <span class="hljs-type">Double</span> { <span class="hljs-keyword">self</span> <span class="hljs-operator">/</span> <span class="hljs-number">1_000.0</span> }
}  
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Array</span> {
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">nullable</span> <span class="hljs-params">idx</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Element</span>? {
        <span class="hljs-keyword">if</span> (startIndex<span class="hljs-operator">..&lt;</span>endIndex).contains(idx) {
            <span class="hljs-keyword">return</span> <span class="hljs-keyword">self</span>[idx]
        }
        <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Int</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">repetitions</span>(<span class="hljs-params">task</span>: () -&gt; <span class="hljs-type">Void</span>) {
        <span class="hljs-keyword">for</span> <span class="hljs-keyword">_</span> <span class="hljs-keyword">in</span> <span class="hljs-number">0</span><span class="hljs-operator">..&lt;</span><span class="hljs-keyword">self</span> { task() }
    }
    
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">square</span>() -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">self</span> <span class="hljs-operator">=</span> <span class="hljs-keyword">self</span> <span class="hljs-operator">*</span> <span class="hljs-keyword">self</span>
        <span class="hljs-keyword">return</span> <span class="hljs-keyword">self</span>
    }
    
    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">Kind</span> { <span class="hljs-keyword">case</span> negative, zero, positive }
    
    <span class="hljs-keyword">var</span> kind: <span class="hljs-type">Kind</span> {
        <span class="hljs-keyword">switch</span> <span class="hljs-keyword">self</span> {
        <span class="hljs-keyword">case</span> <span class="hljs-number">0</span>: <span class="hljs-keyword">return</span> .zero
        <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> x <span class="hljs-keyword">where</span> x <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span>: <span class="hljs-keyword">return</span> .positive
        <span class="hljs-keyword">default</span>: <span class="hljs-keyword">return</span> .negative
        }
    }
    
    <span class="hljs-keyword">subscript</span>(<span class="hljs-params">digitIndex</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">var</span> decimalBase <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
        <span class="hljs-keyword">for</span> <span class="hljs-keyword">_</span> <span class="hljs-keyword">in</span> <span class="hljs-number">0</span><span class="hljs-operator">..&lt;</span>digitIndex { decimalBase <span class="hljs-operator">+=</span> <span class="hljs-number">10</span> }
        <span class="hljs-keyword">return</span> (<span class="hljs-keyword">self</span> <span class="hljs-operator">/</span> decimalBase) <span class="hljs-operator">%</span> <span class="hljs-number">10</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-17">3. 初始化器</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>
    <span class="hljs-keyword">init</span> (<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Equatable</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">==</span> (<span class="hljs-params">left</span>: <span class="hljs-type">Person</span>, <span class="hljs-params">right</span>: <span class="hljs-type">Person</span>) -&gt; <span class="hljs-type">Bool</span> {
        left.age <span class="hljs-operator">==</span> right.age <span class="hljs-operator">&amp;&amp;</span> left.name <span class="hljs-operator">==</span> right.name
    }
    
    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(age: <span class="hljs-number">0</span>, name: <span class="hljs-string">""</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>如果希望自定义初始化器的同时，编译器也能够生成默认初始化器，可以在扩展中编写自定义初始化器
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> y: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">init</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">point</span>: <span class="hljs-type">Point</span>) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(x: point.x, y: point.y)
    }
}

<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
<span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>)
<span class="hljs-keyword">var</span> p3 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(y: <span class="hljs-number">10</span>)
<span class="hljs-keyword">var</span> p4 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">20</span>)
<span class="hljs-keyword">var</span> p5 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(p4) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li><code>required</code>的初始化器也不能写在扩展中
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/86b30907739b411ba4860320550b8df6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w634" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-18">4.协议</h2>
<ul>
<li>
<ol>
<li>如果一个类型<code>已经实现了协议</code>的所有要求，但是<code>还没有声明它遵守</code>了这个协议，<code>可以通过扩展来让他遵守</code>这个协议</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">TestProtocol</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>()
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">TestClass</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"TestClass test1"</span>)
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">TestClass</span>: <span class="hljs-title class_">TestProtocol</span> { } 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">BinaryInteger</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">isOdd</span>() -&gt; <span class="hljs-type">Bool</span> {<span class="hljs-keyword">self</span> <span class="hljs-operator">%</span> <span class="hljs-number">2</span> <span class="hljs-operator">!=</span> <span class="hljs-number">0</span> }
}

<span class="hljs-built_in">print</span>(<span class="hljs-number">10</span>.isOdd()) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li><code>扩展</code>可以给<code>协议</code>提供<code>默认实现</code>，也<code>间接实现可选协议</code>的结果<br>
<code>扩展</code>可以给<code>协议</code>扩充协议中从未声明过的方法</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">TestProtocol</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>()
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">TestProtocol</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"TestProtocol test1"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test2</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"TestProtocol test2"</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">TestClass</span>: <span class="hljs-title class_">TestProtocol</span> { }
<span class="hljs-keyword">var</span> cls <span class="hljs-operator">=</span> <span class="hljs-type">TestClass</span>()
cls.test1() <span class="hljs-comment">// TestProtocol test1</span>
cls.test2() <span class="hljs-comment">// TestProtocol test2</span>

<span class="hljs-keyword">var</span> cls2: <span class="hljs-type">TestProtocol</span> <span class="hljs-operator">=</span> <span class="hljs-type">TestClass</span>()
cls2.test1() <span class="hljs-comment">// TestProtocol test1</span>
cls2.test2() <span class="hljs-comment">// TestProtocol test2 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">TestClass</span>: <span class="hljs-title class_">TestProtocol</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"TestClass test1"</span>)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test2</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"TestClass test2"</span>)
    }
}

<span class="hljs-keyword">var</span> cls <span class="hljs-operator">=</span> <span class="hljs-type">TestClass</span>()
cls.test1() <span class="hljs-comment">// TestClass test1</span>
cls.test2() <span class="hljs-comment">// TestClass test2</span>

<span class="hljs-keyword">var</span> cls2: <span class="hljs-type">TestProtocol</span> <span class="hljs-operator">=</span> <span class="hljs-type">TestClass</span>()
cls2.test1() <span class="hljs-comment">// TestClass test1</span>
cls2.test2() <span class="hljs-comment">// TestProtocol test2 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-19">5. 泛型</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Stack</span>&lt;<span class="hljs-title class_">E</span>&gt; {
    <span class="hljs-keyword">var</span> elements <span class="hljs-operator">=</span> [<span class="hljs-type">E</span>]()
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">push</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">element</span>: <span class="hljs-type">E</span>) {
        elements.append(element)
    }
    
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">pop</span>() -&gt; <span class="hljs-type">E</span> {
        elements.removeLast()
    }
    
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">size</span>() -&gt; <span class="hljs-type">Int</span> {
        elements.count
    }
}  
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol>
<li>扩展中依然可以使用原类型中的泛型类型</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Stack</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">top</span>() -&gt; <span class="hljs-type">E</span> {
        elements.last<span class="hljs-operator">!</span>
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>符合条件才扩展</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Stack</span>: <span class="hljs-title class_">Equatable</span> <span class="hljs-title class_">where</span> <span class="hljs-title class_">E</span> : <span class="hljs-title class_">Equatable</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">==</span> (<span class="hljs-params">left</span>: <span class="hljs-type">Stack</span>, <span class="hljs-params">right</span>: <span class="hljs-type">Stack</span>) -&gt; <span class="hljs-type">Bool</span> {
        left.elements <span class="hljs-operator">==</span> right.elements
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h1 data-id="heading-20">专题系列文章</h1>
<h3 data-id="heading-21">1.前知识</h3>
<ul>
<li><strong><a href="https://juejin.cn/post/7089043618803122183/" target="_blank" title="https://juejin.cn/post/7089043618803122183/">01-探究iOS底层原理|综述</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7093842449998561316/" target="_blank" title="https://juejin.cn/post/7093842449998561316/">02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7095079758844674056" target="_blank" title="https://juejin.cn/post/7095079758844674056">03-探究iOS底层原理|LLDB</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7115302848270696485/" target="_blank" title="https://juejin.cn/post/7115302848270696485/">04-探究iOS底层原理|ARM64汇编</a></strong></li>
</ul>
<h3 data-id="heading-22">2. 基于OC语言探索iOS底层原理</h3>
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
<h3 data-id="heading-23">3. 基于Swift语言探索iOS底层原理</h3>
<p>关于<code>函数</code>、<code>枚举</code>、<code>可选项</code>、<code>结构体</code>、<code>类</code>、<code>闭包</code>、<code>属性</code>、<code>方法</code>、<code>swift多态原理</code>、<code>String</code>、<code>Array</code>、<code>Dictionary</code>、<code>引用计数</code>、<code>MetaData</code>等Swift基本语法和相关的底层原理文章有如下几篇:</p>
<ul>
<li><a href="https://juejin.cn/post/7119020967430455327" target="_blank" title="https://juejin.cn/post/7119020967430455327">Swift5核心语法1-基础语法</a></li>
<li><a href="https://juejin.cn/post/7119510159109390343" target="_blank" title="https://juejin.cn/post/7119510159109390343">Swift5核心语法2-面向对象语法1</a></li>
<li><a href="https://juejin.cn/post/7119513630550261774" target="_blank" title="https://juejin.cn/post/7119513630550261774">Swift5核心语法2-面向对象语法2</a></li>
<li><a href="https://juejin.cn/post/7119714488181325860" target="_blank" title="https://juejin.cn/post/7119714488181325860">Swift5常用核心语法3-其它常用语法</a></li>
<li><a href="https://juejin.cn/post/7119722433589805064" target="_blank" title="https://juejin.cn/post/7119722433589805064">Swift5应用实践常用技术点</a></li>
</ul>
<h1 data-id="heading-24">其它底层原理专题</h1>
<h3 data-id="heading-25">1.底层原理相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7018755998823219213" target="_blank" title="https://juejin.cn/post/7018755998823219213">01-计算机原理|计算机图形渲染原理这篇文章</a></li>
<li><a href="https://juejin.cn/post/7019117942377807908" target="_blank" title="https://juejin.cn/post/7019117942377807908">02-计算机原理|移动终端屏幕成像与卡顿&nbsp;</a></li>
</ul>
<h3 data-id="heading-26">2.iOS相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7019193784806146079" target="_blank" title="https://juejin.cn/post/7019193784806146079">01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019200157119938590" target="_blank" title="https://juejin.cn/post/7019200157119938590">02-iOS底层原理|iOS动画渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019497906650497061/" target="_blank" title="https://juejin.cn/post/7019497906650497061/">03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理</a></li>
<li><a href="https://juejin.cn/post/7020613901033144351" target="_blank" title="https://juejin.cn/post/7020613901033144351">04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案</a></li>
</ul>
<h3 data-id="heading-27">3.webApp相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021035020445810718/" target="_blank" title="https://juejin.cn/post/7021035020445810718/">01-Web和类RN大前端的渲染原理</a></li>
</ul>
<h3 data-id="heading-28">4.跨平台开发方案相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021057396147486750/" target="_blank" title="https://juejin.cn/post/7021057396147486750/">01-Flutter页面渲染原理</a></li>
</ul>
<h3 data-id="heading-29">5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较</h3>
<ul>
<li><a href="https://juejin.cn/post/7021071990723182606/" target="_blank" title="https://juejin.cn/post/7021071990723182606/">01-Native、WebApp、跨平台开发三种方案性能比较</a></li>
</ul>
<h3 data-id="heading-30">6.Android、HarmonyOS页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021840737431978020/" target="_blank" title="https://juejin.cn/post/7021840737431978020/">01-Android页面渲染原理</a></li>
<li><a href="#" title="#">02-HarmonyOS页面渲染原理</a> (<code>待输出</code>)</li>
</ul>
<h3 data-id="heading-31">7.小程序页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021414123346853919" target="_blank" title="https://juejin.cn/post/7021414123346853919">01-小程序框架渲染原理</a></li>
</ul></div></div>