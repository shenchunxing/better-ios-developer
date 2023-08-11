//
//  main.m
//  dispatch_semephore_demo
//
//  Created by 沈春兴 on 2023/8/11.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 创建一个信号量，初始值为 0
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        // 创建一个全局队列
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        // 定义一组任务
        NSArray *tasks = @[@1, @2, @3, @4, @5];
        
        // 遍历任务数组，将任务提交到队列中执行
        for (NSNumber *taskNumber in tasks) {
            dispatch_async(queue, ^{
                // 模拟任务执行
                sleep(arc4random_uniform(3) + 1);
                // 因为控制了并发数，都是在同一个子线程内执行的
                NSLog(@"Task %@ finished - thread - %@", taskNumber,[NSThread currentThread]);
                
                // 信号量的计数增加，表示一个任务已完成
                dispatch_semaphore_signal(semaphore);
            });
            
            // 等待信号量的计数达到指定值，表示一个任务已完成
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        // 所有任务完成后，执行指定任务
        dispatch_async(queue, ^{
            NSLog(@"All tasks completed. Performing the specified task.");
        });
        
        // 让程序不退出，以便查看输出结果
        dispatch_main();
    }
    return 0;
}
