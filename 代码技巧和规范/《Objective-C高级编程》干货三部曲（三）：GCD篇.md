《Objective-C高级编程：iOS与OS X多线程和内存管理》

我们知道在iOS开发中，一共有四种多线程技术：pthread，NSThread，GCD，NSOperation：

*   前两者是面向线程开发的多线程技术，需要开发者自己去维护线程的生命周期，比较繁琐。
*   后两者是面向队列开发的多线程技术，开发者仅仅定义想执行的任务追加到适当的Dispatch Queue（队列）中并设置一些优先级，依赖等操作就可以了，其他的事情可以交给系统来做。

本篇是这一[系列：iOS - 《Objective-C 高级编程》](https://www.jianshu.com/nb/11486967)的最后一篇，讲解了本书的第三章。在这一章里，作者主要介绍了GCD技术，它是基于C语言的API，开发者只需要将任务放在block内，并指定好追加的队列，就可以完成多线程开发。

但是多线程开发时容易发生的一些问题：

*   多个线程更新相同的资源：数据竞争。
*   多个线程相互持续等待：死锁。
*   使用太多的线程导致消耗内存。

虽然解决这些问题的代价是会使程序的复杂度上升，但是多线程技术仍然是必须使用的：因为使用多线程编程可以保证应用程序的响应性能。如果耗时操作阻塞了主线程的RunLoop，会导致用户界面无法响应用户的操作，所以必须开启子线程将耗时操作放在子线程中处理。那么我们应该怎么进行多线程开发呢？在讲解之前先看一下本文结构（GCD部分）：

《Objective-C高级编程》 干货三部曲

本文的Demo地址：[knightsj/iOS\_Demo/gcd\_demo](https://github.com/knightsj/iOS_Demo/tree/master/%5B12%5D.%20gcd_demo)  
虽然文章里应给出了详细的输出结果，但还是希望读者可以将demo下载后仔细对照一下代码并体会。

队列
==

Dispatch Queue是执行处理的等待队列，按照任务（block）追加到队列里的顺序，先进先出执行处理。

而等待队列有两种

*   Serial Dispatch Queue：串行队列，等待当前执行任务处理结束的队列。
*   Concurrent Dispatch Queue:并发队列，不等待当前执行任务处理结束的队列。

串行队列
----

将任务追加到串行队列：

    - (void)serialQueue
    {
        dispatch_queue_t queue = dispatch_queue_create("serial queue", NULL);
        for (NSInteger index = 0; index < 6; index ++) {
            dispatch_async(queue, ^{
                NSLog(@"task index %ld in serial queue",index);
            });
        }
    }
    

输出：

    gcd_demo[33484:2481120] task index 0 in serial queue
    gcd_demo[33484:2481120] task index 1 in serial queue
    gcd_demo[33484:2481120] task index 2 in serial queue
    gcd_demo[33484:2481120] task index 3 in serial queue
    gcd_demo[33484:2481120] task index 4 in serial queue
    gcd_demo[33484:2481120] task index 5 in serial queue
    

> 通过dispatch\_queue\_create函数可以创建队列，第一个函数为队列的名称，第二个参数是`NULL`和`DISPATCH_QUEUE_SERIAL`时，返回的队列就是串行队列。

> 为了避免重复代码，我在这里使用了for循环，将任务追加到了queue中。

> 注意，这里的任务是按照顺序执行的。说明任务是以阻塞的形式执行的：必须等待上一个任务执行完成才能执行现在的任务。也就是说：一个Serial Dispatch Queue中同时只能执行一个追加处理（任务block），而且系统对于一个Serial Dispatch Queue只生成并使用一个线程。

但是，如果我们将6个任务分别追加到6个Serial Dispatch Queue中，那么系统就会同时处理这6个任务（因为会另开启6个子线程）：

    - (void)multiSerialQueue
    {
        for (NSInteger index = 0; index < 10; index ++) {
            //新建一个serial queue
            dispatch_queue_t queue = dispatch_queue_create("different serial queue", NULL);
            dispatch_async(queue, ^{
                NSLog(@"serial queue index : %ld",index);
            });
        }
    }
    

输出结果：

    gcd_demo[33576:2485282] serial queue index : 1
    gcd_demo[33576:2485264] serial queue index : 0
    gcd_demo[33576:2485267] serial queue index : 2
    gcd_demo[33576:2485265] serial queue index : 3
    gcd_demo[33576:2485291] serial queue index : 4
    gcd_demo[33576:2485265] serial queue index : 5
    

> 从输出结果可以看出来，这里的6个任务并不是按顺序执行的。

需要注意的是：一旦开发者新建了一个串行队列，并使用异步函数（dispatch\_async），那么系统一定会开启一个子线程（这里感谢[lmh\_](https://www.jianshu.com/u/810e06f40391)同学指正～），所以在使用串行队列的时候，一定只创建真正需要创建的串行队列，避免资源浪费。

并发队列
----

将任务追加到并发队列：

    - (void)concurrentQueue
    {
        dispatch_queue_t queue = dispatch_queue_create("concurrent queue", DISPATCH_QUEUE_CONCURRENT);
        for (NSInteger index = 0; index < 6; index ++) {
            dispatch_async(queue, ^{
                NSLog(@"task index %ld in concurrent queue",index);
            });
        }
    }
    

输出结果：

    gcd_demo[33550:2484160] task index 1 in concurrent queue
    gcd_demo[33550:2484159] task index 0 in concurrent queue
    gcd_demo[33550:2484162] task index 2 in concurrent queue
    gcd_demo[33550:2484182] task index 3 in concurrent queue
    gcd_demo[33550:2484183] task index 4 in concurrent queue
    gcd_demo[33550:2484160] task index 5 in concurrent queue
    

> 可以看到，dispatch\_queue\_create函数的第二个参数是`DISPATCH_QUEUE_CONCURRENT`。

> 注意，这里追加到并发队列的6个任务并不是按照顺序执行的，符合上面并发队列的定义。

> 扩展知识：iOS和OSX基于Dispatch Queue中的处理数，CPU核数，以及CPU负荷等当前系统的状态来决定Concurrent Dispatch Queue中并发处理的任务数。

队列的命名
-----

现在我们知道dispatch\_queue\_create方法第一个参数指定了这个新建队列的名称，推荐使用逆序quan cheng全程域名(FQDN,fully qualified domain name)。这个名称可以在Xcode和CrashLog中显示出来，对bug的追踪很有帮助。

在继续讲解之前做个小总结，现在我们知道了：

*   如何创建串行队列和并发队列。
*   将任务追加到这两种队列里以后的执行效果。
*   将任务追加到多个串行队列会使这几个任务在不同的线程执行。

实际上，系统给我们提供了两种特殊的队列，分别对应串行队列和并发队列：

系统提供的队列
-------

### Main Dispatch Queue

主队列：放在这个队列里的任务会追加到主线程的RunLoop中执行。需要刷新UI的时候我们可以直接获取这个队列，将任务追加到这个队列中。

### Globle Dispatch Queue

全局并发队列：开发者可以不需要特意通过dispatch\_queue\_create方法创建一个Concurrent Dispatch Queue，可以将任务直接放在这个全局并发队列里面。

有一个常见的例子可以充分体现二者的使用方法：

    //获取全局并发队列进行耗时操作 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
              //加载图片
              NSData *dataFromURL = [NSData dataWithContentsOfURL:imageURL];
              UIImage *imageFromData = [UIImage imageWithData:dataFromURL];
    
          dispatch_async(dispatch_get_main_queue(), ^{
    
                  //获取主队列，在图片加载完成后更新UIImageView
                  UIImageView *imageView = [[UIImageView alloc] initWithImage:imageFromData];          
          });      
      });
    

GCD的各种函数
========

dispatch\_set\_target\_queue
----------------------------

这个函数有两个作用：

1.  改变队列的优先级。
2.  防止多个串行队列的并发执行。

### 改变队列的优先级

dispatch\_queue\_create方法生成的串行队列合并发队列的优先级都是与默认优先级的Globle Dispatch Queue一致。

如果想要变更某个队列的优先级，需要使用dispatch\_set\_target\_queue函数。  
举个🌰：创建一个在后台执行动作处理的Serial Dispatch Queue

    //需求：生成一个后台的串行队列
    - (void)changePriority
    {
        dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
        dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        
        //第一个参数：需要改变优先级的队列；
        //第二个参数：目标队列
        dispatch_set_target_queue(queue, bgQueue);
    }
    

### 防止多个串行队列的并发执行

有时，我们将不能并发执行的处理追加到多个Serial Dispatch Queue中时，可以使用dispatch\_set\_target\_queue函数将目标函数定为某个Serial Dispatch Queue，就可以防止这些处理的并发执行。

代码：

     NSMutableArray *array = [NSMutableArray array];
    for (NSInteger index = 0; index < 5; index ++) {
            //5个串行队列
            dispatch_queue_t serial_queue = dispatch_queue_create("serial_queue", NULL);
            [array addObject:serial_queue];
    }
        
    [array enumerateObjectsUsingBlock:^(dispatch_queue_t queue, NSUInteger idx, BOOL * _Nonnull stop) {
            
        dispatch_async(queue, ^{
            NSLog(@"任务%ld",idx);
        });
    }];
    

输出：

    gcd_demo[40329:2999714] 任务1
    gcd_demo[40329:2999726] 任务0
    gcd_demo[40329:2999717] 任务2
    gcd_demo[40329:2999715] 任务3
    gcd_demo[40329:2999730] 任务4
    

> 我们可以看到，如果仅仅是将任务追加到5个串行队列中，那么这些任务就会并发执行。

那接下来看看使用dispatch\_set\_target\_queue方法以后：

    //多个串行队列，设置了target queue
    NSMutableArray *array = [NSMutableArray array];
    dispatch_queue_t serial_queue_target = dispatch_queue_create("queue_target", NULL);
    
    for (NSInteger index = 0; index < 5; index ++) {
          
        //分别给每个队列设置相同的target queue  
        dispatch_queue_t serial_queue = dispatch_queue_create("serial_queue", NULL);
        dispatch_set_target_queue(serial_queue, serial_queue_target);
        [array addObject:serial_queue];
    }
        
    [array enumerateObjectsUsingBlock:^(dispatch_queue_t queue, NSUInteger idx, BOOL * _Nonnull stop) {
            
        dispatch_async(queue, ^{
            NSLog(@"任务%ld",idx);
        });
    }];
    

输出：

    gcd_demo[40408:3004382] 任务0
    gcd_demo[40408:3004382] 任务1
    gcd_demo[40408:3004382] 任务2
    gcd_demo[40408:3004382] 任务3
    gcd_demo[40408:3004382] 任务4
    

> 很显然，这些任务就按顺序执行了。

dispatch\_after
---------------

dispatch\_after解决的问题：某个线程里，在指定的时间后处理某个任务：

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"三秒之后追加到队列");
    });
    

注意：不是在3秒之后处理任务，准确来说是3秒之后追加到队列。所以说，如果这个线程的runloop执行1/60秒一次，那么这个block最快会在3秒后执行，最慢会在（3+1/60）秒后执行。而且，如果这个队列本身还有延迟，那么这个block的延迟执行时间会更多。

dispatch\_group
---------------

如果遇到这样到需求：全部处理完多个预处理任务(block\_1 ~ 4)后执行某个任务（block\_finish），我们有两个方法：

*   如果预处理任务需要一个接一个的执行：将所有需要先处理完的任务追加到Serial Dispatch Queue中，并在最后追加最后处理的任务(block\_finish)。
*   如果预处理任务需要并发执行：需要使用dispatch\_group函数，将这些预处理的block追加到global dispatch queue中。

分别详细讲解一下两种需求的实现方式：

### 预处理任务需要一个接一个的执行：

这个需求的实现方式相对简单一点，只要将所有的任务（block\_1 ~ 4 + block\_finish）放在一个串行队列中即可，因为都是按照顺序执行的，只要不做多余的事情，这些任务就会乖乖地按顺序执行。

### 预处理任务需要一个接一个的执行：

    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger index = 0; index < 5; index ++) {
            dispatch_group_async(group, queue, ^{
                NSLog(@"任务%ld",index);
            });
    }
        
    dispatch_group_notify(group, queue, ^{
        NSLog(@"最后的任务");
    });
    

输出：

    gcd_demo[40905:3057237] 任务0
    gcd_demo[40905:3057235] 任务1
    gcd_demo[40905:3057234] 任务2
    gcd_demo[40905:3057253] 任务3
    gcd_demo[40905:3057237] 任务4
    gcd_demo[40905:3057237] 最后的任务
    

因为这些预处理任务都是追加到global dispatch queue中的，所以这些任务的执行任务的顺序是不定的。但是最后的任务一定是最后输出的。

> dispatch\_group\_notify函数监听传入的group中任务的完成，等这些任务全部执行以后，再将第三个参数（block）追加到第二个参数的queue（相同的queue）中。

dispatch\_group\_wait
---------------------

dispatch\_group\_wait 也是配合dispatch\_group 使用的，利用这个函数，我们可以设定group内部所有任务执行完成的超时时间。

一共有两种情况：超时的情况和没有超时的情况：

### 超时的情况：

    - (void)dispatch_wait_1
    {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        for (NSInteger index = 0; index < 5; index ++) {
            dispatch_group_async(group, queue, ^{
                for (NSInteger i = 0; i< 1000000000; i ++) {
                    
                }
                NSLog(@"任务%ld",index);
            });
        }
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
        long result = dispatch_group_wait(group, time);
        if (result == 0) {
            
            NSLog(@"group内部的任务全部结束");
            
        }else{
            
            NSLog(@"虽然过了超时时间，group还有任务没有完成");
        }
        
    }
    

输出：

    gcd_demo[41277:3087481] 虽然过了超时时间，group还有任务没有完成，结果是判定为超时
    gcd_demo[41277:3087563] 任务0
    gcd_demo[41277:3087564] 任务2
    gcd_demo[41277:3087579] 任务3
    gcd_demo[41277:3087566] 任务1
    gcd_demo[41277:3087563] 任务4
    

### 没有超时的情况：

    - (void)dispatch_wait_2
    {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        for (NSInteger index = 0; index < 5; index ++) {
            dispatch_group_async(group, queue, ^{
                for (NSInteger i = 0; i< 100000000; i ++) {
                    
                }
                NSLog(@"任务%ld",index);
            });
        }
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);
        long result = dispatch_group_wait(group, time);
        if (result == 0) {
            
            NSLog(@"group内部的任务全部结束");
            
        }else{
            
            NSLog(@"虽然过了超时时间，group还有任务没有完成");
        }
        
    }
    

输出：

    gcd_demo[41357:3092079] 任务2
    gcd_demo[41357:3092076] 任务3
    gcd_demo[41357:3092092] 任务1
    gcd_demo[41357:3092077] 任务0
    gcd_demo[41357:3092079] 任务4
    gcd_demo[41357:3091956] group内部的任务全部结束，在超时的时间以内完成，结果判定为没有超时
    

> 注意：  
> 一旦调用dispatch\_group\_wait以后，当经过了函数中指定的超时时间后 或者 指定的group内的任务全部执行后会返回这个函数的结果：

*   经过了函数中指定的超时时间后，group内部的任务没有全部完成，判定为超时，否则，没有超时
*   指定的group内的任务全部执行后，经过的时间长于超时时间，判定为超时，否则，没有超时。

> 也就是说：  
> 如果指定的超时时间为DISPATCH\_TIME\_NOW，那么则没有等待，立即判断group内的任务是否完成。

> 可以看出，指定的超时时间为DISPATCH\_TIME\_NOW的时候相当于dispatch\_group\_notify函数的使用：判断group内的任务是否都完成。

然而dispatch\_group\_notify函数是作者推荐的，因为通过这个函数可以直接设置最后任务所被追加的队列，使用起来相对比较方便。

dispatch\_barrier\_async
------------------------

关于解决数据竞争的方法：读取处理是可以并发的，但是写入处理却是不允许并发执行的。

所以合理的方案是这样的：

*   读取处理追加到concurrent dispatch queue中
*   写入处理在任何一个读取处理没有执行的状态下，追加到serial dispatch queue中（也就是说，在写入处理结束之前，读取处理不可执行）。

我们看看如何使用dispatch\_barrier\_async来解决这个问题。

为了帮助大家理解，我构思了一个例子：

1.  3名董事和总裁开会，在每个人都查看完合同之后，由总裁签字。
2.  总裁签字之后，所有人再审核一次合同。

这个需求有三个关键点：

*   关键点1：所有与会人员查看和审核合同，是同时进行的，无序的行为。
*   关键点2：只有与会人员都查看了合同之后，总裁才能签字。
*   关键点3: 只有总裁签字之后，才能进行审核。

用代码看一下：

    - (void)dispatch_barrier
    {
        dispatch_queue_t meetingQueue = dispatch_queue_create("com.meeting.queue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(meetingQueue, ^{
            NSLog(@"总裁查看合同");
        });
        
        dispatch_async(meetingQueue, ^{
            NSLog(@"董事1查看合同");
        });
        
        dispatch_async(meetingQueue, ^{
            NSLog(@"董事2查看合同");
        });
        
        dispatch_async(meetingQueue, ^{
            NSLog(@"董事3查看合同");
        });
        
        dispatch_barrier_async(meetingQueue, ^{
            NSLog(@"总裁签字");
        });
        
        dispatch_async(meetingQueue, ^{
            NSLog(@"总裁审核合同");
        });
        
        dispatch_async(meetingQueue, ^{
            NSLog(@"董事1审核合同");
        });
        
        dispatch_async(meetingQueue, ^{
            NSLog(@"董事2审核合同");
        });
        
        dispatch_async(meetingQueue, ^{
            NSLog(@"董事3审核合同");
        });
    }
    

输出结果：

    gcd_demo[41791:3140315] 总裁查看合同
    gcd_demo[41791:3140296] 董事1查看合同
    gcd_demo[41791:3140297] 董事3查看合同
    gcd_demo[41791:3140299] 董事2查看合同
    gcd_demo[41791:3140299] 总裁签字
    gcd_demo[41791:3140299] 总裁审核合同
    gcd_demo[41791:3140297] 董事1审核合同
    gcd_demo[41791:3140296] 董事2审核合同
    gcd_demo[41791:3140320] 董事3审核合同
    

> 在这里，我们可以将meetingQueue看成是会议的时间线。总裁签字这个行为相当于写操作，其他都相当于读操作。使用dispatch\_barrier\_async以后，之前的所有并发任务都会被dispatch\_barrier\_async里的任务拦截掉，就像函数名称里的“栅栏”一样。

因此，使用Concurrent Dispatch Queue 和 dispatch\_barrier\_async 函数可以实现高效率的数据库访问和文件访问。

dispatch\_sync
--------------

到目前为止的所有例子都使用的是异步函数，有异步就一定会有同步，那么现在就来区分一下同步和异步函数的区别：

*   dispatch\_async：异步函数，这个函数会立即返回，不做任何等待，它所指定的block“非同步地”追加到指定的队列中。
*   dispatch\_sync：同步函数，这个函数不会立即返回，它会一直等待追加到特定队列中的制定block完成工作后才返回，所以它的目的（也是效果）是阻塞当前线程。

举个例子：

    - (void)dispatch_sync_1
    {
        //同步处理
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"同步处理开始");
        
        __block NSInteger num = 0;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_sync(queue, ^{
            //模仿耗时操作
            for (NSInteger i = 0; i< 1000000000; i ++) {
                num++;
            }
            NSLog(@"%@",[NSThread currentThread]);
            NSLog(@"同步处理完毕");
        });
        NSLog(@"%ld",num);
        NSLog(@"%@",[NSThread currentThread]);
    }
    

输出结果：

    gcd_demo[5604:188687] <NSThread: 0x60800006fa40>{number = 1, name = main}
    gcd_demo[5604:188687] 同步处理开始
    gcd_demo[5604:188687] <NSThread: 0x60800006fa40>{number = 1, name = main}
    gcd_demo[5604:188687] 同步处理完毕
    gcd_demo[5604:188687] 1000000000
    gcd_demo[5604:188687] <NSThread: 0x60800006fa40>{number = 1, name = main}
    

在最开始的时候只打印前两行，循环完毕之后才打印后面的内容。  
因为是同步函数，它阻塞了当前线程（主线程），所以只能等到block内部的任务都结束后，才能打印下面的两行。

但是如果使用异步函数会怎样呢？

    - (void)dispatch_sync_2
    {
        //异步处理
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"异步处理开始");
        
        __block NSInteger num = 0;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            //模仿耗时操作
            for (NSInteger i = 0; i< 1000000000; i ++) {
                num++;
            }
            NSLog(@"%@",[NSThread currentThread]);
            NSLog(@"异步处理完毕");
        });
        NSLog(@"%ld",num);
        NSLog(@"%@",[NSThread currentThread]);
    }
    

输出：

    gcd_demo[5685:194233] <NSThread: 0x600000071f00>{number = 1, name = main}
    gcd_demo[5685:194233] 异步处理开始
    gcd_demo[5685:194233] 0
    gcd_demo[5685:194233] <NSThread: 0x600000071f00>{number = 1, name = main}
    gcd_demo[5685:194280] <NSThread: 0x608000260400>{number = 3, name = (null)}
    gcd_demo[5685:194280] 异步处理完毕
    

我们可以看到，不同于上面的情况，block下面的两个输出是先打印的（因为没有经过for循环的计算，num的值是0）。因为是异步处理，所以没有等待block中任务的完成就立即返回了。

了解了同步异步的区别之后，我们看一下使用同步函数容易发生的问题：如果给同步函数传入的队列是串行队列的时候就会容易造成死锁。看一下一个死锁的例子：

    - (void)dispatch_sync_3
    {
        NSLog(@"任务1");
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_sync(queue, ^{
            
            NSLog(@"任务2");
        });
        
        NSLog(@"任务3");
    }
    

上面的代码只能输出任务1，并形成死锁。  
因为任务2被追加到了主队列的最后，所以它需要等待任务3执行完成。  
但又因为是同步函数，任务3也在等待任务2执行完成。  
二者互相等待，所以形成了死锁。

dispatch\_apply
---------------

通过dispatch\_apply函数，我们可以按照指定的次数将block追加到指定的队列中。并等待全部处理执行结束。

    - (void)dispatch_apply_1
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_apply(10, queue, ^(size_t index) {
            NSLog(@"%ld",index);
        });
        NSLog(@"完毕");
    }
    

    gcd_demo[6128:240332] 1
    gcd_demo[6128:240331] 0
    gcd_demo[6128:240334] 2
    gcd_demo[6128:240332] 4
    gcd_demo[6128:240334] 6
    gcd_demo[6128:240331] 5
    gcd_demo[6128:240332] 7
    gcd_demo[6128:240334] 8
    gcd_demo[6128:240331] 9
    gcd_demo[6128:240259] 3
    gcd_demo[6128:240259] 完毕
    

我们也可以用这个函数来遍历数组，取得下标进行操作:

    - (void)dispatch_apply_2
    {
        NSArray *array = @[@1,@10,@43,@13,@33];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_apply([array count], queue, ^(size_t index) {
            NSLog(@"%@",array[index]);
        });
        NSLog(@"完毕");
    }
    

输出：

    gcd_demo[6180:244316] 10
    gcd_demo[6180:244313] 1
    gcd_demo[6180:244316] 33
    gcd_demo[6180:244314] 43
    gcd_demo[6180:244261] 13
    gcd_demo[6180:244261] 完毕
    

我们可以看到dispatch\_apply函数与dispatch\_sync函数同样具有阻塞的作用（dispatch\_apply函数返回后才打印完毕）。

我们也可以在dispatch\_async函数里执行dispatch\_apply函数：

    - (void)dispatch_apply_3
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            
            NSArray *array = @[@1,@10,@43,@13,@33];
            __block  NSInteger sum = 0;
        
            dispatch_apply([array count], queue, ^(size_t index) {
                NSNumber *number = array[index];
                NSInteger num = [number integerValue];
                sum += num;
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //回到主线程，拿到总和
                NSLog(@"完毕");
                NSLog(@"%ld",sum);
            });
        });
    }
    

dispatch\_suspend/dispatch\_resume
----------------------------------

挂起函数调用后对已经执行的处理没有影响，但是追加到队列中但是尚未执行的处理会在此之后停止执行。

    dispatch_suspend(queue);
    dispatch_resume(queue);
    

dispatch\_once
--------------

通过dispatch\_once处理的代码只执行一次，而且是线程安全的：

    - (void)dispatch_once_1
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        for (NSInteger index = 0; index < 5; index++) {
            
            dispatch_async(queue, ^{
                [self onceCode];
            });
        }
    }
    
    
    - (void)onceCode
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"只执行一次的代码");
        });
    }
    

输出：

    gcd_demo[7556:361196] 只执行一次的代码
    

该函数主要用于单例模式的使用。

到这里终于总结完啦，这本书加深了我对iOS内存管理，block以及GCD的理解，希望我写的这三篇能对您有所帮助～