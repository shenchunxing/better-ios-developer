//
//  YCSentinel.m
//  YCAPIHUDPresenter
//
//  Created by haima on 2019/3/27.
//

#import "YCSentinel.h"
#import <libkern/OSAtomic.h>

@implementation YCSentinel
{
    int32_t _value;
}

- (instancetype)init {
    if (self = [super init]) {
        _value = 0;
    }
    return self;
}

- (int32_t)value {
    return _value;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
// 有atomic_fetch_add 没有atomic_add_fetch
- (int32_t)increase {
    return OSAtomicIncrement32(&_value);
}

- (int32_t)decrease {
    return OSAtomicDecrement32(&_value);
}
#pragma clang diagnostic pop

@end
