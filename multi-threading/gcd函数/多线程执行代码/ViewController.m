//
//  ViewController.m
//  多线程执行代码
//
//  Created by shenchunxing on 2022/12/13.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    [self serialQueue2];
//    [self serialQueue];
//    [self concurrentQueue];
//    [self multiSerialQueue_1];
//    [self multiSerialQueue];
//    [self setTargetQueue_1];
//    [self setTargetQueue_2];
//    [self setTargetQueue_3];
//    [self dispatch_after];
//    [self dispatch_group];
//    [self dispatch_wait_3];
//    [self dispatch_wait_2];
    [self dispatch_barrier];
//    [self dispatch_sync_1];
//    [self dispatch_sync_2];
//    [self dispatch_sync_4];
//    [self dispatch_apply_3];
//    [self dispatch_once_1];
}


///在内部的dispatch_sync块中使用的是内部块中的新串行队列，而不是外部的串行队列。由于这两个串行队列是不同的对象，因此打印地址时会得到不同的结果。然而，由于内部的dispatch_sync块是在外部的dispatch_async块中执行的，两者在时间上是连续的，所以在打印地址时可能会出现相同的结果。
- (void)serialQueue2 {
    dispatch_queue_t my_serial_queue = dispatch_queue_create("my_serial_queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(my_serial_queue, ^{
       NSLog(@"%@", [NSThread currentThread]);
       dispatch_queue_t my_serial_queue1 = dispatch_queue_create("my_serial_queue_2", DISPATCH_QUEUE_SERIAL);
       dispatch_sync(my_serial_queue1, ^{ //使用外部的串行队列
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
- (void)dispatch_apply_2
{
    NSArray *array = @[@1,@10,@43,@13,@33];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply([array count], queue, ^(size_t index) {
        NSLog(@"%@",array[index]);
    });
    NSLog(@"完毕");
}

//异步遍历
//通过dispatch_apply函数，我们可以按照指定的次数将block追加到指定的队列中。并等待全部处理执行结束。
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

//同步阻塞,但是不会死锁
- (void)dispatch_sync_1
{
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
- (void)dispatch_sync_2
{
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
- (void)dispatch_sync_3
{
    NSLog(@"任务1");
    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_sync(queue, ^{//主线程被同步阻塞
        
        NSLog(@"任务2");
    });
    NSLog(@"任务3");
}

//死锁2
- (void)dispatch_sync_4
{
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
- (void)dispatch_barrier
{
    dispatch_queue_t meetingQueue = dispatch_queue_create("com.meeting.queue", DISPATCH_QUEUE_CONCURRENT);
    /**注意：dispatch_get_global_queue是一个特殊的并发队列，不能直接用于dispatch_barrier_async，会导致dispatch_barrier_async不生效**/
//    dispatch_queue_t meetingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
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
- (void)dispatch_wait_1
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

//超时
- (void)dispatch_wait_2
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

//超时时间为：DISPATCH_TIME_NOW：无超时时间
- (void)dispatch_wait_3
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for (NSInteger index = 0; index < 5; index ++) {
        dispatch_group_async(group, queue, ^{
            for (NSInteger i = 0; i< 1000000000; i ++) {
                
            }
            NSLog(@"任务%ld - 线程%@",index,[NSThread currentThread]);
        });
    }
    
    //超时时间一到或者任务完成，立即返回结果
    long result = dispatch_group_wait(group, dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC));
    if (result == 0) {
        NSLog(@"group内部的任务全部结束");
    }else{
        NSLog(@"虽然过了超时时间，group还有任务没有完成");
    }
    
}

//dispatch_group_async和dispatch_get_global_queue配合异步执行，开启多个子线程。
//dispatch_group_notify会在dispatch_group_t执行完后，执行内部代码
- (void)dispatch_group
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    for (NSInteger index = 0; index < 5; index ++) {
        dispatch_group_async(group, queue, ^{
            NSLog(@"任务%ld - 线程%@",index,[NSThread currentThread]);
        });
    }
    
    //这个位置要放最后
    dispatch_group_notify(group, queue, ^{
        NSLog(@"最后的任务");
    });
}

//推迟追加队列
- (void)dispatch_after
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"三秒之后追加到队列");
    });
}

//target
- (void)setTargetQueue_1
{
    //需求：生成一个后台的串行队列
    dispatch_queue_t queue = dispatch_queue_create("queue", NULL);
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    //第一个参数：需要改变优先级的队列；
    //第二个参数：目标队列
    dispatch_set_target_queue(queue, bgQueue);
}


//没有设置target，dispatch_async下会创建多个子线程，每个子线程执行1个或多个任务，是依次执行的
- (void)setTargetQueue_2
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger index = 0; index < 5; index ++) {
        dispatch_queue_t serial_queue = dispatch_queue_create("serial_queue", NULL);
        [array addObject:serial_queue];
    }
    
    [array enumerateObjectsUsingBlock:^(dispatch_queue_t queue, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_async(queue, ^{
            NSLog(@"任务%ld - 线程%@",idx,[NSThread currentThread]);
        });
    }];
    
}

//dispatch_set_target_queue：防止多个串行队列的并发执行
- (void)setTargetQueue_3
{
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

//dispatch_async允许开启多个线程，但因为是串行队列，同一时间只能执行一个任务
- (void)multiSerialQueue
{
    for (NSInteger index = 0; index < 10; index ++) {
        
        dispatch_queue_t queue = dispatch_queue_create("different serial queue", NULL);
        dispatch_async(queue, ^{
            NSLog(@"serial queue index : %@",[NSThread currentThread]);
        });
    }
}

//dispatch_sync 不开启线程 ； dispatch_async 开启线程
- (void)multiSerialQueue_1
{
    for (NSInteger index = 0; index < 20; index ++) {
        dispatch_queue_t queue = dispatch_queue_create("different serial queue", NULL);
        if (index%2 == 0) {
            //因为是dispatch_sync，没有开启子线程的能力，代码还是运行在主线程，且按顺序0 2 4 6 8偶数打印
            dispatch_sync(queue, ^{
                NSLog(@"queue1  : %@ index = %d",[NSThread currentThread],index);
            });
        }else{
            //因为是dispatch_async，开启了多个子线程，但是因为是串行队列，每次只打印一个，随机打印
            dispatch_async(queue, ^{//dispatch_async开启多条子线程
                NSLog(@"queue2  : %@ index = %d",[NSThread currentThread],index);
            });
        }
    }
}


//会创建多个线程，每个线程会执行1个或多个任务，且顺序是随机的
- (void)concurrentQueue
{
    dispatch_queue_t queue = dispatch_queue_create("concurrent queue", DISPATCH_QUEUE_CONCURRENT);
    for (NSInteger index = 0; index < 10; index ++) {
        dispatch_async(queue, ^{
            NSLog(@"task index %ld in concurrent queue: %@",index,[NSThread currentThread]);
        });
    }
}

//只会创建一个线程，在同一个串行队列中线程会依次执行10个任务
- (void)serialQueue
{
    dispatch_queue_t queue = dispatch_queue_create("serial queue", DISPATCH_QUEUE_SERIAL);
    for (NSInteger index = 0; index < 10; index ++) {
        dispatch_async(queue, ^{
            NSLog(@"task index %ld in serial queue : %@",index,[NSThread currentThread]);
        });
    }
}

@end

