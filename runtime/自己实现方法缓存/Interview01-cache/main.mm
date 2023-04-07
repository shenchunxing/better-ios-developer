//
//  main.m
//  Interview01-cache
//
//  Created by MJ Lee on 2018/5/22.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJGoodStudent.h"
#import "MJClassInfo.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        MJPerson *person = [[MJPerson alloc] init];
        mj_objc_class *personClass = (__bridge mj_objc_class *)[MJPerson class];
        [person personTest];
        
        MJGoodStudent *goodStudent = [[MJGoodStudent alloc] init];
        mj_objc_class *goodStudentClass = (__bridge mj_objc_class *)[MJGoodStudent class];
        
        [goodStudent goodStudentTest];
        [goodStudent studentTest];
        [goodStudent personTest];
        [goodStudent goodStudentTest];
        [goodStudent studentTest];
        
        NSLog(@"--------------------------");
        
        cache_t cache = goodStudentClass->cache;
        //打印从缓存查找到的方法地址
        NSLog(@"%s %p", @selector(personTest), cache.imp(@selector(personTest)));
        NSLog(@"%s %p", @selector(studentTest), cache.imp(@selector(studentTest)));
        NSLog(@"%s %p", @selector(goodStudentTest), cache.imp(@selector(goodStudentTest)));
        
        
//        bucket_t *buckets = cache._buckets;
//
//        bucket_t bucket = buckets[(long long)@selector(studentTest) & cache._mask];
//        NSLog(@"%s %p", bucket._key, bucket._imp);
        
//        for (int i = 0; i <= cache._mask; i++) {
//            bucket_t bucket = buckets[i];
//            NSLog(@"%s %p", bucket._key, bucket._imp);
//        }
        
        
        NSLog(@"123");
    }
    return 0;
}
