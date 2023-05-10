# Swift5应用实践常用技术点

<h1 data-id="heading-0">一、概述</h1>
<p>最近刚好有空,趁这段时间,复习一下<code>Swift5</code>核心语法,进行知识储备,以供日后温习 和 进一步探索<code>Swift</code>语言的底层原理做铺垫。</p>
<p>本文继前三篇文章复习:</p>
<ul>
<li><a href="https://juejin.cn/post/7119020967430455327" target="_blank" title="https://juejin.cn/post/7119020967430455327">Swift5核心语法1-基础语法</a></li>
<li><a href="https://juejin.cn/post/7119510159109390343" target="_blank" title="https://juejin.cn/post/7119510159109390343">Swift5核心语法2-面向对象语法1</a></li>
<li><a href="https://juejin.cn/post/7119513630550261774" target="_blank" title="https://juejin.cn/post/7119513630550261774">Swift5核心语法2-面向对象语法2</a></li>
<li><a href="https://juejin.cn/post/7119714488181325860" target="_blank" title="https://juejin.cn/post/7119714488181325860">Swift5常用核心语法3-其它常用语法</a></li>
<li>我们通过本文继续复习<code>Swift5应用实践常用技术要点</code>
<img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a03e517565e54fa6895098e060598486~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="image.png" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h1 data-id="heading-1">一、从OC到Swift</h1>
<h2 data-id="heading-2">1. 标记</h2>
<p>我们可以通过一些注释标记来特殊标明注释的含义</p>
<ul>
<li><code>// MARK:</code> 类似<code>OC</code>中的<code>#pragma mark</code></li>
<li><code>// MARK: -</code> 类似<code>OC</code>中的<code>#pragma mark -</code></li>
<li><code>// TODO:</code> 用于标记未完成的任务</li>
<li><code>// FIXME:</code> 用于标记待修复的问题</li>
</ul>
<p>使用示例如下</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/503e1e80a2264029b79524650dc62c74~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w370" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/34ed563f13d74c0f92d8ed1336b66231~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w440" loading="lazy" class="medium-zoom-image"></p>
<p>我们还可以使用<code>#warning</code>来作为警告的提示，效果更为显著</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c05a9f610fd149389b6d9719617ab47c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w714" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-3">2. 条件编译</h2>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5157980e7c574b31a5c37d39667d3c10~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w720" loading="lazy" class="medium-zoom-image"></p>
<p>我们还可以在<code>Build Settings-&gt; Swift Compiler -Custom Flags</code>自定义标记</p>
<p>在<code>Other Swift Flags</code>里自定义的标记要以<code>-D</code>开头</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5a8057e99b664fd1b4125b33a0be75f0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w716" loading="lazy" class="medium-zoom-image"></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5eaf1ed438f24cda8833e9e6a2182470~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w278" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-4">3. 打印</h2>
<p>我们可以自定义打印的内容，便于开发中的详情观察</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">/*
 * msg: 打印的内容
 * file: 文件名
 * line: 所在行数
 * fn: 执行的函数名
 */</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">log</span>&lt;<span class="hljs-type">T</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">msg</span>: <span class="hljs-type">T</span>, <span class="hljs-params">file</span>: <span class="hljs-type">NSString</span> <span class="hljs-operator">=</span> <span class="hljs-keyword">#file</span>, <span class="hljs-params">line</span>: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-keyword">#line</span>, <span class="hljs-params">fn</span>: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-keyword">#function</span>) {
    <span class="hljs-keyword">#if</span> <span class="hljs-type">DEBUG</span>
    <span class="hljs-keyword">let</span> <span class="hljs-keyword">prefix</span> <span class="hljs-operator">=</span> <span class="hljs-string">"(file.lastPathComponent)_(line)_(fn):"</span>
    <span class="hljs-built_in">print</span>(<span class="hljs-keyword">prefix</span>, msg)
    <span class="hljs-keyword">#endif</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">test</span>() {
    log(<span class="hljs-string">"哈哈"</span>)
} 

<span class="hljs-comment">// 输出：</span>
<span class="hljs-comment">// main.swift_66_test(): 哈哈 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-5">4. 系统的版本检测</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">if</span> <span class="hljs-keyword">#available</span>(<span class="hljs-keyword">iOS</span> <span class="hljs-number">10</span>, <span class="hljs-keyword">macOS</span> <span class="hljs-number">10.12</span>, <span class="hljs-operator">*</span>) {
    <span class="hljs-comment">// 对于iOS平台，只在iOS10及以上版本执行</span>
    <span class="hljs-comment">// 对于macOS平台，只在macOS 10.12以上版本执行</span>
    <span class="hljs-comment">// 最后的*表示在其他所有平台都执行</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-6">5. API可用性说明</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@available</span>(<span class="hljs-keyword">iOS</span> <span class="hljs-number">10</span>, <span class="hljs-keyword">macOS</span> <span class="hljs-number">10.12</span>, <span class="hljs-operator">*</span>)
<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}

<span class="hljs-keyword">struct</span> <span class="hljs-title class_">Student</span> {
    <span class="hljs-comment">// 旧的方法名更改，使用者用到时就会报错</span>
    <span class="hljs-keyword">@available</span>(<span class="hljs-operator">*</span>, unavailable, renamed: <span class="hljs-string">"study"</span>)
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">study_</span>() {}
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">study</span>() {}
    
    <span class="hljs-comment">// 表示该方法在这个平台已经过期</span>
    <span class="hljs-keyword">@available</span>(<span class="hljs-keyword">iOS</span>, deprecated: <span class="hljs-number">11</span>)
    <span class="hljs-keyword">@available</span>(<span class="hljs-keyword">macOS</span>, deprecated: <span class="hljs-number">10.12</span>)
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {}
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1aae54a5a9b34e69a0f5b0ad58548a54~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w642" loading="lazy" class="medium-zoom-image"></p>
<p>更多用法参考：<a href="https://link.juejin.cn?target=https%3A%2F%2Fdocs.swift.org%2Fswift-book%2FReferenceManual%2FAttributes.html" title="https://link.juejin.cn?target=https%3A%2F%2Fdocs.swift.org%2Fswift-book%2FReferenceManual%2FAttributes.html" target="_blank">docs.swift.org/swift-book/…</a></p>
<h2 data-id="heading-7">6. 程序入口</h2>
<p>在<code>AppDelegate</code>上面默认有个<code>@main</code>标记，这表示编译器自动生成入口代码（main函数代码），自动设置<code>AppDelegate</code>为APP的代理</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1c7e5d9b0a024687be380d5f3e31c3ed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w776" loading="lazy" class="medium-zoom-image"></p>
<p>之前的<code>Xcode</code>版本会生成<code>@UIApplicationMain</code>标记，和<code>@main</code>的作用一样</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7232bfd8d235474daec8a836b6536209~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w776" loading="lazy" class="medium-zoom-image"></p>
<p>也可以删掉<code>@main</code>或者<code>@UIApplicationMain</code>，自定义入口代码</p>
<p>1.创建<code>main.swift</code>文件</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7645c407f7cf4f48a9e30d01ffc5830a~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w728" loading="lazy" class="medium-zoom-image"></p>
<p>2.去掉<code>AppDelegate</code>里的标记</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/34896ddcd5ea4639b69827eadba0f9a1~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w775" loading="lazy" class="medium-zoom-image"></p>
<p>3.在<code>main.swift</code>里面自定义<code>UIApplication</code>并增加入口代码</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f1cfff66a40a49c8bb4b8212148fb761~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w748" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-8">7. Swift调用OC</h2>
<p>如果我们在Swift项目中需要调用到OC的代码，需要建立一个桥接头文件，文件名格式为<code>{targetName}-Bridging-Header.h</code></p>
<p>在桥接文件里引用需要的OC头文件</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/37741c059c2042fe91899f89c2216886~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1119" loading="lazy" class="medium-zoom-image"></p>
<p>在<code>Build Setting -&gt; Swift Compiler - General</code>中写好桥接文件路径</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4598ea94c3e7465d81630f451ed8e7b2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w849" loading="lazy" class="medium-zoom-image"></p>
<p>如果我们是在Swift项目里第一次创建OC文件，<code>Xcode</code>会提示是否需要帮助创建桥接文件</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e57cadadbef147678501a38b0aa6f9b8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w731" loading="lazy" class="medium-zoom-image"></p>
<p>然后我们就可以在Swift文件里调用OC的代码了</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1d68d5363bf6452d91a438f5ebae0b00~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w532" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1c2b5a1e962843c5a651b6f7107a6b1e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w728" loading="lazy" class="medium-zoom-image"></p>
<p>如果C语言暴露给Swift的函数名和Swift中的其他函数名冲突了，可以在Swift中使用<code>@_silgen_name</code>修改C语言的函数名</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// C文件</span>
int sum(int a, int b) {
    <span class="hljs-keyword">return</span> a <span class="hljs-operator">+</span> b;
}

<span class="hljs-comment">// Swift文件</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">a</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">b</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    a <span class="hljs-operator">-</span> b
}

<span class="hljs-meta">@_silgen_name</span>(<span class="hljs-string">"sum"</span>)
<span class="hljs-keyword">func</span> <span class="hljs-title function_">swift_sum</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">a</span>: <span class="hljs-type">Int32</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">b</span>: <span class="hljs-type">Int32</span>) -&gt; <span class="hljs-type">Int32</span>

<span class="hljs-built_in">print</span>(sum(<span class="hljs-number">5</span>, <span class="hljs-number">6</span>))
<span class="hljs-built_in">print</span>(swift_sum(<span class="hljs-number">5</span>, <span class="hljs-number">6</span>)) 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><code>@_silgen_name</code>还可以用来调用C的私有函数</p>
<h2 data-id="heading-9">8. OC调用Swift</h2>
<p>我们要是想在OC文件中调用Swift代码，需要引用一个隐藏文件<code>{targetName}-Swift.h</code></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b7ee3e67cbd64afbafd980f77c1275ed~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w847" loading="lazy" class="medium-zoom-image"></p>
<p>Swift暴露给OC的类最终都要继承自<code>NSObject</code></p>
<p>使用<code>@objc</code>修饰需要暴露给OC的成员</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/95b10b0c07a54d3bb366dbfc0603da69~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w400" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c09a72f8d1764594a8fe7abf349c3d01~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w592" loading="lazy" class="medium-zoom-image"></p>
<p>使用<code>@objcMembers</code>修饰类，代表默认所有成员都会暴露给OC（包括扩展中定义的成员）</p>
<p>最终是否成功暴露，还需要考虑成员自身的权限问题</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a03455cdbec8415ca2c8efa0cc7281c6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w496" loading="lazy" class="medium-zoom-image"></p>
<p>我们进入到<code>test-Swift.h</code>里看看编译器默认帮我们转成的OC代码是怎样的</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f3c621b1d7854c529d8596c0d4345821~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w722" loading="lazy" class="medium-zoom-image"></p>
<p>我们还可以通过<code>@objc</code>来对Swift文件里的类和成员重命名，来更适应于OC的代码规范</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9d7c4fff781e464dbfd50177c7b2a0b8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w573" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bdf387dd03044e158df292505ce6730d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w635" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-10">9.选择器</h2>
<p>Swift中依然可以使用选择器，使用<code>#selector(name)</code>定义一个选择器</p>
<p>必须是被<code>@objcMembers</code>或<code>@objc</code>修饰的方法才可以定义选择器</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a485a1206acd4edc93cc8a20fa927aee~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w728" loading="lazy" class="medium-zoom-image"></p>
<p>如果不加<code>@objcMembers</code>或<code>@objc</code>是会报错的</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ffbcaad964884810b40513cba3491bcf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w777" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-11">10. 混编调用的本质</h2>
<p><strong>我们先来思考一个问题，为什么Swift暴露给OC的类最终要继承NSObject？</strong></p>
<p>只有OC调用最后还是走的消息发送机制，要想能够实现消息机制，就需要有<code>isa指针</code>，所以要继承<code>NSObject</code></p>
<p>我们在调用的地方打上断点，然后进行反汇编</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4574b5b5d78347169f7dbe634f696c13~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w557" loading="lazy" class="medium-zoom-image"></p>
<p>我们发现，反汇编内部最终调用了<code>objc_msgSend</code>，很明显是消息发送机制</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ebd29213bfc4c6fb9fecd82a89fb3a8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w846" loading="lazy" class="medium-zoom-image"></p>
<p><strong>那Swift调用OC的方法，是走的消息发送机制，还是Swift本身的调用方式呢？</strong></p>
<p>我们在调用的地方打上断点，然后进行反汇编</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3305857dbdb44dab9df8b61d78e72bc5~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w781" loading="lazy" class="medium-zoom-image"></p>
<p>我们发现，反汇编内部最终调用了<code>objc_msgSend</code>，很明显是消息发送机制</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c3240ca290794899999dd1d823160a82~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w846" loading="lazy" class="medium-zoom-image"></p>
<p><strong>暴露给OC使用的Swift函数和类，如果被Swift调用，是走的消息发送机制，还是Swift本身的调用方式呢？</strong></p>
<p>我们在调用的地方打上断点，然后进行反汇编</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/99cab04169314f668cdd7830050e3836~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w784" loading="lazy" class="medium-zoom-image"></p>
<p>我们发现，反汇编内部是按照根据元类信息里的函数地址去调用的方式，没有<code>Runtime</code>相关的调用</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e0ad94a0f0e548079899cf2e491551e6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w841" loading="lazy" class="medium-zoom-image"> <img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/17a8bb7f1d7445f0b865c5ade381ff21~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w847" loading="lazy" class="medium-zoom-image"></p>
<p>我们可以加上<code>dynamic</code>关键字，这样不管是OC调用还是Swift调用都会走<code>Runtime</code>的消息发送机制</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cffbba28d0e842c38114d4b205789d0c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w505" loading="lazy" class="medium-zoom-image"></p>
<p>反汇编之后</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ba276810bb6b4858b5ab13c4606f3bb3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w843" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-12">11. String</h2>
<p>Swift的字符串类型<code>String</code>，和OC的<code>NSString</code>，在API设计上还是有较大差异的</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 空字符串</span>
<span class="hljs-keyword">var</span> emptyStr1 <span class="hljs-operator">=</span> <span class="hljs-string">""</span>
<span class="hljs-keyword">var</span> emptyStr2 <span class="hljs-operator">=</span> <span class="hljs-type">String</span>() 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 拼接字符串</span>
<span class="hljs-keyword">var</span> str: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">"1"</span>
str.append(<span class="hljs-string">"_2"</span>)

<span class="hljs-comment">// 重载运算符</span>
str <span class="hljs-operator">=</span> str <span class="hljs-operator">+</span> <span class="hljs-string">"_3"</span>
str <span class="hljs-operator">+=</span> <span class="hljs-string">"_4"</span>

<span class="hljs-comment">// 插值</span>
str <span class="hljs-operator">=</span> <span class="hljs-string">"(str)_5"</span>
<span class="hljs-built_in">print</span>(str, str.count) <span class="hljs-comment">// 1_2_3_4_5, 9 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 字符串的判断</span>
<span class="hljs-keyword">var</span> str <span class="hljs-operator">=</span> <span class="hljs-string">"123456"</span>
<span class="hljs-built_in">print</span>(str.hasPrefix(<span class="hljs-string">"123"</span>)) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(str.hasSuffix(<span class="hljs-string">"456"</span>)) <span class="hljs-comment">// true </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-13">11.1  String的插入和删除</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str <span class="hljs-operator">=</span> <span class="hljs-string">"1_2"</span>

str.insert(<span class="hljs-string">"_"</span>, at: str.endIndex) <span class="hljs-comment">// 1_2_</span>
str.insert(contentsOf: <span class="hljs-string">"3_4"</span>, at: str.endIndex) <span class="hljs-comment">// 1_2_3_4</span>
str.insert(contentsOf: <span class="hljs-string">"666"</span>, at: str.index(after: str.startIndex)) <span class="hljs-comment">// 1666_2_3_4</span>
str.insert(contentsOf: <span class="hljs-string">"888"</span>, at: str.index(before: str.endIndex)) <span class="hljs-comment">// 1666_2_3_8884</span>
str.insert(contentsOf: <span class="hljs-string">"hello"</span>, at: str.index(str.startIndex, offsetBy: <span class="hljs-number">4</span>)) <span class="hljs-comment">// 1666hello_2_3_8884 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift">str.remove(at: str.firstIndex(of: <span class="hljs-string">"1"</span>)<span class="hljs-operator">!</span>) <span class="hljs-comment">// 666hello_2_3_8884</span>
str.removeAll { <span class="hljs-variable">$0</span> <span class="hljs-operator">==</span> <span class="hljs-string">"6"</span> } <span class="hljs-comment">// hello_2_3_8884</span>
    
<span class="hljs-keyword">let</span> range <span class="hljs-operator">=</span> str.index(str.endIndex, offsetBy: <span class="hljs-operator">-</span><span class="hljs-number">4</span>)<span class="hljs-operator">..&lt;</span>str.index(before: str.endIndex)
str.removeSubrange(range) <span class="hljs-comment">// hello_2_3_4 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-14">11.2 Substring</h3>
<p><code>String</code>可以通过<code>下标、prefix、suffix</code>等截取子串，子串类型不是<code>String</code>，而是<code>Substring</code></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str <span class="hljs-operator">=</span> <span class="hljs-string">"1_2_3_4_5"</span>

<span class="hljs-keyword">var</span> substr1 <span class="hljs-operator">=</span> str.prefix(<span class="hljs-number">3</span>) <span class="hljs-comment">// 1_2</span>
<span class="hljs-keyword">var</span> substr2 <span class="hljs-operator">=</span> str.suffix(<span class="hljs-number">3</span>) <span class="hljs-comment">// 4_5</span>

<span class="hljs-keyword">var</span> range <span class="hljs-operator">=</span> str.startIndex<span class="hljs-operator">..&lt;</span>str.index(str.startIndex, offsetBy: <span class="hljs-number">3</span>)
<span class="hljs-keyword">var</span> substr3 <span class="hljs-operator">=</span> str[range] <span class="hljs-comment">// 1_2</span>

<span class="hljs-comment">// 最初的String</span>
<span class="hljs-built_in">print</span>(substr3.base) <span class="hljs-comment">// 1_2_3_4_5</span>

<span class="hljs-comment">// Substring -&gt; String</span>
<span class="hljs-keyword">var</span> str2 <span class="hljs-operator">=</span> <span class="hljs-type">String</span>(substr3) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>Substring</code>和它的<code>base</code>，共享字符串数据</li>
<li>其本质是<code>Substring</code>内部有一个指针指向<code>String</code>对应的区域</li>
<li><code>Substring</code>发生修改或者转为<code>String</code>时，会分配新的内存存储字符串数据，不会影响到最初的<code>String</code>的内容，编译器会自动做优化
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6fbefa1a85e4471abcca65a83ef20b47~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w467" loading="lazy" class="medium-zoom-image"></li>
</ul>
<h3 data-id="heading-15">11.3 String与Character</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">for</span> c <span class="hljs-keyword">in</span> <span class="hljs-string">"jack"</span> { <span class="hljs-comment">// c是Character类型</span>
    <span class="hljs-built_in">print</span>(c)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str <span class="hljs-operator">=</span> <span class="hljs-string">"jack"</span>
<span class="hljs-keyword">var</span> c <span class="hljs-operator">=</span> str[str.startIndex] <span class="hljs-comment">// c是Character类型 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-16">11.4 String相关的协议</h3>
<ul>
<li>
<p><code>BidirectionalCollection</code>协议包含的部分内容</p>
<ul>
<li><code>startIndex</code>、<code>endIndex</code>属性、<code>index</code>方法</li>
<li><code>String</code>、<code>Array</code>都遵守了这个协议</li>
</ul>
</li>
<li>
<p><code>RangeReplaceableCollection</code>协议包含的部分内容</p>
<ul>
<li><code>append</code>、<code>insert</code>、<code>remove</code>方法</li>
<li><code>String</code>、<code>Array</code>都遵守了这个协议</li>
</ul>
</li>
<li>
<p><code>Dictionary</code>、<code>Set</code>也有实现上述协议中声明的一些方法，只是并没有遵守上述协议</p>
</li>
</ul>
<h3 data-id="heading-17">11.5  多行String</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> str <span class="hljs-operator">=</span> <span class="hljs-string">"""
1
    ”2“
3
    '4'
"""</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>如果要显示3引号，至少转义1个引号</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> str <span class="hljs-operator">=</span> <span class="hljs-string">"""
Escaping the first quote """</span>
<span class="hljs-type">Escaping</span> two quotes <span class="hljs-string">"""
Escaping all three quotes """</span>
<span class="hljs-string">""" 
</span><span class="copy-code-btn">复制代码</span></code></pre>
<p>以下两个字符是等价的</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> str1 <span class="hljs-operator">=</span> <span class="hljs-string">"These are the same."</span>
<span class="hljs-keyword">let</span> str2 <span class="hljs-operator">=</span> <span class="hljs-string">"""
These are the same.
"""</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>缩进以结尾的3引号为对齐线</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> str <span class="hljs-operator">=</span> <span class="hljs-string">"""
        1
            2
    3
        4
    """</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-18">11.6 String和NSString</h3>
<ul>
<li><code>String</code>和<code>NSString</code>之间可以随时随地的桥接转换</li>
<li>如果你觉得<code>String</code>的API过于复杂难用，可以考虑将<code>String</code>转为<code>NSString</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">"jack"</span>
<span class="hljs-keyword">var</span> str2: <span class="hljs-type">NSString</span> <span class="hljs-operator">=</span> <span class="hljs-string">"rose"</span>

<span class="hljs-keyword">var</span> str3 <span class="hljs-operator">=</span> str1 <span class="hljs-keyword">as</span> <span class="hljs-type">NSString</span>
<span class="hljs-keyword">var</span> str4 <span class="hljs-operator">=</span> str2 <span class="hljs-keyword">as</span> <span class="hljs-type">String</span>

<span class="hljs-keyword">var</span> str5 <span class="hljs-operator">=</span> str3.substring(with: <span class="hljs-type">NSRange</span>(location: <span class="hljs-number">0</span>, length: <span class="hljs-number">2</span>))
<span class="hljs-built_in">print</span>(str5) <span class="hljs-comment">// ja </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>我们通过反汇编发现，<code>String</code>和<code>NSString</code>的转换会调用函数来实现的，相对会有性能的消耗，但由于编译器的优化，消耗的成本可以忽略不计</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ebe0ffeb017440ad8bdba06af9d07524~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w715" loading="lazy" class="medium-zoom-image"></p>
<p><strong>比较字符串内容是否等价</strong></p>
<ul>
<li><code>String</code>使用<code>==</code>运算符</li>
<li><code>NSString</code>使用<code>isEqual</code>方法，也可以使用<code>==</code>运算符（本质还是调用了<code>isEqual</code>方法）</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> str1: <span class="hljs-type">NSString</span> <span class="hljs-operator">=</span> <span class="hljs-string">"jack"</span>
<span class="hljs-keyword">var</span> str2: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">"rose"</span>
<span class="hljs-keyword">var</span> str5: <span class="hljs-type">String</span> <span class="hljs-operator">=</span> <span class="hljs-string">"rose"</span>
<span class="hljs-keyword">var</span> str6: <span class="hljs-type">NSString</span> <span class="hljs-operator">=</span> <span class="hljs-string">"jack"</span>

<span class="hljs-built_in">print</span>(str2 <span class="hljs-operator">==</span> str5)
<span class="hljs-built_in">print</span>(str1 <span class="hljs-operator">==</span> str6) 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>通过反汇编，我们可以看到<code>==</code>运算符的本质还是调用了<code>isEqual</code>方法</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/54a041f55100495d9d08b9ad2a82e727~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w714" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/70eb10bfdbff485d90798d2806b3fe11~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w714" loading="lazy" class="medium-zoom-image">
!<a href="https://link.juejin.cn?target=https%3A%2F%2Fp3-juejin.byteimg.com%2Ftos-cn-i-k3u1fbpfcp%2Fbf842a9f550e41ea875c8b7aa0fc7fc7~tplv-k3u1fbpfcp-zoom-1.image" target="_blank" title="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bf842a9f550e41ea875c8b7aa0fc7fc7~tplv-k3u1fbpfcp-zoom-1.image" ref="nofollow noopener noreferrer">-w713</a></p>
<p><strong>下面是Swift和OC的几个类型的转换表格</strong></p>
<p><code>String</code>和<code>NSString</code>可以相互转换，而<code>NSMutableString</code>就只能单向转换成<code>String</code></p>
<p>其他类型同理</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/045b94548fa64169ad7bbd9c1d0a839f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w506" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-19">12. 只能被class继承的协议</h2>
<ul>
<li>如果协议对应<code>AnyObject、class、@objc</code>来修饰，那么只能被类所遵守
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/157c85f4208741afa8daba0486044620~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w654" loading="lazy" class="medium-zoom-image"></li>
<li>被<code>@objc</code>修饰的协议，还可以暴露给OC去遵守协议实现</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// Swift文件</span>
<span class="hljs-keyword">@objc</span> <span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable4</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>()
}

<span class="hljs-comment">// OC文件</span>
<span class="hljs-meta">@interface</span> <span class="hljs-type">LLTest</span> : <span class="hljs-type">NSObject</span>&lt;<span class="hljs-type">Runnable4</span>&gt;

<span class="hljs-meta">@end</span>

<span class="hljs-meta">@implementation</span> <span class="hljs-type">LLTest</span>

<span class="hljs-operator">-</span> (void)run { }
<span class="hljs-meta">@end</span> 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>可以通过<code>@objc</code>定义可选协议，这种协议只能被<code>class</code>遵守</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@objc</span> <span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable4</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>()
    <span class="hljs-keyword">@objc</span> <span class="hljs-keyword">optional</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">eat</span>()
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">Runnable4</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"run"</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-20">13. dynamic</h2>
<p>被<code>@objc dynamic</code>修饰的内容会具有动态性，比如调用方法会走<code>Runtime</code>的消息发送机制</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Dog</span> {
    <span class="hljs-keyword">@objc</span> <span class="hljs-keyword">dynamic</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">test1</span>() {}
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">test2</span>() {}
}

<span class="hljs-keyword">var</span> d <span class="hljs-operator">=</span> <span class="hljs-type">Dog</span>()
d.test1()
d.test2() 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>具体汇报调用过程可以参考上文<code>混编调用的本质</code></p>
<h2 data-id="heading-21">14.KVC、KVO</h2>
<ul>
<li>
<ol>
<li>Swift支持<code>KVC、KVO</code>的条件需要属性所在的类、监听器最终继承自<code>NSObject</code></li>
</ol>
</li>
<li>
<ol start="2">
<li>用<code>@objc dynamic</code>修饰对应的属性</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Observer</span>: <span class="hljs-title class_">NSObject</span> {
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">observeValue</span>(<span class="hljs-params">forKeyPath</span> <span class="hljs-params">keyPath</span>: <span class="hljs-type">String</span>?, <span class="hljs-params">of</span> <span class="hljs-params">object</span>: <span class="hljs-keyword">Any</span><span class="hljs-operator">?</span>, <span class="hljs-params">change</span>: [<span class="hljs-params">NSKeyValueChangeKey</span> : <span class="hljs-keyword">Any</span>]<span class="hljs-operator">?</span>, <span class="hljs-params">context</span>: <span class="hljs-type">UnsafeMutableRawPointer</span>?) {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"observeValue"</span>, change<span class="hljs-operator">?</span>[.newKey] <span class="hljs-keyword">as</span> <span class="hljs-keyword">Any</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">NSObject</span> {
    <span class="hljs-keyword">@objc</span> <span class="hljs-keyword">dynamic</span> <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> observer: <span class="hljs-type">Observer</span> <span class="hljs-operator">=</span> <span class="hljs-type">Observer</span>()
    
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>()
        
        addObserver(observer, forKeyPath: <span class="hljs-string">"age"</span>, options: .new, context: <span class="hljs-literal">nil</span>)
    }
    
    <span class="hljs-keyword">deinit</span> {
        removeObserver(observer, forKeyPath: <span class="hljs-string">"age"</span>)
    }
}


<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
p.age <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
p.setValue(<span class="hljs-number">25</span>, forKey: <span class="hljs-string">"age"</span>)

<span class="hljs-comment">// Optional(20)</span>
<span class="hljs-comment">// Optional(25) </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol start="3">
<li><code>block</code>方式的`KVO</li>
</ol>
</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span>: <span class="hljs-title class_">NSObject</span> {
    <span class="hljs-keyword">@objc</span> <span class="hljs-keyword">dynamic</span> <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> <span class="hljs-operator">=</span> <span class="hljs-number">0</span>
    <span class="hljs-keyword">var</span> observation: <span class="hljs-type">NSKeyValueObservation</span>?
    
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">init</span>() {
        <span class="hljs-keyword">super</span>.<span class="hljs-keyword">init</span>()
        
        observation <span class="hljs-operator">=</span> observe(\<span class="hljs-type">Person</span>.age, options: .new, changeHandler: { (person, change) <span class="hljs-keyword">in</span>
            <span class="hljs-built_in">print</span>(change.newValue <span class="hljs-keyword">as</span> <span class="hljs-keyword">Any</span>)
        })
    }
}


<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
p.age <span class="hljs-operator">=</span> <span class="hljs-number">20</span>
p.setValue(<span class="hljs-number">25</span>, forKey: <span class="hljs-string">"age"</span>)

<span class="hljs-comment">// Optional(20)</span>
<span class="hljs-comment">// Optional(25) </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-22">15. 关联对象（Associated Object）</h2>
<ul>
<li>在Swift中，<code>class</code>依然可以使用关联对象</li>
<li>默认情况下，<code>extension</code>不可以增加存储属性</li>
<li>借助关联对象，可以实现类似<code>extension</code>为<code>class</code>增加存储属性的效果</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Person</span> {}
<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-comment">// Void类型只占一个字节</span>
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> <span class="hljs-type">AGE_KEY</span>: <span class="hljs-type">Void</span>?
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">get</span> {
            (objc_getAssociatedObject(<span class="hljs-keyword">self</span>, <span class="hljs-operator">&amp;</span><span class="hljs-keyword">Self</span>.<span class="hljs-type">AGE_KEY</span>) <span class="hljs-keyword">as?</span> <span class="hljs-type">Int</span>) <span class="hljs-operator">??</span> <span class="hljs-number">0</span>
        }
        
        <span class="hljs-keyword">set</span> {
            objc_setAssociatedObject(<span class="hljs-keyword">self</span>, <span class="hljs-operator">&amp;</span><span class="hljs-keyword">Self</span>.<span class="hljs-type">AGE_KEY</span>, newValue, .<span class="hljs-type">OBJC_ASSOCIATION_ASSIGN</span>)
        }
    }
}

<span class="hljs-keyword">var</span> p <span class="hljs-operator">=</span> <span class="hljs-type">Person</span>()
<span class="hljs-built_in">print</span>(p.age) <span class="hljs-comment">// 0</span>

p.age <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-built_in">print</span>(p.age) <span class="hljs-comment">// 10 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-23">16. 资源名管理</h2>
<p>我们日常在代码中对资源的使用如下</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> img <span class="hljs-operator">=</span> <span class="hljs-type">UIImage</span>(named: <span class="hljs-string">"logo"</span>)
        
<span class="hljs-keyword">let</span> btn <span class="hljs-operator">=</span> <span class="hljs-type">UIButton</span>(type: .custom)
btn.setTitle(<span class="hljs-string">"添加"</span>, for: .normal)
    
performSegue(withIdentifier: <span class="hljs-string">"login_main"</span>, sender: <span class="hljs-keyword">self</span>) 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>我们采用<code>枚举</code>的方式对资源名进行管理</li>
<li>这种方式是参考了<code>Android</code>的资源名管理方式</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">R</span> {
    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">string</span>: <span class="hljs-title class_">String</span> {
        <span class="hljs-keyword">case</span> add <span class="hljs-operator">=</span> <span class="hljs-string">"添加"</span>
    }
    
    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">image</span>: <span class="hljs-title class_">String</span> {
        <span class="hljs-keyword">case</span> logo
    }
    
    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">segue</span>: <span class="hljs-title class_">String</span> {
        <span class="hljs-keyword">case</span> login_main
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">ViewController</span>: <span class="hljs-title class_">UIViewController</span> {

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">viewDidLoad</span>() {
        <span class="hljs-keyword">super</span>.viewDidLoad()
        
        <span class="hljs-keyword">let</span> img <span class="hljs-operator">=</span> <span class="hljs-type">UIImage</span>(named: <span class="hljs-type">R</span>.image.logo)

        <span class="hljs-keyword">let</span> btn <span class="hljs-operator">=</span> <span class="hljs-type">UIButton</span>(type: .custom)
        btn.setTitle(<span class="hljs-type">R</span>.string.add, for: .normal)

        performSegue(withIdentifier: <span class="hljs-type">R</span>.segue.login_main, sender: <span class="hljs-keyword">self</span>)
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">UIImage</span> {
    <span class="hljs-keyword">convenience</span> <span class="hljs-keyword">init?</span>(<span class="hljs-params">named</span> <span class="hljs-params">name</span>: <span class="hljs-type">R</span>.image) {
        <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(named: name.rawValue)
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">UIViewController</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">performSegue</span>(<span class="hljs-params">withIdentifier</span> <span class="hljs-params">identifier</span>: <span class="hljs-type">R</span>.segue, <span class="hljs-params">sender</span>: <span class="hljs-keyword">Any</span><span class="hljs-operator">?</span>) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">UIButton</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">setTitle</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">title</span>: <span class="hljs-type">R</span>.string, <span class="hljs-params">for</span> <span class="hljs-params">state</span>: <span class="hljs-type">UIControl</span>.<span class="hljs-type">State</span>) {
        setTitle(title.rawValue, for: state)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>资源名管理的其他思路</p>
<p>原始写法如下</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> img <span class="hljs-operator">=</span> <span class="hljs-type">UIImage</span>(named: <span class="hljs-string">"logo"</span>)
<span class="hljs-keyword">let</span> font <span class="hljs-operator">=</span> <span class="hljs-type">UIFont</span>(name: <span class="hljs-string">"Arial"</span>, size: <span class="hljs-number">14</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">enum</span> <span class="hljs-title class_">R</span> {
    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">image</span> {
        <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> logo <span class="hljs-operator">=</span> <span class="hljs-type">UIImage</span>(named: <span class="hljs-string">"logo"</span>)
    }
    
    <span class="hljs-keyword">enum</span> <span class="hljs-title class_">font</span> {
        <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">arial</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">size</span>: <span class="hljs-type">CGFloat</span>) -&gt; <span class="hljs-type">UIFont</span>? {
            <span class="hljs-type">UIFont</span>(name: <span class="hljs-string">"Arial"</span>, size: size)
        }
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">ViewController</span>: <span class="hljs-title class_">UIViewController</span> {

    <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">viewDidLoad</span>() {
        <span class="hljs-keyword">super</span>.viewDidLoad()
        
        <span class="hljs-keyword">let</span> img <span class="hljs-operator">=</span> <span class="hljs-type">R</span>.image.logo
        <span class="hljs-keyword">let</span> font <span class="hljs-operator">=</span> <span class="hljs-type">R</span>.font.arial(<span class="hljs-number">14</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>更多优秀的思路请参考以下链接：</p>
<ul>
<li><a href="https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fmac-cain13%2FR.swift" target="_blank" title="https://github.com/mac-cain13/R.swift" ref="nofollow noopener noreferrer">github.com/mac-cain13/…</a></li>
<li><a href="https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FSwiftGen%2FSwiftGen" target="_blank" title="https://github.com/SwiftGen/SwiftGen" ref="nofollow noopener noreferrer">github.com/SwiftGen/Sw…</a></li>
</ul>
<h2 data-id="heading-24">17. 多线程开发</h2>
<ul>
<li>利用<code>DispatchWorkItem</code>封装常用多线程执行函数</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">public</span> <span class="hljs-keyword">typealias</span> <span class="hljs-type">Task</span> <span class="hljs-operator">=</span> () -&gt; <span class="hljs-type">Void</span>

<span class="hljs-keyword">public</span> <span class="hljs-keyword">struct</span> <span class="hljs-title class_">Asyncs</span> {
    <span class="hljs-comment">/// 异步执行</span>
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">async</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">task</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>) {
        _async(task)
    }

    <span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">async</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">task</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>,
                             <span class="hljs-keyword">_</span> <span class="hljs-params">mainTask</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>) {
        _async(task, mainTask)
    }
    
    <span class="hljs-comment">/// 主线程延迟执行</span>
    <span class="hljs-keyword">@discardableResult</span>
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">delay</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">seconds</span>: <span class="hljs-type">Double</span>,
                             <span class="hljs-keyword">_</span> <span class="hljs-params">block</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>) -&gt; <span class="hljs-type">DispatchWorkItem</span> {
        <span class="hljs-keyword">let</span> item <span class="hljs-operator">=</span> <span class="hljs-type">DispatchWorkItem</span>(block: block)
        <span class="hljs-type">DispatchQueue</span>.main.asyncAfter(deadline: <span class="hljs-type">DispatchTime</span>.now() <span class="hljs-operator">+</span> seconds, execute: item)
        
        <span class="hljs-keyword">return</span> item
    }
    
    <span class="hljs-comment">/// 异步延迟执行</span>
    <span class="hljs-keyword">@discardableResult</span>
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">asyncDelay</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">seconds</span>: <span class="hljs-type">Double</span>,
                                  <span class="hljs-keyword">_</span> <span class="hljs-params">task</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>) -&gt; <span class="hljs-type">DispatchWorkItem</span> {
        _asyncDelay(seconds, task)
    }
    
    <span class="hljs-keyword">@discardableResult</span>
    <span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">asyncDelay</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">seconds</span>: <span class="hljs-type">Double</span>,
                                  <span class="hljs-keyword">_</span> <span class="hljs-params">task</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>,
                                  <span class="hljs-keyword">_</span> <span class="hljs-params">mainTask</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>) -&gt; <span class="hljs-type">DispatchWorkItem</span> {
        _asyncDelay(seconds, task, mainTask)
    }
}

<span class="hljs-comment">// MARK: - 私有API</span>
<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Asyncs</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">_async</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">task</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>,
                               <span class="hljs-keyword">_</span> <span class="hljs-params">mainTask</span>: <span class="hljs-type">Task</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>) {
        <span class="hljs-keyword">let</span> item <span class="hljs-operator">=</span> <span class="hljs-type">DispatchWorkItem</span>(block: task)
        <span class="hljs-type">DispatchQueue</span>.global().async(execute: item)
        
        <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> main <span class="hljs-operator">=</span> mainTask {
            item.notify(queue: <span class="hljs-type">DispatchQueue</span>.main, execute: main)
        }
    }
    
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">_asyncDelay</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">seconds</span>: <span class="hljs-type">Double</span>,
                                    <span class="hljs-keyword">_</span> <span class="hljs-params">task</span>: <span class="hljs-keyword">@escaping</span> <span class="hljs-type">Task</span>,
                                    <span class="hljs-keyword">_</span> <span class="hljs-params">mainTask</span>: <span class="hljs-type">Task</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>) -&gt; <span class="hljs-type">DispatchWorkItem</span> {
        <span class="hljs-keyword">let</span> item <span class="hljs-operator">=</span> <span class="hljs-type">DispatchWorkItem</span>(block: task)
        <span class="hljs-type">DispatchQueue</span>.global().asyncAfter(deadline: <span class="hljs-type">DispatchTime</span>.now() <span class="hljs-operator">+</span> seconds, execute: item)
        
        <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> main <span class="hljs-operator">=</span> mainTask {
            item.notify(queue: <span class="hljs-type">DispatchQueue</span>.main, execute: main)
        }
        
        <span class="hljs-keyword">return</span> item
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>dispatch_once</code>在Swift中已被废弃，取而代之的是用<code>类型属性</code>或者<code>全局变量\常量</code></li>
<li>默认自带<code>lazy+dispatch_once</code>效果</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">fileprivate</span> <span class="hljs-keyword">let</span> initTask2: <span class="hljs-type">Void</span> <span class="hljs-operator">=</span> {
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"initTask2"</span>)
}()

<span class="hljs-keyword">class</span> <span class="hljs-title class_">ViewController</span>: <span class="hljs-title class_">UIViewController</span> {
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">let</span> initTask1: <span class="hljs-type">Void</span> <span class="hljs-operator">=</span> {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"initTask1------------"</span>)
    }()
    
    <span class="hljs-keyword">override</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">viewDidLoad</span>() {
        <span class="hljs-keyword">super</span>.viewDidLoad()
        
        
        <span class="hljs-keyword">let</span> <span class="hljs-keyword">_</span> <span class="hljs-operator">=</span> <span class="hljs-keyword">Self</span>.initTask1
        <span class="hljs-keyword">let</span> <span class="hljs-keyword">_</span> <span class="hljs-operator">=</span> initTask2
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>多个线程操作同一份数据会有资源抢夺问题，需要进行加锁</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">Cache</span> {
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> data <span class="hljs-operator">=</span> [<span class="hljs-type">String</span> : <span class="hljs-keyword">Any</span>]()
    <span class="hljs-keyword">private</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> lock <span class="hljs-operator">=</span> <span class="hljs-type">DispatchSemaphore</span>(value: <span class="hljs-number">1</span>)
    
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">set</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">key</span>: <span class="hljs-type">String</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-keyword">Any</span>) {
        lock.wait()
        <span class="hljs-keyword">defer</span> { lock.signal() }
        data[key] <span class="hljs-operator">=</span> value
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">private</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> lock <span class="hljs-operator">=</span> <span class="hljs-type">NSLock</span>()
<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">set</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">key</span>: <span class="hljs-type">String</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-keyword">Any</span>) {
    lock.lock()
    <span class="hljs-keyword">defer</span> {
        lock.unlock()
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">private</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> lock <span class="hljs-operator">=</span> <span class="hljs-type">NSRecursiveLock</span>()
<span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">set</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">key</span>: <span class="hljs-type">String</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-keyword">Any</span>) {
    lock.lock()
    <span class="hljs-keyword">defer</span> {
        lock.unlock()
    }
}
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-25">二、函数式编程（Funtional Programming）</h1>
<h2 data-id="heading-26">1. 基本概念</h2>
<p>函数式编程（Funtional Programming，简称FP）是一种编程范式，也就是如何编写程序的方法论</p>
<ul>
<li>主要思想：把计算过程尽量分解成一系列可复用函数的调用</li>
<li>主要特征：”函数的第一等公民“，函数与其他数据类型一样的地位，可以赋值给其他变量，也可以作为函数参数、函数返回值</li>
</ul>
<p>函数式编程最早出现在<code>LISP</code>语言，绝大部分的现代编程语言也对函数式编程做了不同程度的支持，比如<code>Haskell、JavaScript、Swift、Python、Kotlin、Scala</code>等</p>
<p>函数式编程中几个常用概念</p>
<ul>
<li>Higher-Order Function、Function Currying</li>
<li>Functor、Applicative Functor、Monad</li>
</ul>
<p>参考资料：</p>
<ul>
<li><a href="https://link.juejin.cn?target=http%3A%2F%2Fadit.io%2Fposts%2F2013-04-17-functors%2C_applicatives%2C_and_monads_in_pictures.html" target="_blank" title="http://adit.io/posts/2013-04-17-functors,_applicatives,_and_monads_in_pictures.html" ref="nofollow noopener noreferrer">adit.io/posts/2013-…</a></li>
<li><a href="https://link.juejin.cn?target=https%3A%2F%2Fmokacoding.com%2Fblog%2Ffunctor-applicative-monads-in-pictures%2F" target="_blank" title="https://mokacoding.com/blog/functor-applicative-monads-in-pictures/" ref="nofollow noopener noreferrer">mokacoding.com/blog/functo…</a></li>
</ul>
<h2 data-id="heading-27">2. Array的常见操作</h2>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> array <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>]

<span class="hljs-comment">// map：遍历数组，可以将每个元素对应做调整变成新的元素，放入新的数组中</span>
<span class="hljs-keyword">var</span> array2 <span class="hljs-operator">=</span> array.map { <span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span> } <span class="hljs-comment">// [2, 4, 6, 8]</span>

<span class="hljs-comment">// filter：遍历数组，选出符合条件的元素放入新的数组中</span>
<span class="hljs-keyword">var</span> array3 <span class="hljs-operator">=</span> array.filter { <span class="hljs-variable">$0</span> <span class="hljs-operator">%</span> <span class="hljs-number">2</span> <span class="hljs-operator">==</span> <span class="hljs-number">0</span> }

<span class="hljs-comment">// reduce：首先设定一个初始值（0）</span>
<span class="hljs-comment">// $0：上一次遍历返回的结果（0，1，3，10）</span>
<span class="hljs-comment">//$1：每次遍历到的数组元素（1，2，3，4）</span>
<span class="hljs-keyword">var</span> array4 <span class="hljs-operator">=</span> array.reduce(<span class="hljs-number">0</span>) { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-variable">$1</span> } <span class="hljs-comment">// 10</span>
<span class="hljs-keyword">var</span> array5 <span class="hljs-operator">=</span> array.reduce(<span class="hljs-number">0</span>, <span class="hljs-operator">+</span>) <span class="hljs-comment">// 同array4一样 </span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> array <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>]
<span class="hljs-keyword">func</span> <span class="hljs-title function_">double</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">i</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { i <span class="hljs-operator">*</span> <span class="hljs-number">2</span> }

<span class="hljs-built_in">print</span>(array.map(double)) <span class="hljs-comment">// [2, 4, 6, 8]</span>
<span class="hljs-built_in">print</span>(array.map { double(<span class="hljs-variable">$0</span>) }) <span class="hljs-comment">// [2, 4, 6, 8]</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>
<ol>
<li><code>map</code>和<code>flatMap、compactMap</code>的区别</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> arr <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>]
<span class="hljs-keyword">var</span> arr2 <span class="hljs-operator">=</span> arr.map { <span class="hljs-type">Array</span>(repeating: <span class="hljs-variable">$0</span>, count: <span class="hljs-variable">$0</span>) } <span class="hljs-comment">// [[1], [2, 2], [3, 3, 3]]</span>

<span class="hljs-comment">// flatMap会将处理完的新元素都放在同一个数组中</span>
<span class="hljs-keyword">var</span> arr3 <span class="hljs-operator">=</span> arr.flatMap { <span class="hljs-type">Array</span>(repeating: <span class="hljs-variable">$0</span>, count: <span class="hljs-variable">$0</span>) } <span class="hljs-comment">// [1, 2, 2, 3, 3, 3]</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> arr <span class="hljs-operator">=</span> [<span class="hljs-string">"123"</span>, <span class="hljs-string">"test"</span>, <span class="hljs-string">"jack"</span>, <span class="hljs-string">"-30"</span>]
<span class="hljs-keyword">var</span> arr1 <span class="hljs-operator">=</span> arr.map { <span class="hljs-type">Int</span>(<span class="hljs-variable">$0</span>) } <span class="hljs-comment">// [Optional(123), nil, nil, Optional(-30)]</span>
<span class="hljs-keyword">var</span> arr2 <span class="hljs-operator">=</span> arr.compactMap { <span class="hljs-type">Int</span>(<span class="hljs-variable">$0</span>) } <span class="hljs-comment">// [123, -30]</span>
<span class="hljs-keyword">var</span> arr3 <span class="hljs-operator">=</span> arr.flatMap(<span class="hljs-type">Int</span>.<span class="hljs-keyword">init</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="2">
<li>使用<code>reduce</code>分别实现<code>map、filter</code>功能</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> arr <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">4</span>]

<span class="hljs-comment">// map</span>
<span class="hljs-keyword">var</span> arr1 <span class="hljs-operator">=</span> arr.map { <span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span> }
<span class="hljs-built_in">print</span>(arr1)

<span class="hljs-keyword">var</span> arr2 <span class="hljs-operator">=</span> arr.reduce([]) { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> [<span class="hljs-variable">$1</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span>] }
<span class="hljs-built_in">print</span>(arr1)

<span class="hljs-comment">// filter</span>
<span class="hljs-keyword">var</span> arr3 <span class="hljs-operator">=</span> arr.filter { <span class="hljs-variable">$0</span> <span class="hljs-operator">%</span> <span class="hljs-number">2</span> <span class="hljs-operator">==</span> <span class="hljs-number">0</span> }
<span class="hljs-built_in">print</span>(arr3)

<span class="hljs-keyword">var</span> arr4 <span class="hljs-operator">=</span> arr.reduce([]) { <span class="hljs-variable">$1</span> <span class="hljs-operator">%</span> <span class="hljs-number">2</span> <span class="hljs-operator">==</span> <span class="hljs-number">0</span> <span class="hljs-operator">?</span> <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> [<span class="hljs-variable">$1</span>] : <span class="hljs-variable">$0</span> }
<span class="hljs-built_in">print</span>(arr4) 
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="3">
<li><code>lazy</code>的优化</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">let</span> arr <span class="hljs-operator">=</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span>, <span class="hljs-number">3</span>]

<span class="hljs-keyword">let</span> result <span class="hljs-operator">=</span> arr.lazy.map { (i: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> <span class="hljs-keyword">in</span>
    <span class="hljs-built_in">print</span>(<span class="hljs-string">"mapping (i)"</span>)
    <span class="hljs-keyword">return</span> i <span class="hljs-operator">*</span> <span class="hljs-number">2</span>
}

<span class="hljs-built_in">print</span>(<span class="hljs-string">"begin-----"</span>)
<span class="hljs-built_in">print</span>(<span class="hljs-string">"mapped"</span>, result[<span class="hljs-number">0</span>])
<span class="hljs-built_in">print</span>(<span class="hljs-string">"mapped"</span>, result[<span class="hljs-number">1</span>])
<span class="hljs-built_in">print</span>(<span class="hljs-string">"mapped"</span>, result[<span class="hljs-number">2</span>])
<span class="hljs-built_in">print</span>(<span class="hljs-string">"end-----"</span>)

<span class="hljs-comment">//begin-----</span>
<span class="hljs-comment">//mapping 1</span>
<span class="hljs-comment">//mapped 2</span>
<span class="hljs-comment">//mapping 2</span>
<span class="hljs-comment">//mapped 4</span>
<span class="hljs-comment">//mapping 3</span>
<span class="hljs-comment">//mapped 6</span>
<span class="hljs-comment">//end----- </span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
<li>
<ol start="4">
<li><code>Optional</code>的<code>map</code>和<code>flatMap</code><br>
会先将可选类型解包，处理完会再进行包装返回出去</li>
</ol>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num1: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> num2 <span class="hljs-operator">=</span> num1.map { <span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span> } <span class="hljs-comment">// Optional(20)</span>

<span class="hljs-keyword">var</span> num3: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-literal">nil</span>
<span class="hljs-keyword">var</span> num4 <span class="hljs-operator">=</span> num3.map { <span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span> } <span class="hljs-comment">// nil</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num1: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> num2 <span class="hljs-operator">=</span> num1.map { <span class="hljs-type">Optional</span>.some(<span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span>) } <span class="hljs-comment">// Optional(Optional(20))</span>

<span class="hljs-comment">//flatMap发现其为可选项，不会再进行包装</span>
<span class="hljs-keyword">var</span> num3 <span class="hljs-operator">=</span> num1.flatMap { <span class="hljs-type">Optional</span>.some(<span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span>) } <span class="hljs-comment">// Optional(20)</span>
<span class="hljs-keyword">var</span> num4 <span class="hljs-operator">=</span> num1.flatMap { <span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span> } <span class="hljs-comment">// Optional(20)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num1: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> num2 <span class="hljs-operator">=</span> (num1 <span class="hljs-operator">!=</span> <span class="hljs-literal">nil</span>) <span class="hljs-operator">?</span> (num1<span class="hljs-operator">!</span> <span class="hljs-operator">+</span> <span class="hljs-number">10</span>) : <span class="hljs-literal">nil</span> <span class="hljs-comment">// Optional(20)</span>
<span class="hljs-keyword">var</span> num3 <span class="hljs-operator">=</span> num1.map { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-number">10</span> } <span class="hljs-comment">// Optional(20)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> fmt <span class="hljs-operator">=</span> <span class="hljs-type">DateFormatter</span>()
fmt.dateFormat <span class="hljs-operator">=</span> <span class="hljs-string">"yyyy-MM-dd"</span>
<span class="hljs-keyword">var</span> str: <span class="hljs-type">String</span>? <span class="hljs-operator">=</span> <span class="hljs-string">"2011-09-10"</span>
<span class="hljs-keyword">var</span> date1 <span class="hljs-operator">=</span> str <span class="hljs-operator">!=</span> <span class="hljs-literal">nil</span> <span class="hljs-operator">?</span> fmt.date(from: str<span class="hljs-operator">!</span>) : <span class="hljs-literal">nil</span> <span class="hljs-comment">// Optional(2011-09-09 16:00:00 +0000)</span>
<span class="hljs-keyword">var</span> date2 <span class="hljs-operator">=</span> str.flatMap(fmt.date) <span class="hljs-comment">// Optional(2011-09-09 16:00:00 +0000)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> score: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">98</span>
<span class="hljs-keyword">var</span> str1 <span class="hljs-operator">=</span> score <span class="hljs-operator">!=</span> <span class="hljs-literal">nil</span> <span class="hljs-operator">?</span> <span class="hljs-string">"score is (score!)"</span> : <span class="hljs-string">"No score"</span> <span class="hljs-comment">// score is 98</span>
<span class="hljs-keyword">var</span> str2 <span class="hljs-operator">=</span> score.map { <span class="hljs-string">"score is ($0)"</span>} <span class="hljs-operator">??</span> <span class="hljs-string">"No score"</span> <span class="hljs-comment">// score is 98</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>
}

<span class="hljs-keyword">var</span> items <span class="hljs-operator">=</span> [
    <span class="hljs-type">Person</span>(name: <span class="hljs-string">"jack"</span>, age: <span class="hljs-number">20</span>),
    <span class="hljs-type">Person</span>(name: <span class="hljs-string">"rose"</span>, age: <span class="hljs-number">21</span>),
    <span class="hljs-type">Person</span>(name: <span class="hljs-string">"kate"</span>, age: <span class="hljs-number">22</span>)
]

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getPerson1</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">name</span>: <span class="hljs-type">String</span>) -&gt; <span class="hljs-type">Person</span>? {
    <span class="hljs-comment">// 遍历数组找到对应的索引</span>
    <span class="hljs-keyword">let</span> index <span class="hljs-operator">=</span> items.firstIndex { <span class="hljs-variable">$0</span>.name <span class="hljs-operator">==</span> name }
    <span class="hljs-keyword">return</span> index <span class="hljs-operator">!=</span> <span class="hljs-literal">nil</span> <span class="hljs-operator">?</span> items[index<span class="hljs-operator">!</span>] : <span class="hljs-literal">nil</span>
}

<span class="hljs-keyword">func</span> <span class="hljs-title function_">getPerson2</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">name</span>: <span class="hljs-type">String</span>) -&gt; <span class="hljs-type">Person</span>? {
    items.firstIndex { <span class="hljs-variable">$0</span>.name <span class="hljs-operator">==</span> name }
        .map { items[<span class="hljs-variable">$0</span>] }
}

<span class="hljs-keyword">let</span> p1 <span class="hljs-operator">=</span> getPerson1(<span class="hljs-string">"rose"</span>)
<span class="hljs-keyword">let</span> p2 <span class="hljs-operator">=</span> getPerson2(<span class="hljs-string">"rose"</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">Person</span> {
    <span class="hljs-keyword">var</span> name: <span class="hljs-type">String</span>
    <span class="hljs-keyword">var</span> age: <span class="hljs-type">Int</span>

    <span class="hljs-keyword">init?</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">json</span>: [<span class="hljs-params">String</span> : <span class="hljs-keyword">Any</span>]) {
        <span class="hljs-keyword">guard</span> <span class="hljs-keyword">let</span> name <span class="hljs-operator">=</span> json[<span class="hljs-string">"name"</span>] <span class="hljs-keyword">as?</span> <span class="hljs-type">String</span>,
              <span class="hljs-keyword">let</span> age <span class="hljs-operator">=</span> json[<span class="hljs-string">"age"</span>] <span class="hljs-keyword">as?</span> <span class="hljs-type">Int</span> <span class="hljs-keyword">else</span> { <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span> }

        <span class="hljs-keyword">self</span>.name <span class="hljs-operator">=</span> name
        <span class="hljs-keyword">self</span>.age <span class="hljs-operator">=</span> age
    }
}

<span class="hljs-keyword">var</span> json: <span class="hljs-type">Dictionary</span>? <span class="hljs-operator">=</span> [<span class="hljs-string">"name"</span> : <span class="hljs-string">"Jack"</span>, <span class="hljs-string">"age"</span> : <span class="hljs-number">10</span>]
<span class="hljs-keyword">var</span> p1 <span class="hljs-operator">=</span> json <span class="hljs-operator">!=</span> <span class="hljs-literal">nil</span> <span class="hljs-operator">?</span> <span class="hljs-type">Person</span>(json<span class="hljs-operator">!</span>) : <span class="hljs-literal">nil</span> <span class="hljs-comment">// Optional(__lldb_expr_36.Person(name: "Jack", age: 10)) </span>
<span class="hljs-keyword">var</span> p2 <span class="hljs-operator">=</span> json.flatMap(<span class="hljs-type">Person</span>.<span class="hljs-keyword">init</span>) <span class="hljs-comment">// Optional(__lldb_expr_36.Person(name: "Jack", age: 10))</span>
<span class="copy-code-btn">复制代码</span></code></pre>
</li>
</ul>
<h2 data-id="heading-28">3. 函数式的写法</h2>
<ul>
<li>假如要实现以下功能: <code>[(num + 3) * 5 - 1] % 10 / 2</code></li>
<li>传统写法</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">1</span>

<span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">+</span> v2 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sub</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">-</span> v2 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">multiple</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">*</span> v2 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">divide</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">/</span> v2 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">mod</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">%</span> v2 }

divide(mod(sub(multiple(add(num, <span class="hljs-number">3</span>), <span class="hljs-number">5</span>), <span class="hljs-number">1</span>), <span class="hljs-number">10</span>), <span class="hljs-number">2</span>)
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li>函数式写法</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> v }}
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sub</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">-</span> v }}
<span class="hljs-keyword">func</span> <span class="hljs-title function_">multiple</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> v }}
<span class="hljs-keyword">func</span> <span class="hljs-title function_">divide</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">/</span> v }}
<span class="hljs-keyword">func</span> <span class="hljs-title function_">mod</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">%</span> v }}

<span class="hljs-keyword">infix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">&gt;&gt;&gt;</span> : <span class="hljs-type">AdditionPrecedence</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">&gt;&gt;&gt;&lt;</span><span class="hljs-type">A</span>, <span class="hljs-type">B</span>, <span class="hljs-type">C</span><span class="hljs-operator">&gt;</span>(<span class="hljs-keyword">_</span> f1: <span class="hljs-keyword">@escaping</span> (<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">B</span>,
                  <span class="hljs-keyword">_</span> f2: <span class="hljs-keyword">@escaping</span> (<span class="hljs-type">B</span>) -&gt; <span class="hljs-type">C</span>) -&gt; (<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">C</span> {{ f2(f1(<span class="hljs-variable">$0</span>)) }}

<span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> add(<span class="hljs-number">3</span>) <span class="hljs-operator">&gt;&gt;&gt;</span> multiple(<span class="hljs-number">5</span>) <span class="hljs-operator">&gt;&gt;&gt;</span> sub(<span class="hljs-number">1</span>) <span class="hljs-operator">&gt;&gt;&gt;</span> mod(<span class="hljs-number">10</span>) <span class="hljs-operator">&gt;&gt;&gt;</span> divide(<span class="hljs-number">2</span>)
fn(num) 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-29">4. 高阶函数（Higher-Order Function）</h2>
<p>高阶函数至少满足下列一个条件的函数：</p>
<ul>
<li>接受一个或多个函数作为输入（map、filter、reduce等）</li>
<li>返回一个函数</li>
</ul>
<p>FP中到处都是高阶函数</p>
<h2 data-id="heading-30">5.柯里化（Currying）</h2>
<ul>
<li>什么是柯里化？</li>
<li>将一个接受多参数的函数变换为一系列只接受单个参数的函数
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c65a4b56a69341e4831147a7e9b8de02~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w633" loading="lazy" class="medium-zoom-image"></li>
<li><code>Array、Optional</code>的<code>map</code>方法接收的参数就是一个柯里化函数
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e3c435264b624d8bb4f46d786935e08e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w619" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p>演变示例</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">+</span> v2 }
add(<span class="hljs-number">2</span> <span class="hljs-operator">+</span> <span class="hljs-number">4</span>)

变为函数式的写法：

<span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-keyword">return</span> { v1 <span class="hljs-keyword">in</span>
        <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2
    }
}

add(<span class="hljs-number">4</span>)(<span class="hljs-number">2</span>)

再精简：

<span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {{ v1 <span class="hljs-keyword">in</span> v1 <span class="hljs-operator">+</span> v2 }}
add(<span class="hljs-number">4</span>)(<span class="hljs-number">2</span>)

再精简：

<span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {{ <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> v }}
add(<span class="hljs-number">4</span>)(<span class="hljs-number">2</span>)

柯里化：

<span class="hljs-keyword">func</span> <span class="hljs-title function_">currying</span>&lt;<span class="hljs-type">A</span>, <span class="hljs-type">B</span>, <span class="hljs-type">C</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">fn</span>: <span class="hljs-keyword">@escaping</span> (<span class="hljs-type">A</span>, <span class="hljs-type">B</span>) -&gt; <span class="hljs-type">C</span>) -&gt; (<span class="hljs-type">B</span>) -&gt; (<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">C</span> {{ b <span class="hljs-keyword">in</span> { a <span class="hljs-keyword">in</span> fn(a, b) }}}

<span class="hljs-keyword">let</span> curriedAdd <span class="hljs-operator">=</span> currying(add)
<span class="hljs-built_in">print</span>(curriedAdd(<span class="hljs-number">4</span>)(<span class="hljs-number">2</span>)) 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v3</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">+</span> v2 <span class="hljs-operator">+</span> v3 }
add(<span class="hljs-number">2</span>, <span class="hljs-number">3</span>, <span class="hljs-number">5</span>)

变为函数式的写法：

<span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v3</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {
    <span class="hljs-comment">// v2是3</span>
    <span class="hljs-keyword">return</span> { v2 <span class="hljs-keyword">in</span>
        <span class="hljs-comment">// v1是2</span>
        <span class="hljs-keyword">return</span> { v1 <span class="hljs-keyword">in</span>
            <span class="hljs-keyword">return</span> v1 <span class="hljs-operator">+</span> v2 <span class="hljs-operator">+</span> v3
        }
    }
}

add(<span class="hljs-number">5</span>)(<span class="hljs-number">3</span>)(<span class="hljs-number">2</span>)

再精简：

<span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v3</span>: <span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; (<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> {{ v2 <span class="hljs-keyword">in</span> { v1 <span class="hljs-keyword">in</span> v1 <span class="hljs-operator">+</span> v2 <span class="hljs-operator">+</span> v3 }}}

add(<span class="hljs-number">5</span>)(<span class="hljs-number">3</span>)(<span class="hljs-number">2</span>)

柯里化：

<span class="hljs-keyword">func</span> <span class="hljs-title function_">currying</span>&lt;<span class="hljs-type">A</span>, <span class="hljs-type">B</span>, <span class="hljs-type">C</span>, <span class="hljs-type">D</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">fn</span>: <span class="hljs-keyword">@escaping</span> (<span class="hljs-type">A</span>, <span class="hljs-type">B</span>, <span class="hljs-type">C</span>) -&gt; <span class="hljs-type">D</span>) -&gt; (<span class="hljs-type">C</span>) -&gt; (<span class="hljs-type">B</span>) -&gt; (<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">D</span> {{ c <span class="hljs-keyword">in</span> { b <span class="hljs-keyword">in</span> { a <span class="hljs-keyword">in</span> fn(a, b, c) }}}}

<span class="hljs-keyword">let</span> curriedAdd <span class="hljs-operator">=</span> currying(add)
<span class="hljs-built_in">print</span>(curriedAdd(<span class="hljs-number">10</span>)(<span class="hljs-number">20</span>)(<span class="hljs-number">30</span>)) 
<span class="copy-code-btn">复制代码</span></code></pre>
<p>一开始的示例就可以都保留旧的方法，然后通过柯里化来调用</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">add</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">+</span> v2 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">sub</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">-</span> v2 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">multiple</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">*</span> v2 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">divide</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">/</span> v2 }
<span class="hljs-keyword">func</span> <span class="hljs-title function_">mod</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">v1</span>: <span class="hljs-type">Int</span>, <span class="hljs-keyword">_</span> <span class="hljs-params">v2</span>: <span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span> { v1 <span class="hljs-operator">%</span> v2 }

<span class="hljs-keyword">prefix</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">~&lt;</span><span class="hljs-type">A</span>, <span class="hljs-type">B</span>, <span class="hljs-type">C</span><span class="hljs-operator">&gt;</span>(<span class="hljs-keyword">_</span> fn: <span class="hljs-keyword">@escaping</span> (<span class="hljs-type">A</span>, <span class="hljs-type">B</span>) -&gt; <span class="hljs-type">C</span>) -&gt; (<span class="hljs-type">B</span>) -&gt; (<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">C</span> {{ b <span class="hljs-keyword">in</span> { a <span class="hljs-keyword">in</span> fn(a, b) }}}

<span class="hljs-keyword">infix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">&gt;&gt;&gt;</span> : <span class="hljs-type">AdditionPrecedence</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">&gt;&gt;&gt;&lt;</span><span class="hljs-type">A</span>, <span class="hljs-type">B</span>, <span class="hljs-type">C</span><span class="hljs-operator">&gt;</span>(<span class="hljs-keyword">_</span> f1: <span class="hljs-keyword">@escaping</span> (<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">B</span>,
                  <span class="hljs-keyword">_</span> f2: <span class="hljs-keyword">@escaping</span> (<span class="hljs-type">B</span>) -&gt; <span class="hljs-type">C</span>) -&gt; (<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">C</span> {{ f2(f1(<span class="hljs-variable">$0</span>)) }}

<span class="hljs-keyword">var</span> num <span class="hljs-operator">=</span> <span class="hljs-number">1</span>
<span class="hljs-keyword">var</span> fn <span class="hljs-operator">=</span> (<span class="hljs-operator">~</span>add)(<span class="hljs-number">3</span>) <span class="hljs-operator">&gt;&gt;&gt;</span> (<span class="hljs-operator">~</span>multiple)(<span class="hljs-number">5</span>) <span class="hljs-operator">&gt;&gt;&gt;</span> (<span class="hljs-operator">~</span>sub)(<span class="hljs-number">1</span>) <span class="hljs-operator">&gt;&gt;&gt;</span> (<span class="hljs-operator">~</span>mod)(<span class="hljs-number">10</span>) <span class="hljs-operator">&gt;&gt;&gt;</span> (<span class="hljs-operator">~</span>divide)(<span class="hljs-number">2</span>)
fn(num) 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-31">6.函子（Functor）</h2>
<ul>
<li>像<code>Array、Optional</code>这样支持<code>map运算</code>的类型，称为函子（Functor）
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a65a70a9420e450e888edc51d3ce8fd2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w619" loading="lazy" class="medium-zoom-image">
<img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3dc25bf331ae44c99d28f270dec602bf~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w601" loading="lazy" class="medium-zoom-image"></li>
</ul>
<p>下图充分解释了函子</p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b3eff77056f149afac3c5e1a2c6b7304~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w910" loading="lazy" class="medium-zoom-image"></p>
<h2 data-id="heading-32">7. 适用函子（Applicative Functor）</h2>
<p>对任意一个函子<code>F</code>，如果能支持以下运算，该函子就是一个适用函子</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">pure</span>&lt;<span class="hljs-type">A</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-type">A</span>) -&gt; <span class="hljs-type">F</span>&lt;<span class="hljs-type">A</span>&gt;
<span class="hljs-keyword">func</span> <span class="hljs-title function_">&lt;*&gt;&lt;</span><span class="hljs-type">A</span>, <span class="hljs-type">B</span><span class="hljs-operator">&gt;</span>(fn: <span class="hljs-type">F</span>&lt;(<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">B</span>&gt;, value: <span class="hljs-type">F</span>&lt;<span class="hljs-type">A</span>&gt;) -&gt; <span class="hljs-type">F</span>&lt;<span class="hljs-type">B</span>&gt;
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>Optional</code>可以成为适用函子</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">pure</span>&lt;<span class="hljs-type">A</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-type">A</span>) -&gt; <span class="hljs-type">A</span>? { value }

<span class="hljs-keyword">infix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">&lt;*&gt;</span> : <span class="hljs-type">AdditionPrecedence</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">&lt;*&gt;&lt;</span><span class="hljs-type">A</span>, <span class="hljs-type">B</span><span class="hljs-operator">&gt;</span>(fn: ((<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">B</span>)<span class="hljs-operator">?</span>, value: <span class="hljs-type">A</span>?) -&gt; <span class="hljs-type">B</span>? {
    <span class="hljs-keyword">guard</span> <span class="hljs-keyword">let</span> f <span class="hljs-operator">=</span> fn, <span class="hljs-keyword">let</span> v <span class="hljs-operator">=</span> value <span class="hljs-keyword">else</span> { <span class="hljs-keyword">return</span> <span class="hljs-literal">nil</span> }
    <span class="hljs-keyword">return</span> f(v)
}

<span class="hljs-keyword">var</span> value: <span class="hljs-type">Int</span>? <span class="hljs-operator">=</span> <span class="hljs-number">10</span>
<span class="hljs-keyword">var</span> fn: ((<span class="hljs-type">Int</span>) -&gt; <span class="hljs-type">Int</span>)<span class="hljs-operator">?</span> <span class="hljs-operator">=</span> { <span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span> }
<span class="hljs-built_in">print</span>(fn <span class="hljs-operator">&lt;*&gt;</span> value <span class="hljs-keyword">as</span> <span class="hljs-keyword">Any</span>) <span class="hljs-comment">// Optional(20)</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>Array</code>可以成为适用函子</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">pure</span>&lt;<span class="hljs-type">A</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-type">A</span>) -&gt; [<span class="hljs-type">A</span>] { [value] }

<span class="hljs-keyword">infix</span> <span class="hljs-keyword">operator</span> <span class="hljs-title">&lt;*&gt;</span> : <span class="hljs-type">AdditionPrecedence</span>
<span class="hljs-keyword">func</span> <span class="hljs-title function_">&lt;*&gt;&lt;</span><span class="hljs-type">A</span>, <span class="hljs-type">B</span><span class="hljs-operator">&gt;</span>(fn: [(<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">B</span>], value: [<span class="hljs-type">A</span>]) -&gt; [<span class="hljs-type">B</span>] {
    <span class="hljs-keyword">var</span> arr: [<span class="hljs-type">B</span>] <span class="hljs-operator">=</span> []
    <span class="hljs-keyword">if</span> fn.count <span class="hljs-operator">==</span> value.count {
        <span class="hljs-keyword">for</span> i <span class="hljs-keyword">in</span> fn.startIndex<span class="hljs-operator">..&lt;</span>fn.endIndex {
            arr.append(fn[i](value[i]))
        }
    }
    
    <span class="hljs-keyword">return</span> arr
}

<span class="hljs-built_in">print</span>(pure(<span class="hljs-number">10</span>)) <span class="hljs-comment">// [10]</span>

<span class="hljs-keyword">var</span> arr <span class="hljs-operator">=</span> [{ <span class="hljs-variable">$0</span> <span class="hljs-operator">*</span> <span class="hljs-number">2</span> }, { <span class="hljs-variable">$0</span> <span class="hljs-operator">+</span> <span class="hljs-number">10</span> }, { <span class="hljs-variable">$0</span> <span class="hljs-operator">-</span> <span class="hljs-number">5</span> }] <span class="hljs-operator">&lt;*&gt;</span> [<span class="hljs-number">1</span>, <span class="hljs-number">2</span> , <span class="hljs-number">3</span>]
<span class="hljs-built_in">print</span>(arr) <span class="hljs-comment">// [2, 12, -2]</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-33">8.单子（Monad）</h2>
<p>对任意一共类型<code>F</code>，如果能支持以下运算，那么就可以称为是一个单子</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">pure</span>&lt;<span class="hljs-type">A</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-type">A</span>) -&gt; <span class="hljs-type">F</span>&lt;<span class="hljs-type">A</span>&gt;
<span class="hljs-keyword">func</span> <span class="hljs-title function_">flatMap</span>&lt;<span class="hljs-type">A</span>, <span class="hljs-type">B</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-type">F</span>&lt;<span class="hljs-type">A</span>&gt;, <span class="hljs-keyword">_</span> <span class="hljs-params">fn</span>: (<span class="hljs-type">A</span>) -&gt; <span class="hljs-type">F</span>&lt;<span class="hljs-type">B</span>&gt;) -&gt; <span class="hljs-type">F</span>&lt;<span class="hljs-type">B</span>&gt;
<span class="copy-code-btn">复制代码</span></code></pre>
<p>很显然，<code>Array、Optional</code>都是单子</p>
<h1 data-id="heading-34">三、面向协议编程（Protocol Oriented Programming）</h1>
<h2 data-id="heading-35">1. 基本概念</h2>
<p>面向协议编程（Protocol Oriented Programming，简称POP）</p>
<ul>
<li>是Swift的一种编程范式，<code>Apple</code>于2015年<code>WWDC</code>提出</li>
<li>在Swift标准库中，能见到大量<code>POP</code>的影子
同时，Swift也是一门面向对象的编程语言（Object Oriented Programming，简称OOP）</li>
</ul>
<p>在Swift开发中，<code>OOP</code>和<code>POP</code>是相辅相成的，任何一方并不能取代另一方</p>
<p><code>POP</code>能弥补<code>OOP</code>一些设计上的不足</p>
<h2 data-id="heading-36">2.OOP和POP</h2>
<p><strong>回顾OOP</strong></p>
<ul>
<li><code>OOP</code>的三大特性：<code>封装</code>、<strong>继承</strong>、<code>多态</code></li>
<li>继承的经典使用场合:<br>
当多个类（比如A、B、C类）具有很大共性时，可以将这些共性抽取到一个父类中（比如D类），最后A、B、C类继承D类</li>
</ul>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/346429b4d3da44dd9518b93f365e4cb4~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w514" loading="lazy" class="medium-zoom-image"></p>
<ul>
<li><strong>OOP的不足</strong></li>
<li>但有些问题，使用<code>OOP</code>并不能很好解决，比如如何将BVC、DVC的<code>公共方法run</code>抽出来</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">class</span> <span class="hljs-title class_">BVC</span>: <span class="hljs-title class_">UIViewController</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"run"</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">DVC</span>: <span class="hljs-title class_">UITableViewController</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"run"</span>)
    }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><strong>基于<code>OOP</code>想到的一些解决方案：</strong></li>
</ul>
<p>1.将<code>run方法</code>放到另一个对象A中，然后BVC、DVC拥有对象A属性</p>
<ul>
<li>多了一些额外的依赖关系</li>
</ul>
<p>2.将<code>run方法</code>增加到<code>UIViewController分类</code>中</p>
<ul>
<li><code>UIViewController</code>会越来越臃肿，而且会影响它的其他所有子类</li>
</ul>
<p>3.将<code>run方法</code>抽取到新的父类，采用多继承（<code>C++</code>支持多继承）</p>
<ul>
<li>会增加程序设计的复杂度，产生菱形继承等问题，需要开发者额外解决</li>
</ul>
<p><strong>POP的解决方案</strong></p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">protocol</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>()
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Runnable</span> {
    <span class="hljs-keyword">func</span> <span class="hljs-title function_">run</span>() {
        <span class="hljs-built_in">print</span>(<span class="hljs-string">"run"</span>)
    }
}

<span class="hljs-keyword">class</span> <span class="hljs-title class_">BVC</span>: <span class="hljs-title class_">UIViewController</span>, <span class="hljs-title class_">Runnable</span> {}
<span class="hljs-keyword">class</span> <span class="hljs-title class_">DVC</span>: <span class="hljs-title class_">UITableViewController</span>, <span class="hljs-title class_">Runnable</span> {} 
<span class="copy-code-btn">复制代码</span></code></pre>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/73c69593f53f4225ab370615f9449cee~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w447" loading="lazy" class="medium-zoom-image"></p>
<p><strong>POP的注意点</strong></p>
<ul>
<li>优先考虑创建协议，而不是父类（基类）</li>
<li>优先考虑值类型（struct、enum），而不是引用类型（class）</li>
<li>巧用协议的扩展功能</li>
<li>不要为了面向协议而使用协议</li>
</ul>
<h2 data-id="heading-37">3.POP的应用</h2>
<p>下面我们利用协议来实现前缀效果</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">var</span> string <span class="hljs-operator">=</span> <span class="hljs-string">"123fdsf434"</span>

<span class="hljs-keyword">protocol</span> <span class="hljs-title class_">NameSpaceWrapperProtocol</span> {
    <span class="hljs-keyword">associatedtype</span> <span class="hljs-type">WrappedType</span>
    <span class="hljs-keyword">var</span> wrappedValue: <span class="hljs-type">WrappedType</span> { <span class="hljs-keyword">get</span> <span class="hljs-keyword">set</span> }
    
    <span class="hljs-keyword">init</span>(<span class="hljs-params">value</span>: <span class="hljs-type">WrappedType</span>)
}

<span class="hljs-keyword">struct</span> <span class="hljs-title class_">NameSpaceWrapper</span>&lt;<span class="hljs-title class_">T</span>&gt;: <span class="hljs-title class_">NameSpaceWrapperProtocol</span> {
    
    <span class="hljs-keyword">var</span> wrappedValue: <span class="hljs-type">T</span>
    
    <span class="hljs-keyword">init</span>(<span class="hljs-params">value</span>: <span class="hljs-type">T</span>) {
        <span class="hljs-keyword">self</span>.wrappedValue <span class="hljs-operator">=</span> value
    }
}

<span class="hljs-keyword">protocol</span> <span class="hljs-title class_">NamespaceWrappable</span> { }

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">NamespaceWrappable</span> {
    <span class="hljs-keyword">var</span> ll: <span class="hljs-type">NameSpaceWrapper</span>&lt;<span class="hljs-keyword">Self</span>&gt; {
        <span class="hljs-keyword">get</span> { <span class="hljs-type">NameSpaceWrapper</span>(value: <span class="hljs-keyword">self</span>) }
        
        <span class="hljs-keyword">set</span> {}
    }
    
    <span class="hljs-keyword">static</span> <span class="hljs-keyword">var</span> ll: <span class="hljs-type">NameSpaceWrapper</span>&lt;<span class="hljs-keyword">Self</span>&gt;.<span class="hljs-keyword">Type</span> {
        <span class="hljs-keyword">get</span> { <span class="hljs-type">NameSpaceWrapper</span>.<span class="hljs-keyword">self</span> }
        
        <span class="hljs-keyword">set</span> {}
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">NameSpaceWrapperProtocol</span> <span class="hljs-title class_">where</span> <span class="hljs-title class_">WrappedType</span>: <span class="hljs-title class_">ExpressibleByStringLiteral</span> {
    <span class="hljs-keyword">var</span> numberCount: <span class="hljs-type">Int</span> {
        (wrappedValue <span class="hljs-keyword">as?</span> <span class="hljs-type">String</span>)<span class="hljs-operator">?</span>.filter { (<span class="hljs-string">"0"</span><span class="hljs-operator">...</span><span class="hljs-string">"9"</span>).contains(<span class="hljs-variable">$0</span>) }.count <span class="hljs-operator">??</span> <span class="hljs-number">0</span>
    }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">String</span>: <span class="hljs-title class_">NamespaceWrappable</span> {}
<span class="hljs-keyword">extension</span> <span class="hljs-title class_">NSString</span>: <span class="hljs-title class_">NamespaceWrappable</span> {}

<span class="hljs-built_in">print</span>(string.ll.numberCount)
<span class="hljs-built_in">print</span>((string <span class="hljs-keyword">as</span> <span class="hljs-type">NSString</span>).ll.numberCount) <span class="hljs-comment">// 6</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<p>利用协议实现类型判断</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">func</span> <span class="hljs-title function_">isArray</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">value</span>: <span class="hljs-keyword">Any</span>) -&gt; <span class="hljs-type">Bool</span> { value <span class="hljs-keyword">is</span> [<span class="hljs-keyword">Any</span>] }

<span class="hljs-built_in">print</span>(isArray([<span class="hljs-number">1</span>, <span class="hljs-number">2</span>])) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(isArray([<span class="hljs-string">"1"</span>, <span class="hljs-number">2</span>])) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(isArray(<span class="hljs-type">NSArray</span>())) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(isArray(<span class="hljs-type">NSMutableArray</span>())) <span class="hljs-comment">// true</span>


<span class="hljs-keyword">protocol</span> <span class="hljs-title class_">ArrayType</span> {}
<span class="hljs-keyword">func</span> <span class="hljs-title function_">isArrayType</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">type</span>: <span class="hljs-keyword">Any</span>.<span class="hljs-keyword">Type</span>) -&gt; <span class="hljs-type">Bool</span> { type <span class="hljs-keyword">is</span> <span class="hljs-type">ArrayType</span>.<span class="hljs-keyword">Type</span> }

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Array</span>: <span class="hljs-title class_">ArrayType</span> {}
<span class="hljs-keyword">extension</span> <span class="hljs-title class_">NSArray</span>: <span class="hljs-title class_">ArrayType</span> {}

<span class="hljs-built_in">print</span>(isArrayType([<span class="hljs-type">Int</span>].<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(isArrayType([<span class="hljs-keyword">Any</span>].<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(isArrayType(<span class="hljs-type">NSArray</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(isArrayType(<span class="hljs-type">NSMutableArray</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// true</span>
<span class="hljs-built_in">print</span>(isArrayType(<span class="hljs-type">String</span>.<span class="hljs-keyword">self</span>)) <span class="hljs-comment">// false</span>
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-38">四、响应式编程（Reactive Programming）</h1>
<h2 data-id="heading-39">1. 基本概念</h2>
<p>响应式编程（Reactive Programming，简称RP），是一种编程范式，于1997年提出，可以简化异步编程，提供更优雅的数据绑定</p>
<p>一般与函数式融合在一起，所以也会叫做：函数响应式编程（Functional Reactive Programming，简称FRP）</p>
<p>比较著名的、成熟的响应式框架</p>
<ul>
<li><strong>ReactiveCocoa</strong>：简称RAC，有Objective-C、Swift版本</li>
<li><strong>ReactiveX</strong>：简称Rx，有众多编程语言版本，比如RxJava、RxKotlin、RxJS、RxCpp、RxPHP、RxGo、RxSwift等</li>
</ul>
<h2 data-id="heading-40">2. RxSwift</h2>
<p><code>RxSwift</code>（ReactiveX for Swift），<code>ReactiveX</code>的<code>Swift</code>版本</p>
<p>源码： <a href="https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FReactiveX%2FRxSwift" title="https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2FReactiveX%2FRxSwift" target="_blank">github.com/ReactiveX/R…</a> <a href="https://link.juejin.cn?target=https%3A%2F%2Fbeeth0ven.github.io%2FRxSwift-Chinese-Documentation%2F" title="https://link.juejin.cn?target=https%3A%2F%2Fbeeth0ven.github.io%2FRxSwift-Chinese-Documentation%2F" target="_blank">beeth0ven.github.io/RxSwift-Chi…</a></p>
<h1 data-id="heading-41">五、Swift源码分析</h1>
<p>我们通过分析<code>Swift标准库源码</code>来更近一步了解Swift的语法</p>
<h2 data-id="heading-42">1.Array相关</h2>
<p><strong>map、filter</strong>的源码路径:<code>/swift-main/stdlib/public/core/Sequence.swift</code></p>
<p><strong>flatMap、compactMap、reduce</strong>的源码路径:<code>/swift-main/stdlib/public/core/SequenceAlgorithms.swift</code></p>
<h3 data-id="heading-43">1.1 map</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@inlinable</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">map</span>&lt;<span class="hljs-type">T</span>&gt;(
<span class="hljs-keyword">_</span> <span class="hljs-params">transform</span>: (<span class="hljs-type">Element</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">T</span>
) <span class="hljs-keyword">rethrows</span> -&gt; [<span class="hljs-type">T</span>] {

  <span class="hljs-keyword">let</span> initialCapacity <span class="hljs-operator">=</span> underestimatedCount
  <span class="hljs-keyword">var</span> result <span class="hljs-operator">=</span> <span class="hljs-type">ContiguousArray</span>&lt;<span class="hljs-type">T</span>&gt;()
  result.reserveCapacity(initialCapacity)

  <span class="hljs-keyword">var</span> iterator <span class="hljs-operator">=</span> <span class="hljs-keyword">self</span>.makeIterator()

  <span class="hljs-comment">// Add elements up to the initial capacity without checking for regrowth.</span>
  <span class="hljs-keyword">for</span> <span class="hljs-keyword">_</span> <span class="hljs-keyword">in</span> <span class="hljs-number">0</span><span class="hljs-operator">..&lt;</span>initialCapacity {
    result.append(<span class="hljs-keyword">try</span> transform(iterator.next()<span class="hljs-operator">!</span>))
  }
  
  <span class="hljs-comment">// Add remaining elements, if any.</span>
  <span class="hljs-keyword">while</span> <span class="hljs-keyword">let</span> element <span class="hljs-operator">=</span> iterator.next() {
    <span class="hljs-comment">// 如果element是数组，会把整个数组作为元素加到新数组中</span>
    result.append(<span class="hljs-keyword">try</span> transform(element))
  }
  
  <span class="hljs-keyword">return</span> <span class="hljs-type">Array</span>(result)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-44">1.2  flatMap</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@inlinable</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">flatMap</span>&lt;<span class="hljs-type">SegmentOfResult</span>: <span class="hljs-type">Sequence</span>&gt;(
<span class="hljs-keyword">_</span> <span class="hljs-params">transform</span>: (<span class="hljs-type">Element</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">SegmentOfResult</span>
) <span class="hljs-keyword">rethrows</span> -&gt; [<span class="hljs-type">SegmentOfResult</span>.<span class="hljs-type">Element</span>] {

  <span class="hljs-keyword">var</span> result: [<span class="hljs-type">SegmentOfResult</span>.<span class="hljs-type">Element</span>] <span class="hljs-operator">=</span> []
  <span class="hljs-keyword">for</span> element <span class="hljs-keyword">in</span> <span class="hljs-keyword">self</span> {
    <span class="hljs-comment">// 将数组元素添加到新数组中</span>
    result.append(contentsOf: <span class="hljs-keyword">try</span> transform(element))
  } 
  
  <span class="hljs-keyword">return</span> result
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-45">1.3 filter</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@inlinable</span>
<span class="hljs-keyword">public</span> __consuming <span class="hljs-keyword">func</span> <span class="hljs-title function_">filter</span>(
<span class="hljs-keyword">_</span> <span class="hljs-params">isIncluded</span>: (<span class="hljs-type">Element</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">Bool</span>
) <span class="hljs-keyword">rethrows</span> -&gt; [<span class="hljs-type">Element</span>] {
  <span class="hljs-keyword">return</span> <span class="hljs-keyword">try</span> _filter(isIncluded)
}

<span class="hljs-meta">@_transparent</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">_filter</span>(
<span class="hljs-keyword">_</span> <span class="hljs-params">isIncluded</span>: (<span class="hljs-type">Element</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">Bool</span>
) <span class="hljs-keyword">rethrows</span> -&gt; [<span class="hljs-type">Element</span>] {

  <span class="hljs-keyword">var</span> result <span class="hljs-operator">=</span> <span class="hljs-type">ContiguousArray</span>&lt;<span class="hljs-type">Element</span>&gt;()

  <span class="hljs-keyword">var</span> iterator <span class="hljs-operator">=</span> <span class="hljs-keyword">self</span>.makeIterator()

  <span class="hljs-keyword">while</span> <span class="hljs-keyword">let</span> element <span class="hljs-operator">=</span> iterator.next() {
    <span class="hljs-keyword">if</span> <span class="hljs-keyword">try</span> isIncluded(element) {
      result.append(element)
    }
  }

  <span class="hljs-keyword">return</span> <span class="hljs-type">Array</span>(result)
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-46">1.4 compactMap</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@inlinable</span> <span class="hljs-comment">// protocol-only</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">compactMap</span>&lt;<span class="hljs-type">ElementOfResult</span>&gt;(
<span class="hljs-keyword">_</span> <span class="hljs-params">transform</span>: (<span class="hljs-type">Element</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">ElementOfResult</span>?
) <span class="hljs-keyword">rethrows</span> -&gt; [<span class="hljs-type">ElementOfResult</span>] {
  <span class="hljs-keyword">return</span> <span class="hljs-keyword">try</span> _compactMap(transform)
}

<span class="hljs-keyword">@inlinable</span> <span class="hljs-comment">// protocol-only</span>
<span class="hljs-meta">@inline</span>(__always)
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">_compactMap</span>&lt;<span class="hljs-type">ElementOfResult</span>&gt;(
<span class="hljs-keyword">_</span> <span class="hljs-params">transform</span>: (<span class="hljs-type">Element</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">ElementOfResult</span>?
) <span class="hljs-keyword">rethrows</span> -&gt; [<span class="hljs-type">ElementOfResult</span>] {

  <span class="hljs-keyword">var</span> result: [<span class="hljs-type">ElementOfResult</span>] <span class="hljs-operator">=</span> []
  
  <span class="hljs-keyword">for</span> element <span class="hljs-keyword">in</span> <span class="hljs-keyword">self</span> {
    <span class="hljs-comment">// 会进行解包，只有不为空才会被加到数组中</span>
    <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> newElement <span class="hljs-operator">=</span> <span class="hljs-keyword">try</span> transform(element) {
      result.append(newElement)
    }
  }
  
  <span class="hljs-keyword">return</span> result
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-47">1.5 reduce</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@inlinable</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">reduce</span>&lt;<span class="hljs-type">Result</span>&gt;(
<span class="hljs-keyword">_</span> <span class="hljs-params">initialResult</span>: <span class="hljs-type">Result</span>,
<span class="hljs-keyword">_</span> <span class="hljs-params">nextPartialResult</span>:
(<span class="hljs-keyword">_</span> partialResult: <span class="hljs-type">Result</span>, <span class="hljs-type">Element</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">Result</span>
) <span class="hljs-keyword">rethrows</span> -&gt; <span class="hljs-type">Result</span> {

  <span class="hljs-comment">// 上一次的结果</span>
  <span class="hljs-keyword">var</span> accumulator <span class="hljs-operator">=</span> initialResult
    
  <span class="hljs-keyword">for</span> element <span class="hljs-keyword">in</span> <span class="hljs-keyword">self</span> {
    accumulator <span class="hljs-operator">=</span> <span class="hljs-keyword">try</span> nextPartialResult(accumulator, element)
  }
  
  <span class="hljs-keyword">return</span> accumulator
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-48">2. Substring相关</h2>
<p><strong>Substring</strong>的源码路径:<code>/swift-main/stdlib/public/core/Substring.swift</code></p>
<h3 data-id="heading-49">2.1初始化</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@frozen</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">struct</span> <span class="hljs-title class_">Substring</span>: <span class="hljs-title class_">ConcurrentValue</span> {
  <span class="hljs-keyword">@usableFromInline</span>
  <span class="hljs-keyword">internal</span> <span class="hljs-keyword">var</span> _slice: <span class="hljs-type">Slice</span>&lt;<span class="hljs-type">String</span>&gt;

  <span class="hljs-keyword">@inlinable</span>
  <span class="hljs-keyword">internal</span> <span class="hljs-keyword">init</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">slice</span>: <span class="hljs-type">Slice</span>&lt;<span class="hljs-type">String</span>&gt;) {
    <span class="hljs-keyword">let</span> _guts <span class="hljs-operator">=</span> slice.base._guts
    <span class="hljs-keyword">let</span> start <span class="hljs-operator">=</span> _guts.scalarAlign(slice.startIndex)
    <span class="hljs-keyword">let</span> end <span class="hljs-operator">=</span> _guts.scalarAlign(slice.endIndex)
    
    <span class="hljs-comment">// 保存传进来的字符串的内容和位置</span>
    <span class="hljs-keyword">self</span>._slice <span class="hljs-operator">=</span> <span class="hljs-type">Slice</span>(
      base: slice.base,
      bounds: <span class="hljs-type">Range</span>(_uncheckedBounds: (start, end))) 
    _invariantCheck()
  }

  <span class="hljs-meta">@inline</span>(__always)
  <span class="hljs-keyword">internal</span> <span class="hljs-keyword">init</span>(<span class="hljs-keyword">_</span> <span class="hljs-params">slice</span>: _StringGutsSlice) {
    <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(<span class="hljs-type">String</span>(slice._guts)[slice.range])
  }

  <span class="hljs-comment">/// Creates an empty substring.</span>
  <span class="hljs-keyword">@inlinable</span> <span class="hljs-meta">@inline</span>(__always)
  <span class="hljs-keyword">public</span> <span class="hljs-keyword">init</span>() {
    <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(<span class="hljs-type">Slice</span>())
  }
}

<span class="hljs-keyword">extension</span> <span class="hljs-title class_">Substring</span> {
  <span class="hljs-comment">/// Returns the underlying string from which this Substring was derived.</span>
  <span class="hljs-meta">@_alwaysEmitIntoClient</span>
  
  <span class="hljs-comment">// _slice.base就是初始化传进来的字符串</span>
  <span class="hljs-keyword">public</span> <span class="hljs-keyword">var</span> base: <span class="hljs-type">String</span> { <span class="hljs-keyword">return</span> _slice.base }

  <span class="hljs-keyword">@inlinable</span> <span class="hljs-meta">@inline</span>(__always)
  <span class="hljs-keyword">internal</span> <span class="hljs-keyword">var</span> _wholeGuts: _StringGuts { <span class="hljs-keyword">return</span> base._guts }

  <span class="hljs-keyword">@inlinable</span> <span class="hljs-meta">@inline</span>(__always)

  <span class="hljs-comment">// 从这里也能看出和传进来的String共有的是同一块区域，在这块区域进行偏移获取Substring的内容</span>
  <span class="hljs-keyword">internal</span> <span class="hljs-keyword">var</span> _offsetRange: <span class="hljs-type">Range</span>&lt;<span class="hljs-type">Int</span>&gt; {
    <span class="hljs-keyword">return</span> <span class="hljs-type">Range</span>(
      _uncheckedBounds: (startIndex._encodedOffset, endIndex._encodedOffset))
  }

  <span class="hljs-keyword">#if</span> <span class="hljs-operator">!</span><span class="hljs-type">INTERNAL_CHECKS_ENABLED</span>
  <span class="hljs-keyword">@inlinable</span> <span class="hljs-meta">@inline</span>(__always) <span class="hljs-keyword">internal</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">_invariantCheck</span>() {}
  <span class="hljs-keyword">#else</span>
  <span class="hljs-keyword">@usableFromInline</span> <span class="hljs-meta">@inline</span>(never) <span class="hljs-meta">@_effects</span>(releasenone)
  <span class="hljs-keyword">internal</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">_invariantCheck</span>() {
    <span class="hljs-comment">// Indices are always scalar aligned</span>
    _internalInvariant(
      _slice.startIndex <span class="hljs-operator">==</span> base._guts.scalarAlign(_slice.startIndex) <span class="hljs-operator">&amp;&amp;</span>
      _slice.endIndex <span class="hljs-operator">==</span> base._guts.scalarAlign(_slice.endIndex))

    <span class="hljs-keyword">self</span>.base._invariantCheck()
  }
  <span class="hljs-keyword">#endif</span> <span class="hljs-comment">// INTERNAL_CHECKS_ENABLED</span>
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-50">2.2 append</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Substring</span>: <span class="hljs-title class_">RangeReplaceableCollection</span> {
  <span class="hljs-meta">@_specialize</span>(<span class="hljs-keyword">where</span> <span class="hljs-type">S</span> <span class="hljs-operator">==</span> <span class="hljs-type">String</span>)
  <span class="hljs-meta">@_specialize</span>(<span class="hljs-keyword">where</span> <span class="hljs-type">S</span> <span class="hljs-operator">==</span> <span class="hljs-type">Substring</span>)
  <span class="hljs-meta">@_specialize</span>(<span class="hljs-keyword">where</span> <span class="hljs-type">S</span> <span class="hljs-operator">==</span> <span class="hljs-type">Array</span>&lt;<span class="hljs-type">Character</span>&gt;)
  <span class="hljs-keyword">public</span> <span class="hljs-keyword">init</span>&lt;<span class="hljs-type">S</span>: <span class="hljs-type">Sequence</span>&gt;(<span class="hljs-keyword">_</span> <span class="hljs-params">elements</span>: <span class="hljs-type">S</span>)
  <span class="hljs-keyword">where</span> <span class="hljs-type">S</span>.<span class="hljs-type">Element</span> <span class="hljs-operator">==</span> <span class="hljs-type">Character</span> {
    <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> str <span class="hljs-operator">=</span> elements <span class="hljs-keyword">as?</span> <span class="hljs-type">String</span> {
      <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(str)
      <span class="hljs-keyword">return</span>
    }
    <span class="hljs-keyword">if</span> <span class="hljs-keyword">let</span> subStr <span class="hljs-operator">=</span> elements <span class="hljs-keyword">as?</span> <span class="hljs-type">Substring</span> {
      <span class="hljs-keyword">self</span> <span class="hljs-operator">=</span> subStr
      <span class="hljs-keyword">return</span>
    }
    <span class="hljs-keyword">self</span>.<span class="hljs-keyword">init</span>(<span class="hljs-type">String</span>(elements))
  }

  <span class="hljs-comment">// Substring的拼接</span>
  <span class="hljs-keyword">@inlinable</span> <span class="hljs-comment">// specialize</span>
  <span class="hljs-keyword">public</span> <span class="hljs-keyword">mutating</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">append</span>&lt;<span class="hljs-type">S</span>: <span class="hljs-type">Sequence</span>&gt;(<span class="hljs-params">contentsOf</span> <span class="hljs-params">elements</span>: <span class="hljs-type">S</span>)
  <span class="hljs-keyword">where</span> <span class="hljs-type">S</span>.<span class="hljs-type">Element</span> <span class="hljs-operator">==</span> <span class="hljs-type">Character</span> {

    <span class="hljs-comment">// 拼接时会创建一个新的字符串</span>
    <span class="hljs-keyword">var</span> string <span class="hljs-operator">=</span> <span class="hljs-type">String</span>(<span class="hljs-keyword">self</span>)
    <span class="hljs-keyword">self</span> <span class="hljs-operator">=</span> <span class="hljs-type">Substring</span>() <span class="hljs-comment">// Keep unique storage if possible</span>
    string.append(contentsOf: elements)
    <span class="hljs-keyword">self</span> <span class="hljs-operator">=</span> <span class="hljs-type">Substring</span>(string)
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-51">2.3 lowercased、uppercased</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">extension</span> <span class="hljs-title class_">Substring</span> {
  <span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">lowercased</span>() -&gt; <span class="hljs-type">String</span> {
    <span class="hljs-keyword">return</span> <span class="hljs-type">String</span>(<span class="hljs-keyword">self</span>).lowercased()
  }

  <span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">uppercased</span>() -&gt; <span class="hljs-type">String</span> {
    <span class="hljs-keyword">return</span> <span class="hljs-type">String</span>(<span class="hljs-keyword">self</span>).uppercased()
  }

  <span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">filter</span>(
    <span class="hljs-keyword">_</span> <span class="hljs-params">isIncluded</span>: (<span class="hljs-type">Element</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">Bool</span>
  ) <span class="hljs-keyword">rethrows</span> -&gt; <span class="hljs-type">String</span> {
    <span class="hljs-keyword">return</span> <span class="hljs-keyword">try</span> <span class="hljs-type">String</span>(<span class="hljs-keyword">self</span>.lazy.filter(isIncluded))
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-52">3. Optional相关</h2>
<p><strong>Optional</strong>的源码路径:<code>/swift-main/stdlib/public/core/Optional.swift</code></p>
<h3 data-id="heading-53">3.1 map</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@inlinable</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">map</span>&lt;<span class="hljs-type">U</span>&gt;(
<span class="hljs-keyword">_</span> <span class="hljs-params">transform</span>: (<span class="hljs-type">Wrapped</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">U</span>
) <span class="hljs-keyword">rethrows</span> -&gt; <span class="hljs-type">U</span>? {
  <span class="hljs-keyword">switch</span> <span class="hljs-keyword">self</span> {
  <span class="hljs-keyword">case</span> .some(<span class="hljs-keyword">let</span> y): <span class="hljs-comment">// 先解包进行处理</span>
    <span class="hljs-keyword">return</span> .some(<span class="hljs-keyword">try</span> transform(y)) <span class="hljs-comment">// 然后再包装一层可选类型返回出去</span>
  <span class="hljs-keyword">case</span> .none:
    <span class="hljs-keyword">return</span> .none
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-54">3.2flatMap</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@inlinable</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">flatMap</span>&lt;<span class="hljs-type">U</span>&gt;(
<span class="hljs-keyword">_</span> <span class="hljs-params">transform</span>: (<span class="hljs-type">Wrapped</span>) <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">U</span>?
) <span class="hljs-keyword">rethrows</span> -&gt; <span class="hljs-type">U</span>? {
  <span class="hljs-keyword">switch</span> <span class="hljs-keyword">self</span> {
  <span class="hljs-keyword">case</span> .some(<span class="hljs-keyword">let</span> y): <span class="hljs-comment">// 先进行解包</span>
    <span class="hljs-keyword">return</span> <span class="hljs-keyword">try</span> transform(y) <span class="hljs-comment">// 将解包后的处理完直接给出去</span>
  <span class="hljs-keyword">case</span> .none:
    <span class="hljs-keyword">return</span> .none
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-55">3.3 ==</h3>
<ul>
<li><code>==</code>两边都为<code>可选项</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">@inlinable</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">==</span>(<span class="hljs-params">lhs</span>: <span class="hljs-type">Wrapped</span>?, <span class="hljs-params">rhs</span>: <span class="hljs-type">Wrapped</span>?) -&gt; <span class="hljs-type">Bool</span> {
  <span class="hljs-keyword">switch</span> (lhs, rhs) {
    <span class="hljs-keyword">case</span> <span class="hljs-keyword">let</span> (l<span class="hljs-operator">?</span>, r<span class="hljs-operator">?</span>):
      <span class="hljs-keyword">return</span> l <span class="hljs-operator">==</span> r
    <span class="hljs-keyword">case</span> (<span class="hljs-literal">nil</span>, <span class="hljs-literal">nil</span>):
      <span class="hljs-keyword">return</span> <span class="hljs-literal">true</span>
    <span class="hljs-keyword">default</span>:
      <span class="hljs-keyword">return</span> <span class="hljs-literal">false</span>
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>==</code>左边为<code>可选项</code>，右边为<code>nil</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-meta">@_transparent</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">==</span>(<span class="hljs-params">lhs</span>: <span class="hljs-type">Wrapped</span>?, <span class="hljs-params">rhs</span>: _OptionalNilComparisonType) -&gt; <span class="hljs-type">Bool</span> {
  <span class="hljs-keyword">switch</span> lhs {
    <span class="hljs-keyword">case</span> .some:
      <span class="hljs-keyword">return</span> <span class="hljs-literal">false</span>
    <span class="hljs-keyword">case</span> .none:
      <span class="hljs-keyword">return</span> <span class="hljs-literal">true</span>
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>==</code>左边为<code>nil</code>，右边为<code>可选项</code></li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-meta">@_transparent</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">static</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">==</span>(<span class="hljs-params">lhs</span>: _OptionalNilComparisonType, <span class="hljs-params">rhs</span>: <span class="hljs-type">Wrapped</span>?) -&gt; <span class="hljs-type">Bool</span> {
  <span class="hljs-keyword">switch</span> rhs {
    <span class="hljs-keyword">case</span> .some:
      <span class="hljs-keyword">return</span> <span class="hljs-literal">false</span>
    <span class="hljs-keyword">case</span> .none:
      <span class="hljs-keyword">return</span> <span class="hljs-literal">true</span>
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<ul>
<li><code>_OptionalNilComparisonType</code>是一个遵守<code>ExpressibleByNilLiteral</code>协议的结构体，可以用<code>nil</code>来进行初始化</li>
</ul>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-comment">// 遵守ExpressibleByNilLiteral协议的结构体，可以用nil来进行初始化</span>
<span class="hljs-keyword">@frozen</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">struct</span> <span class="hljs-title class_">_OptionalNilComparisonType</span>: <span class="hljs-title class_">ExpressibleByNilLiteral</span> {
  <span class="hljs-comment">/// Create an instance initialized with `nil`.</span>
  <span class="hljs-meta">@_transparent</span>
  <span class="hljs-keyword">public</span> <span class="hljs-keyword">init</span>(<span class="hljs-params">nilLiteral</span>: ()) {
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h3 data-id="heading-56">3.4 ??</h3>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-meta">@_transparent</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">??</span> &lt;<span class="hljs-type">T</span>&gt;(<span class="hljs-params">optional</span>: <span class="hljs-type">T</span>?, <span class="hljs-params">defaultValue</span>: <span class="hljs-keyword">@autoclosure</span> () <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">T</span>)
    <span class="hljs-keyword">rethrows</span> -&gt; <span class="hljs-type">T</span> {
  <span class="hljs-keyword">switch</span> <span class="hljs-keyword">optional</span> {
  <span class="hljs-keyword">case</span> .some(<span class="hljs-keyword">let</span> value):
    <span class="hljs-keyword">return</span> value
  <span class="hljs-keyword">case</span> .none:
    <span class="hljs-keyword">return</span> <span class="hljs-keyword">try</span> defaultValue()
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-meta">@_transparent</span>
<span class="hljs-keyword">public</span> <span class="hljs-keyword">func</span> <span class="hljs-title function_">??</span> &lt;<span class="hljs-type">T</span>&gt;(<span class="hljs-params">optional</span>: <span class="hljs-type">T</span>?, <span class="hljs-params">defaultValue</span>: <span class="hljs-keyword">@autoclosure</span> () <span class="hljs-keyword">throws</span> -&gt; <span class="hljs-type">T</span>?)
    <span class="hljs-keyword">rethrows</span> -&gt; <span class="hljs-type">T</span>? {
  <span class="hljs-keyword">switch</span> <span class="hljs-keyword">optional</span> {
  <span class="hljs-keyword">case</span> .some(<span class="hljs-keyword">let</span> value):
    <span class="hljs-keyword">return</span> value
  <span class="hljs-keyword">case</span> .none:
    <span class="hljs-keyword">return</span> <span class="hljs-keyword">try</span> defaultValue()
  }
} 
<span class="copy-code-btn">复制代码</span></code></pre>
<h2 data-id="heading-57">4. Metadata相关</h2>
<p>源码路径:</p>
<ul>
<li><code>/swift-main/include/swift/ABI/Metadata.h</code></li>
<li><code>/swift-main/include/swift/ABI/MetadataKind.def</code></li>
<li><code>/swift-main/include/swift/ABI/MetadataValues.h</code></li>
<li><code>/swift-main/include/swift/Reflection/Records.h</code></li>
</ul>
<p>文档路径:</p>
<ul>
<li><code>/swift-main/docs/ABI/TypeMetadata.rst</code></li>
</ul>
<p><strong>Swift中很多类型都有自己的<code>metadata</code></strong></p>
<p><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eaca2dbfa6fc44628c3eee1c30d427a3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp" alt="-w1020" loading="lazy" class="medium-zoom-image"></p>
<p><strong>Class Metadata</strong></p>
<p>我们可以从第三方库<code>KaKaJSON</code>中的<code>ClassType</code>，以及对应<code>Metadata</code>的相关文档来分析<code>Class Metadata</code>信息</p>
<pre><code class="hljs language-swift copyable" lang="swift"><span class="hljs-keyword">struct</span> <span class="hljs-title class_">ClassLayout</span>: <span class="hljs-title class_">ModelLayout</span> {
    <span class="hljs-keyword">let</span> kind: <span class="hljs-type">UnsafeRawPointer</span>
    
    <span class="hljs-comment">/// 指向父类类型的指针</span>
    <span class="hljs-keyword">let</span> superclass: <span class="hljs-keyword">Any</span>.<span class="hljs-keyword">Type</span>
    
    <span class="hljs-comment">/// The cache data is used for certain dynamic lookups; it is owned by the runtime and generally needs to interoperate with Objective-C's use</span>
    <span class="hljs-comment">/// 缓存数据用于某些动态查找；它属于运行时，通常需要与Objective-C的使用进行互操作</span>
    <span class="hljs-keyword">let</span> runtimeReserved0: <span class="hljs-type">UInt</span>
    <span class="hljs-keyword">let</span> runtimeReserved1: <span class="hljs-type">UInt</span>
    
    <span class="hljs-comment">/// The data pointer is used for out-of-line metadata and is generally opaque, except that the compiler sets the low bit in order to indicate that this is a Swift metatype and therefore that the type metadata header is present</span>
    <span class="hljs-keyword">let</span> rodata: <span class="hljs-type">UInt</span>
    
    <span class="hljs-comment">/// Swift-specific class flags</span>
    <span class="hljs-comment">/// 类标志</span>
    <span class="hljs-keyword">let</span> flags: <span class="hljs-type">UInt32</span>
    
    <span class="hljs-comment">/// The address point of instances of this type</span>
    <span class="hljs-comment">/// 实例的地址值</span>
    <span class="hljs-keyword">let</span> instanceAddressPoint: <span class="hljs-type">UInt32</span>

    <span class="hljs-comment">/// The required size of instances of this type. 'InstanceAddressPoint' bytes go before the address point; 'InstanceSize - InstanceAddressPoint' bytes go after it</span>
    <span class="hljs-comment">/// 实例大小</span>
    <span class="hljs-keyword">let</span> instanceSize: <span class="hljs-type">UInt32</span>

    <span class="hljs-comment">/// The alignment mask of the address point of instances of this type</span>
    <span class="hljs-comment">/// 实例对齐掩码</span>
    <span class="hljs-keyword">let</span> instanceAlignMask: <span class="hljs-type">UInt16</span>

    <span class="hljs-comment">/// Reserved for runtime use</span>
    <span class="hljs-comment">/// 运行时保留字段</span>
    <span class="hljs-keyword">let</span> reserved: <span class="hljs-type">UInt16</span>

    <span class="hljs-comment">/// The total size of the class object, including prefix and suffix extents</span>
    <span class="hljs-comment">/// 类对象的大小</span>
    <span class="hljs-keyword">let</span> classSize: <span class="hljs-type">UInt32</span>

    <span class="hljs-comment">/// The offset of the address point within the class object</span>
    <span class="hljs-comment">/// 类对象地址</span>
    <span class="hljs-keyword">let</span> classAddressPoint: <span class="hljs-type">UInt32</span>

    <span class="hljs-comment">// Description is by far the most likely field for a client to try to access directly, so we force access to go through accessors</span>
    <span class="hljs-comment">/// An out-of-line Swift-specific description of the type, or null if this is an artificial subclass.  We currently provide no supported mechanism for making a non-artificial subclass dynamically</span>
    <span class="hljs-keyword">var</span> description: <span class="hljs-type">UnsafeMutablePointer</span>&lt;<span class="hljs-type">ClassDescriptor</span>&gt;
    
    <span class="hljs-comment">/// A function for destroying instance variables, used to clean up after an early return from a constructor. If null, no clean up will be performed and all ivars must be trivial</span>
    <span class="hljs-keyword">let</span> iVarDestroyer: <span class="hljs-type">UnsafeRawPointer</span>
    
    <span class="hljs-keyword">var</span> genericTypeOffset: <span class="hljs-type">Int</span> {
        <span class="hljs-keyword">let</span> descriptor <span class="hljs-operator">=</span> description.pointee
        <span class="hljs-comment">// don't have resilient superclass</span>
        <span class="hljs-keyword">if</span> (<span class="hljs-number">0x4000</span> <span class="hljs-operator">&amp;</span> flags) <span class="hljs-operator">==</span> <span class="hljs-number">0</span> {
            <span class="hljs-keyword">return</span> (flags <span class="hljs-operator">&amp;</span> <span class="hljs-number">0x800</span>) <span class="hljs-operator">==</span> <span class="hljs-number">0</span>
            <span class="hljs-operator">?</span> <span class="hljs-type">Int</span>(descriptor.metadataPositiveSizeInWords <span class="hljs-operator">-</span> descriptor.numImmediateMembers)
            : <span class="hljs-operator">-</span><span class="hljs-type">Int</span>(descriptor.metadataNegativeSizeInWords)
        }
        <span class="hljs-keyword">return</span> <span class="hljs-type">GenenicTypeOffset</span>.wrong
    }
}
<span class="copy-code-btn">复制代码</span></code></pre>
<h1 data-id="heading-58">专题系列文章</h1>
<h3 data-id="heading-59">1.前知识</h3>
<ul>
<li><strong><a href="https://juejin.cn/post/7089043618803122183/" target="_blank" title="https://juejin.cn/post/7089043618803122183/">01-探究iOS底层原理|综述</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7093842449998561316/" target="_blank" title="https://juejin.cn/post/7093842449998561316/">02-探究iOS底层原理|编译器LLVM项目【Clang、SwiftC、优化器、LLVM】</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7095079758844674056" target="_blank" title="https://juejin.cn/post/7095079758844674056">03-探究iOS底层原理|LLDB</a></strong></li>
<li><strong><a href="https://juejin.cn/post/7115302848270696485/" target="_blank" title="https://juejin.cn/post/7115302848270696485/">04-探究iOS底层原理|ARM64汇编</a></strong></li>
</ul>
<h3 data-id="heading-60">2. 基于OC语言探索iOS底层原理</h3>
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
<h3 data-id="heading-61">3. 基于Swift语言探索iOS底层原理</h3>
<p>关于<code>函数</code>、<code>枚举</code>、<code>可选项</code>、<code>结构体</code>、<code>类</code>、<code>闭包</code>、<code>属性</code>、<code>方法</code>、<code>swift多态原理</code>、<code>String</code>、<code>Array</code>、<code>Dictionary</code>、<code>引用计数</code>、<code>MetaData</code>等Swift基本语法和相关的底层原理文章有如下几篇:</p>
<ul>
<li><a href="https://juejin.cn/post/7119020967430455327" target="_blank" title="https://juejin.cn/post/7119020967430455327">Swift5核心语法1-基础语法</a></li>
<li><a href="https://juejin.cn/post/7119510159109390343" target="_blank" title="https://juejin.cn/post/7119510159109390343">Swift5核心语法2-面向对象语法1</a></li>
<li><a href="https://juejin.cn/post/7119513630550261774" target="_blank" title="https://juejin.cn/post/7119513630550261774">Swift5核心语法2-面向对象语法2</a></li>
<li><a href="https://juejin.cn/post/7119714488181325860" target="_blank" title="https://juejin.cn/post/7119714488181325860">Swift5常用核心语法3-其它常用语法</a></li>
<li><a href="https://juejin.cn/post/7119722433589805064" target="_blank" title="https://juejin.cn/post/7119722433589805064">Swift5应用实践常用技术点</a></li>
</ul>
<h1 data-id="heading-62">其它底层原理专题</h1>
<h3 data-id="heading-63">1.底层原理相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7018755998823219213" target="_blank" title="https://juejin.cn/post/7018755998823219213">01-计算机原理|计算机图形渲染原理这篇文章</a></li>
<li><a href="https://juejin.cn/post/7019117942377807908" target="_blank" title="https://juejin.cn/post/7019117942377807908">02-计算机原理|移动终端屏幕成像与卡顿&nbsp;</a></li>
</ul>
<h3 data-id="heading-64">2.iOS相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7019193784806146079" target="_blank" title="https://juejin.cn/post/7019193784806146079">01-iOS底层原理|iOS的各个渲染框架以及iOS图层渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019200157119938590" target="_blank" title="https://juejin.cn/post/7019200157119938590">02-iOS底层原理|iOS动画渲染原理</a></li>
<li><a href="https://juejin.cn/post/7019497906650497061/" target="_blank" title="https://juejin.cn/post/7019497906650497061/">03-iOS底层原理|iOS OffScreen Rendering 离屏渲染原理</a></li>
<li><a href="https://juejin.cn/post/7020613901033144351" target="_blank" title="https://juejin.cn/post/7020613901033144351">04-iOS底层原理|因CPU、GPU资源消耗导致卡顿的原因和解决方案</a></li>
</ul>
<h3 data-id="heading-65">3.webApp相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021035020445810718/" target="_blank" title="https://juejin.cn/post/7021035020445810718/">01-Web和类RN大前端的渲染原理</a></li>
</ul>
<h3 data-id="heading-66">4.跨平台开发方案相关专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021057396147486750/" target="_blank" title="https://juejin.cn/post/7021057396147486750/">01-Flutter页面渲染原理</a></li>
</ul>
<h3 data-id="heading-67">5.阶段性总结:Native、WebApp、跨平台开发三种方案性能比较</h3>
<ul>
<li><a href="https://juejin.cn/post/7021071990723182606/" target="_blank" title="https://juejin.cn/post/7021071990723182606/">01-Native、WebApp、跨平台开发三种方案性能比较</a></li>
</ul>
<h3 data-id="heading-68">6.Android、HarmonyOS页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021840737431978020/" target="_blank" title="https://juejin.cn/post/7021840737431978020/">01-Android页面渲染原理</a></li>
<li><a href="#" title="#">02-HarmonyOS页面渲染原理</a> (<code>待输出</code>)</li>
</ul>
<h3 data-id="heading-69">7.小程序页面渲染专题</h3>
<ul>
<li><a href="https://juejin.cn/post/7021414123346853919" target="_blank" title="https://juejin.cn/post/7021414123346853919">01-小程序框架渲染原理</a></li>
</ul></div></div>