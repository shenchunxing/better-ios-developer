//
//  ViewController.m
//  __autorelease使用问题
//
//  Created by 沈春兴 on 2023/3/20.
//

#import "ViewController.h"


@interface DRNode : NSObject
@property (nonatomic, strong) DRNode *next;
@end

@implementation DRNode
- (void)dealloc {
    //头结点析构后会释放自身持有的属性,导致next指向的node析构...不停的析构导致stack overflow引发的EXC_BAD_ACCESS
//让_next = nil;可以缓解，栈溢出的问题，但是数据规模增大还是会栈溢出
//    NSLog(@"_next = %@",_next);
    //最终解决方案是将next加入到自动释放池中，由自动释放池管理其释放，就不是造成因链式析构导致的stack overflow问题了
    __autoreleasing DRNode *next __attribute__((unused)) = _next;
    _next = nil;
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DRNode *head = [[DRNode alloc] init];
    DRNode *cur = head;
    for (int i = 0 ; i < 500000; i++) {
        DRNode *node = [[DRNode alloc] init];
        cur.next = node;
        cur = node;
    }
}

@end
