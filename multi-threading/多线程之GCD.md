### 同步和异步
```
// dispatch_sync和dispatch_async用来控制是否要开启新的线程
- (void)interview01{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？会！
    NSLog(@"1");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{
        NSLog(@"2");
    });
    NSLog(@"3");
    // dispatch_sync立马在当前线程同步执行任务
}

//1 3 2
- (void)interview02{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？不会！
    NSLog(@"1");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        NSLog(@"2");
    });
    NSLog(@"3");
    // dispatch_async不要求立马在当前线程同步执行任务
}

//1 5 2
- (void)interview03{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？会！
    NSLog(@"1");
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{ // 0
        NSLog(@"2");
        dispatch_sync(queue, ^{ // 1
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

//1 5 2 3 4
- (void)interview04{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？不会！
    NSLog(@"1");
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_SERIAL);
//    dispatch_queue_t queue2 = dispatch_queue_create("myqueu2", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue2 = dispatch_queue_create("myqueu2", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{ // 0
        NSLog(@"2");
        dispatch_sync(queue2, ^{ // 1
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

//1 5 2 3 4
- (void)interview05{
    // 问题：以下代码是在主线程执行的，会不会产生死锁？不会！
    NSLog(@"1");
    dispatch_queue_t queue = dispatch_queue_create("myqueu", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{ // 0
        NSLog(@"2");
        dispatch_sync(queue, ^{ // 1
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_queue_t queue1 = dispatch_get_global_queue(0, 0);//全局并发队列,只有一个
    dispatch_queue_t queue2 = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue3 = dispatch_queue_create("queu3", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue4 = dispatch_queue_create("queu4", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue5 = dispatch_queue_create("queu5", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"%p %p %p %p %p", queue1, queue2, queue3, queue4, queue5);
}
```

### 队列组
```
//执行任务1 2后，回到主线程执行任务3
- (void)groupQueue1 {
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("my_queue", DISPATCH_QUEUE_CONCURRENT);
    // 添加异步任务
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务1-%@", [NSThread currentThread]);
        }
    });
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务2-%@", [NSThread currentThread]);
        }
    });
    // 等前面的任务执行完毕后，会自动执行这个任务
    dispatch_group_notify(group, queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            for (int i = 0; i < 3; i++) {
                NSLog(@"任务3-%@", [NSThread currentThread]);
            }
        });
    });
}
```
```
//执行完任务1和任务2后再做执行任务3和任务4
- (void)groupQueue2 {
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    // 创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("my_queue", DISPATCH_QUEUE_CONCURRENT);
    // 添加异步任务
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务1-%@", [NSThread currentThread]);
        }
    });
    dispatch_group_async(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务2-%@", [NSThread currentThread]);
        }
    });
    // 上面任务执行完后再执行
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务3-%@", [NSThread currentThread]);
        }
    });
    // 上面任务执行完后再执行
    dispatch_group_notify(group, queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"任务4-%@", [NSThread currentThread]);
        }
    });
}
```

### 理解队列和任务以及线程之间的关系
假设现在有 5 个人要穿过一道门禁，这道门禁总共有 10 个入口，管理员可以决定同一时间打开几个入口，可以决定同一时间让一个人单独通过还是多个人一起通过。不过默认情况下，管理员只开启一个入口，且一个通道一次只能通过一个人。

这个故事里，人好比是 任务，管理员好比是 系统，入口则代表 线程。

5 个人表示有 5 个任务，10 个入口代表 10 条线程。
串行队列 好比是 5 个人排成一支长队。
并发队列 好比是 5 个人排成多支队伍，比如 2 队，或者 3 队。
同步任务 好比是管理员只开启了一个入口（当前线程）。
异步任务 好比是管理员同时开启了多个入口（当前线程 + 新开的线程）。

『异步执行 + 并发队列』 可以理解为：现在管理员开启了多个入口（比如 3 个入口），5 个人排成了多支队伍（比如 3 支队伍），这样这 5 个人就可以 3 个人同时一起穿过门禁了。

『同步执行 + 并发队列』 可以理解为：现在管理员只开启了 1 个入口，5  个人排成了多支队伍。虽然这 5 个人排成了多支队伍，但是只开了 1 个入口啊，这 5 个人虽然都想快点过去，但是 1 个入口一次只能过 1 个人，所以大家就只好一个接一个走过去了，表现的结果就是：顺次通过入口。

换成 GCD 里的语言就是说：

『异步执行 + 并发队列』就是：系统开启了多个线程（主线程+其他子线程），任务可以多个同时运行。
『同步执行 + 并发队列』就是：系统只默认开启了一个主线程，没有开启子线程，虽然任务处于并发队列中，但也只能一个接一个执行了。

### 如何用GCD同步若干个异步调用？（如根据若干个url异步加载多张图片，然后在都下载完成后合成一张整图）

使用Dispatch Group追加block到Global Group Queue,这些block如果全部执行完毕，就会执行Main Dispatch Queue中的结束处理的block。
```Objective-C
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();
dispatch_group_async(group, queue, ^{ /*加载图片1 */ });
dispatch_group_async(group, queue, ^{ /*加载图片2 */ });
dispatch_group_async(group, queue, ^{ /*加载图片3 */ }); 
dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 合并图片
});
```
### `dispatch_barrier_async`的作用是什么？
 在并发队列中，为了保持某些任务的顺序，需要等待一些任务完成后才能继续进行，使用 barrier 来等待之前任务完成，避免数据竞争等问题。 
 `dispatch_barrier_async` 函数会等待追加到Concurrent Dispatch Queue并发队列中的操作全部执行完之后，然后再执行 `dispatch_barrier_async` 函数追加的处理，等 `dispatch_barrier_async` 追加的处理执行结束之后，Concurrent Dispatch Queue才恢复之前的动作继续执行。

打个比方：比如你们公司周末跟团旅游，高速休息站上，司机说：大家都去上厕所，速战速决，上完厕所就上高速。超大的公共厕所，大家同时去，程序猿很快就结束了，但程序媛就可能会慢一些，即使你第一个回来，司机也不会出发，司机要等待所有人都回来后，才能出发。 `dispatch_barrier_async` 函数追加的内容就如同 “上完厕所就上高速”这个动作。

（注意：使用 `dispatch_barrier_async` ，该函数只能搭配自定义并发队列 `dispatch_queue_t` 使用。不能使用： `dispatch_get_global_queue` ，否则 `dispatch_barrier_async` 的作用会和 `dispatch_async` 的作用一模一样。 ）


### 苹果为什么要废弃`dispatch_get_current_queue`？
`dispatch_get_current_queue`函数的行为常常与开发者所预期的不同。
由于派发队列是按层级来组织的，这意味着排在某条队列中的块会在其上级队列里执行。
队列间的层级关系会导致检查当前队列是否为执行同步派发所用的队列这种方法并不总是奏效。`dispatch_get_current_queue`函数通常会被用于解决由不可以重入的代码所引发的死锁，然后能用此函数解决的问题，通常也可以用"队列特定数据"来解决。

### GCD使用
```
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self serialQueue2];
//    [self serialQueue];
//    [self concurrentQueue];
//    [self multiSerialQueue_1];
//    [self setTargetQueue_3];
//    [self dispatch_after];
//    [self dispatch_group];
//    [self dispatch_wait_3];
//    [self dispatch_wait_2];
//    [self dispatch_barrier];
//    [self dispatch_sync_1];
//    [self dispatch_sync_2];
//    [self dispatch_sync_4];
//    [self dispatch_apply_3];
//    [self dispatch_once_1];
}

- (void)serialQueue2 {
    dispatch_queue_t my_serial_queue = dispatch_queue_create("my_serial_queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(my_serial_queue, ^{
       NSLog(@"%@", [NSThread currentThread]);
       dispatch_queue_t my_serial_queue = dispatch_queue_create("my_serial_queue_2", DISPATCH_QUEUE_SERIAL);
       dispatch_sync(my_serial_queue, ^{ //使用外部的串行队列
            NSLog(@"%@", [NSThread currentThread]);
        });
    });
}

//一次的代码
- (void)dispatch_once_1{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger index = 0; index < 5; index++) {
        dispatch_async(queue, ^{
            [self onceCode];
        });
    }
}

- (void)onceCode{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"只执行一次的代码");
    });
}


//简单重复调用
- (void)dispatch_apply_1{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(10, queue, ^(size_t index) {
        NSLog(@"%ld",index);
    });
    NSLog(@"完毕");
}

//遍历数组
- (void)dispatch_apply_2{
    NSArray *array = @[@1,@10,@43,@13,@33];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply([array count], queue, ^(size_t index) {
        NSLog(@"%@",array[index]);
    });
    NSLog(@"完毕");
}

//异步遍历
//通过dispatch_apply函数，我们可以按照指定的次数将block追加到指定的队列中。并等待全部处理执行结束。
- (void)dispatch_apply_3{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *array = @[@1,@10,@43,@13,@33];
        __block  NSInteger sum = 0;
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

//同步阻塞,但是不会死锁
- (void)dispatch_sync_1{
    //同步处理
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"同步处理开始");
    __block NSInteger num = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        for (NSInteger i = 0; i< 1000000000; i ++) {
            num++;
        }
        NSLog(@"%@",[NSThread currentThread]);//因为是同步，一直在主线程执行
        NSLog(@"同步处理完毕");
    });
    NSLog(@"%ld",num);
    NSLog(@"%@",[NSThread currentThread]);
}

//异步
- (void)dispatch_sync_2{
    //异步处理
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"异步处理开始");
    __block NSInteger num = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (NSInteger i = 0; i< 1000000000; i ++) {
            num++;
        }
        NSLog(@"%@",[NSThread currentThread]);
        NSLog(@"异步处理完毕");
    });
    NSLog(@"%ld",num);
    NSLog(@"%@",[NSThread currentThread]);
}

//死锁1
- (void)dispatch_sync_3{
    NSLog(@"任务1");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{//主线程被同步阻塞
        NSLog(@"任务2");
    });
    NSLog(@"任务3");
}

//死锁2
- (void)dispatch_sync_4{
    NSLog(@"任务1");
    dispatch_queue_t queue = dispatch_queue_create("dead lock queue", NULL);
    dispatch_async(queue, ^{
        NSLog(@"任务2");
        dispatch_sync(queue, ^{//子线程被同步阻塞
            NSLog(@"任务3");
        });
    });
    NSLog(@"任务4");
}

//3名董事和总裁开会，在每个人都查看完合同之后，由总裁签字。总裁签字之后，所有人再审核一次合同
- (void)dispatch_barrier{
    dispatch_queue_t meetingQueue = dispatch_queue_create("com.meeting.queue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_queue_t meetingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
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

//没有超时
- (void)dispatch_wait_1{
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

//超时
- (void)dispatch_wait_2{
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

//超时时间为：DISPATCH_TIME_NOW：无超时时间
- (void)dispatch_wait_3{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger index = 0; index < 5; index ++) {
        dispatch_group_async(group, queue, ^{
            for (NSInteger i = 0; i< 1000000000; i ++) {
            }
            NSLog(@"任务%ld",index);
        });
    }
    //超时时间一到或者任务完成，立即返回结果
    long result = dispatch_group_wait(group, DISPATCH_TIME_NOW);
    if (result == 0) {
        NSLog(@"group内部的任务全部结束");
    }else{
        NSLog(@"虽然过了超时时间，group还有任务没有完成");
    }
}

//group
- (void)dispatch_group{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger index = 0; index < 5; index ++) {
        dispatch_group_async(group, queue, ^{
            NSLog(@"任务%ld",index);
        });
    }
    //这个位置要放最后
    dispatch_group_notify(group, queue, ^{
        NSLog(@"最后的任务");
    });
}

//推迟追加队列
- (void)dispatch_after{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"三秒之后追加到队列");
    });
}

//target
- (void)setTargetQueue_1{
    //需求：生成一个后台的串行队列
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    //第一个参数：需要改变优先级的队列；
    //第二个参数：目标队列
    dispatch_set_target_queue(queue, bgQueue);
}

- (void)setTargetQueue_2{
    //多个串行队列，没有设置target queue
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger index = 0; index < 5; index ++) {
        dispatch_queue_t serial_queue = dispatch_queue_create("serial_queue", NULL);
        [array addObject:serial_queue];
    }
    [array enumerateObjectsUsingBlock:^(dispatch_queue_t queue, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(queue, ^{
            NSLog(@"任务%ld",idx);
        });
    }];
}

- (void)setTargetQueue_3{
    //多个串行队列，设置了target queue,只会开辟一条子线程
    NSMutableArray *array = [NSMutableArray array];
    dispatch_queue_t serial_queue_target = dispatch_queue_create("queue_target", NULL);
    for (NSInteger index = 0; index < 5; index ++) {
        dispatch_queue_t serial_queue = dispatch_queue_create("serial_queue", NULL);
        //防止多个串行队列的并发执行
        dispatch_set_target_queue(serial_queue, serial_queue_target);
        [array addObject:serial_queue];
    }
    [array enumerateObjectsUsingBlock:^(dispatch_queue_t queue, NSUInteger idx, BOOL * _Nonnull stop) {
        //因为设置了相同的目标队列，异步也只会开启一条子线程
        dispatch_async(queue, ^{
            NSLog(@"任务%ld - %@",idx,[NSThread currentThread]);
        });
    }];
}

//多个串行队列队列，多个线程
- (void)multiSerialQueue{
    for (NSInteger index = 0; index < 10; index ++) {
        dispatch_queue_t queue = dispatch_queue_create("different serial queue", NULL);
        dispatch_async(queue, ^{
            NSLog(@"serial queue index : %@",[NSThread currentThread]);
        });
    }
}

//dispatch_sync 不开启线程 ； dispatch_async 开启线程
- (void)multiSerialQueue_1{
    for (NSInteger index = 0; index < 20; index ++) {
        dispatch_queue_t queue = dispatch_queue_create("different serial queue", NULL);
        if (index%2 == 0) {
            dispatch_sync(queue, ^{ //dispatch_sync不开启子线程，还是运行在主线程
                NSLog(@"serial queue index : %@",[NSThread currentThread]);
            });
        }else{
            dispatch_async(queue, ^{//dispatch_async开启多条子线程
                NSLog(@"serial queue index : %@",[NSThread currentThread]);
            });
        }
    }
}

//并行
- (void)concurrentQueue{
    dispatch_queue_t queue = dispatch_queue_create("concurrent queue", DISPATCH_QUEUE_CONCURRENT);
    for (NSInteger index = 0; index < 10; index ++) {
        dispatch_async(queue, ^{
            NSLog(@"task index %ld in concurrent queue: %@",index,[NSThread currentThread]);
        });
    }
}

//串行
- (void)serialQueue{
    dispatch_queue_t queue = dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL);
    for (NSInteger index = 0; index < 10; index ++) {
        dispatch_async(queue, ^{
            NSLog(@"task index %ld in serial queue : %@",index,[NSThread currentThread]);
        });
    }
}
```
