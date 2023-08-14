//
//  AppDelegate.m
//  MGJRouter-Demo
//
//  Created by 沈春兴 on 2023/8/14.
//

#import "AppDelegate.h"
#import "DemoListViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    DemoListViewController *vc = [[DemoListViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = navigationController;

    return YES;
}




@end
