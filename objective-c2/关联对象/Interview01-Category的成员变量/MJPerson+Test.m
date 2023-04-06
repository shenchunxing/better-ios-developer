//
//  MJPerson+Test.m
//  Interview01-Category的成员变量
//
//  Created by MJ Lee on 2018/5/9.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJPerson+Test.h"
#import <objc/runtime.h>

@implementation MJPerson (Test)
/**
 void objc_setAssociatedObject(id _Nonnull object, const void * _Nonnull key,
                         id _Nullable value, objc_AssociationPolicy policy)
 AssociationsManager = {static AssociationsHashMap map}
 AssociationsHashMap map = [{object : AssociationsMap = {key : Associations = {policy,value}}}]
 */
- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)name
{
    // 隐式参数
    // _cmd == @selector(name)
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWeight:(int)weight
{
    objc_setAssociatedObject(self, @selector(weight), @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)weight
{
    // _cmd == @selector(weight)
    return [objc_getAssociatedObject(self, _cmd) intValue];
}

//- (NSString *)name
//{
//    return objc_getAssociatedObject(self, @selector(name));
//}
//- (int)weight
//{
//    return [objc_getAssociatedObject(self, @selector(weight)) intValue];
//}

//#define MJNameKey @"name"
//#define MJWeightKey @"weight"
//- (void)setName:(NSString *)name
//{
//    objc_setAssociatedObject(self, MJNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (NSString *)name
//{
//    return objc_getAssociatedObject(self, MJNameKey);
//}
//
//- (void)setWeight:(int)weight
//{
//    objc_setAssociatedObject(self, MJWeightKey, @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (int)weight
//{
//    return [objc_getAssociatedObject(self, MJWeightKey) intValue];
//}

//static const void *MJNameKey = &MJNameKey;
//static const void *MJWeightKey = &MJWeightKey;
//- (void)setName:(NSString *)name
//{
//    objc_setAssociatedObject(self, MJNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (NSString *)name
//{
//    return objc_getAssociatedObject(self, MJNameKey);
//}
//
//- (void)setWeight:(int)weight
//{
//    objc_setAssociatedObject(self, MJWeightKey, @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (int)weight
//{
//    return [objc_getAssociatedObject(self, MJWeightKey) intValue];
//}

//static const char MJNameKey;
//static const char MJWeightKey;
//- (void)setName:(NSString *)name
//{
//    objc_setAssociatedObject(self, &MJNameKey, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
//
//- (NSString *)name
//{
//    return objc_getAssociatedObject(self, &MJNameKey);
//}
//
//- (void)setWeight:(int)weight
//{
//    objc_setAssociatedObject(self, &MJWeightKey, @(weight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (int)weight
//{
//    return [objc_getAssociatedObject(self, &MJWeightKey) intValue];
//}

@end
