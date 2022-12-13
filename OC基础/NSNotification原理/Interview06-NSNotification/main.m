//
//  main.m
//  Interview06-NSNotification
//
//  Created by 沈春兴 on 2022/6/28.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        // MARK: - 实现原理（结构设计、通知如何存储的、name & observer & SEL之间的关系等）
        /**
         Observation是通知观察对象，存储通知名、object、SEL的结构体
         NSNotificationCenter持有一个根容器NCTable，根容器里面包含三个张链表

         wildCards，存放没有name & object的通知观察对象（Observation）
         nameless，存放没有name但是有object的通知观察对象（Observation）
         named，存放有name & object的通知观察对象（Observation）


         当添加通知观察的时候，NSNotificationCenter根据传入参数是否齐全，创建Observation并添加到不同链表

         创建一个新的通知观察对象（Observation）
         如果传入参数包含名称，在named表里查询对应名称，如果已经存在同名的通知观察对象，将新的通知观察对象插入其后，如果不存在则添加到表尾。存储结构为链表，节点内先以name作为key，一个字典作为value。如果通知参数带有object，字典内以object为key，以Observation作为value。
         如果传入的参数如果只包含object，在nameless表查询对应名称，将新的通知观察对象插入其后，如果不存在则添加到表尾。存储结构为链表，节点内以object为key，以Observation作为value。
         如果传入参数没有name也没有object，直接添加到wildCards表尾。结构为链表，节点内存储Observation。
         */

        //MARK:通知的底层实现？
        /**
         NSNotification ： 存储通知信息，包含NSNotificationName通知名、对象objetct、useInfo字典
         @interface CHXNotification : NSObject
          @property (readonly, copy) NSNotificationName name;
         @property (nullable, readonly, retain) id object;
         @property (nullable, readonly, copy) NSDictionary *userInfo;

         NSNotificationCenter ： 单例实现。并且通知中心维护了一个包含所有注册的观察者的集合

         NSObserverModel:定义了一个观察者模型用于保存观察者，通知消息名，观察者收到通知后执行代码所在的操作队列和执行代码的回调
         @interface NSObserverModel : NSObject@property (nonatomic, strong) id observer;  //观察者对象
         @property (nonatomic, assign) SEL selector;  //执行的方法
         @property (nonatomic, copy) NSString *notificationName; //通知名字
         @property (nonatomic, strong) id object;  //携带参数
         @property (nonatomic, strong) NSOperationQueue *operationQueue;//队列
         @property (nonatomic, copy) OperationBlock block;  //回调

         向通知中心注册观察者，源码如下：
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

         发送通知
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

         */

        //MARK:为什么说NSNotification是线程安全的？
        /**
         nsnotification发送在什么线程，默认响应就在什么线程，和注册位置无关。
         */

        //MARK:NSNotificationCenter接受消息和发送消息是在一个线程里吗？如何异步发送消息? NSNotificationQueue是异步还是同步发送？在哪个线程响应
        /**
         通知是同步的。
         子线程发送消息，就会变成异步.可以使用addObserverForName：object: queue: usingBlock:
         
         NSNotificationQueue是异步发送，也就是延迟发送。在同一个线程发送和响应
         */

        //MARK: NSNotificationQueue和runloop的关系
        /**
         NSNotificationQueue将通知添加到队列中时，其中postringStyle参数就是定义通知调用和runloop状态之间关系。

         该参数的三个可选参数：
         NSPostWhenIdle：runloop空闲的时候回调通知方法
         NSPostASAP：runloop在执行timer事件或sources事件完成的时候回调通知方法
         NSPostNow：runloop立即回调通知方法
         
         NSNotificationQueue只是把通知添加到通知队列，并不会主动发送
         NSNotificationQueue依赖runloop，如果线程runloop没开启就不生效。
         NSNotificationQueue发送通知需要runloop循环中会触发NotifyASAP和NotifyIdle从而调用NSNotificationCenter
         NSNotificationCenter 内部的发送方法其实是同步的，所以NSNotificationQueue的异步发送其实是延迟发送。
         */

        //MARK:NSNotification如何保证通知接收的线程在主线程？
        /**
         1.使用addObserverForName: object: queue: usingBlock方法注册通知，指定在mainqueue上响应block
         2.通过在主线程的runloop中添加machPort，设置这个port的delegate，通过这个Port其他线程可以跟主线程通信，在这个port的代理回调中执行的代码肯定在主线程中运行，所以，在这里调用NSNotificationCenter发送通知即可
         */

        //MARK:NSNotification多次添加同一个通知会是什么结果？多次移除通知呢？
        /**
         多次添加同一个通知，会导致发送一次这个通知的时候，响应多次通知回调。因为在添加的时候不会做去重操作
         
         因为查找时做了这个链表的遍历，所以删除时会把重复的通知全都删除掉，因此多次移除通知不会产生crash。
         */

        //MARK:NSNotification页面销毁时不移除通知会崩溃吗？
        /**
         iOS9.0之前，会crash，原因：通知中心对观察者的引用是unsafe_unretained，导致当观察者释放的时候，观察者的指针值并不为nil，出现野指针。
         iOS9.0之后，不会crash，原因：通知中心对观察者的引用是weak。
         
         有时候会导致crash
         比如在你通知事件中处理数据或UI事件，但是由于通知的的不确定性造成处理事件的时间不确定，有异步操作在通知事件中处理等都可能造成崩溃。
         */

        // MARK: - 下面的方式能接收到通知吗？为什么？
        /**
         // 注册通知
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:@"TestNotification" object:@1];
         // 发送通知
         [NSNotificationCenter.defaultCenter postNotificationName:@"TestNotification" object:nil];
         不能
         这个通知存储在named表里，原本记录的通知观察对象内部会用object作为字典里的key，查找的时候没了object无法找到对应观察者和处理方法。
         */
    }
    return 0;
}
