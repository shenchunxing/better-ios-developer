
### runtime的使用
#### objc_msgSend
```
// 通过类名获取类
Class catClass = objc_getClass("Cat"); 
//注意Class实际上也是对象，所以同样能够接受消息，向Class发送alloc消息
Cat *cat = objc_msgSend(catClass, @selector(alloc)); 
//发送init消息给Cat实例cat
cat = objc_msgSend(cat, @selector(init)); 
//发送eat消息给cat，即调用eat方法
objc_msgSend(cat, @selector(eat));
//汇总消息传递过程
objc_msgSend(objc_msgSend(objc_msgSend(objc_getClass("Cat"), sel_registerName("alloc")), sel_registerName("init")), sel_registerName("eat"));
```
#### 关联对象:alertView,一般传值，使用的是alertView的tag属性。我们想把更多的参数传给alertView代理
```
- (void)shopCartCell:(BSShopCartCell *)shopCartCell didDeleteClickedAtRecId:(NSString *)recId{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确认要删除这个宝贝" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    objc_setAssociatedObject(alert, "suppliers_id", @"1", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(alert, "warehouse_id", @"2", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    alert.tag = [recId intValue];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *warehouse_id = objc_getAssociatedObject(alertView, "warehouse_id");
        NSString *suppliers_id = objc_getAssociatedObject(alertView, "suppliers_id");
        NSString *recId = [NSString stringWithFormat:@"%ld",(long)alertView.tag];
    }
}
```
#### 方法交换

```
#import "NSMutableDictionary+Extension.h"
#import <objc/runtime.h>
@implementation NSMutableDictionary (Extension)

+ (void)load{ 
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ //确保不会被多次交换
    //NSDictionary是一个类蔟，找到子类去交换
        Class cls = NSClassFromString(@"__NSDictionaryM");
        //__NSDictionaryM NSMutableDictionary NSDictionary NSObject
        NSLog(@"%@ %@ %@ %@",cls , [cls superclass],[[cls superclass] superclass],[[[cls superclass] superclass] superclass]);

        Method method1 = class_getInstanceMethod(cls, @selector(setObject:forKeyedSubscript:));

        Method method2 = class_getInstanceMethod(cls, @selector(mj_setObject:forKeyedSubscript:));
        method_exchangeImplementations(method1, method2);
        Class cls2 = NSClassFromString(@"__NSDictionaryI");
        //__NSDictionaryI NSDictionary NSObject (null)
        NSLog(@"%@ %@ %@ %@",cls2 , [cls2 superclass],[[cls2 superclass] superclass],[[[cls2 superclass] superclass] superclass]);
        Method method3 = class_getInstanceMethod(cls2, @selector(objectForKeyedSubscript:));
        Method method4 = class_getInstanceMethod(cls2, @selector(mj_objectForKeyedSubscript:));
        method_exchangeImplementations(method3, method4);
    });
}

- (void)mj_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key{
    if (!key) return;
    [self mj_setObject:obj forKeyedSubscript:key];
}

- (id)mj_objectForKeyedSubscript:(id)key{
    if (!key) return nil;
    return [self mj_objectForKeyedSubscript:key];
}
@end
```
#### 动态添加方法
```
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    Person *p = [[Person alloc] init];
    // 默认person，没有实现eat方法，可以通过performSelector调用，但是会报错。
    // 动态添加方法就不会报错
    [p performSelector:@selector(eat)];
}
@end
@implementation Person
// void(*)()
// 默认方法都有两个隐式参数，
void eat(id self,SEL sel) {
    NSLog(@"%@ %@",self,NSStringFromSelector(sel));
}
// 当一个对象调用未实现的方法，会调用这个方法处理,并且会把对应的方法列表传过来.
// 刚好可以用来判断，未实现的方法是不是我们想要动态添加的方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if (sel == @selector(eat)) {
        // 动态添加eat方法
        // 第一个参数：给哪个类添加方法
        // 第二个参数：添加方法的方法编号
        // 第三个参数：添加方法的函数实现（函数地址）
        // 第四个参数：函数的类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
        class_addMethod(self, @selector(eat), eat, "v@:");
    }
    return [super resolveInstanceMethod:sel];
}
@end
```

#### 字典转模型
```
// Ivar:成员变量 以下划线开头
// Property:属性
+ (instancetype)modelWithDict:(NSDictionary *)dict{
    id objc = [[self alloc] init];
    // runtime:根据模型中属性,去字典中取出对应的value给模型属性赋值
    // 1.获取模型中所有成员变量 key
    // 获取哪个类的成员变量
    // count:成员变量个数
    unsigned int count = 0;
    // 获取成员变量数组
    Ivar *ivarList = class_copyIvarList(self, &count);
    // 遍历所有成员变量
    for (int i = 0; i < count; i++) {
        // 获取成员变量
        Ivar ivar = ivarList[i];
        // 获取成员变量名字
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 获取成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        // @"User" -> User
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@""" withString:@""];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        // 获取key
        NSString *key = [ivarName substringFromIndex:1];
        // 去字典中查找对应value
        // key:user  value:NSDictionary
        id value = dict[key];
        
        // 二级转换:判断下value是否是字典,如果是,字典转换层对应的模型
        // 并且是自定义对象才需要转换
        if ([value isKindOfClass:[NSDictionary class]] && ![ivarType hasPrefix:@"NS"]) {
            // 字典转换成模型 userDict => User模型
            // 转换成哪个模型

            // 获取类
            Class modelClass = NSClassFromString(ivarType);
            value = [modelClass modelWithDict:value];
        }
        
        // 给模型中属性赋值
        if (value) {
            [objc setValue:value forKey:key];
        }
    }
        
    return objc;
}
```

#### 崩溃防护（消息转发）

```
#import "MJPerson.h"
@implementation MJPerson
- (void)run{
    NSLog(@"run-123");
}

// MARK: - 防止出现方法找不到的崩溃
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    // 本来能调用的方法
    if ([self respondsToSelector:aSelector]) {
        return [super methodSignatureForSelector:aSelector];
    }
    // 找不到的方法
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

// 找不到的方法，都会来到这里
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"找不到%@方法", NSStringFromSelector(anInvocation.selector));
}
@end
```