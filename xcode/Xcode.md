# Xcode
### 自动打包到Appstore和蒲公英脚本
先将shell.sh脚本和exportTest.plist、exportAppstore.plist放到工程目录（也可以自己指定，那样的话需要调整路径），执行./shell.sh

shell.sh：
```
#使用方法
if [ ! -d ./IPADir ];
then
mkdir -p IPADir;
fi

#工程绝对路径
project_path=$(cd `dirname $0`; pwd)
#工程名 将XXX替换成自己的工程名
project_name=YCPartner
#scheme名 将XXX替换成自己的sheme名
scheme_name=YCPartner
#打包模式 Debug/Release
development_mode=Debug
#build文件夹路径
build_path=${project_path}/build
#plist文件所在路径
exportOptionsPlistPath=${project_path}/exportTest.plist
#导出.ipa文件所在路径
exportIpaPath=${project_path}/IPADir/${development_mode}

shell字体加粗和设置颜色
echo "\033[32;1m Place enter the number you want to export ? [1:app-store  2:ad-hoc] \033[0m"
##
read number
while([[ $number != 1 ]] && [[ $number != 2 ]])
do
echo "Error! Should enter 1 or 2"
echo "Place enter the number you want to export ? [ 1:app-store 2:ad-hoc] "
read number
done

if [ $number == 1 ];then
development_mode=Release
exportOptionsPlistPath=${project_path}/exportAppstore.plist
else
development_mode=Debug
exportOptionsPlistPath=${project_path}/exportTest.plist
fi

echo "正在清理工程..."
#强制删除build文件夹（该文件夹每次执行脚本会自动生成，但是运行脚本无法自动删除，会报错）
rm -rf build/ 
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit

echo '///--------'
echo '/// 清理完成'
echo '///--------'
echo ''

echo '///-----------'
echo '/// 正在编译工程:'${development_mode}
echo '///-----------'
xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive  -quiet  || exit

echo '///--------'
echo '/// 编译完成'
echo '///--------'
echo ''

echo '///----------'
echo '/// 开始ipa打包'
echo '///----------'
xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

if [ -e $exportIpaPath/$scheme_name.ipa ]; then
echo '///----------'
echo '/// ipa包已导出'
echo '///----------'
open $exportIpaPath
else
echo '///-------------'
echo '/// ipa包导出失败 '
echo '///-------------'
fi
echo '///------------'
echo '/// 打包ipa完成  '
echo '///-----------='
echo ''

echo '///-------------'
echo '/// 开始发布ipa包 '
echo '///-------------'

if [ $number == 1 ];then

#验证并上传到App Store
# 将-u 后面的XXX替换成自己的AppleID的账号，-p后面的是APP专用密码
xcrun altool --validate-app -f ${exportIpaPath}/${scheme_name}.ipa -t iOS -u "liucheng@yunchejinrong.com" -p "xfta-mnoq-kyve-nhvq" --verbose
if [ $? -eq 0 ]; then
    echo "\033[32;1m 校验通过 \033[0m"
    # 执行上传的命令
else
    echo "\033[31;1m 校验失败 \033[0m"
    exit -1;
fi

xcrun altool --upload-app -f ${exportIpaPath}/${scheme_name}.ipa -t iOS -u "liucheng@yunchejinrong.com" -p "xfta-mnoq-kyve-nhvq" --verbose
if [ $? -eq 0 ]; then
    echo "\033[32;1m 上传AppStorte成功 \033[0m"
    # 执行上传的命令
else
    echo "\033[31;1m 上传AppStorte失败 \033[0m"
    exit -1;
fi

else


#上传到蒲公英
uKey="a08620e9fa0fc5bcebf163f6ed51a22a"
#蒲公英上的API Key
apiKey="62c4b6b25f182fd399dad20881bccfd6"
#蒲公英版本更新描述，这里取git最后一条提交记录作为描述
pgyer_desc=`git log -1 --pretty=%B`
#要上传的ipa文件路径
echo $exportIpaPath
#执行上传至蒲公英的命令
echo "++++++++++++++upload+++++++++++++"
curl -F "file=@${exportIpaPath}/${scheme_name}.ipa" -F "uKey=${uKey}" -F "_api_key=${apiKey}" -F "buildUpdateDescription=${pgyer_desc}" http://www.pgyer.com/apiv2/app/upload
if [ $? -eq 0 ]; then
    echo "\033[32;1m 蒲公英上传成功 \033[0m"
    echo "\033[32;1m https://www.pgyer.com/991L \033[0m"
    # 执行上传的命令
else
    echo "\033[31;1m 蒲公英上传失败 \033[0m"
    exit -1;
fi

fi

exit 0
```

exportTest.plist
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
```

exportAppstore.plist
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <true/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>

```

### Xocde 自增build脚本
```
xcrun agvtool next-version -all
```
Build Phases - New Run Script - xcrun agvtool next-version -all

### Xcode14 pods中的resource bundles要指定team

![1920755-35e6116b9558c167.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d81818a12ec149fa91a741d67953e6f0~tplv-k3u1fbpfcp-watermark.image?)

### flutter_pdfview.dart:80:9: Error: Type 'Uint8List' not found.
![截屏2023-03-27 13.36.42.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/234569319b7942788a363e4c973f0719~tplv-k3u1fbpfcp-watermark.image?)
自己看报错，发现是有个叫Uint8List的类型没有找到，和同事比对版本，发现是版本不一致。他么是1.2.5我是1.2.9。切换成1.2.5解决问题。


### Invalid Swift Support - The SwiftSupport folder is empty. Rebuild your app using the current
Project：ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = YES
Pods：ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES = NO

### The iOS deployment target 'IPHONES_DEPLOYMENT_TARGET' is set to 9.0
![截屏2023-03-23 16.46.43.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aeb922a250074876ab0a588e814d1470~tplv-k3u1fbpfcp-watermark.image?)
和Xcode版本不一致，更新podfile版本

```
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

### Signing for xxx required a development team in the Signing & Capabilities editor
![截屏2023-03-23 16.55.28.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0c81c171eb314507ad38ede722f27647~tplv-k3u1fbpfcp-watermark.image?)
给Pods里面的库重新选择Development Team

### The Xcode build system has crashed. Please close
File->Workspace setting->driveData clean

### Target xxx has copy command from ...
![截屏2023-03-22 17.59.47.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/064710057e694ed589cb43f9dcc84a4f~tplv-k3u1fbpfcp-watermark.image?)
因为有framework不支持new build system。切换回build system：legacy build system

### flutter_oscloud_module/.ios/Flutter/engine/Flutter.xcframework/ios-arm64-armv7 failed: No such file or directory

![截屏2023-03-10 11.17.10.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e02feae23a65417c97a3fca3ae80241c~tplv-k3u1fbpfcp-watermark.image?)
engine文件夹下没有Flutter.podspec。找到Flutter.podspec，存入engine文件夹下

### /usr/local/pgp/bin/php: No Such file or directory

![截屏2023-03-09 17.45.17.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4b700c304876421aa49c53f4c7fb841d~tplv-k3u1fbpfcp-watermark.image?)
路径配置错误，重新配置路径

### Team UnKnown Name

![截屏2023-03-09 16.52.46.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9dcb31f7d35540daa332cf88667e7aa3~tplv-k3u1fbpfcp-watermark.image?)
这个位置一直被选中，需要改成当前的证书
![截屏2023-03-09 17.03.17.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7533f06cc88c4e8ca336e4c74a205602~tplv-k3u1fbpfcp-watermark.image?)

### 报错dependency were found, but they required a higher minimum deployment target
![截屏2023-03-04 08.24.09.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6ac4409555dd4c4292d3bd616b25dd38~tplv-k3u1fbpfcp-watermark.image?)
podfile里面修改platform: ios, '13.0'

### multiple command prodict报错
![截屏2023-03-07 08.54.44.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d56727cd86fe47179cc1767291fbb755~tplv-k3u1fbpfcp-watermark.image?)
重新pod install

### flutter在cocoapods里面的依赖配置
![p2.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c07f45f265164604899569ad28b4d05c~tplv-k3u1fbpfcp-watermark.image?)

### 运行模式：
![p1.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3aed1a9b234948d3a5f05ecc30ae8bce~tplv-k3u1fbpfcp-watermark.image?)

### app.framework 找不到
![p3.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/75662530b39940f68102d7df7449362b~tplv-k3u1fbpfcp-watermark.image?)
.ios 文件没有app.framework包，需要添加


### run script脚本里面的文件路径被注销了，导致找不到
![p4.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d795b57655f34fb586ea240e91af3959~tplv-k3u1fbpfcp-watermark.image?)
重新打开脚本


### OC的Pod三方库 调用 Swift的Pod三方库：
1. 在OC库的Pod文件夹下的`.podspec文件`内添加对该Swift库的依赖(例如：`s.dependency 'TestSwift1', ~'0.1.0'`)，
2. 单独调用该Swift库，只需在这个OC文件内导入Swift库头文件即可(例如：`@import RxSwift;`[不要给库文件名添加<>或者""、不要遗漏分号";"] )，
3. 全局调用该Swift库，在该OC库中创建`.h文件`(可以任意命名，但为了保持统一性，命名规则参照桥接文件的命名规则) -> 在OC库的Pod文件夹下的`.podspec文件`中添加对`.h文件`的引用(`s.prefix_header_contents = '#import "该OC库名-Bridging-Header.h"`)  -> 重新pod update工程 -> 该`.h文件`会自动添加到OC库的`Support Files文件夹`下的`.pch文件`中 -> 在`.h文件`内导入Swift库的头文件即可(例如：`@import RxSwift;`[不要给库文件名添加<>或者""、不要遗漏分号";"] )。

### Swift的Pod三方库 调用 OC的Pod三方库：
1. Swift库内混编：在Swift库中进行库内的混编时，创建OC文件后pod update时，OC文件的头文件会被自动添加到该Swift库的`Support Files文件夹`下的`-umbrella.h文件`中 -> 可以直接调用，
2. Swift库内依赖OC库混编：在该Swift库的`Pod文件夹`下的`.podspec文件`内添加依赖OC库(例如：`s.dependency 'AFNetworking, ~'2.3'`) -> 在主工程的`Podfile文件`中对调用的OC库做特殊处理添加(`:modular_headers => true ->` 例如：`pod 'AFNetworking', '2.3', :modular_headers => true`)，

3. 在Swift库内创建.h文件(可以任意命名，但为了保持统一性，命名规则参照桥接文件的命名规则) -> 此处不需要进行头文件的依赖和引用，直接进行pod update 后，该Swift库的`.h文件`会被自动同步添加到该Swift库的`Support Files文件夹`下的-`umbrella.h文件`中 -> 在Swift库内新建的.h文件中添加需要依赖的OC库的头文件(例如：`#import <AFNetworking/AFNetworking.h>`)，

    4. 编译后调用时才会出现自动提示。

### xcode报错：Command Phasescriptexecution failed with a nonzero exit code，下面显示php command not found? 
说明是php环境没有配置，需要配置php

### php指令
查看php版本 php -v
查询可安装的php版本 brew search php
安装指定版本 brew install php@7.4
将第三方仓库加入brew brew tap shivammathur/php
安装PHP brew install shivammathur/php/php@7.4
卸载 brew uninstall php@7.4
重新安装 brew reinstall php@7.4

### homebrew-core is a shallow clone? 
brew update,首先运行git -C /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core fetch --unshallow

### Error: php@7.4 has been disabled because it is a versioned formula? 
1. sudo vim /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core/Formula/php@7.4.rb 
2. 找到disabled，前面加#

### Error: go: undefined method `xxx’ for? 
brew update


### zsh: command not found: php ？ 
1. 添加 PHP 公式 brew tap shivammathur/php 
2. 选择 PHP 版本——本例使用 7.4 brew install shivammathur/php/php@7.4 
3. 链接 PHP 版本 brew link --overwrite --force php@7.4 
4. 重启终端 查看php -v
