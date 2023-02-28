//
//  MJPerson.m
//  Interview01-内存管理
//
//  Created by MJ Lee on 2018/6/27.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson.h"

@implementation MJPerson

- (void)setAge:(int)age
{
    _age = age;
}

- (int)age
{
    return _age;
}

- (void)setDog:(MJDog *)dog
{
    if (_dog != dog) { //不判断可能两只狗是一样的，狗直接被释放了
        [_dog release]; //将上一只狗先释放
        _dog = [dog retain];//再拥有当前这只狗
    }
    
    //这种写法也可以
//    [dog retain];
//    [_dog release];
//    _dog = dog;
}

- (MJDog *)dog
{
    return _dog;
}

- (void)setCar:(MJCar *)car
{
    if (_car != car) {
        [_car release];
        _car = [car retain];
    }
}

- (MJCar *)car
{
    return _car;
}

- (void)dealloc
{
//    [_dog release];
//    _dog = nil;
    self.dog = nil; //等价//[_dog release]、dog = nil;。走的是setter方法
    self.car = nil;
    
    NSLog(@"%s", __func__);
    
    // 父类的dealloc放到最后
    [super dealloc];
}

@end
