//
//  ViewController.m
//  release_modifier
//
//  Created by 沈春兴 on 2023/3/20.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self weakLifeCycleTest];
}

- (void)weakLifeCycleTest {
    id obj0 = @"iTeaTime(技术清谈)";
    __weak id obj1 = obj0;
    id obj2 = [NSObject new];
    __weak id obj3 = [NSObject new];
    {
        id obj4 = [NSObject new];
    }
    __autoreleasing id obj5 = [NSObject new];
    __unsafe_unretained id obj6 = self;
    NSLog(@"obj0=%@, obj1=%@, obj2=%@, obj3=%@, obj5=%@, obj6=%@", obj0, obj1, obj2, obj3, obj5, obj6);
    // Lots of code ...
}

@end
