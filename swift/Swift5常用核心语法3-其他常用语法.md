# Swift5常用核心语法3-其他常用语法

<h1 data-id="heading-0">一、概述</h1>
<p>最近刚好有空,趁这段时间,复习一下<code>Swift5</code>核心语法,进行知识储备,以供日后温习 和 进一步探索<code>Swift</code>语言的底层原理做铺垫。</p>
<p>本文继前两篇文章复习:</p>
<ul>
<li><a href="https://juejin.cn/post/7119020967430455327" target="_blank" title="https://juejin.cn/post/7119020967430455327">Swift5核心语法1-基础语法</a></li>
<li><a href="https://juejin.cn/post/7119510159109390343" target="_blank" title="https://juejin.cn/post/7119510159109390343">Swift5核心语法2-面向对象语法1</a></li>
<li><a href="https://juejin.cn/post/7119513630550261774" target="_blank" title="https://juejin.cn/post/7119513630550261774">Swift5核心语法2-面向对象语法2</a></li>
<li>我们通过本文继续复习<code>Swift5常用核心语法3-其它常用语法</code>
<img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a03e517565e54fa6895098e060598486~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h1 data-id="heading-1">二、String、Array的底层分析</h1>
<h2 data-id="heading-2">1. String</h2>
<blockquote>
<p><strong>我们先来思考String变量<code>占用多少内存</code>？</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789"</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 0x3736353433323130 0xea00000000003938 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol>
<li>我们通过打印可以看到<code>String变量</code>占用了<code>16</code>个字节，并且打印内存布局，前后各占用了<code>8个字节</code></li>
</ol>
</li>
<li>
<ol start="2">
<li>下面我们再进行<code>反汇编</code>来观察下:<br>
可以看到这两句指令正是分配了前后8个字节给了<code>String变量</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6660d592d9af43a891376332ffd407f1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w715" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<blockquote>
<p><strong>那String变量底层<code>存储的是什么</code>呢？</strong></p>
</blockquote>
<ul>
<li>
<ol>
<li>我们通过上面看到<code>String变量</code>的16个字节的值其实是对应转成的<code>ASCII码值</code></li>
</ol>
</li>
<li>ASCII码表的地址：<a href="https://link.juejin.cn?target=https%3A%2F%2Fwww.ascii-code.com" target="_blank" title="https://www.ascii-code.com" ref="nofollow noopener noreferrer">www.ascii-code.com</a>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3e0acfa1dfc44f2bb9b58b0d2d7f9b0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1139" loading="lazy" class="medium-zoom-image"></li>
<li>我们看上图就可以得知:
<ul>
<li>左边对应的是<code>0~9</code>的十六进制<code>ASCII码值</code></li>
<li>又因为<code>小端模式(高高低低)</code>下高字节放高地址，低字节放低地址的原则，对比正是我们打印的16个字节中存储的数据
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-number">0x3736353433323130</span> <span class="hljs-number">0xea00000000003938</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
</li>
</ul>
<blockquote>
<p><strong>然后我们再看后8个字节前面的<code>e</code>和<code>a</code>分别代表的是<code>类型</code>和<code>长度</code></strong></p>
</blockquote>
<ul>
<li>如果<code>String</code>的数据是<code>直接存储在变量中</code>的,就是用<code>e</code>来标明类型</li>
<li>如果要是<code>存储在其他地方</code>,就会<code>用别的字母来表示</code></li>
<li>我们<code>String</code>字符的长度正好是10，所以就是十六进制的<code>a</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789ABCDE"</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 0x3736353433323130 0xef45444342413938</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>我们打印上面这个<code>String变量</code>，发现表示长度的值正好变成了<code>f</code></li>
<li>而后7个字节也都被填满了，所以也证明了这种方式最多只能存储15个字节的数据</li>
<li>这种方式很像<code>OC</code>中的<code>Tagger Pointer</code>的存储方式</li>
</ul>
<blockquote>
<p><strong>如果存储的数据超过15个字符，String变量又会是什么样呢？</strong></p>
</blockquote>
<ul>
<li>我们改变<code>String变量</code>的值，再进行打印观察</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789ABCDEF"</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 0xd000000000000010 0x80000001000079a0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>我们发现<code>String变量</code>的内存占用还是16个字节，但是内存布局已经完全不一样了</li>
<li>这时我们就需要借助反汇编来进一步分析了:
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5755335330d5408787db631d057a1c08~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w998" loading="lazy" class="medium-zoom-image"></li>
<li>看上图能发现最后还是会先后分配<code>8个字节</code>给<code>String变量</code>，但不同的是在这之前会调用了函数，并将返回值给了<code>String变量</code>的<code>前8个字节</code></li>
<li>而且分别将<code>字符串</code>的值还有长度作为参数传递了进去，下面我们就看看调用的函数里具体做了什么
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/104ab1a55d59499280f28b37fcf21205~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w995" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e7ba4e15d1e14911815c30f9f02d007a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1058" loading="lazy" class="medium-zoom-image"></li>
<li>我们可以看到函数内部会将一个<code>掩码</code>的值和<code>String变量</code>的地址值相加，然后存储到<code>String变量</code>的后8个字节中</li>
<li>所以我们可以反向计算出所存储的数据真实地址值</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-number">0x80000001000079a0</span> <span class="hljs-operator">-</span> <span class="hljs-number">0x7fffffffffffffe0</span> <span class="hljs-operator">=</span> <span class="hljs-number">0x1000079C0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>其实也就是一开始存储到<code>rdi</code>中的值
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c8be70d3fa449fa85d744375cabd040~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w640" loading="lazy" class="medium-zoom-image">
<ul>
<li>通过打印真实地址值可以看到16个字节确实都是存储着对应的<code>ASCII码值</code></li>
</ul>
</li>
</ul>
<blockquote>
<p><strong>那么真实数据是存储在什么地方呢？</strong></p>
</blockquote>
<ul>
<li>通过观察它的地址我们可以大概推测是在<code>数据段</code></li>
<li>为了更确切的认证我们的推测，使用<code>MachOView</code>来直接查看在可执行文件中这句代码的真正存储位置</li>
<li>我们找到项目中的可执行文件，然后右键<code>Show in Finder</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b9e34e897cad43a7aaf099869e9c9b59~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w357" loading="lazy" class="medium-zoom-image"></li>
<li>然后右键通过<code>MachOView</code>的方式来打开
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1ce3b7c154d14f1493081d48953f99f5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w498" loading="lazy" class="medium-zoom-image"></li>
<li>最终我们发现在代码段中的字符串<code>常量区</code>中
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/438688bb7e5a408e9c8302391914e0cd~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1055" loading="lazy" class="medium-zoom-image"></li>
</ul>
<blockquote>
<p><strong>对比两个字符串的存储位置</strong></p>
</blockquote>
<ul>
<li>我们现在分别查看下这两个字符串的存储位置是否相同</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789"</span>
<span class="hljs-keyword">var</span> str2 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789ABCDEF"</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>我们还是用<code>MachOView</code>来打开可执行文件，发现两个字符串的真实地址都是放在代码段中的<code>字符串常量区</code>，并且相差<code>16个字节</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/06b26919bbde4b98b028c96d686bc17e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1165" loading="lazy" class="medium-zoom-image"></li>
<li>然后我们再看打印的地址的前8个字节</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-number">0xd000000000000010</span> <span class="hljs-number">0x80000001000079a0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>按照推测<code>10</code>应该也是表示长度的十六进制，而前面的<code>d</code>就代表着这种类型</li>
<li>我们更改下字符串的值，发现果然表示长度的值也随之变化了</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str2 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789ABCDEFGH"</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str2)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str2)) <span class="hljs-comment">// 0xd000000000000012 0x80000001000079a0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>如果分别给两个String变量进行拼接会怎样呢？</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789"</span>
str1.append(<span class="hljs-string">"G"</span>)

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 0x3736353433323130 0xeb00000000473938</span>

<span class="hljs-keyword">var</span> str2 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789ABCDEF"</span>
str2.append(<span class="hljs-string">"G"</span>)

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str2)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str2)) <span class="hljs-comment">// 0xf000000000000011 0x0000000100776ed0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>我们发现str1的后8个字节还有位置可以存放新的字符串，所以还是继续存储在内存变量里</li>
<li>而str2的内存布局不一样了，前8个字节可以看出来类型变成<code>f</code>，字符串长度也变为十六进制的<code>11</code>；</li>
<li>而后8个字节的地址很像<code>堆空间</code>的地址值</li>
</ul>
<blockquote>
<p><strong>验证String变量的存储位置是否在堆空间</strong></p>
</blockquote>
<ul>
<li>为了验证我们的推测，下面用反汇编来进行观察</li>
<li>我们在验证之前先创建一个类的实例变量，然后跟进去在内部调用<code>malloc</code>的指令位置打上断点</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }

<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/280785045b49499fb719596615a8d313~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w979" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>然后我们先将断点置灰，重新反汇编之前的<code>Sting变量</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5bc12e07e8ae42f5bff7642c2af48169~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w979" loading="lazy" class="medium-zoom-image"></li>
<li>然后将置灰的<code>malloc</code>的断点点亮，然后进入
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/efca144df3804ed08d949b79aca7f1b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w978" loading="lazy" class="medium-zoom-image"></li>
<li>发现确实会进入到我们之前在调用<code>malloc</code>的断点处，所以这就验证了确实会分配堆空间内存来存储<code>String变量</code>的值了</li>
<li>我们还可以用<code>LLDB</code>的指令<code>bt</code>来打印调用栈详细信息来查看
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2d9a75d0d4cb4d7791e9baf68910218f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w979" loading="lazy" class="medium-zoom-image"></li>
<li>发现也是在调用完<code>append方法</code>之后就会进行<code>malloc</code>的调用了，从这一层面也验证了我们的推测</li>
</ul>
<blockquote>
<p><strong>那堆空间里存储的str2的值是怎样的呢？</strong></p>
</blockquote>
<ul>
<li>然后我们过掉了<code>append函数</code>后，打印str2的地址值，然后再打印后8个字节存放的堆空间地址值
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1b804928b02f43fdbe4d7364359a24db~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w981" loading="lazy" class="medium-zoom-image"></li>
<li>其内部偏移了<code>32个字节</code>后，正是我们<code>String变量</code>的<code>ASCII码值</code></li>
</ul>
<h3 data-id="heading-3">1.1 总结</h3>
<ul>
<li>
<ol>
<li><strong>如果字符串长度小于等于0xF（十进制为15）</strong>,字符串内容直接存储到字符串变量的内存中，并以<code>ASCII</code>码值的<strong>小端模式来进行存储</strong></li>
</ol>
</li>
<li><code>第9个字节</code>会存储字符串<code>变量的类型</code>和<code>字符长度</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789"</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 0x3736353433323130 0xeb00000000473938</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>进行字符串拼接操作后</strong></p>
</blockquote>
<ul>
<li>
<ol start="2">
<li><strong>如果拼接后的字符串长度还是<code>小于等于</code>0xF（十进制为15）</strong> ,存储位置同未拼接之前</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789"</span>
str1.append(<span class="hljs-string">"ABCDE"</span>)

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 0x3736353433323130 0xef45444342413938</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li><strong>如果拼接后的字符串长度<code>大于</code>0xF（十进制为15）</strong>,会<code>开辟堆空间</code>来存储字符串内容</li>
</ol>
</li>
<li>字符串的地址值中:</li>
<li><code>前8个字节</code>存储<code>字符串变量的类型</code>和<code>字符长度</code></li>
<li><code>后8个字节</code>存储着<code>堆空间的地址值</code>，<code>堆空间地址 + 0x20</code>可以得到<code>真正的字符串内容</code></li>
<li>堆空间地址的<code>前32个字节</code>是用来<code>存储描述信息</code>的</li>
<li>由于<code>常量区</code>是程序运行之前就已经确定位置了的,所以拼接字符串是运行时操作,不可能再回存放到常量区,所以<code>直接分配堆空间</code>进行存储</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789"</span>
str1.append(<span class="hljs-string">"ABCDEF"</span>)

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str1)) <span class="hljs-comment">// 0xf000000000000010 0x000000010051d600</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li><strong>如果字符串长度大于0xF（十进制为15）</strong> , 字符串内容会存储在<code>__TEXT.cstring</code>中（常量区）</li>
</ol>
</li>
<li>字符串的地址值中，<code>前8个字节</code>存储字符串变量的类型和字符长度，<code>后8个字节</code>存储着一个地址值，<code>地址值 &amp; mask</code>可以得到字符串内容在常量区真正的地址值</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str2 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789ABCDEF"</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str2)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str2)) <span class="hljs-comment">// 0xd000000000000010 0x80000001000079a0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="5">
<li><strong>进行字符串拼接操作后</strong>，同上面开辟<code>堆空间</code>存储的方式</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str2 <span class="hljs-operator">=</span> <span class="hljs-string">"0123456789ABCDEF"</span>
str2.append(<span class="hljs-string">"G"</span>)

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>str2)) <span class="hljs-comment">// 16</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofVal: <span class="hljs-operator">&amp;</span>str2)) <span class="hljs-comment">// 0xf000000000000011 0x0000000106232230</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-4">1.2 dyld_stub_binder</h3>
<ul>
<li>
<ol>
<li>我们反汇编看到底层调用的<code>String.init</code>方法其实是<code>动态库</code>里的方法，而动态库在内存中的位置是在<code>Mach-O文件</code>的更高地址的位置，如下图所示
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/93c7a01e241b41249b9baa0f3a3c1e6a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w939" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="2">
<li>所以我们这里看到的地址值其实是一个<code>假的地址值</code>，<code>只是用来占位的</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b5d8bba1b0e54694b76952752cc2c49b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w999" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>我们再跟进发现其内部会跳转到另一个地址，取出其存储的真正需要调用的地址值去调用</li>
<li>下一个调用的地址值一般都是相差6个字节</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-number">0x10000774e</span> <span class="hljs-operator">+</span> <span class="hljs-number">0x6</span> <span class="hljs-operator">=</span> <span class="hljs-number">0x100007754</span>
<span class="hljs-number">0x100007754</span> <span class="hljs-operator">+</span> <span class="hljs-number">0x48bc</span>(<span class="hljs-operator">%</span>rip) <span class="hljs-operator">=</span> <span class="hljs-number">0x10000C010</span>
最后就是去<span class="hljs-number">0x10000C010</span>地址中找到需要调用的地址值<span class="hljs-number">0x100007858</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a5afbe8541244d9dab7347755bde2656~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w998" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3a48c418233d4ade9c0c935b1d3ed5c6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w997" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li>3. 然后一直跟进，最后会进入到动态库的<code>dyld_stub_binder</code>中进行绑定
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8bb1f99041f24e3080de780b8405998c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w996" loading="lazy" class="medium-zoom-image"></li>
<li>
<ol start="4">
<li>最后才会真正进入到动态库中的<code>String.init</code>执行指令，而且可以发现其真正的地址值非常大，这也能侧面证明动态库是在可执行文件更高地址的位置
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ffcbe445b3e94cf2ac38865229bfc08d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1000" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="5">
<li>然后我们在执行到下一个<code>String.init</code>的调用
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/98f566de85184723a9edf493e4d5678e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w997" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="6">
<li>跟进去发现这是要跳转的地址值就已经是动态库中的<code>String.init</code>真实地址值了
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e5179fdfdc2b4ad3ac626492ded5b6f7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w997" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2df7d588ff9444c9ab6805413b925c62~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w999" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="7">
<li>这也说明了<code>dyld_stub_binder</code>只会执行一次，而且是用到的时候在进行调用，也就是延迟绑定</li>
</ol>
</li>
<li>
<ol start="8">
<li><code>dyld_stub_binder</code>的主要作用就是在程序运行时，将真正需要调用的函数地址替换掉之前的占位地址</li>
</ol>
</li>
</ul>
<h2 data-id="heading-5">2. Array</h2>
<blockquote>
<p><strong>我们来思考Array变量占用多少内存？</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> array <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>]

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.size(ofVal: <span class="hljs-operator">&amp;</span>array)) <span class="hljs-comment">// 8</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofVal: <span class="hljs-operator">&amp;</span>array)) <span class="hljs-comment">// 0x000000010000c1c8</span>
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.ptr(ofRef: array)) <span class="hljs-comment">// 0x0000000105862270</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol>
<li>我们通过打印可以看到<code>Array变量</code>占用了<code>8个字节</code>，其内存地址就是存储在<code>全局区</code>的地址</li>
</ol>
</li>
<li>
<ol start="2">
<li>然而我们发现其内存地址的存储空间存储的地址值更像一个堆空间的地址</li>
</ol>
</li>
</ul>
<blockquote>
<p><strong>Array变量存储在什么地方呢？</strong></p>
</blockquote>
<ul>
<li>3.带着疑问我们还是进行反汇编来观察下，并且在<code>malloc</code>的调用指令处打上断点
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/485f28a97e604a2eb8bf1c16ad4ec132~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w988" loading="lazy" class="medium-zoom-image"></li>
<li>发现确实调用了<code>malloc</code>，那么就证明了<code>Array变量</code>内部会分配堆空间
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8b36e7c6d60d44389c801ec6a03ddd13~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1000" loading="lazy" class="medium-zoom-image"></li>
<li>
<ol start="4">
<li>等执行完返回值给到<code>Array变量</code>之后，我们打印<code>Array变量</code>存储的地址值内存布局，发现其内部<code>偏移32个字节</code>的位置存储着元素1、2、3、4</li>
</ol>
</li>
<li>我们还可以直接通过打印内存结构来观察
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> array <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>]
<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofRef: array))

<span class="hljs-comment">//0x00007fff88a8dd18</span>
<span class="hljs-comment">//0x0000000200000003</span>
<span class="hljs-comment">//0x0000000000000004</span>
<span class="hljs-comment">//0x0000000000000008</span>
<span class="hljs-comment">//0x0000000000000001</span>
<span class="hljs-comment">//0x0000000000000002</span>
<span class="hljs-comment">//0x0000000000000003</span>
<span class="hljs-comment">//0x0000000000000004 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>我们调整一下元素数量，再打印观察
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> array <span class="hljs-operator">=</span> [<span class="hljs-type">Int</span>]()

<span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> <span class="hljs-number">1</span><span class="hljs-operator">...</span><span class="hljs-number">8</span> {
    array.append(i)
}

<span class="hljs-built_in">print</span>(<span class="hljs-type">Mems</span>.memStr(ofRef: array))

<span class="hljs-comment">//0x00007fff88a8e460</span>
<span class="hljs-comment">//0x0000000200000003</span>
<span class="hljs-comment">//0x0000000000000008</span>
<span class="hljs-comment">//0x0000000000000010</span>
<span class="hljs-comment">//0x0000000000000001</span>
<span class="hljs-comment">//0x0000000000000002</span>
<span class="hljs-comment">//0x0000000000000003</span>
<span class="hljs-comment">//0x0000000000000004</span>
<span class="hljs-comment">//0x0000000000000005</span>
<span class="hljs-comment">//0x0000000000000006</span>
<span class="hljs-comment">//0x0000000000000007</span>
<span class="hljs-comment">//0x0000000000000008</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h1 data-id="heading-6">三、高级运算符</h1>
<h2 data-id="heading-7">1. 溢出运算符（Overflow Operator）</h2>
<ul>
<li>
<ol>
<li>Swift的算数运算符出现溢出时会抛出运行时错误</li>
</ol>
</li>
<li>
<ol start="2">
<li>Swift有溢出运算符<code>&amp;+、&amp;-、&amp;*</code>，用来支持溢出运算
<img src="https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6978fad6d78746afae3d0c5a5cdeaf20~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> min <span class="hljs-operator">=</span> <span class="hljs-type">UInt8</span>.min
<span class="hljs-built_in">print</span>(min <span class="hljs-operator">&amp;-</span> <span class="hljs-number">1</span>) <span class="hljs-comment">// 255, Int8.max</span>

<span class="hljs-keyword">var</span> max <span class="hljs-operator">=</span> <span class="hljs-type">UInt8</span>.max
<span class="hljs-built_in">print</span>(max <span class="hljs-operator">&amp;+</span> <span class="hljs-number">1</span>) <span class="hljs-comment">// 0, Int8.min</span>
<span class="hljs-built_in">print</span>(max <span class="hljs-operator">&amp;*</span> <span class="hljs-number">2</span>) <span class="hljs-comment">// 254, 等价于 max &amp;+ max、</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/92913b09c78f4c9d8f1b5abb6aecbda9~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></p>
<blockquote>
<p><strong>计算方式</strong></p>
</blockquote>
<ul>
<li>
<ol>
<li>类似于一个循环，最大值255再+1，就会回到0；最小值0再-1，就会回到255</li>
</ol>
</li>
<li>
<ol start="2">
<li>而<code>max &amp;* 2</code>就等于<code>max &amp;+ max</code>，也就是255 + 1 + 254，255 + 1会变为0，那么最后的值就是254
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/052d8810d49e4f789585499c901372a4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w596" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-8">2. 运算符重载（Operator Overload）</h2>
<ul>
<li>
<ol>
<li><code>类</code>、<code>结构体</code>、<code>枚举</code>可以为现有的运算符提供自定义的实现，这个操作叫做<code>运算符重载</code></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span>, y: <span class="hljs-type">Int</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">+</span> (<span class="hljs-params">p1</span>: <span class="hljs-type">Point</span>, <span class="hljs-params">p2</span>: <span class="hljs-type">Point</span>) -&gt; <span class="hljs-type">Point</span> {
    <span class="hljs-type">Point</span>(x: p1.x <span class="hljs-operator">+</span> p2.x, y: p1.y <span class="hljs-operator">+</span> p2.y)
}

<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">20</span>) <span class="hljs-operator">+</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">11</span>, y: <span class="hljs-number">22</span>)
<span class="hljs-built_in">print</span>(p) <span class="hljs-comment">// Point(x: 21, y: 42) Point(x: 11, y: 22)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>一般将运算符重载写在相关的<code>结构体</code>、<code>类</code>、<code>枚举</code>的内部</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span>, y: <span class="hljs-type">Int</span>

    <span class="hljs-comment">// 默认就是中缀运算符</span>
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">+</span> (<span class="hljs-params">p1</span>: <span class="hljs-type">Point</span>, <span class="hljs-params">p2</span>: <span class="hljs-type">Point</span>) -&gt; <span class="hljs-type">Point</span> {
        <span class="hljs-type">Point</span>(x: p1.x <span class="hljs-operator">+</span> p2.x, y: p1.y <span class="hljs-operator">+</span> p2.y)
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">-</span> (<span class="hljs-params">p1</span>: <span class="hljs-type">Point</span>, <span class="hljs-params">p2</span>: <span class="hljs-type">Point</span>) -&gt; <span class="hljs-type">Point</span> {
        <span class="hljs-type">Point</span>(x: p1.x <span class="hljs-operator">-</span> p2.x, y: p1.y <span class="hljs-operator">-</span> p2.y)
    }

    <span class="hljs-comment">// 前缀运算符</span>
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">prefix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">-</span> (<span class="hljs-params">p</span>: <span class="hljs-type">Point</span>) -&gt; <span class="hljs-type">Point</span> {
        <span class="hljs-type">Point</span>(x: <span class="hljs-operator">-</span>p.x, y: <span class="hljs-operator">-</span>p.y)
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">+=</span> (<span class="hljs-params">p1</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Point</span>, <span class="hljs-params">p2</span>: <span class="hljs-type">Point</span>) {
        p1 <span class="hljs-operator">=</span> p1 <span class="hljs-operator">+</span> p2
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">prefix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">++</span> (<span class="hljs-params">p</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Point</span>) -&gt; <span class="hljs-type">Point</span> {
        p <span class="hljs-operator">+=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">1</span>, y: <span class="hljs-number">1</span>)
        <span class="hljs-keyword">return</span> p
    }

    <span class="hljs-comment">// 后缀运算符</span>
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">postfix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">++</span> (<span class="hljs-params">p</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Point</span>) -&gt; <span class="hljs-type">Point</span> {
        <span class="hljs-keyword">let</span> tmp <span class="hljs-operator">=</span> p
        p <span class="hljs-operator">+=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">1</span>, y: <span class="hljs-number">1</span>)
        <span class="hljs-keyword">return</span> tmp
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">==</span> (<span class="hljs-params">p1</span>: <span class="hljs-type">Point</span>, <span class="hljs-params">p2</span>: <span class="hljs-type">Point</span>) -&gt; <span class="hljs-type">Bool</span> {
        (p1.x <span class="hljs-operator">==</span> p2.x) <span class="hljs-operator">&amp;&amp;</span> (p1.y <span class="hljs-operator">==</span> p2.y)
    }
}

<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">20</span>)
<span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">11</span>, y: <span class="hljs-number">22</span>)
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">+</span> p2) <span class="hljs-comment">// Point(x: 21, y: 42)</span>
<span class="hljs-built_in">print</span>(p2 <span class="hljs-operator">-</span> p1) <span class="hljs-comment">// Point(x: 1, y: 2)</span>
<span class="hljs-built_in">print</span>(<span class="hljs-operator">-</span>p1) <span class="hljs-comment">// Point(x: -10, y: -20)</span>

p1 <span class="hljs-operator">+=</span> p2
<span class="hljs-built_in">print</span>(p1, p2) <span class="hljs-comment">// Point(x: 21, y: 42) Point(x: 11, y: 22)</span>

p1 <span class="hljs-operator">=</span> <span class="hljs-operator">++</span>p2
<span class="hljs-built_in">print</span>(p1, p2) <span class="hljs-comment">// Point(x: 12, y: 23) Point(x: 12, y: 23)</span>

p1 <span class="hljs-operator">=</span> p2<span class="hljs-operator">++</span>
<span class="hljs-built_in">print</span>(p1, p2) <span class="hljs-comment">// Point(x: 12, y: 23) Point(x: 13, y: 24)</span>
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">==</span> p2) <span class="hljs-comment">// false</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-9">3. Equatable</h2>
<ul>
<li>
<ol>
<li>要想得知两个实例是否等价，一般做法是遵守<code>Equatable协议</code>，重载<code>==</code>运算符
于此同时，等价于<code>!=</code>运算符</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Equatable</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">==</span> (<span class="hljs-params">lhs</span>: <span class="hljs-type">Person</span>, <span class="hljs-params">rhs</span>: <span class="hljs-type">Person</span>) -&gt; <span class="hljs-type">Bool</span> {
        lhs.age <span class="hljs-operator">==</span> rhs.age
    }
}

<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>(age: <span class="hljs-number">10</span>)
<span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>(age: <span class="hljs-number">20</span>)
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">==</span> p2) <span class="hljs-comment">// false</span>
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">!=</span> p2) <span class="hljs-comment">// true</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>如果没有遵守<code>Equatable协议</code>，使用<code>!=</code>就会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d27c4247a3b24460ac35ad8614007b19~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w640" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>如果没有遵守<code>Equatable协议</code>，只重载<code>==</code>运算符，也可以使用<code>p1 == p2</code>的判断，但是遵守<code>Equatable协议</code>是为了能够在有限制的泛型函数中作为参数使用</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">equal</span>&lt;<span class="hljs-type">T</span>: <span class="hljs-type">Equatable</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">t1</span>: <span class="hljs-type">T</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">t2</span>: <span class="hljs-type">T</span>) -&gt; <span class="hljs-type">Bool</span> {
    t1 <span class="hljs-operator">==</span> t2
}

<span class="hljs-built_in">print</span>(equal(p1, p2)) <span class="hljs-comment">// false</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>Swift为以下类型提供默认的<code>Equatable</code>实现</strong></p>
</blockquote>
<ul>
<li>
<ol>
<li>没有关联类型的枚举</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Answer</span> {
    <span class="hljs-keyword">case</span> right, wrong
}

<span class="hljs-keyword">var</span> s1 <span class="hljs-operator">=</span> <span class="hljs-type">Answer</span>.right
<span class="hljs-keyword">var</span> s2 <span class="hljs-operator">=</span> <span class="hljs-type">Answer</span>.wrong
<span class="hljs-built_in">print</span>(s1 <span class="hljs-operator">==</span> s2) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>只拥有遵守<code>Equatable协议</code>关联类型的枚举</li>
</ol>
</li>
<li>
<ol start="3">
<li>系统很多自带类型都已经遵守了<code>Equatable协议</code>，类似<code>Int、Double</code>等</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Answer</span>: <span class="hljs-title class_">Equatable</span> {
    <span class="hljs-keyword">case</span> right, wrong(<span class="hljs-type">Int</span>)
}

<span class="hljs-keyword">var</span> s1 <span class="hljs-operator">=</span> <span class="hljs-type">Answer</span>.wrong(<span class="hljs-number">20</span>)
<span class="hljs-keyword">var</span> s2 <span class="hljs-operator">=</span> <span class="hljs-type">Answer</span>.wrong(<span class="hljs-number">10</span>)
<span class="hljs-built_in">print</span>(s1 <span class="hljs-operator">==</span> s2)
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li>关联类型没有遵守<code>Equatable协议</code>的就会报错
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fbe5768c60e74704ab7c5996cb3174fb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w640" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="5">
<li>只拥有遵守<code>Equatable协议</code>存储属性的结构体</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span>: <span class="hljs-title class_">Equatable</span> {
    <span class="hljs-keyword">var</span> x: <span class="hljs-type">Int</span>, y: <span class="hljs-type">Int</span>
}

<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">20</span>)
<span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">11</span>, y: <span class="hljs-number">22</span>)
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">==</span> p2) <span class="hljs-comment">// false</span>
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">!=</span> p2) <span class="hljs-comment">// true</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="6">
<li>引用类型比较存储的地址值是否相等（是否引用着同一个对象），使用恒等运算符<code>===、!==</code></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {

}

<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">===</span> p2) <span class="hljs-comment">// false</span>
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">!==</span> p2) <span class="hljs-comment">// true </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-10">4. Comparable</h2>
<ul>
<li>
<ol>
<li>要想比较两个实例的大小，一般做法是遵守<code>Comparable协议</code>，重载相应的运算符</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Comparable</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">var</span> score: <span class="hljs-type">Int</span>
    <span class="hljs-keyword">init</span>(<span class="hljs-params">score</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">age</span>: <span class="hljs-type">Int</span>) {
        <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> score
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">&lt;</span> (<span class="hljs-params">lhs</span>: <span class="hljs-type">Student</span>, <span class="hljs-params">rhs</span>: <span class="hljs-type">Student</span>) -&gt; <span class="hljs-type">Bool</span> {
        (lhs.score <span class="hljs-operator">&lt;</span> rhs.score) <span class="hljs-operator">||</span> (lhs.score <span class="hljs-operator">==</span> rhs.score <span class="hljs-operator">&amp;&amp;</span> lhs.age <span class="hljs-operator">&gt;</span> rhs.age)
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">&gt;</span> (<span class="hljs-params">lhs</span>: <span class="hljs-type">Student</span>, <span class="hljs-params">rhs</span>: <span class="hljs-type">Student</span>) -&gt; <span class="hljs-type">Bool</span> {
        (lhs.score <span class="hljs-operator">&gt;</span> rhs.score) <span class="hljs-operator">||</span> (lhs.score <span class="hljs-operator">==</span> rhs.score <span class="hljs-operator">&amp;&amp;</span> lhs.age <span class="hljs-operator">&lt;</span> rhs.age)
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">&lt;=</span> (<span class="hljs-params">lhs</span>: <span class="hljs-type">Student</span>, <span class="hljs-params">rhs</span>: <span class="hljs-type">Student</span>) -&gt; <span class="hljs-type">Bool</span> {
        <span class="hljs-operator">!</span>(lhs <span class="hljs-operator">&gt;</span> rhs)
    }

    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">&gt;=</span> (<span class="hljs-params">lhs</span>: <span class="hljs-type">Student</span>, <span class="hljs-params">rhs</span>: <span class="hljs-type">Student</span>) -&gt; <span class="hljs-type">Bool</span> {
        <span class="hljs-operator">!</span>(lhs <span class="hljs-operator">&lt;</span> rhs)
    }
}

<span class="hljs-keyword">var</span> stu1 <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(score: <span class="hljs-number">100</span>, age: <span class="hljs-number">20</span>)
<span class="hljs-keyword">var</span> stu2 <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(score: <span class="hljs-number">98</span>, age: <span class="hljs-number">18</span>)
<span class="hljs-keyword">var</span> stu3 <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(score: <span class="hljs-number">100</span>, age: <span class="hljs-number">20</span>)

<span class="hljs-built_in">print</span>(stu1 <span class="hljs-operator">&gt;</span> stu2) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(stu1 <span class="hljs-operator">&gt;=</span> stu2) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(stu1 <span class="hljs-operator">&gt;=</span> stu3) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(stu1 <span class="hljs-operator">&lt;=</span> stu3) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(stu2 <span class="hljs-operator">&lt;</span> stu1) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(stu2 <span class="hljs-operator">&lt;=</span> stu1) <span class="hljs-comment">// true </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-11">5. 自定义运算符（Custom Operator）</h2>
<ul>
<li>
<ol>
<li>可以<code>自定义新的运算符</code>: 在全局作用域使用<code>operator</code>进行声明</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">prefix</span> <span class="hljs-keyword">operator</span> 前缀运算符
<span class="hljs-keyword">postfix</span> <span class="hljs-keyword">operator</span> 后缀运算符
<span class="hljs-keyword">infix</span> <span class="hljs-keyword">operator</span> 中缀运算符：优先级组

<span class="hljs-keyword">precedencegroup</span> 优先级组 {
    associativity: 结合性（left\right\none）
    higherThan: 比谁的优先级更高
    lowerThan: 比谁的优先级低
    assignment: <span class="hljs-literal">true</span>代表在可选链操作中拥有跟赋值运算符一样的优先级
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li><code>自定义运算符</code>的使用示例如下</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">prefix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">+++</span>

<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">+++</span> (<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) {
    i <span class="hljs-operator">+=</span> <span class="hljs-number">2</span>
}

<span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-operator">+++</span>age
<span class="hljs-built_in">print</span>(age) <span class="hljs-comment">// 12 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">infix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">+-</span>: <span class="hljs-type">PlusMinusPrecedence</span>
<span class="hljs-keyword">precedencegroup</span> <span class="hljs-title">PlusMinusPrecedence</span> {
    <span class="hljs-keyword">associativity</span>: <span class="hljs-keyword">none</span>
    <span class="hljs-keyword">higherThan</span>: <span class="hljs-type">AdditionPrecedence</span>
    <span class="hljs-keyword">lowerThan</span>: <span class="hljs-type">MultiplicationPrecedence</span>
    <span class="hljs-keyword">assignment</span>: <span class="hljs-keyword">true</span>
}

<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
    <span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">+-</span> (<span class="hljs-params">p1</span>: <span class="hljs-type">Point</span>, <span class="hljs-params">p2</span>: <span class="hljs-type">Point</span>) -&gt; <span class="hljs-type">Point</span> {
        <span class="hljs-type">Point</span>(x: p1.x <span class="hljs-operator">+</span> p2.x, y: p1.y <span class="hljs-operator">-</span> p2.y)
    }
}

<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">20</span>)
<span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">5</span>, y: <span class="hljs-number">10</span>)

<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">+-</span> p2) <span class="hljs-comment">// Point(x: 15, y: 10)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>优先级组中的associativity的设置影响</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift">associativity对应的三个选项

left: 从左往右执行，可以多个进行结合
right: 从右往左执行，可以多个进行结合
none: 不支持多个结合 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li>如果再增加一个计算就会报错，因为我们设置的<code>associativity</code>为<code>none</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc1d00a4584b47388f5e57ee164d9c2f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w643" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="4">
<li>我们把<code>associativity</code>改为<code>left</code>或者<code>right</code>，再运行就可以了</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">infix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">+-</span>: <span class="hljs-type">PlusMinusPrecedence</span>
<span class="hljs-keyword">precedencegroup</span> <span class="hljs-title">PlusMinusPrecedence</span> {
    <span class="hljs-keyword">associativity</span>: <span class="hljs-keyword">left</span>
    <span class="hljs-keyword">higherThan</span>: <span class="hljs-type">AdditionPrecedence</span>
    <span class="hljs-keyword">lowerThan</span>: <span class="hljs-type">MultiplicationPrecedence</span>
    <span class="hljs-keyword">assignment</span>: <span class="hljs-keyword">true</span>
}

<span class="hljs-keyword">var</span> p3 <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">5</span>, y: <span class="hljs-number">10</span>)
<span class="hljs-built_in">print</span>(p1 <span class="hljs-operator">+-</span> p2 <span class="hljs-operator">+-</span> p3) <span class="hljs-comment">// Point(x: 20, y: 0)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>优先级组中的assignment的设置影响</strong></p>
</blockquote>
<p>我们先看下面的示例代码</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
<span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
<span class="hljs-keyword">var</span> point: <span class="hljs-type">Point</span> <span class="hljs-operator">=</span> <span class="hljs-type">Point</span>()
}

<span class="hljs-keyword">var</span> p: <span class="hljs-type">Person</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>

<span class="hljs-built_in">print</span>(p<span class="hljs-operator">?</span>.point <span class="hljs-operator">+-</span> <span class="hljs-type">Point</span>(x: <span class="hljs-number">10</span>, y: <span class="hljs-number">20</span>))
<span class="copy-code-btn">复制代码</span></code></pre>
<p>设置<code>assignment</code>为<code>true</code>的意思就是如果在运算中，前面的可选项为<code>nil</code>，那么运算符后面的代码就不会执行了</p>
<p>Apple文档参考链接： <a href="https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2Fswift%2Fswift_standard_library%2Foperator_declarations" target="_blank" title="https://developer.apple.com/documentation/swift/swift_standard_library/operator_declarations" ref="nofollow noopener noreferrer">developer.apple.com/documentati…</a></p>
<p>另一个： <a href="https://link.juejin.cn?target=https%3A%2F%2Fdocs.swift.org%2Fswift-book%2FReferenceManual%2FDeclarations.html" target="_blank" title="https://docs.swift.org/swift-book/ReferenceManual/Declarations.html" ref="nofollow noopener noreferrer">docs.swift.org/swift-book/…</a></p>
<h1 data-id="heading-12">四、错误处理、泛型</h1>
<h2 data-id="heading-13">1. 错误处理</h2>
<h3 data-id="heading-14">1.1 错误类型</h3>
<p>开发过程中常见的错误有</p>
<ul>
<li>语法错误（编译报错）</li>
<li>逻辑错误</li>
<li>运行时错误（可能会导致闪退，一般也叫做异常）</li>
<li>....</li>
</ul>
<h3 data-id="heading-15">1.2 自定义错误</h3>
<ul>
<li>
<ol>
<li>Swift中可以通过<code>Error</code>协议自定义运行时的错误信息</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">SomeError</span>: <span class="hljs-title class_">Error</span> {
    <span class="hljs-keyword">case</span> illegalArg(<span class="hljs-type">String</span>)
    <span class="hljs-keyword">case</span> outOffBounds(<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>)
    <span class="hljs-keyword">case</span> outOfMemory
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>函数内部通过<code>throw</code>抛出自定义<code>Error</code>，可能会抛出<code>Error</code>的函数必须加上<code>throws</code>声明</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">divide</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">num2</span>: <span class="hljs-type">Int</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-keyword">if</span> num2 <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
        <span class="hljs-keyword">throw</span> <span class="hljs-type">SomeError</span>.illegalArg(<span class="hljs-string">"0不能作为除数"</span>)
    }
    <span class="hljs-keyword">return</span> num1 <span class="hljs-operator">/</span> num2
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li>需要使用<code>try</code>调用可能会抛出<code>Error</code>的函数</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> result <span class="hljs-operator">=</span> <span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">10</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li>抛出错误信息的情况
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7930b652084241faba9c27f010bc0d2d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w715" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h3 data-id="heading-16">1.3 do—catch</h3>
<ul>
<li>
<ol>
<li>可以使用<code>do—catch</code>捕捉<code>Error</code></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">do</span> {
    <span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>)
} <span class="hljs-keyword">catch</span> <span class="hljs-keyword">let</span> error {
    <span class="hljs-keyword">switch</span> error {
    <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> <span class="hljs-type">SomeError</span>.illegalArg(msg):
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"参数错误"</span>, msg)
    <span class="hljs-keyword">default</span>:
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"其他错误"</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>抛出<code>Error</code>后，<code>try</code>下一句直到作用域结束的代码都将停止运行</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"1"</span>)

    <span class="hljs-keyword">do</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
        <span class="hljs-built_in">print</span>(<span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>)) <span class="hljs-comment">// 这句抛出异常后面的代码不会执行了</span>
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"3"</span>)
    } <span class="hljs-keyword">catch</span> <span class="hljs-keyword">let</span> <span class="hljs-type">SomeError</span>.illegalArg(msg) {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"参数异常:"</span>, msg)
    } <span class="hljs-keyword">catch</span> <span class="hljs-keyword">let</span> <span class="hljs-type">SomeError</span>.outOffBounds(size, index) {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"下标越界:"</span>, <span class="hljs-string">"size=(size)"</span>, <span class="hljs-string">"index=(index)"</span>)
    } <span class="hljs-keyword">catch</span> <span class="hljs-type">SomeError</span>.outOfMemory {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"内存溢出"</span>)
    } <span class="hljs-keyword">catch</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"其他错误"</span>)
    }

    <span class="hljs-built_in">print</span>(<span class="hljs-string">"4"</span>)
}

test()

<span class="hljs-comment">//1</span>
<span class="hljs-comment">//2</span>
<span class="hljs-comment">//参数异常: 0不能作为除数</span>
<span class="hljs-comment">//4 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li><code>catch</code>作用域内默认就有<code>error</code>的变量可以捕获</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">do</span> {
    <span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>)
} <span class="hljs-keyword">catch</span> {
    <span class="hljs-built_in">print</span>(error)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-17">2. 处理Error</h2>
<ul>
<li>
<ol>
<li>处理<code>Error</code>的两种方式:</li>
</ol>
</li>
<li>a. 通过<code>do—catch</code>捕捉<code>Error</code>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">do</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>))
} <span class="hljs-keyword">catch</span> <span class="hljs-keyword">is</span> <span class="hljs-type">SomeError</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"SomeError"</span>)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>b. 不捕捉<code>Error</code>，在当前函数增加<code>throws</code>声明，<code>Error</code>将自动抛给上层函数<br>
如果最顶层函数<code>main函数</code>依然没有捕捉<code>Error</code>，那么程序将终止
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() <span class="hljs-keyword">throws</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"1"</span>)
    <span class="hljs-built_in">print</span>(<span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>))
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
}

<span class="hljs-keyword">try</span> test()

<span class="hljs-comment">// 1</span>
<span class="hljs-comment">// Fatal error: Error raised at top level </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>调用函数如果是写在函数里面，没有进行捕捉<code>Error</code>就会报错，而写在外面就不会
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5b762799211d40e0a615dd5a6e22c6f3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w648" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>然后我们加上<code>do-catch</code>发现还是会报错，因为捕捉<code>Error</code>的处理不够详细，要捕捉所有<code>Error</code>信息才可以
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cb1a1d7f29104af994f8efec21a18f1d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w639" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>这时我们加上<code>throws</code>就可以了
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() <span class="hljs-keyword">throws</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"1"</span>)
    <span class="hljs-keyword">do</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
        <span class="hljs-built_in">print</span>(<span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>))
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"3"</span>)
    } <span class="hljs-keyword">catch</span> <span class="hljs-keyword">let</span> error <span class="hljs-keyword">as</span> <span class="hljs-type">SomeError</span> {
        <span class="hljs-built_in">print</span>(error)
    }

    <span class="hljs-built_in">print</span>(<span class="hljs-string">"4"</span>)
}

<span class="hljs-keyword">try</span> test()

<span class="hljs-comment">// 1</span>
<span class="hljs-comment">// 2</span>
<span class="hljs-comment">// illegalArg("0不能作为除数")</span>
<span class="hljs-comment">// 4 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>或者再加上一个<code>catch</code>捕获其他所有<code>Error</code>情况
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"1"</span>)
    <span class="hljs-keyword">do</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
        <span class="hljs-built_in">print</span>(<span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>))
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"3"</span>)
    } <span class="hljs-keyword">catch</span> <span class="hljs-keyword">let</span> error <span class="hljs-keyword">as</span> <span class="hljs-type">SomeError</span> {
        <span class="hljs-built_in">print</span>(error)
    } <span class="hljs-keyword">catch</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"其他错误情况"</span>)
    }

    <span class="hljs-built_in">print</span>(<span class="hljs-string">"4"</span>)
}

test() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>看下面示例代码，执行后会输出什么
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test0</span>() <span class="hljs-keyword">throws</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"1"</span>)
    <span class="hljs-keyword">try</span> test1()
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>() <span class="hljs-keyword">throws</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"3"</span>)
    <span class="hljs-keyword">try</span> test2()
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"4"</span>)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test2</span>() <span class="hljs-keyword">throws</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"5"</span>)
    <span class="hljs-keyword">try</span> test3()
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"6"</span>)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test3</span>() <span class="hljs-keyword">throws</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"7"</span>)
    <span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>)
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"8"</span>)
}

<span class="hljs-keyword">try</span> test0() 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>执行后打印如下，并会抛出错误信息
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fb0551c1a8ea45829511ba7bf79cfaa3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w717" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-18">3. try</h2>
<ul>
<li>
<ol>
<li>可以使用<code>try?、try!</code>调用可能会抛出<code>Error</code>的函数，这样就不用去处理<code>Error</code></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"1"</span>)

    <span class="hljs-keyword">var</span> result1 <span class="hljs-operator">=</span> <span class="hljs-keyword">try?</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">10</span>) <span class="hljs-comment">// Optional(2), Int?</span>
    <span class="hljs-keyword">var</span> result2 <span class="hljs-operator">=</span> <span class="hljs-keyword">try?</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>) <span class="hljs-comment">// nil</span>
    <span class="hljs-keyword">var</span> result3 <span class="hljs-operator">=</span> <span class="hljs-keyword">try!</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">10</span>) <span class="hljs-comment">// 2, Int</span>

    <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
}

test() 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>a、b是等价的</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> a <span class="hljs-operator">=</span> <span class="hljs-keyword">try?</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>)
<span class="hljs-keyword">var</span> b: <span class="hljs-type">Int</span>?

<span class="hljs-keyword">do</span> {
     b <span class="hljs-operator">=</span> <span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>)
} <span class="hljs-keyword">catch</span> { b <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span> }
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-19">4. rethrows</h2>
<ul>
<li><code>rethrows</code>表明，函数本身不会抛出错误，但调用闭包参数抛出错误，那么它会将错误向上抛</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">exec</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">fn</span>: (<span class="hljs-type">Int</span>, <span class="hljs-type">Int</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">num1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">num2</span>: <span class="hljs-type">Int</span>) <span class="hljs-keyword">rethrows</span> {
<span class="hljs-built_in">print</span>(<span class="hljs-keyword">try</span> fn(num1, num2))
}

<span class="hljs-comment">// Fatal error: Error raised at top level</span>
<span class="hljs-keyword">try</span> exec(divide, <span class="hljs-number">20</span>, <span class="hljs-number">0</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>空合并运算符就是用了<code>rethrows</code>来进行声明的
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3d973592ccd54e0a96c23cc6d9b4b4a5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w609" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-20">5. defer</h2>
<ul>
<li>
<ol>
<li><code>defer</code>语句，用来定义以任何方式（抛错误、return等）离开代码块前必须要执行的代码</li>
</ol>
</li>
<li>
<ol start="2">
<li><code>defer</code>语句将延迟至当前作用域结束之前执行</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">open</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">filename</span>: <span class="hljs-type">String</span>) -&gt; <span class="hljs-type">Int</span> {
<span class="hljs-built_in">print</span>(<span class="hljs-string">"open"</span>)
<span class="hljs-keyword">return</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">close</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">file</span>: <span class="hljs-type">Int</span>) {
<span class="hljs-built_in">print</span>(<span class="hljs-string">"close"</span>)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">processFile</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">filename</span>: <span class="hljs-type">String</span>) <span class="hljs-keyword">throws</span> {
<span class="hljs-keyword">let</span> file <span class="hljs-operator">=</span> <span class="hljs-keyword">open</span>(filename)
<span class="hljs-keyword">defer</span> {
    close(file)
}

<span class="hljs-comment">// 使用file</span>
<span class="hljs-comment">// .....</span>
<span class="hljs-keyword">try</span> divide(<span class="hljs-number">20</span>, <span class="hljs-number">0</span>)

<span class="hljs-comment">// close将会在这里调用</span>
}

<span class="hljs-keyword">try</span> processFile(<span class="hljs-string">"test.txt"</span>)

<span class="hljs-comment">// open</span>
<span class="hljs-comment">// close</span>
<span class="hljs-comment">// Fatal error: Error raised at top level</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li><code>defer</code>语句的执行顺序与定义顺序相反</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">fn1</span>() { <span class="hljs-built_in">print</span>(<span class="hljs-string">"fn1"</span>) }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">fn2</span>() { <span class="hljs-built_in">print</span>(<span class="hljs-string">"fn2"</span>) }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
<span class="hljs-keyword">defer</span> { fn1() }
<span class="hljs-keyword">defer</span> { fn2() }
}

test()

<span class="hljs-comment">// fn2</span>
<span class="hljs-comment">// fn1 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-21">6. assert（断言）</h2>
<ul>
<li>很多编程语言都有断言机制，不符合指定条件就抛出运行时错误，常用于调试<code>Debug</code>阶段的条件判断
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9dd47e1150c04452aefc2cb0ff1fcefa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image"></li>
<li>默认情况下，Swift的断言只会在<code>Debug</code>模式下生效，<code>Release</code>模式下会忽略</li>
<li>增加<code>Swift Flags</code>修改断言的默认行为</li>
<li><code>-assert-config Release</code>：强制关闭断言</li>
<li><code>-assert-config Debug</code>：强制开启断言
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3876ff55e7b4d719e6639fb3f5f8e05~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h2 data-id="heading-22">7. fatalError</h2>
<ul>
<li>
<ol>
<li>如果遇到严重问题，希望结束程序运行时，可以直接使用<code>fatalError</code>函数抛出错误</li>
</ol>
</li>
<li>
<ol start="2">
<li>这是无法通过<code>do—catch</code>捕获的错误</li>
</ol>
</li>
<li>
<ol start="3">
<li>使用了<code>fatalError</code>函数，就不需要再写<code>return</code></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-keyword">if</span> num <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> {
        <span class="hljs-keyword">return</span> <span class="hljs-number">1</span>
    }
    <span class="hljs-built_in">fatalError</span>(<span class="hljs-string">"num不能小于0"</span>)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li>在某些不得不实现，但不希望别人调用的方法，可以考虑内部使用<code>fatalError</code>函数</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {} }
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-built_in">fatalError</span>(<span class="hljs-string">"don't call Student.init"</span>)
    }

    <span class="hljs-keyword">init</span>(<span class="hljs-params">score</span>: <span class="hljs-type">Int</span>) {

    }
}

<span class="hljs-keyword">var</span> stu1 <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(score: <span class="hljs-number">98</span>)
<span class="hljs-keyword">var</span> stu2 <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>()
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-23">8. 局部作用域</h2>
<ul>
<li>
<ol>
<li>可以使用<code>do</code>实现局部作用域</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">do</span> {
    <span class="hljs-keyword">let</span> dog1 <span class="hljs-operator">=</span> <span class="hljs-type">Dog</span>()
    dog1.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    dog1.run()
}

<span class="hljs-keyword">do</span> {
    <span class="hljs-keyword">let</span> dog2 <span class="hljs-operator">=</span> <span class="hljs-type">Dog</span>()
    dog2.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
    dog2.run()
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-24">五、泛型（Generics）</h1>
<h2 data-id="heading-25">1. 基本概念</h2>
<ul>
<li>1.1 <code>泛型</code>可以将<code>类型参数化</code><br>
提高代码复用率，减少代码量</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">swapValues</span>&lt;<span class="hljs-type">T</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">a</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">T</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">b</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">T</span>) {
    (a, b) <span class="hljs-operator">=</span> (b, a)
}

<span class="hljs-keyword">var</span> i1 <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> i2 <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
<span class="hljs-built_in">swap</span>(<span class="hljs-operator">&amp;</span>i1, <span class="hljs-operator">&amp;</span>i2)
<span class="hljs-built_in">print</span>(i1, i2) <span class="hljs-comment">// 20, 10</span>

<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Date</span> {
    <span class="hljs-keyword">var</span> year <span class="hljs-operator">=</span> <span class="hljs-number">0</span>, month <span class="hljs-operator">=</span> <span class="hljs-number">0</span>, day <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
}

<span class="hljs-keyword">var</span> d1 <span class="hljs-operator">=</span> <span class="hljs-type">Date</span>(year: <span class="hljs-number">2011</span>, month: <span class="hljs-number">9</span>, day: <span class="hljs-number">10</span>)
<span class="hljs-keyword">var</span> d2 <span class="hljs-operator">=</span> <span class="hljs-type">Date</span>(year: <span class="hljs-number">2012</span>, month: <span class="hljs-number">10</span>, day: <span class="hljs-number">20</span>)
<span class="hljs-built_in">swap</span>(<span class="hljs-operator">&amp;</span>d1, <span class="hljs-operator">&amp;</span>d2)
<span class="hljs-built_in">print</span>(d1, d2) <span class="hljs-comment">// Date(year: 2012, month: 10, day: 20), Date(year: 2011, month: 9, day: 10) </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>1.2 <code>泛型</code>函数赋值给变量</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>&lt;<span class="hljs-type">T1</span>, <span class="hljs-type">T2</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">t1</span>: <span class="hljs-type">T1</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">t2</span>: <span class="hljs-type">T2</span>) {}
<span class="hljs-keyword">var</span> fn: (<span class="hljs-type">Int</span>, <span class="hljs-type">Double</span>) -&gt; () <span class="hljs-operator">=</span> test
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-26">2. 泛型类型</h2>
<blockquote>
<p>Case1 <code>栈</code></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Stack</span>&lt;<span class="hljs-title class_">E</span>&gt; {
<span class="hljs-keyword">var</span> elements <span class="hljs-operator">=</span> [<span class="hljs-type">E</span>]()

<span class="hljs-keyword">func</span> <span class="hljs-title function_">push</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">element</span>: <span class="hljs-type">E</span>) {
    elements.append(element)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">pop</span>() -&gt; <span class="hljs-type">E</span> {
    elements.removeLast()
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">top</span>() -&gt; <span class="hljs-type">E</span> {
    elements.last<span class="hljs-operator">!</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">size</span>() -&gt; <span class="hljs-type">Int</span> {
    elements.count
}
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">SubStack</span>&lt;<span class="hljs-title class_">E</span>&gt;: <span class="hljs-title class_">Stack</span>&lt;<span class="hljs-title class_">E</span>&gt; {

}

<span class="hljs-keyword">var</span> intStack <span class="hljs-operator">=</span> <span class="hljs-type">Stack</span>&lt;<span class="hljs-type">Int</span>&gt;()
<span class="hljs-keyword">var</span> stringStack <span class="hljs-operator">=</span> <span class="hljs-type">Stack</span>&lt;<span class="hljs-type">String</span>&gt;()
<span class="hljs-keyword">var</span> anyStack <span class="hljs-operator">=</span> <span class="hljs-type">Stack</span>&lt;<span class="hljs-keyword">Any</span>&gt;()
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p>Case1 <code>栈</code> 继续完善</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Stack</span>&lt;<span class="hljs-title class_">E</span>&gt; {
<span class="hljs-keyword">var</span> elements <span class="hljs-operator">=</span> [<span class="hljs-type">E</span>]()

<span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">push</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">element</span>: <span class="hljs-type">E</span>) {
    elements.append(element)
}

<span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">pop</span>() -&gt; <span class="hljs-type">E</span> {
    elements.removeLast()
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">top</span>() -&gt; <span class="hljs-type">E</span> {
    elements.last<span class="hljs-operator">!</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">size</span>() -&gt; <span class="hljs-type">Int</span> {
    elements.count
}
}

<span class="hljs-keyword">var</span> stack <span class="hljs-operator">=</span> <span class="hljs-type">Stack</span>&lt;<span class="hljs-type">Int</span>&gt;()
stack.push(<span class="hljs-number">11</span>)
stack.push(<span class="hljs-number">22</span>)
stack.push(<span class="hljs-number">33</span>)
<span class="hljs-built_in">print</span>(stack.top()) <span class="hljs-comment">// 33</span>
<span class="hljs-built_in">print</span>(stack.pop()) <span class="hljs-comment">// 33</span>
<span class="hljs-built_in">print</span>(stack.pop()) <span class="hljs-comment">// 22</span>
<span class="hljs-built_in">print</span>(stack.pop()) <span class="hljs-comment">// 11</span>
<span class="hljs-built_in">print</span>(stack.size()) <span class="hljs-comment">// 0</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p>Case2</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Score</span>&lt;<span class="hljs-title class_">T</span>&gt; {
<span class="hljs-keyword">case</span> point(<span class="hljs-type">T</span>)
<span class="hljs-keyword">case</span> grade(<span class="hljs-type">String</span>)
}

<span class="hljs-keyword">let</span> score0 <span class="hljs-operator">=</span> <span class="hljs-type">Score</span>&lt;<span class="hljs-type">Int</span>&gt;.point(<span class="hljs-number">100</span>)
<span class="hljs-keyword">let</span> score1 <span class="hljs-operator">=</span> <span class="hljs-type">Score</span>.point(<span class="hljs-number">99</span>)
<span class="hljs-keyword">let</span> score2 <span class="hljs-operator">=</span> <span class="hljs-type">Score</span>.point(<span class="hljs-number">99.5</span>)
<span class="hljs-keyword">let</span> score3 <span class="hljs-operator">=</span> <span class="hljs-type">Score</span>&lt;<span class="hljs-type">Int</span>&gt;.grade(<span class="hljs-string">"A"</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-27">3. 关联类型（Associated Type）</h2>
<ul>
<li>
<ol>
<li>关联类型的作用: 给协议中用到的类型定义一个占位名称</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Stackable</span> {
    <span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Element</span>
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">push</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">element</span>: <span class="hljs-type">Element</span>)
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">pop</span>() -&gt; <span class="hljs-type">Element</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">top</span>() -&gt; <span class="hljs-type">Element</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">size</span>() -&gt; <span class="hljs-type">Int</span>
}

<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Stack</span>&lt;<span class="hljs-title class_">E</span>&gt;: <span class="hljs-title class_">Stackable</span> {
    <span class="hljs-keyword">var</span> elements <span class="hljs-operator">=</span> [<span class="hljs-type">E</span>]()

    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">push</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">element</span>: <span class="hljs-type">E</span>) {
        elements.append(element)
    }

    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">pop</span>() -&gt; <span class="hljs-type">E</span> {
        elements.removeLast()
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">top</span>() -&gt; <span class="hljs-type">E</span> {
        elements.last<span class="hljs-operator">!</span>
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">size</span>() -&gt; <span class="hljs-type">Int</span> {
        elements.count
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">StringStack</span>: <span class="hljs-title class_">Stackable</span> {
    <span class="hljs-keyword">var</span> elements <span class="hljs-operator">=</span> [<span class="hljs-type">String</span>]()

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">push</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">element</span>: <span class="hljs-type">String</span>) {
        elements.append(element)
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">pop</span>() -&gt; <span class="hljs-type">String</span> {
        elements.removeLast()
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">top</span>() -&gt; <span class="hljs-type">String</span> {
        elements.last<span class="hljs-operator">!</span>
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">size</span>() -&gt; <span class="hljs-type">Int</span> {
        elements.count
    }
}

<span class="hljs-keyword">var</span> ss <span class="hljs-operator">=</span> <span class="hljs-type">StringStack</span>()
ss.push(<span class="hljs-string">"Jack"</span>)
ss.push(<span class="hljs-string">"Rose"</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="2">
<li>协议中可以拥有多个关联类型</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Stackable</span> {
    <span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Element</span>
    <span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Element2</span>
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">push</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">element</span>: <span class="hljs-type">Element</span>)
    <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">pop</span>() -&gt; <span class="hljs-type">Element</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">top</span>() -&gt; <span class="hljs-type">Element</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">size</span>() -&gt; <span class="hljs-type">Int</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-28">4. 类型约束</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> { }
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }

<span class="hljs-keyword">func</span> <span class="hljs-title function_">swapValues</span>&lt;<span class="hljs-type">T</span>: <span class="hljs-type">Person</span> &amp; <span class="hljs-type">Runnable</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">a</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">T</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">b</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">T</span>) {
(a, b) <span class="hljs-operator">=</span> (b, a)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Stackable</span> {
<span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Element</span>: <span class="hljs-type">Equatable</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Stack</span>&lt;<span class="hljs-title class_">E</span>: <span class="hljs-title class_">Equatable</span>&gt;: <span class="hljs-title class_">Stackable</span> {
<span class="hljs-keyword">typealias</span> <span class="hljs-type">Element</span> <span class="hljs-operator">=</span> <span class="hljs-type">E</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">equal</span>&lt;<span class="hljs-type">S1</span>: <span class="hljs-type">Stackable</span>, <span class="hljs-type">S2</span>: <span class="hljs-type">Stackable</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">s1</span>: <span class="hljs-type">S1</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">s2</span>: <span class="hljs-type">S2</span>) -&gt; <span class="hljs-type">Bool</span> <span class="hljs-keyword">where</span> <span class="hljs-type">S1</span>.<span class="hljs-type">Element</span> <span class="hljs-operator">==</span> <span class="hljs-type">S2</span>.<span class="hljs-type">Element</span>, <span class="hljs-type">S1</span>.<span class="hljs-type">Element</span> : <span class="hljs-type">Hashable</span> {
 <span class="hljs-keyword">return</span> <span class="hljs-literal">false</span>
}

<span class="hljs-keyword">var</span> stack1 <span class="hljs-operator">=</span> <span class="hljs-type">Stack</span>&lt;<span class="hljs-type">Int</span>&gt;()
<span class="hljs-keyword">var</span> stack2 <span class="hljs-operator">=</span> <span class="hljs-type">Stack</span>&lt;<span class="hljs-type">String</span>&gt;()
equal(stack1, stack2) 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-29">5. 协议类型的注意点</h2>
<p>看下面的示例代码来分析</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> { }
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Runnable</span> { }
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span>: <span class="hljs-title class_">Runnable</span> { }

<span class="hljs-keyword">func</span> <span class="hljs-title function_">get</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">type</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Runnable</span> {
<span class="hljs-keyword">if</span> type <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
    <span class="hljs-keyword">return</span> <span class="hljs-type">Person</span>()
}

<span class="hljs-keyword">return</span> <span class="hljs-type">Car</span>()
}

<span class="hljs-keyword">var</span> r1 <span class="hljs-operator">=</span> <span class="hljs-keyword">get</span>(<span class="hljs-number">0</span>)
<span class="hljs-keyword">var</span> r2 <span class="hljs-operator">=</span> <span class="hljs-keyword">get</span>(<span class="hljs-number">1</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>如果协议中有<code>associatedtype</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
<span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Speed</span>
<span class="hljs-keyword">var</span> speed: <span class="hljs-type">Speed</span> { <span class="hljs-keyword">get</span> }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Runnable</span> {
<span class="hljs-keyword">var</span> speed: <span class="hljs-type">Double</span> { <span class="hljs-number">0.0</span> }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span>: <span class="hljs-title class_">Runnable</span> {
<span class="hljs-keyword">var</span> speed: <span class="hljs-type">Int</span> { <span class="hljs-number">0</span> }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>这样写会报错，因为无法在编译阶段知道<code>Speed</code>的真实类型是什么
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/efce02a4842a49258ed91629e11c620f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w638" loading="lazy" class="medium-zoom-image"></li>
<li>可以用泛型来解决</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Speed</span>
    <span class="hljs-keyword">var</span> speed: <span class="hljs-type">Speed</span> { <span class="hljs-keyword">get</span> }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">var</span> speed: <span class="hljs-type">Double</span> { <span class="hljs-number">0.0</span> }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span>: <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">var</span> speed: <span class="hljs-type">Int</span> { <span class="hljs-number">0</span> }
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">get</span>&lt;<span class="hljs-type">T</span>: <span class="hljs-type">Runnable</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">type</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">T</span> {
    <span class="hljs-keyword">if</span> type <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
        <span class="hljs-keyword">return</span> <span class="hljs-type">Person</span>() <span class="hljs-keyword">as!</span> <span class="hljs-type">T</span>
    }

    <span class="hljs-keyword">return</span> <span class="hljs-type">Car</span>() <span class="hljs-keyword">as!</span> <span class="hljs-type">T</span>
}

<span class="hljs-keyword">var</span> r1: <span class="hljs-type">Person</span> <span class="hljs-operator">=</span> <span class="hljs-keyword">get</span>(<span class="hljs-number">0</span>)
<span class="hljs-keyword">var</span> r2: <span class="hljs-type">Car</span> <span class="hljs-operator">=</span> <span class="hljs-keyword">get</span>(<span class="hljs-number">1</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>还可以使用<code>some</code>关键字声明一个<code>不透明类型</code></li>
<li><code>some</code>限制只能返回一种类型</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Speed</span>
    <span class="hljs-keyword">var</span> speed: <span class="hljs-type">Speed</span> { <span class="hljs-keyword">get</span> }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">var</span> speed: <span class="hljs-type">Double</span> { <span class="hljs-number">0.0</span> }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Car</span>: <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">var</span> speed: <span class="hljs-type">Int</span> { <span class="hljs-number">0</span> }
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">get</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">type</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-keyword">some</span> <span class="hljs-type">Runnable</span> {
    <span class="hljs-keyword">return</span> <span class="hljs-type">Car</span>()
}

<span class="hljs-keyword">var</span> r1 <span class="hljs-operator">=</span> <span class="hljs-keyword">get</span>(<span class="hljs-number">0</span>)
<span class="hljs-keyword">var</span> r2 <span class="hljs-operator">=</span> <span class="hljs-keyword">get</span>(<span class="hljs-number">1</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>some</code>除了用在返回值类型上，一般还可以用在属性类型上</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Speed</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span>: <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">typealias</span> <span class="hljs-type">Speed</span> <span class="hljs-operator">=</span> <span class="hljs-type">Double</span>
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> pet: <span class="hljs-keyword">some</span> <span class="hljs-type">Runnable</span> {
        <span class="hljs-keyword">return</span> <span class="hljs-type">Dog</span>()
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-30">6. 泛型的本质</h2>
<ul>
<li>我们通过下面的示例代码来分析其内部具体是怎样实现的</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">swapValues</span>&lt;<span class="hljs-type">T</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">a</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">T</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">b</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">T</span>) {
    (a, b) <span class="hljs-operator">=</span> (b, a)
}

<span class="hljs-keyword">var</span> i1 <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> i2 <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
<span class="hljs-built_in">swap</span>(<span class="hljs-operator">&amp;</span>i1, <span class="hljs-operator">&amp;</span>i2)
<span class="hljs-built_in">print</span>(i1, i2) <span class="hljs-comment">// 20, 10</span>

<span class="hljs-keyword">var</span> d1 <span class="hljs-operator">=</span> <span class="hljs-number">10.0</span>
<span class="hljs-keyword">var</span> d2 <span class="hljs-operator">=</span> <span class="hljs-number">20.0</span>
<span class="hljs-built_in">swap</span>(<span class="hljs-operator">&amp;</span>d1, <span class="hljs-operator">&amp;</span>d2)
<span class="hljs-built_in">print</span>(d1, d2) <span class="hljs-comment">// 20.0, 10.0 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>反汇编之后
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/281c636f9b5b4cbba84bea1f8833610d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1000" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/423e799fe8324208b6a7ec356a5c90ef~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1002" loading="lazy" class="medium-zoom-image"></li>
<li>从调用两个交换方法来看，最终调用的都是同一个函数，因为函数地址是一样的；</li>
<li>但不同的是分别会将<code>Int的metadata</code>和<code>Double的metadata</code>作为参数传递进去</li>
<li>所以推测<code>metadata</code>中应该分别指明对应的类型来做处理</li>
</ul>
<h2 data-id="heading-31">7. 可选项的本质</h2>
<ul>
<li>
<ol>
<li>可选项的本质的本质是<code>enum</code>类型</li>
</ol>
</li>
<li>
<ol start="2">
<li>我们可以进到头文件中查看
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4e338908efc74aa6b8f35758510ebafa~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1034" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>我们平时写的语法糖的真正写法如下:</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

本质写法如下：
<span class="hljs-keyword">var</span> ageOpt0: <span class="hljs-type">Optional</span>&lt;<span class="hljs-type">Int</span>&gt; <span class="hljs-operator">=</span> <span class="hljs-type">Optional</span>&lt;<span class="hljs-type">Int</span>&gt;.some(<span class="hljs-number">10</span>)
<span class="hljs-keyword">var</span> ageOpt1: <span class="hljs-type">Optional</span> <span class="hljs-operator">=</span> .some(<span class="hljs-number">10</span>)
<span class="hljs-keyword">var</span> ageOpt2 <span class="hljs-operator">=</span> <span class="hljs-type">Optional</span>.some(<span class="hljs-number">10</span>)
<span class="hljs-keyword">var</span> ageOpt3 <span class="hljs-operator">=</span> <span class="hljs-type">Optional</span>(<span class="hljs-number">10</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>

本质写法如下：
<span class="hljs-keyword">var</span> ageOpt0: <span class="hljs-type">Optional</span>&lt;<span class="hljs-type">Int</span>&gt; <span class="hljs-operator">=</span> .none
<span class="hljs-keyword">var</span> ageOpt1 <span class="hljs-operator">=</span> <span class="hljs-type">Optional</span>&lt;<span class="hljs-type">Int</span>&gt;.none 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> .none
age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
age <span class="hljs-operator">=</span> .some(<span class="hljs-number">20</span>)
age <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li>switch中可选项的使用</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">switch</span> age {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> v<span class="hljs-operator">?</span>: <span class="hljs-comment">// 加上?表示如果有值会解包赋值给v</span>
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"some"</span>, v)
<span class="hljs-keyword">case</span> <span class="hljs-literal">nil</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"none"</span>)
}

<span class="hljs-keyword">switch</span> age {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> .some(v):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"some"</span>, v)
<span class="hljs-keyword">case</span> .none:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"none"</span>)
}
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li>多重可选项</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age_: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>?? <span class="hljs-operator">=</span> age_
age <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>

<span class="hljs-keyword">var</span> age0 <span class="hljs-operator">=</span> <span class="hljs-type">Optional</span>.some(<span class="hljs-type">Optional</span>.some(<span class="hljs-number">10</span>))
age0 <span class="hljs-operator">=</span> .none
<span class="hljs-keyword">var</span> age1: <span class="hljs-type">Optional</span>&lt;<span class="hljs-type">Optional</span>&gt; <span class="hljs-operator">=</span> .some(.some(<span class="hljs-number">10</span>))
age1 <span class="hljs-operator">=</span> .none 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>?? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> age0: <span class="hljs-type">Optional</span>&lt;<span class="hljs-type">Optional</span>&gt; <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-32">六、内存管理</h1>
<h2 data-id="heading-33">1. 基本概念</h2>
<ul>
<li>跟<code>OC</code>一样，Swift也是采取基于<code>引用计数的ARC</code>内存管理方案（<code>针对堆空间</code>）</li>
<li>Swift的ARC中有三种引用:</li>
<li>a. <strong>强引用（strong reference）</strong> ： 默认情况下，引用都是强引用
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }
<span class="hljs-keyword">var</span> po: <span class="hljs-type">Person</span>? 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>b. <strong>弱引用（weak reference）</strong> ：通过<code>weak</code>定义弱引用
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }
<span class="hljs-keyword">weak</span> <span class="hljs-keyword">var</span> po: <span class="hljs-type">Person</span>? 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<p>必须是可选类型的<code>var</code>，因为实例销毁后，ARC会自动将弱引用设置为<code>nil</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/96b77e643805422dbe1fc1674df9988c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w634" loading="lazy" class="medium-zoom-image"></p>
</li>
<li>
<p>ARC自动给弱引用设置<code>nil</code>时，不会触发属性观察器</p>
</li>
</ul>
</li>
<li>c. <strong>无主引用（unowned reference）</strong> ： 通过<code>unowned</code>定义无主引用<br>
不会产生强引用，实例销毁后仍然存储着实例的内存地址（类似于<code>OC</code>中的<code>unsafe_unretained</code>）
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }
<span class="hljs-keyword">unowned</span> <span class="hljs-keyword">var</span> po: <span class="hljs-type">Person</span>?
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>试图在实例销毁后访问无主引用，会产生运行时错误（野指针）</li>
</ul>
</li>
</ul>
<h2 data-id="heading-34">2. weak、unowned的使用限制</h2>
<ul>
<li>
<ol>
<li><code>weak、unowned</code>只能用在<code>类实例</code>上面</li>
</ol>
</li>
<li>
<ol start="2">
<li>只有<code>类</code>是存放在<code>堆空间</code>的，堆空间的内存是需要我们手动管理的</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Liveable</span>: <span class="hljs-title class_">AnyObject</span> { }
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> { }

<span class="hljs-keyword">weak</span> <span class="hljs-keyword">var</span> po: <span class="hljs-type">Person</span>?
<span class="hljs-keyword">weak</span> <span class="hljs-keyword">var</span> p1: <span class="hljs-type">AnyObject</span>?
<span class="hljs-keyword">weak</span> <span class="hljs-keyword">var</span> p2: <span class="hljs-type">Liveable</span>?

<span class="hljs-keyword">unowned</span> <span class="hljs-keyword">var</span> p10: <span class="hljs-type">Person</span>?
<span class="hljs-keyword">unowned</span> <span class="hljs-keyword">var</span> p11: <span class="hljs-type">AnyObject</span>?
<span class="hljs-keyword">unowned</span> <span class="hljs-keyword">var</span> p12: <span class="hljs-type">Liveable</span>? 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-35">3. Autoreleasepool</h2>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2423f7b20efc41a182c192968f2f029d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w628" loading="lazy" class="medium-zoom-image"></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
<span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
<span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>

<span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
    <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {}
}

autoreleasepool {
<span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>(age: <span class="hljs-number">20</span>, name: <span class="hljs-string">"Jack"</span>)
p.run()
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-36">4. 循环引用（Reference Cycle）</h2>
<ul>
<li>
<ol>
<li><code>weak、unowned</code>都能解决循环引用的问题，<code>unowned</code>要比<code>weak</code>少一些性能消耗</li>
</ol>
</li>
<li>
<ol start="2">
<li>在生命周期中可能会变为<code>nil</code>的使用<code>weak</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ae54ada24fdd4980826c095c975900c3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w649" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="3">
<li>初始化赋值后再也不会变为<code>nil</code>的使用<code>unowned</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cf3332da09bc4522ba39c957fe78014d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<h2 data-id="heading-37">5. 闭包的循环引用</h2>
<ul>
<li>
<ol>
<li>闭包表达式默认会对用到的外层对象产生额外的强引用（对外层对象进行了<code>retain</code>操作）</li>
</ol>
</li>
<li>
<ol start="2">
<li>下面代码会产生循环引用，导致Person对象无法释放（看不到Person的<code>deinit</code>被调用）</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> fn: (() -&gt; ())<span class="hljs-operator">?</span>
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() { <span class="hljs-built_in">print</span>(<span class="hljs-string">"run"</span>) }
    <span class="hljs-keyword">deinit</span> { <span class="hljs-built_in">print</span>(<span class="hljs-string">"deinit"</span>) }
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
    p.fn <span class="hljs-operator">=</span> { p.run() }
}

test() 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li>在闭包表达式的捕获列表声明<code>weak</code>或<code>unowned</code>引用，解决循环引用问题</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
    p.fn <span class="hljs-operator">=</span> {
        [<span class="hljs-keyword">weak</span> p] <span class="hljs-keyword">in</span>
        p<span class="hljs-operator">?</span>.run()
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    <span class="hljs-keyword">let</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
    p.fn <span class="hljs-operator">=</span> {
        [<span class="hljs-keyword">unowned</span> p] <span class="hljs-keyword">in</span>
        p.run()
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li>如果想在定义闭包属性的同时引用<code>self</code>，这个闭包必须是<code>lazy</code>的（因为在实例初始化完毕之后才能引用<code>self</code>）
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fd9d5910b51d48be8c9453ede114e27d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w645" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">lazy</span> <span class="hljs-keyword">var</span> fn: (() -&gt; ()) <span class="hljs-operator">=</span> {
        [<span class="hljs-keyword">weak</span> <span class="hljs-keyword">self</span>] <span class="hljs-keyword">in</span>
        <span class="hljs-keyword">self</span><span class="hljs-operator">?</span>.run()
    }

    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() { <span class="hljs-built_in">print</span>(<span class="hljs-string">"run"</span>) }
    <span class="hljs-keyword">deinit</span> { <span class="hljs-built_in">print</span>(<span class="hljs-string">"deinit"</span>) }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="5">
<li>闭包fn内部如果用到了实例成员（属性、方法），编译器会强制要求明确写出<code>self</code>
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1fcf107651554f919175ef073d648907~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>
<ol start="6">
<li>如果<code>lazy属性</code>是闭包调用的结果，那么不用考虑循环引用的问题（因为闭包调用后，闭包的生命周期就结束了）</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">lazy</span> <span class="hljs-keyword">var</span> getAge: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> {
        <span class="hljs-keyword">self</span>.age
    }()

    <span class="hljs-keyword">deinit</span> { <span class="hljs-built_in">print</span>(<span class="hljs-string">"deinit"</span>) }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-38">6. @escaping</h2>
<ul>
<li>
<ol>
<li>非逃逸闭包、逃逸闭包，一般都是<code>当做参数</code>传递给函数</li>
</ol>
</li>
<li>
<ol start="2">
<li>非逃逸闭包：闭包调用发生在函数结束前，闭包调用在函数作用域内</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">Fn</span> <span class="hljs-operator">=</span> () -&gt; ()

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">fn</span>: <span class="hljs-type">Fn</span>) { fn() }
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li>逃逸闭包：闭包有可能在函数结束后调用，闭包调用逃离了函数的作用域，需要通过<code>@escaping</code>声明</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">Fn</span> <span class="hljs-operator">=</span> () -&gt; ()

<span class="hljs-keyword">var</span> gFn: <span class="hljs-type">Fn</span>?
<span class="hljs-keyword">func</span> <span class="hljs-title function_">test2</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">fn</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Fn</span>) { gFn <span class="hljs-operator">=</span> fn }
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="4">
<li><code>DispatchQueue.global().async</code>也是一个逃逸闭包
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1ec645caee914960bfdc6c01b8ff915f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w605" loading="lazy" class="medium-zoom-image">
使用示例如下</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">import</span> Dispatch
<span class="hljs-keyword">typealias</span> <span class="hljs-type">Fn</span> <span class="hljs-operator">=</span> () -&gt; ()

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test3</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">fn</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Fn</span>) {
<span class="hljs-type">DispatchQueue</span>.global().async {
    fn()
}
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
<span class="hljs-keyword">var</span> fn: <span class="hljs-type">Fn</span>

<span class="hljs-comment">// fn是逃逸闭包</span>
<span class="hljs-keyword">init</span>(<span class="hljs-params">fn</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Fn</span>) {
    <span class="hljs-keyword">self</span>.fn <span class="hljs-operator">=</span> fn
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
    <span class="hljs-comment">// DispatchQueue.global().async也是一个逃逸闭包</span>
    <span class="hljs-comment">// 它用到了实例成员（属性、方法），编译器会强制要求明确写出self</span>
    <span class="hljs-type">DispatchQueue</span>.global().async {
        <span class="hljs-keyword">self</span>.fn()
    }
}
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="5">
<li>逃逸闭包不可以捕获<code>inout</code>参数<br>
看下面的示例
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/13af1d9ba59c440db4a5adbe2103ac9a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w646" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a29ee1f1c3b340c99961c7165c92062e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w644" loading="lazy" class="medium-zoom-image"></li>
</ol>
</li>
<li>如果逃逸闭包里捕获的是外面的局部变量的地址值，就会有局部变量已经不存在了之后才会执行逃逸闭包的情况，那么捕获的值就是不合理的</li>
<li>而非逃逸闭包是可以保证在局部变量的生命周期没有结束的时候就能够执行闭包的</li>
</ul>
<h2 data-id="heading-39">7. 内存访问冲突（Conflicting Access to Memory）</h2>
<p>内存访问冲突会在两个访问满足下列条件时发生：</p>
<ul>
<li><code>至少一个是写入</code>操作</li>
<li>它们访问的是<code>同一块内存</code></li>
<li>它们的<code>访问时间重叠</code>（比如在同一个函数内）</li>
</ul>
<ol>
<li>看下面示例，哪个会造成内存访问冲突</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">plus</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { num <span class="hljs-operator">+</span> <span class="hljs-number">1</span> }

<span class="hljs-keyword">var</span> number <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
number <span class="hljs-operator">=</span> plus(<span class="hljs-operator">&amp;</span>number)
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> step <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">increment</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) { num <span class="hljs-operator">+=</span> step }
increment(<span class="hljs-operator">&amp;</span>step) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>第一个不会造成<code>内存访问</code>冲突，第二个<code>会造成内存访问</code>冲突，并报错</li>
<li>因为在<code>num += step</code>中既访问了step的值，同时又进行了写入操作
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/13e0e749f3d84fa7a87497bcf9854523~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image">
解决方案如下</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> step <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">increment</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) { num <span class="hljs-operator">+=</span> step }

<span class="hljs-keyword">var</span> copyOfStep <span class="hljs-operator">=</span> step
increment(<span class="hljs-operator">&amp;</span>copyOfStep)
step <span class="hljs-operator">=</span> copyOfStep
<span class="copy-code-btn">复制代码</span></code></pre>
<p>2.看下面示例，哪个会造成内存访问冲突</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">balance</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">x</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">y</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Int</span>) {
<span class="hljs-keyword">let</span> sum <span class="hljs-operator">=</span> x <span class="hljs-operator">+</span> y
x <span class="hljs-operator">=</span> sum <span class="hljs-operator">/</span> <span class="hljs-number">2</span>
y <span class="hljs-operator">=</span> sum <span class="hljs-operator">-</span> x
}

<span class="hljs-keyword">var</span> num1 <span class="hljs-operator">=</span> <span class="hljs-number">42</span>
<span class="hljs-keyword">var</span> num2 <span class="hljs-operator">=</span> <span class="hljs-number">30</span>
balance(<span class="hljs-operator">&amp;</span>num1, <span class="hljs-operator">&amp;</span>num2) <span class="hljs-comment">// ok</span>
balance(<span class="hljs-operator">&amp;</span>num1, <span class="hljs-operator">&amp;</span>num1) <span class="hljs-comment">// Error</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>第一句执行不会报错，因为传进去的是两个变量的地址值，不会冲突</li>
<li>第二句会报错，传进去的都是同一个变量的地址值，而内部又同时进行了对num1的读写操作，所以会造成内存访问冲突</li>
<li>而且都不用运行，编译器直接就报错</li>
</ul>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6dfc7e4c8a4a4c3fac30b869db7d65c8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w635" loading="lazy" class="medium-zoom-image"></p>
<p>3.看下面示例，哪个会造成内存访问冲突</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Player</span> {
<span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>
<span class="hljs-keyword">var</span> health: <span class="hljs-type">Int</span>
<span class="hljs-keyword">var</span> energy: <span class="hljs-type">Int</span>

<span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">shareHealth</span>(<span class="hljs-params">with</span> <span class="hljs-params">teammate</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">Player</span>) {
    balance(<span class="hljs-operator">&amp;</span>teammate.health, <span class="hljs-operator">&amp;</span>health)
}
}

<span class="hljs-keyword">var</span> oscar <span class="hljs-operator">=</span> <span class="hljs-type">Player</span>(name: <span class="hljs-string">"Oscar"</span>, health: <span class="hljs-number">10</span>, energy: <span class="hljs-number">10</span>)
<span class="hljs-keyword">var</span> maria <span class="hljs-operator">=</span> <span class="hljs-type">Player</span>(name: <span class="hljs-string">"Maria"</span>, health: <span class="hljs-number">5</span>, energy: <span class="hljs-number">10</span>)
oscar.shareHealth(with: <span class="hljs-operator">&amp;</span>maria)
oscar.shareHealth(with: <span class="hljs-operator">&amp;</span>oscar)
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>第一句执行不会报错，第二句执行会报错</li>
<li>因为传入的地址都是同一个，会造成内存访问冲突，而且也是在编译阶段就直接报错了
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e1bf5017ac334ea085cf407349f5800e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w647" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p>4.看下面示例，哪个会造成内存访问冲突</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> tuple <span class="hljs-operator">=</span> (health: <span class="hljs-number">10</span>, energy: <span class="hljs-number">20</span>)

balance(<span class="hljs-operator">&amp;</span>tuple.health, <span class="hljs-operator">&amp;</span>tuple.energy)

<span class="hljs-keyword">var</span> holly <span class="hljs-operator">=</span> <span class="hljs-type">Player</span>(name: <span class="hljs-string">"Holly"</span>, health: <span class="hljs-number">10</span>, energy: <span class="hljs-number">10</span>)
balance(<span class="hljs-operator">&amp;</span>holly.health, <span class="hljs-operator">&amp;</span>holly.energy)
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>这两个都会报错，都是操作了同一个存储空间，同时进行了读写操作
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2ca2a3d6d91a43b298cfecdfb8f3e96a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w712" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p>如果下面的条件可以满足，就说明重叠访问结构体的属性是安全的</p>
<ul>
<li>你只访问实例存储属性，不是计算属性或者类属性</li>
<li>结构体是局部变量而非全局变量</li>
<li>结构体要么没有被闭包捕获，要么只被非逃逸闭包捕获</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift">    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
        <span class="hljs-keyword">var</span> tuple <span class="hljs-operator">=</span> (health: <span class="hljs-number">10</span>, energy: <span class="hljs-number">20</span>)
        balance(<span class="hljs-operator">&amp;</span>tuple.health, <span class="hljs-operator">&amp;</span>tuple.energy)

        <span class="hljs-keyword">var</span> holly <span class="hljs-operator">=</span> <span class="hljs-type">Player</span>(name: <span class="hljs-string">"Holly"</span>, health: <span class="hljs-number">10</span>, energy: <span class="hljs-number">10</span>)
        balance(<span class="hljs-operator">&amp;</span>holly.health, <span class="hljs-operator">&amp;</span>holly.energy)
    }

    test() 
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-40">七、指针</h1>
<h2 data-id="heading-41">1. 指针简介</h2>
<p>Swift中也有专门的指针类型，这些都被定性为“<code>Unsafe</code>“（不安全的）， 常见的有以下四种类型</p>
<ul>
<li><strong>UnsafePointer:</strong> 类似于<code>const Pointee *</code></li>
<li><strong>UnsafeMutablePointer:</strong> 类似于<code>Pointee *</code></li>
<li><strong>UnsafeRawPointer:</strong> 类似于<code>const void *</code></li>
<li><strong>UnsafeMutableRawPointer:</strong> 类似于<code>void *</code></li>
</ul>
<blockquote>
<p><strong>UnsafePointer、UnsafeMutablePointer</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">ptr</span>: <span class="hljs-type">UnsafeMutablePointer</span>&lt;<span class="hljs-type">Int</span>&gt;) {
ptr.pointee <span class="hljs-operator">+=</span> <span class="hljs-number">10</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test2</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">ptr</span>: <span class="hljs-type">UnsafePointer</span>&lt;<span class="hljs-type">Int</span>&gt;) {
<span class="hljs-built_in">print</span>(ptr.pointee)
}

test1(<span class="hljs-operator">&amp;</span>age)
test2(<span class="hljs-operator">&amp;</span>age) <span class="hljs-comment">// 20</span>
<span class="hljs-built_in">print</span>(age) <span class="hljs-comment">// 20  </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p><strong>UnsafeRawPointer、UnsafeMutableRawPointer</strong></p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span> 

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test3</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">ptr</span>: <span class="hljs-type">UnsafeMutableRawPointer</span>) {
ptr.storeBytes(of: <span class="hljs-number">30</span>, as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test4</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">ptr</span>: <span class="hljs-type">UnsafeRawPointer</span>) {
<span class="hljs-built_in">print</span>(ptr.load(as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>))
}

test3(<span class="hljs-operator">&amp;</span>age)
test4(<span class="hljs-operator">&amp;</span>age) <span class="hljs-comment">// 30</span>
<span class="hljs-built_in">print</span>(age) <span class="hljs-comment">// 30 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-42">2. 指针应用示例</h2>
<blockquote>
<p><strong><code>NSArray</code>的遍历方法中也使用了指针类型</strong></p>
</blockquote>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/77332c011f144a93afe938beac6ba27d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w545" loading="lazy" class="medium-zoom-image"></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> arr <span class="hljs-operator">=</span> <span class="hljs-type">NSArray</span>(objects: <span class="hljs-number">11</span>, <span class="hljs-number">22</span>, <span class="hljs-number">33</span>, <span class="hljs-number">44</span>)
arr.enumerateObjects { (obj, idx, stop) <span class="hljs-keyword">in</span>
<span class="hljs-built_in">print</span>(idx, obj)

<span class="hljs-keyword">if</span> idx <span class="hljs-operator">==</span> <span class="hljs-number">2</span> { <span class="hljs-comment">// 下标为2就停止遍历</span>
    stop.pointee <span class="hljs-operator">=</span> <span class="hljs-literal">true</span>
}

<span class="hljs-built_in">print</span>(<span class="hljs-string">"----"</span>)
}

<span class="hljs-comment">//0 11</span>
<span class="hljs-comment">//----</span>
<span class="hljs-comment">//1 22</span>
<span class="hljs-comment">//----</span>
<span class="hljs-comment">//2 33</span>
<span class="hljs-comment">//---- </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>arr.enumerateObjects</code>中的stop并不等同于<code>break</code>的作用，设置完stop也会继续执行完作用域中的代码，然后才会判断是否需要下一次循环</li>
<li>在Swift中遍历元素更适用于<code>enumerated</code>的方式</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> arr <span class="hljs-operator">=</span> <span class="hljs-type">NSArray</span>(objects: <span class="hljs-number">11</span>, <span class="hljs-number">22</span>, <span class="hljs-number">33</span>, <span class="hljs-number">44</span>)
<span class="hljs-keyword">for</span> (idx, obj) <span class="hljs-keyword">in</span> arr.enumerated() {
    <span class="hljs-built_in">print</span>(idx, obj)
    <span class="hljs-keyword">if</span> idx <span class="hljs-operator">==</span> <span class="hljs-number">2</span> { <span class="hljs-keyword">break</span> }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-43">3. 获得指向某个变量的指针</h2>
<ul>
<li>我们可以调用<code>withUnsafeMutablePointer、withUnsafePointer</code>来获得指向变量的指针</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">11</span>
<span class="hljs-keyword">var</span> ptr1 <span class="hljs-operator">=</span> <span class="hljs-built_in">withUnsafeMutablePointer</span>(to: <span class="hljs-operator">&amp;</span>age) { <span class="hljs-variable">$0</span> }
<span class="hljs-keyword">var</span> ptr2 <span class="hljs-operator">=</span> <span class="hljs-built_in">withUnsafePointer</span>(to: <span class="hljs-operator">&amp;</span>age) { <span class="hljs-variable">$0</span> }
ptr1.pointee <span class="hljs-operator">=</span> <span class="hljs-number">22</span>

<span class="hljs-built_in">print</span>(ptr2.pointee) <span class="hljs-comment">// 22</span>
<span class="hljs-built_in">print</span>(age) <span class="hljs-comment">// 22</span>

<span class="hljs-keyword">var</span> ptr3 <span class="hljs-operator">=</span> <span class="hljs-built_in">withUnsafeMutablePointer</span>(to: <span class="hljs-operator">&amp;</span>age) { <span class="hljs-type">UnsafeMutableRawPointer</span>(<span class="hljs-variable">$0</span>)}
<span class="hljs-keyword">var</span> ptr4 <span class="hljs-operator">=</span> <span class="hljs-built_in">withUnsafePointer</span>(to: <span class="hljs-operator">&amp;</span>age) { <span class="hljs-type">UnsafeRawPointer</span>(<span class="hljs-variable">$0</span>) }
ptr3.storeBytes(of: <span class="hljs-number">33</span>, as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)

<span class="hljs-built_in">print</span>(ptr4.load(as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// 33</span>
<span class="hljs-built_in">print</span>(age) <span class="hljs-comment">// 33 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>withUnsafeMutablePointer</code>的实现本质就是将传入的变量地址值放到闭包表达式中作为返回值</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">withUnsafeMutablePointer</span>&lt;<span class="hljs-type">Result</span>, <span class="hljs-type">T</span>&gt;(<span class="hljs-params">to</span> <span class="hljs-params">value</span>: <span class="hljs-keyword">inout</span> <span class="hljs-type">T</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">body</span>: (<span class="hljs-type">UnsafeMutablePointer</span>&lt;<span class="hljs-type">T</span>&gt;) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">Result</span>) <span class="hljs-keyword">rethrows</span> -&gt; <span class="hljs-type">Result</span> {
    <span class="hljs-keyword">try</span> body(<span class="hljs-operator">&amp;</span>value)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-44">4.  获得指向堆空间实例的指针</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}
<span class="hljs-keyword">var</span> person <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()

<span class="hljs-comment">// ptr中存储的还是person指针变量的地址值</span>
<span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> <span class="hljs-built_in">withUnsafePointer</span>(to: <span class="hljs-operator">&amp;</span>person) { <span class="hljs-type">UnsafeRawPointer</span>(<span class="hljs-variable">$0</span>) }
<span class="hljs-comment">// 从指针变量里取8个字节，也就是取出存储的堆空间地址值</span>
<span class="hljs-keyword">var</span> heapPtr <span class="hljs-operator">=</span> <span class="hljs-type">UnsafeRawPointer</span>(bitPattern: ptr.load(as: <span class="hljs-type">UInt</span>.<span class="hljs-keyword">self</span>))
<span class="hljs-built_in">print</span>(heapPtr<span class="hljs-operator">!</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-45">5.  创建指针</h2>
<blockquote>
<p>第一种方式</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> <span class="hljs-type">UnsafeRawPointer</span>(bitPattern: <span class="hljs-number">0x100001234</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p>第二种方式</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 创建</span>
<span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> malloc(<span class="hljs-number">16</span>)

<span class="hljs-comment">// 存</span>
ptr<span class="hljs-operator">?</span>.storeBytes(of: <span class="hljs-number">11</span>, as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)
ptr<span class="hljs-operator">?</span>.storeBytes(of: <span class="hljs-number">22</span>, toByteOffset: <span class="hljs-number">8</span>, as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)

<span class="hljs-comment">// 取</span>
<span class="hljs-built_in">print</span>(ptr<span class="hljs-operator">?</span>.load(as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// 11</span>
<span class="hljs-built_in">print</span>(ptr<span class="hljs-operator">?</span>.load(fromByteOffset: <span class="hljs-number">8</span>, as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// 22</span>

<span class="hljs-comment">// 销毁</span>
free(ptr) 
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p>第三种方式</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> <span class="hljs-type">UnsafeMutableRawPointer</span>.allocate(byteCount: <span class="hljs-number">16</span>, alignment: <span class="hljs-number">1</span>)

<span class="hljs-comment">// 从前8个字节开始存储11</span>
ptr.storeBytes(of: <span class="hljs-number">11</span>, as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)
<span class="hljs-comment">// 指向后8个字节开始存储22</span>
ptr.advanced(by: <span class="hljs-number">8</span>).storeBytes(of: <span class="hljs-number">22</span>, as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)

<span class="hljs-built_in">print</span>(ptr.load(as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// 11</span>
<span class="hljs-built_in">print</span>(ptr.advanced(by: <span class="hljs-number">8</span>).load(as: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// 22</span>
ptr.deallocate() 
<span class="copy-code-btn">复制代码</span></code></pre>
<blockquote>
<p>第四种方式</p>
</blockquote>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> <span class="hljs-type">UnsafeMutablePointer</span>&lt;<span class="hljs-type">Int</span>&gt;.allocate(capacity: <span class="hljs-number">3</span>)

<span class="hljs-comment">// 先初始化内存</span>
ptr.initialize(to: <span class="hljs-number">11</span>)
<span class="hljs-comment">// ptr.successor表示下一个Int，也就是跳一个类型字节大小</span>
ptr.successor().initialize(to: <span class="hljs-number">22</span>)
ptr.successor().successor().initialize(to: <span class="hljs-number">33</span>)

<span class="hljs-built_in">print</span>(ptr.pointee) <span class="hljs-comment">// 11</span>

<span class="hljs-comment">// ptr + 1，意味着跳过一个Int类型大小的字节数</span>
<span class="hljs-built_in">print</span>((ptr <span class="hljs-operator">+</span> <span class="hljs-number">1</span>).pointee) <span class="hljs-comment">// 22</span>
<span class="hljs-built_in">print</span>((ptr <span class="hljs-operator">+</span> <span class="hljs-number">2</span>).pointee) <span class="hljs-comment">// 33</span>

<span class="hljs-built_in">print</span>(ptr[<span class="hljs-number">0</span>]) <span class="hljs-comment">// 11</span>
<span class="hljs-built_in">print</span>(ptr[<span class="hljs-number">1</span>]) <span class="hljs-comment">// 22</span>
<span class="hljs-built_in">print</span>(ptr[<span class="hljs-number">2</span>]) <span class="hljs-comment">// 33</span>

<span class="hljs-comment">// 释放要调用反初始化，调用了几个就释放几个</span>
ptr.deinitialize(count: <span class="hljs-number">3</span>)
ptr.deallocate() 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {
<span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
<span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>
<span class="hljs-keyword">init</span>(<span class="hljs-params">age</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">name</span>: <span class="hljs-type">String</span>) {
    <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
}

<span class="hljs-keyword">deinit</span> {
    <span class="hljs-built_in">print</span>(name, <span class="hljs-string">"deinit"</span>)
}
}

<span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> <span class="hljs-type">UnsafeMutablePointer</span>&lt;<span class="hljs-type">Person</span>&gt;.allocate(capacity: <span class="hljs-number">3</span>)
ptr.initialize(to: <span class="hljs-type">Person</span>(age: <span class="hljs-number">10</span>, name: <span class="hljs-string">"Jack"</span>))
(ptr <span class="hljs-operator">+</span> <span class="hljs-number">1</span>).initialize(to: <span class="hljs-type">Person</span>(age: <span class="hljs-number">11</span>, name: <span class="hljs-string">"Rose"</span>))
(ptr <span class="hljs-operator">+</span> <span class="hljs-number">2</span>).initialize(to: <span class="hljs-type">Person</span>(age: <span class="hljs-number">12</span>, name: <span class="hljs-string">"Kate"</span>))

ptr.deinitialize(count: <span class="hljs-number">3</span>)
ptr.deallocate() 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-46">6. 指针之间的转换</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> <span class="hljs-type">UnsafeMutableRawPointer</span>.allocate(byteCount: <span class="hljs-number">16</span>, alignment: <span class="hljs-number">1</span>)
<span class="hljs-comment">// 假想一个类型</span>
ptr.assumingMemoryBound(to: <span class="hljs-type">Int</span>.<span class="hljs-keyword">self</span>)
<span class="hljs-comment">// 不确定类型的pointer+8是真的加8个字节，不同于有类型的pointer</span>
(ptr <span class="hljs-operator">+</span> <span class="hljs-number">8</span>).assumingMemoryBound(to: <span class="hljs-type">Double</span>.<span class="hljs-keyword">self</span>).pointee <span class="hljs-operator">=</span> <span class="hljs-number">22.0</span>

<span class="hljs-comment">// 强制转换类型为Int</span>
<span class="hljs-built_in">print</span>(<span class="hljs-built_in">unsafeBitCast</span>(ptr, to: <span class="hljs-type">UnsafePointer</span>&lt;<span class="hljs-type">Int</span>&gt;.<span class="hljs-keyword">self</span>).pointee) <span class="hljs-comment">// 11</span>
<span class="hljs-built_in">print</span>(<span class="hljs-built_in">unsafeBitCast</span>((ptr <span class="hljs-operator">+</span> <span class="hljs-number">8</span>), to: <span class="hljs-type">UnsafePointer</span>&lt;<span class="hljs-type">Double</span>&gt;.<span class="hljs-keyword">self</span>).pointee) <span class="hljs-comment">// 22.0</span>

ptr.deallocate() 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>unsafeBitCast</code>是忽略数据类型的强制转换，不会因为数据类型的变化而改变原来的内存数据，所以这种转换也是不安全的</li>
<li>类似于<code>C++</code>中的<code>reinterpret_cast</code></li>
<li>我们可以用<code>unsafeBitCast</code>的强制转换指针类型，直接将person变量里存储的堆空间地址值拷贝到ptr指针变量中，由于ptr是指针类型，那么它所指向的地址值就是堆空间地址</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}
<span class="hljs-keyword">var</span> person <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> <span class="hljs-built_in">unsafeBitCast</span>(person, to: <span class="hljs-type">UnsafeRawPointer</span>.<span class="hljs-keyword">self</span>)
<span class="hljs-built_in">print</span>(ptr) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>另一个转换方式，可以先转成<code>UInt类型</code>的变量，然后再从变量中取出存储的地址值</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}
<span class="hljs-keyword">var</span> person <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-keyword">var</span> address <span class="hljs-operator">=</span> <span class="hljs-built_in">unsafeBitCast</span>(person, to: <span class="hljs-type">UInt</span>.<span class="hljs-keyword">self</span>)
<span class="hljs-keyword">var</span> ptr <span class="hljs-operator">=</span> <span class="hljs-type">UnsafeRawPointer</span>(bitPattern: address) 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>看下面的示例
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3541f61318f34cf1be6e18394cba135c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w944" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li><code>Int</code>和<code>Double</code>的内存结构应该是有差异的，但通过<code>unsafeBitCast</code>转换的age3的内存结构和age1是一样的，所以说<code>unsafeBitCast</code>只会转换数据类型，不会改变内存数据</li>
</ul>
<h1 data-id="heading-47">八、字面量（Literal）</h1>
<h2 data-id="heading-48">1.基本概念</h2>
<ul>
<li>下面代码中的<code>10、false、"Jack"</code>就是字面量</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> isRed <span class="hljs-operator">=</span> <span class="hljs-literal">false</span>
<span class="hljs-keyword">var</span> name <span class="hljs-operator">=</span> <span class="hljs-string">"Jack"</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>常见字面量的默认类型
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95680f960f7a4430b437754b0ce8567b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w507" loading="lazy" class="medium-zoom-image"></li>
<li>可以通过<code>typealias</code>修改字面量的默认类型</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">typealias</span> <span class="hljs-type">FloatLiteralType</span> <span class="hljs-operator">=</span> <span class="hljs-type">Float</span>
<span class="hljs-keyword">typealias</span> <span class="hljs-type">IntegerLiteralType</span> <span class="hljs-operator">=</span> <span class="hljs-type">UInt8</span>
<span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span> <span class="hljs-comment">// UInt8</span>
<span class="hljs-keyword">var</span> height <span class="hljs-operator">=</span> <span class="hljs-number">1.68</span> <span class="hljs-comment">// Float</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>Swift自带的绝大部分类型、都支持直接通过字面量进行初始化</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-type">Bool</span><span class="hljs-operator">、</span><span class="hljs-type">Int</span><span class="hljs-operator">、</span><span class="hljs-type">Float</span><span class="hljs-operator">、</span><span class="hljs-type">Double</span><span class="hljs-operator">、</span><span class="hljs-type">String</span><span class="hljs-operator">、</span><span class="hljs-type">Array</span><span class="hljs-operator">、</span><span class="hljs-type">Dictionary</span><span class="hljs-operator">、</span><span class="hljs-type">Set</span><span class="hljs-operator">、</span><span class="hljs-type">Optional等</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-49">2. 字面量协议</h2>
<p>Swift自带类型之所以能够通过字面量初始化，是因为它们遵守了对应的协议</p>
<ul>
<li>Bool: <code>ExpressibleByBooleanLiteral</code></li>
<li>Int: <code>ExpressibleByIntegerLiteral</code></li>
<li>Float、Double: <code>ExpressibleByIntegerLiteral、ExpressibleByFloatLiteral</code></li>
<li>String: <code>ExpressibleByStringLiteral</code></li>
<li>Array、Set: <code>ExpressibleByArrayLiteral</code></li>
<li>Dictionary: <code>ExpressibleByDictionaryLiteral</code></li>
<li>Optional: <code>ExpressibleByNilLiteral</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> b: <span class="hljs-type">Bool</span> <span class="hljs-operator">=</span> <span class="hljs-literal">false</span> <span class="hljs-comment">// ExpressibleByBooleanLiteral</span>
<span class="hljs-keyword">var</span> i: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span> <span class="hljs-comment">// ExpressibleByIntegerLiteral</span>
<span class="hljs-keyword">var</span> f0: <span class="hljs-type">Float</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span> <span class="hljs-comment">// ExpressibleByIntegerLiteral</span>
<span class="hljs-keyword">var</span> f1: <span class="hljs-type">Float</span> <span class="hljs-operator">=</span> <span class="hljs-number">10.0</span> <span class="hljs-comment">// ExpressibleByFloatLiteral</span>
<span class="hljs-keyword">var</span> d0: <span class="hljs-type">Double</span> <span class="hljs-operator">=</span> <span class="hljs-number">10</span> <span class="hljs-comment">// ExpressibleByIntegerLiteral</span>
<span class="hljs-keyword">var</span> d1: <span class="hljs-type">Double</span> <span class="hljs-operator">=</span> <span class="hljs-number">10.0</span> <span class="hljs-comment">// ExpressibleByFloatLiteral</span>
<span class="hljs-keyword">var</span> s: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">"jack"</span> <span class="hljs-comment">// ExpressibleByStringLiteral</span>
<span class="hljs-keyword">var</span> arr: <span class="hljs-type">Array</span> <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>] <span class="hljs-comment">// ExpressibleByArrayLiteral</span>
<span class="hljs-keyword">var</span> <span class="hljs-keyword">set</span>: <span class="hljs-type">Set</span> <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>] <span class="hljs-comment">// ExpressibleByArrayLiteral</span>
<span class="hljs-keyword">var</span> dict: <span class="hljs-type">Dictionary</span> <span class="hljs-operator">=</span> [<span class="hljs-string">"jack"</span> : <span class="hljs-number">60</span>] <span class="hljs-comment">// ExpressibleByDictionaryLiteral</span>
<span class="hljs-keyword">var</span> o: <span class="hljs-type">Optional</span>&lt;<span class="hljs-type">Int</span>&gt; <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span> <span class="hljs-comment">// ExpressibleByNilLiteral</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-50">3.字面量协议应用</h2>
<p>有点类似于<code>C++</code>中的<code>转换构造函数</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Int</span>: <span class="hljs-title class_">ExpressibleByBooleanLiteral</span> {
<span class="hljs-keyword">public</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">booleanLiteral</span> <span class="hljs-params">value</span>: <span class="hljs-type">Bool</span>) {
    <span class="hljs-keyword">self</span> <span class="hljs-operator">=</span> value <span class="hljs-operator">?</span> <span class="hljs-number">1</span> : <span class="hljs-number">0</span>
}
}

<span class="hljs-keyword">var</span> num: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-literal">true</span>
<span class="hljs-built_in">print</span>(num) <span class="hljs-comment">// 1 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Student</span>: <span class="hljs-title class_">ExpressibleByIntegerLiteral</span>, <span class="hljs-title class_">ExpressibleByFloatLiteral</span>, <span class="hljs-title class_">ExpressibleByStringLiteral</span>, <span class="hljs-title class_">CustomDebugStringConvertible</span> {
<span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">""</span>
<span class="hljs-keyword">var</span> score: <span class="hljs-type">Double</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>

<span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">floatLiteral</span> <span class="hljs-params">value</span>: <span class="hljs-type">Double</span>) {
    <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> value
}

<span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">integerLiteral</span> <span class="hljs-params">value</span>: <span class="hljs-type">Int</span>) {
    <span class="hljs-keyword">self</span>.score <span class="hljs-operator">=</span> <span class="hljs-type">Double</span>(value)
}

<span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">stringLiteral</span> <span class="hljs-params">value</span>: <span class="hljs-type">String</span>) {
    <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> value
}

<span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">unicodeScalarLiteral</span> <span class="hljs-params">value</span>: <span class="hljs-type">String</span>) {
    <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> value
}

<span class="hljs-keyword">required</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">extendedGraphemeClusterLiteral</span> <span class="hljs-params">value</span>: <span class="hljs-type">String</span>) {
    <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> value
}

<span class="hljs-keyword">var</span> debugDescription: <span class="hljs-type">String</span> {
    <span class="hljs-string">"name=(name), score=(score)"</span>
}
}

<span class="hljs-keyword">var</span> stu: <span class="hljs-type">Student</span> <span class="hljs-operator">=</span> <span class="hljs-number">90</span>
<span class="hljs-built_in">print</span>(stu) <span class="hljs-comment">// name=, score=90.0</span>

stu <span class="hljs-operator">=</span> <span class="hljs-number">98.5</span>
<span class="hljs-built_in">print</span>(stu) <span class="hljs-comment">// name=, score=98.5</span>

stu <span class="hljs-operator">=</span> <span class="hljs-string">"Jack"</span>
<span class="hljs-built_in">print</span>(stu) <span class="hljs-comment">// name=Jack, score=0.0 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Point</span> {
<span class="hljs-keyword">var</span> x <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>, y <span class="hljs-operator">=</span> <span class="hljs-number">0.0</span>
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Point</span>: <span class="hljs-title class_">ExpressibleByArrayLiteral</span>, <span class="hljs-title class_">ExpressibleByDictionaryLiteral</span> {
<span class="hljs-keyword">init</span>(<span class="hljs-params">arrayLiteral</span> <span class="hljs-params">elements</span>: <span class="hljs-type">Double</span>...) {
    <span class="hljs-keyword">guard</span> elements.count <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span> <span class="hljs-keyword">else</span> { <span class="hljs-keyword">return</span> }
    <span class="hljs-keyword">self</span>.x <span class="hljs-operator">=</span> elements[<span class="hljs-number">0</span>]

    <span class="hljs-keyword">guard</span> elements.count <span class="hljs-operator">&gt;</span> <span class="hljs-number">1</span> <span class="hljs-keyword">else</span> { <span class="hljs-keyword">return</span> }
    <span class="hljs-keyword">self</span>.y <span class="hljs-operator">=</span> elements[<span class="hljs-number">1</span>]
}

<span class="hljs-keyword">init</span>(<span class="hljs-params">dictionaryLiteral</span> <span class="hljs-params">elements</span>: (<span class="hljs-type">String</span>, <span class="hljs-type">Double</span>)<span class="hljs-operator">...</span>) {
    <span class="hljs-keyword">for</span> (k, v) <span class="hljs-keyword">in</span> elements {
        <span class="hljs-keyword">if</span> k <span class="hljs-operator">==</span> <span class="hljs-string">"x"</span> { <span class="hljs-keyword">self</span>.x <span class="hljs-operator">=</span> v }
        <span class="hljs-keyword">else</span> <span class="hljs-keyword">if</span> k <span class="hljs-operator">==</span> <span class="hljs-string">"y"</span> { <span class="hljs-keyword">self</span>.y <span class="hljs-operator">=</span> v }
    }
}
}

<span class="hljs-keyword">var</span> p: <span class="hljs-type">Point</span> <span class="hljs-operator">=</span> [<span class="hljs-number">10.5</span>, <span class="hljs-number">20.5</span>]
<span class="hljs-built_in">print</span>(p) <span class="hljs-comment">// Point(x: 10.5, y: 20.5)</span>

p <span class="hljs-operator">=</span> [<span class="hljs-string">"x"</span> : <span class="hljs-number">11</span>, <span class="hljs-string">"y"</span> : <span class="hljs-number">22</span>]
<span class="hljs-built_in">print</span>(p) <span class="hljs-comment">// Point(x: 11.0, y: 22.0) </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-51">九、模式匹配（Pattern）</h1>
<h2 data-id="heading-52">1. 基本概念</h2>
<blockquote>
<p><strong>什么是模式？</strong></p>
</blockquote>
<ul>
<li>模式是用于匹配的规则，比如<code>switch的case、捕捉错误的catch、if\guard\while\for语句的条件</code>等</li>
</ul>
<p>Swift中的模式有</p>
<ul>
<li>通配符模式（Wildcard Pattern）</li>
<li>标识符模式（Identifier Pattern）</li>
<li>值绑定模式（Value-Binding Pattern）</li>
<li>元组模式（Tuple Pattern）</li>
<li>枚举Case模式（Enumeration Case Pattern）</li>
<li>可选模式（Optional Pattern）</li>
<li>类型转换模式（Type-Casting Pattern）</li>
<li>表达式模式（Expression Pattern）</li>
</ul>
<h2 data-id="heading-53">2. 通配符模式（Wildcard Pattern）</h2>
<ul>
<li><code>_</code>匹配任何值</li>
<li><code>_?</code>匹配非<code>nil</code>值</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">Life</span> {
<span class="hljs-keyword">case</span> human(name: <span class="hljs-type">String</span>, age: <span class="hljs-type">Int</span>?)
<span class="hljs-keyword">case</span> animal(name: <span class="hljs-type">String</span>, age: <span class="hljs-type">Int</span>?)
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">check</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">life</span>: <span class="hljs-type">Life</span>) {
<span class="hljs-keyword">switch</span> life {
<span class="hljs-keyword">case</span> .human(<span class="hljs-keyword">let</span> name, <span class="hljs-keyword">_</span>):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"human"</span>, name)
<span class="hljs-keyword">case</span> .animal(<span class="hljs-keyword">let</span> name, <span class="hljs-keyword">_</span><span class="hljs-operator">?</span>):
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"animal"</span>, name)
<span class="hljs-keyword">default</span>:
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"other"</span>)
}
}

check(.human(name: <span class="hljs-string">"Rose"</span>, age: <span class="hljs-number">20</span>)) <span class="hljs-comment">// human Rose</span>
check(.human(name: <span class="hljs-string">"Jack"</span>, age: <span class="hljs-literal">nil</span>)) <span class="hljs-comment">// human Jack</span>
check(.animal(name: <span class="hljs-string">"Dog"</span>, age: <span class="hljs-number">5</span>)) <span class="hljs-comment">// animal Dog</span>
check(.animal(name: <span class="hljs-string">"Cat"</span>, age: <span class="hljs-literal">nil</span>)) <span class="hljs-comment">// other</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-54">2.标识符模式（Identifier Pattern）</h2>
<p>给对应的变量、常量名赋值</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">let</span> name <span class="hljs-operator">=</span> <span class="hljs-string">"jack"</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-55">3.值绑定模式（Value-Binding Pattern）</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> point <span class="hljs-operator">=</span> (<span class="hljs-number">3</span>, <span class="hljs-number">2</span>)
<span class="hljs-keyword">switch</span> point {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (x, y):
<span class="hljs-built_in">print</span>(<span class="hljs-string">"The point is at ((x), (y)."</span>)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-56">4.元组模式（Tuple Pattern）</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> points <span class="hljs-operator">=</span> [(<span class="hljs-number">0</span>, <span class="hljs-number">0</span>), (<span class="hljs-number">1</span>, <span class="hljs-number">0</span>), (<span class="hljs-number">2</span>, <span class="hljs-number">0</span>)]
<span class="hljs-keyword">for</span> (x, <span class="hljs-keyword">_</span>) <span class="hljs-keyword">in</span> points {
<span class="hljs-built_in">print</span>(x)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> name: <span class="hljs-type">String</span>? <span class="hljs-operator">=</span> <span class="hljs-string">"jack"</span>
<span class="hljs-keyword">let</span> age <span class="hljs-operator">=</span> <span class="hljs-number">18</span>
<span class="hljs-keyword">let</span> info: <span class="hljs-keyword">Any</span> <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>]
<span class="hljs-keyword">switch</span> (name, age, info) {
<span class="hljs-keyword">case</span> (<span class="hljs-keyword">_</span><span class="hljs-operator">?</span>, <span class="hljs-keyword">_</span>, <span class="hljs-keyword">_</span> <span class="hljs-keyword">as</span> <span class="hljs-type">String</span>):
<span class="hljs-built_in">print</span>(<span class="hljs-string">"case"</span>)
<span class="hljs-keyword">default</span>:
<span class="hljs-built_in">print</span>(<span class="hljs-string">"default"</span>)
} <span class="hljs-comment">// default </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> scores <span class="hljs-operator">=</span> [<span class="hljs-string">"jack"</span> : <span class="hljs-number">98</span>, <span class="hljs-string">"rose"</span> : <span class="hljs-number">100</span>, <span class="hljs-string">"kate"</span> : <span class="hljs-number">86</span>]
<span class="hljs-keyword">for</span> (name, score) <span class="hljs-keyword">in</span> scores {
<span class="hljs-built_in">print</span>(name, score)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-57">5. 枚举Case模式（Enumeration Case Pattern）</h2>
<ul>
<li><code>if case</code>语句等价于只有1个<code>case</code>的<code>switch</code>语句</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> age <span class="hljs-operator">=</span> <span class="hljs-number">2</span>

<span class="hljs-comment">// 原来的写法</span>
<span class="hljs-keyword">if</span> age <span class="hljs-operator">&gt;=</span> <span class="hljs-number">0</span> <span class="hljs-operator">&amp;&amp;</span> age <span class="hljs-operator">&lt;=</span> <span class="hljs-number">9</span> {
<span class="hljs-built_in">print</span>(<span class="hljs-string">"[0, 9]"</span>)
}

<span class="hljs-comment">// 枚举Case模式</span>
<span class="hljs-keyword">if</span> <span class="hljs-keyword">case</span> <span class="hljs-number">0</span><span class="hljs-operator">...</span><span class="hljs-number">9</span> <span class="hljs-operator">=</span> age {
<span class="hljs-built_in">print</span>(<span class="hljs-string">"[0, 9]"</span>)
}

<span class="hljs-keyword">guard</span> <span class="hljs-keyword">case</span> <span class="hljs-number">0</span><span class="hljs-operator">...</span><span class="hljs-number">9</span> <span class="hljs-operator">=</span> age <span class="hljs-keyword">else</span> { <span class="hljs-keyword">return</span> }
<span class="hljs-built_in">print</span>(<span class="hljs-string">"[0, 9]"</span>)

<span class="hljs-comment">// 等同于switch case</span>
<span class="hljs-keyword">switch</span> age {
<span class="hljs-keyword">case</span> <span class="hljs-number">0</span><span class="hljs-operator">...</span><span class="hljs-number">9</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"[0, 9]"</span>)
<span class="hljs-keyword">default</span>: <span class="hljs-keyword">break</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> ages: [<span class="hljs-type">Int</span>?] <span class="hljs-operator">=</span> [<span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-literal">nil</span>, <span class="hljs-number">5</span>]
<span class="hljs-keyword">for</span> <span class="hljs-keyword">case</span> <span class="hljs-literal">nil</span> <span class="hljs-keyword">in</span> ages {
<span class="hljs-built_in">print</span>(<span class="hljs-string">"有nil值"</span>)
<span class="hljs-keyword">break</span>
} <span class="hljs-comment">// 有nil值 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> points <span class="hljs-operator">=</span> [(<span class="hljs-number">1</span>, <span class="hljs-number">0</span>), (<span class="hljs-number">2</span>, <span class="hljs-number">1</span>), (<span class="hljs-number">3</span>, <span class="hljs-number">0</span>)]
<span class="hljs-keyword">for</span> <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (x, <span class="hljs-number">0</span>) <span class="hljs-keyword">in</span> points {
<span class="hljs-built_in">print</span>(x)
} <span class="hljs-comment">// 1 3 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-58">6. 可选模式（Optional Pattern）</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> age: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">42</span>
<span class="hljs-keyword">if</span> <span class="hljs-keyword">case</span> .some(<span class="hljs-keyword">let</span> x) <span class="hljs-operator">=</span> age { <span class="hljs-built_in">print</span>(x) }
<span class="hljs-keyword">if</span> <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> x<span class="hljs-operator">?</span> <span class="hljs-operator">=</span> age { <span class="hljs-built_in">print</span>(x) }
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> ages: [<span class="hljs-type">Int</span>?] <span class="hljs-operator">=</span> [<span class="hljs-literal">nil</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-literal">nil</span>, <span class="hljs-number">5</span>]
<span class="hljs-keyword">for</span> <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> age<span class="hljs-operator">?</span> <span class="hljs-keyword">in</span> ages {
<span class="hljs-built_in">print</span>(age)
} <span class="hljs-comment">// 2 3 5</span>

<span class="hljs-comment">// 同上面效果等价</span>
<span class="hljs-keyword">let</span> ages: [<span class="hljs-type">Int</span>?] <span class="hljs-operator">=</span> [<span class="hljs-literal">nil</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-literal">nil</span>, <span class="hljs-number">5</span>]
<span class="hljs-keyword">for</span> item <span class="hljs-keyword">in</span> ages {
<span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> age <span class="hljs-operator">=</span> item {
    <span class="hljs-built_in">print</span>(age)
}
}  
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">check</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">num</span>: <span class="hljs-type">Int</span>?) {
<span class="hljs-keyword">switch</span> num {
<span class="hljs-keyword">case</span> <span class="hljs-number">2</span><span class="hljs-operator">?</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">4</span><span class="hljs-operator">?</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"4"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">6</span><span class="hljs-operator">?</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"6"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">_</span><span class="hljs-operator">?</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"other"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">_</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"nil"</span>)
}
}

check(<span class="hljs-number">4</span>) <span class="hljs-comment">// 4</span>
check(<span class="hljs-number">8</span>) <span class="hljs-comment">// other</span>
check(<span class="hljs-literal">nil</span>) <span class="hljs-comment">// nil </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-59">7.类型转换模式（Type-Casting Pattern）</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> num: <span class="hljs-keyword">Any</span> <span class="hljs-operator">=</span> <span class="hljs-number">6</span>
<span class="hljs-keyword">switch</span> num {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">is</span> <span class="hljs-type">Int</span>:
<span class="hljs-comment">// 编译器依然认为num是Any类型</span>
<span class="hljs-built_in">print</span>(<span class="hljs-string">"is Int"</span>, num)
<span class="hljs-comment">//case let n as Int:</span>
<span class="hljs-comment">//    print("as Int", n + 1)</span>
<span class="hljs-keyword">default</span>:
<span class="hljs-keyword">break</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Animal</span> {
<span class="hljs-keyword">func</span> <span class="hljs-title function_">eat</span>() {
    <span class="hljs-built_in">print</span>(<span class="hljs-built_in">type</span>(of: <span class="hljs-keyword">self</span>), <span class="hljs-string">"eat"</span>)
}
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span>: <span class="hljs-title class_">Animal</span> {
<span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
    <span class="hljs-built_in">print</span>(<span class="hljs-built_in">type</span>(of: <span class="hljs-keyword">self</span>), <span class="hljs-string">"run"</span>)
}
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Cat</span>: <span class="hljs-title class_">Animal</span> {
<span class="hljs-keyword">func</span> <span class="hljs-title function_">jump</span>() {
    <span class="hljs-built_in">print</span>(<span class="hljs-built_in">type</span>(of: <span class="hljs-keyword">self</span>), <span class="hljs-string">"jump"</span>)
}
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">check</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">animal</span>: <span class="hljs-type">Animal</span>) {
<span class="hljs-keyword">switch</span> animal {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> dog <span class="hljs-keyword">as</span> <span class="hljs-type">Dog</span>:
    dog.eat()
    dog.run()
<span class="hljs-keyword">case</span> <span class="hljs-keyword">is</span> <span class="hljs-type">Cat</span>:
    animal.eat()
<span class="hljs-keyword">default</span>: <span class="hljs-keyword">break</span>
}
}

check(<span class="hljs-type">Dog</span>()) <span class="hljs-comment">// Dog eat, Dog run</span>
check(<span class="hljs-type">Cat</span>()) <span class="hljs-comment">// Cat eat </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-60">8.表达式模式（Expression Pattern）</h2>
<p>表达式模式用在<code>case</code>中</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> point <span class="hljs-operator">=</span> (<span class="hljs-number">1</span>, <span class="hljs-number">2</span>)
<span class="hljs-keyword">switch</span> point {
<span class="hljs-keyword">case</span> (<span class="hljs-number">0</span>, <span class="hljs-number">0</span>):
<span class="hljs-built_in">print</span>(<span class="hljs-string">"(0, 0) is at the origin."</span>)
<span class="hljs-keyword">case</span> (<span class="hljs-operator">-</span><span class="hljs-number">2</span><span class="hljs-operator">...</span><span class="hljs-number">2</span>, <span class="hljs-operator">-</span><span class="hljs-number">2</span><span class="hljs-operator">...</span><span class="hljs-number">2</span>):
<span class="hljs-built_in">print</span>(<span class="hljs-string">"((point.0), (point.1) is near the origin."</span>)
<span class="hljs-keyword">default</span>:
<span class="hljs-built_in">print</span>(<span class="hljs-string">"The point is at ((point.0), (point.1)."</span>)
} <span class="hljs-comment">// (1, 2) is near the origin. </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>通过反汇编，我们可以看到其内部会调用<code>~=运算符</code>来计算<code>(-2...2, -2...2)</code>这个区间</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5e9c12335d5e4f01bac6820368e90f2b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w714" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-61">9. 自定义表达式模式</h2>
<p>可以通过重载运算符，自定义表达式模式的匹配规则</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Student</span> {
<span class="hljs-keyword">var</span> score <span class="hljs-operator">=</span> <span class="hljs-number">0</span>, name <span class="hljs-operator">=</span> <span class="hljs-string">""</span>

<span class="hljs-comment">// pattern：放的是case后面的值</span>
<span class="hljs-comment">// value：放的是switch后面的值</span>
<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~=</span> (<span class="hljs-params">pattern</span>: <span class="hljs-type">Int</span>, <span class="hljs-params">value</span>: <span class="hljs-type">Student</span>) -&gt; <span class="hljs-type">Bool</span> {
    value.score <span class="hljs-operator">&gt;=</span> pattern
}

<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~=</span> (<span class="hljs-params">pattern</span>: <span class="hljs-type">ClosedRange</span>&lt;<span class="hljs-type">Int</span>&gt;, <span class="hljs-params">value</span>: <span class="hljs-type">Student</span>) -&gt; <span class="hljs-type">Bool</span> {
    pattern.contains(value.score)
}

<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~=</span> (<span class="hljs-params">pattern</span>: <span class="hljs-type">Range</span>&lt;<span class="hljs-type">Int</span>&gt;, <span class="hljs-params">value</span>: <span class="hljs-type">Student</span>) -&gt; <span class="hljs-type">Bool</span> {
    pattern.contains(value.score)
}
}

<span class="hljs-keyword">var</span> stu <span class="hljs-operator">=</span> <span class="hljs-type">Student</span>(score: <span class="hljs-number">75</span>, name: <span class="hljs-string">"Jack"</span>)

<span class="hljs-keyword">switch</span> stu {
<span class="hljs-keyword">case</span> <span class="hljs-number">100</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"&gt;= 100"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">90</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"&gt;= 90"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">80</span><span class="hljs-operator">..&lt;</span><span class="hljs-number">90</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"[80, 90]"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">60</span><span class="hljs-operator">...</span><span class="hljs-number">79</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"[60, 79]"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-number">0</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"&gt;= 0"</span>)
<span class="hljs-keyword">default</span>: <span class="hljs-keyword">break</span>
} <span class="hljs-comment">// [60, 79]</span>

<span class="hljs-keyword">if</span> <span class="hljs-keyword">case</span> <span class="hljs-number">60</span> <span class="hljs-operator">=</span> stu {
<span class="hljs-built_in">print</span>(<span class="hljs-string">"&gt;= 60"</span>)
} <span class="hljs-comment">// &gt;= 60</span>

<span class="hljs-keyword">var</span> info <span class="hljs-operator">=</span> (<span class="hljs-type">Student</span>(score: <span class="hljs-number">70</span>, name: <span class="hljs-string">"Jack"</span>), <span class="hljs-string">"及格"</span>)
<span class="hljs-keyword">switch</span> info {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (<span class="hljs-number">60</span>, text): <span class="hljs-built_in">print</span>(text)
<span class="hljs-keyword">default</span>: <span class="hljs-keyword">break</span>
} <span class="hljs-comment">// 及格 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">String</span> {
<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~=</span> (<span class="hljs-params">pattern</span>: (<span class="hljs-type">String</span>) -&gt; <span class="hljs-type">Bool</span>, <span class="hljs-params">value</span>: <span class="hljs-type">String</span>) -&gt; <span class="hljs-type">Bool</span> {
    pattern(value)
}
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">hasPrefix</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">prefix</span>: <span class="hljs-type">String</span>) -&gt; ((<span class="hljs-type">String</span>) -&gt; <span class="hljs-type">Bool</span>) {
{ <span class="hljs-variable">$0</span>.hasPrefix(<span class="hljs-keyword">prefix</span>) }
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">hasSuffix</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">suffix</span>: <span class="hljs-type">String</span>) -&gt; ((<span class="hljs-type">String</span>) -&gt; <span class="hljs-type">Bool</span>) {
{ <span class="hljs-variable">$0</span>.hasSuffix(suffix) }
}

<span class="hljs-keyword">var</span> str <span class="hljs-operator">=</span> <span class="hljs-string">"jack"</span>
<span class="hljs-keyword">switch</span> str {
<span class="hljs-keyword">case</span> hasPrefix(<span class="hljs-string">"j"</span>), hasSuffix(<span class="hljs-string">"k"</span>):
<span class="hljs-built_in">print</span>(<span class="hljs-string">"以j开头，以k结尾"</span>)
<span class="hljs-keyword">default</span>: <span class="hljs-keyword">break</span>
} <span class="hljs-comment">// 以j开头，以k结尾 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">isEven</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span> { i <span class="hljs-operator">%</span> <span class="hljs-number">2</span> <span class="hljs-operator">==</span> <span class="hljs-number">0</span> }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">isOdd</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span> { i <span class="hljs-operator">%</span> <span class="hljs-number">2</span> <span class="hljs-operator">!=</span> <span class="hljs-number">0</span> }

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Int</span> {
<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~=</span> (<span class="hljs-params">pattern</span>: (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span>, <span class="hljs-params">value</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span> {
    pattern(value)
}
}

<span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">9</span>
<span class="hljs-keyword">switch</span> age {
<span class="hljs-keyword">case</span> isEven: <span class="hljs-built_in">print</span>(<span class="hljs-string">"偶数"</span>)
<span class="hljs-keyword">case</span> isOdd: <span class="hljs-built_in">print</span>(<span class="hljs-string">"奇数"</span>)
<span class="hljs-keyword">default</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"其他"</span>)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Int</span> {
<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~=</span> (<span class="hljs-params">pattern</span>: (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span>, <span class="hljs-params">value</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span> {
    pattern(value)
}
}

<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">~&gt;</span>
<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">~&gt;=</span>
<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">~&lt;</span>
<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">~&lt;=</span>

<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~&gt;</span> (<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; ((<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span>) {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">&gt;</span> i }}
<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~&gt;=</span> (<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; ((<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span>) {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">&gt;=</span> i }}
<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~&lt;</span> (<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; ((<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span>) {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">&lt;</span> i }}
<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~&lt;=</span> (<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; ((<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Bool</span>) {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">&lt;=</span> i }}

<span class="hljs-keyword">var</span> age <span class="hljs-operator">=</span> <span class="hljs-number">9</span>
<span class="hljs-keyword">switch</span> age {
<span class="hljs-keyword">case</span> <span class="hljs-operator">~&gt;=</span><span class="hljs-number">0</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"1"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-operator">~&gt;</span><span class="hljs-number">10</span>: <span class="hljs-built_in">print</span>(<span class="hljs-string">"2"</span>)
<span class="hljs-keyword">default</span>: <span class="hljs-keyword">break</span>
} <span class="hljs-comment">// 1 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-62">10. where</h2>
<p>可以使用<code>where</code>为模式匹配增加匹配条件</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> data <span class="hljs-operator">=</span> (<span class="hljs-number">10</span>, <span class="hljs-string">"Jack"</span>)
<span class="hljs-keyword">switch</span> data {
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (age, <span class="hljs-keyword">_</span>) <span class="hljs-keyword">where</span> age <span class="hljs-operator">&gt;</span> <span class="hljs-number">10</span>:
<span class="hljs-built_in">print</span>(data.<span class="hljs-number">1</span>, <span class="hljs-string">"age&gt;10"</span>)
<span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (age, <span class="hljs-keyword">_</span>) <span class="hljs-keyword">where</span> age <span class="hljs-operator">&gt;</span> <span class="hljs-number">0</span>:
<span class="hljs-built_in">print</span>(data.<span class="hljs-number">1</span>, <span class="hljs-string">"age&gt;0"</span>)
<span class="hljs-keyword">default</span>:
<span class="hljs-keyword">break</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> ages <span class="hljs-operator">=</span> [<span class="hljs-number">10</span>, <span class="hljs-number">20</span>, <span class="hljs-number">44</span>, <span class="hljs-number">23</span>, <span class="hljs-number">55</span>]
<span class="hljs-keyword">for</span> age <span class="hljs-keyword">in</span> ages <span class="hljs-keyword">where</span> age <span class="hljs-operator">&gt;</span> <span class="hljs-number">30</span> {
<span class="hljs-built_in">print</span>(age)
} <span class="hljs-comment">// 44 55 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Stackable</span> {
<span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Element</span>
}

<span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Container</span> {
<span class="hljs-keyword">associatedtype</span> <span class="hljs-type">Stack</span>: <span class="hljs-type">Stackable</span> <span class="hljs-keyword">where</span> <span class="hljs-type">Stack</span>.<span class="hljs-type">Element</span>: <span class="hljs-type">Equatable</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">equal</span>&lt;<span class="hljs-type">S1</span>: <span class="hljs-type">Stackable</span>, <span class="hljs-type">S2</span>: <span class="hljs-type">Stackable</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">s1</span>: <span class="hljs-type">S1</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">s2</span>: <span class="hljs-type">S2</span>) -&gt; <span class="hljs-type">Bool</span> <span class="hljs-keyword">where</span> <span class="hljs-type">S1</span>.<span class="hljs-type">Element</span> <span class="hljs-operator">==</span> <span class="hljs-type">S2</span>.<span class="hljs-type">Element</span>, <span class="hljs-type">S1</span>.<span class="hljs-type">Element</span> : <span class="hljs-type">Hashable</span> { <span class="hljs-literal">false</span> } 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Container</span> <span class="hljs-title class_">where</span> <span class="hljs-title class_">Self</span>.<span class="hljs-title class_">Stack</span>.<span class="hljs-title class_">Element</span>: <span class="hljs-title class_">Hashable</span> { }
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-63">专题系列文章</h1>
<h3 data-id="heading-64">1.前知识</h3>
<ul>
<li><strong><a href="https://juejin.cn/post/7089043618803122183/" target="_blank" title="https://juejin.cn/post/7089043618803122183/">01-探究iOS底层原理|综述</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7093842449998561316/" target="_blank" title="https://juejin.cn/post/7093842449998561316/">02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7095079758844674056" target="_blank" title="https://juejin.cn/post/7095079758844674056">03-探究iOS底层原理|LLDB</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7115302848270696485/" target="_blank" title="https://juejin.cn/post/7115302848270696485/">04-探究iOS底层原理|ARM64汇编</a></strong></li>
</ul>
<h3 data-id="heading-65">2. 基于OC语言探索iOS底层原理</h3>
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
<h3 data-id="heading-66">3. 基于Swift语言探索iOS底层原理</h3>
<p>关于<code>函数</code>、<code>枚举</code>、<code>可选项</code>、<code>结构体</code>、<code>类</code>、<code>闭包</code>、<code>属性</code>、<code>方法</code>、<code>swift多态原理</code>、<code>String</code>、<code>Array</code>、<code>Dictionary</code>、<code>引用计数</code>、<code>MetaData</code>等Swift基本语法和相关的底层原理文章有如下几篇:</p>
<ul>
<li><a href="https://juejin.cn/post/7119020967430455327" target="_blank" title="https://juejin.cn/post/7119020967430455327">Swift5核心语法1-基础语法</a></li>
<li><a href="https://juejin.cn/post/7119510159109390343" target="_blank" title="https://juejin.cn/post/7119510159109390343">Swift5核心语法2-面向对象语法1</a></li>
<li><a href="https://juejin.cn/post/7119513630550261774" target="_blank" title="https://juejin.cn/post/7119513630550261774">Swift5核心语法2-面向对象语法2</a></li>
<li><a href="https://juejin.cn/post/7119714488181325860" target="_blank" title="https://juejin.cn/post/7119714488181325860">Swift5常用核心语法3-其它常用语法</a></li>
<li><a href="https://juejin.cn/post/7119722433589805064" target="_blank" title="https://juejin.cn/post/7119722433589805064">Swift5应用实践常用技术点</a></li>
</ul>
<h1 data-id="heading-67">其它底层原理专题</h1>
<h3 data-id="heading-68">1.底层原理相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7018755998823219213" target="_blank" title="https://juejin.cn/post/7018755998823219213">01-计算机原理|计算机图形渲染原理这篇文章</a></li>
<li><a href="https://juejin.cn/post/7019117942377807908" target="_blank" title="https://juejin.cn/post/7019117942377807908">02-计算机原理|移动终端屏幕成像与卡顿&nbsp;</a></li>
</ul>
<h3 data-id="heading-69">2.iOS相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7019193784806146079" target="_blank" title="https://juejin.cn/post/7019193784806146079">01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019200157119938590" target="_blank" title="https://juejin.cn/post/7019200157119938590">02-iOS底层原理|iOS动画渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019497906650497061/" target="_blank" title="https://juejin.cn/post/7019497906650497061/">03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理</a></li>
<li><a href="https://juejin.cn/post/7020613901033144351" target="_blank" title="https://juejin.cn/post/7020613901033144351">04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案</a></li>
</ul>
<h3 data-id="heading-70">3.webApp相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021035020445810718/" target="_blank" title="https://juejin.cn/post/7021035020445810718/">01-Web和类RN大前端的渲染原理</a></li>
</ul>
<h3 data-id="heading-71">4.跨平台开发方案相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021057396147486750/" target="_blank" title="https://juejin.cn/post/7021057396147486750/">01-Flutter页面渲染原理</a></li>
</ul>
<h3 data-id="heading-72">5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较</h3>
<ul>
<li><a href="https://juejin.cn/post/7021071990723182606/" target="_blank" title="https://juejin.cn/post/7021071990723182606/">01-Native、WebApp、跨平台开发三种方案性能比较</a></li>
</ul>
<h3 data-id="heading-73">6.Android、HarmonyOS页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021840737431978020/" target="_blank" title="https://juejin.cn/post/7021840737431978020/">01-Android页面渲染原理</a></li>
<li><a href="#" title="#">02-HarmonyOS页面渲染原理</a> (<code>待输出</code>)</li>
</ul>
<h3 data-id="heading-74">7.小程序页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021414123346853919" target="_blank" title="https://juejin.cn/post/7021414123346853919">01-小程序框架渲染原理</a></li>
</ul></div></div>