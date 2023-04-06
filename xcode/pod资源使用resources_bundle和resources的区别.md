# Pod 库的资源引用 resource_bundles or resources区别
CocoaPods 官方强烈推荐使用 `resource_bundles`，因为可以避免相同名称资源的名称冲突。建议 bundle 的名称至少应该包括 Pod 库的名称，可以尽量减少同名冲突
Examples:

```
spec.ios.resource_bundle = { 'MapBox' => 'MapView/Map/Resources/*.png' } 或 
spec.resource_bundles = { 'MapBox' => ['MapView/Map/Resources/*.png'], 'OtherResources' => ['MapView/Map/OtherResources/*.png'] }
```
## 1.2 resources
使用 `resources` 来指定资源，被指定的资源只会简单的被 copy 到目标工程中（主工程）。
官方认为用 `resources` 是无法避免同名资源文件的冲突的，同时，Xcode 也不会对这些资源做优化。
```
spec.resource = 'Resources/HockeySDK.bundle' 或者
pec.resources = ['Images/*.png', 'Sounds/*']
```
# 2. 图片资源的管理

我们熟知平常用的 @2x @3x 图片是为了缩小用户最终下载时包的大小，通常我们会将图片放在 `.xcassets` 文件中管理，新建的项目也默认创建：
![16164ae8f76d970e~tplv-t2oaga2asx-zoom-in-crop-mark-3024-0-0-0.image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f4b87cfd493742b99f7404060c6e228f~tplv-k3u1fbpfcp-watermark.image?)
使用 `.xcassets` 不仅可以方便在 Xcode 查看和拖入图片，同时 `.xcassets` 最终会打包生成为 `Assets.car` 文件。对于 `Assets.car` 文件，[App Slicing](https://link.juejin.cn?target=https%3A%2F%2Fhelp.apple.com%2Fxcode%2Fmac%2Fcurrent%2F%23%2Fdevbbdc5ce4f "https://help.apple.com/xcode/mac/current/#/devbbdc5ce4f") 会为切割留下符合目标设备分辨率的图片，可以缩小用户最终下载的包的大小。

> **FYI：** [Xcode Ref Asset Catalog Format](https://link.juejin.cn?target=https%3A%2F%2Fdeveloper.apple.com%2Flibrary%2Fcontent%2Fdocumentation%2FXcode%2FReference%2Fxcode_ref-Asset_Catalog_Format%2FFolderStructure.html%23%2F%2Fapple_ref%2Fdoc%2Fuid%2FTP40015170-CH33-SW1 "https://developer.apple.com/library/content/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/FolderStructure.html#//apple_ref/doc/uid/TP40015170-CH33-SW1") [App thinning overview (iOS, tvOS, watchOS)](https://link.juejin.cn?target=https%3A%2F%2Fhelp.apple.com%2Fxcode%2Fmac%2Fcurrent%2F%23%2Fdevbbdc5ce4f "https://help.apple.com/xcode/mac/current/#/devbbdc5ce4f")

实际上，对于 Pods 库的资源，同样可以使用 `.xcassets` 管理。

## 3.1 resource_bundles 是否能使用 *.xcassets 指定资源并正确打包
写两个 Demo Pod，同时创建好对应的 Example 测试工程。对两个 Pod 分别使用不同的方式指定资源。分别用了 `resource_bundles` 和 `resources` 两种方式引用。`pod install` 后，观察结果。
### 3.1.1 使用 resources

`pod install` 并编译 Example 工程后，我们可以打开最后生成的 Product 文件下的内容：

![16164ae8f984320c~tplv-t2oaga2asx-zoom-in-crop-mark-3024-0-0-0.image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7c783051cb53460b9d69108e0ae38252~tplv-k3u1fbpfcp-watermark.image?)
可以看到只有 一些 `.a` 文件，`.a` 文件是二进制文件。初次之外只有 `SubModule-Example.app`，打开包内容，可以看到只有一个 `Assets.car`。
这说明，使用 `resources` 之后只会简单的将资源文件 copy 到目标工程（Example 工程），最后和目标工程的图片文件以及其他同样使用 `resources` 的 Pod 的图片文件，统一一起打包为了一个 `Assets.car`。
使用：
```
UIImage *image = [UIImage imageNamed:@"some-image"
                                inBundle:[NSBundle bundleForClass:[self class]]
           compatibleWithTraitCollection:nil];
```
### 3.1.2 使用 `resource_bundles`
可以看到最终生成了一个 `SubModule_Use_Bundle.bundle`，打开看内部：
 ![16164ae93d1af173~tplv-t2oaga2asx-zoom-in-crop-mark-3024-0-0-0.image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6cb946a02c8843988f1c291716c84929~tplv-k3u1fbpfcp-watermark.image?)
 发现包含了一个 `Assets.car`
使用：
```
NSString *bundlePath = [[NSBundle bundleForClass:[self class]].resourcePath
                            stringByAppendingPathComponent:@"/SubModule_Use_Bundle.bundle"];
NSBundle *resource_bundle = [NSBundle bundleWithPath:bundlePath];
UIImage *image = [UIImage imageNamed:@"some-image"
                                inBundle:resource_bundle
           compatibleWithTraitCollection:nil];
```
### 3.1.3 resources 和 resource_bundles 对于 .xcassets 的支持

从 3.1 和 3.2 可以看出 resources 和 resource_bundles 都可以很好的支持 .xcassets 的引用。

所以，[这篇](https://link.juejin.cn?target=http%3A%2F%2Fblog.xianqu.org%2F2015%2F08%2Fpod-resources%2F "http://blog.xianqu.org/2015/08/pod-resources/") 文章，里面提到 resource_bundles 不能使用 .xcassets 并不存在。应该说这篇文章已经比较老了，**CocoaPods 随着不断的更新，`resource_bundles` 已经可以很好的支持 `.xcassets` 了。**

 ## 3.2 同名资源的冲突问题

从上面的分析可以看出：

使用 `resources` 之后只会简单的将资源文件 copy 到目标工程（Example 工程），最后和目标工程的图片文件以及其他同样使用 `resources` 的 Pod 的图片文件，统一一起打包为了一个 `Assets.car`。

使用 `resource_bundles` 之后会为为指定的资源打一个 `.bundle`，`.bundle`包含一个 `Assets.car`，获取图片的时候要严格指定 `.bundle` 的位置，很好的隔离了各个库或者一个库下的资源包。

显然，使用 `resources`，如果出现同名的图片，显然是会出现冲突的，同样使用 `some-image` 名称的两个图片资源，不一定能正确调用到。

  # 4. 总结

**resource_bundles 优点：**

1.  可以使用 `.xcassets` 指定资源文件
1.  可以避免每个库和主工程之间的同名资源冲突

**resource_bundles 缺点：**

1.  获取图片时可能需要使用硬编码的形式来获取：`[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/SubModule_Use_Bundle.bundle"]`

**resources 优点：**

1.  可以使用 `.xcassets` 指定资源文件

**resources 缺点：**

1.  会导致每个库和主工程之间的同名资源冲突
1.  不需要用硬编码方式获取图片：`[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];`

So，一般来说使用 `resource_bundles` 会更好，不过关于硬编码，还可以再找找别的方式去避免。

