//
//  YCNetworkErrorView.m
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/4/20.
//

#import "YCNetworkErrorView.h"
#import <Masonry/Masonry.h>

static NSInteger kNetworkErrorViewTag = 50000;
@interface YCNetworkErrorView ()
/* 图标 */
@property (nonatomic, strong) UIImageView *imageView;
/* 描述文字 */
@property (nonatomic, strong) UILabel *describeLbl;
/* 重新加载 */
@property (nonatomic, strong) UIButton *retryBtn;
/* 回调 */
@property (nonatomic, copy) RetryHandler retryHandler;
@end

@implementation YCNetworkErrorView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
        [self addSubview:self.imageView];
        [self addSubview:self.describeLbl];
        [self addSubview:self.retryBtn];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(120);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(150, 150));
        }];
        [self.describeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(10);
            make.centerX.equalTo(self);
            make.left.greaterThanOrEqualTo(self).offset(14);
            make.right.lessThanOrEqualTo(self).offset(-14);
        }];
        [self.retryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.describeLbl.mas_bottom).offset(20);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(130, 44));
        }];
    }
    return self;
}

+ (void)showNetworkErrorViewInView:(UIView *)view block:(RetryHandler)block {
    
    UIView *subView =[view viewWithTag:kNetworkErrorViewTag];
    if (subView) {
        //防止重复添加
        [subView removeFromSuperview];
    }
    CGRect frame = view.bounds;
    if (CGRectGetHeight(frame) == [UIScreen mainScreen].bounds.size.height) {
        CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
        frame = CGRectMake(0, height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-height);
    }
    
    YCNetworkErrorView *errorView = [[YCNetworkErrorView alloc] initWithFrame:frame];
    errorView.imageView.image = [errorView networkImageWithNamed:@"img_404"];
    errorView.describeLbl.text = @"页面出错了，攻城狮正在紧急搜救中…";
    errorView.retryHandler = block;
    errorView.tag = kNetworkErrorViewTag;
    [view addSubview:errorView];
}

+ (void)showNoNetworkViewInView:(UIView *)view block:(RetryHandler)block {
    
    UIView *subView =[view viewWithTag:kNetworkErrorViewTag];
    if (subView) {
        [subView removeFromSuperview];
    }
    
    CGRect frame = view.bounds;
    if (CGRectGetHeight(frame) == [UIScreen mainScreen].bounds.size.height) {
        CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height + 44;
        frame = CGRectMake(0, height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-height);
    }
    YCNetworkErrorView *noNetworkView = [[YCNetworkErrorView alloc] initWithFrame:frame];
    noNetworkView.imageView.image = [noNetworkView networkImageWithNamed:@"img_no_network"];
    noNetworkView.describeLbl.text = @"啊哦，你的网络走丢咯";
    noNetworkView.retryHandler = block;
    noNetworkView.tag = kNetworkErrorViewTag;
    [view addSubview:noNetworkView];
}

- (UIImage *)networkImageWithNamed:(NSString *)name {
    
    NSString *mainBundlePath = [NSBundle mainBundle].bundlePath;
    NSString *bundlePath = [NSString stringWithFormat:@"%@/%@.bundle",mainBundlePath,@"YCAPIHUDPresenter"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    if (bundle == nil) {
        bundlePath = [NSString stringWithFormat:@"%@/Frameworks/%@.framework/%@.bundle",mainBundlePath,@"YCAPIHUDPresenter",@"YCAPIHUDPresenter"];
        bundle = [NSBundle bundleWithPath:bundlePath];
    }
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
    }
    return nil;
}

- (void)onRetryButtonClick:(UIButton *)btn {
    
    if (self.retryHandler) {
        self.retryHandler();
    }
    self.retryHandler = nil;
    [self removeFromSuperview];
}

#pragma mark - getter
- (UIImageView *)imageView {
    
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UILabel *)describeLbl {
    
    if (_describeLbl == nil) {
        _describeLbl = [[UILabel alloc] init];
        _describeLbl.textColor = [UIColor colorWithRed:155/255.0 green:158/255.0 blue:168/255.0 alpha:1.0];
        _describeLbl.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 16];
        _describeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _describeLbl;
}

- (UIButton *)retryBtn {
    
    if (_retryBtn == nil) {
        _retryBtn = [[UIButton alloc] init];
        _retryBtn.layer.masksToBounds = YES;
        _retryBtn.layer.cornerRadius = 4.0;
        _retryBtn.layer.borderColor = [UIColor colorWithRed:16/255.0 green:142/255.0 blue:233/255.0 alpha:1.0].CGColor;
        _retryBtn.layer.borderWidth = 1.0;
        _retryBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 17];
        [_retryBtn setTitleColor:[UIColor colorWithRed:16/255.0 green:142/255.0 blue:233/255.0 alpha:1.0] forState:UIControlStateNormal];
        [_retryBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        [_retryBtn addTarget:self action:@selector(onRetryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryBtn;
}

@end
