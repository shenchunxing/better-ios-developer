//
//  ViewController.m
//  Protocol-Class
//
//  Created by 沈春兴 on 2023/8/14.
//

#import "ViewController.h"

/**
 Protocol-Class方案的优点，这个方案没有硬编码。
 Protocol-Class方案也是存在一些缺点的，每个Protocol都要向ModuleManager进行注册。
 这种方案ModuleEntry是同时需要依赖ModuleManager和组件里面的页面或者组件两者的。当然ModuleEntry也是会依赖ModuleEntryProtocol的，但是这个依赖是可以去掉的，比如用Runtime的方法NSProtocolFromString，加上硬编码是可以去掉对Protocol的依赖的。但是考虑到硬编码的方式对出现bug，后期维护都是不友好的，所以对Protocol的依赖还是不要去除。
 最后一个缺点是组件方法的调用是分散在各处的，没有统一的入口，也就没法做组件不存在时或者出现错误时的统一处理。

 */

static NSMutableDictionary *cache;

@protocol MTDetailViewControllerProtocol <NSObject>

+ (__kindof UIViewController *)detailViewControllerWithUrl:(NSString *)detailUrl;

@end

@interface MTMediator : NSObject
+ (void)registerProtol:(Protocol *)protocol class:(Class)cls;
+ (Class)classForProtocol:(Protocol *)protocol;
@end

@implementation MTMediator

+ (void)registerProtol:(Protocol *)protocol class:(Class)cls{
    if (protocol && cls) {
        [[[self class] mediatorCache] setObject:cls forKey:NSStringFromProtocol(protocol)];
    }
}

+ (Class)classForProtocol:(Protocol *)protocol{
    return [[[self class] mediatorCache] objectForKey:NSStringFromProtocol(protocol)];
}

+ (NSMutableDictionary *)mediatorCache {
    if (!cache) {
        cache =[NSMutableDictionary dictionary];
    }
    return cache;
}

@end

//被调用
//MTDetailViewController.h --- start
@protocol MTDetailViewControllerProtocol;

@interface MTDetailViewController : UIViewController<MTDetailViewControllerProtocol>
@property (nonatomic,strong) NSString *detailUrl;
@end

@implementation MTDetailViewController
+ (void)load {
    [MTMediator registerProtol: @protocol(MTDetailViewControllerProtocol) class:[self class]];
}

#pragma mark - MTDetailViewControllerProtocol
+ ( __kindof UIViewController *)detailViewControllerWithUrl:(NSString *)detailUrl{
    return [[MTDetailViewController alloc] initWithUrlString:detailUrl];
}

- (instancetype)initWithUrlString:(NSString *)detailUrl {
    if (self = [super init]) {
        self.detailUrl = detailUrl;
    }
    return self;
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //调用
    Class cls = [MTMediator classForProtocol: @protocol(MTDetailViewControllerProtocol)];
    if ([cls respondsToSelector: @selector(detailViewControllerWithUrl:)]) {
            [self.navigationController pushViewController:[cls detailViewControllerWithUrl:@"xxxx"] animated:YES];
    }

}


@end
