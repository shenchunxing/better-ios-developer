
###  通知的原理
nsnotification发送在什么线程，默认响应就在什么线程，和注册位置无关。所以说NSNotification是线程安全的。

通知是同步的。子线程发送消息，就会变成异步.可以使用addObserverForName：object: queue: usingBlock:。

NSNotificationQueue是异步发送，也就是延迟发送。在同一个线程发送和响应

不移除通知，iOS9.0之后，不会crash，原因：通知中心对观察者的引用是weak

多次添加同一个通知，会导致发送一次这个通知的时候，响应多次通知回调。因为在添加的时候不会做去重操作   

NSNotificationQueue和runloop的关系
     NSNotificationQueue将通知添加到队列中时，其中postringStyle参数就是定义通知调用和runloop状态之间关系。

     该参数的三个可选参数：
     NSPostWhenIdle：runloop空闲的时候回调通知方法
     NSPostASAP：runloop在执行timer事件或sources事件完成的时候回调通知方法
     NSPostNow：runloop立即回调通知方法
     
     NSNotificationQueue只是把通知添加到通知队列，并不会主动发送
     NSNotificationQueue依赖runloop，如果线程runloop没开启就不生效。
     NSNotificationQueue发送通知需要runloop循环中会触发NotifyASAP和NotifyIdle从而调用NSNotificationCenter
     NSNotificationCenter 内部的发送方法其实是同步的，所以NSNotificationQueue的异步发送其实是延迟发送。

      
```Objective-C
 NSNotification ： 存储通知信息，包含NSNotificationName通知名、对象objetct、useInfo字典
 @interface NSNotification : NSObject
  @property (readonly, copy) NSNotificationName name;
 @property (nullable, readonly, retain) id object;
 @property (nullable, readonly, copy) NSDictionary *userInfo;
 ```
NSNotificationCenter ： 单例实现。并且通知中心维护了一个包含所有注册的观察者的集合
  
NSObserverModel:定义了一个观察者模型用于保存观察者，通知消息名，观察者收到通知后执行代码所在的操作队列和执行代码的回调
```Objective-C
 @interface NSObserverModel : NSObject
 @property (nonatomic, strong) id observer;  //观察者对象
 @property (nonatomic, assign) SEL selector;  //执行的方法
 @property (nonatomic, copy) NSString *notificationName; //通知名字
 @property (nonatomic, strong) id object;  //携带参数
 @property (nonatomic, strong) NSOperationQueue *operationQueue;//队列
 @property (nonatomic, copy) OperationBlock block;  //回调
 ```
向通知中心注册观察者，源码如下：
```Objective-C
 - (void)addObserver:(id)observer selector:(SEL)aSelector name:(nullable NSString*)aName object:(nullable id)anObject{
  //如果不存在，那么即创建
     if (![self.obsetvers objectForKey:aName]) {
         NSMutableArray *arrays = [[NSMutableArray alloc]init];
        // 创建数组模型
         NSObserverModel *observerModel = [[NSObserverModel alloc]init];
         observerModel.observer = observer;
         observerModel.selector = aSelector;
         observerModel.notificationName = aName;
         observerModel.object = anObject;
         [arrays addObject:observerModel];
       //填充进入数组
         [self.obsetvers setObject:arrays forKey:aName];
  
  
     }else{
  
         //如果存在，取出来，继续添加减去即可
         NSMutableArray *arrays = (NSMutableArray*)[self.obsetvers objectForKey:aName];
         // 创建数组模型
         NSObserverModel *observerModel = [[NSObserverModel alloc]init];
         observerModel.observer = observer;
         observerModel.selector = aSelector;
         observerModel.notificationName = aName;
         observerModel.object = anObject;
         [arrays addObject:observerModel];
   }
 }
 ```
发送通知
```Objective-C  
 - (void)postNotification:(YFLNotification *)notification
 {
     //name 取出来对应观察者数组，执行任务
     NSMutableArray *arrays = (NSMutableArray*)[self.obsetvers objectForKey:notification.name];
  
     [arrays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
  
         //取出数据模型
         NSObserverModel *observerModel = obj;
         id observer = observerModel.observer;
         SEL secector = observerModel.selector;
  
         if (!observerModel.operationQueue) {
 #pragma clang diagnostic push
 #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             [observer performSelector:secector withObject:notification];
 #pragma clang diagnostic pop
         }else{
  
             //创建任务
             NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
  
                 //这里用block回调出去
                 observerModel.block(notification);
  
             }];
  
             // 如果添加观察者 传入 队列，那么就任务放在队列中执行(子线程异步执行)
             NSOperationQueue *operationQueue = observerModel.operationQueue;
             [operationQueue addOperation:operation];
  
         }
  
     }];
  
 }
```