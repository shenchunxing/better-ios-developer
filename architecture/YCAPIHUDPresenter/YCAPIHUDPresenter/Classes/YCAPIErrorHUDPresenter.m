//
//  YCAPIErrorHUDPresenter.m
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/7/18.
//

#import "YCAPIErrorHUDPresenter.h"
#import "UIView+Toast.h"

@implementation YCAPIErrorHUDPresenter

- (void)api:(id <YCAPIProtocol>)api showFailureHUD:(NSError *)error {
    
    [super api:api showFailureHUD:error];
    [self.view makeToast:error.localizedDescription duration:1.5 position:CSToastPositionCenter];
}

@end
