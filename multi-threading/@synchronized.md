# `@synchronized`

```
int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
        @synchronized (appDelegateClassName) {
        }
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
```
通过xcrun查看底层代码编译：

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fd765fad787641b5a0423966dd8d1d1b~tplv-k3u1fbpfcp-watermark.image?)

通过上面查看`.cpp`代码，知道`@synchronized`核心的方法是`objc_sync_enter`和`objc_sync_exit`方法

## `objc_sync_enter`探究
在`Objc`源码库中全局搜索 `objc_sync_enter`
```
// 从'obj'开始同步。
// 递归分配与obj关联的互斥锁。
// 一旦获得锁，返回OBJC_SYNC_SUCCESS。
int objc_sync_enter(id obj)
{
    int result = OBJC_SYNC_SUCCESS;
    // 根据obj是否存在判断流程
    if (obj) {
        // 获取底层封装的 SyncData
        SyncData* data = id2data(obj, ACQUIRE);
        ASSERT(data);
        data->mutex.lock();// 加锁
    } else {
        // @synchronized(nil) does nothing
        if (DebugNilSync) {
            _objc_inform("NIL SYNC DEBUG: @synchronized(nil); set a breakpoint on objc_sync_nil to debug");
        }
        objc_sync_nil();
    }
    return result;
}
```
-   首先判断`obj`是否为`nil`，注意`obj`是`id`类型，`id`是对象指针类型`objc_object*`
-   如果`obj`有值走加锁的流程
-   如果`obj` = `nil`根据注释`@synchronized(nil) does nothing`什么也不操作，里面调用了`objc_sync_nil()`方法

全局搜索`objc_sync_nil()`方法

```
#   define BREAKPOINT_FUNCTION(prototype)  \
    OBJC_EXTERN __attribute__((noinline, used, visibility("hidden"))) \
    prototype { asm(""); }
    
BREAKPOINT_FUNCTION(
    void objc_sync_nil(void)
);
```
`BREAKPOINT_FUNCTION` 是一个宏定义`void objc_sync_nil(void)`是一个参数。相当于 `define BREAKPOINT_FUNCTION(prototype)`中的`prototype`，而`prototype`的实现就是啥也没做，简单理解就是如果`obj` = `nil`相当于没加锁

总结：`objc_sync_enter`方法是加锁的过程，如果`obj`参数不为`nil`就走加锁流程，否则相当于没有加锁
## `objc_sync_exit`探究
在`Objc`源码库中全局搜索 `objc_sync_exit`

```
// 结束'obj'同步。
// 返回OBJC_SYNC_SUCCESS或OBJC_SYNC_NOT_OWNING_THREAD_ERROR
int objc_sync_exit(id obj)
{
    int result = OBJC_SYNC_SUCCESS;
    // 根据obj是否存在判断流程
    if (obj) {
        SyncData* data = id2data(obj, RELEASE); 
        if (!data) {
            result = OBJC_SYNC_NOT_OWNING_THREAD_ERROR;
        } else {
            bool okay = data->mutex.tryUnlock();//解锁
            if (!okay) {
                result = OBJC_SYNC_NOT_OWNING_THREAD_ERROR;
            }
        }
    } else {
        //如果 obj = nil 什么也不做
        // @synchronized(nil) does nothing
    }
    return result;
}
```
`objc_sync_exit`方法和`objc_sync_enter`方法是对应的。`objc_sync_exit`方法就是解锁功能，如果`obj`= `nil` 什么也不做

总结：

-   `objc_sync_enter`方法作用是任务开始时进行加锁操作，而`objc_sync_exit`方法作用是在任务结束时进行解锁操作。如果参数为`nil`相当于没有加锁解锁的作用，这就是`@synchronized`内部自己实现的加锁解锁功能
-   在`objc_sync_enter`方法和`objc_sync_exit`方法都有`id2data`方法而且加锁解锁的功能也是通过`id2data`方法的返回值调用的。下面探究下`id2data`方法

## `id2data`方法探究
`id2data`方法源码比较多，先理一下整体流程，然后在对每一部分进行详细的探究

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6da59741270c443abcc2eb7a26afdc00~tplv-k3u1fbpfcp-watermark.image?)
图中的整体流程如下

-   首先从`tls`（线程局部存储）中查找`SyncData`，如果查找到就走其相应的流程
-   如果`tls`没有查找到，就到线程缓存中去查找，如果缓存中有走缓存中的流程
-   如果缓存中没有，判断哈希表中是否存储对应的`SyncData`，如果`SyncData`存在就进行多线程操作同一对象的流程
-   如果都没有则表示是第一次进来，此时创建`SyncData`

上面代码中说到了`SyncData`、哈希表`StripedMap`以及`SyncCache`
#### `SyncData`结构分析

```
typedef struct alignas(CacheLineSize) SyncData {
    struct SyncData* nextData;// 相同的数据类型 单向链表形式
    DisguisedPtr<objc_object> object; // 将object进行底层封装
    // 多少线程对同一对象进行加锁的操作
    int32_t threadCount;  // number of THREADS using this block
    recursive_mutex_t mutex;// 递归锁
} SyncData;
```
`SyncData`是一个结构体类型，里面有`4`个变量

-   `struct SyncData* nextData`：和`SyncData`相同的数据类型单向链表的形式
-   `DisguisedPtr<objc_object> object`：将`object`进行底层封装，方便计算比较。关联对象也有其封装
-   `threadCount`：多少线程对同一对象进行加锁的操作
-   `recursive_mutex_t mutex`：递归锁

#### `StripedMap` 结构分析

```
#define LOCK_FOR_OBJ(obj) sDataLists[obj].lock
#define LIST_FOR_OBJ(obj) sDataLists[obj].data
static StripedMap<SyncList> sDataLists;
// SyncList
struct SyncList {
    SyncData *data;
    spinlock_t lock;

    constexpr SyncList() : data(nil), lock(fork_unsafe_lock) { }
};
// StripedMap
template<typename T>
class StripedMap {
#if TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR
    enum { StripeCount = 8 };
#else
    enum { StripeCount = 64 };
#endif
   ...//省略部分代码
}
```
`StripedMap`是一张哈希表在真机情况的存储`SyncList`个数是`8`个，其它环境`64`个。`SyncList`是一个结构体有两个变量`SyncData *data` 和 `lock`
#### `SyncCache`结构分析

```
typedef struct {
    SyncData *data;
    unsigned int lockCount;  // number of times THIS THREAD locked this block
} SyncCacheItem;

typedef struct SyncCache {
    unsigned int allocated;//开辟SyncCacheItem内存空间的个数
    unsigned int used;//被使用的个数
    SyncCacheItem list[0];
} SyncCache;
```
`SyncCache`是一个结构体，每个线程缓存对应一个`SyncCache`.`SyncCacheItem`表示每个对象锁的信息。`SyncCacheItem`也是一个结构体里面包含了`SyncData`和`lockCount`当前线程当前对象锁的次数

### `tls`中查找`data`

`tls` 线程局部存储：是操作系统为线程单独提供的私有空间，通常只有有限的容量。每个线程都会有独立的 `tls`

```
// Check per-thread single-entry fast cache for matching object
// 检查每个线程的单条目快速缓存是否匹配对象
bool fastCacheOccupied = NO;
// 1.从线程的局部存储中查找data
SyncData *data = (SyncData *)tls_get_direct(SYNC_DATA_DIRECT_KEY);
if (data) {
    fastCacheOccupied = YES; // 如果fastCacheOccupied = YES
    // 如果 data->object 和 object相等
    if (data->object == object) {
        // Found a match in fast cache.
        uintptr_t lockCount; // 被锁的次数
        result = data; // 在tls中查找的data 赋值给result
        // 初始化的lockCount = 1 存储 key = SYNC_COUNT_DIRECT_KEY 的tls中
        lockCount = (uintptr_t)tls_get_direct(SYNC_COUNT_DIRECT_KEY);
        if (result->threadCount <= 0  ||  lockCount <= 0) {
            _objc_fatal("id2data fastcache is buggy");
        }

        switch(why) {
        case ACQUIRE: { // 加锁的标识
            lockCount++; // lockCount ++  说明此锁是可以递归的
            tls_set_direct(SYNC_COUNT_DIRECT_KEY, (void*)lockCount); // 更新tls中lockCount的值
            break;
        }
        case RELEASE: // 解锁的标识
            lockCount--;
            tls_set_direct(SYNC_COUNT_DIRECT_KEY, (void*)lockCount); // 更新tls中lockCount的值
            if (lockCount == 0) {
                // remove from fast cache
                // 如果 lockCount = 0 表示当前线程全部解锁，tls中的data设置为nil
                tls_set_direct(SYNC_DATA_DIRECT_KEY, NULL);
                // atomic because may collide with concurrent ACQUIRE
                // 线程threadCount个数进行减1
                OSAtomicDecrement32Barrier(&result->threadCount);
            }
            break;
        case CHECK:
            // do nothing
            break;
        }
        // 直接返回 result
        return result;
    }
}
```
`tls`查找流程

-   首先在`tls`查到`data`，如果`data`有值`fastCacheOccupied` = `YES`
-   如果`data->object` == `object`表示加锁的是同一个对象，此时把在`tls`中查找的`data`赋值给`result`
-   如果`why`是`ACQUIRE`表示加锁，此时`lockCount++`，并把`lockCount`更新到`tls`中
-   如果`why`是`RELEASE`表示解锁，此时`lockCount--`，并把`lockCount`更新到`tls`中，`如果lockCount` == `0`表示当前线程中没有加锁的对象或者已经全部解锁。此时`threadCount`减`1`，返回`result`
-   如果`data->object`和`object`不是同一个对象则进行线程缓存查找流程
### 线程缓存查找流程

```
// 检查已拥有锁的每个线程缓存，以查找匹配的对象
// 2.从线程缓存中查找如果fetch_cache(NO)参数是NO表示去只是去查找
SyncCache *cache = fetch_cache(NO);
if (cache) {
    unsigned int i;
    // 遍历缓存中的 SyncCacheItem
    for (i = 0; i < cache->used; i++) {
        SyncCacheItem *item = &cache->list[i];
        if (item->data->object != object) continue;
        // Found a match.
        result = item->data; // 如果线程缓存中查找到item将item->data赋值给result
        if (result->threadCount <= 0  ||  item->lockCount <= 0) {
            _objc_fatal("id2data cache is buggy");
        }
            
        switch(why) {
        case ACQUIRE: // 加锁的标识
            item->lockCount++;
            break;
        case RELEASE: // 解锁的标识
            item->lockCount--;
            if (item->lockCount == 0) {
                // remove from per-thread cache
                // 将当前的item中的数据设置为空的数据，然后cache->used被使用的个数进行减减
                cache->list[i] = cache->list[--cache->used];
                // atomic because may collide with concurrent ACQUIRE
                // 线程threadCount个数进行减一
                OSAtomicDecrement32Barrier(&result->threadCount);
            }
            break;
        case CHECK:
            // do nothing
            break;
        }
        // 如果线程缓存中查询到就直接返回result
        return result;
    }
}
```
线程缓存的查找流程和`tls`查找流程基本相似，就是数据结构的类型不同。在线程缓存中通过遍历查找需要加锁的对象，详细的流程上面注释的很清楚

#### `fetch_cache`探究

```
static SyncCache *fetch_cache(bool create)
{
    _objc_pthread_data *data;
    
    //查询或者创建线程数据
    data = _objc_fetch_pthread_data(create);
    if (!data) return NULL;// 如果data = nil 返回NULL

    if (!data->syncCache) {
        if (!create) {
            return NULL;
        } else {
            // 首次创建 4 个 SyncCacheItem
            int count = 4;
            // 开辟内存空间
            data->syncCache = (SyncCache *)
                calloc(1, sizeof(SyncCache) + count*sizeof(SyncCacheItem));
            // 初始化的个数等于 4 
            data->syncCache->allocated = count;
        }
    }

    // Make sure there's at least one open slot in the list.
    // 下面进行扩容操作如果初始的个数和使用的个数相等 则进行两倍扩容
    if (data->syncCache->allocated == data->syncCache->used) {
        // 两倍扩容
        data->syncCache->allocated *= 2;
        // 开辟空间
        data->syncCache = (SyncCache *)
            realloc(data->syncCache, sizeof(SyncCache) 
                    + data->syncCache->allocated * sizeof(SyncCacheItem));
    }

    return data->syncCache;
}
```
-   根据`create`去查找线程数据`_objc_pthread_data`，如果`data`不存在直接返回`NULL`

-   如果`data->syncCache`不存在且`create`== `YES`去为`SyncCache`和`SyncCacheItem`开辟内存空间第一次开辟`4`个`SyncCacheItem`，初始化的个数`allocated` = `4`。每个`SyncCacheItem`里面的默认数据都是`0`

-   如果初始化的个数和使用的个数相进行`2`倍扩容。返回`SyncCache`
#### `_objc_fetch_pthread_data`探究

```
 _objc_pthread_data *_objc_fetch_pthread_data(bool create)
{
    _objc_pthread_data *data;
    // 先去tls查找线程数据，如果data存在直接返回
    // 如果data不存在且create = NO 返回nil
    data = (_objc_pthread_data *)tls_get(_objc_pthread_key);
    // 如果data不存在且create = YES 则去开辟内存创建_objc_pthread_data
    if (!data  &&  create) {
        data = (_objc_pthread_data *)
            calloc(1, sizeof(_objc_pthread_data));
        tls_set(_objc_pthread_key, data);
    }
    return data;
}
```
`_objc_fetch_pthread_data`流程

-   在`tls`中查找`_objc_pthread_data`，如果查询到直接返回`data`
-   如果`data`不存在且`create` = `NO`，返回`nil`
-   如果`data`不存在且`create` = `YES`，则去开辟内存创建`_objc_pthread_data`

所以在`create` = `NO`只会去`tls`中查找`data`，`create` = `YES`先去查找`data`，如果没有就去开 辟内存创建data

### 多线程加锁同一对象

为什么说下面这段代码是多线程加锁同一对象呢，因为如果是单个线程内存操作会直接走上面的`tls`查找流程和线程缓存查找流程

```
lockp->lock();
// 多线程操作流程
{
    SyncData* p;
    SyncData* firstUnused = NULL;
    // 哈希表中的SyncList的data如果有值即*listp有值
    // 遍历循环单向链表中的SyncData
    for (p = *listp; p != NULL; p = p->nextData) {
        //查询到需要加锁的对象
        if ( p->object == object ) {
            result = p; // 赋值操作
            // atomic because may collide with concurrent RELEASE
            // 线程数threadCount进行加1操作，threadCount多个线程对该对象进行加锁操作
            OSAtomicIncrement32Barrier(&result->threadCount);
            // 跳转到done流程。此时的result还是存在各个线程的tls中或者线程缓存中
            goto done;
        }
        if ( (firstUnused == NULL) && (p->threadCount == 0) )
            firstUnused = p;
    }
    ...
}
```
多线程操作流程

-   首先会根据`object`在哈希表中找到下标对应的`SyncList`，然后判断`SyncList`的`data`有值
-   如果`SyncList`的`data`有值中有值，则在单向链表找到相应的加锁对象，进行`threadCount++`操作，然后跳转`done`流程，在`done`流程里存储在对应线程的`tls`中或者线程缓存中

### 创建`SyncData`

```
posix_memalign((void **)&result, alignof(SyncData), sizeof(SyncData));
// 赋值操作
result->object = (objc_object *)object;
result->threadCount = 1; // 默认 threadCount = 1
new (&result->mutex) recursive_mutex_t(fork_unsafe_lock); // 创建一个递归锁
result->nextData = *listp; // 哈希下标如果一样头插法形成链表的形式
*listp = result; // 更新哈希表中的值
```
-   第一次给对象加锁时，会创建一个`SyncData`，简单的说就是一个`SyncData`绑定一个对象，一个对象有且只有一个`SyncData`
-   如果不同对象哈希的下标是一样的这样就会形成单向链表，而插入的方式采用的是头插法

### `done`流程

```
done:
    lockp->unlock();
    if (result) {
        // Only new ACQUIRE should get here.
        // All RELEASE and CHECK and recursive ACQUIRE are 
        // handled by the per-thread caches above.
        if (why == RELEASE) { 
            // Probably some thread is incorrectly exiting 
            // while the object is held by another thread.
            return nil;
        }
        if (why != ACQUIRE) _objc_fatal("id2data is buggy");
        if (result->object != object) _objc_fatal("id2data is buggy");

#if SUPPORT_DIRECT_THREAD_KEYS
        // fastCacheOccupied = NO 表示当前线程的tls里面没有数据
        // 此时把第一次需要加锁创建的SyncData和lockCout = 1 存储在tls
        if (!fastCacheOccupied) {
            // Save in fast thread cache
            tls_set_direct(SYNC_DATA_DIRECT_KEY, result);
            tls_set_direct(SYNC_COUNT_DIRECT_KEY, (void*)1);
        } else 
#endif
        {   //当在同一线程对另一个对象进行加锁注意（上一个加锁的对象没有进行解锁）
            //此时的SyncData和lockCount存储在线程缓存中
            // Save in thread cache
            if (!cache) cache = fetch_cache(YES);
            cache->list[cache->used].data = result;
            cache->list[cache->used].lockCount = 1;
            cache->used++;
        }
    }
    return result;
```
`done`流程

-   当前线程第一个进行加锁操作的对象，此时会把`SyncData`和`lockCout`=`1` 存储在`tls`，而且当前线程的`tls`不会改变除非解锁。一个线程的`tls`只存储第一次加锁的`SyncData`和`lockCout`
-   当在同一线程对另一个对象进行加锁注意（上一个加锁的对象没有进行解锁），此时的`SyncData`和`lockCount`存储在线程缓存中

至此整个`id2data`方法的源码已经探究完，下面通过案例分析下
### 单线程单对象递归加锁

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        YJPerson * p = [YJPerson alloc];
        @synchronized (p) {
            NSLog(@"p第一次进来");
            @synchronized (p) {
                NSLog(@"p第二次进来");
                @synchronized (p ) {
                    NSLog(@"p第三次进来");
                };
            };
        };
    }
    return 0;
}
```
在第一个`@synchronized`打下断点进行调试

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a32ced548bd54d05916765e374e588f9~tplv-k3u1fbpfcp-watermark.image?)
第一次给对象加锁`*listp`、`data`以及`cache`都是空，说哈希表中和tls以及线程缓存中都没有查找到。 那么就会进入创建`SyncData`流程,为了方便测试我把在非真机状态下的 `StripeCount` = `2`

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/633b97163ac04158a905a0b8ce38107d~tplv-k3u1fbpfcp-watermark.image?)

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/a64e1d0c7bbb4969b3b270b7a8733bd0~tplv-k3u1fbpfcp-watermark.image?)
图中显示此时的哈希表中的数据都是空的没有数据，断点往下走一步，继续调试

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/71f13091bae74bd3b3468ee57fa0e072~tplv-k3u1fbpfcp-watermark.image?)
`*listp = result`更新哈希表中`data`的值，此时`result`的`nextData`等于`*listp`，`*listp`前面打印的值是空的，所以`result`的`nextData`也是空的，`*listp = result`以后此时`*listp`已经被赋值。继续调试走到`done`流程

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f3626cf2ef154ac78fdc3942e3472f16~tplv-k3u1fbpfcp-watermark.image?)
图中断点显示此时第一次创建的`SyncData`和`lockCount`存储在`tls`中

在第二个`@synchronized`打下断点进行调试

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/6c724ef078bc4b81a58649e77e71d604~tplv-k3u1fbpfcp-watermark.image?)
对同一个对象再次加锁此时`*listp`和`data`都有值，那么此时会走到`tls`查找`data`的流程， `lockCount` = `2`说明又加锁一次，然后更新`tls`中`lockCount`的值，然后直接返回`result`

在第三个`@synchronized`打下断点进行调试

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/10095c22e03e4e379ad18ef6f482f3ab~tplv-k3u1fbpfcp-watermark.image?)
很明显在单线程中对同一个对象进行递归加锁，`SyncData`和`lockCount`存储在`tls`，而没有缓存的事

### 单线程多对象递归加锁

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        YJPerson * p  = [YJPerson alloc];
        YJPerson * p1 = [YJPerson alloc];
        YJPerson * p2 = [YJPerson alloc];

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @synchronized (p) {
                NSLog(@"p第一次进来");
                @synchronized (p1) {
                    NSLog(@"p1第二次进来");
                    @synchronized (p2) {
                        NSLog(@"p2第三次进来");
                    };
                };
            };
        });
        do {  } while (1);
    }
    return 0;
}
```
在第一个`@synchronized`打下断点进行调试  
对`p`对象进行加锁，此时创建的`SyncData`和`lockCount`存储在`tls`中，这个上面已经探究过了

在第二个`@synchronized`打下断点进行调试

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/205e7bfb36b14105ac5a11caf7ac2d3e~tplv-k3u1fbpfcp-watermark.image?)
`*listp`有值说明`p`和`p1`的哈希下标是一样的，此时`cache`中也没有数据，`tls`中的是有`data`不过和`p1`不是同一个对象，所以此时会重新创建`SyncData`，然后用头插法的方式形成单向链表

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e79420778c1e44b7be57ea7389489aad~tplv-k3u1fbpfcp-watermark.image?)
最新创建的`SyncData`放在拉链的最前面，此时`p1`的`SyncData`的`nextData`存储着`p`的`SyncData`地址

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4fe99b1bbd94481b85c6baf905a1bc3f~tplv-k3u1fbpfcp-watermark.image?)
因为当前线程的`tls`中是有`data`的而且不会改变，所以`fastCacheOccupied` = `YES`，在走`done`流程就会存储在线程缓存中，如果后面还有其它对象需要加锁，也都会储存在缓存中。解锁的时候缓存的数据会被清空

### 多线程递归加锁

```
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        YJPerson * p  = [YJPerson alloc];
        YJPerson * p1 = [YJPerson alloc];
        dispatch_queue_t  queue = dispatch_queue_create("YJ", DISPATCH_QUEUE_CONCURRENT);
        for (int i = 0; i<10;i++) {
            dispatch_async(queue, ^{
                @synchronized (p) {
                    NSLog(@"p第一次进来");
                    @synchronized (p1) {
                        NSLog(@"p第一次进来");
                    };
                };
            });
        }
        do {
        } while (1);
    }
    return 0;
}
```
在 `@synchronized (p1)`打下断点进行调试

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ce64506dcc0d46d8b1f6dff20928562f~tplv-k3u1fbpfcp-watermark.image?)
哈希表中只有一个`SyncList`有值，而且`SyncData`里面的值`threadCount` = `10`，说明走了多线程的流程。而`nextData`的值为空，说明此时只有一个对象进行了多线程加锁，如果多线程多对象实际就是每个对象走单个对象的加锁流程

# `@synchronized`总结

-   `objc_sync_exit`流程和`objc_sync_enter`流程走的是一样的只不过一个是加锁一个是解锁
-   `@synchronized`底层是链表查找、缓存查找以及递归，是非常耗内存以及性能的
-   `@synchronized`底层封装了是一把递归锁，可以自动进行加锁解锁，这也是大家喜欢使用它的原因
-   `@synchronized`中`lockCount`控制递归，而`threadCount`控制多线程
-   `@synchronized`加锁的对象尽量不要为`nil`，不然起不到加锁的效果