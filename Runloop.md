 4.  [28. runloop和线程有什么关系？](https://github.com/shenchunxing/ios_interview_questions/blob/master/Runloop.md#28-runloop和线程有什么关系) 
 5.  [29. runloop的mode作用是什么？](https://github.com/shenchunxing/ios_interview_questions/blob/master/Runloop.md#29-runloop的mode作用是什么) 
 6.  [30. 以+ scheduledTimerWithTimeInterval...的方式触发的timer，在滑动页面上的列表时，timer会暂定回调，为什么？如何解决？](https://github.com/shenchunxing/ios_interview_questions/blob/master/Runloop.md#30-以-scheduledtimerwithtimeinterval的方式触发的timer在滑动页面上的列表时timer会暂定回调为什么如何解决) 
 7.  [31. 猜想runloop内部是如何实现的？](https://github.com/shenchunxing/ios_interview_questions/blob/master/Runloop.md#31-猜想runloop内部是如何实现的) 
 
 ### 28. runloop和线程有什么关系？

总的说来，Run loop，正如其名，loop表示某种循环，和run放在一起就表示一直在运行着的循环。实际上，run loop和线程是紧密相连的，可以这样说run loop是为了线程而生，没有线程，它就没有存在的必要。Run loops是线程的基础架构部分， Cocoa 和 CoreFundation 都提供了 run loop 对象方便配置和管理线程的 run loop （以下都以 Cocoa 为例）。每个线程，包括程序的主线程（ main thread ）都有与之相应的 run loop 对象。

 runloop 和线程的关系：




 1. 主线程的run loop默认是启动的。

 iOS的应用程序里面，程序启动后会有一个如下的main()函数
 
 ```Objective-C
int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
```





 重点是UIApplicationMain()函数，这个方法会为main thread设置一个NSRunLoop对象，这就解释了：为什么我们的应用可以在无人操作的时候休息，需要让它干活的时候又能立马响应。

 2. 对其它线程来说，run loop默认是没有启动的，如果你需要更多的线程交互则可以手动配置和启动，如果线程只是去执行一个长时间的已确定的任务则不需要。

 3. 在任何一个 Cocoa 程序的线程中，都可以通过以下代码来获取到当前线程的 run loop 。


 ```Objective-C
NSRunLoop *runloop = [NSRunLoop currentRunLoop];
```


参考链接：[《Objective-C之run loop详解》](http://blog.csdn.net/wzzvictory/article/details/9237973)。

### 29. runloop的mode作用是什么？

model 主要是用来指定事件在运行循环中的优先级的，分为：


* NSDefaultRunLoopMode（kCFRunLoopDefaultMode）：默认，空闲状态
* UITrackingRunLoopMode：ScrollView滑动时
* UIInitializationRunLoopMode：启动时
* NSRunLoopCommonModes（kCFRunLoopCommonModes）：Mode集合

苹果公开提供的 Mode 有两个：

 1. NSDefaultRunLoopMode（kCFRunLoopDefaultMode）
 2. NSRunLoopCommonModes（kCFRunLoopCommonModes）

讨论区： [《https://github.com/ChenYilong/iOSInterviewQuestions/issues/36》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/36 ) 

### 30. 以+ scheduledTimerWithTimeInterval...的方式触发的timer，在滑动页面上的列表时，timer会暂定回调，为什么？如何解决？

RunLoop只能运行在一种mode下，如果要换mode，当前的loop也需要停下重启成新的。利用这个机制，ScrollView滚动过程中NSDefaultRunLoopMode（kCFRunLoopDefaultMode）的mode会切换到UITrackingRunLoopMode来保证ScrollView的流畅滑动：只能在NSDefaultRunLoopMode模式下处理的事件会影响ScrollView的滑动。

如果我们把一个NSTimer对象以NSDefaultRunLoopMode（kCFRunLoopDefaultMode）添加到主运行循环中的时候,
ScrollView滚动过程中会因为mode的切换，而导致NSTimer将不再被调度。

同时因为mode还是可定制的，所以：

 Timer计时会被scrollView的滑动影响的问题可以通过将timer添加到NSRunLoopCommonModes（kCFRunLoopCommonModes）来解决。代码如下：

```objective-c
// 
// http://weibo.com/luohanchenyilong/ (微博@iOS程序犭袁)
// https://github.com/ChenYilong

//将timer添加到NSDefaultRunLoopMode中
[NSTimer scheduledTimerWithTimeInterval:1.0
     target:self
     selector:@selector(timerTick:)
     userInfo:nil
     repeats:YES];
//然后再添加到NSRunLoopCommonModes里
NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
     target:self
     selector:@selector(timerTick:)
     userInfo:nil
     repeats:YES];
[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
```

如果对本回答有疑问，欢迎参与讨论：  [《第30题，使用dispatch source替换NSTimer #45》]( https://github.com/ChenYilong/iOSInterviewQuestions/issues/45 ) 

### 31. 猜想runloop内部是如何实现的？

> 一般来讲，一个线程一次只能执行一个任务，执行完成后线程就会退出。如果我们需要一个机制，让线程能随时处理事件但并不退出，通常的代码逻辑
是这样的：




    function loop() {
        initialize();
        do {
            var message = get_next_message();
            process_message(message);
        } while (message != quit);
    }


或使用伪代码来展示下:

    // 
    // http://weibo.com/luohanchenyilong/ (微博@iOS程序犭袁)
    // https://github.com/ChenYilong
    int main(int argc, char * argv[]) {
     //程序一直运行状态
     while (AppIsRunning) {
          //睡眠状态，等待唤醒事件
          id whoWakesMe = SleepForWakingUp();
          //得到唤醒事件
          id event = GetEvent(whoWakesMe);
          //开始处理事件
          HandleEvent(event);
     }
     return 0;
    }

参考链接：

 1. [《深入理解RunLoop》](http://blog.ibireme.com/2015/05/18/runloop/#base)
 2. 摘自博文[***CFRunLoop***](https://github.com/ming1016/study/wiki/CFRunLoop)，原作者是[微博@我就叫Sunny怎么了](http://weibo.com/u/1364395395)


