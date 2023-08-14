//
//  YCCustomHUD.m
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/4/20.
//

#import "YCCustomHUD.h"
#import <Masonry/Masonry.h>

@interface YCCustomHUD ()

/* 显示动画view */
@property (nonatomic, strong) UIView *animationView;

@end

@implementation YCCustomHUD

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 4.0;
        [self addSubview:self.animationView];
        [self addSubview:self.titleLbl];
        [self.animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 14));
            make.top.equalTo(@18);
            make.centerX.equalTo(self);
        }];
        [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self.mas_bottom).offset(-18);
            make.height.equalTo(@20);
        }];
        [self showAnimation];
    }
    return self;
}


- (void)showAnimation {
    
    for (NSInteger i = 0; i < 3; i ++) {
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.path = [self bezierPathAtIndex:i].CGPath;
        layer.fillColor = [UIColor whiteColor].CGColor;
        CAKeyframeAnimation *opacityAnimation = [self createAnimationForKeyPath:@"opacity"];
        if (i == 0) {
            opacityAnimation.values = @[@(1.0f), @(0.7f), @(0.4f),@(0.7),@(1.0)];
        }else if (i == 1) {
            opacityAnimation.values = @[@(0.7f), @(1.0f), @(0.7f),@(0.4f),@(0.7)];
        }else{
            opacityAnimation.values = @[@(0.4f), @(0.7f), @(1.0f),@(0.7),@(0.4)];
        }
        [self.animationView.layer addSublayer:layer];
        [layer addAnimation:opacityAnimation forKey:@"animation"];
    }
}

- (UIBezierPath *)bezierPathAtIndex:(NSInteger)index {
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapSquare;
    path.lineJoinStyle = kCGLineCapSquare;
    CGFloat originX = 4 * (index*3+1);
    [path moveToPoint:CGPointMake(originX, 0)];
    [path addLineToPoint:CGPointMake(originX+4, 0)];
    [path addLineToPoint:CGPointMake(originX, 14)];
    [path addLineToPoint:CGPointMake(originX-4, 14)];
    [path closePath];
    return path;
}


- (CAKeyframeAnimation *)createAnimationForKeyPath:(NSString *)keyPath {
    
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    keyAnimation.repeatCount = HUGE_VALF;
    keyAnimation.duration = 0.75;
    keyAnimation.removedOnCompletion = NO;
//    keyAnimation.autoreverses = YES;
//    keyAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    return keyAnimation;
}


#pragma mark - getter
- (UIView *)animationView {
    
    if (_animationView == nil) {
        _animationView = [[UIView alloc] init];
        
    }
    return _animationView;
}

- (UILabel *)titleLbl {
    
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = [UIColor whiteColor];
        _titleLbl.font = [UIFont fontWithName:@"PingFangSC-Regular" size: 14];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.text = @"加载中";
    }
    return _titleLbl;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(80, 80);
}

@end
