//
//  main.m
//  RuntimeExample
//
//  Created by shenchunxing on 2022/12/13.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface YJPerson : NSObject
@property (nonatomic, copy) NSString *name;
@end
@implementation YJPerson
- (instancetype)init {
    self = [super init];//如果不写就不能继承父类的属性和方法，父类的一些自带的就不能用所以最好写[super init]
    if (self) {
        NSLog(@"-- %@ -- %@ --",[self class], [super class]);//super的消息接收者还是self
    }
    return self;
}

- (void)say1 {
    NSLog(@"%s, name = %@", __func__ , self.name);
}

@end

void printMyName(id self, SEL _cmd) {
  id name = [self valueForKey:@"name"];
  NSLog(@"name = %@", name);
}

void generalYJTeacherClass() {
 // 定义一个 YJTeacher 类，继承自 NSObject
    Class YJTeacher = objc_allocateClassPair(NSObject.class, "YJTeacher", 0);
    // 添加实例变量
    BOOL isSuccess = class_addIvar(YJTeacher, "name", sizeof(NSString *), 0, "@");
    isSuccess ? NSLog(@"添加变量成功") : NSLog(@"添加变量失败");
    // 添加方法
    class_addMethod(YJTeacher, @selector(printMyName), (IMP)printMyName, "v@:");
    // 注册 YJTeacher
    objc_registerClassPair(YJTeacher);

    // 实例化
    id t = [[YJTeacher alloc] init];
    [t setValue:@"张三" forKey:@"name"];
    [t performSelector:@selector(printMyName)];
       
}

int main(int argc, const char * argv[]) {
  @autoreleasepool {
        //super关键字
        YJPerson *p1 = [[YJPerson alloc] init];
      p1.name = @"张三";
      [p1 say1];

       //内存平移
      
    Class cls = YJPerson.class;//cls变量指向全局区的YJPerson类对象
    void *p2= &cls;//p2指向cls
    [(__bridge id)p2 say1];//p2地址偏移8位，找到的是p1，因为栈上地址p1和p2是挨着的

        
        //动态生成类以及添加实例变量
        generalYJTeacherClass();
    
  }
    return 0;
}

